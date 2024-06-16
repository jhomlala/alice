import 'package:alice/helper/alice_conversion_helper.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_http_response.dart';
import 'package:alice/utils/alice_constants.dart';
import 'package:flutter/material.dart';

const int _endpointMaxLines = 10;
const int _serverMaxLines = 5;

class AliceCallListItemWidget extends StatelessWidget {
  final AliceHttpCall call;
  final void Function(AliceHttpCall) itemClickAction;

  const AliceCallListItemWidget(this.call, this.itemClickAction, {super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // ignore: avoid_dynamic_calls
      onTap: () => itemClickAction.call(call),
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
                      _buildStatsRow(),
                    ],
                  ),
                ),
                _buildResponseColumn(context),
              ],
            ),
          ),
          _buildDivider(),
        ],
      ),
    );
  }

  Widget _buildMethodAndEndpointRow(BuildContext context) {
    final Color? textColor = _getEndpointTextColor(context);

    return Row(
      children: [
        Text(
          call.method,
          style: TextStyle(fontSize: 16, color: textColor),
        ),
        const Padding(
          padding: EdgeInsets.only(left: 10),
        ),
        Flexible(
          // ignore: avoid_unnecessary_containers
          child: Container(
            child: Text(
              call.endpoint,
              maxLines: _endpointMaxLines,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16,
                color: textColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServerRow() => Row(
        children: [
          _getSecuredConnectionIcon(call.secure),
          Expanded(
            child: Text(
              call.server,
              overflow: TextOverflow.ellipsis,
              maxLines: _serverMaxLines,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ],
      );

  Widget _buildStatsRow() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              call.request?.time != null
                  ? _formatTime(call.request!.time)
                  : 'n/a',
              style: const TextStyle(fontSize: 12),
            ),
          ),
          Flexible(
            child: Text(
              AliceConversionHelper.formatTime(call.duration),
              style: const TextStyle(fontSize: 12),
            ),
          ),
          Flexible(
            child: Text(
              '${AliceConversionHelper.formatBytes(call.request?.size ?? 0)} / '
              '${AliceConversionHelper.formatBytes(call.response?.size ?? 0)}',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      );

  Widget _buildDivider() => Container(height: 1, color: AliceConstants.grey);

  String _formatTime(DateTime time) => '${formatTimeUnit(time.hour)}:'
      '${formatTimeUnit(time.minute)}:'
      '${formatTimeUnit(time.second)}:'
      '${formatTimeUnit(time.millisecond)}';

  String formatTimeUnit(int timeUnit) =>
      (timeUnit < 10) ? '0$timeUnit' : '$timeUnit';

  Widget _buildResponseColumn(BuildContext context) {
    final List<Widget> widgets = [];

    if (call.loading) {
      widgets.addAll([
        const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AliceConstants.lightRed),
          ),
        ),
        const SizedBox(height: 4),
      ]);
    }

    if (call.response != null) {
      widgets.add(
        Text(
          _getStatus(call.response!),
          style: TextStyle(
            fontSize: 16,
            color: _getStatusTextColor(context),
          ),
        ),
      );
    }

    return SizedBox(
      width: 50,
      child: Column(
        children: widgets,
      ),
    );
  }

  Color? _getStatusTextColor(BuildContext context) =>
      switch (call.response?.status) {
        -1 => AliceConstants.red,
        int status when status < 200 =>
          Theme.of(context).textTheme.bodyLarge?.color,
        int status when status >= 200 && status < 300 => AliceConstants.green,
        int status when status >= 300 && status < 400 => AliceConstants.orange,
        int status when status >= 400 && status < 600 => AliceConstants.red,
        _ => Theme.of(context).textTheme.bodyLarge?.color,
      };

  Color? _getEndpointTextColor(BuildContext context) {
    if (call.loading) {
      return AliceConstants.grey;
    } else {
      return _getStatusTextColor(context);
    }
  }

  String _getStatus(AliceHttpResponse response) => switch (response.status) {
        -1 => 'ERR',
        0 => '???',
        _ => '${response.status}',
      };

  Widget _getSecuredConnectionIcon(bool secure) {
    late final IconData iconData;
    late final Color iconColor;

    if (secure) {
      iconData = Icons.lock_outline;
      iconColor = AliceConstants.green;
    } else {
      iconData = Icons.lock_open;
      iconColor = AliceConstants.red;
    }

    return Padding(
      padding: const EdgeInsets.only(right: 3),
      child: Icon(
        iconData,
        color: iconColor,
        size: 12,
      ),
    );
  }
}
