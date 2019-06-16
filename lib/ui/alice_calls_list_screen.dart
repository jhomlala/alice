import 'package:alice/model/alice_menu_item.dart';
import 'package:alice/ui/alice_call_details_screen.dart';
import 'package:alice/core/alice_core.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_http_response.dart';
import 'package:flutter/material.dart';

import 'alice_stats_screen.dart';

class AliceCallsListScreen extends StatefulWidget {
  final AliceCore _aliceCore;

  AliceCallsListScreen(this._aliceCore);

  @override
  _AliceCallsListScreenState createState() => _AliceCallsListScreenState();
}

class _AliceCallsListScreenState extends State<AliceCallsListScreen> {
  List<AliceMenuItem> _menuItems = List();

  _AliceCallsListScreenState() {
    _menuItems.add(AliceMenuItem("Delete", Icons.delete));
    _menuItems.add(AliceMenuItem("Stats", Icons.insert_chart));
    _menuItems.add(AliceMenuItem("Save", Icons.save));
  }

  @override
  Widget build(BuildContext context) {
    print("Menu items: " + _menuItems.toString());
    return Scaffold(
        appBar: AppBar(
          title: Text("Alice - HTTP Inspector"),
          actions: [
            PopupMenuButton<AliceMenuItem>(
              onSelected: (AliceMenuItem item) => {_onMenuItemSelected(item)},
              itemBuilder: (BuildContext context) {
                return _menuItems.map((AliceMenuItem item) {
                  return PopupMenuItem<AliceMenuItem>(
                      value: item,
                      child: Row(children: [
                        Icon(
                          item.iconData,
                          color: Colors.lightBlue,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 10),
                        ),
                        Text(item.title)
                      ]));
                }).toList();
              },
            ),
          ],
        ),
        body: getCallsList());
  }

  void _onMenuItemSelected(AliceMenuItem menuItem) {
    if (menuItem.title == "Delete") {
      _showRemoveDialog();
    }
    if (menuItem.title == "Stats") {
      _showStatsScreen();
    }
  }

  Widget getCallsList() {
    return StreamBuilder(
        stream: widget._aliceCore.changesSubject.stream,
        builder: (context, AsyncSnapshot<int> snapshot) {
          if (widget._aliceCore.calls.length == 0) {
            return Center(child: Text("There is no calls to show"));
          } else {
            return ListView(
              children: _getListElements(),
            );
          }
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
                    Flexible(
                        child: Column(
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
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              )),
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
    if (response.status == -1) {
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
    if (status == -1) {
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

  void _showRemoveDialog() {
    showDialog(
        context: context,
        builder: (BuildContext buildContext) {
          return AlertDialog(
            title: Text("Delete calls"),
            content: Text("Do you want to delete http calls?"),
            actions: <Widget>[
              FlatButton(
                child: Text("Yes"),
                onPressed: () {
                  _removeCalls();
                  Navigator.of(buildContext).pop();
                },
              ),
              FlatButton(
                child: Text("No"),
                onPressed: () {
                  Navigator.of(buildContext).pop();
                },
              )
            ],
          );
        });
  }

  void _removeCalls() {
    widget._aliceCore.removeCalls();
  }

  void _showStatsScreen() {
    Navigator.push(
        widget._aliceCore.getContext(),
        MaterialPageRoute(
            builder: (context) => AliceStatsScreen(widget._aliceCore.calls)));
  }
}
