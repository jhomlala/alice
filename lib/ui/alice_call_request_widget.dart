import 'package:alice/model/alice_http_call.dart';
import 'package:flutter/material.dart';

import 'alice_base_call_details_widget.dart';

class AliceCallRequestWidget extends StatefulWidget {
  final AliceHttpCall call;

  AliceCallRequestWidget(this.call);

  @override
  State<StatefulWidget> createState() {
    return _AliceCallRequestWidget();
  }
}

class _AliceCallRequestWidget
    extends AliceBaseCallDetailsWidgetState<AliceCallRequestWidget> {
  AliceHttpCall get _call => widget.call;

  @override
  Widget build(BuildContext context) {
    List<Widget> rows = List();
    rows.add(getListRow("Started:", _call.request.time.toString()));
    rows.add(getListRow("Bytes sent:", formatBytes(_call.request.size)));
    rows.add(
        getListRow("Content type:", getContentType(_call.request.headers)));

    var body = _call.request.body;
    var bodyContent = "Body is empty";
    if (body != null && body.length > 0) {
      bodyContent = formatBody(body, getContentType(_call.request.headers));
    }
    rows.add(getListRow("Body:", bodyContent));

    var headers = _call.request.headers;
    var headersContent = "Headers are empty";
    if (headers != null && headers.length > 0) {
      headersContent = "";
    }
    rows.add(getListRow("Headers: ", headersContent));
    if (_call.request.headers != null) {
      _call.request.headers.forEach((header, value) {
        rows.add(getListRow("   • $header:", value.toString()));
      });
    }
    var queryParameters = _call.request.queryParameters;
    var queryParametersContent = "Query parameters are empty";
    if (queryParameters != null && queryParameters.length > 0) {
      queryParametersContent = "";
    }
    rows.add(getListRow("Query Parameters: ", queryParametersContent));
    if (_call.request.queryParameters != null) {
      _call.request.queryParameters.forEach((query, value) {
        rows.add(getListRow("   • $query:", value.toString()));
      });
    }

    return Container(
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
        child: ListView(children: rows));
  }
}
