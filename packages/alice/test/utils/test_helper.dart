import 'package:material_ui/material_ui.dart';

class TestHelper {
  /// Wraps [child] in a [MaterialApp] with material localizations and [Scaffold]
  /// for widget testing.
  static Widget wrapWithMaterialApp(Widget child) => MaterialApp(
    localizationsDelegates: const [
      DefaultMaterialLocalizations.delegate,
      DefaultWidgetsLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en', 'US')],
    home: Scaffold(body: child),
  );
}
