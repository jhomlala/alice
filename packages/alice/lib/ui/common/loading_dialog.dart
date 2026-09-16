import 'package:alice/model/translation.dart';
import 'package:alice/ui/common/context_ext.dart';
import 'package:alice/ui/common/theme.dart';
import 'package:material_ui/material_ui.dart';

class LoadingDialog extends StatelessWidget {
  const LoadingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AliceAppTheme.getTheme(),
      child: AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(color: AliceAppTheme.lightRed),
            const SizedBox(width: 16),
            Expanded(
              child: Text(context.i18n(TranslationKey.saveLoading)),
            ),
          ],
        ),
      ),
    );
  }

  static void show(BuildContext context) {
    final navigator = Navigator.maybeOf(context);
    if (navigator == null) {
      return;
    }
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const LoadingDialog(),
    );
  }

  static void hide(BuildContext context) {
    final navigator = Navigator.maybeOf(context);
    if (navigator == null) {
      return;
    }
    navigator.pop();
  }
}
