import 'package:alice/model/alice_http_call.dart';
import 'package:alice/ui/widget/alice_base_call_details_widget.dart';
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

class _AliceCallOverviewWidget
    extends AliceBaseCallDetailsWidgetState<AliceCallOverviewWidget> {
  AliceHttpCall get _call => widget.call;

  @override
  Widget build(BuildContext context) {
    final rows = [
      getListRow('Method: ', _call.method),
      getListRow('Server: ', _call.server),
      getListRow('Endpoint: ', _call.endpoint),
      getListRow('Started:', _call.request!.time.toString()),
      getListRow('Finished:', _call.response!.time.toString()),
      getListRow('Duration:', formatDuration(_call.duration)),
      getListRow('Bytes sent:', formatBytes(_call.request!.size)),
      getListRow('Bytes received:', formatBytes(_call.response!.size)),
      getListRow('Client:', _call.client),
      getListRow('Secure:', _call.secure.toString()),
    ];

    return Container(
      padding: const EdgeInsets.all(6),
      child: ScrollConfiguration(
        behavior: AliceScrollBehavior(),
        child: ListView(children: rows),
      ),
    );
  }
}
