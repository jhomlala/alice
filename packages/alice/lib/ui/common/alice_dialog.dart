import 'package:alice/model/alice_translation.dart';
import 'package:alice/ui/common/alice_context_ext.dart';
import 'package:alice/ui/common/alice_theme.dart';
import 'package:flutter/material.dart';

/// General dialogs used in Alice.
class AliceGeneralDialog {
  /// Helper method used to open alarm with given title and description.
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String description,
    String? firstButtonTitle,
    String? secondButtonTitle,
    Function? firstButtonAction,
    Function? secondButtonAction,
  }) => showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return Theme(
        data: AliceTheme.getTheme(),
        child: AlertDialog(
          title: Text(title),
          content: Text(description),
          actions: [
            TextButton(
              onPressed: () {
                // ignore: avoid_dynamic_calls
                firstButtonAction?.call();
                Navigator.of(context).pop();
              },
              child: Text(
                firstButtonTitle ?? context.i18n(AliceTranslationKey.accept),
              ),
            ),
            if (secondButtonTitle != null)
              TextButton(
                onPressed: () {
                  // ignore: avoid_dynamic_calls
                  secondButtonAction?.call();
                  Navigator.of(context).pop();
                },
                child: Text(secondButtonTitle),
              ),
          ],
        ),
      );
    },
  );
}
