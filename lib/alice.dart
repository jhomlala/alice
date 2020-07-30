import 'dart:io';
import 'package:alice_lightweight/core/alice_http_adapter.dart';
import 'package:alice_lightweight/model/alice_http_call.dart';

import 'package:http/http.dart' as http;
import 'package:alice_lightweight/core/alice_core.dart';
import 'package:alice_lightweight/core/alice_dio_interceptor.dart';
import 'package:alice_lightweight/core/alice_http_client_adapter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Alice {
  /// Should inspector use dark theme
  final bool darkTheme;

  GlobalKey<NavigatorState> _navigatorKey;
  AliceCore _aliceCore;
  AliceHttpClientAdapter _httpClientAdapter;
  AliceHttpAdapter _httpAdapter;

  /// Creates alice instance.
  Alice(
      {GlobalKey<NavigatorState> navigatorKey,
      this.darkTheme = false,})
      : assert(darkTheme != null, "darkTheme can't be null") {
    _navigatorKey = navigatorKey ?? GlobalKey<NavigatorState>();
    _aliceCore = AliceCore(_navigatorKey, darkTheme);
    _httpClientAdapter = AliceHttpClientAdapter(_aliceCore);
    _httpAdapter = AliceHttpAdapter(_aliceCore);
  }

  /// Set custom navigation key. This will help if there's route library.
  void setNavigatorKey(GlobalKey<NavigatorState> navigatorKey) {
    assert(navigatorKey != null, "navigatorKey can't be null");
    _aliceCore.setNavigatorKey(navigatorKey);
  }

  /// Get currently used navigation key
  GlobalKey<NavigatorState> getNavigatorKey() {
    return _navigatorKey;
  }

  /// Get Dio interceptor which should be applied to Dio instance.
  AliceDioInterceptor getDioInterceptor() {
    return AliceDioInterceptor(_aliceCore);
  }

  /// Handle request from HttpClient
  void onHttpClientRequest(HttpClientRequest request, {dynamic body}) {
    assert(request != null, "httpClientRequest can't be null");
    _httpClientAdapter.onRequest(request, body: body);
  }

  /// Handle response from HttpClient
  void onHttpClientResponse(
      HttpClientResponse response, HttpClientRequest request,
      {dynamic body}) {
    assert(response != null, "httpClientResponse can't be null");
    assert(request != null, "httpClientRequest can't be null");
    _httpClientAdapter.onResponse(response, request, body: body);
  }

  /// Handle both request and response from http package
  void onHttpResponse(http.Response response, {dynamic body}) {
    assert(response != null, "response can't be null");
    _httpAdapter.onResponse(response, body: body);
  }

  /// Opens Http calls inspector. This will navigate user to the new fullscreen
  /// page where all listened http calls can be viewed.
  void showInspector() {
    _aliceCore.navigateToCallListScreen();
  }

  /// Handle generic http call. Can be used to any http client.
  void addHttpCall(AliceHttpCall aliceHttpCall) {
    assert(aliceHttpCall != null, "Http call can't be null");
    assert(aliceHttpCall.id != null, "Http call id can't be null");
    assert(aliceHttpCall.request != null, "Http call request can't be null");
    assert(aliceHttpCall.response != null, "Http call response can't be null");
    assert(aliceHttpCall.endpoint != null, "Http call endpoint can't be null");
    assert(aliceHttpCall.server != null, "Http call server can't be null");
    _aliceCore.addCall(aliceHttpCall);
  }
}
