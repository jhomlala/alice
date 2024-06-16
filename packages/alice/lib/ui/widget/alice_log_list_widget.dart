import 'dart:convert';

import 'package:alice/model/alice_log.dart';
import 'package:alice/utils/alice_scroll_behavior.dart';
import 'package:alice/utils/alice_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AliceLogListWidget extends StatefulWidget {
  const AliceLogListWidget({
    required this.  logsListenable,
    required this.scrollController,
    required this.emptyWidget,
    super.key,
  });

  final ValueListenable<List<AliceLog>> logsListenable;
  final ScrollController? scrollController;
  final Widget emptyWidget;

  @override
  State<AliceLogListWidget> createState() => _AliceLogListWidgetState();
}

class _AliceLogListWidgetState extends State<AliceLogListWidget> {
  final DiagnosticLevel _minLevel = DiagnosticLevel.debug;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<AliceLog>>(
      valueListenable: widget.logsListenable,
      builder: (_, List<AliceLog> logs, __) {
        if (logs.isEmpty) {
          return widget.emptyWidget;
        }

        final List<AliceLog> filteredLogs = [
          for (final AliceLog log in logs)
            if (log.level.index >= _minLevel.index) log
        ];

        return ScrollConfiguration(
          behavior: AliceScrollBehavior(),
          child: ListView.builder(
            controller: widget.scrollController,
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: filteredLogs.length,
            itemBuilder: (context, i) => AliceLogEntryWidget(filteredLogs[i]),
          ),
        );
      },
    );
  }
}

class AliceLogEntryWidget extends StatelessWidget {
  AliceLogEntryWidget(this.log) : super(key: ValueKey(log));

  final AliceLog log;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    final String rawTimestamp = log.timestamp.toString();
    final int timeStartIndex = rawTimestamp.indexOf(' ') + 1;
    final String formattedTimestamp = rawTimestamp.substring(timeStartIndex);

    final Color color = _getTextColor(context);
    final Text content = Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: formattedTimestamp,
            style: textTheme.bodySmall?.copyWith(
              color: color.withOpacity(0.6),
              fontFeatures: [const FontFeature.tabularFigures()],
            ),
          ),
          TextSpan(text: ' ${log.message}'),
          ..._toText(context, 'Error', log.error),
          ..._toText(
            context,
            'Stack Trace',
            log.stackTrace,
            addLineBreakAfterTitle: true,
          ),
        ],
        style: TextStyle(color: color),
      ),
    );

    return InkWell(
      onLongPress: () => _copyToClipboard(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              _getLogIcon(log.level),
              size: 16,
              color: color,
            ),
            const SizedBox(width: 4),
            Expanded(child: content),
          ],
        ),
      ),
    );
  }

  List<InlineSpan> _toText(
    BuildContext context,
    String title,
    dynamic object, {
    bool addLineBreakAfterTitle = false,
  }) {
    final String? string = _stringify(object);
    if (string == null) return [];

    return [
      TextSpan(
        text: '\n$title:${addLineBreakAfterTitle ? '\n' : ' '}',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      TextSpan(text: string),
    ];
  }

  Color _getTextColor(BuildContext context) {
    return AliceTheme.getTextColor(context, log.level);
  }

  IconData _getLogIcon(DiagnosticLevel level) => switch (level) {
        DiagnosticLevel.hidden => Icons.all_inclusive_outlined,
        DiagnosticLevel.fine => Icons.bubble_chart_outlined,
        DiagnosticLevel.debug => Icons.bug_report_outlined,
        DiagnosticLevel.info => Icons.info_outline,
        DiagnosticLevel.warning => Icons.warning_outlined,
        DiagnosticLevel.hint => Icons.privacy_tip_outlined,
        DiagnosticLevel.summary => Icons.subject,
        DiagnosticLevel.error => Icons.error_outlined,
        DiagnosticLevel.off => Icons.not_interested_outlined,
      };

  Future<void> _copyToClipboard(BuildContext context) async {
    final String? error = _stringify(log.error);
    final String? stackTrace = _stringify(log.stackTrace);
    final StringBuffer text = StringBuffer()
      ..writeAll([
        '${log.timestamp}: ${log.message}\n',
        if (error != null) 'Error: $error\n',
        if (stackTrace != null) 'Stack Trace: $stackTrace\n',
      ]);

    await Clipboard.setData(ClipboardData(text: text.toString()));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Copied!')),
      );
    }
  }

  String? _stringify(dynamic object) {
    if (object == null) return null;
    if (object is String) return object.trim();
    if (object is DiagnosticsNode) return object.toStringDeep();

    try {
      // ignore: avoid_dynamic_calls
      object.toJson();
      // It supports `toJson()`.

      dynamic toEncodable(dynamic object) {
        try {
          // ignore: avoid_dynamic_calls
          return object.toJson();
        } catch (_) {
          try {
            return '$object';
          } catch (_) {
            return describeIdentity(object);
          }
        }
      }

      return JsonEncoder.withIndent('  ', toEncodable).convert(object);
    } catch (_) {}

    try {
      return '$object'.trim();
    } catch (_) {
      return describeIdentity(object);
    }
  }
}
