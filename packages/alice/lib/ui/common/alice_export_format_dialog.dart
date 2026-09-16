import 'package:alice/model/alice_export_format.dart';
import 'package:alice/model/alice_translation.dart';
import 'package:alice/ui/common/alice_context_ext.dart';
import 'package:alice/ui/common/alice_theme.dart';
import 'package:material_ui/material_ui.dart';

class AliceExportFormatDialog extends StatelessWidget {
  const AliceExportFormatDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.i18n(AliceTranslationKey.exportFormatDialogTitle)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            context.i18n(AliceTranslationKey.exportFormatCancel),
            style: const TextStyle(color: AliceTheme.grey),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(AliceExportFormat.txt),
          child: Text(
            context.i18n(AliceTranslationKey.exportFormatTxt),
            style: const TextStyle(color: AliceTheme.lightRed),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(AliceExportFormat.har),
          child: Text(
            context.i18n(AliceTranslationKey.exportFormatHar),
            style: const TextStyle(color: AliceTheme.lightRed),
          ),
        ),
      ],
    );
  }

  static Future<AliceExportFormat?> show(BuildContext context) {
    return showDialog<AliceExportFormat>(
      context: context,
      builder:
          (_) => Theme(
            data: AliceTheme.getTheme(),
            child: const AliceExportFormatDialog(),
          ),
    );
  }
}
