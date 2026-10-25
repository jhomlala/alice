import 'package:alice/src/services/logger/alice_logger.dart';
import 'package:alice/src/services/notification/alice_notification_adapter.dart';
import 'package:alice/src/services/storage/alice_memory_storage.dart';
import 'package:alice/src/services/storage/alice_storage.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

class AliceConfiguration extends Equatable {
  /// Default max calls count used in default memory storage.
  static const _defaultMaxCalls = 1000;

  /// Default max logs count.
  static const _defaultMaxLogs = 1000;

  /// External notification adapter to show OS notifications when calls arrive.
  /// If null, OS notifications are disabled.
  final AliceNotificationAdapter? notificationAdapter;

  /// Whether to display a floating draggable in-app bubble with live call stats.
  /// When enabled, the bubble automatically appears once the first HTTP call is recorded.
  /// Styled with Alice colors: green for successes, orange for in-flight requests, and red for errors.
  final bool showOverlayBubble;

  /// Should inspector be opened on device shake (works only with physical
  /// with sensors). Default value is true.
  final bool showInspectorOnShake;

  /// Directionality of app. Directionality of the app will be used if set to
  /// null. Default value is null.
  final TextDirection? directionality;

  /// Flag used to show/hide share button
  final bool showShareButton;

  /// Navigator key used to open inspector. Default value is null.
  final GlobalKey<NavigatorState>? navigatorKey;

  /// Storage where calls will be saved. The default storage is memory storage.
  final AliceStorage aliceStorage;

  /// Logger instance.
  final AliceLogger aliceLogger;

  /// Whether duplicate requests (same method & endpoint) should be detected.
  final bool detectDuplicates;

  /// Time window to consider requests as duplicates. Default is 500 ms.
  final Duration duplicateDetectionWindow;

  /// Case-insensitive header names whose values will be replaced with [redactionReplacement] at capture time.
  final Set<String> redactedHeaders;

  /// Case-insensitive JSON/Map keys, query parameter keys, and form-data field names
  /// whose values will be replaced with [redactionReplacement] at capture time.
  final Set<String> redactedBodyKeys;

  /// Replacement string used for redacted values. Defaults to `'[REDACTED]'`.
  final String redactionReplacement;

  AliceConfiguration({
    this.notificationAdapter,
    this.showOverlayBubble = false,
    this.showInspectorOnShake = true,
    this.directionality,
    this.showShareButton = true,
    this.detectDuplicates = true,
    this.duplicateDetectionWindow = const Duration(milliseconds: 500),
    this.redactedHeaders = const {},
    this.redactedBodyKeys = const {},
    this.redactionReplacement = '[REDACTED]',
    GlobalKey<NavigatorState>? navigatorKey,
    AliceStorage? storage,
    AliceLogger? logger,
  }) : aliceStorage =
           storage ?? AliceMemoryStorage(maxCallsCount: _defaultMaxCalls),
       navigatorKey = navigatorKey ?? GlobalKey<NavigatorState>(),
       aliceLogger = logger ?? AliceLogger(maximumSize: _defaultMaxLogs);

  AliceConfiguration copyWith({
    GlobalKey<NavigatorState>? navigatorKey,
    AliceNotificationAdapter? notificationAdapter,
    bool? showOverlayBubble,
    bool? showInspectorOnShake,
    TextDirection? directionality,
    bool? showShareButton,
    bool? detectDuplicates,
    Duration? duplicateDetectionWindow,
    Set<String>? redactedHeaders,
    Set<String>? redactedBodyKeys,
    String? redactionReplacement,
    AliceStorage? aliceStorage,
    AliceLogger? aliceLogger,
  }) => AliceConfiguration(
    notificationAdapter: notificationAdapter ?? this.notificationAdapter,
    showOverlayBubble: showOverlayBubble ?? this.showOverlayBubble,
    showInspectorOnShake: showInspectorOnShake ?? this.showInspectorOnShake,
    directionality: directionality ?? this.directionality,
    showShareButton: showShareButton ?? this.showShareButton,
    detectDuplicates: detectDuplicates ?? this.detectDuplicates,
    duplicateDetectionWindow:
        duplicateDetectionWindow ?? this.duplicateDetectionWindow,
    redactedHeaders: redactedHeaders ?? this.redactedHeaders,
    redactedBodyKeys: redactedBodyKeys ?? this.redactedBodyKeys,
    redactionReplacement: redactionReplacement ?? this.redactionReplacement,
    navigatorKey: navigatorKey ?? this.navigatorKey,
    storage: aliceStorage ?? this.aliceStorage,
    logger: aliceLogger ?? this.aliceLogger,
  );

  @override
  List<Object?> get props => [
    notificationAdapter,
    showOverlayBubble,
    showInspectorOnShake,
    directionality,
    showShareButton,
    detectDuplicates,
    duplicateDetectionWindow,
    redactedHeaders,
    redactedBodyKeys,
    redactionReplacement,
    navigatorKey,
    aliceStorage,
    aliceLogger,
  ];
}
