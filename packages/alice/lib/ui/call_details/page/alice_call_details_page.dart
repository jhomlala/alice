import 'package:alice/core/alice_core.dart';
import 'package:alice/helper/alice_save_helper.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/ui/call_details/model/alice_call_details_tab.dart';
import 'package:alice/ui/call_details/widget/alice_call_error_screen.dart';
import 'package:alice/ui/call_details/widget/alice_call_overview_screen.dart';
import 'package:alice/ui/call_details/widget/alice_call_request_screen.dart';
import 'package:alice/ui/call_details/widget/alice_call_response_screen.dart';
import 'package:alice/ui/common/alice_page.dart';
import 'package:alice/utils/alice_theme.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

/// Call details page which displays 4 tabs: overview, request, response, error.
class AliceCallDetailsPage extends StatefulWidget {
  final AliceHttpCall call;
  final AliceCore core;

  const AliceCallDetailsPage({
    required this.call,
    required this.core,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _AliceCallDetailsPageState();
}

/// State of call details page.
class _AliceCallDetailsPageState extends State<AliceCallDetailsPage>
    with SingleTickerProviderStateMixin {
  AliceHttpCall get call => widget.call;

  @override
  Widget build(BuildContext context) {
    return AlicePage(
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
                      indicatorColor: AliceTheme.lightRed,
                      tabs: AliceCallDetailsTabItem.values.map((item) {
                        return Tab(
                          icon: _getTabIcon(item: item),
                          text: _getTabName(
                            item: item,
                          ),
                        );
                      }).toList(),
                    ),
                    title: const Text('Alice - HTTP Call Details'),
                  ),
                  body: TabBarView(
                    children: [
                      AliceCallOverviewScreen(call: widget.call),
                      AliceCallRequestScreen(call: widget.call),
                      AliceCallResponseScreen(call: widget.call),
                      AliceCallErrorScreen(call: widget.call),
                    ],
                  ),
                  floatingActionButton: widget.core.showShareButton ?? false
                      ? FloatingActionButton(
                          backgroundColor: AliceTheme.lightRed,
                          key: const Key('share_key'),
                          onPressed: () async => await Share.share(
                            await AliceSaveHelper.buildCallLog(widget.call),
                            subject: 'Request Details',
                          ),
                          child: const Icon(
                            Icons.share,
                            color: AliceTheme.white,
                          ),
                        )
                      : null,
                ),
              );
            }
          }

          return const Center(child: Text('Failed to load data'));
        },
      ),
    );
  }

  /// Get tab name based on [item] type.
  String _getTabName({required AliceCallDetailsTabItem item}) {
    switch (item) {
      case AliceCallDetailsTabItem.overview:
        return "Overview";
      case AliceCallDetailsTabItem.request:
        return "Request";
      case AliceCallDetailsTabItem.response:
        return "Response";
      case AliceCallDetailsTabItem.error:
        return "Error";
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
