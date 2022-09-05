/// Copyright (c) 2020 Jonas Wanke

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DiagnosticLevelSelector extends StatelessWidget {
  const DiagnosticLevelSelector({
    required this.value,
    required this.onSelected,
  });

  final DiagnosticLevel value;
  final ValueSetter<DiagnosticLevel> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<DiagnosticLevel>(
      initialValue: value,
      tooltip: 'Select the minimum diagnostics level to display',
      onSelected: onSelected,
      itemBuilder: (context) => [
        for (final level in DiagnosticLevel.values)
          PopupMenuItem(
            value: level,
            child: Text(describeEnum(level)),
          ),
      ],
      child: Icon(levelToIcon(value)),
    );
  }

  static IconData levelToIcon(DiagnosticLevel level) {
    switch (level) {
      case DiagnosticLevel.hidden:
        return Icons.all_inclusive_outlined;
      case DiagnosticLevel.fine:
        return Icons.bubble_chart_outlined;
      case DiagnosticLevel.debug:
        return Icons.bug_report_outlined;
      case DiagnosticLevel.info:
        return Icons.info_outline;
      case DiagnosticLevel.warning:
        return Icons.warning_outlined;
      case DiagnosticLevel.hint:
        return Icons.privacy_tip_outlined;
      case DiagnosticLevel.summary:
        return Icons.subject;
      case DiagnosticLevel.error:
        return Icons.error_outlined;
      case DiagnosticLevel.off:
        return Icons.not_interested_outlined;
    }
  }
}
