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
  /// Should user be notified with notification if there's new request catched
  /// by Alice
  final bool showNotification;

  /// Should inspector be opened on device shake (works only with physical
  /// with sensors)
  final bool showInspectorOnShake;

  /// Should inspector use dark theme
  final bool darkTheme;

  /// Icon url for notification
  final String notificationIcon;

  GlobalKey<NavigatorState> _navigatorKey;
  AliceCore _aliceCore;
  AliceHttpClientAdapter _httpClientAdapter;
  AliceHttpAdapter _httpAdapter;

  /// Creates alice instance.
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

  /// Get chopper interceptor. This should be added to Chopper instance.
  List<ResponseInterceptor> getChopperInterceptor() {
    return [AliceChopperInterceptor(_aliceCore)];
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
