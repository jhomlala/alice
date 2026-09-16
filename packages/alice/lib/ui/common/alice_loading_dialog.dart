import 'package:alice/model/alice_translation.dart';
import 'package:alice/ui/common/alice_context_ext.dart';
import 'package:alice/ui/common/alice_theme.dart';
import 'package:material_ui/material_ui.dart';

class AliceLoadingDialog extends StatelessWidget {
  const AliceLoadingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AliceTheme.getTheme(),
      child: AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(color: AliceTheme.lightRed),
            const SizedBox(width: 16),
            Expanded(
              child: Text(context.i18n(AliceTranslationKey.saveLoading)),
            ),
          ],
        ),
      ),
    );
  }

  static void show(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AliceLoadingDialog(),
    );
  }

  static void hide(BuildContext context) {
    Navigator.of(context).pop();
  }
}
