import 'dart:async';

import 'package:alice/core/alice_logger.dart';
import 'package:alice/core/alice_utils.dart';
import 'package:alice/helper/alice_save_helper.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_http_error.dart';
import 'package:alice/model/alice_http_response.dart';
import 'package:alice/model/alice_log.dart';
import 'package:alice/ui/page/alice_calls_list_screen.dart';
import 'package:alice/utils/shake_detector.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';

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
      BehaviorSubject.seeded([]);

  /// Icon url for notification
  final String notificationIcon;

  ///Max number of calls that are stored in memory. When count is reached, FIFO
  ///method queue will be used to remove elements.
  final int maxCallsCount;

  ///Directionality of app. If null then directionality of context will be used.
  final TextDirection? directionality;

  ///Flag used to show/hide share button
  final bool? showShareButton;

  final AliceLogger _aliceLogger = AliceLogger();

  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  GlobalKey<NavigatorState>? navigatorKey;
  Brightness _brightness = Brightness.light;
  bool _isInspectorOpened = false;
  ShakeDetector? _shakeDetector;
  StreamSubscription? _callsSubscription;
  String? _notificationMessage;
  String? _notificationMessageShown;
  bool _notificationProcessing = false;

  /// Creates alice core instance
  AliceCore(
    this.navigatorKey, {
    required this.showNotification,
    required this.showInspectorOnShake,
    required this.darkTheme,
    required this.notificationIcon,
    required this.maxCallsCount,
    this.directionality,
    this.showShareButton,
  }) {
    if (showNotification) {
      _initializeNotificationsPlugin();
      _callsSubscription = callsSubject.listen((_) => _onCallsChanged());
    }
    if (showInspectorOnShake) {
      _shakeDetector = ShakeDetector.autoStart(
        onPhoneShake: () {
          navigateToCallListScreen();
        },
        shakeThresholdGravity: 4,
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
    final initializationSettingsAndroid =
        AndroidInitializationSettings(notificationIcon);
    const initializationSettingsIOS = DarwinInitializationSettings();
    final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );
  }

  void _onCallsChanged() async {
    if (callsSubject.value.isNotEmpty) {
      _notificationMessage = _getNotificationMessage();
      if (_notificationMessage != _notificationMessageShown &&
          !_notificationProcessing) {
        await _showLocalNotification();
        _onCallsChanged();
      }
    }
  }

  Future<void> _onDidReceiveNotificationResponse(
      NotificationResponse response) async {
    assert(response.payload != null, "payload can't be null");
    navigateToCallListScreen();
    return;
  }

  /// Opens Http calls inspector. This will navigate user to the new fullscreen
  /// page where all listened http calls can be viewed.
  void navigateToCallListScreen() {
    final context = getContext();
    if (context == null) {
      AliceUtils.log(
        "Cant start Alice HTTP Inspector. Please add NavigatorKey to your application",
      );
      return;
    }
    if (!_isInspectorOpened) {
      _isInspectorOpened = true;
      Navigator.push<void>(
        context,
        MaterialPageRoute(
          builder: (context) => AliceCallsListScreen(this, _aliceLogger),
        ),
      ).then((onValue) => _isInspectorOpened = false);
    }
  }

  /// Get context from navigator key. Used to open inspector route.
  BuildContext? getContext() => navigatorKey?.currentState?.overlay?.context;

  String _getNotificationMessage() {
    final List<AliceHttpCall> calls = callsSubject.value;
    final int successCalls = calls
        .where(
          (call) =>
              call.response != null &&
              call.response!.status! >= 200 &&
              call.response!.status! < 300,
        )
        .toList()
        .length;

    final int redirectCalls = calls
        .where(
          (call) =>
              call.response != null &&
              call.response!.status! >= 300 &&
              call.response!.status! < 400,
        )
        .toList()
        .length;

    final int errorCalls = calls
        .where(
          (call) =>
              call.response != null &&
              call.response!.status! >= 400 &&
              call.response!.status! < 600,
        )
        .toList()
        .length;

    final int loadingCalls =
        calls.where((call) => call.loading).toList().length;

    final StringBuffer notificationsMessage = StringBuffer();
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
    String notificationMessageString = notificationsMessage.toString();
    if (notificationMessageString.endsWith(" | ")) {
      notificationMessageString = notificationMessageString.substring(
        0,
        notificationMessageString.length - 3,
      );
    }

    return notificationMessageString;
  }

  Future _showLocalNotification() async {
    _notificationProcessing = true;
    const channelId = "Alice";
    const channelName = "Alice";
    const channelDescription = "Alice";
    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      enableVibration: false,
      playSound: false,
      largeIcon: DrawableResourceAndroidBitmap(notificationIcon),
    );
    const iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(presentSound: false);
    final platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    final String? message = _notificationMessage;
    await _flutterLocalNotificationsPlugin.show(
      0,
      "Alice (total: ${callsSubject.value.length} requests)",
      message,
      platformChannelSpecifics,
      payload: "",
    );
    _notificationMessageShown = message;
    _notificationProcessing = false;
    return;
  }

  /// Add alice http call to calls subject
  void addCall(AliceHttpCall call) {
    final callsCount = callsSubject.value.length;
    if (callsCount >= maxCallsCount) {
      final originalCalls = callsSubject.value;
      final calls = List<AliceHttpCall>.from(originalCalls);
      calls.sort(
        (call1, call2) => call1.createdTime.compareTo(call2.createdTime),
      );
      final indexToReplace = originalCalls.indexOf(calls.first);
      originalCalls[indexToReplace] = call;

      callsSubject.add(originalCalls);
    } else {
      callsSubject.add([...callsSubject.value, call]);
    }
  }

  /// Add error to existing alice http call
  void addError(AliceHttpError error, int requestId) {
    final AliceHttpCall? selectedCall = _selectCall(requestId);

    if (selectedCall == null) {
      AliceUtils.log("Selected call is null");
      return;
    }

    selectedCall.error = error;
    callsSubject.add([...callsSubject.value]);
  }

  /// Add response to existing alice http call
  void addResponse(AliceHttpResponse response, int requestId) {
    final AliceHttpCall? selectedCall = _selectCall(requestId);

    if (selectedCall == null) {
      AliceUtils.log("Selected call is null");
      return;
    }
    selectedCall.loading = false;
    selectedCall.response = response;
    selectedCall.duration = response.time.millisecondsSinceEpoch -
        selectedCall.request!.time.millisecondsSinceEpoch;

    callsSubject.add([...callsSubject.value]);
  }

  /// Add alice http call to calls subject
  void addHttpCall(AliceHttpCall aliceHttpCall) {
    assert(aliceHttpCall.request != null, "Http call request can't be null");
    assert(aliceHttpCall.response != null, "Http call response can't be null");
    callsSubject.add([...callsSubject.value, aliceHttpCall]);
  }

  /// Remove all calls from calls subject
  void removeCalls() {
    callsSubject.add([]);
  }

  AliceHttpCall? _selectCall(int requestId) =>
      callsSubject.value.firstWhereOrNull((call) => call.id == requestId);

  /// Save all calls to file
  void saveHttpRequests(BuildContext context) {
    AliceSaveHelper.saveCalls(context, callsSubject.value, _brightness);
  }

  /// Adds new log to Alice logger.
  void addLog(AliceLog log) {
    _aliceLogger.logs.add(log);
  }

  /// Adds list of logs to Alice logger
  void addLogs(List<AliceLog> logs) {
    _aliceLogger.logs.addAll(logs);
  }
}
