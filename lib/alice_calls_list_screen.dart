import 'package:alice/alice_call_details_screen.dart';
import 'package:alice/alice_core.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_http_response.dart';
import 'package:flutter/material.dart';

class AliceCallsListScreen extends StatefulWidget {
  AliceCore _aliceCore;

  AliceCallsListScreen(AliceCore aliceCore) {
    _aliceCore = aliceCore;
  }

  @override
  _AliceCallsListScreenState createState() => _AliceCallsListScreenState();
}

class _AliceCallsListScreenState extends State<AliceCallsListScreen> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              title: Text("Alice"),
            ),
            body: getCallsList()));
  }

  Widget getCallsList() {
    return StreamBuilder(
        stream: widget._aliceCore.changesSubject.stream,
        builder: (context, AsyncSnapshot<int> snapshot) {
          print("Refreshing list... " +
              widget._aliceCore.calls.length.toString());
          return ListView(
            children: _getListElements(),
          );
        });
  }

  _getListElements() {
    List<Widget> widgets = List();
    print("Get list elements: " + widget._aliceCore.calls.length.toString());
    widget._aliceCore.calls
        .forEach((call) => {widgets.add(_getListItem(call))});
    return widgets;
  }

  Widget _getListItem(AliceHttpCall call) {
    return InkWell(
      onTap: (){
        _onListItemClicked(call);
      },
        child: Column(children: [
      Container(
          padding: EdgeInsets.all(10),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(call.method,
                        style: TextStyle(fontSize: 16, color: Colors.black)),
                    Padding(
                      padding: EdgeInsets.only(left: 10),
                    ),
                    Text(call.endpoint,
                        style: TextStyle(fontSize: 16, color: Colors.black))
                  ]),
                  Padding(
                    padding: EdgeInsets.only(top: 5),
                  ),
                  Text(call.server,
                      style: TextStyle(fontSize: 14, color: Colors.black)),
                  Padding(
                    padding: EdgeInsets.only(top: 5),
                  ),
                  Text(_formatTime(call.request.time),
                      style: TextStyle(fontSize: 12, color: Colors.black))
                ]),
            _getResponseColumn(call)
          ])),
      Container(height: 1,color:Colors.grey)
    ]));
  }

  String _formatTime(DateTime time) {
    return "${formatTimeUnit(time.hour)}:${formatTimeUnit(time.minute)}:${formatTimeUnit(time.second)}:${formatTimeUnit(time.millisecond)}";
  }

  String formatTimeUnit(int timeUnit) {
    return (timeUnit < 10) ? "0${timeUnit}" : "${timeUnit}";
  }

  String getStatus(AliceHttpResponse response) {
    if (response.status == 0) {
      return "???";
    } else {
      return "${response.status}";
    }
  }

  Column _getResponseColumn(AliceHttpCall call) {
    List<Widget> widgets = List();
    if (call.loading) {
      widgets.add(SizedBox(
        child: new CircularProgressIndicator(),
        width: 20,
        height: 20,
      ));
    }
    widgets.add(Text(getStatus(call.response),
        style: TextStyle(fontSize: 16, color: Colors.black)));
    return Column(children: widgets);
  }

  void _onListItemClicked(AliceHttpCall call) {
    print("list item clicked");
    Navigator.push(
      widget._aliceCore.getContext(),
      MaterialPageRoute(builder: (context) => AliceCallDetailsScreen(call,widget._aliceCore)),
    );
  }
}
