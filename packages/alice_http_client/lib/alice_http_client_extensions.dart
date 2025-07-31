import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:alice_http_client/alice_http_client_adapter.dart';

extension AliceHttpClientExtensions on Future<HttpClientRequest> {
  /// Intercept http client with alice. This extension method provides
  /// additional helpful method to intercept httpClientResponse.
  Future<HttpClientResponse> interceptWithAlice(
    AliceHttpClientAdapter alice, {
    dynamic body,
    Map<String, dynamic>? headers,
  }) async {
    final request = await this;
    if (body != null) {
      request.write(body);
    }
    if (headers != null) {
      headers.forEach((String key, dynamic value) {
        request.headers.add(key, value as Object);
      });
    }
    alice.onRequest(request, body: body);
    final httpResponse = await request.close();
    final responseBody = await utf8.decoder.bind(httpResponse).join();
    alice.onResponse(httpResponse, request, body: responseBody);
    return httpResponse;
  }
}
