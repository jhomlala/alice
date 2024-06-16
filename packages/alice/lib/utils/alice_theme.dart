import 'package:alice/utils/alice_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class AliceTheme {
  static bool get _isDarkMode =>
      SchedulerBinding.instance.platformDispatcher.platformBrightness ==
      Brightness.dark;

  static ColorScheme getColorScheme() => _isDarkMode
      ? ColorScheme.dark(primary: AliceConstants.lightRed)
      : ColorScheme.light(primary: AliceConstants.lightRed);

  static Color getTextColor(BuildContext context, DiagnosticLevel level) =>
      switch (level) {
        DiagnosticLevel.hidden => Colors.grey,
        DiagnosticLevel.fine => Colors.grey,
        DiagnosticLevel.debug => Theme.of(context).colorScheme.onSurface,
        DiagnosticLevel.info => Theme.of(context).colorScheme.onSurface,
        DiagnosticLevel.warning => Colors.orange,
        DiagnosticLevel.hint => Colors.grey,
        DiagnosticLevel.summary => Theme.of(context).colorScheme.onSurface,
        DiagnosticLevel.error => Theme.of(context).colorScheme.error,
        DiagnosticLevel.off => Colors.purple,
      };
}
