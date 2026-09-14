import 'package:alice/core/alice_core.dart';
import 'package:alice/ui/common/alice_theme.dart';
import 'package:material_ui/material_ui.dart';

/// Common page widget which is used across Alice pages.
class AlicePage extends StatelessWidget {
  const AlicePage({super.key, required this.core, required this.child});

  final AliceCore core;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    Widget content = Theme(data: AliceTheme.getTheme(), child: child);

    if (Localizations.of<MaterialLocalizations>(context, MaterialLocalizations) == null) {
      content = Localizations(
        locale: const Locale('en', 'US'),
        delegates: const [
          DefaultMaterialLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
        ],
        child: content,
      );
    }

    return Directionality(
      textDirection: core.configuration.directionality ??
          Directionality.maybeOf(context) ??
          TextDirection.ltr,
      child: content,
    );
  }
}
