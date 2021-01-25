import 'package:alice_lightweight/helper/alice_conversion_helper.dart';
import 'package:alice_lightweight/model/alice_http_call.dart';
import 'package:alice_lightweight/model/alice_http_response.dart';
import 'package:alice_lightweight/ui/utils/alice_constants.dart';
import 'package:flutter/material.dart';

class AliceCallListItemWidget extends StatelessWidget {
  final AliceHttpCall call;
  final Function itemClickAction;

  const AliceCallListItemWidget(this.call, this.itemClickAction)
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
                      _buildMethodAndEndpointRow(context),
                      const SizedBox(height: 4),
                      _buildServerRow(),
                      const SizedBox(height: 4),
                      _buildStatsRow()
                    ],
                  ),
                ),
                _buildResponseColumn(context)
              ],
            ),
          ),
          _buildDivider()
        ],
      ),
    );
  }

  Widget _buildMethodAndEndpointRow(BuildContext context) {
    Color textColor = _getEndpointTextColor(context);
    return Row(children: [
      Text(
        call.method,
        style: TextStyle(fontSize: 16, color: textColor),
      ),
      Padding(
        padding: EdgeInsets.only(left: 10),
      ),
      Flexible(
        child: Container(
          child: Text(
            call.endpoint,
            overflow: TextOverflow.visible,
            style: TextStyle(
              fontSize: 16,
              color: textColor,
            ),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
            flex: 1,
            child: Text(_formatTime(call.request.time),
                style: TextStyle(fontSize: 12))),
        Flexible(
            flex: 1,
            child: Text("${AliceConversionHelper.formatTime(call.duration)}",
                style: TextStyle(fontSize: 12))),
        Flexible(
          flex: 1,
          child: Text(
            "${AliceConversionHelper.formatBytes(call.request.size)} / "
            "${AliceConversionHelper.formatBytes(call.response.size)}",
            style: TextStyle(fontSize: 12),
          ),
        )
      ],
    );
  }

  Widget _buildDivider() {
    return Container(height: 1, color: AliceConstants.grey);
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

  Widget _buildResponseColumn(BuildContext context) {
    assert(context != null, "context can't be null");
    List<Widget> widgets = List();
    if (call.loading) {
      widgets.add(
        SizedBox(
          child: new CircularProgressIndicator(
            valueColor:
                new AlwaysStoppedAnimation<Color>(AliceConstants.lightRed),
          ),
          width: 20,
          height: 20,
        ),
      );
      widgets.add(
        const SizedBox(
          height: 4,
        ),
      );
    }
    widgets.add(
      Text(
        _getStatus(call.response),
        style: TextStyle(
          fontSize: 16,
          color: _getStatusTextColor(context),
        ),
      ),
    );
    return Container(
      width: 50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: widgets,
      ),
    );
  }

  Color _getStatusTextColor(BuildContext context) {
    assert(context != null, "context can't be null");
    int status = call.response.status;
    if (status == -1) {
      return AliceConstants.red;
    } else if (status < 200) {
      return Theme.of(context).textTheme.bodyText1.color;
    } else if (status >= 200 && status < 300) {
      return AliceConstants.green;
    } else if (status >= 300 && status < 400) {
      return AliceConstants.orange;
    } else if (status >= 400 && status < 600) {
      return AliceConstants.red;
    } else {
      return Theme.of(context).textTheme.bodyText1.color;
    }
  }

  Color _getEndpointTextColor(BuildContext context) {
    if (call.loading) {
      return AliceConstants.grey;
    } else {
      return _getStatusTextColor(context);
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
      iconColor = AliceConstants.green;
    } else {
      iconData = Icons.lock_open;
      iconColor = AliceConstants.red;
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
