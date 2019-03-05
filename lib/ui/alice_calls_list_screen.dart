import 'package:alice/ui/alice_call_details_screen.dart';
import 'package:alice/core/alice_core.dart';
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
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            appBar: AppBar(
              title: Text("Alice - HTTP Inspector"),
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
        onTap: () {
          _onListItemClicked(call);
        },
        child: Column(children: [
          Container(
              padding: EdgeInsets.all(10),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Text(call.method,
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black)),
                            Padding(
                              padding: EdgeInsets.only(left: 10),
                            ),
                            Flexible(
                                child: Container(
                                    child: Text(call.endpoint,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black))))
                          ]),
                          Padding(
                            padding: EdgeInsets.only(top: 5),
                          ),
                          Text(call.server,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style:
                                  TextStyle(fontSize: 14, color: Colors.black, )),
                          Padding(
                            padding: EdgeInsets.only(top: 5),
                          ),
                          Row(children: [
                            Text(_formatTime(call.request.time),
                                style: TextStyle(
                                    fontSize: 12, color: Colors.black)),
                            Padding(padding: EdgeInsets.only(left: 10)),
                            Text("${call.duration} ms",
                                style: TextStyle(
                                    fontSize: 12, color: Colors.black)),
                            Padding(padding: EdgeInsets.only(left: 10)),
                            Text(
                                "${call.request.size}B / ${call.response.size}B",
                                style: TextStyle(
                                    fontSize: 12, color: Colors.black))
                          ]),
                        ])),
                    _getResponseColumn(call)
                  ])),
          Container(height: 1, color: Colors.grey)
        ]));
  }

  String _formatTime(DateTime time) {
    return "${formatTimeUnit(time.hour)}:${formatTimeUnit(time.minute)}:${formatTimeUnit(time.second)}:${formatTimeUnit(time.millisecond)}";
  }

  String formatTimeUnit(int timeUnit) {
    return (timeUnit < 10) ? "0$timeUnit" : "$timeUnit";
  }

  String getStatus(AliceHttpResponse response) {
    if (response.status == -1){
      return "ERR";
    } else if (response.status == 0) {
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
        style: TextStyle(
            fontSize: 16, color: _getStatusTextColor(call.response.status))));
    return Column(children: widgets);
  }

  void _onListItemClicked(AliceHttpCall call) {
    Navigator.push(
      widget._aliceCore.getContext(),
      MaterialPageRoute(
          builder: (context) =>
              AliceCallDetailsScreen(call, widget._aliceCore)),
    );
  }

  Color _getStatusTextColor(int status) {
    if (status == -1){
      return Colors.red;
    } else if (status < 200) {
      return Colors.black;
    } else if (status >= 200 && status < 300) {
      return Colors.green;
    } else if (status >= 300 && status < 400) {
      return Colors.orange;
    } else if (status >= 400 && status < 600) {
      return Colors.red;
    } else {
      return Colors.black;
    }
  }
}
