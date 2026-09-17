import 'package:alice/core/alice_core.dart';
import 'package:alice/utils/conversion_utils.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/translation.dart';
import 'package:alice/ui/common/context_ext.dart';
import 'package:alice/ui/common/page.dart';
import 'package:alice/ui/common/navigation.dart';
import 'package:alice/ui/common/theme.dart';
import 'package:alice/utils/num_comparison.dart';
import 'package:alice/ui/calls_list/widget/call_list_item_widget.dart';
import 'package:material_ui/material_ui.dart';

/// General stats page for currently caught HTTP calls.
class StatsPage extends StatefulWidget {
  final AliceCore aliceCore;

  const StatsPage(this.aliceCore, {super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  @override
  Widget build(BuildContext context) {
    return BasePage(
      core: widget.aliceCore,
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              '${context.i18n(TranslationKey.alice)} - '
              '${context.i18n(TranslationKey.statsTitle)}',
            ),
            bottom: const TabBar(
              indicatorColor: AliceAppTheme.lightRed,
              tabs: [
                Tab(text: 'Overview'),
                Tab(text: 'Insights'),
              ],
            ),
          ),
        body: StreamBuilder<List<AliceHttpCall>>(
          stream: widget.aliceCore.callsStream,
          builder: (context, snapshot) {
            final calls = snapshot.data ?? widget.aliceCore.getCalls();
            return TabBarView(
              children: [
                ListView(
                  children: [
                    _buildMetricsTable(context, calls),
                    const Divider(height: 1, color: AliceAppTheme.grey),
                    _buildRatios(context, 'Status Distribution', _getStatusDistribution(calls)),
                    const Divider(height: 1, color: AliceAppTheme.grey),
                    _buildRatios(context, 'HTTP Methods', _getMethodDistribution(calls)),
                  ],
                ),
                ListView(
                  children: [
                    _buildInsightSection(context, 'Top 3 Slowest', _getTopSlowest(calls, 3)),
                    _buildInsightSection(context, 'Recent Errors', _getTopErrors(calls, 3)),
                    _buildInsightSection(context, 'Largest Payloads', _getLargestPayloads(calls, 3)),
                  ],
                ),
              ],
            );
          },
        ),
        ),
      ),
    );
  }

  Widget _buildMetricsTable(BuildContext context, List<AliceHttpCall> calls) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MetricText(title: context.i18n(TranslationKey.statsTotalRequests), value: '${calls.length}'),
                const SizedBox(height: 16),
                _MetricText(title: 'Total Data', value: ConversionUtils.formatBytes(_getBytesSent(calls) + _getBytesReceived(calls))),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MetricText(title: context.i18n(TranslationKey.statsAverageRequestTime), value: ConversionUtils.formatTime(_getAverageRequestTime(calls))),
                const SizedBox(height: 16),
                _MetricText(title: context.i18n(TranslationKey.statsPendingRequests), value: '${_getPendingRequests(calls)}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatios(BuildContext context, String title, List<_RatioData> data) {
    final total = data.fold(0, (sum, item) => sum + item.value);
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (total == 0)
            const Text('No data available', style: TextStyle(color: AliceAppTheme.grey))
          else
            Wrap(
              spacing: 16,
              runSpacing: 4,
              children: data.map((item) {
                final percentage = (item.value / total * 100).toStringAsFixed(1);
                return RichText(
                  text: TextSpan(
                    style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 13),
                    children: [
                      TextSpan(text: '${item.label}: ', style: TextStyle(color: item.color, fontWeight: FontWeight.bold)),
                      TextSpan(text: '$percentage% (${item.value})'),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildInsightSection(BuildContext context, String title, List<AliceHttpCall> calls) {
    if (calls.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[900] : Colors.grey[200],
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AliceAppTheme.grey)),
        ),
        const Divider(height: 1, color: AliceAppTheme.grey),
        ...calls.map((call) => CallListItemWidget(
              call,
              (call) => Navigation.navigateToCallDetails(call: call, core: widget.aliceCore),
            )),
      ],
    );
  }

  int _getPendingRequests(List<AliceHttpCall> calls) =>
      calls.where((call) => call.loading).length;

  int _getBytesSent(List<AliceHttpCall> calls) => calls.fold(
        0,
        (sum, call) => sum + (call.request?.size ?? 0),
      );

  int _getBytesReceived(List<AliceHttpCall> calls) => calls.fold(
        0,
        (sum, call) => sum + (call.response?.size ?? 0),
      );

  int _getAverageRequestTime(List<AliceHttpCall> calls) {
    int requestTimeSum = 0;
    int requestsWithDurationCount = 0;
    for (final call in calls) {
      if (call.duration != 0) {
        requestTimeSum += call.duration;
        requestsWithDurationCount++;
      }
    }
    return requestsWithDurationCount == 0 ? 0 : requestTimeSum ~/ requestsWithDurationCount;
  }

  List<_RatioData> _getStatusDistribution(List<AliceHttpCall> calls) {
    if (calls.isEmpty) return [];
    int success = 0;
    int redirect = 0;
    int error = 0;

    for (final call in calls) {
      if (call.loading) continue;
      final status = call.response?.status;
      if (status.gte(200) && status.lt(300)) {
        success++;
      } else if (status.gte(300) && status.lt(400)) {
        redirect++;
      } else if (status.gte(400) || status == 0 || status == -1) {
        error++;
      }
    }

    final total = success + redirect + error;
    if (total == 0) return [];

    return [
      if (success > 0) _RatioData('Success', success, AliceAppTheme.green),
      if (redirect > 0) _RatioData('Redirect', redirect, AliceAppTheme.orange),
      if (error > 0) _RatioData('Error', error, AliceAppTheme.red),
    ];
  }

  List<_RatioData> _getMethodDistribution(List<AliceHttpCall> calls) {
    if (calls.isEmpty) return [];
    final counts = <String, int>{};
    for (final call in calls) {
      counts[call.method] = (counts[call.method] ?? 0) + 1;
    }

    final colors = {
      'GET': AliceAppTheme.green,
      'POST': Colors.blue,
      'PUT': AliceAppTheme.orange,
      'DELETE': AliceAppTheme.red,
      'PATCH': Colors.purple,
    };

    return counts.entries
        .map((e) => _RatioData(e.key, e.value, colors[e.key] ?? AliceAppTheme.grey))
        .toList();
  }

  List<AliceHttpCall> _getTopSlowest(List<AliceHttpCall> calls, int count) {
    final list = calls.where((c) => !c.loading).toList();
    list.sort((a, b) => b.duration.compareTo(a.duration));
    return list.take(count).toList();
  }

  List<AliceHttpCall> _getTopErrors(List<AliceHttpCall> calls, int count) {
    final list = calls
        .where((c) => (c.response?.status.gte(400) ?? false) || c.error != null || c.response?.status == 0 || c.response?.status == -1)
        .toList();
    // Sort by createdTime descending for "Recent"
    list.sort((a, b) => b.createdTime.compareTo(a.createdTime));
    return list.take(count).toList();
  }

  List<AliceHttpCall> _getLargestPayloads(List<AliceHttpCall> calls, int count) {
    final list = calls.where((c) => c.response != null).toList();
    list.sort((a, b) => (b.response?.size ?? 0).compareTo(a.response?.size ?? 0));
    return list.take(count).toList();
  }
}

class _MetricText extends StatelessWidget {
  final String title;
  final String value;
  
  const _MetricText({required this.title, required this.value});
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: AliceAppTheme.grey, fontSize: 12)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }
}

class _RatioData {
  final String label;
  final int value;
  final Color color;

  _RatioData(this.label, this.value, this.color);
}
