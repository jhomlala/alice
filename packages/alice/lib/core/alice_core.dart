import 'dart:async' show FutureOr, StreamSubscription;

import 'package:alice/core/alice_logger.dart';
import 'package:alice/core/alice_storage.dart';
import 'package:alice/core/alice_utils.dart';
import 'package:alice/helper/alice_export_helper.dart';
import 'package:alice/core/alice_notification_helper.dart';
import 'package:alice/helper/operating_system.dart';
import 'package:alice/model/alice_export_result.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_http_error.dart';
import 'package:alice/model/alice_http_response.dart';
import 'package:alice/model/alice_log.dart';
import 'package:alice/ui/common/alice_navigation.dart';
import 'package:alice/utils/shake_detector.dart';
import 'package:flutter/material.dart';

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

  /// Helper used for notification management
  AliceNotification? _notification;

  /// Subscription for call changes
  StreamSubscription<List<AliceHttpCall>>? _callsSubscription;

  /// Creates alice core instance
  AliceCore(
    this.navigatorKey, {
    required this.showNotification,
    required this.showInspectorOnShake,
    required this.notificationIcon,
    required AliceStorage aliceStorage,
    required AliceLogger aliceLogger,
    this.directionality,
    this.showShareButton,
  })  : _aliceStorage = aliceStorage,
        _aliceLogger = aliceLogger {
    _subscribeToCallChanges();
    if (showNotification) {
      _notification = AliceNotification();
      _notification?.configure(
        notificationIcon: notificationIcon,
        openInspectorCallback: navigateToCallListScreen,
      );
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

  @protected
  Future<void> onCallsChanged(List<AliceHttpCall>? calls) async {
    if (calls != null && calls.isNotEmpty) {
      final AliceStats stats = _aliceStorage.getStats();
      _notification?.showStatsNotification(
        context: getContext()!,
        stats: stats,
      );
    }
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

  /// Save all calls to file.
  Future<AliceExportResult> saveCallsToFile(BuildContext context) {
    return AliceExportHelper.saveCallsToFile(context, _aliceStorage.getCalls());
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
