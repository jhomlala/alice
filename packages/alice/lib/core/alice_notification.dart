import 'package:alice/core/alice_storage.dart';
import 'package:alice/core/alice_utils.dart';
import 'package:alice/helper/operating_system.dart';
import 'package:alice/model/alice_translation.dart';
import 'package:alice/ui/common/alice_context_ext.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Helper for displaying local notifications.
class AliceNotification {
  static const String _payload = 'Alice';
  static const String _channel = 'Alice';
  static const String _callCount = '[callCount]';

  /// Notification plugin instance
  FlutterLocalNotificationsPlugin? _flutterLocalNotificationsPlugin;

  /// Notification configuration for Alice.
  late final NotificationDetails _notificationDetails;

  /// Callback used to open inspector on notification click.
  late final void Function() _openInspectorCallback;

  /// Currently displayed notification message
  String? _notificationMessageDisplayed;

  /// Is current notification being processed
  bool _isNotificationProcessing = false;

  /// Configures local notifications with [notificationIcon] and
  /// [openInspectorCallback].
  void configure({
    required String notificationIcon,
    required void Function() openInspectorCallback,
  }) {
    _openInspectorCallback = openInspectorCallback;
    _notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        _channel,
        _channel,
        channelDescription: _channel,
        enableVibration: false,
        playSound: false,
        largeIcon: DrawableResourceAndroidBitmap(notificationIcon),
      ),
      iOS: const DarwinNotificationDetails(presentSound: false),
    );

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
    _requestNotificationPermissions();
  }

  /// Requests notification permissions to display stats notification.
  Future<void> _requestNotificationPermissions() async {
    if (OperatingSystem.isIOS || OperatingSystem.isMacOS) {
      await _flutterLocalNotificationsPlugin
          ?.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      await _flutterLocalNotificationsPlugin
          ?.resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } else if (OperatingSystem.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin
              ?.resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      await androidImplementation?.requestNotificationsPermission();
    }
  }

  /// Called when notification has been clicked. It navigates to calls screen.
  Future<void> _onDidReceiveNotificationResponse(
    NotificationResponse response,
  ) async {
    _openInspectorCallback();
  }

  /// Formats [stats] for notification message.
  String _getNotificationMessage({
    required BuildContext context,
    required AliceStats stats,
  }) => <String>[
    if (stats.loading > 0)
      '${context.i18n(AliceTranslationKey.notificationLoading)} ${stats.loading}',
    if (stats.successes > 0)
      '${context.i18n(AliceTranslationKey.notificationSuccess)} ${stats.successes}',
    if (stats.redirects > 0)
      '${context.i18n(AliceTranslationKey.notificationRedirect)} ${stats.redirects}',
    if (stats.errors > 0)
      '${context.i18n(AliceTranslationKey.notificationError)} ${stats.errors}',
  ].join(' | ');

  /// Shows current stats notification. It formats [stats] into simple
  /// notification which is displayed when stats has changed.
  Future<void> showStatsNotification({
    required BuildContext context,
    required AliceStats stats,
  }) async {
    try {
      if (_isNotificationProcessing) {
        return;
      }
      final message = _getNotificationMessage(context: context, stats: stats);
      if (message == _notificationMessageDisplayed) {
        return;
      }

      _isNotificationProcessing = true;

      await _flutterLocalNotificationsPlugin?.show(
        0,
        context
            .i18n(AliceTranslationKey.notificationTotalRequests)
            .replaceAll(_callCount, stats.total.toString()),
        message,
        _notificationDetails,
        payload: _payload,
      );

      _notificationMessageDisplayed = message;
    } catch (error) {
      AliceUtils.log(error.toString());
    } finally {
      _isNotificationProcessing = false;
    }
  }
}
