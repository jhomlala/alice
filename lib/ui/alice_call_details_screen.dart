import 'package:alice/core/alice_core.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:flutter/material.dart';

import 'alice_call_error_widger.dart';
import 'alice_call_overview_widget.dart';
import 'alice_call_request_widget.dart';
import 'alice_call_response_widget.dart';

class AliceCallDetailsScreen extends StatefulWidget {
  final AliceHttpCall call;
  final AliceCore core;

  AliceCallDetailsScreen(this.call, this.core);

  @override
  _AliceCallDetailsScreenState createState() => _AliceCallDetailsScreenState();
}

class _AliceCallDetailsScreenState extends State<AliceCallDetailsScreen>
    with SingleTickerProviderStateMixin {
  Widget _previousState;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AliceHttpCall>(
        stream: widget.core.callUpdateSubject,
        initialData: widget.call,
        builder: (context, callSnapshot) {
          if (widget.call.id == callSnapshot.data.id) {
            _previousState = DefaultTabController(
                length: 4,
                child: Scaffold(
                    appBar: AppBar(
                      bottom: TabBar(tabs: _getTabBars()),
                      title: Text('Alice - HTTP Inspector - Details'),
                    ),
                    body: TabBarView(children: _getTabBarViewList())));
          }
          return _previousState;
        });
  }

  List<Widget> _getTabBars() {
    List<Widget> widgets = List();
    widgets.add(Tab(icon: Icon(Icons.info_outline), text: "Overview"));
    widgets.add(Tab(icon: Icon(Icons.arrow_upward), text: "Request"));
    widgets.add(Tab(icon: Icon(Icons.arrow_downward), text: "Response"));
    widgets.add(Tab(
      icon: Icon(Icons.warning),
      text: "Error",
    ));
    return widgets;
  }

  List<Widget> _getTabBarViewList() {
    List<Widget> widgets = List();
    widgets.add(AliceCallOverviewWidget(widget.call));
    widgets.add(AliceCallRequestWidget(widget.call));
    widgets.add(AliceCallResponseWidget(widget.call));
    widgets.add(AliceCallErrorWidget(widget.call));
    return widgets;
  }
}
