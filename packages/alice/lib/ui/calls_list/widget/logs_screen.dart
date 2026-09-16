import 'package:alice/services/logger/alice_logger.dart';
import 'package:alice/ui/calls_list/widget/empty_logs_widget.dart';
import 'package:alice/ui/calls_list/widget/log_list_widget.dart';
import 'package:alice/ui/calls_list/widget/raw_log_list_widger.dart';
import 'package:material_ui/material_ui.dart';

/// Screen hosted in calls list which displays logs list.
class LogsScreen extends StatelessWidget {
  const LogsScreen({
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
              ? RawLogListWidget(
                scrollController: scrollController,
                getRawLogs: aliceLogger?.getAndroidRawLogs(),
              )
              : LogListWidget(
                logsStream: aliceLogger?.logsStream,
                scrollController: scrollController,
              )
          : const EmptyLogsWidget();
}
