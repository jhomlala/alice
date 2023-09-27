import 'dart:convert';

import 'package:alice/src/core/alice_core.dart';
import 'package:alice/src/model/alice_http_call.dart';
import 'package:alice/src/model/alice_http_error.dart';
import 'package:alice/src/model/alice_http_request.dart';
import 'package:alice/src/model/alice_http_response.dart';
import 'package:http/http.dart' as http;

class AliceHttpAdapter {
  /// AliceCore instance
  final AliceCore aliceCore;

  /// Creates alice http adapter
  AliceHttpAdapter(this.aliceCore);

  void onRequest(http.BaseRequest request, {dynamic body, Object? id}) {
    final AliceHttpCall call = AliceHttpCall(id ?? request.hashCode);
    call.loading = true;
    call.client = "HttpClient (http package)";
    call.uri = request.url.toString();
    call.method = request.method;
    var path = request.url.path;
    if (path.isEmpty) {
      path = "/";
    }
    call.endpoint = path;

    call.server = request.url.host;
    if (request.url.scheme == "https") {
      call.secure = true;
    }

    final AliceHttpRequest httpRequest = AliceHttpRequest();

    if (request is http.Request) {
      // we are guaranteed` the existence of body and headers
      if (body != null) {
        httpRequest.body = body;
      }
      // ignore: cast_nullable_to_non_nullable
      httpRequest.body = body ?? request.body ?? "";
      httpRequest.size = utf8.encode(httpRequest.body.toString()).length;
      httpRequest.headers = Map<String, dynamic>.from(request.headers);
    } else if (body == null) {
      httpRequest.size = 0;
      httpRequest.body = "";
    } else {
      httpRequest.size = utf8.encode(body.toString()).length;
      httpRequest.body = body;
    }

    httpRequest.time = DateTime.now();

    String? contentType = "unknown";
    if (httpRequest.headers.containsKey("Content-Type")) {
      contentType = httpRequest.headers["Content-Type"] as String?;
    }

    httpRequest.contentType = contentType;

    httpRequest.queryParameters = request.url.queryParameters;
    call.request = httpRequest;
    aliceCore.addCall(call);
  }

  /// Handles http response. It creates both request and response from http call
  void onResponse(http.Response response, {dynamic body, Object? id}) {
    final httpResponse = AliceHttpResponse();
    httpResponse.status = response.statusCode;
    httpResponse.body = response.body;

    httpResponse.size = utf8.encode(response.body.toString()).length;
    httpResponse.time = DateTime.now();
    final Map<String, String> responseHeaders = {};
    response.headers.forEach((header, values) {
      responseHeaders[header] = values.toString();
    });
    httpResponse.headers = responseHeaders;
    aliceCore.addResponse(httpResponse, id ?? response.hashCode);
  }

  void onError(Object error, StackTrace? stackTrace, {required Object id}) {
    final httpError = AliceHttpError(
      error: error,
      stackTrace: stackTrace,
      time: DateTime.now(),
    );
    aliceCore.addError(httpError, id);
  }
}
