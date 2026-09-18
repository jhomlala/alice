import 'package:alice/src/services/logger/alice_logger.dart';
import 'package:alice/src/services/storage/alice_memory_storage.dart';
import 'package:alice/src/services/storage/alice_storage.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

class AliceConfiguration extends Equatable {
  /// Default max calls count used in default memory storage.
  static const _defaultMaxCalls = 1000;

  /// Default max logs count.
  static const _defaultMaxLogs = 1000;

  /// Should user be notified with notification when there's new request caught
  /// by Alice. Default value is true.
  final bool showNotification;

  /// Should inspector be opened on device shake (works only with physical
  /// with sensors). Default value is true.
  final bool showInspectorOnShake;

  /// Icon url for notification. Default value is '@mipmap/ic_launcher'.
  final String notificationIcon;

  /// Large icon url for notification.
  final String? notificationLargeIcon;

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

  AliceConfiguration({
    this.showNotification = true,
    this.showInspectorOnShake = true,
    this.notificationIcon = '@mipmap/ic_launcher',
    this.notificationLargeIcon,
    this.directionality,
    this.showShareButton = true,
    this.detectDuplicates = true,
    this.duplicateDetectionWindow = const Duration(milliseconds: 500),
    GlobalKey<NavigatorState>? navigatorKey,
    AliceStorage? storage,
    AliceLogger? logger,
  }) : aliceStorage =
           storage ?? AliceMemoryStorage(maxCallsCount: _defaultMaxCalls),
       navigatorKey = navigatorKey ?? GlobalKey<NavigatorState>(),
       aliceLogger = logger ?? AliceLogger(maximumSize: _defaultMaxLogs);

  AliceConfiguration copyWith({
    GlobalKey<NavigatorState>? navigatorKey,
    bool? showNotification,
    bool? showInspectorOnShake,
    String? notificationIcon,
    String? notificationLargeIcon,
    TextDirection? directionality,
    bool? showShareButton,
    bool? detectDuplicates,
    Duration? duplicateDetectionWindow,
    AliceStorage? aliceStorage,
    AliceLogger? aliceLogger,
  }) => AliceConfiguration(
    showNotification: showNotification ?? this.showNotification,
    showInspectorOnShake: showInspectorOnShake ?? this.showInspectorOnShake,
    notificationIcon: notificationIcon ?? this.notificationIcon,
    notificationLargeIcon: notificationLargeIcon ?? this.notificationLargeIcon,
    directionality: directionality ?? this.directionality,
    showShareButton: showShareButton ?? this.showShareButton,
    detectDuplicates: detectDuplicates ?? this.detectDuplicates,
    duplicateDetectionWindow: duplicateDetectionWindow ?? this.duplicateDetectionWindow,
    navigatorKey: navigatorKey ?? this.navigatorKey,
    storage: aliceStorage ?? this.aliceStorage,
    logger: aliceLogger ?? this.aliceLogger,
  );

  @override
  List<Object?> get props => [
    showNotification,
    showInspectorOnShake,
    notificationIcon,
    notificationLargeIcon,
    directionality,
    showShareButton,
    detectDuplicates,
    duplicateDetectionWindow,
    navigatorKey,
    aliceStorage,
    aliceLogger,
  ];
}
