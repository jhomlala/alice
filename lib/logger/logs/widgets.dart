/// Copyright (c) 2020 Jonas Wanke
import 'dart:convert';
import 'dart:ui';

import 'package:alice/logger/logs/level_selector.dart';
import 'package:alice/utils/alice_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'data.dart';

class LogsDebugHelper extends StatefulWidget {
  const LogsDebugHelper(
    this.logs, {
    this.scrollController,
  });

  final LogCollection logs;
  final ScrollController? scrollController;

  @override
  State<LogsDebugHelper> createState() => _LogsDebugHelperState();
}

class _LogsDebugHelperState extends State<LogsDebugHelper> {
  var _minLevel = DiagnosticLevel.debug;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ValueListenableBuilder<List<Log>>(
            valueListenable: widget.logs.listenable,
            builder: (context, logs, _) {
              if (logs.isEmpty) {
                return Center(
                  child: Text(
                    'No logs available.',
                    style: textTheme.caption!.copyWith(
                      color: AliceConstants.orange,
                    ),
                  ),
                );
              }

              final filteredLogs = logs
                  .where((it) => it.level.index >= _minLevel.index)
                  .toList();
              return ListView.builder(
                controller: widget.scrollController,
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: filteredLogs.length,
                itemBuilder: (context, i) => LogEntryWidget(filteredLogs[i]),
              );
            },
          ),
        ),
      ],
    );
  }
}

class LogEntryWidget extends StatelessWidget {
  LogEntryWidget(this.log) : super(key: ValueKey(log));

  final Log log;

  @override
  Widget build(BuildContext context) {
    // We don't show the date to save space.
    final textTheme = Theme.of(context).textTheme;

    final rawTimestamp = log.timestamp.toString();
    final timeStartIndex = rawTimestamp.indexOf(' ') + 1;
    final formattedTimestamp = rawTimestamp.substring(timeStartIndex);

    final color = _getTextColor(context);
    final content = Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: formattedTimestamp,
            style: textTheme.caption!.copyWith(
              color: color.withOpacity(0.6),
              fontFeatures: [FontFeature.tabularFigures()],
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
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              DiagnosticLevelSelector.levelToIcon(log.level),
              size: 16,
              color: color,
            ),
            SizedBox(width: 4),
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
    final string = _stringify(object);
    if (string == null) return [];

    return [
      TextSpan(
        text: '\n$title:${addLineBreakAfterTitle ? '\n' : ' '}',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      TextSpan(text: string),
    ];
  }

  Color _getTextColor(BuildContext context) {
    final theme = Theme.of(context);
    switch (log.level) {
      case DiagnosticLevel.hidden:
        return Colors.grey;
      case DiagnosticLevel.fine:
        return Colors.grey;
      case DiagnosticLevel.debug:
        return Colors.black;
      case DiagnosticLevel.info:
        return Colors.black;
      case DiagnosticLevel.warning:
        return Colors.orange;
      case DiagnosticLevel.hint:
        return Colors.grey;
      case DiagnosticLevel.summary:
        return Colors.black;
      case DiagnosticLevel.error:
        return theme.errorColor;
      case DiagnosticLevel.off:
        return Colors.purple;
    }
  }

  Future<void> _copyToClipboard(BuildContext context) async {
    final error = _stringify(log.error);
    final stackTrace = _stringify(log.stackTrace);
    final text = [
      '${log.timestamp}: ${log.message}',
      if (error != null) 'Error: $error',
      if (stackTrace != null) 'Stack Trace: $stackTrace',
    ].join('\n');
    await Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Copied!')));
  }

  String? _stringify(dynamic object) {
    if (object == null) return null;
    if (object is String) return object.trim();
    if (object is DiagnosticsNode) return object.toStringDeep();

    try {
      object.toJson();
      // It supports `toJson()`.

      dynamic toEncodable(dynamic object) {
        try {
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
