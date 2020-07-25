import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:alice/alice.dart';

extension AliceHttpClientExtensions on Future<HttpClientRequest> {
  /// Intercept http client with alice. This extension method provides additional
  /// helpful method to intercept httpClientResponse.
  Future<HttpClientResponse> interceptWithAlice(Alice alice,
      {dynamic body, Map<String, dynamic> headers}) async {
    assert(alice != null, "alice can't be null");
    HttpClientRequest request = await this;
    if (body != null) {
      request.write(body);
    }
    if (headers != null) {
      headers.forEach(
        (String key, dynamic value) {
          request.headers.add(key, value);
        },
      );
    }
    alice.onHttpClientRequest(request, body: body);
    var httpResponse = await request.close();
    var responseBody = await utf8.decoder.bind(httpResponse).join();
    alice.onHttpClientResponse(httpResponse, request, body: responseBody);
    return httpResponse;
  }
}
