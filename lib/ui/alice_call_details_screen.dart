import 'dart:convert';

import 'package:alice/core/alice_core.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:flutter/material.dart';

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
    return  StreamBuilder<AliceHttpCall>(
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
    widgets.add(_getOverviewWidget());
    widgets.add(_getRequestWidget());
    widgets.add(_getResponseWidget());
    widgets.add(_getErrorWidget());
    return widgets;
  }

  Widget _getOverviewWidget() {
    List<Widget> rows = List();
    rows.add(_getListRow("Method: ", widget.call.method));
    rows.add(_getListRow("Server: ", widget.call.server));
    rows.add(_getListRow("Endpoint: ", widget.call.endpoint));
    rows.add(_getListRow("Started:", widget.call.request.time.toString()));
    rows.add(_getListRow("Finished:", widget.call.response.time.toString()));
    rows.add(_getListRow("Duration:", formatDuration(widget.call.duration)));
    rows.add(_getListRow("Bytes sent:", formatBytes(widget.call.request.size)));
    rows.add(
        _getListRow("Bytes received:", formatBytes(widget.call.response.size)));
    rows.add(_getListRow("Client:", widget.call.client));
    rows.add(_getListRow("Secure:", widget.call.secure.toString()));
    return Container(
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
        child: ListView(children: rows));
  }

  Widget _getRequestWidget() {
    List<Widget> rows = List();
    rows.add(_getListRow("Started:", widget.call.request.time.toString()));
    rows.add(_getListRow("Bytes sent:", formatBytes(widget.call.request.size)));
    rows.add(_getListRow("Content type:", widget.call.request.contentType));

    var body = widget.call.request.body;
    var bodyContent = "Body is empty";
    if (body != null && body.length > 0) {
      bodyContent = _encoder.convert(widget.call.request.body);
    }
    rows.add(_getListRow("Body:", bodyContent));

    var headers = widget.call.request.headers;
    var headersContent = "Headers are empty";
    if (headers != null && headers.length > 0) {
      headersContent = "";
    }
    rows.add(_getListRow("Headers: ", headersContent));
    if (widget.call.request.headers != null) {
      widget.call.request.headers.forEach((header, value) {
        rows.add(_getListRow("   • $header:", value.toString()));
      });
    }
    return Container(
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
        child: ListView(children: rows));
  }

  Widget _getResponseWidget() {
    List<Widget> rows = List();
    if (!widget.call.loading) {
      rows.add(_getListRow("Received:", widget.call.response.time.toString()));
      rows.add(_getListRow(
          "Bytes received:", formatBytes(widget.call.response.size)));

      var status = widget.call.response.status;
      var statusText = "$status";
      if (status == -1) {
        statusText = "Error";
      }

      rows.add(_getListRow("Status:", statusText));

      var body = widget.call.response.body;
      var bodyContent = "Body is empty";
      if (body != null && body.length > 0) {
        bodyContent = _encoder.convert(widget.call.response.body);
      }
      rows.add(_getListRow("Body:", bodyContent));

      var headers = widget.call.response.headers;
      var headersContent = "Headers are empty";
      if (headers != null && headers.length > 0) {
        headersContent = "";
      }
      rows.add(_getListRow("Headers: ", headersContent));
      if (widget.call.response.headers != null) {
        widget.call.response.headers.forEach((header, value) {
          rows.add(_getListRow("   • $header:", value.toString()));
        });
      }
      return Container(
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
          child: ListView(children: rows));
    } else {
      return Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          new CircularProgressIndicator(),
          Text("Awaiting response...")
        ],
      ));
    }
  }

  Widget _getErrorWidget() {
    if (widget.call.error != null) {
      List<Widget> rows = List();
      var error = widget.call.error.error;
      var errorText = "Error is empty";
      if (error != null){
        errorText = error.toString();
      }
      rows.add(_getListRow("Error:", errorText));

      var stackTrace = widget.call.error.stackTrace;
      var stackTraceText = "Stack Trace is empty";
      if (stackTrace != null){
        stackTraceText = stackTrace.toString();
      }

      rows.add(_getListRow(
          "Stack Trace: ", stackTraceText));
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
}
