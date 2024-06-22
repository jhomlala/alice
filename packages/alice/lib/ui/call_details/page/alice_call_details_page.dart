import 'package:alice/core/alice_core.dart';
import 'package:alice/helper/alice_save_helper.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/ui/call_details/widget/alice_call_error_widget.dart';
import 'package:alice/ui/call_details/widget/alice_call_overview_widget.dart';
import 'package:alice/ui/call_details/widget/alice_call_request_widget.dart';
import 'package:alice/ui/call_details/widget/alice_call_response_widget.dart';
import 'package:alice/utils/alice_constants.dart';
import 'package:alice/utils/alice_theme.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class AliceCallDetailsPage extends StatefulWidget {
  final AliceHttpCall call;
  final AliceCore core;

  const AliceCallDetailsPage(this.call, this.core, {super.key});

  @override
  State<StatefulWidget> createState() => _AliceCallDetailsPageState();
}

class _AliceCallDetailsPageState extends State<AliceCallDetailsPage>
    with SingleTickerProviderStateMixin {
  AliceHttpCall get call => widget.call;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: widget.core.directionality ?? Directionality.of(context),
      child: Theme(
        data: AliceTheme.getTheme(),
        child: StreamBuilder<List<AliceHttpCall>>(
          stream: widget.core.callsSubject,
          initialData: [widget.call],
          builder: (context, AsyncSnapshot<List<AliceHttpCall>> callsSnapshot) {
            if (callsSnapshot.hasData && !callsSnapshot.hasError) {
              final AliceHttpCall? call = callsSnapshot.data?.firstWhereOrNull(
                (AliceHttpCall snapshotCall) =>
                    snapshotCall.id == widget.call.id,
              );
              if (call != null) {
                return DefaultTabController(
                  length: 4,
                  child: Scaffold(
                    appBar: AppBar(
                      bottom: const TabBar(
                        indicatorColor: AliceConstants.lightRed,
                        tabs: [
                          Tab(icon: Icon(Icons.info_outline), text: 'Overview'),
                          Tab(icon: Icon(Icons.arrow_upward), text: 'Request'),
                          Tab(
                              icon: Icon(Icons.arrow_downward),
                              text: 'Response'),
                          Tab(
                            icon: Icon(Icons.warning),
                            text: 'Error',
                          ),
                        ],
                      ),
                      title: const Text('Alice - HTTP Call Details'),
                    ),
                    body: TabBarView(
                      children: [
                        AliceCallOverviewWidget(widget.call),
                        AliceCallRequestWidget(widget.call),
                        AliceCallResponseWidget(widget.call),
                        AliceCallErrorWidget(widget.call),
                      ],
                    ),
                    floatingActionButton: widget.core.showShareButton ?? false
                        ? FloatingActionButton(
                            backgroundColor: AliceConstants.lightRed,
                            key: const Key('share_key'),
                            onPressed: () async => await Share.share(
                              await AliceSaveHelper.buildCallLog(widget.call),
                              subject: 'Request Details',
                            ),
                            child: const Icon(
                              Icons.share,
                              color: AliceConstants.white,
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
      ),
    );
  }
}
