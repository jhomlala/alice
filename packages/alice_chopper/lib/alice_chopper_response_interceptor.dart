import 'dart:async' show FutureOr;
import 'dart:convert' show utf8;
import 'dart:io' show HttpHeaders;

import 'package:alice/core/alice_core.dart';
import 'package:alice/core/alice_utils.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_http_request.dart';
import 'package:alice/model/alice_http_response.dart';
import 'package:chopper/chopper.dart';
import 'package:http/http.dart' as http;

class AliceChopperInterceptor implements Interceptor {
  /// AliceCore instance
  final AliceCore aliceCore;

  /// Creates instance of chopper interceptor
  AliceChopperInterceptor(this.aliceCore);

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
      Chain<BodyType> chain,) async {
    final Response<BodyType> response = await chain.proceed(chain.request);

    try {
      final AliceHttpCall call = AliceHttpCall(
        getRequestHashCode(
          applyHeader(
            chain.request,
            'alice_token',
            DateTime
                .now()
                .millisecondsSinceEpoch
                .toString(),
          ),
        ),
      )
        ..method = chain.request.method
        ..endpoint =
        chain.request.url.path.isEmpty ? '/' : chain.request.url.path
        ..server = chain.request.url.host
        ..secure = chain.request.url.scheme == 'https'
        ..uri = chain.request.url.toString()
        ..client = 'Chopper';

      final AliceHttpRequest aliceHttpRequest = AliceHttpRequest();

      if (chain.request.body == null) {
        aliceHttpRequest
          ..size = 0
          ..body = '';
      } else {
        aliceHttpRequest
          ..size = utf8
              .encode(chain.request.body as String)
              .length
          ..body = chain.request.body;
      }
      aliceHttpRequest
        ..time = DateTime.now()
        ..headers = chain.request.headers;

      String? contentType = 'unknown';
      if (chain.request.headers.containsKey(HttpHeaders.contentTypeHeader)) {
        contentType = chain.request.headers[HttpHeaders.contentTypeHeader];
      }
      aliceHttpRequest
        ..contentType = contentType
        ..queryParameters = chain.request.parameters;

      call
        ..request = aliceHttpRequest
        ..response = (AliceHttpResponse()
          ..status = response.statusCode
          ..body = response.body ?? ''
          ..size = response.body != null
              ? utf8
              .encode(response.body.toString())
              .length
              : 0
          ..time = DateTime.now()
          ..headers = <String, String>{
            for (final MapEntry<String, String> entry
            in response.headers.entries)
              entry.key: entry.value
          });

      aliceCore.addCall(call);
    } catch (exception) {
      AliceUtils.log(exception.toString());
    }

    return response;
  }
}
