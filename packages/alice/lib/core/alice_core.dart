import 'dart:async' show StreamSubscription;
import 'dart:io' show Platform;

import 'package:alice/core/alice_logger.dart';
import 'package:alice/core/alice_storage.dart';
import 'package:alice/core/alice_utils.dart';
import 'package:alice/helper/alice_save_helper.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_http_error.dart';
import 'package:alice/model/alice_http_response.dart';
import 'package:alice/model/alice_log.dart';
import 'package:alice/model/alice_translation.dart';
import 'package:alice/ui/common/alice_context_ext.dart';
import 'package:alice/ui/common/alice_navigation.dart';
import 'package:alice/utils/shake_detector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

typedef AliceOnCallsChanged = Future<void> Function(List<AliceHttpCall>? calls);

class AliceCore {
  /// Should user be notified with notification if there's new request caught
  /// by Alice
  final bool showNotification;

  /// Should inspector be opened on device shake (works only with physical
  /// with sensors)
  final bool showInspectorOnShake;

  /// Icon url for notification
  final String notificationIcon;

  final AliceStorage _aliceStorage;

  late final NotificationDetails _notificationDetails = NotificationDetails(
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

  GlobalKey<NavigatorState>? navigatorKey;

  bool _isInspectorOpened = false;

  ShakeDetector? _shakeDetector;

  StreamSubscription<List<AliceHttpCall>>? _callsSubscription;

  String? _notificationMessage;

  String? _notificationMessageShown;

  bool _notificationProcessing = false;

  /// Creates alice core instance
  AliceCore(
    this.navigatorKey, {
    required this.showNotification,
    required this.showInspectorOnShake,
    required this.notificationIcon,
    required this.maxCallsCount,
    required AliceStorage aliceStorage,
    this.directionality,
    this.showShareButton,
  }) : _aliceStorage = aliceStorage {
    if (showNotification) {
      _initializeNotificationsPlugin();
      _requestNotificationPermissions();
      _aliceStorage.subscribeToCallChanges(onCallsChanged);
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
    _flutterLocalNotificationsPlugin?.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );
  }

  @protected
  Future<void> onCallsChanged(List<AliceHttpCall>? calls) async {
    if (calls != null && calls.isNotEmpty) {
      final AliceStats stats = _aliceStorage.getStats();

      _notificationMessage = _getNotificationMessage(stats);
      if (_notificationMessage != _notificationMessageShown &&
          !_notificationProcessing) {
        await _showLocalNotification(stats);
      }
    }
  }

  Future<void> _onDidReceiveNotificationResponse(
    NotificationResponse response,
  ) async {
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

  String _getNotificationMessage(AliceStats stats) => <String>[
        if (stats.loading > 0)
          '${getContext()?.i18n(AliceTranslationKey.notificationLoading)} ${stats.loading}',
        if (stats.successes > 0)
          '${getContext()?.i18n(AliceTranslationKey.notificationSuccess)} ${stats.successes}',
        if (stats.redirects > 0)
          '${getContext()?.i18n(AliceTranslationKey.notificationRedirect)} ${stats.redirects}',
        if (stats.errors > 0)
          '${getContext()?.i18n(AliceTranslationKey.notificationError)} ${stats.errors}',
      ].join(' | ');

  Future<void> _requestNotificationPermissions() async {
    if (Platform.isIOS || Platform.isMacOS) {
      await _flutterLocalNotificationsPlugin
          ?.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      await _flutterLocalNotificationsPlugin
          ?.resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin
              ?.resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>();

      await androidImplementation?.requestNotificationsPermission();
    }
  }

  Future<void> _showLocalNotification(AliceStats stats) async {
    try {
      _notificationProcessing = true;

      final String? message = _notificationMessage;

      await _flutterLocalNotificationsPlugin?.show(
        0,
        getContext()
            ?.i18n(AliceTranslationKey.notificationTotalRequests)
            .replaceAll("[requestCount]", stats.total.toString()),
        message,
        _notificationDetails,
        payload: '',
      );

      _notificationMessageShown = message;
    } finally {
      _notificationProcessing = false;
    }
  }

  /// Add alice http call to calls subject
  void addCall(AliceHttpCall call) => _aliceStorage.addCall(call);

  /// Add error to existing alice http call
  void addError(AliceHttpError error, int requestId) =>
      _aliceStorage.addError(error, requestId);

  /// Add response to existing alice http call
  void addResponse(AliceHttpResponse response, int requestId) =>
      _aliceStorage.addResponse(response, requestId);

  /// Add alice http call to calls subject
  void addHttpCall(AliceHttpCall aliceHttpCall) =>
      _aliceStorage.addHttpCall(aliceHttpCall);

  /// Remove all calls from calls subject
  void removeCalls() => _aliceStorage.removeCalls();

  @protected
  AliceHttpCall? selectCall(int requestId) =>
      _aliceStorage.selectCall(requestId);

  Stream<List<AliceHttpCall>> get callsStream => _aliceStorage.callsStream;

  List<AliceHttpCall> getCalls() => _aliceStorage.getCalls();

  /// Save all calls to file
  void saveHttpRequests(BuildContext context) {
    AliceSaveHelper.saveCalls(context, _aliceStorage.getCalls());
  }

  /// Adds new log to Alice logger.
  void addLog(AliceLog log) => _aliceLogger.logs.add(log);

  /// Adds list of logs to Alice logger
  void addLogs(List<AliceLog> logs) => _aliceLogger.logs.addAll(logs);

  /// Returns flag which determines whether inspector is opened
  bool get isInspectorOpened => _isInspectorOpened;
}
