import 'dart:async';

import 'package:alice/src/services/storage/alice_storage.dart';
import 'package:flutter/widgets.dart';

/// Interface for external notification adapters (e.g. `alice_notification`).
abstract interface class AliceNotificationAdapter {
  /// Configures the notification adapter and registers [openInspectorCallback].
  void configure({required VoidCallback openInspectorCallback});

  /// Displays or updates the notification with the latest [stats].
  FutureOr<void> showStatsNotification({
    required BuildContext context,
    required AliceStats stats,
  });

  /// Disposes any resources held by the adapter.
  void dispose() {}
}
