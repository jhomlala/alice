import 'package:alice/src/utils/conversion_utils.dart';
import 'package:alice/src/model/alice_http_call.dart';
import 'package:alice/src/model/translation.dart';
import 'package:alice/src/ui/call_details/widget/call_list_row.dart';
import 'package:alice/src/ui/common/context_ext.dart';
import 'package:alice/src/ui/common/scroll_behavior.dart';
import 'package:material_ui/material_ui.dart';

/// Screen which displays call overview data, for example method, server.
class CallOverviewScreen extends StatelessWidget {
  final AliceHttpCall call;

  const CallOverviewScreen({super.key, required this.call});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      child: ScrollConfiguration(
        behavior: CustomScrollBehavior(),
        child: SelectionArea(
          child: ListView(
            children: [
              CallListRow(
                name: context.i18n(TranslationKey.callOverviewMethod),
                value: call.method,
              ),
              CallListRow(
                name: context.i18n(TranslationKey.callOverviewServer),
                value: call.server,
              ),
              CallListRow(
                name: context.i18n(TranslationKey.callOverviewEndpoint),
                value: call.endpoint,
              ),
              CallListRow(
                name: context.i18n(TranslationKey.callOverviewStarted),
                value: call.request?.time.toString(),
              ),
              CallListRow(
                name: context.i18n(TranslationKey.callOverviewFinished),
                value: call.response?.time.toString(),
              ),
              CallListRow(
                name: context.i18n(TranslationKey.callOverviewDuration),
                value: ConversionUtils.formatTime(call.duration),
              ),
              CallListRow(
                name: context.i18n(TranslationKey.callOverviewBytesSent),
                value: ConversionUtils.formatBytes(call.request?.size ?? 0),
              ),
              CallListRow(
                name: context.i18n(TranslationKey.callOverviewBytesReceived),
                value: ConversionUtils.formatBytes(call.response?.size ?? 0),
              ),
              CallListRow(
                name: context.i18n(TranslationKey.callOverviewClient),
                value: call.client,
              ),
              CallListRow(
                name: context.i18n(TranslationKey.callOverviewSecure),
                value: call.secure.toString(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
