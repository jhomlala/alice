import 'package:alice/src/model/translation.dart';
import 'package:alice/src/ui/common/context_ext.dart';
import 'package:alice/src/ui/common/page.dart';
import 'package:material_ui/material_ui.dart';

/// Helper method to show dialogs safely in Alice.
/// Uses [showGeneralDialog] wrapped in [BasePage] so that [MaterialLocalizations]
/// and [Directionality] are always available, regardless of whether the host app
/// uses package:flutter/material.dart or package:material_ui.
Future<T?> showAliceDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  String? barrierLabel,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
}) {
  return showGeneralDialog<T>(
    context: context,
    useRootNavigator: useRootNavigator,
    barrierDismissible: barrierDismissible,
    barrierLabel: barrierLabel ?? context.i18n(TranslationKey.dismiss),
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 150),
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      return BasePage(child: builder(dialogContext));
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child,
      );
    },
    routeSettings: routeSettings,
  );
}

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
  }) => showAliceDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
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
              firstButtonTitle ?? context.i18n(TranslationKey.accept),
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
      );
    },
  );
}
