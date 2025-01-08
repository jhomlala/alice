import 'package:alice/model/alice_http_call.dart';
import 'package:alice/ui/widget/alice_base_call_details_widget.dart';
import 'package:alice/utils/alice_scroll_behavior.dart';
import 'package:flutter/material.dart';

class AliceCallErrorWidget extends StatefulWidget {
  final AliceHttpCall call;

  const AliceCallErrorWidget(this.call, {super.key});

  @override
  State<StatefulWidget> createState() {
    return _AliceCallErrorWidgetState();
  }
}

class _AliceCallErrorWidgetState
    extends AliceBaseCallDetailsWidgetState<AliceCallErrorWidget> {
  AliceHttpCall get _call => widget.call;

  @override
  Widget build(BuildContext context) {
    if (_call.error != null) {
      final rows = <Widget>[];
      final dynamic error = _call.error!.error;
      var errorText = 'Error is empty';
      if (error != null) {
        errorText = error.toString();
      }
      rows.add(getListRow('Error:', errorText));

      return Container(
        padding: const EdgeInsets.all(6),
        child: ScrollConfiguration(
          behavior: AliceScrollBehavior(),
          child: ListView(children: rows),
        ),
      );
    } else {
      return const Center(child: Text('Nothing to display here'));
    }
  }
}
