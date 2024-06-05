import 'package:alice/utils/alice_theme.dart';
import 'package:flutter/material.dart';

class AliceAlertHelper {
  ///Helper method used to open alarm with given title and description.
  static void showAlert(
    BuildContext context,
    String title,
    String description, {
    String firstButtonTitle = 'Accept',
    String? secondButtonTitle,
    Function? firstButtonAction,
    Function? secondButtonAction,
  }) {
    final actions = <Widget>[
      TextButton(
        onPressed: () {
          // ignore: avoid_dynamic_calls
          firstButtonAction?.call();
          Navigator.of(context).pop();
        },
        child: Text(firstButtonTitle),
      ),
    ];
    if (secondButtonTitle != null) {
      actions.add(
        TextButton(
          onPressed: () {
            // ignore: avoid_dynamic_calls
            secondButtonAction?.call();
            Navigator.of(context).pop();
          },
          child: Text(secondButtonTitle),
        ),
      );
    }
    showDialog<void>(
      context: context,
      builder: (BuildContext buildContext) {
        return Theme(
          data: ThemeData(
            colorScheme: AliceTheme.getColorScheme(),
          ),
          child: AlertDialog(
            title: Text(title),
            content: Text(description),
            actions: actions,
          ),
        );
      },
    );
  }
}
