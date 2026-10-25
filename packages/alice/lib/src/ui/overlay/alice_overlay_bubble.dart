import 'dart:math' as math;

import 'package:alice/src/model/alice_http_call.dart';
import 'package:alice/src/services/storage/alice_storage.dart';
import 'package:alice/src/ui/common/theme.dart';
import 'package:flutter/material.dart';

/// Draggable floating overlay bubble displaying live Alice statistics.
/// Styled to match the Alice HTTP Inspector design language.
/// Automatically stays hidden until at least one HTTP call is recorded.
class AliceOverlayBubble extends StatefulWidget {
  final Stream<List<AliceHttpCall>> callsStream;
  final AliceStorage storage;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const AliceOverlayBubble({
    super.key,
    required this.callsStream,
    required this.storage,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  State<AliceOverlayBubble> createState() => _AliceOverlayBubbleState();
}

class _AliceOverlayBubbleState extends State<AliceOverlayBubble> {
  Offset _offset = const Offset(16, 96);
  bool _isInitialized = false;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;
    final padding = mediaQuery.padding;

    // Constrain position within screen safe area bounds.
    if (!_isInitialized) {
      _offset = Offset(screenSize.width - 200, padding.top + 60);
      _isInitialized = true;
    } else {
      final double minX = padding.left + 8;
      final double maxX = math.max(
        minX,
        screenSize.width - padding.right - 200,
      );
      final double minY = padding.top + 8;
      final double maxY = math.max(
        minY,
        screenSize.height - padding.bottom - 56,
      );

      _offset = Offset(
        _offset.dx.clamp(minX, maxX),
        _offset.dy.clamp(minY, maxY),
      );
    }

    return Positioned(
      left: _offset.dx,
      top: _offset.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _offset += details.delta;
          });
        },
        child: StreamBuilder<List<AliceHttpCall>>(
          stream: widget.callsStream,
          builder: (context, snapshot) {
            final stats = widget.storage.getStats();

            // Only show the bubble when at least one call has been recorded.
            if (stats.total == 0) {
              return const SizedBox.shrink();
            }

            final hasSuccesses = stats.successes > 0;
            final hasErrors = stats.errors > 0;
            final isLoading = stats.loading > 0;

            return Material(
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: widget.onTap,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Alice brand emblem
                        Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: AliceAppTheme.lightRed,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.search,
                            size: 12,
                            color: AliceAppTheme.white,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Alice',
                          style: TextStyle(
                            color: AliceAppTheme.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 14,
                          color: Colors.white24,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        Text(
                          '${stats.total}',
                          style: const TextStyle(
                            color: AliceAppTheme.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (isLoading) ...[
                          const SizedBox(width: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(
                                width: 10,
                                height: 10,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AliceAppTheme.orange,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '${stats.loading}',
                                style: const TextStyle(
                                  color: AliceAppTheme.orange,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (hasSuccesses) ...[
                          const SizedBox(width: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check,
                                size: 13,
                                color: AliceAppTheme.green,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${stats.successes}',
                                style: const TextStyle(
                                  color: AliceAppTheme.green,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (hasErrors) ...[
                          const SizedBox(width: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                size: 13,
                                color: AliceAppTheme.red,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${stats.errors}',
                                style: const TextStyle(
                                  color: AliceAppTheme.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
