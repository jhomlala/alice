import 'dart:async' show FutureOr, StreamSubscription;

import 'package:alice/core/alice_logger.dart';
import 'package:alice/core/alice_storage.dart';
import 'package:alice/core/alice_utils.dart';
import 'package:alice/helper/alice_save_helper.dart';
import 'package:alice/helper/operating_system.dart';
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

  /// Storage used for Alice to keep calls data.
  final AliceStorage _aliceStorage;

  /// Logger used for Alice to keep logs;
  final AliceLogger _aliceLogger;

  /// Notification configuration for Alice.
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

  ///Directionality of app. If null then directionality of context will be used.
  final TextDirection? directionality;

  ///Flag used to show/hide share button
  final bool? showShareButton;

  /// Navigator key used for inspector navigator.
  GlobalKey<NavigatorState>? navigatorKey;

  /// Flag used to determine whether is inspector opened
  bool _isInspectorOpened = false;

  /// Detector used to detect device shakes
  ShakeDetector? _shakeDetector;

  /// Subscription for call changes
  StreamSubscription<List<AliceHttpCall>>? _callsSubscription;

  /// Currently displayed notification message
  String? _notificationMessageDisplayed;

  /// Is current notification being processed
  bool _isNotificationProcessing = false;

  /// Notification plugin instance
  FlutterLocalNotificationsPlugin? _flutterLocalNotificationsPlugin;

  /// Creates alice core instance
  AliceCore(this.navigatorKey, {
    required this.showNotification,
    required this.showInspectorOnShake,
    required this.notificationIcon,
    required AliceStorage aliceStorage,
    required AliceLogger aliceLogger,
    this.directionality,
    this.showShareButton,
  })
      : _aliceStorage = aliceStorage,
        _aliceLogger = aliceLogger {
    _subscribeToCallChanges();
    if (showNotification) {
      _initializeNotificationsPlugin();
      _requestNotificationPermissions();
    }
    if (showInspectorOnShake) {
      if (OperatingSystem.isAndroid() || OperatingSystem.isMacOS()) {
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
    _unsubscribeFromCallChanges();
  }

  /// Initialises notification settings.
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
      _showStatsNotification(stats: stats);
    }
  }

  /// Called when notification has been clicked. It navigates to calls screen.
  Future<void> _onDidReceiveNotificationResponse(
      NotificationResponse response,) async {
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

  /// Formats [stats] for notification message.
  String _getNotificationMessage(AliceStats stats) =>
      <String>[
        if (stats.loading > 0)
          '${getContext()?.i18n(
              AliceTranslationKey.notificationLoading)} ${stats.loading}',
        if (stats.successes > 0)
          '${getContext()?.i18n(
              AliceTranslationKey.notificationSuccess)} ${stats.successes}',
        if (stats.redirects > 0)
          '${getContext()?.i18n(
              AliceTranslationKey.notificationRedirect)} ${stats.redirects}',
        if (stats.errors > 0)
          '${getContext()?.i18n(AliceTranslationKey.notificationError)} ${stats
              .errors}',
      ].join(' | ');

  /// Requests notification permissions to display stats notification.
  Future<void> _requestNotificationPermissions() async {
    if (OperatingSystem.isIOS() || OperatingSystem.isMacOS()) {
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
    } else if (OperatingSystem.isAndroid()) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
      _flutterLocalNotificationsPlugin
          ?.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      await androidImplementation?.requestNotificationsPermission();
    }
  }

  /// Shows current stats notification. It formats [stats] into simple
  /// notification which is displayed when stats has changed.
  Future<void> _showStatsNotification({required AliceStats stats}) async {
    try {
      if (_isNotificationProcessing) {
        return;
      }
      final message = _getNotificationMessage(stats);
      if (message == _notificationMessageDisplayed) {
        return;
      }

      _isNotificationProcessing = true;

      await _flutterLocalNotificationsPlugin?.show(
        0,
        getContext()
            ?.i18n(AliceTranslationKey.notificationTotalRequests)
            .replaceAll("[requestCount]", stats.total.toString()),
        message,
        _notificationDetails,
        payload: '',
      );

      _notificationMessageDisplayed = message;
    } catch (error) {
      AliceUtils.log(error.toString());
    } finally {
      _isNotificationProcessing = false;
    }
  }

  /// Add alice http call to calls subject
  FutureOr<void> addCall(AliceHttpCall call) => _aliceStorage.addCall(call);

  /// Add error to existing alice http call
  FutureOr<void> addError(AliceHttpError error, int requestId) =>
      _aliceStorage.addError(error, requestId);

  /// Add response to existing alice http call
  FutureOr<void> addResponse(AliceHttpResponse response, int requestId) =>
      _aliceStorage.addResponse(response, requestId);

  /// Remove all calls from calls subject
  FutureOr<void> removeCalls() => _aliceStorage.removeCalls();

  /// Selects call with given [requestId]. It may return null.
  @protected
  AliceHttpCall? selectCall(int requestId) =>
      _aliceStorage.selectCall(requestId);

  /// Returns stream which returns list of HTTP calls
  Stream<List<AliceHttpCall>> get callsStream => _aliceStorage.callsStream;

  /// Returns all stored HTTP calls.
  List<AliceHttpCall> getCalls() => _aliceStorage.getCalls();

  /// Save all calls to file
  void saveHttpRequests(BuildContext context) {
    AliceSaveHelper.saveCalls(context, _aliceStorage.getCalls());
  }

  /// Adds new log to Alice logger.
  void addLog(AliceLog log) => _aliceLogger.add(log);

  /// Adds list of logs to Alice logger
  void addLogs(List<AliceLog> logs) => _aliceLogger.addAll(logs);

  /// Returns flag which determines whether inspector is opened
  bool get isInspectorOpened => _isInspectorOpened;

  /// Subscribes to storage for call changes.
  void _subscribeToCallChanges() {
    _callsSubscription = _aliceStorage.callsStream.listen(onCallsChanged);
  }

  /// Unsubscribes storage for call changes.
  void _unsubscribeFromCallChanges() {
    _callsSubscription?.cancel();
    _callsSubscription = null;
  }
}
