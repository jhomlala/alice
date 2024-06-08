import 'dart:async' show FutureOr;
import 'dart:convert' show utf8;
import 'dart:io' show HttpHeaders;

import 'package:alice/core/alice_adapter.dart';
import 'package:alice/core/alice_utils.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_http_request.dart';
import 'package:alice/model/alice_http_response.dart';
import 'package:chopper/chopper.dart';
import 'package:http/http.dart' as http;

class AliceChopperAdapter with AliceAdapter implements Interceptor {
  /// Creates hashcode based on request
  int getRequestHashCode(http.BaseRequest baseRequest) {
    final int hashCodeSum = baseRequest.url.hashCode +
        baseRequest.method.hashCode +
        (baseRequest.headers.entries
            .map((MapEntry<String, String> header) =>
                header.key.hashCode + header.value.hashCode)
            .reduce((int value, int hashCode) => value + hashCode)) +
        (baseRequest.contentLength?.hashCode ?? 0);

    return hashCodeSum.hashCode;
  }

  /// Handles chopper request and creates alice http call
  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(
    Chain<BodyType> chain,
  ) async {
    final Response<BodyType> response = await chain.proceed(chain.request);

    try {
      aliceCore.addCall(
        AliceHttpCall(getRequestHashCode(chain.request))
          ..method = chain.request.method
          ..endpoint =
              chain.request.url.path.isEmpty ? '/' : chain.request.url.path
          ..server = chain.request.url.host
          ..secure = chain.request.url.scheme == 'https'
          ..uri = chain.request.url.toString()
          ..client = 'Chopper'
          ..request = (AliceHttpRequest()
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
            ..queryParameters = chain.request.parameters)
          ..response = (AliceHttpResponse()
            ..status = response.statusCode
            ..body = response.body ?? ''
            ..size = response.body != null
                ? utf8.encode(response.body.toString()).length
                : 0
            ..time = DateTime.now()
            ..headers = <String, String>{
              for (final MapEntry<String, String> entry
                  in response.headers.entries)
                entry.key: entry.value
            }),
      );
    } catch (exception) {
      AliceUtils.log(exception.toString());
    }

    return response;
  }
}