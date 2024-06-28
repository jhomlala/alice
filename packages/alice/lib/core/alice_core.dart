import 'dart:async' show StreamSubscription;
import 'dart:io' show Platform;

import 'package:alice/core/alice_logger.dart';
import 'package:alice/core/alice_utils.dart';
import 'package:alice/helper/alice_save_helper.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_http_error.dart';
import 'package:alice/model/alice_http_response.dart';
import 'package:alice/model/alice_log.dart';
import 'package:alice/ui/common/alice_navigation.dart';
import 'package:alice/utils/num_comparison.dart';
import 'package:alice/utils/shake_detector.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';

class AliceCore {
  /// Should user be notified with notification if there's new request caught
  /// by Alice
  final bool showNotification;

  /// Should inspector be opened on device shake (works only with physical
  /// with sensors)
  final bool showInspectorOnShake;

  /// Rx subject which contains all intercepted http calls
  final BehaviorSubject<List<AliceHttpCall>> callsSubject =
      BehaviorSubject.seeded([]);

  /// Stream which contains all intercepted http calls
  Stream<List<AliceHttpCall>> get callsStream => callsSubject;

  /// Get all calls from calls subject
  List<AliceHttpCall> getCalls() => callsSubject.value;

  /// Icon url for notification
  final String notificationIcon;

