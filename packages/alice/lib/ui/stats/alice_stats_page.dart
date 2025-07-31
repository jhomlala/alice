import 'package:alice/core/alice_core.dart';
import 'package:alice/helper/alice_conversion_helper.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_translation.dart';
import 'package:alice/ui/common/alice_context_ext.dart';
import 'package:alice/ui/common/alice_page.dart';
import 'package:alice/ui/widget/alice_stats_row.dart';
import 'package:alice/utils/num_comparison.dart';
import 'package:flutter/material.dart';

/// General stats page for currently caught HTTP calls.
class AliceStatsPage extends StatelessWidget {
  final AliceCore aliceCore;

  const AliceStatsPage(this.aliceCore, {super.key});

  @override
  Widget build(BuildContext context) {
    return AlicePage(
      core: aliceCore,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '${context.i18n(AliceTranslationKey.alice)} - '
            '${context.i18n(AliceTranslationKey.statsTitle)}',
          ),
        ),
        body: Container(
          padding: const EdgeInsets.all(8),
          child: ListView(
            children: [
              AliceStatsRow(
                context.i18n(AliceTranslationKey.statsTotalRequests),
                '${_getTotalRequests()}',
              ),
              AliceStatsRow(
                context.i18n(AliceTranslationKey.statsPendingRequests),
                '${_getPendingRequests()}',
              ),
              AliceStatsRow(
                context.i18n(AliceTranslationKey.statsSuccessRequests),
                '${_getSuccessRequests()}',
              ),
              AliceStatsRow(
                context.i18n(AliceTranslationKey.statsRedirectionRequests),
                '${_getRedirectionRequests()}',
              ),
              AliceStatsRow(
                context.i18n(AliceTranslationKey.statsErrorRequests),
                '${_getErrorRequests()}',
              ),
              AliceStatsRow(
                context.i18n(AliceTranslationKey.statsBytesSent),
                AliceConversionHelper.formatBytes(_getBytesSent()),
              ),
              AliceStatsRow(
                context.i18n(AliceTranslationKey.statsBytesReceived),
                AliceConversionHelper.formatBytes(_getBytesReceived()),
              ),
              AliceStatsRow(
                context.i18n(AliceTranslationKey.statsAverageRequestTime),
                AliceConversionHelper.formatTime(_getAverageRequestTime()),
              ),
              AliceStatsRow(
                context.i18n(AliceTranslationKey.statsMaxRequestTime),
                AliceConversionHelper.formatTime(_getMaxRequestTime()),
              ),
              AliceStatsRow(
                context.i18n(AliceTranslationKey.statsMinRequestTime),
                AliceConversionHelper.formatTime(_getMinRequestTime()),
              ),
              AliceStatsRow(
                context.i18n(AliceTranslationKey.statsGetRequests),
                '${_getRequests('GET')} ',
              ),
              AliceStatsRow(
                context.i18n(AliceTranslationKey.statsPostRequests),
                '${_getRequests('POST')} ',
              ),
              AliceStatsRow(
                context.i18n(AliceTranslationKey.statsDeleteRequests),
                '${_getRequests('DELETE')} ',
              ),
              AliceStatsRow(
                context.i18n(AliceTranslationKey.statsPutRequests),
                '${_getRequests('PUT')} ',
              ),
              AliceStatsRow(
                context.i18n(AliceTranslationKey.statsPatchRequests),
                '${_getRequests('PATCH')} ',
              ),
              AliceStatsRow(
                context.i18n(AliceTranslationKey.statsSecuredRequests),
                '${_getSecuredRequests()}',
              ),
              AliceStatsRow(
                context.i18n(AliceTranslationKey.statsUnsecuredRequests),
                '${_getUnsecuredRequests()}',
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Returns count of requests.
  int _getTotalRequests() => _calls.length;

  /// Returns count of success requests.
  int _getSuccessRequests() =>
      _calls
          .where(
            (AliceHttpCall call) =>
                (call.response?.status.gte(200) ?? false) &&
                (call.response?.status.lt(300) ?? false),
          )
          .toList()
          .length;

  /// Returns count of redirection requests.
  int _getRedirectionRequests() =>
      _calls
          .where(
            (AliceHttpCall call) =>
                (call.response?.status.gte(300) ?? false) &&
                (call.response?.status.lt(400) ?? false),
          )
          .toList()
          .length;

  /// Returns count of error requests.
  int _getErrorRequests() =>
      _calls
          .where(
            (AliceHttpCall call) =>
                (call.response?.status.gte(400) ?? false) &&
                    (call.response?.status.lt(600) ?? false) ||
                const [-1, 0].contains(call.response?.status),
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
