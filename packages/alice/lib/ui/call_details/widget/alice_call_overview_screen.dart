import 'package:alice/helper/alice_conversion_helper.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/ui/call_details/widget/alice_call_list_row.dart';
import 'package:alice/utils/alice_scroll_behavior.dart';
import 'package:flutter/material.dart';

class AliceCallOverviewScreen extends StatelessWidget {
  final AliceHttpCall call;
  const AliceCallOverviewScreen({super.key, required this.call});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      child: ScrollConfiguration(
        behavior: AliceScrollBehavior(),
        child: ListView(
          children: [
            AliceCallListRow(
              name: 'Method: ',
              value: call.method,
            ),
            AliceCallListRow(
              name: 'Server: ',
              value: call.server,
            ),
            AliceCallListRow(
              name: 'Endpoint: ',
              value: call.endpoint,
            ),
            AliceCallListRow(
              name: 'Started:',
              value: call.request?.time.toString(),
            ),
            AliceCallListRow(
              name: 'Finished:',
              value: call.response?.time.toString(),
            ),
            AliceCallListRow(
              name: 'Duration:',
              value: AliceConversionHelper.formatTime(call.duration),
            ),
            AliceCallListRow(
              name: 'Bytes sent:',
              value: AliceConversionHelper.formatBytes(
                call.request?.size ?? 0,
              ),
            ),
            AliceCallListRow(
              name: 'Bytes received:',
              value: AliceConversionHelper.formatBytes(
                call.response?.size ?? 0,
              ),
            ),
            AliceCallListRow(name: 'Client:', value: call.client),
            AliceCallListRow(
              name: 'Secure:',
              value: call.secure.toString(),
            ),
          ],
        ),
      ),
    );
  }
}
