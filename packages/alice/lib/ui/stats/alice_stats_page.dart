import 'package:alice/core/alice_core.dart';
import 'package:alice/helper/alice_conversion_helper.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/ui/common/alice_page.dart';
import 'package:alice/ui/widget/alice_stats_row.dart';
import 'package:alice/utils/num_comparison.dart';
import 'package:flutter/material.dart';

/// General stats page for currently caught HTTP calls.
class AliceStatsPage extends StatelessWidget {
  final AliceCore aliceCore;

  const AliceStatsPage(
    this.aliceCore, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AlicePage(
      core: aliceCore,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Alice - HTTP Inspector - Stats'),
        ),
        body: Container(
          padding: const EdgeInsets.all(8),
          child: ListView(
            children: [
              AliceStatsRow('Total requests:', '${_getTotalRequests()}'),
              AliceStatsRow('Pending requests:', '${_getPendingRequests()}'),
              AliceStatsRow('Success requests:', '${_getSuccessRequests()}'),
              AliceStatsRow(
                'Redirection requests:',
                '${_getRedirectionRequests()}',
              ),
              AliceStatsRow('Error requests:', '${_getErrorRequests()}'),
              AliceStatsRow(
                'Bytes send:',
                AliceConversionHelper.formatBytes(_getBytesSent()),
              ),
              AliceStatsRow(
                'Bytes received:',
                AliceConversionHelper.formatBytes(_getBytesReceived()),
              ),
              AliceStatsRow(
                'Average request time:',
                AliceConversionHelper.formatTime(_getAverageRequestTime()),
              ),
              AliceStatsRow(
                'Max request time:',
                AliceConversionHelper.formatTime(_getMaxRequestTime()),
              ),
              AliceStatsRow(
                'Min request time:',
                AliceConversionHelper.formatTime(_getMinRequestTime()),
              ),
              AliceStatsRow('Get requests:', '${_getRequests('GET')} '),
              AliceStatsRow('Post requests:', '${_getRequests('POST')} '),
              AliceStatsRow('Delete requests:', '${_getRequests('DELETE')} '),
              AliceStatsRow('Put requests:', '${_getRequests('PUT')} '),
              AliceStatsRow('Patch requests:', '${_getRequests('PATCH')} '),
              AliceStatsRow('Secured requests:', '${_getSecuredRequests()}'),
              AliceStatsRow(
                  'Unsecured requests:', '${_getUnsecuredRequests()}'),
            ],
          ),
        ),
      ),
    );
  }

  /// Returns count of requests.
  int _getTotalRequests() => _calls.length;

  /// Returns count of success requests.
  int _getSuccessRequests() => _calls
      .where(
        (AliceHttpCall call) =>
            (call.response?.status.gte(200) ?? false) &&
            (call.response?.status.lt(300) ?? false),
      )
      .toList()
      .length;

  /// Returns count of redirection requests.
  int _getRedirectionRequests() => _calls
      .where(
        (AliceHttpCall call) =>
            (call.response?.status.gte(300) ?? false) &&
            (call.response?.status.lt(400) ?? false),
      )
      .toList()
      .length;

  /// Returns count of error requests.
  int _getErrorRequests() => _calls
      .where(
        (AliceHttpCall call) =>
            (call.response?.status.gte(400) ?? false) &&
            (call.response?.status.lt(600) ?? false),
      )
      .toList()
      .length;

  /// Returns count of pending requests.
  int _getPendingRequests() =>
      _calls.where((AliceHttpCall call) => call.loading).toList().length;

  /// Returns total bytes sent count.
  int _getBytesSent() => _calls.fold(
        0,
        (int sum, AliceHttpCall call) => sum + (call.request?.size ?? 0),
      );

  /// Returns total bytes received count.
  int _getBytesReceived() => _calls.fold(
        0,
        (int sum, AliceHttpCall call) => sum + (call.response?.size ?? 0),
      );

  /// Returns average request time of all calls.
  int _getAverageRequestTime() {
    int requestTimeSum = 0;
    int requestsWithDurationCount = 0;
    for (final AliceHttpCall call in _calls) {
      if (call.duration != 0) {
        requestTimeSum = call.duration;
        requestsWithDurationCount++;
      }
    }
    if (requestTimeSum == 0) {
      return 0;
    }
    return requestTimeSum ~/ requestsWithDurationCount;
  }

  /// Returns max request time of all calls.
  int _getMaxRequestTime() {
    int maxRequestTime = 0;
    for (final AliceHttpCall call in _calls) {
      if (call.duration > maxRequestTime) {
        maxRequestTime = call.duration;
      }
    }
    return maxRequestTime;
  }

  /// Returns min request time of all calls.
  int _getMinRequestTime() {
    int minRequestTime = 10000000;
    if (_calls.isEmpty) {
      minRequestTime = 0;
    } else {
      for (final AliceHttpCall call in _calls) {
        if (call.duration != 0 && call.duration < minRequestTime) {
          minRequestTime = call.duration;
        }
      }
    }
    return minRequestTime;
  }

  /// Get all requests with [requestType].
  int _getRequests(String requestType) =>
      _calls.where((call) => call.method == requestType).toList().length;

  /// Get all secured requests count.
  int _getSecuredRequests() =>
      _calls.where((call) => call.secure).toList().length;

  /// Get unsecured requests count.
  int _getUnsecuredRequests() =>
      _calls.where((call) => !call.secure).toList().length;

  /// Get all calls from Alice.
  List<AliceHttpCall> get _calls => aliceCore.getCalls();
}
