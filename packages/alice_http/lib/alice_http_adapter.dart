import 'dart:convert';

import 'package:alice/alice.dart';
import 'package:http/http.dart' as http;

class AliceHttpAdapter with AliceAdapter {
  /// Handles http response. It creates both request and response from http call
  void onResponse(http.Response response, {dynamic body, Duration? duration}) {
    if (response.request == null) {
      return;
    }
    final request = response.request!;

    final call =
        AliceHttpCall(response.request.hashCode)
          ..loading = true
          ..client = 'HttpClient (http package)'
          ..uri = request.url.toString()
          ..method = request.method;
    var path = request.url.path;
    if (path.isEmpty) {
      path = '/';
    }
    call
      ..endpoint = path
      ..server = request.url.host;
    if (request.url.scheme == 'https') {
      call.secure = true;
    }

    final httpRequest = AliceHttpRequest();

    if (response.request is http.Request) {
      // we are guaranteed` the existence of body and headers
      if (body != null) {
        httpRequest.body = body;
      }
      // ignore: cast_nullable_to_non_nullable
      httpRequest
        ..body = body ?? (response.request! as http.Request).body ?? ''
        ..size = utf8.encode(httpRequest.body.toString()).length
        ..headers = Map<String, String>.from(response.request!.headers);
    } else if (response.request is http.MultipartRequest) {
      final multipartRequest = response.request! as http.MultipartRequest;
      httpRequest.headers = Map<String, String>.from(multipartRequest.headers);
      if (body != null) {
        httpRequest.body = body;
      } else {
        httpRequest.body = {
          'fields': multipartRequest.fields,
          'files':
              multipartRequest.files
                  .map(
                    (file) => {
                      'field': file.field,
                      'filename': file.filename,
                      'length': file.length,
                      'contentType': file.contentType.toString(),
                    },
                  )
                  .toList(),
        };
      }
      httpRequest.size = utf8.encode(httpRequest.body.toString()).length;
    } else if (body == null) {
      httpRequest
        ..size = 0
        ..body = ''
        ..headers = Map<String, String>.from(response.request!.headers);
    } else {
      httpRequest
        ..size = utf8.encode(body.toString()).length
        ..body = body
        ..headers = Map<String, String>.from(response.request!.headers);
    }

    httpRequest.time = DateTime.now();

    String? contentType = 'unknown';
    if (httpRequest.headers.containsKey('Content-Type')) {
      contentType = httpRequest.headers['Content-Type'];
    }

    httpRequest
      ..contentType = contentType
      ..queryParameters = response.request!.url.queryParameters;

    final httpResponse =
        AliceHttpResponse()
          ..status = response.statusCode
          ..body = response.body
          // ignore: noop_primitive_operations
          ..size = utf8.encode(response.body.toString()).length
          ..time = DateTime.now();
    final responseHeaders = <String, String>{};
    response.headers.forEach((header, values) {
      responseHeaders[header] = values;
    });
    httpResponse.headers = responseHeaders;

    call
      ..request = httpRequest
      ..response = httpResponse
      ..loading = false
      ..duration =
          duration?.inMilliseconds ??
          (httpResponse.time.millisecondsSinceEpoch -
              httpRequest.time.millisecondsSinceEpoch);
    aliceCore.addCall(call);
  }
}
