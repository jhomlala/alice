import 'package:alice/src/core/alice_core.dart';
import 'package:alice/src/ui/overlay/alice_overlay_bubble.dart';
import 'package:flutter/widgets.dart';

/// Service managing the lifecycle and attachment of the [AliceOverlayBubble].
class AliceOverlayService {
  OverlayEntry? _overlayEntry;

  /// Returns true if the overlay is currently inserted into the tree.
  bool get isInserted => _overlayEntry != null && _overlayEntry!.mounted;

  /// Ensures the overlay entry is inserted into [overlayState].
  void ensureInserted({
    required OverlayState? overlayState,
    required AliceCore core,
  }) {
    if (overlayState == null) {
      return;
    }

    if (_overlayEntry != null) {
      if (_overlayEntry!.mounted) {
        return;
      }
      _overlayEntry = null;
    }

    _overlayEntry = OverlayEntry(
      builder: (context) {
        if (core.isInspectorOpened) {
          return const SizedBox.shrink();
        }
        return AliceOverlayBubble(
          callsStream: core.callsStream,
          storage: core.configuration.aliceStorage,
          onTap: () {
            if (!core.isInspectorOpened) {
              core.navigateToCallListScreen();
            }
          },
          onDismiss: remove,
        );
      },
    );

    overlayState.insert(_overlayEntry!);
  }

  /// Rebuilds the overlay entry if inserted (e.g. when inspector opens/closes).
  void markNeedsBuild() {
    _overlayEntry?.markNeedsBuild();
  }

  /// Removes the overlay entry from the overlay if attached.
  void remove() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
