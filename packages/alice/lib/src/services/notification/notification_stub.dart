import 'package:alice/src/services/storage/alice_storage.dart';
import 'package:cupertino_ui/cupertino_ui.dart';

/// Stub implementation of AliceNotificationService for platforms where
/// local notifications are not supported or cause compatibility issues (e.g. Wasm).
class AliceNotificationService {
  /// No-op configuration for stub.
  void configure({
    required String notificationIcon,
    String? notificationLargeIcon,
    required void Function() openInspectorCallback,
  }) {
    // No-op for web/wasm
  }

  /// No-op show stats notification for stub.
  Future<void> showStatsNotification({
    required BuildContext context,
    required AliceStats stats,
  }) async {
    // No-op for web/wasm
  }
}
