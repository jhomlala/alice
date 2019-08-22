import 'package:alice/model/alice_menu_item.dart';
import 'package:alice/ui/alice_call_details_screen.dart';
import 'package:alice/core/alice_core.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:flutter/material.dart';

import 'alice_alert_helper.dart';
import 'alice_call_list_item.dart';
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
    return Scaffold(
        appBar: AppBar(
          title: Text("Alice - HTTP Inspector - Calls"),
          actions: [
            PopupMenuButton<AliceMenuItem>(
              onSelected: (AliceMenuItem item) => _onMenuItemSelected(item),
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
        body: _getCallsList());
  }

  void _onMenuItemSelected(AliceMenuItem menuItem) {
    if (menuItem.title == "Delete") {
      _showRemoveDialog();
    }
    if (menuItem.title == "Stats") {
      _showStatsScreen();
    }
    if (menuItem.title == "Save") {
      _saveToFile();
    }
  }

  Widget _getCallsList() {
    return StreamBuilder(
        stream: widget._aliceCore.changesSubject.stream,
        builder: (context, AsyncSnapshot<int> snapshot) {
          if (widget._aliceCore.calls.length == 0) {
            return Container(
                margin: EdgeInsets.all(5),
                child: Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.orange,
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 5),
                        ),
                        Text(
                          "There are no calls to show",
                          style: TextStyle(fontSize: 18),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 5),
                        ),
                        Text(
                          "You have not send any http call or your Alice configuration is invalid.",
                          style: TextStyle(fontSize: 12),
                        )
                      ]),
                ));
          } else {
            return ListView(
              children: _getListElements(),
            );
          }
        });
  }

  _getListElements() {
    List<Widget> widgets = List();
    widget._aliceCore.calls.forEach((AliceHttpCall call) {
      widgets.add(AliceCallListItem(call, _onListItemClicked));
    });
    return widgets;
  }

  void _onListItemClicked(AliceHttpCall call) {
    Navigator.push(
      widget._aliceCore.getContext(),
      MaterialPageRoute(
          builder: (context) =>
              AliceCallDetailsScreen(call, widget._aliceCore)),
    );
  }

  void _showRemoveDialog() {
    AliceAlertHelper.showAlert(
        context, "Delete calls", "Do you want to delete http calls?",
        firstButtonTitle: "No",
        firstButtonAction: () => {},
        secondButtonTitle: "Yes",
        secondButtonAction: () => _removeCalls());
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

  void _saveToFile() async {
    widget._aliceCore.saveHttpRequests(context);
  }
}
