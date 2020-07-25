import 'dart:convert';
import 'dart:io';

import 'package:alice/core/alice_core.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_http_request.dart';
import 'package:alice/model/alice_http_response.dart';

class AliceHttpClientAdapter {
  /// AliceCore instance
  final AliceCore aliceCore;

  /// Creates alice http client adapter
  AliceHttpClientAdapter(this.aliceCore)
      : assert(aliceCore != null, "aliceCore can't be null");

  /// Handles httpClientRequest and creates http alice call from it
  void onRequest(HttpClientRequest request, {dynamic body}) {
    if (request == null) {
      return;
    }
    AliceHttpCall call = AliceHttpCall(request.hashCode);
    call.loading = true;
    call.client = "HttpClient (io package)";
    call.method = request.method;
    call.uri = request.uri.toString();

    var path = request.uri.path;
    if (path == null || path.length == 0) {
      path = "/";
    }

    call.endpoint = path;
    call.server = request.uri.host;
    if (request.uri.scheme == "https") {
      call.secure = true;
    }
    AliceHttpRequest httpRequest = AliceHttpRequest();
    if (body == null) {
      httpRequest.size = 0;
      httpRequest.body = "";
    } else {
      httpRequest.size = utf8.encode(body.toString()).length;
      httpRequest.body = body;
    }
    httpRequest.time = DateTime.now();
    Map<String, dynamic> headers = Map();
    httpRequest.headers.forEach((header, value) {
      headers[header] = value;
    });

    httpRequest.headers = headers;
    String contentType = "unknown";
    if (headers.containsKey("Content-Type")) {
      contentType = headers["Content-Type"];
    }

    httpRequest.contentType = contentType;
    httpRequest.cookies = request.cookies;

    call.request = httpRequest;
    call.response = AliceHttpResponse();
    aliceCore.addCall(call);
  }

  /// Handles httpClientRequest and adds response to http alice call
  void onResponse(HttpClientResponse response, HttpClientRequest request,
      {dynamic body}) async {
    if (response == null) {
      return;
    }
    if (request == null) {
      return;
    }
    AliceHttpResponse httpResponse = AliceHttpResponse();
    httpResponse.status = response.statusCode;

    if (body != null) {
      httpResponse.body = body;
      httpResponse.size = utf8.encode(body.toString()).length;
    } else {
      httpResponse.body = "";
      httpResponse.size = 0;
    }
    httpResponse.time = DateTime.now();
    Map<String, String> headers = Map();
    response.headers.forEach((header, values) {
      headers[header] = values.toString();
    });
    httpResponse.headers = headers;
    aliceCore.addResponse(httpResponse, request.hashCode);
  }
}
