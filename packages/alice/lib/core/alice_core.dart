import 'dart:async' show FutureOr, StreamSubscription;

import 'package:alice/core/alice_storage.dart';
import 'package:alice/core/alice_utils.dart';
import 'package:alice/helper/alice_exporter.dart';
import 'package:alice/helper/alice_export_helper.dart';
import 'package:alice/core/alice_notification.dart';
import 'package:alice/helper/operating_system.dart';
import 'package:alice/model/alice_configuration.dart';
import 'package:alice/model/alice_export_result.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_http_error.dart';
import 'package:alice/model/alice_http_response.dart';
import 'package:alice/model/alice_http_request.dart';
import 'package:alice/model/alice_log.dart';
import 'package:alice/ui/common/alice_loading_dialog.dart';
import 'package:alice/ui/common/alice_navigation.dart';
import 'package:alice/utils/shake_detector.dart';
import 'package:material_ui/material_ui.dart';
import 'dart:io' show HttpClient, HttpClientRequest, HttpClientResponse, HttpHeaders;
import 'dart:convert' show utf8;

class AliceCore {
  /// Configuration of Alice
  late AliceConfiguration _configuration;

  /// Detector used to detect device shakes
  ShakeDetector? _shakeDetector;

  /// Helper used for notification management
  AliceNotification? _notification;

  /// Subscription for call changes
  StreamSubscription<List<AliceHttpCall>>? _callsSubscription;

  /// Flag used to determine whether is inspector opened
  bool _isInspectorOpened = false;

  /// Creates alice core instance
  AliceCore({required AliceConfiguration configuration}) {
    _configuration = configuration;
    _subscribeToCallChanges();
    if (_configuration.showNotification) {
      _notification = AliceNotification();
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
      await AliceNavigation.navigateToCallsList(core: this);
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
  Future<AliceExportResult> exportCalls({
    required BuildContext context,
    required AliceExporter exporter,
  }) => AliceExportHelper.exportCalls(
    context: context,
    calls: getCalls(),
    exporter: exporter,
  );

  /// Replays given [originalCall].
  Future<void> replayCall({
    required AliceHttpCall originalCall,
    required BuildContext context,
  }) async {
    if (originalCall.request?.formDataFiles != null &&
        originalCall.request!.formDataFiles!.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Multipart/FormData replays are not yet supported.'),
        ),
      );
      return;
    }

    final int newId = DateTime.now().millisecondsSinceEpoch;
    final AliceHttpCall newCall = AliceHttpCall(newId)
      ..client = originalCall.client
      ..method = originalCall.method
      ..endpoint = originalCall.endpoint
      ..server = originalCall.server
      ..uri = originalCall.uri
      ..secure = originalCall.secure
      ..isReplay = true;

    final AliceHttpRequest newRequest = AliceHttpRequest()
      ..time = DateTime.now()
      ..contentType = originalCall.request?.contentType
      ..headers = Map<String, String>.from(originalCall.request?.headers ?? {})
      ..queryParameters = Map<String, dynamic>.from(originalCall.request?.queryParameters ?? {})
      ..body = originalCall.request?.body;

    newCall.request = newRequest;
    await addCall(newCall);

    final Stopwatch stopwatch = Stopwatch()..start();
    AliceLoadingDialog.show(context);

    try {
      final HttpClient httpClient = HttpClient();
      final Uri parsedUri = Uri.parse(originalCall.uri);
      HttpClientRequest request;
      
      switch (originalCall.method.toUpperCase()) {
        case 'GET':
          request = await httpClient.getUrl(parsedUri);
          break;
        case 'POST':
          request = await httpClient.postUrl(parsedUri);
          break;
        case 'PUT':
          request = await httpClient.putUrl(parsedUri);
          break;
        case 'DELETE':
          request = await httpClient.deleteUrl(parsedUri);
          break;
        case 'PATCH':
          request = await httpClient.patchUrl(parsedUri);
          break;
        case 'HEAD':
          request = await httpClient.headUrl(parsedUri);
          break;
        default:
          request = await httpClient.openUrl(originalCall.method, parsedUri);
          break;
      }

      newRequest.headers.forEach((key, value) {
        if (key.toLowerCase() != 'content-length') {
          request.headers.set(key, value);
        }
      });

      if (newRequest.body != null &&
          newRequest.body.toString().isNotEmpty &&
          ['POST', 'PUT', 'PATCH', 'DELETE'].contains(originalCall.method.toUpperCase())) {
        if (newRequest.body is String) {
          request.write(newRequest.body);
        } else if (newRequest.body is List<int>) {
          request.add(newRequest.body);
        } else {
          request.write(newRequest.body.toString());
        }
      }

      final HttpClientResponse response = await request.close();
      stopwatch.stop();

      final List<int> responseBytes = await response.fold<List<int>>([], (buffer, chunk) => buffer..addAll(chunk));
      String responseBody = '';
      try {
        responseBody = utf8.decode(responseBytes);
      } catch (_) {
        responseBody = responseBytes.toString();
      }

      final Map<String, String> responseHeaders = {};
      response.headers.forEach((name, values) {
        responseHeaders[name] = values.join(', ');
      });

      final AliceHttpResponse aliceResponse = AliceHttpResponse()
        ..status = response.statusCode
        ..time = DateTime.now()
        ..size = responseBytes.length
        ..headers = responseHeaders
        ..body = responseBody;

      newCall.duration = stopwatch.elapsedMilliseconds;
      newCall.loading = false;
      await addResponse(aliceResponse, newId);
      AliceLoadingDialog.hide(context);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request replayed successfully')),
        );
      }
    } catch (error, stackTrace) {
      stopwatch.stop();
      newCall.duration = stopwatch.elapsedMilliseconds;
      newCall.loading = false;
      
      final AliceHttpError aliceError = AliceHttpError()
        ..error = error
        ..stackTrace = stackTrace;

      await addError(aliceError, newId);
      AliceLoadingDialog.hide(context);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Replay failed: $error')),
        );
      }
    }
  }

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
