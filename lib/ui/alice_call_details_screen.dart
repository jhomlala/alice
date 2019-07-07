import 'dart:convert';

import 'package:alice/core/alice_core.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:flutter/material.dart';

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
  JsonEncoder _encoder = new JsonEncoder.withIndent('  ');
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
                      title: Text('Alice - HTTP Inspector'),
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
    widgets.add(_getErrorWidget());
    return widgets;
  }


  Widget _getErrorWidget() {
    if (widget.call.error != null) {
      List<Widget> rows = List();
      var error = widget.call.error.error;
      var errorText = "Error is empty";
      if (error != null) {
        errorText = error.toString();
      }
      rows.add(_getListRow("Error:", errorText));

      return Container(
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
          child: ListView(children: rows));
    } else {
      return Center(child: Text("No error to display"));
    }
  }

  Widget _getListRow(String name, String value) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
          Padding(padding: EdgeInsets.only(left: 5)),
          Flexible(
              fit: FlexFit.loose,
              child: Text(
                value,
                overflow: TextOverflow.clip,
              )),
          Padding(
            padding: EdgeInsets.only(bottom: 18),
          )
        ]);
  }

  String formatBytes(int bytes) {
    return "$bytes B";
  }

  String formatDuration(int duration) {
    return "$duration ms";
  }

  String formatBody(dynamic body, String contentType) {
    var bodyContent = "Body is empty";
    if (body != null) {
      if (contentType == null ||
          !contentType.toLowerCase().contains("application/json")) {
        return body.toString();
      } else {
        if (body is String && body.contains("\n")) {
          bodyContent = body;
        } else {
          bodyContent = _encoder.convert(widget.call.response.body);
        }
      }
    }
    return bodyContent;
  }

  String getContentType(Map<String, dynamic> headers) {
    if (headers != null) {
      if (headers.containsKey("content-type")) {
        return headers["content-type"];
      }
      if (headers.containsKey("Content-Type")) {
        return headers["Content-Type"];
      }
    }
    return "???";
  }
}
