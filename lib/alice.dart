import 'dart:io';
import 'package:alice/core/alice_chopper_response_interceptor.dart';
import 'package:alice/core/alice_http_adapter.dart';
import 'package:alice/model/alice_http_call.dart';

import 'package:chopper/chopper.dart';
import 'package:http/http.dart' as http;
import 'package:alice/core/alice_core.dart';
import 'package:alice/core/alice_dio_interceptor.dart';
import 'package:alice/core/alice_http_client_adapter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Alice {
  final bool showNotification;
  final bool showInspectorOnShake;
  final bool darkTheme;
  final String notificationIcon;
  GlobalKey<NavigatorState> _navigatorKey;
  AliceCore _aliceCore;
  AliceHttpClientAdapter _httpClientAdapter;
  AliceHttpAdapter _httpAdapter;

  Alice(
      {GlobalKey<NavigatorState> navigatorKey,
      this.showNotification = true,
      this.showInspectorOnShake = false,
      this.darkTheme = false,
      this.notificationIcon = "@mipmap/ic_launcher"})
      : assert(showNotification != null, "showNotification can't be null"),
        assert(
            showInspectorOnShake != null, "showInspectorOnShake can't be null"),
        assert(darkTheme != null, "darkTheme can't be null"),
        assert(notificationIcon != null, "notificationIcon can't be null") {
    _navigatorKey = navigatorKey ?? GlobalKey<NavigatorState>();
    _aliceCore = AliceCore(_navigatorKey, showNotification,
        showInspectorOnShake, darkTheme, notificationIcon);
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

  void onHttpClientRequest(HttpClientRequest request, {dynamic body}) {
    assert(request != null, "httpClientRequest can't be null");
    _httpClientAdapter.onRequest(request, body: body);
  }

  void onHttpClientResponse(
      HttpClientResponse response, HttpClientRequest request,
      {dynamic body}) {
    assert(response != null, "httpClientResponse can't be null");
    assert(request != null, "httpClientRequest can't be null");
    _httpClientAdapter.onResponse(response, request, body: body);
  }

  void onHttpResponse(http.Response response, {dynamic body}) {
    assert(response != null, "response can't be null");
    _httpAdapter.onResponse(response, body: body);
  }

  void showInspector() {
    _aliceCore.navigateToCallListScreen();
  }

  List<ResponseInterceptor> getChopperInterceptor() {
    return [AliceChopperInterceptor(_aliceCore)];
  }

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
