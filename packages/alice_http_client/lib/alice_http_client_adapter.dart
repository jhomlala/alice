import 'dart:convert';
import 'dart:io';

import 'package:alice/core/alice_adapter.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_http_request.dart';
import 'package:alice/model/alice_http_response.dart';
import 'package:alice/utils/alice_parser.dart';

class AliceHttpClientAdapter with AliceAdapter {
  /// Handles httpClientRequest and creates http alice call from it
  void onRequest(HttpClientRequest request, {dynamic body}) {
    final call =
        AliceHttpCall(request.hashCode)
          ..loading = true
          ..client = 'HttpClient (io package)'
          ..method = request.method
          ..uri = request.uri.toString();

    var path = request.uri.path;
    if (path.isEmpty) {
      path = '/';
    }

    call
      ..endpoint = path
      ..server = request.uri.host;
    if (request.uri.scheme == 'https') {
      call.secure = true;
    }
    final httpRequest = AliceHttpRequest();
    if (body == null) {
      httpRequest
        ..size = 0
        ..body = '';
    } else {
      httpRequest
        ..size = utf8.encode(body.toString()).length
        ..body = body;
    }
    httpRequest.time = DateTime.now();
    final headers = <String, dynamic>{};

    httpRequest.headers.forEach((header, dynamic value) {
      headers[header] = value;
    });

    httpRequest.headers = AliceParser.parseHeaders(headers: headers);
    String? contentType = 'unknown';
    if (headers.containsKey('Content-Type')) {
      contentType = headers['Content-Type'];
    }

    httpRequest
      ..contentType = contentType
      ..cookies = request.cookies;

    call
      ..request = httpRequest
      ..response = AliceHttpResponse();
    aliceCore.addCall(call);
  }

  /// Handles httpClientRequest and adds response to http alice call
  Future<void> onResponse(
    HttpClientResponse response,
    HttpClientRequest request, {
    dynamic body,
  }) async {
    final httpResponse = AliceHttpResponse()..status = response.statusCode;

    if (body != null) {
      httpResponse
        ..body = body
        ..size = utf8.encode(body.toString()).length;
    } else {
      httpResponse
        ..body = ''
        ..size = 0;
    }
    httpResponse.time = DateTime.now();
    final headers = <String, String>{};
    response.headers.forEach((header, values) {
      headers[header] = values.toString();
    });
    httpResponse.headers = headers;
    aliceCore.addResponse(httpResponse, request.hashCode);
  }
}
