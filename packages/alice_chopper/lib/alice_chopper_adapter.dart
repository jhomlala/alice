import 'dart:async' show FutureOr;
import 'dart:convert' show utf8;
import 'dart:io' show HttpHeaders;

import 'package:alice/model/alice_form_data_file.dart';
import 'package:alice/model/alice_from_data_field.dart';
import 'package:flutter/foundation.dart';
import 'package:alice/core/alice_adapter.dart';
import 'package:alice/core/alice_utils.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_http_error.dart';
import 'package:alice/model/alice_http_request.dart';
import 'package:alice/model/alice_http_response.dart';
import 'package:alice/model/alice_log.dart';
import 'package:chopper/chopper.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class AliceChopperAdapter with AliceAdapter implements Interceptor {
  /// Creates hashcode based on request
  int getRequestHashCode(http.BaseRequest baseRequest) {
    final int hashCodeSum =
        baseRequest.url.hashCode +
        baseRequest.method.hashCode +
        baseRequest.headers.entries.fold<int>(
          0,
          (int previousValue, MapEntry<String, String> header) =>
              previousValue + header.key.hashCode + header.value.hashCode,
        ) +
        (baseRequest.contentLength?.hashCode ?? 0);

    return hashCodeSum.hashCode;
  }

  /// Handles chopper request and creates alice http call
  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(
    Chain<BodyType> chain,
  ) async {
    final int requestId = getRequestHashCode(
      /// The alice_token header is added to the request in order to keep track
      /// of the request in the AliceCore instance.
      applyHeader(chain.request, 'alice_token', const Uuid().v4()),
    );

    aliceCore.addCall(
      AliceHttpCall(requestId)
        ..method = chain.request.method
        ..endpoint =
            chain.request.url.path.isEmpty ? '/' : chain.request.url.path
        ..server = chain.request.url.host
        ..secure = chain.request.url.scheme == 'https'
        ..uri = chain.request.url.toString()
        ..client = 'Chopper'
        ..request =
            (AliceHttpRequest()
              ..size = switch (chain.request.body) {
                dynamic body when body is String => utf8.encode(body).length,
                dynamic body when body is List<int> => body.length,
                dynamic body when body == null => 0,
                _ => utf8.encode(body.toString()).length,
              }
              ..body = chain.request.body ?? ''
              ..time = DateTime.now()
              ..headers = chain.request.headers
              ..contentType =
                  chain.request.headers[HttpHeaders.contentTypeHeader] ??
                  'unknown'
              ..formDataFields =
                  chain.request.parts
                      .whereType<PartValue>()
                      .map(
                        (field) => AliceFormDataField(field.name, field.value),
                      )
                      .toList()
              ..formDataFiles =
                  chain.request.parts
                      .whereType<PartValueFile>()
                      .map((file) => AliceFormDataFile(file.value, "", 0))
                      .toList()
              ..queryParameters = chain.request.parameters)
        ..response = AliceHttpResponse(),
    );

    try {
      final Response<BodyType> response = await chain.proceed(chain.request);

      aliceCore.addResponse(
        AliceHttpResponse()
          ..status = response.statusCode
          ..body = response.body ?? ''
          ..size = switch (response.body) {
            dynamic body when body is String => utf8.encode(body).length,
            dynamic body when body is List<int> => body.length,
            dynamic body when body == null => 0,
            _ => utf8.encode(body.toString()).length,
          }
          ..time = DateTime.now()
          ..headers = <String, String>{
            for (final MapEntry<String, String> entry
                in response.headers.entries)
              entry.key: entry.value,
          },
        requestId,
      );

      if (!response.isSuccessful || response.error != null) {
        aliceCore.addError(AliceHttpError()..error = response.error, requestId);
      }

      return response;
    } catch (error, stackTrace) {
      /// Log error to Alice log
      AliceUtils.log(error.toString());

      aliceCore.addLog(
        AliceLog(
          message: error.toString(),
          level: DiagnosticLevel.error,
          error: error,
          stackTrace: stackTrace,
        ),
      );

      /// Add empty response to Alice core
      aliceCore.addResponse(AliceHttpResponse()..status = -1, requestId);

      /// Add error to Alice core
      aliceCore.addError(
        AliceHttpError()
          ..error = error
          ..stackTrace = stackTrace,
        requestId,
      );

      /// Rethrow error
      rethrow;
    }
  }
}
