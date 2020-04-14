import 'dart:async';

import 'package:alice/model/alice_http_error.dart';
import 'package:alice/ui/alice_calls_list_screen.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_http_response.dart';
import 'package:alice/ui/alice_save_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shake/shake.dart';

class AliceCore {
  final bool showNotification;
  final bool showInspectorOnShake;
  final bool darkTheme;
  final BehaviorSubject<List<AliceHttpCall>> callsSubject =
      BehaviorSubject.seeded(List());
  final String notificationIcon;

  FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  GlobalKey<NavigatorState> _navigatorKey;
  Brightness _brightness = Brightness.light;
  bool _isInspectorOpened = false;
  ShakeDetector _shakeDetector;
  StreamSubscription _callsSubscription;
  String _notificationMessage;
  String _notificationMessageShown;
  bool _notificationProcessing = false;

  AliceCore(this._navigatorKey, this.showNotification,
      this.showInspectorOnShake, this.darkTheme, this.notificationIcon)
      : assert(showNotification != null, "showNotification can't be null"),
        assert(
            showInspectorOnShake != null, "showInspectorOnShake can't be null"),
        assert(darkTheme != null, "darkTheme can't be null"),
        assert(notificationIcon != null, "notificationIcon can't be null") {
    if (showNotification) {
      _initializeNotificationsPlugin();
      _callsSubscription = callsSubject.listen((_) => _onCallsChanged());
    }
    if (showInspectorOnShake) {
      _shakeDetector = ShakeDetector.autoStart(
        onPhoneShake: () => navigateToCallListScreen(),
        shakeThresholdGravity: 5,
      );
    }
    _brightness = darkTheme ? Brightness.dark : Brightness.light;
  }

  void dispose() {
    callsSubject.close();
    _shakeDetector?.stopListening();
    _callsSubscription?.cancel();
  }

  Brightness get brightness => _brightness;

  void _initializeNotificationsPlugin() {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid =
        new AndroidInitializationSettings(notificationIcon);
    var initializationSettingsIOS = IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: _onSelectedNotification);
  }

  void _onCallsChanged() async {
    if (callsSubject.value.length > 0) {
      _notificationMessage = _getNotificationMessage();
      if (_notificationMessage != _notificationMessageShown &&
          !_notificationProcessing) {
        await _showLocalNotification();
        _onCallsChanged();
      }
    }
  }

  void setNavigatorKey(GlobalKey<NavigatorState> navigatorKey) {
    assert(navigatorKey != null, "navigatorKey can't be null");
    this._navigatorKey = navigatorKey;
  }

  Future _onSelectedNotification(String payload) {
    assert(payload != null, "payload can't be null");
    navigateToCallListScreen();
    return Future.sync(() {});
  }

  void navigateToCallListScreen() {
    var context = getContext();
    if (context == null) {
      print(
          "Cant start Alice HTTP Inspector. Please add NavigatorKey to your application");
      return;
    }
    if (!_isInspectorOpened) {
      _isInspectorOpened = true;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AliceCallsListScreen(this),
        ),
      ).then((onValue) => _isInspectorOpened = false);
    }
  }

  BuildContext getContext() => _navigatorKey?.currentState?.overlay?.context;

  String _getNotificationMessage() {
    List<AliceHttpCall> calls = callsSubject.value;
    int successCalls = calls
        .where((call) =>
            call.response != null &&
            call.response.status >= 200 &&
            call.response.status < 300)
        .toList()
        .length;

    int redirectCalls = calls
        .where((call) =>
            call.response != null &&
            call.response.status >= 300 &&
            call.response.status < 400)
        .toList()
        .length;

    int errorCalls = calls
        .where((call) =>
            call.response != null &&
            call.response.status >= 400 &&
            call.response.status < 600)
        .toList()
        .length;

    int loadingCalls = calls.where((call) => call.loading).toList().length;

    StringBuffer notificationsMessage = StringBuffer();
    if (loadingCalls > 0) {
      notificationsMessage.write("Loading: $loadingCalls");
      notificationsMessage.write(" | ");
    }
    if (successCalls > 0) {
      notificationsMessage.write("Success: $successCalls");
      notificationsMessage.write(" | ");
    }
    if (redirectCalls > 0) {
      notificationsMessage.write("Error: $redirectCalls");
      notificationsMessage.write(" | ");
    }
    if (errorCalls > 0) {
      notificationsMessage.write("Error: $errorCalls");
    }
    return notificationsMessage.toString();
  }

  Future _showLocalNotification() async {
    _notificationProcessing = true;
    var channelId = "Alice";
    var channelName = "Alice";
    var channelDescription = "Alice";
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        channelId, channelName, channelDescription,
        enableVibration: false,
        playSound: false,
        importance: Importance.Low,
        priority: Priority.Default);
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    String message = _notificationMessage;
    await _flutterLocalNotificationsPlugin.show(
        0,
        "Alice (total: ${callsSubject.value.length} requests)",
        message,
        platformChannelSpecifics,
        payload: "");
    _notificationMessageShown = message;
    _notificationProcessing = false;
    return;
  }

  void addCall(AliceHttpCall call) {
    assert(call != null, "call can't be null");
    callsSubject.add(callsSubject.value..add(call));
  }

  void addError(AliceHttpError error, int requestId) {
    assert(error != null, "error can't be null");
    assert(requestId != null, "requestId can't be null");
    AliceHttpCall selectedCall = _selectCall(requestId);

    if (selectedCall == null) {
      print("Selected call is null");
      return;
    }

    selectedCall.error = error;
    callsSubject.add(List()..addAll(callsSubject.value));
  }

  void addResponse(AliceHttpResponse response, int requestId) {
    assert(response != null, "response can't be null");
    assert(requestId != null, "requestId can't be null");
    AliceHttpCall selectedCall = _selectCall(requestId);

    if (selectedCall == null) {
      print("Selected call is null");
      return;
    }
    selectedCall.loading = false;
    selectedCall.response = response;
    selectedCall.duration = response.time.millisecondsSinceEpoch -
        selectedCall.request.time.millisecondsSinceEpoch;

    callsSubject.add(List()..addAll(callsSubject.value));
  }

  void removeCalls() {
    callsSubject.add(List());
  }

  AliceHttpCall _selectCall(int requestId) => callsSubject.value
      .firstWhere((call) => call.id == requestId, orElse: null);

  void saveHttpRequests(BuildContext context) {
    assert(context != null, "context can't be null");
    AliceSaveHelper.saveCalls(context, callsSubject.value);
  }
}
