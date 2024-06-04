import 'dart:async' show FutureOr;
import 'dart:convert' show utf8;

import 'package:alice/core/alice_core.dart';
import 'package:alice/core/alice_utils.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_http_request.dart';
import 'package:alice/model/alice_http_response.dart';
import 'package:chopper/chopper.dart';
import 'package:http/http.dart' as http;

extension on String {
  String stripTrailingSlash() =>
      endsWith('/') ? substring(0, length - 1) : this;
}

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
    Chain<BodyType> chain,
  ) async {
    try {
      final Map<String, String> headers = chain.request.headers;
      headers['alice_token'] = DateTime.now().millisecondsSinceEpoch.toString();
      final Request changedRequest = chain.request.copyWith(headers: headers);
      final http.BaseRequest baseRequest = await changedRequest.toBaseRequest();

      final AliceHttpCall call = AliceHttpCall(getRequestHashCode(baseRequest));
      final StringBuffer endpoint = StringBuffer();
      final StringBuffer server = StringBuffer();

      final List<String> split = chain.request.url.toString().split('/');
      if (split.length > 2) {
        server.writeAll([
          split[1],
          split[2],
        ]);
      }
      if (split.length > 4) {
        endpoint.write('/');
        for (int splitIndex = 3; splitIndex < split.length; splitIndex++) {
          endpoint.writeAll([
            split[splitIndex],
            '/',
          ]);
        }
      }

      call
        ..method = chain.request.method
        ..endpoint = endpoint.toString().stripTrailingSlash()
        ..server = server.toString()
        ..client = 'Chopper';
      if (chain.request.url.toString().contains('https')) {
        call.secure = true;
      }

      final AliceHttpRequest aliceHttpRequest = AliceHttpRequest();

      if (chain.request.body == null) {
        aliceHttpRequest
          ..size = 0
          ..body = '';
      } else {
        aliceHttpRequest
          ..size = utf8.encode(chain.request.body as String).length
          ..body = chain.request.body;
      }
      aliceHttpRequest
        ..time = DateTime.now()
        ..headers = chain.request.headers;

      String? contentType = 'unknown';
      if (chain.request.headers.containsKey('Content-Type')) {
        contentType = chain.request.headers['Content-Type'];
      }
      aliceHttpRequest
        ..contentType = contentType
        ..queryParameters = chain.request.parameters;

      call
        ..request = aliceHttpRequest
        ..response = AliceHttpResponse();

      aliceCore.addCall(call);
    } catch (exception) {
      AliceUtils.log(exception.toString());
    }

    final Response<BodyType> response = await chain.proceed(chain.request);

    /// Adds data to existing alice http call
    aliceCore.addResponse(
      AliceHttpResponse()
        ..status = response.statusCode
        ..body = response.body ?? ''
        ..size = response.body != null
            ? utf8.encode(response.body.toString()).length
            : 0
        ..time = DateTime.now()
        ..headers = <String, String>{
          for (final MapEntry<String, String> entry in response.headers.entries)
            entry.key: entry.value
        },
      getRequestHashCode(response.base.request!),
    );

    return response;
  }
}
