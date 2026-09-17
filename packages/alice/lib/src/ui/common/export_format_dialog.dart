import 'package:alice/src/model/export_format.dart';
import 'package:alice/src/model/translation.dart';
import 'package:alice/src/ui/common/context_ext.dart';
import 'package:alice/src/ui/common/theme.dart';
import 'package:material_ui/material_ui.dart';

class ExportFormatDialog extends StatelessWidget {
  const ExportFormatDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.i18n(TranslationKey.exportFormatDialogTitle)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            context.i18n(TranslationKey.exportFormatCancel),
            style: const TextStyle(color: AliceAppTheme.grey),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(ExportFormat.txt),
          child: Text(
            context.i18n(TranslationKey.exportFormatTxt),
            style: const TextStyle(color: AliceAppTheme.lightRed),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(ExportFormat.har),
          child: Text(
            context.i18n(TranslationKey.exportFormatHar),
            style: const TextStyle(color: AliceAppTheme.lightRed),
          ),
        ),
      ],
    );
  }

  static Future<ExportFormat?> show(BuildContext context) {
    return showDialog<ExportFormat>(
      context: context,
      builder:
          (_) => Theme(
            data: AliceAppTheme.getTheme(),
            child: const ExportFormatDialog(),
          ),
    );
  }
}
