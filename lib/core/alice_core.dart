import 'dart:async';

import 'package:alice/helper/alice_save_helper.dart';
import 'package:alice/model/alice_http_error.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_http_response.dart';
import 'package:alice/ui/page/alice_calls_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shake/shake.dart';

class AliceCore {
  /// Should user be notified with notification if there's new request catched
  /// by Alice
  final bool showNotification;

  /// Should inspector be opened on device shake (works only with physical
  /// with sensors)
  final bool showInspectorOnShake;

  /// Should inspector use dark theme
  final bool darkTheme;

  /// Rx subject which contains all intercepted http calls
  final BehaviorSubject<List<AliceHttpCall>> callsSubject =
      BehaviorSubject.seeded(List());

  /// Icon url for notification
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

  /// Creates alice core instance
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

  /// Dispose subjects and subscriptions
  void dispose() {
    callsSubject.close();
    _shakeDetector?.stopListening();
    _callsSubscription?.cancel();
  }

  /// Get currently used brightness
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

  /// Set custom navigation key. This will help if there's route library.
  void setNavigatorKey(GlobalKey<NavigatorState> navigatorKey) {
    assert(navigatorKey != null, "navigatorKey can't be null");
    this._navigatorKey = navigatorKey;
  }

  Future _onSelectedNotification(String payload) {
    assert(payload != null, "payload can't be null");
    navigateToCallListScreen();
    return Future.sync(() {});
  }

  /// Opens Http calls inspector. This will navigate user to the new fullscreen
  /// page where all listened http calls can be viewed.
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

  /// Get context from navigator key. Used to open inspector route.
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
      notificationsMessage.write("Redirect: $redirectCalls");
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
        largeIcon: DrawableResourceAndroidBitmap(notificationIcon),
        importance: Importance.Default,
        priority: Priority.Default);
    var iOSPlatformChannelSpecifics =
        new IOSNotificationDetails(presentSound: false);
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

  /// Add alice http call to calls subject
  void addCall(AliceHttpCall call) {
    assert(call != null, "call can't be null");
    callsSubject.add([...callsSubject.value, call]);
  }

  /// Add error to exisng alice http call
  void addError(AliceHttpError error, int requestId) {
    assert(error != null, "error can't be null");
    assert(requestId != null, "requestId can't be null");
    AliceHttpCall selectedCall = _selectCall(requestId);

    if (selectedCall == null) {
      print("Selected call is null");
      return;
    }

    selectedCall.error = error;
    callsSubject.add([...callsSubject.value]);
  }

  /// Add response to existing alice http call
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

    callsSubject.add([...callsSubject.value]);
  }

  /// Add alice http call to calls subject
  void addHttpCall(AliceHttpCall aliceHttpCall) {
    assert(aliceHttpCall != null, "Http call can't be null");
    assert(aliceHttpCall.id != null, "Http call id can't be null");
    assert(aliceHttpCall.request != null, "Http call request can't be null");
    assert(aliceHttpCall.response != null, "Http call response can't be null");
    assert(aliceHttpCall.endpoint != null, "Http call endpoint can't be null");
    assert(aliceHttpCall.server != null, "Http call server can't be null");
    callsSubject.add([...callsSubject.value, aliceHttpCall]);
  }

  /// Remove all calls from calls subject
  void removeCalls() {
    callsSubject.add(List());
  }

  AliceHttpCall _selectCall(int requestId) => callsSubject.value
      .firstWhere((call) => call.id == requestId, orElse: () => null);

  /// Save all calls to file
  void saveHttpRequests(BuildContext context) {
    assert(context != null, "context can't be null");
    AliceSaveHelper.saveCalls(context, callsSubject.value, _brightness);
  }
}
