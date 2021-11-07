import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:alice/alice.dart';

extension AliceHttpClientExtensions on Future<HttpClientRequest> {
  /// Intercept http client with alice. This extension method provides additional
  /// helpful method to intercept httpClientResponse.
  Future<HttpClientResponse> interceptWithAlice(
    Alice alice, {
    dynamic body,
    Map<String, dynamic>? headers,
  }) async {
    final HttpClientRequest request = await this;
    if (body != null) {
      request.write(body);
    }
    if (headers != null) {
      headers.forEach(
        (String key, dynamic value) {
          request.headers.add(key, value as Object);
        },
      );
    }
    alice.onHttpClientRequest(request, body: body);
    final httpResponse = await request.close();
    final responseBody = await utf8.decoder.bind(httpResponse).join();
    alice.onHttpClientResponse(httpResponse, request, body: responseBody);
    return httpResponse;
  }
}
