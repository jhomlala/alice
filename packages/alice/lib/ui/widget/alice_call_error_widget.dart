import 'package:alice/model/alice_http_call.dart';
import 'package:alice/ui/widget/alice_base_call_details_widget.dart';
import 'package:alice/utils/alice_scroll_behavior.dart';
import 'package:flutter/material.dart';

class AliceCallErrorWidget extends StatefulWidget {
  const AliceCallErrorWidget(
    this.call, {
    super.key,
  });

  final AliceHttpCall call;

  @override
  State<StatefulWidget> createState() => _AliceCallErrorWidgetState();
}

class _AliceCallErrorWidgetState
    extends AliceBaseCallDetailsWidgetState<AliceCallErrorWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.call.error != null) {
      final dynamic error = widget.call.error!.error;
      final String errorText =
          error != null ? error.toString() : 'Error is empty';

      return Container(
        padding: const EdgeInsets.all(6),
        child: ScrollConfiguration(
          behavior: AliceScrollBehavior(),
          child: ListView(
            children: [
              getListRow('Error:', errorText),
            ],
          ),
        ),
      );
    } else {
      return const Center(
        child: Text('Nothing to display here'),
      );
    }
  }
}
