import 'package:alice/alice.dart';
import 'package:flutter/widgets.dart';

/// Stub implementation of [AliceNotificationAdapter] for Web and unsupported platforms.
class AliceLocalNotification implements AliceNotificationAdapter {
  final String notificationIcon;
  final String? notificationLargeIcon;

  AliceLocalNotification({
    this.notificationIcon = '@mipmap/ic_launcher',
    this.notificationLargeIcon,
  });

  @override
  void configure({required VoidCallback openInspectorCallback}) {}

  @override
  Future<void> showStatsNotification({
    required BuildContext context,
    required AliceStats stats,
  }) async {}

  @override
  void dispose() {}
}
