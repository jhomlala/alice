import 'package:alice/core/alice_logger.dart';
import 'package:alice/ui/calls_list/widget/alice_empty_logs_widget.dart';
import 'package:alice/ui/calls_list/widget/alice_log_list_widget.dart';
import 'package:alice/ui/calls_list/widget/alice_raw_log_list_widger.dart';
import 'package:flutter/material.dart';

/// Screen hosted in calls list which displays logs list.
class AliceLogsScreen extends StatelessWidget {
  const AliceLogsScreen({
    super.key,
    required this.scrollController,
    this.aliceLogger,
    this.isAndroidRawLogsEnabled = false,
  });

  final ScrollController scrollController;
  final AliceLogger? aliceLogger;
  final bool isAndroidRawLogsEnabled;

  @override
  Widget build(BuildContext context) =>
      aliceLogger != null
          ? isAndroidRawLogsEnabled
              ? AliceRawLogListWidget(
                scrollController: scrollController,
                getRawLogs: aliceLogger?.getAndroidRawLogs(),
              )
              : AliceLogListWidget(
                logsStream: aliceLogger?.logsStream,
                scrollController: scrollController,
              )
          : const AliceEmptyLogsWidget();
}
