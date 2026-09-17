import 'package:alice/src/model/alice_http_call.dart';
import 'package:alice/src/model/translation.dart';
import 'package:alice/src/ui/call_details/widget/call_expandable_list_row.dart';
import 'package:alice/src/ui/call_details/widget/call_list_row.dart';
import 'package:alice/src/ui/common/context_ext.dart';
import 'package:alice/src/ui/common/scroll_behavior.dart';
import 'package:material_ui/material_ui.dart';

/// Call error screen which displays info on HTTP call error.
class CallErrorScreen extends StatelessWidget {
  const CallErrorScreen({super.key, required this.call});

  final AliceHttpCall call;

  @override
  Widget build(BuildContext context) {
    if (call.error != null) {
      final dynamic error = call.error?.error;
      final StackTrace? stackTrace = call.error?.stackTrace;
      final String errorText = error != null
          ? error.toString()
          : context.i18n(TranslationKey.callErrorScreenErrorEmpty);

      return Container(
        padding: const EdgeInsets.all(6),
        child: ScrollConfiguration(
          behavior: CustomScrollBehavior(),
          child: SelectionArea(
            child: ListView(
              children: [
                CallListRow(
                  name: context.i18n(TranslationKey.callErrorScreenError),
                  value: errorText,
                ),
                if (stackTrace != null)
                  CallExpandableListRow(
                    name: context.i18n(
                      TranslationKey.callErrorScreenStacktrace,
                    ),
                    value: stackTrace.toString(),
                  ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Center(
        child: SelectionArea(
          child: Text(context.i18n(TranslationKey.callErrorScreenEmpty)),
        ),
      );
    }
  }
}
