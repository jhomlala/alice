import 'package:alice/core/alice_core.dart';
import 'package:alice/utils/conversion_utils.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/translation.dart';
import 'package:alice/ui/common/context_ext.dart';
import 'package:alice/ui/common/page.dart';
import 'package:alice/ui/widget/stats_row.dart';
import 'package:alice/utils/num_comparison.dart';
import 'package:material_ui/material_ui.dart';

/// General stats page for currently caught HTTP calls.
class StatsPage extends StatelessWidget {
  final AliceCore aliceCore;

  const StatsPage(this.aliceCore, {super.key});

  @override
  Widget build(BuildContext context) {
    return BasePage(
      core: aliceCore,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '${context.i18n(TranslationKey.alice)} - '
            '${context.i18n(TranslationKey.statsTitle)}',
          ),
        ),
        body: Container(
          padding: const EdgeInsets.all(8),
          child: ListView(
            children: [
              StatsRow(
                context.i18n(TranslationKey.statsTotalRequests),
                '${_getTotalRequests()}',
              ),
              StatsRow(
                context.i18n(TranslationKey.statsPendingRequests),
                '${_getPendingRequests()}',
              ),
              StatsRow(
                context.i18n(TranslationKey.statsSuccessRequests),
                '${_getSuccessRequests()}',
              ),
              StatsRow(
                context.i18n(TranslationKey.statsRedirectionRequests),
                '${_getRedirectionRequests()}',
              ),
              StatsRow(
                context.i18n(TranslationKey.statsErrorRequests),
                '${_getErrorRequests()}',
              ),
              StatsRow(
                context.i18n(TranslationKey.statsBytesSent),
                ConversionUtils.formatBytes(_getBytesSent()),
              ),
              StatsRow(
                context.i18n(TranslationKey.statsBytesReceived),
                ConversionUtils.formatBytes(_getBytesReceived()),
              ),
              StatsRow(
                context.i18n(TranslationKey.statsAverageRequestTime),
                ConversionUtils.formatTime(_getAverageRequestTime()),
              ),
              StatsRow(
                context.i18n(TranslationKey.statsMaxRequestTime),
                ConversionUtils.formatTime(_getMaxRequestTime()),
              ),
              StatsRow(
                context.i18n(TranslationKey.statsMinRequestTime),
                ConversionUtils.formatTime(_getMinRequestTime()),
              ),
              StatsRow(
                context.i18n(TranslationKey.statsGetRequests),
                '${_getRequests('GET')} ',
              ),
              StatsRow(
                context.i18n(TranslationKey.statsPostRequests),
                '${_getRequests('POST')} ',
              ),
              StatsRow(
                context.i18n(TranslationKey.statsDeleteRequests),
                '${_getRequests('DELETE')} ',
              ),
              StatsRow(
                context.i18n(TranslationKey.statsPutRequests),
                '${_getRequests('PUT')} ',
              ),
              StatsRow(
                context.i18n(TranslationKey.statsPatchRequests),
                '${_getRequests('PATCH')} ',
              ),
              StatsRow(
                context.i18n(TranslationKey.statsSecuredRequests),
                '${_getSecuredRequests()}',
              ),
              StatsRow(
                context.i18n(TranslationKey.statsUnsecuredRequests),
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
