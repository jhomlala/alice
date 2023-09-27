import 'dart:io';

import 'package:alice/src/core/alice_core.dart';
import 'package:alice/src/core/http_client/alice_http_client_adapter.dart';
import 'package:alice/src/core/http/alice_http_adapter.dart';
import 'package:alice/src/model/alice_http_call.dart';
import 'package:alice/src/model/alice_log.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

export 'package:alice/src/model/alice_log.dart';

class Alice {
  /// Should inspector use dark theme
  final bool darkTheme;

  ///Max number of calls that are stored in memory. When count is reached, FIFO
  ///method queue will be used to remove elements.
  final int maxCallsCount;

  ///Directionality of app. Directionality of the app will be used if set to null.
  final TextDirection? directionality;

  ///Flag used to show/hide share button
  final bool? showShareButton;

  late AliceCore _aliceCore;
  late AliceHttpClientAdapter _httpClientAdapter;
  late AliceHttpAdapter _httpAdapter;

  /// Creates alice instance.
  Alice({
    this.darkTheme = false,
    this.maxCallsCount = 1000,
    this.directionality,
    this.showShareButton = true,
  }) {
    _aliceCore = AliceCore(
      darkTheme: darkTheme,
      maxCallsCount: maxCallsCount,
      directionality: directionality,
      showShareButton: showShareButton,
    );
    _httpClientAdapter = AliceHttpClientAdapter(_aliceCore);
    _httpAdapter = AliceHttpAdapter(_aliceCore);
  }

  /// Handle request from HttpClient
  void onHttpClientRequest(HttpClientRequest request, {dynamic body}) {
    _httpClientAdapter.onRequest(request, body: body);
  }

  /// Handle response from HttpClient
  void onHttpClientResponse(
    HttpClientResponse response,
    HttpClientRequest request, {
    dynamic body,
  }) {
    _httpClientAdapter.onResponse(response, request, body: body);
  }

  /// Handle both request and response from http package
  void onHttpResponse(http.Response response, {dynamic body}) {
    _httpAdapter.onResponse(response, body: body);
  }

  /// Opens Http calls inspector. This will navigate user to the new fullscreen
  /// page where all listened http calls can be viewed.
  void showInspector(BuildContext context) {
    _aliceCore.navigateToCallListScreen(context);
  }

  /// Handle generic http call. Can be used to any http client.
  void addHttpCall(AliceHttpCall aliceHttpCall) {
    assert(aliceHttpCall.request != null, "Http call request can't be null");
    assert(aliceHttpCall.response != null, "Http call response can't be null");
    _aliceCore.addCall(aliceHttpCall);
  }

  /// Adds new log to Alice logger.
  void addLog(AliceLog log) {
    _aliceCore.addLog(log);
  }

  /// Adds list of logs to Alice logger
  void addLogs(List<AliceLog> logs) {
    _aliceCore.addLogs(logs);
  }
}
