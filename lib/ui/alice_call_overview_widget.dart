import 'package:alice/model/alice_http_call.dart';
import 'package:flutter/material.dart';

import 'alice_base_call_details_widget.dart';

class AliceCallOverviewWidget extends AliceBaseCallDetailsWidget {
  final AliceHttpCall call;

  AliceCallOverviewWidget(this.call);

  @override
  Widget build(BuildContext context) {
    List<Widget> rows = List();
    rows.add(getListRow("Method: ", call.method));
    rows.add(getListRow("Server: ", call.server));
    rows.add(getListRow("Endpoint: ", call.endpoint));
    rows.add(getListRow("Started:", call.request.time.toString()));
    rows.add(getListRow("Finished:", call.response.time.toString()));
    rows.add(getListRow("Duration:", formatDuration(call.duration)));
    rows.add(getListRow("Bytes sent:", formatBytes(call.request.size)));
    rows.add(getListRow("Bytes received:", formatBytes(call.response.size)));
    rows.add(getListRow("Client:", call.client));
    rows.add(getListRow("Secure:", call.secure.toString()));
    return Container(
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
        child: ListView(children: rows));
  }
}
