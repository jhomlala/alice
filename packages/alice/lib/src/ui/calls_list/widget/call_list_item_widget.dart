import 'package:alice/src/utils/conversion_utils.dart';
import 'package:alice/src/model/alice_http_call.dart';
import 'package:alice/src/model/alice_http_response.dart';
import 'package:alice/src/model/translation.dart';
import 'package:alice/src/ui/common/context_ext.dart';
import 'package:alice/src/ui/common/theme.dart';
import 'package:material_ui/material_ui.dart';

const int _endpointMaxLines = 10;
const int _serverMaxLines = 5;

/// Widget which renders one row in calls list view. It displays general
/// information about call.
class CallListItemWidget extends StatelessWidget {
  const CallListItemWidget(this.call, this.itemClickAction, {super.key});

  final AliceHttpCall call;
  final void Function(AliceHttpCall) itemClickAction;

  @override
  Widget build(BuildContext context) {
    final Color requestColor = _getEndpointTextColor(context);
    final Color statusColor = _getStatusTextColor(context);

    return InkWell(
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
                      _EndpointAndMethod(call: call, color: requestColor),
                      const SizedBox(height: 4),
                      if (call.isReplay) ...[
                        Row(
                          children: [
                            Text(
                              context.i18n(TranslationKey.replay),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AliceAppTheme.orange,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                      ],
                      _ServerAddress(call: call),
                      const SizedBox(height: 4),
                      _ConnectionStats(call: call),
                    ],
                  ),
                ),
                _ResponseStatus(call: call, color: statusColor),
              ],
            ),
          ),
          const Divider(height: 1, color: AliceAppTheme.grey),
        ],
      ),
    );
  }

  /// Get response status text color based on response status.
  Color _getStatusTextColor(BuildContext context) => switch (call
      .response
      ?.status) {
    -1 => AliceAppTheme.red,
    int status when status < 200 =>
      Theme.of(context).textTheme.bodyLarge?.color ?? AliceAppTheme.grey,
    int status when status >= 200 && status < 300 => AliceAppTheme.green,
    int status when status >= 300 && status < 400 => AliceAppTheme.orange,
    int status when status >= 400 && status < 600 => AliceAppTheme.red,
    _ => Theme.of(context).textTheme.bodyLarge!.color ?? AliceAppTheme.grey,
  };

  /// Returns endpoint text color based on call state.
  Color _getEndpointTextColor(BuildContext context) =>
      call.loading ? AliceAppTheme.grey : _getStatusTextColor(context);
}

/// Widget which renders server address line.
class _ServerAddress extends StatelessWidget {
  final AliceHttpCall call;

  const _ServerAddress({required this.call});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 3),
          child: Icon(
            call.secure ? Icons.lock_outline : Icons.lock_open,
            color: call.secure ? AliceAppTheme.green : AliceAppTheme.red,
            size: 12,
          ),
        ),
        Expanded(
          child: Text(
            call.server,
            overflow: TextOverflow.ellipsis,
            maxLines: _serverMaxLines,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }
}

/// Widget which renders endpoint and the HTTP method line.
class _EndpointAndMethod extends StatelessWidget {
  final AliceHttpCall call;
  final Color color;

  const _EndpointAndMethod({required this.call, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(call.method, style: TextStyle(fontSize: 16, color: color)),
        const Padding(padding: EdgeInsets.only(left: 10)),
        Flexible(
          // ignore: avoid_unnecessary_containers
          child: Container(
            child: Text(
              call.endpoint,
              maxLines: _endpointMaxLines,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 16, color: color),
            ),
          ),
        ),
      ],
    );
  }
}

/// Widget which renders response status line.
class _ResponseStatus extends StatelessWidget {
  final AliceHttpCall call;
  final Color color;

  const _ResponseStatus({required this.call, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      child: Column(
        children: [
          if (call.loading) ...[
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AliceAppTheme.lightRed,
                ),
              ),
            ),
            const SizedBox(height: 4),
          ],
          if (call.response != null)
            Text(
              _getStatus(call.response!),
              style: TextStyle(fontSize: 16, color: color),
            ),
        ],
      ),
    );
  }

  /// Get status based on [response].
  String _getStatus(AliceHttpResponse response) => switch (response.status) {
    -1 => 'ERR',
    0 => '???',
    _ => '${response.status}',
  };
}

/// Widget which renders connection stats based on [call].
class _ConnectionStats extends StatelessWidget {
  final AliceHttpCall call;

  const _ConnectionStats({required this.call});

  @override
  Widget build(BuildContext context) {
    return Row(
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
            ConversionUtils.formatTime(call.duration),
            style: const TextStyle(fontSize: 12),
          ),
        ),
        Flexible(
          child: Text(
            '${ConversionUtils.formatBytes(call.request?.size ?? 0)} / '
            '${ConversionUtils.formatBytes(call.response?.size ?? 0)}',
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }

  /// Formats call time.
  String _formatTime(DateTime time) =>
      '${formatTimeUnit(time.hour)}:'
      '${formatTimeUnit(time.minute)}:'
      '${formatTimeUnit(time.second)}:'
      '${formatTimeUnit(time.millisecond)}';

  /// Format one of time units.
  String formatTimeUnit(int timeUnit) => timeUnit.toString().padLeft(2, '0');
}
