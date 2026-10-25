import 'dart:io' show Platform;

import 'package:alice/alice.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Local OS notification adapter using `flutter_local_notifications`.
class AliceLocalNotification implements AliceNotificationAdapter {
  static const String _payload = 'Alice';
  static const String _channel = 'Alice';

  final String notificationIcon;
  final String? notificationLargeIcon;

  /// Notification plugin instance
  FlutterLocalNotificationsPlugin? _flutterLocalNotificationsPlugin;

  /// Notification configuration details.
  NotificationDetails? _notificationDetails;

  /// Callback used to open inspector on notification click.
  VoidCallback? _openInspectorCallback;

  /// Currently displayed notification message
  String? _notificationMessageDisplayed;

  /// Flag indicating whether notification is processing
  bool _isNotificationProcessing = false;

  AliceLocalNotification({
    this.notificationIcon = '@mipmap/ic_launcher',
    this.notificationLargeIcon,
  });

  @override
  void configure({required VoidCallback openInspectorCallback}) {
    _openInspectorCallback = openInspectorCallback;
    _notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        _channel,
        _channel,
        channelDescription: _channel,
        enableVibration: false,
        playSound: false,
        largeIcon: notificationLargeIcon != null
            ? DrawableResourceAndroidBitmap(notificationLargeIcon!)
            : null,
      ),
      iOS: const DarwinNotificationDetails(
        presentSound: false,
        presentBanner: false,
        presentList: true,
      ),
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
      settings: initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );
    _requestNotificationPermissions();
  }

  Future<void> _requestNotificationPermissions() async {
    if (Platform.isIOS || Platform.isMacOS) {
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
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin
              ?.resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      await androidImplementation?.requestNotificationsPermission();
    }
  }

  Future<void> _onDidReceiveNotificationResponse(
    NotificationResponse response,
  ) async {
    _openInspectorCallback?.call();
  }

  String _formatStats(AliceStats stats) {
    return <String>[
      if (stats.loading > 0) 'Loading: ${stats.loading}',
      if (stats.successes > 0) 'Success: ${stats.successes}',
      if (stats.redirects > 0) 'Redirect: ${stats.redirects}',
      if (stats.errors > 0) 'Error: ${stats.errors}',
    ].join(' | ');
  }

  @override
  Future<void> showStatsNotification({
    required BuildContext context,
    required AliceStats stats,
  }) async {
    try {
      if (_isNotificationProcessing) {
        return;
      }
      final message = _formatStats(stats);
      if (message == _notificationMessageDisplayed) {
        return;
      }

      _isNotificationProcessing = true;

      await _flutterLocalNotificationsPlugin?.show(
        id: 0,
        title: 'Alice (total ${stats.total} HTTP calls)',
        body: message,
        notificationDetails: _notificationDetails,
        payload: _payload,
      );

      _notificationMessageDisplayed = message;
    } catch (_) {
    } finally {
      _isNotificationProcessing = false;
    }
  }

  @override
  void dispose() {}
}
