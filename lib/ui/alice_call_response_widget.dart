import 'package:alice/model/alice_http_call.dart';
import 'package:flutter/material.dart';

import 'alice_base_call_details_widget.dart';

class AliceCallResponseWidget extends AliceBaseCallDetailsWidget {
  final AliceHttpCall call;

  AliceCallResponseWidget(this.call);

  @override
  Widget build(BuildContext context) {
    List<Widget> rows = List();
    if (!call.loading) {
      rows.add(getListRow("Received:", call.response.time.toString()));
      rows.add(getListRow("Bytes received:", formatBytes(call.response.size)));

      var status = call.response.status;
      var statusText = "$status";
      if (status == -1) {
        statusText = "Error";
      }

      rows.add(getListRow("Status:", statusText));
      var headers = call.response.headers;
      var bodyContent = formatBody(call.response.body, getContentType(headers));
      rows.add(getListRow("Body:", bodyContent));
      var headersContent = "Headers are empty";
      if (headers != null && headers.length > 0) {
        headersContent = "";
      }
      rows.add(getListRow("Headers: ", headersContent));
      if (call.response.headers != null) {
        call.response.headers.forEach((header, value) {
          rows.add(getListRow("   • $header:", value.toString()));
        });
      }
      return Container(
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
          child: ListView(children: rows));
    } else {
      return Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          new CircularProgressIndicator(),
          Text("Awaiting response...")
        ],
      ));
    }
  }
}
