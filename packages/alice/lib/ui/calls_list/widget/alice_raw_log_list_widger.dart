import 'package:alice/model/alice_translation.dart';
import 'package:alice/ui/calls_list/widget/alice_empty_logs_widget.dart';
import 'package:alice/ui/calls_list/widget/alice_error_logs_widget.dart';
import 'package:alice/ui/common/alice_context_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Widget which displays raw logs list (logs collected with ADB).
class AliceRawLogListWidget extends StatelessWidget {
  const AliceRawLogListWidget({
    required this.scrollController,
    required this.getRawLogs,
    super.key,
  });

  final ScrollController scrollController;
  final Future<String>? getRawLogs;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: getRawLogs,
      builder: (context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.none ||
            snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const AliceErrorLogsWidget();
        }

        final logs = snapshot.data ?? '';
        if (logs.isEmpty) {
          return const AliceEmptyLogsWidget();
        }

        return Scrollbar(
          thickness: 8,
          controller: scrollController,
          child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: InkWell(
                onLongPress:
                    () => _copyToClipboard(
                      context: context,
                      text: snapshot.data ?? '',
                    ),
                child: Text(
                  snapshot.data ?? '',
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Copies provided text to clipboard and displays info about it.
  Future<void> _copyToClipboard({
    required BuildContext context,
    required String text,
  }) async {
    await Clipboard.setData(ClipboardData(text: text));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.i18n(AliceTranslationKey.logsCopied))),
      );
    }
  }
}
