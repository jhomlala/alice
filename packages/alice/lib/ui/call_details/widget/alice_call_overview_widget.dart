import 'package:alice/helper/alice_conversion_helper.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/ui/call_details/widget/alice_call_list_row.dart';
import 'package:alice/utils/alice_scroll_behavior.dart';
import 'package:flutter/material.dart';

class AliceCallOverviewWidget extends StatefulWidget {
  final AliceHttpCall call;

  const AliceCallOverviewWidget(this.call, {super.key});

  @override
  State<StatefulWidget> createState() {
    return _AliceCallOverviewWidget();
  }
}

class _AliceCallOverviewWidget extends State<AliceCallOverviewWidget> {
  AliceHttpCall get _call => widget.call;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      child: ScrollConfiguration(
        behavior: AliceScrollBehavior(),
        child: ListView(
          children: [
            AliceCallListRow(name: 'Method: ', value: _call.method),
            AliceCallListRow(name: 'Server: ', value: _call.server),
            AliceCallListRow(name: 'Endpoint: ', value: _call.endpoint),
            AliceCallListRow(
                name: 'Started:', value: _call.request?.time.toString()),
            AliceCallListRow(
                name: 'Finished:', value: _call.response?.time.toString()),
            AliceCallListRow(
                name: 'Duration:',
                value: AliceConversionHelper.formatTime(_call.duration)),
            AliceCallListRow(
                name: 'Bytes sent:',
                value: AliceConversionHelper.formatBytes(
                    _call.request?.size ?? 0)),
            AliceCallListRow(
              name: 'Bytes received:',
              value:
                  AliceConversionHelper.formatBytes(_call.response?.size ?? 0),
            ),
            AliceCallListRow(name: 'Client:', value: _call.client),
            AliceCallListRow(name: 'Secure:', value: _call.secure.toString()),
          ],
        ),
      ),
    );
  }
}
