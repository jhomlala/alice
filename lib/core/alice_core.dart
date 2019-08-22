import 'package:alice/model/alice_http_error.dart';
import 'package:alice/ui/alice_calls_list_screen.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_http_response.dart';
import 'package:alice/ui/alice_save_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';

class AliceCore {
  FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  GlobalKey<NavigatorState> _navigatorKey;
  bool _showNotification = false;

  List<AliceHttpCall> calls;
  PublishSubject<int> changesSubject;
  PublishSubject<AliceHttpCall> callUpdateSubject;

  AliceCore(GlobalKey<NavigatorState> navigatorKey, bool showNotification) {
    _navigatorKey = navigatorKey;
    calls = List();
    changesSubject = PublishSubject();
    callUpdateSubject = PublishSubject();
    _showNotification = showNotification;
    if (showNotification) {
      _initializeNotificationsPlugin();
    }
  }

  dispose() {
    changesSubject.close();
    callUpdateSubject.close();
  }

  void _initializeNotificationsPlugin() {
    _flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid =
        new AndroidInitializationSettings("@mipmap/ic_launcher");
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: _onSelectedNotification);
  }

  Future _onSelectedNotification(String payload) {
    navigateToCallListScreen();
    return Future.sync(() {});
  }

  void navigateToCallListScreen() {
    var context = getContext();
    if (context == null) {
      print(
          "Cant start Alice HTTP Inspector. Please add NavigatorKey to your application");
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AliceCallsListScreen(this)),
    );
  }

  BuildContext getContext() {
    if (_navigatorKey != null &&
        _navigatorKey.currentState != null &&
        _navigatorKey.currentState.overlay != null) {
      return _navigatorKey.currentState.overlay.context;
    } else {
      return null;
    }
  }

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

    await _flutterLocalNotificationsPlugin.show(
        0, "Alice", "HTTP Requests: ${calls.length}", platformChannelSpecifics,
        payload: "");
  }

  void addCall(AliceHttpCall call) {
    calls.add(call);
    if (_showNotification) {
      _showLocalNotification();
    }
  }

  void addError(AliceHttpError error, int requestId) {
    AliceHttpCall selectedCall = _selectCall(requestId);

    if (selectedCall == null) {
      print("Selected call is null");
      return;
    }

    selectedCall.error = error;
    changesSubject.sink.add(requestId);
    callUpdateSubject.sink.add(selectedCall);
  }

  void addResponse(AliceHttpResponse response, int requestId) {
    AliceHttpCall selectedCall = _selectCall(requestId);

    if (selectedCall == null) {
      print("Selected call is null");
      return;
    }
    selectedCall.loading = false;
    selectedCall.response = response;
    selectedCall.duration = response.time.millisecondsSinceEpoch -
        selectedCall.request.time.millisecondsSinceEpoch;

    changesSubject.sink.add(requestId);
    callUpdateSubject.sink.add(selectedCall);
  }

  void removeCalls() {
    calls = List();
    changesSubject.sink.add(0);
  }

  AliceHttpCall _selectCall(int requestId) {
    AliceHttpCall requestedCall;
    calls.forEach((call) {
      if (call.id == requestId) {
        requestedCall = call;
      }
    });
    return requestedCall;
  }

  void saveHttpRequests(BuildContext context) {
    AliceSaveHelper.saveCalls(context, calls);
  }
}
