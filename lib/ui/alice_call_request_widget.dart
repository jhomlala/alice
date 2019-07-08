import 'package:alice/model/alice_http_call.dart';
import 'package:flutter/material.dart';

import 'alice_base_call_details_widget.dart';

class AliceCallRequestWidget extends AliceBaseCallDetailsWidget {
  final AliceHttpCall call;

  AliceCallRequestWidget(this.call);

  @override
  Widget build(BuildContext context) {
    List<Widget> rows = List();
    rows.add(getListRow("Started:", call.request.time.toString()));
    rows.add(getListRow("Bytes sent:", formatBytes(call.request.size)));
    rows.add(getListRow("Content type:", call.request.contentType));

    var body = call.request.body;
    var bodyContent = "Body is empty";
    if (body != null && body.length > 0) {
      bodyContent = encoder.convert(call.request.body);
    }
    rows.add(getListRow("Body:", bodyContent));

    var headers = call.request.headers;
    var headersContent = "Headers are empty";
    if (headers != null && headers.length > 0) {
      headersContent = "";
    }
    rows.add(getListRow("Headers: ", headersContent));
    if (call.request.headers != null) {
      call.request.headers.forEach((header, value) {
        rows.add(getListRow("   • $header:", value.toString()));
      });
    }
    var queryParameters = call.request.queryParameters;
    var queryParametersContent = "Query parameters are empty";
    if (queryParameters != null && queryParameters.length > 0) {
      queryParametersContent = "";
    }
    rows.add(getListRow("Query Parameters: ", queryParametersContent));
    if (call.request.queryParameters != null) {
      call.request.queryParameters.forEach((query, value) {
        rows.add(getListRow("   • $query:", value.toString()));
      });
    }

    return Container(
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
        child: ListView(children: rows));
  }
}
