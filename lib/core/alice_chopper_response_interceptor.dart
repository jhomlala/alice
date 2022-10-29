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
      final AliceHttpCall call = AliceHttpCall(getRequestHashCode(baseRequest));
      String endpoint = "";
      String server = "";

      final List<String> split = request.url.toString().split("/");
      if (split.length > 2) {
        server = split[1] + split[2];
      }
      if (split.length > 4) {
        endpoint = "/";
        for (int splitIndex = 3; splitIndex < split.length; splitIndex++) {
          // ignore: use_string_buffers
          endpoint += "${split[splitIndex]}/";
        }
        endpoint = endpoint.substring(0, endpoint.length - 1);
      }

      call.method = request.method;
      call.endpoint = endpoint;
      call.server = server;
      call.client = "Chopper";
      if (request.url.toString().contains("https")) {
        call.secure = true;
      }

      final AliceHttpRequest aliceHttpRequest = AliceHttpRequest();

      if (request.body == null) {
        aliceHttpRequest.size = 0;
        aliceHttpRequest.body = "";
      } else {
        aliceHttpRequest.size = utf8.encode(request.body as String).length;
        aliceHttpRequest.body = request.body;
      }
      aliceHttpRequest.time = DateTime.now();
      aliceHttpRequest.headers = request.headers;

      String? contentType = "unknown";
      if (request.headers.containsKey("Content-Type")) {
        contentType = request.headers["Content-Type"];
      }
      aliceHttpRequest.contentType = contentType;
      aliceHttpRequest.queryParameters = request.parameters;

      call.request = aliceHttpRequest;
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
    if (response.body == null) {
      httpResponse.body = "";
      httpResponse.size = 0;
    } else {
      httpResponse.body = response.body;
      httpResponse.size = utf8.encode(response.body.toString()).length;
    }

    httpResponse.time = DateTime.now();
    final Map<String, String> headers = {};
    response.headers.forEach((header, values) {
      headers[header] = values.toString();
    });
    httpResponse.headers = headers;

    aliceCore.addResponse(
      httpResponse,
      getRequestHashCode(response.base.request!),
    );
    return response;
  }
}
