import 'package:alice/src/core/alice_core.dart';
import 'package:alice/src/ui/overlay/alice_overlay_bubble.dart';
import 'package:flutter/widgets.dart';

/// Service managing the lifecycle and attachment of the [AliceOverlayBubble].
class AliceOverlayService {
  OverlayEntry? _overlayEntry;

  /// Returns true if the overlay is currently inserted into the tree.
  bool get isInserted => _overlayEntry != null;

  /// Ensures the overlay entry is inserted into [overlayState].
  void ensureInserted({
    required OverlayState? overlayState,
    required AliceCore core,
  }) {
    if (_overlayEntry != null || overlayState == null) {
      return;
    }

    _overlayEntry = OverlayEntry(
      builder: (context) {
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

  /// Removes the overlay entry from the overlay if attached.
  void remove() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
