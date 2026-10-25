import 'dart:async' show FutureOr, StreamSubscription;

import 'package:alice/src/services/storage/alice_storage.dart';
import 'package:alice/src/utils/utils.dart';
import 'package:alice/src/export/exporter.dart';
import 'package:alice/src/export/export_service.dart';
import 'package:alice/src/utils/operating_system.dart';
import 'package:alice/src/services/replay/replay_service.dart';
import 'package:alice/src/services/tag/alice_tag_service.dart';
import 'package:alice/src/services/duplicate/alice_duplicate_detector.dart';
import 'package:alice/src/services/overlay/alice_overlay_service.dart';
import 'package:alice/src/services/redaction/alice_redaction_service.dart';
import 'package:alice/src/services/vm/alice_vm_service.dart';
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

  /// Subscription for call changes
  StreamSubscription<List<AliceHttpCall>>? _callsSubscription;

  /// Flag used to determine whether is inspector opened
  bool _isInspectorOpened = false;

  late final ReplayService _replayService;

  late final AliceTagService tagService;

  late final AliceOverlayService _overlayService;

  late final AliceRedactionService _redactionService;

  /// Creates alice core instance
  AliceCore({required AliceConfiguration configuration}) {
    _configuration = configuration;
    _replayService = ReplayService(this);
    tagService = AliceTagService();
    _overlayService = AliceOverlayService();
    _redactionService = AliceRedactionService(configuration: _configuration);

    _subscribeToCallChanges();

    _configuration.notificationAdapter?.configure(
      openInspectorCallback: navigateToCallListScreen,
    );

    if (_configuration.showInspectorOnShake) {
      if (OperatingSystem.isAndroid || OperatingSystem.isIOS) {
        _shakeDetector = ShakeDetector.autoStart(
          onPhoneShake: navigateToCallListScreen,
          shakeThresholdGravity: 4,
        );
      }
    }

    AliceVmService.register(this);
  }

  /// Returns current configuration
  AliceConfiguration get configuration => _configuration;

  /// Set custom navigation key. This will help if there's route library.
  void setNavigatorKey(GlobalKey<NavigatorState> navigatorKey) {
    _configuration = _configuration.copyWith(navigatorKey: navigatorKey);
    if (_configuration.showOverlayBubble) {
      final overlay = navigatorKey.currentState?.overlay;
      _overlayService.ensureInserted(overlayState: overlay, core: this);
    }
  }

  /// Manually shows or ensures the floating overlay bubble is displayed.
  void showOverlayBubble() {
    final overlay = _configuration.navigatorKey?.currentState?.overlay;
    _overlayService.ensureInserted(overlayState: overlay, core: this);
  }

  /// Dispose subjects and subscriptions
  void dispose() {
    _shakeDetector?.stopListening();
    _overlayService.remove();
    _configuration.notificationAdapter?.dispose();
    _unsubscribeFromCallChanges();
  }

  /// Called when calls has been updated
  Future<void> _onCallsChanged(List<AliceHttpCall>? calls) async {
    if (_configuration.showOverlayBubble) {
      final overlay = _configuration.navigatorKey?.currentState?.overlay;
      _overlayService.ensureInserted(overlayState: overlay, core: this);
    }

    if (_configuration.notificationAdapter != null &&
        calls != null &&
        calls.isNotEmpty) {
      final BuildContext? context = getContext();
      if (context != null) {
        final AliceStats stats = _configuration.aliceStorage.getStats();
        await _configuration.notificationAdapter?.showStatsNotification(
          context: context,
          stats: stats,
        );
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
      _overlayService.markNeedsBuild();
      await Navigation.navigateToCallsList(core: this);
      _isInspectorOpened = false;
      _overlayService.markNeedsBuild();
    }
  }

  /// Get context from navigator key. Used to open inspector route.
  BuildContext? getContext() =>
      _configuration.navigatorKey?.currentState?.overlay?.context;

  /// Add alice http call to calls subject
  FutureOr<void> addCall(AliceHttpCall call) {
    call.tag = tagService.consumeTag();
    if (_configuration.detectDuplicates) {
      AliceDuplicateDetector.inspect(
        newCall: call,
        existingCalls: getCalls(),
        window: _configuration.duplicateDetectionWindow,
      );
    }
    _redactionService.redactCall(call);
    return _configuration.aliceStorage.addCall(call);
  }

  /// Add error to existing alice http call
  FutureOr<void> addError(AliceHttpError error, int requestId) =>
      _configuration.aliceStorage.addError(error, requestId);

  /// Add response to existing alice http call
  FutureOr<void> addResponse(AliceHttpResponse response, int requestId) {
    _redactionService.redactResponse(response);
    return _configuration.aliceStorage.addResponse(response, requestId);
  }

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
