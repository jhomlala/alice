import 'dart:async' show FutureOr, StreamSubscription;

import 'package:alice/src/services/storage/alice_storage.dart';
import 'package:alice/src/utils/AliceUtils.dart';
import 'package:alice/src/export/exporter.dart';
import 'package:alice/src/export/export_service.dart';
import 'package:alice/src/services/notification/notification.dart';
import 'package:alice/src/utils/operating_system.dart';
import 'package:alice/src/services/replay/replay_service.dart';
import 'package:alice/src/model/alice_configuration.dart';
import 'package:alice/src/model/export_result.dart';
import 'package:alice/src/model/alice_http_call.dart';
import 'package:alice/src/model/alice_http_error.dart';
import 'package:alice/src/model/alice_http_response.dart';
import 'package:alice/src/model/alice_log.dart';
import 'package:alice/src/ui/common/navigation.dart';
import 'package:alice/src/services/shake_detector/shake_detector.dart';
import 'package:material_ui/material_ui.dart';

class AliceCore {
  /// Configuration of Alice
  late AliceConfiguration _configuration;

  /// Detector used to detect device shakes
  ShakeDetector? _shakeDetector;

  /// Service used for notification management
  AliceNotificationService? _notification;

  /// Subscription for call changes
  StreamSubscription<List<AliceHttpCall>>? _callsSubscription;

  /// Flag used to determine whether is inspector opened
  bool _isInspectorOpened = false;

  late final ReplayService _replayService;

  /// Creates alice core instance
  AliceCore({required AliceConfiguration configuration}) {
    _configuration = configuration;
    _replayService = ReplayService(this);
    _subscribeToCallChanges();
    if (_configuration.showNotification) {
      _notification = AliceNotificationService();
      _notification?.configure(
        notificationIcon: _configuration.notificationIcon,
        notificationLargeIcon: _configuration.notificationLargeIcon,
        openInspectorCallback: navigateToCallListScreen,
      );
    }
    if (_configuration.showInspectorOnShake) {
      if (OperatingSystem.isAndroid || OperatingSystem.isIOS) {
        _shakeDetector = ShakeDetector.autoStart(
          onPhoneShake: navigateToCallListScreen,
          shakeThresholdGravity: 4,
        );
      }
    }
  }

  /// Returns current configuration
  AliceConfiguration get configuration => _configuration;

  /// Set custom navigation key. This will help if there's route library.
  void setNavigatorKey(GlobalKey<NavigatorState> navigatorKey) {
    _configuration = _configuration.copyWith(navigatorKey: navigatorKey);
  }

  /// Dispose subjects and subscriptions
  void dispose() {
    _shakeDetector?.stopListening();
    _unsubscribeFromCallChanges();
  }

  /// Called when calls has been updated
  Future<void> _onCallsChanged(List<AliceHttpCall>? calls) async {
    if (!_configuration.showNotification || _notification == null) {
      return;
    }

    if (calls != null && calls.isNotEmpty) {
      final BuildContext? context = getContext();
      if (context != null) {
        final AliceStats stats = _configuration.aliceStorage.getStats();
        _notification?.showStatsNotification(context: context, stats: stats);
      }
    }
  }

  /// Opens Http calls inspector. This will navigate user to the new fullscreen
  /// page where all listened http calls can be viewed.
  Future<void> navigateToCallListScreen() async {
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
      await Navigation.navigateToCallsList(core: this);
      _isInspectorOpened = false;
    }
  }

  /// Get context from navigator key. Used to open inspector route.
  BuildContext? getContext() =>
      _configuration.navigatorKey?.currentState?.overlay?.context;

  /// Add alice http call to calls subject
  FutureOr<void> addCall(AliceHttpCall call) =>
      _configuration.aliceStorage.addCall(call);

  /// Add error to existing alice http call
  FutureOr<void> addError(AliceHttpError error, int requestId) =>
      _configuration.aliceStorage.addError(error, requestId);

  /// Add response to existing alice http call
  FutureOr<void> addResponse(AliceHttpResponse response, int requestId) =>
      _configuration.aliceStorage.addResponse(response, requestId);

  /// Remove all calls from calls subject
  FutureOr<void> removeCalls() => _configuration.aliceStorage.removeCalls();

  /// Selects call with given [requestId]. It may return null.
  @protected
  AliceHttpCall? selectCall(int requestId) =>
      _configuration.aliceStorage.selectCall(requestId);

  /// Returns stream which returns list of HTTP calls
  Stream<List<AliceHttpCall>> get callsStream =>
      _configuration.aliceStorage.callsStream;

  /// Returns all stored HTTP calls.
  List<AliceHttpCall> getCalls() => _configuration.aliceStorage.getCalls();

  /// Export all calls using [exporter].
  Future<ExportResult> exportCalls({
    required BuildContext context,
    required Exporter exporter,
  }) => ExportService.exportCalls(
    context: context,
    calls: getCalls(),
    exporter: exporter,
  );

  /// Replays given [originalCall].
  Future<void> replayCall({
    required AliceHttpCall originalCall,
    required BuildContext context,
  }) => _replayService.replayCall(originalCall: originalCall, context: context);

  /// Adds new log to Alice logger.
  void addLog(AliceLog log) => _configuration.aliceLogger.add(log);

  /// Adds list of logs to Alice logger
  void addLogs(List<AliceLog> logs) => _configuration.aliceLogger.addAll(logs);

  /// Returns flag which determines whether inspector is opened
  bool get isInspectorOpened => _isInspectorOpened;

  /// Subscribes to storage for call changes.
  void _subscribeToCallChanges() {
    _callsSubscription = _configuration.aliceStorage.callsStream.listen(
      _onCallsChanged,
    );
  }

  /// Unsubscribes storage for call changes.
  void _unsubscribeFromCallChanges() {
    _callsSubscription?.cancel();
    _callsSubscription = null;
  }
}
