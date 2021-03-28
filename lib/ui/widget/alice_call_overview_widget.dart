import 'package:alice/model/alice_http_call.dart';
import 'package:alice/ui/widget/alice_base_call_details_widget.dart';
import 'package:flutter/material.dart';

class AliceCallOverviewWidget extends StatefulWidget {
  final AliceHttpCall call;

  const AliceCallOverviewWidget(this.call);

  @override
  State<StatefulWidget> createState() {
    return _AliceCallOverviewWidget();
  }
}

class _AliceCallOverviewWidget
    extends AliceBaseCallDetailsWidgetState<AliceCallOverviewWidget> {
  AliceHttpCall get _call => widget.call;

  @override
  Widget build(BuildContext context) {
    final List<Widget> rows = [];
    rows.add(getListRow("Method: ", _call.method));
    rows.add(getListRow("Server: ", _call.server));
    rows.add(getListRow("Endpoint: ", _call.endpoint));
    rows.add(getListRow("Started:", _call.request!.time.toString()));
    rows.add(getListRow("Finished:", _call.response!.time.toString()));
    rows.add(getListRow("Duration:", formatDuration(_call.duration)));
    rows.add(getListRow("Bytes sent:", formatBytes(_call.request!.size)));
    rows.add(getListRow("Bytes received:", formatBytes(_call.response!.size)));
    rows.add(getListRow("Client:", _call.client));
    rows.add(getListRow("Secure:", _call.secure.toString()));
    return Container(
      padding: const EdgeInsets.all(6),
      child: ListView(children: rows),
    );
  }
}
