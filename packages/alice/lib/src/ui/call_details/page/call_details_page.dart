// ignore_for_file: use_build_context_synchronously

import 'package:alice/src/core/alice_core.dart';
import 'package:alice/src/model/alice_http_call.dart';
import 'package:alice/src/model/translation.dart';
import 'package:alice/src/ui/call_details/model/call_details_tab.dart';
import 'package:alice/src/ui/call_details/widget/call_error_screen.dart';
import 'package:alice/src/ui/call_details/widget/call_details_fab.dart';
import 'package:alice/src/ui/call_details/widget/call_overview_screen.dart';
import 'package:alice/src/ui/call_details/widget/call_request_screen.dart';
import 'package:alice/src/ui/call_details/widget/call_response_screen.dart';
import 'package:alice/src/ui/common/context_ext.dart';
import 'package:alice/src/ui/common/page.dart';
import 'package:alice/src/ui/common/theme.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:material_ui/material_ui.dart';

/// Call details page which displays 4 tabs: overview, request, response, error.
class CallDetailsPage extends StatefulWidget {
  final AliceHttpCall call;
  final AliceCore core;

  const CallDetailsPage({required this.call, required this.core, super.key});

  @override
  State<StatefulWidget> createState() => _AliceCallDetailsPageState();
}

/// State of call details page.
class _AliceCallDetailsPageState extends State<CallDetailsPage>
    with SingleTickerProviderStateMixin {
  AliceHttpCall get call => widget.call;

  @override
  Widget build(BuildContext context) {
    return BasePage(
      core: widget.core,
      child: StreamBuilder<List<AliceHttpCall>>(
        stream: widget.core.callsStream,
        initialData: [widget.call],
        builder: (context, AsyncSnapshot<List<AliceHttpCall>> callsSnapshot) {
          if (callsSnapshot.hasData && !callsSnapshot.hasError) {
            final AliceHttpCall? call = callsSnapshot.data?.firstWhereOrNull(
              (AliceHttpCall snapshotCall) => snapshotCall.id == widget.call.id,
            );
            if (call != null) {
              return DefaultTabController(
                length: 4,
                child: Scaffold(
                  appBar: AppBar(
                    bottom: TabBar(
                      indicatorColor: AliceAppTheme.lightRed,
                      tabs: AliceCallDetailsTabItem.values.map((item) {
                        return Tab(
                          icon: _getTabIcon(item: item),
                          text: _getTabName(item: item),
                        );
                      }).toList(),
                    ),
                    title: Text(
                      '${context.i18n(TranslationKey.alice)} -'
                      ' ${context.i18n(TranslationKey.callDetails)}',
                    ),
                  ),
                  body: TabBarView(
                    children: [
                      CallOverviewScreen(call: widget.call),
                      CallRequestScreen(call: widget.call),
                      CallResponseScreen(call: widget.call),
                      CallErrorScreen(call: widget.call),
                    ],
                  ),
                  floatingActionButton: CallDetailsFab(
                    call: widget.call,
                    core: widget.core,
                  ),
                ),
              );
            }
          }

          return Center(
            child: Text(context.i18n(TranslationKey.callDetailsEmpty)),
          );
        },
      ),
    );
  }

  /// Called when share button has been pressed. It encodes the [widget.call]
  /// and tries to invoke system action to share it.

  /// Get tab name based on [item] type.
  String _getTabName({required AliceCallDetailsTabItem item}) {
    switch (item) {
      case AliceCallDetailsTabItem.overview:
        return context.i18n(TranslationKey.callDetailsOverview);
      case AliceCallDetailsTabItem.request:
        return context.i18n(TranslationKey.callDetailsRequest);
      case AliceCallDetailsTabItem.response:
        return context.i18n(TranslationKey.callDetailsResponse);
      case AliceCallDetailsTabItem.error:
        return context.i18n(TranslationKey.callDetailsError);
    }
  }

  /// Get tab icon based on [item] type.
  Icon _getTabIcon({required AliceCallDetailsTabItem item}) {
    switch (item) {
      case AliceCallDetailsTabItem.overview:
        return const Icon(Icons.info_outline);
      case AliceCallDetailsTabItem.request:
        return const Icon(Icons.arrow_upward);
      case AliceCallDetailsTabItem.response:
        return const Icon(Icons.arrow_downward);
      case AliceCallDetailsTabItem.error:
        return const Icon(Icons.warning);
    }
  }
}
