import 'package:alice/core/alice_core.dart';
import 'package:alice/helper/alice_save_helper.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/ui/widget/alice_call_error_widget.dart';
import 'package:alice/ui/widget/alice_call_overview_widget.dart';
import 'package:alice/ui/widget/alice_call_request_widget.dart';
import 'package:alice/ui/widget/alice_call_response_widget.dart';
import 'package:alice/utils/alice_constants.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class AliceCallDetailsScreen extends StatefulWidget {
  final AliceHttpCall call;
  final AliceCore core;

  const AliceCallDetailsScreen(this.call, this.core);

  @override
  _AliceCallDetailsScreenState createState() => _AliceCallDetailsScreenState();
}

class _AliceCallDetailsScreenState extends State<AliceCallDetailsScreen>
    with SingleTickerProviderStateMixin {
  late AliceHttpCall call;

  @override
  void initState() {
    super.initState();
    call = widget.call;
  }

  bool parentCallMatchSnapshotCall(AliceHttpCall snapshotCall) {
    return snapshotCall.hasParentCall &&
        snapshotCall.parentCallId == this.call.id;
  }

  bool currentCallMatchSnapshotCall(AliceHttpCall snapshotCall) {
    return snapshotCall.id == this.call.id;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: widget.core.directionality ?? Directionality.of(context),
      child: Theme(
        data: ThemeData(
          brightness: widget.core.brightness,
          colorScheme: ColorScheme.light(secondary: AliceConstants.lightRed),
        ),
        child: StreamBuilder<List<AliceHttpCall>>(
          stream: widget.core.callsSubject,
          initialData: [this.call],
          builder: (context, callsSnapshot) {
            if (callsSnapshot.hasData) {
              AliceHttpCall? call = callsSnapshot.data!
                  .firstWhereOrNull(currentCallMatchSnapshotCall);
              if (call == null) {
                ///Get parent call
                call = callsSnapshot.data!
                    .firstWhereOrNull(parentCallMatchSnapshotCall);
                if (call != null) {
                  this.call = call;
                }
              } else {
                this.call = call;
              }
              if (call != null) {
                return _buildMainWidget();
              } else {
                return _buildErrorWidget();
              }
            } else {
              return _buildErrorWidget();
            }
          },
        ),
      ),
    );
  }

  Widget _renderScaffold(
      {bool? showShareButton = false,
      required Widget body,
      PreferredSizeWidget? bottomAppbar}) {
    return Scaffold(
      floatingActionButton: showShareButton == true
          ? FloatingActionButton(
              backgroundColor: AliceConstants.lightRed,
              key: const Key('share_key'),
              onPressed: () async {
                Share.share(
                  await _getSharableResponseString(),
                  subject: 'Request Details',
                );
              },
              child: Icon(
                Icons.share,
                color: AliceConstants.white,
              ),
            )
          : null,
      appBar: AppBar(
        bottom: bottomAppbar,
        title: const Text('Alice - HTTP Call Details'),
        actions: [_buildRetryButton()],
      ),
      body: body,
    );
  }

  Widget _buildMainWidget() {
    return DefaultTabController(
      length: 4,
      child: _renderScaffold(
        bottomAppbar: TabBar(
          indicatorColor: AliceConstants.lightRed,
          tabs: _getTabBars(),
        ),
        showShareButton: widget.core.showShareButton,
        body: TabBarView(
          children: _getTabBarViewList(),
        ),
      ),
    );
  }

  Widget _buildRetryButton() {
    if (call.shouldShowRetryButton) {
      return IconButton(
        icon: Icon(Icons.replay_outlined),
        onPressed: call.retryCallBack,
      );
    }
    return const SizedBox();
  }

  Widget _buildErrorWidget() {
    return _renderScaffold(
        body: const Center(child: Text("Failed to load data")));
  }

  Future<String> _getSharableResponseString() async {
    return AliceSaveHelper.buildCallLog(this.call);
  }

  List<Widget> _getTabBars() {
    final List<Widget> widgets = [];
    widgets.add(const Tab(icon: Icon(Icons.info_outline), text: "Overview"));
    widgets.add(const Tab(icon: Icon(Icons.arrow_upward), text: "Request"));
    widgets.add(const Tab(icon: Icon(Icons.arrow_downward), text: "Response"));
    widgets.add(
      const Tab(
        icon: Icon(Icons.warning),
        text: "Error",
      ),
    );
    return widgets;
  }

  List<Widget> _getTabBarViewList() {
    final List<Widget> widgets = [];
    widgets.add(AliceCallOverviewWidget(this.call));
    widgets.add(AliceCallRequestWidget(this.call));
    widgets.add(AliceCallResponseWidget(this.call));
    widgets.add(AliceCallErrorWidget(this.call));
    return widgets;
  }
}
