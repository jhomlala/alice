import 'dart:math' as math;

import 'package:alice/src/model/alice_http_call.dart';
import 'package:alice/src/services/storage/alice_storage.dart';
import 'package:flutter/material.dart';

/// Draggable floating bubble displaying live Alice statistics.
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
      _offset = Offset(screenSize.width - 150, padding.top + 50);
      _isInitialized = true;
    } else {
      final double minX = padding.left + 8;
      final double maxX = math.max(
        minX,
        screenSize.width - padding.right - 140,
      );
      final double minY = padding.top + 8;
      final double maxY = math.max(
        minY,
        screenSize.height - padding.bottom - 48,
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
            final hasErrors = stats.errors > 0;
            final isLoading = stats.loading > 0;

            final statusColor = hasErrors
                ? Colors.red
                : (isLoading ? Colors.amber : Colors.green);

            return Material(
              color: Colors.transparent,
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: hasErrors ? Colors.red.shade400 : Colors.white24,
                  width: 1.5,
                ),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: widget.onTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${stats.total}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (hasErrors) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.shade700,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${stats.errors}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
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
