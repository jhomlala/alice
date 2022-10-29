import 'package:alice/core/alice_core.dart';
import 'package:alice/helper/alice_save_helper.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/utils/alice_constants.dart';
import 'package:alice/ui/widget/alice_call_error_widget.dart';
import 'package:alice/ui/widget/alice_call_overview_widget.dart';
import 'package:alice/ui/widget/alice_call_request_widget.dart';
import 'package:alice/ui/widget/alice_call_response_widget.dart';
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
  AliceHttpCall get call => widget.call;

  @override
  void initState() {
    super.initState();
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
          initialData: [widget.call],
          builder: (context, callsSnapshot) {
            if (callsSnapshot.hasData) {
              final AliceHttpCall? call = callsSnapshot.data!.firstWhereOrNull(
                (snapshotCall) => snapshotCall.id == widget.call.id,
              );
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

  Widget _buildMainWidget() {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        floatingActionButton: widget.core.showShareButton == true
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
          bottom: TabBar(
            indicatorColor: AliceConstants.lightRed,
            tabs: _getTabBars(),
          ),
          title: const Text('Alice - HTTP Call Details'),
        ),
        body: TabBarView(
          children: _getTabBarViewList(),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return const Center(child: Text("Failed to load data"));
  }

  Future<String> _getSharableResponseString() async {
    return AliceSaveHelper.buildCallLog(widget.call);
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
    widgets.add(AliceCallOverviewWidget(widget.call));
    widgets.add(AliceCallRequestWidget(widget.call));
    widgets.add(AliceCallResponseWidget(widget.call));
    widgets.add(AliceCallErrorWidget(widget.call));
    return widgets;
  }
}
