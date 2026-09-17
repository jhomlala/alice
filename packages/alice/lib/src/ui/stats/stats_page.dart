import 'package:alice/src/core/alice_core.dart';
import 'package:alice/src/utils/conversion_utils.dart';
import 'package:alice/src/model/alice_http_call.dart';
import 'package:alice/src/model/translation.dart';
import 'package:alice/src/ui/common/context_ext.dart';
import 'package:alice/src/ui/common/page.dart';
import 'package:alice/src/ui/common/navigation.dart';
import 'package:alice/src/ui/common/theme.dart';
import 'package:alice/src/utils/num_comparison.dart';
import 'package:alice/src/ui/calls_list/widget/call_list_item_widget.dart';
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
            bottom: TabBar(
              indicatorColor: AliceAppTheme.lightRed,
              tabs: [
                Tab(text: context.i18n(TranslationKey.callDetailsOverview)),
                Tab(text: context.i18n(TranslationKey.callsListStats)),
              ],
            ),
          ),
          body: StreamBuilder<List<AliceHttpCall>>(
            stream: widget.aliceCore.callsStream,
            builder: (context, snapshot) {
              final calls = snapshot.data ?? widget.aliceCore.getCalls();
              return TabBarView(
                children: [
                  _OverviewSection(calls: calls),
                  _InsightsSection(calls: calls, aliceCore: widget.aliceCore),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _OverviewSection extends StatelessWidget {
  final List<AliceHttpCall> calls;

  const _OverviewSection({required this.calls});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _MetricsGrid(calls: calls),
        const Divider(height: 1, color: AliceAppTheme.grey),
        _RatioSection(
          title: context.i18n(TranslationKey.statsStatusDistribution),
          data: _getStatusDistribution(context, calls),
        ),
        const Divider(height: 1, color: AliceAppTheme.grey),
        _RatioSection(
          title: context.i18n(TranslationKey.statsHttpMethods),
          data: _getMethodDistribution(calls),
        ),
      ],
    );
  }

  List<_RatioData> _getStatusDistribution(
    BuildContext context,
    List<AliceHttpCall> calls,
  ) {
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
    return [
      if (success > 0)
        _RatioData(
          label: context.i18n(TranslationKey.statsStatusSuccess),
          value: success,
          color: AliceAppTheme.green,
        ),
      if (redirect > 0)
        _RatioData(
          label: context.i18n(TranslationKey.statsStatusRedirect),
          value: redirect,
          color: AliceAppTheme.orange,
        ),
      if (error > 0)
        _RatioData(
          label: context.i18n(TranslationKey.statsStatusError),
          value: error,
          color: AliceAppTheme.red,
        ),
    ];
  }

  List<_RatioData> _getMethodDistribution(List<AliceHttpCall> calls) {
    if (calls.isEmpty) return [];
    final counts = <String, int>{};
    for (final call in calls) {
      counts[call.method] = (counts[call.method] ?? 0) + 1;
    }
    return counts.entries
        .map(
          (e) => _RatioData(
            label: e.key,
            value: e.value,
            color: AliceAppTheme.grey,
          ),
        )
        .toList();
  }
}

class _MetricsGrid extends StatelessWidget {
  final List<AliceHttpCall> calls;

  const _MetricsGrid({required this.calls});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MetricText(
                  title: context.i18n(TranslationKey.statsTotalRequests),
                  value: '${calls.length}',
                ),
                const SizedBox(height: 16),
                _MetricText(
                  title: context.i18n(TranslationKey.statsTotalData),
                  value: ConversionUtils.formatBytes(
                    _getBytesSent(calls) + _getBytesReceived(calls),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MetricText(
                  title: context.i18n(TranslationKey.statsAverageRequestTime),
                  value: ConversionUtils.formatTime(
                    _getAverageRequestTime(calls),
                  ),
                ),
                const SizedBox(height: 16),
                _MetricText(
                  title: context.i18n(TranslationKey.statsPendingRequests),
                  value: '${_getPendingRequests(calls)}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _getPendingRequests(List<AliceHttpCall> calls) =>
      calls.where((c) => c.loading).length;

  int _getBytesSent(List<AliceHttpCall> calls) =>
      calls.fold(0, (sum, c) => sum + (c.request?.size ?? 0));

  int _getBytesReceived(List<AliceHttpCall> calls) =>
      calls.fold(0, (sum, c) => sum + (c.response?.size ?? 0));

  int _getAverageRequestTime(List<AliceHttpCall> calls) {
    int timeSum = 0;
    int count = 0;
    for (final c in calls) {
      if (c.duration != 0) {
        timeSum += c.duration;
        count++;
      }
    }
    return count == 0 ? 0 : timeSum ~/ count;
  }
}

class _RatioSection extends StatelessWidget {
  final String title;
  final List<_RatioData> data;

  const _RatioSection({required this.title, required this.data});

  @override
  Widget build(BuildContext context) {
    final total = data.fold(0, (sum, item) => sum + item.value);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (total == 0)
            const Text(
              'No data available',
              style: TextStyle(color: AliceAppTheme.grey),
            )
          else
            Wrap(
              spacing: 16,
              runSpacing: 4,
              children: data.map((item) {
                final percentage = (item.value / total * 100).toStringAsFixed(
                  1,
                );
                return RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 13,
                    ),
                    children: [
                      TextSpan(
                        text: '${item.label}: ',
                        style: TextStyle(
                          color: item.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
}

class _InsightsSection extends StatelessWidget {
  final List<AliceHttpCall> calls;
  final AliceCore aliceCore;

  const _InsightsSection({required this.calls, required this.aliceCore});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _InsightList(
          title: context.i18n(TranslationKey.statsTopSlowest),
          calls: _getTopSlowest(calls, 3),
          aliceCore: aliceCore,
        ),
        _InsightList(
          title: context.i18n(TranslationKey.statsRecentErrors),
          calls: _getTopErrors(calls, 3),
          aliceCore: aliceCore,
        ),
        _InsightList(
          title: context.i18n(TranslationKey.statsLargestPayloads),
          calls: _getLargestPayloads(calls, 3),
          aliceCore: aliceCore,
        ),
      ],
    );
  }

  List<AliceHttpCall> _getTopSlowest(List<AliceHttpCall> calls, int count) {
    final list = calls.where((c) => !c.loading).toList();
    list.sort((a, b) => b.duration.compareTo(a.duration));
    return list.take(count).toList();
  }

  List<AliceHttpCall> _getTopErrors(List<AliceHttpCall> calls, int count) {
    final list = calls
        .where(
          (c) =>
              (c.response?.status.gte(400) ?? false) ||
              c.error != null ||
              c.response?.status == 0 ||
              c.response?.status == -1,
        )
        .toList();
    list.sort((a, b) => b.createdTime.compareTo(a.createdTime));
    return list.take(count).toList();
  }

  List<AliceHttpCall> _getLargestPayloads(
    List<AliceHttpCall> calls,
    int count,
  ) {
    final list = calls.where((c) => c.response != null).toList();
    list.sort(
      (a, b) => (b.response?.size ?? 0).compareTo(a.response?.size ?? 0),
    );
    return list.take(count).toList();
  }
}

class _InsightList extends StatelessWidget {
  final String title;
  final List<AliceHttpCall> calls;
  final AliceCore aliceCore;

  const _InsightList({
    required this.title,
    required this.calls,
    required this.aliceCore,
  });

  @override
  Widget build(BuildContext context) {
    if (calls.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[900]
              : Colors.grey[200],
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: AliceAppTheme.grey,
            ),
          ),
        ),
        const Divider(height: 1, color: AliceAppTheme.grey),
        ...calls.map(
          (call) => CallListItemWidget(
            call,
            (call) =>
                Navigation.navigateToCallDetails(call: call, core: aliceCore),
          ),
        ),
      ],
    );
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
        Text(
          title,
          style: const TextStyle(color: AliceAppTheme.grey, fontSize: 12),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }
}

class _RatioData {
  final String label;
  final int value;
  final Color color;

  _RatioData({required this.label, required this.value, required this.color});
}
