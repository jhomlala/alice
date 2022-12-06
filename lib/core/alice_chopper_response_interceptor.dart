import 'dart:async';
import 'dart:convert';

import 'package:alice/core/alice_utils.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_http_request.dart';
import 'package:alice/model/alice_http_response.dart';
import 'package:chopper/chopper.dart' as chopper;
import 'package:http/http.dart';

import 'alice_core.dart';

class AliceChopperInterceptor extends chopper.ResponseInterceptor
    with chopper.RequestInterceptor {
  /// AliceCore instance
  final AliceCore aliceCore;

  /// Creates instance of chopper interceptor
  AliceChopperInterceptor(this.aliceCore);

  /// Creates hashcode based on request
  int getRequestHashCode(BaseRequest baseRequest) {
    int hashCodeSum = 0;
    hashCodeSum += baseRequest.url.hashCode;
    hashCodeSum += baseRequest.method.hashCode;
    if (baseRequest.headers.isNotEmpty) {
      baseRequest.headers.forEach((key, value) {
        hashCodeSum += key.hashCode;
        hashCodeSum += value.hashCode;
      });
    }
    if (baseRequest.contentLength != null) {
      hashCodeSum += baseRequest.contentLength.hashCode;
    }

    return hashCodeSum.hashCode;
  }

  /// Handles chopper request and creates alice http call
  @override
  FutureOr<chopper.Request> onRequest(chopper.Request request) async {
    try {
      final baseRequest = await request.toBaseRequest();
      final call = AliceHttpCall(getRequestHashCode(baseRequest));

      final aliceHttpRequest = AliceHttpRequest();
      aliceHttpRequest.body = request.body?.toString() ?? '';
      aliceHttpRequest.size =
          utf8.encode(aliceHttpRequest.body.toString()).length;
      aliceHttpRequest.time = DateTime.now();
      aliceHttpRequest.headers = request.headers;
      aliceHttpRequest.contentType =
          request.headers['Content-Type'] ?? 'unknown';
      aliceHttpRequest.queryParameters = request.parameters;

      call.request = aliceHttpRequest;
      call.method = request.method;
      call.endpoint = request.url.path;
      call.server = request.url.origin;
      call.client = 'Chopper';
      call.secure = request.url.scheme.contains('https');
      call.response = AliceHttpResponse();

      aliceCore.addCall(call);
    } catch (exception) {
      AliceUtils.log(exception.toString());
    }
    return request;
  }

  /// Handles chopper response and adds data to existing alice http call
  @override
  FutureOr<chopper.Response> onResponse(chopper.Response response) {
    final httpResponse = AliceHttpResponse();
    httpResponse.status = response.statusCode;
    httpResponse.body = response.body ?? '';
    httpResponse.size = utf8.encode(httpResponse.body.toString()).length;
    httpResponse.time = DateTime.now();
    httpResponse.headers = response.headers;

    aliceCore.addResponse(
      httpResponse,
      getRequestHashCode(response.base.request!),
    );
    return response;
  }
}
