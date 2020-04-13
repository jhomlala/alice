import 'package:alice/model/alice_menu_item.dart';
import 'package:alice/helper/alice_alert_helper.dart';
import 'package:alice/ui/page/alice_call_details_screen.dart';
import 'package:alice/core/alice_core.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/ui/widget/alice_call_list_item_widget.dart';
import 'package:flutter/material.dart';

import 'alice_stats_screen.dart';

class AliceCallsListScreen extends StatefulWidget {
  final AliceCore _aliceCore;

  AliceCallsListScreen(this._aliceCore);

  @override
  _AliceCallsListScreenState createState() => _AliceCallsListScreenState();
}

class _AliceCallsListScreenState extends State<AliceCallsListScreen> {
  AliceCore get aliceCore => widget._aliceCore;

  List<AliceMenuItem> _menuItems = List();

  _AliceCallsListScreenState() {
    _menuItems.add(AliceMenuItem("Delete", Icons.delete));
    _menuItems.add(AliceMenuItem("Stats", Icons.insert_chart));
    _menuItems.add(AliceMenuItem("Save", Icons.save));
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(brightness: widget._aliceCore.brightness),
      child: Scaffold(
        appBar: AppBar(
          title: Text("Alice - Inspector"),
          actions: [_buildMenuButton()],
        ),
        body: _buildCallsListWrapper(),
      ),
    );
  }

  Widget _buildMenuButton() {
    return PopupMenuButton<AliceMenuItem>(
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
            ]),
          );
        }).toList();
      },
    );
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

  Widget _buildCallsListWrapper() {
    return StreamBuilder<List<AliceHttpCall>>(
      stream: aliceCore.callsSubject,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data.isNotEmpty) {
          return _buildCallsListWidget(snapshot.data);
        } else {
          return _buildEmptyWidget();
        }
      },
    );
  }

  Widget _buildEmptyWidget() {
    return Container(
      margin: EdgeInsets.all(5),
      child: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(
            Icons.error_outline,
            color: Colors.orange,
          ),
          const SizedBox(height: 6),
          Text(
            "There are no calls to show",
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 6),
          Text(
            "You have not send any http call or your Alice configuration is invalid.",
            style: TextStyle(fontSize: 12),
          )
        ]),
      ),
    );
  }

  Widget _buildCallsListWidget(List<AliceHttpCall> calls) {
    return ListView.builder(
      itemCount: calls.length,
      itemBuilder: (context, index) {
        return AliceCallListItemWidget(calls[index], _onListItemClicked);
      },
    );
  }

  void _onListItemClicked(AliceHttpCall call) {
    Navigator.push(
      widget._aliceCore.getContext(),
      MaterialPageRoute(
        builder: (context) => AliceCallDetailsScreen(call, widget._aliceCore),
      ),
    );
  }

  void _showRemoveDialog() {
    AliceAlertHelper.showAlert(
      context,
      "Delete calls",
      "Do you want to delete http calls?",
      firstButtonTitle: "No",
      firstButtonAction: () => {},
      secondButtonTitle: "Yes",
      secondButtonAction: () => _removeCalls(),
    );
  }

  void _removeCalls() {
    aliceCore.removeCalls();
  }

  void _showStatsScreen() {
    Navigator.push(
      aliceCore.getContext(),
      MaterialPageRoute(
        builder: (context) => AliceStatsScreen(widget._aliceCore),
      ),
    );
  }

  void _saveToFile() async {
    aliceCore.saveHttpRequests(context);
  }
}
