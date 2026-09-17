import 'package:alice/model/translation.dart';
import 'package:alice/ui/common/context_ext.dart';
import 'package:alice/ui/common/theme.dart';
import 'package:material_ui/material_ui.dart';

/// Widget which renders empty text for calls list.
class ErrorLogsWidget extends StatelessWidget {
  const ErrorLogsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AliceAppTheme.red),
            const SizedBox(height: 6),
            Text(
              context.i18n(TranslationKey.logsItemError),
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
