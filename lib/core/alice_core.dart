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

  AliceCore(this._navigatorKey, this.showNotification,
      this.showInspectorOnShake, this.darkTheme, this.notificationIcon)
      : assert(showNotification != null, "showNotification can't be null"),
        assert(
            showInspectorOnShake != null, "showInspectorOnShake can't be null"),
        assert(darkTheme != null, "darkTheme can't be null"),
        assert(notificationIcon != null, "notificationIcon can't be null") {
    if (showNotification) {
      _initializeNotificationsPlugin();
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
  }

  void _initializeNotificationsPlugin() {
    _flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid =
        new AndroidInitializationSettings(notificationIcon);
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: _onSelectedNotification);
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

  void _showLocalNotification() async {
    var channelId = "Alice";
    var channelName = "Alice";
    var channelDescription = "Alice";
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        channelId, channelName, channelDescription,
        enableVibration: false,
        importance: Importance.Default,
        priority: Priority.Default);
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(0, "Alice",
        "HTTP Requests: ${callsSubject.value.length}", platformChannelSpecifics,
        payload: "");
  }

  void addCall(AliceHttpCall call) {
    assert(call != null, "call can't be null");
    callsSubject.add(callsSubject.value..add(call));
    if (showNotification) {
      _showLocalNotification();
    }
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
    callsSubject.add(callsSubject.value);
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

    callsSubject.add(callsSubject.value);
  }

  void removeCalls() {
    callsSubject.add(List());
  }

  AliceHttpCall _selectCall(int requestId) => callsSubject.value
      .firstWhere((call) => call.id == requestId, orElse: null);

  void saveHttpRequests(BuildContext context) {
    AliceSaveHelper.saveCalls(context, callsSubject.value);
  }

  Brightness get brightness => _brightness;
}
