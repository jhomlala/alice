import 'dart:io';
import 'package:alice/alice_http_adapter.dart';
import 'package:http/http.dart' as http;
import 'package:alice/alice_core.dart';
import 'package:alice/alice_dio_interceptor.dart';
import 'package:alice/alice_http_client_adapter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Alice {
  GlobalKey<NavigatorState> _navigatorKey;
  AliceCore _core;
  AliceHttpClientAdapter _httpClientAdapter;
  AliceHttpAdapter _httpAdapter;

  Alice() {
    _navigatorKey = GlobalKey<NavigatorState>();
    _core = AliceCore(_navigatorKey);
    _httpClientAdapter = AliceHttpClientAdapter(_core);
    _httpAdapter = AliceHttpAdapter(_core);
  }

  GlobalKey<NavigatorState> getNavigatorKey() {
    return _navigatorKey;
  }

  AliceDioInterceptor getDioInterceptor() {
    return AliceDioInterceptor(_core);
  }

  void onHttpClientRequest(HttpClientRequest request, {dynamic body}) {
    print("Request: " + request.hashCode.toString());
    _httpClientAdapter.onRequest(request, body: body);
  }

  void onHttpClientResponse(
      HttpClientResponse response, HttpClientRequest request,
      {dynamic body}) {
    print("Response: " + response.hashCode.toString());
    _httpClientAdapter.onResponse(response, request, body: body);
  }

  void onHttpResponse(http.Response response, {dynamic body}) {
    _httpAdapter.onResponse(response, body: body);
  }
}
