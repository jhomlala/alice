import 'dart:convert';

import 'package:alice/alice_core.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:flutter/material.dart';

class AliceCallDetailsScreen extends StatefulWidget {
  final AliceHttpCall call;
  final AliceCore core;

  AliceCallDetailsScreen(this.call, this.core);

  @override
  _AliceCallDetailsScreenState createState() => _AliceCallDetailsScreenState();
}

class _AliceCallDetailsScreenState extends State<AliceCallDetailsScreen> {
  JsonEncoder encoder = new JsonEncoder.withIndent('  ');
  TabBarView previousTabBarViewState;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
            appBar: AppBar(
              bottom: TabBar(
                tabs: [
                  Row(children: [
                    Tab(icon: Icon(Icons.info_outline)),
                    Padding(
                      padding: EdgeInsets.only(left: 5),
                    ),
                    Text("Overview")
                  ]),
                  Row(children: [
                    Tab(icon: Icon(Icons.arrow_upward)),
                    Padding(
                      padding: EdgeInsets.only(left: 5),
                    ),
                    Text("Request")
                  ]),
                  Row(children: [
                    Tab(icon: Icon(Icons.arrow_downward)),
                    Padding(
                      padding: EdgeInsets.only(left: 5),
                    ),
                    Text("Response")
                  ]),
                ],
              ),
              title: Text('Alice'),
            ),
            body: _getTabBarView()),
      ),
    );
  }

  Widget _getTabBarView() {
    return StreamBuilder<AliceHttpCall>(
        stream: widget.core.callUpdateSubject,
        initialData: widget.call,
        builder: (context, callSnapshot) {
          if (widget.call.id == callSnapshot.data.id) {
            print("Refresh requried!!");
            previousTabBarViewState = TabBarView(children: [
              _getOverviewWidget(),
              _getRequestWidget(),
              _getResponseWidget(),
            ]);
          }
          return previousTabBarViewState;
        });
  }

  Widget _getOverviewWidget() {
    List<Widget> rows = List();
    rows.add(_getListRow("Method: ", widget.call.method));
    rows.add(_getListRow("Server: ", widget.call.server));
    rows.add(_getListRow("Endpoint: ", widget.call.endpoint));
    rows.add(_getListRow("Started:", widget.call.request.time.toString()));
    rows.add(_getListRow("Finished:", widget.call.response.time.toString()));
    rows.add(_getListRow("Duration:", "${widget.call.duration} ms"));
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
    var bodyContent = "";
    if (body != null && body.length > 0){
      bodyContent =  encoder.convert(widget.call.request.body);
    }
    rows.add(_getListRow("Body:", bodyContent));

    rows.add(_getListRow("Headers: ", ""));
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
      rows.add(_getListRow("Bytes received:", formatBytes(widget.call.response.size)));
      rows.add(_getListRow("Status:", widget.call.response.status.toString()));
      rows.add(
          _getListRow("Body:", encoder.convert(widget.call.response.body)));
      rows.add(_getListRow("Headers: ", ""));
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
              ))
        ]);
  }

  String formatBytes(int bytes) {
    return "$bytes B";
  }
}
