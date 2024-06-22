import 'package:alice/model/alice_http_call.dart';
import 'package:alice/ui/call_details/widget/alice_call_expandable_list_row.dart';
import 'package:alice/ui/call_details/widget/alice_call_list_row.dart';
import 'package:alice/utils/alice_scroll_behavior.dart';
import 'package:flutter/material.dart';

class AliceCallErrorScreen extends StatelessWidget {
  const AliceCallErrorScreen({super.key, required this.call});

  final AliceHttpCall call;

  @override
  Widget build(BuildContext context) {
    if (call.error != null) {
      final dynamic error = call.error?.error;
      final StackTrace? stackTrace = call.error?.stackTrace;
      final String errorText =
          error != null ? error.toString() : 'Error is empty';

      return Container(
        padding: const EdgeInsets.all(6),
        child: ScrollConfiguration(
          behavior: AliceScrollBehavior(),
          child: ListView(
            children: [
              AliceCallListRow(name: 'Error:', value: errorText),
              if (stackTrace != null)
                AliceCallExpandableListRow(
                  name: 'Stack trace:',
                  value: stackTrace.toString(),
                ),
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
