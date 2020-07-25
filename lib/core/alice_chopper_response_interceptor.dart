import 'dart:async';
import 'dart:convert';

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
  AliceChopperInterceptor(this.aliceCore)
      : assert(aliceCore != null, "aliceCore can't be null");

  /// Creates hashcode based on request
  int getRequestHashCode(BaseRequest baseRequest) {
    assert(baseRequest != null, "baseReqeust can't be null");
    int hashCodeSum = 0;
    if (baseRequest.url != null) {
      hashCodeSum += baseRequest.url.hashCode;
    }
    if (baseRequest.method != null) {
      hashCodeSum += baseRequest.method.hashCode;
    }
    if (baseRequest.headers != null && baseRequest.headers.isNotEmpty) {
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
    assert(request != null, "request can't be null");
    var baseRequest = await request.toBaseRequest();
    AliceHttpCall call = AliceHttpCall(getRequestHashCode(baseRequest));
    String endpoint = "";
    String server = "";
    if (request.baseUrl == null || request.baseUrl.isEmpty) {
      List<String> split = request.url.split("/");
      if (split.length > 2) {
        server = split[1] + split[2];
      }
      if (split.length > 4) {
        endpoint = "/";
        for (int splitIndex = 3; splitIndex < split.length; splitIndex++) {
          endpoint += split[splitIndex] + "/";
        }
        endpoint = endpoint.substring(0, endpoint.length - 1);
      }
    } else {
      endpoint = request.url;
      server = request.baseUrl;
    }

    call.method = request.method;
    call.endpoint = endpoint;
    call.server = server;
    call.client = "Chopper";
    if (request.baseUrl.contains("https") || request.url.contains("https")) {
      call.secure = true;
    }

    AliceHttpRequest aliceHttpRequest = AliceHttpRequest();

    if (request.body == null) {
      aliceHttpRequest.size = 0;
      aliceHttpRequest.body = "";
    } else {
      aliceHttpRequest.size = utf8.encode(request.body).length;
      aliceHttpRequest.body = request.body;
    }
    aliceHttpRequest.time = DateTime.now();
    aliceHttpRequest.headers = request.headers;

    String contentType = "unknown";
    if (request.headers.containsKey("Content-Type")) {
      contentType = request.headers["Content-Type"];
    }
    aliceHttpRequest.contentType = contentType;
    aliceHttpRequest.queryParameters = request.parameters;

    call.request = aliceHttpRequest;
    call.response = AliceHttpResponse();

    aliceCore.addCall(call);
    return request;
  }

  /// Handles chopper response and adds data to existing alice http call
  FutureOr<chopper.Response> onResponse(chopper.Response response) {
    assert(response != null, "response can't be null");
    var httpResponse = AliceHttpResponse();
    httpResponse.status = response.statusCode;
    if (response.body == null) {
      httpResponse.body = "";
      httpResponse.size = 0;
    } else {
      httpResponse.body = response.body;
      httpResponse.size = utf8.encode(response.body.toString()).length;
    }

    httpResponse.time = DateTime.now();
    Map<String, String> headers = Map();
    if (response.headers != null) {
      response.headers.forEach((header, values) {
        headers[header] = values.toString();
      });
    }
    httpResponse.headers = headers;

    aliceCore.addResponse(
        httpResponse, getRequestHashCode(response.base.request));
    return response;
  }
}
