import 'package:flutter/material.dart';

class AliceAlertHelper {
  static void showAlert(BuildContext context, String title, String description,
      {String firstButtonTitle = "Accept",
      String secondButtonTitle,
      Function firstButtonAction,
      Function secondButtonAction}) {

    List<Widget> actions = List();
    if (firstButtonTitle != null) {
      actions.add(FlatButton(
        child: Text(firstButtonTitle),
        onPressed: () {
          if (firstButtonAction != null) {
            firstButtonAction();
          }
          Navigator.of(context).pop();
        },
      ));
    }
    if (secondButtonTitle != null) {
      actions.add(FlatButton(
        child: Text(secondButtonTitle),
        onPressed: () {
          if (secondButtonAction != null) {
            secondButtonAction();
          }
          Navigator.of(context).pop();
        },
      ));
    }
    showDialog(
        context: context,
        builder: (BuildContext buildContext) {
          return AlertDialog(
              title: Text(title), content: Text(description), actions: actions);
        });
  }
}
