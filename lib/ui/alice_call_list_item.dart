import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_http_response.dart';
import 'package:flutter/material.dart';

class AliceCallListItem extends StatelessWidget {
  final AliceHttpCall call;
  final Function itemClickAction;

  const AliceCallListItem(this.call, this.itemClickAction)
      : assert(call != null, "call can't be null"),
        assert(itemClickAction != null, "itemClickAction can't be null");

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => itemClickAction(call),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMethodAndEndpointRow(),
                      const SizedBox(height: 4),
                      _buildServerRow(),
                      const SizedBox(height: 4),
                      _buildStatsRow()
                    ],
                  ),
                ),
                _buildResponseColumn(context, call)
              ],
            ),
          ),
          _buildDivider()
        ],
      ),
    );
  }

  Widget _buildMethodAndEndpointRow() {
    return Row(children: [
      Text(call.method, style: TextStyle(fontSize: 16)),
      Padding(
        padding: EdgeInsets.only(left: 10),
      ),
      Flexible(
        child: Container(
          child: Text(
            call.endpoint,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 16),
          ),
        ),
      )
    ]);
  }

  Widget _buildServerRow() {
    return Row(children: [
      _getSecuredConnectionIcon(call.secure),
      Expanded(
        child: Text(
          call.server,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: TextStyle(
            fontSize: 14,
          ),
        ),
      ),
    ]);
  }

  Widget _buildStatsRow() {
    return Row(children: [
      Text(_formatTime(call.request.time), style: TextStyle(fontSize: 12)),
      Padding(padding: EdgeInsets.only(left: 10)),
      Text("${call.duration} ms", style: TextStyle(fontSize: 12)),
      Padding(padding: EdgeInsets.only(left: 10)),
      Text("${call.request.size}B / ${call.response.size}B",
          style: TextStyle(fontSize: 12))
    ]);
  }

  Widget _buildDivider() {
    return Container(height: 1, color: Colors.grey);
  }

  String _formatTime(DateTime time) {
    assert(time != null, "time can't be null");
    return "${formatTimeUnit(time.hour)}:"
        "${formatTimeUnit(time.minute)}:"
        "${formatTimeUnit(time.second)}:"
        "${formatTimeUnit(time.millisecond)}";
  }

  String formatTimeUnit(int timeUnit) {
    assert(timeUnit != null, "timeUnit  can't be null");
    return (timeUnit < 10) ? "0$timeUnit" : "$timeUnit";
  }

  Column _buildResponseColumn(BuildContext context, AliceHttpCall call) {
    assert(context != null, "context can't be null");
    assert(call != null, "call can't be null");
    List<Widget> widgets = List();
    if (call.loading) {
      widgets.add(
        SizedBox(
          child: new CircularProgressIndicator(),
          width: 20,
          height: 20,
        ),
      );
    }
    widgets.add(
      Text(
        _getStatus(call.response),
        style: TextStyle(
          fontSize: 16,
          color: _getStatusTextColor(context, call.response.status),
        ),
      ),
    );
    return Column(children: widgets);
  }

  Color _getStatusTextColor(BuildContext context, int status) {
    assert(context != null, "context can't be null");
    assert(status != null, "status can't be null");
    if (status == -1) {
      return Colors.red;
    } else if (status < 200) {
      return Theme.of(context).textTheme.body1.color;
    } else if (status >= 200 && status < 300) {
      return Colors.green;
    } else if (status >= 300 && status < 400) {
      return Colors.orange;
    } else if (status >= 400 && status < 600) {
      return Colors.red;
    } else {
      return Theme.of(context).textTheme.body1.color;
    }
  }

  String _getStatus(AliceHttpResponse response) {
    assert(response != null, "response can't be null");
    if (response.status == -1) {
      return "ERR";
    } else if (response.status == 0) {
      return "???";
    } else {
      return "${response.status}";
    }
  }

  Widget _getSecuredConnectionIcon(bool secure) {
    IconData iconData;
    Color iconColor;
    if (secure) {
      iconData = Icons.lock_outline;
      iconColor = Colors.green;
    } else {
      iconData = Icons.lock_open;
      iconColor = Colors.red;
    }
    return Padding(
      padding: EdgeInsets.only(right: 3),
      child: Icon(
        iconData,
        color: iconColor,
        size: 12,
      ),
    );
  }
}
