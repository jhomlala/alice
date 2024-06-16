import 'package:alice/core/alice_core.dart';
import 'package:alice/helper/alice_conversion_helper.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/ui/widget/alice_stats_row.dart';
import 'package:alice/utils/alice_theme.dart';
import 'package:flutter/material.dart';

class AliceStatsScreen extends StatelessWidget {
  final AliceCore aliceCore;

  const AliceStatsScreen(
    this.aliceCore, {
    super.key,
  });

  int _getTotalRequests() => calls.length;

  int _getSuccessRequests() => calls
      .where(
        (AliceHttpCall call) =>
            call.response != null &&
            call.response!.status! >= 200 &&
            call.response!.status! < 300,
      )
      .toList()
      .length;

  int _getRedirectionRequests() => calls
      .where(
        (AliceHttpCall call) =>
            call.response != null &&
            call.response!.status! >= 300 &&
            call.response!.status! < 400,
      )
      .toList()
      .length;

  int _getErrorRequests() => calls
      .where(
        (AliceHttpCall call) =>
            call.response != null &&
            call.response!.status! >= 400 &&
            call.response!.status! < 600,
      )
      .toList()
      .length;

  int _getPendingRequests() =>
      calls.where((AliceHttpCall call) => call.loading).toList().length;

  int _getBytesSent() => calls.fold(
        0,
        (int sum, AliceHttpCall call) => sum + (call.request?.size ?? 0),
      );

  int _getBytesReceived() => calls.fold(
        0,
        (int sum, AliceHttpCall call) => sum + (call.response?.size ?? 0),
      );

  int _getAverageRequestTime() {
    int requestTimeSum = 0;
    int requestsWithDurationCount = 0;
    for (final AliceHttpCall call in calls) {
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

  int _getMaxRequestTime() {
    int maxRequestTime = 0;
    for (final AliceHttpCall call in calls) {
      if (call.duration > maxRequestTime) {
        maxRequestTime = call.duration;
      }
    }
    return maxRequestTime;
  }

  int _getMinRequestTime() {
    int minRequestTime = 10000000;
    if (calls.isEmpty) {
      minRequestTime = 0;
    } else {
      for (final AliceHttpCall call in calls) {
        if (call.duration != 0 && call.duration < minRequestTime) {
          minRequestTime = call.duration;
        }
      }
    }
    return minRequestTime;
  }

  int _getRequests(String requestType) =>
      calls.where((call) => call.method == requestType).toList().length;

  int _getSecuredRequests() =>
      calls.where((call) => call.secure).toList().length;

  int _getUnsecuredRequests() =>
      calls.where((call) => !call.secure).toList().length;

  List<AliceHttpCall> get calls => aliceCore.callsSubject.value;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: aliceCore.directionality ?? Directionality.of(context),
      child: Theme(
        data: ThemeData(colorScheme: AliceTheme.getColorScheme()),
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
      ),
    );
  }
}
