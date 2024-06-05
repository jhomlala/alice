import 'package:alice/utils/alice_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class AliceTheme {
  static bool _isDarkMode() {
    final brightness =
        SchedulerBinding.instance.platformDispatcher.platformBrightness;
    final isDarkMode = brightness == Brightness.dark;
    return isDarkMode;
  }

  static ColorScheme getColorScheme() {
    if (_isDarkMode()) {
      return ColorScheme.dark(primary: AliceConstants.lightRed);
    } else {
      return ColorScheme.light(primary: AliceConstants.lightRed);
    }
  }

  static Color getTextColor(BuildContext context, DiagnosticLevel level) {
    final theme = Theme.of(context);
    switch (level) {
      case DiagnosticLevel.hidden:
        return Colors.grey;
      case DiagnosticLevel.fine:
        return Colors.grey;
      case DiagnosticLevel.debug:
        return Theme.of(context).colorScheme.onSurface;
      case DiagnosticLevel.info:
        return Theme.of(context).colorScheme.onSurface;
      case DiagnosticLevel.warning:
        return Colors.orange;
      case DiagnosticLevel.hint:
        return Colors.grey;
      case DiagnosticLevel.summary:
        return Theme.of(context).colorScheme.onSurface;
      case DiagnosticLevel.error:
        return theme.colorScheme.error;
      case DiagnosticLevel.off:
        return Colors.purple;
    }
  }
}
