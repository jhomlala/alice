import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class AliceTheme {
  static const Color red = Color(0xffff3f34);
  static const Color lightRed = Color(0xffff5e57);
  static const Color green = Color(0xff05c46b);
  static const Color grey = Color(0xff808e9b);
  static const Color orange = Color(0xffffa801);
  static const Color white = Color(0xffffffff);

  static ThemeData getTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: AliceTheme._getColorScheme(),
      dividerColor: Colors.transparent,
      buttonTheme: const ButtonThemeData(
        buttonColor: lightRed,
        textTheme: ButtonTextTheme.primary,
      ),
    );
  }

  static bool get _isDarkMode =>
      SchedulerBinding.instance.platformDispatcher.platformBrightness ==
      Brightness.dark;

  static ColorScheme _getColorScheme() => _isDarkMode
      ? const ColorScheme.dark(primary: AliceTheme.lightRed)
      : const ColorScheme.light(primary: AliceTheme.lightRed);

  static Color getLogTextColor(BuildContext context, DiagnosticLevel level) =>
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