  @protected
  late final NotificationDetails notificationDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      'Alice',
      'Alice',
      channelDescription: 'Alice',
      enableVibration: false,
      playSound: false,
      largeIcon: DrawableResourceAndroidBitmap(notificationIcon),
    ),
    iOS: const DarwinNotificationDetails(presentSound: false),
  );

  ///Max number of calls that are stored in memory. When count is reached, FIFO
  ///method queue will be used to remove elements.
  final int maxCallsCount;

  ///Directionality of app. If null then directionality of context will be used.
  final TextDirection? directionality;

  ///Flag used to show/hide share button
  final bool? showShareButton;

  final AliceLogger _aliceLogger = AliceLogger();

  FlutterLocalNotificationsPlugin? _flutterLocalNotificationsPlugin;

  @protected
  FlutterLocalNotificationsPlugin? get flutterLocalNotificationsPlugin =>
      _flutterLocalNotificationsPlugin;

  GlobalKey<NavigatorState>? navigatorKey;

  bool _isInspectorOpened = false;

  ShakeDetector? _shakeDetector;

  StreamSubscription<List<AliceHttpCall>>? _callsSubscription;

  @protected
  String? notificationMessage;

  @protected
  String? notificationMessageShown;

  @protected
  bool notificationProcessing = false;

  /// Creates alice core instance
  AliceCore(
    this.navigatorKey, {
    required this.showNotification,
    required this.showInspectorOnShake,
    required this.notificationIcon,
    required this.maxCallsCount,
    this.directionality,
    this.showShareButton,
  }) {
    if (showNotification) {
      _initializeNotificationsPlugin();
      _requestNotificationPermissions();
      _callsSubscription = callsStream.listen(onCallsChanged);
    }
    if (showInspectorOnShake) {
      if (Platform.isAndroid || Platform.isIOS) {
        _shakeDetector = ShakeDetector.autoStart(
          onPhoneShake: navigateToCallListScreen,
          shakeThresholdGravity: 4,
        );
      }
    }
  }

  /// Dispose subjects and subscriptions
  void dispose() {
    callsSubject.close();
    _shakeDetector?.stopListening();
    _callsSubscription?.cancel();
  }

  @protected
  void _initializeNotificationsPlugin() {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(notificationIcon);
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    const DarwinInitializationSettings initializationSettingsMacOS =
        DarwinInitializationSettings();
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: initializationSettingsMacOS,
    );
    flutterLocalNotificationsPlugin?.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );
  }

  @protected
  Future<void> onCallsChanged([List<AliceHttpCall>? calls]) async {
    if (callsSubject.value.isNotEmpty) {
      notificationMessage = _getNotificationMessage();
      if (notificationMessage != notificationMessageShown &&
          !notificationProcessing) {
        await _showLocalNotification();
        await onCallsChanged();
      }
    }
  }

  Future<void> _onDidReceiveNotificationResponse(
    NotificationResponse response,
  ) async {
    assert(response.payload != null, "payload can't be null");
    navigateToCallListScreen();
  }

  /// Opens Http calls inspector. This will navigate user to the new fullscreen
  /// page where all listened http calls can be viewed.
  void navigateToCallListScreen() {
    final BuildContext? context = getContext();
    if (context == null) {
      AliceUtils.log(
        'Cant start Alice HTTP Inspector. Please add NavigatorKey to your '
        'application',
      );
      return;
    }
    if (!_isInspectorOpened) {
      _isInspectorOpened = true;
      AliceNavigation.navigateToCallsList(core: this, logger: _aliceLogger)
          .then((_) => _isInspectorOpened = false);
    }
  }

  /// Get context from navigator key. Used to open inspector route.
  BuildContext? getContext() => navigatorKey?.currentState?.overlay?.context;

  String _getNotificationMessage() {
    final List<AliceHttpCall> calls = callsSubject.value;
    final int successCalls = calls
        .where(
          (AliceHttpCall call) =>
              (call.response?.status.gte(200) ?? false) &&
              (call.response?.status.lt(300) ?? false),
        )
        .toList()
        .length;

    final int redirectCalls = calls
        .where((AliceHttpCall call) =>
            (call.response?.status.gte(300) ?? false) &&
            (call.response?.status.lt(400) ?? false))
        .toList()
        .length;

    final int errorCalls = calls
        .where(
          (AliceHttpCall call) =>
              (call.response?.status.gte(400) ?? false) &&
              (call.response?.status.lt(600) ?? false),
        )
        .toList()
        .length;

    final int loadingCalls =
        calls.where((call) => call.loading).toList().length;

    return <String>[
      if (loadingCalls > 0) 'Loading: $loadingCalls',
      if (successCalls > 0) 'Success: $successCalls',
      if (redirectCalls > 0) 'Redirect: $redirectCalls',
      if (errorCalls > 0) 'Error: $errorCalls',
    ].join(' | ');
  }

  @protected
  Future<void> _requestNotificationPermissions() async {
    if (Platform.isIOS || Platform.isMacOS) {
      await flutterLocalNotificationsPlugin
          ?.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      await flutterLocalNotificationsPlugin
          ?.resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin
              ?.resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>();

      await androidImplementation?.requestNotificationsPermission();
    }
  }

  Future<void> _showLocalNotification() async {
    try {
      notificationProcessing = true;

      final String? message = notificationMessage;

      await flutterLocalNotificationsPlugin?.show(
        0,
        'Alice (total: ${callsSubject.value.length} requests)',
        message,
        notificationDetails,
        payload: '',
      );

      notificationMessageShown = message;
    } finally {
      notificationProcessing = false;
    }
  }

  /// Add alice http call to calls subject
  void addCall(AliceHttpCall call) {
    final int callsCount = callsSubject.value.length;
    if (callsCount >= maxCallsCount) {
      final List<AliceHttpCall> originalCalls = callsSubject.value;
      final List<AliceHttpCall> calls = [...originalCalls]..sort(
          (AliceHttpCall call1, AliceHttpCall call2) =>
              call1.createdTime.compareTo(call2.createdTime),
        );
      final int indexToReplace = originalCalls.indexOf(calls.first);
      originalCalls[indexToReplace] = call;

      callsSubject.add(originalCalls);
    } else {
      callsSubject.add([...callsSubject.value, call]);
    }
  }

  /// Add error to existing alice http call
  void addError(AliceHttpError error, int requestId) {
    final AliceHttpCall? selectedCall = selectCall(requestId);

    if (selectedCall == null) {
      return AliceUtils.log('Selected call is null');
    }

    selectedCall.error = error;
    callsSubject.add([...callsSubject.value]);
  }

  /// Add response to existing alice http call
  void addResponse(AliceHttpResponse response, int requestId) {
    final AliceHttpCall? selectedCall = selectCall(requestId);

    if (selectedCall == null) {
      return AliceUtils.log('Selected call is null');
    }

    selectedCall
      ..loading = false
      ..response = response
      ..duration = response.time.millisecondsSinceEpoch -
          (selectedCall.request?.time.millisecondsSinceEpoch ?? 0);

    callsSubject.add([...callsSubject.value]);
  }

  /// Add alice http call to calls subject
  void addHttpCall(AliceHttpCall aliceHttpCall) {
    assert(aliceHttpCall.request != null, "Http call request can't be null");
    assert(aliceHttpCall.response != null, "Http call response can't be null");
    callsSubject.add([...callsSubject.value, aliceHttpCall]);
  }

  /// Remove all calls from calls subject
  void removeCalls() => callsSubject.add([]);

  @protected
  AliceHttpCall? selectCall(int requestId) => callsSubject.value
      .firstWhereOrNull((AliceHttpCall call) => call.id == requestId);

  /// Save all calls to file
  void saveHttpRequests(BuildContext context) {
    AliceSaveHelper.saveCalls(context, callsSubject.value);
  }

  /// Adds new log to Alice logger.
  void addLog(AliceLog log) {
    _aliceLogger.logs.add(log);
  }

  /// Adds list of logs to Alice logger
  void addLogs(List<AliceLog> logs) {
    _aliceLogger.logs.addAll(logs);
  }

  /// Returns flag which determines whether inspector is opened
  bool get isInspectorOpened => _isInspectorOpened;
}
