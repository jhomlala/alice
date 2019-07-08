import 'package:alice/model/alice_http_call.dart';
import 'package:flutter/material.dart';

import 'alice_base_call_details_widget.dart';

class AliceCallErrorWidget extends AliceBaseCallDetailsWidget {
  final AliceHttpCall call;

  AliceCallErrorWidget(this.call);

  @override
  Widget build(BuildContext context) {
    if (call.error != null) {
      List<Widget> rows = List();
      var error = call.error.error;
      var errorText = "Error is empty";
      if (error != null) {
        errorText = error.toString();
      }
      rows.add(getListRow("Error:", errorText));

      return Container(
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
          child: ListView(children: rows));
    } else {
      return Center(child: Text("Nothing to display here"));
    }
  }
}
