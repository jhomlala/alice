import 'dart:math';
import 'package:alice/core/alice_core.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/ui/common/theme.dart';
import 'package:material_ui/material_ui.dart';

class TimelineScreen extends StatefulWidget {
  final AliceCore aliceCore;
  final void Function(AliceHttpCall) onListItemPressed;

  const TimelineScreen({
    super.key,
    required this.aliceCore,
    required this.onListItemPressed,
  });

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return StreamBuilder<List<AliceHttpCall>>(
      stream: widget.aliceCore.callsStream,
      builder: (context, AsyncSnapshot<List<AliceHttpCall>> snapshot) {
        final List<AliceHttpCall> calls = [...?snapshot.data];

        if (calls.isEmpty) {
          return const Center(child: Text("No calls"));
        }

        DateTime minTime = calls.first.createdTime;
        DateTime maxTime =
            calls.first.response?.time ?? calls.first.createdTime;

        for (final call in calls) {
          if (call.createdTime.isBefore(minTime)) {
            minTime = call.createdTime;
          }
          final callEndTime = call.response?.time ?? call.createdTime;
          if (callEndTime.isAfter(maxTime)) {
            maxTime = callEndTime;
          }
        }

        int totalDurationMs = maxTime.difference(minTime).inMilliseconds;
        if (totalDurationMs == 0) {
          totalDurationMs = 1;
        }

        const double pixelsPerMs = 0.5;
        final double drawingWidth = max(
          MediaQuery.of(context).size.width,
          totalDurationMs * pixelsPerMs + 32.0,
        );
        final double drawingHeight = calls.length * 40.0 + 40.0;

        return InteractiveViewer(
          constrained: false,
          minScale: 0.1,
          maxScale: 5.0,
          child: SizedBox(
            width: drawingWidth,
            height: drawingHeight,
            child: Stack(
              children: () {
                final List<Widget> children = [];

                // Determine grid interval based on total duration
                int gridIntervalMs = 1000;
                if (totalDurationMs < 500) {
                  gridIntervalMs = 100;
                } else if (totalDurationMs < 2000) {
                  gridIntervalMs = 250;
                } else if (totalDurationMs > 10000) {
                  gridIntervalMs = 5000;
                }

                // Add vertical grid lines
                for (int i = 0; i <= totalDurationMs; i += gridIntervalMs) {
                  final double left = i * pixelsPerMs + 16.0;
                  children.add(
                    Positioned(
                      left: left,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: 1,
                        color: AliceAppTheme.grey.withOpacity(0.3),
                      ),
                    ),
                  );
                  children.add(
                    Positioned(
                      left: left + 2.0,
                      top: 2.0,
                      child: Text(
                        '${i}ms',
                        style: const TextStyle(
                          color: AliceAppTheme.grey,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  );
                }

                // Add call bars
                for (int index = 0; index < calls.length; index++) {
                  final call = calls[index];
                  final left =
                      call.createdTime.difference(minTime).inMilliseconds *
                      pixelsPerMs;
                  final callEndTime = call.response?.time ?? DateTime.now();
                  final int durationMs =
                      callEndTime.difference(call.createdTime).inMilliseconds;
                  double width = durationMs * pixelsPerMs;
                  if (width < 5.0) {
                    width = 5.0;
                  }
                  final top = index * 40.0 + 20.0;

                  Color barColor = AliceAppTheme.orange; // pending
                  if (!call.loading) {
                    final status = call.response?.status;
                    if (status != null && status >= 200 && status < 400) {
                      barColor = AliceAppTheme.green;
                    } else {
                      barColor = AliceAppTheme.lightRed;
                    }
                  }

                  children.add(
                    Positioned(
                      left: left + 16.0,
                      top: top,
                      width: width,
                      height: 30.0,
                      child: GestureDetector(
                        onTap: () => widget.onListItemPressed(call),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          decoration: BoxDecoration(
                            color: barColor,
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '${call.endpoint} (${durationMs}ms)',
                            style: const TextStyle(
                              color: AliceAppTheme.white,
                              fontSize: 12.0,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return children;
              }(),
            ),
          ),
        );
      },
    );
  }
}
