import 'package:alice/core/alice_core.dart';
import 'package:alice/utils/conversion_utils.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/translation.dart';
import 'package:alice/ui/common/context_ext.dart';
import 'package:alice/ui/common/page.dart';
import 'package:alice/ui/common/navigation.dart';
import 'package:alice/utils/num_comparison.dart';
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
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '${context.i18n(TranslationKey.alice)} - '
            '${context.i18n(TranslationKey.statsTitle)}',
          ),
        ),
        body: StreamBuilder<List<AliceHttpCall>>(
          stream: widget.aliceCore.callsStream,
          builder: (context, snapshot) {
            final calls = snapshot.data ?? widget.aliceCore.getCalls();
            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.6,
                    children: [
                      _MetricCard(
                        title: context.i18n(TranslationKey.statsTotalRequests),
                        value: '${calls.length}',
                        icon: Icons.swap_vert,
                        color: Colors.blue,
                      ),
                      _MetricCard(
                        title: context.i18n(TranslationKey.statsAverageRequestTime),
                        value: ConversionUtils.formatTime(_getAverageRequestTime(calls)),
                        icon: Icons.timer,
                        color: Colors.orange,
                      ),
                      _MetricCard(
                        title: 'Total Data',
                        value: ConversionUtils.formatBytes(_getBytesSent(calls) + _getBytesReceived(calls)),
                        icon: Icons.data_usage,
                        color: Colors.purple,
                      ),
                      _MetricCard(
                        title: context.i18n(TranslationKey.statsPendingRequests),
                        value: '${_getPendingRequests(calls)}',
                        icon: Icons.hourglass_empty,
                        color: Colors.amber,
                      ),
                    ],
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _RatioBar(
                          title: 'Status Distribution',
                          data: _getStatusDistribution(calls),
                        ),
                        const SizedBox(height: 24),
                        _RatioBar(
                          title: 'HTTP Methods',
                          data: _getMethodDistribution(calls),
                        ),
                        const SizedBox(height: 24),
                        _InsightList(
                          title: 'Top 3 Slowest',
                          calls: _getTopSlowest(calls, 3),
                          aliceCore: widget.aliceCore,
                        ),
                        const SizedBox(height: 24),
                        _InsightList(
                          title: 'Recent Errors',
                          calls: _getTopErrors(calls, 3),
                          aliceCore: widget.aliceCore,
                        ),
                        const SizedBox(height: 24),
                        _InsightList(
                          title: 'Largest Payloads',
                          calls: _getLargestPayloads(calls, 3),
                          aliceCore: widget.aliceCore,
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
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
      if (success > 0) _RatioData('Success', success, Colors.green),
      if (redirect > 0) _RatioData('Redirect', redirect, Colors.orange),
      if (error > 0) _RatioData('Error', error, Colors.red),
    ];
  }

  List<_RatioData> _getMethodDistribution(List<AliceHttpCall> calls) {
    if (calls.isEmpty) return [];
    final counts = <String, int>{};
    for (final call in calls) {
      counts[call.method] = (counts[call.method] ?? 0) + 1;
    }

    final colors = {
      'GET': Colors.green,
      'POST': Colors.blue,
      'PUT': Colors.orange,
      'DELETE': Colors.red,
      'PATCH': Colors.purple,
    };

    return counts.entries
        .map((e) => _RatioData(e.key, e.value, colors[e.key] ?? Colors.grey))
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

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _RatioData {
  final String label;
  final int value;
  final Color color;

  _RatioData(this.label, this.value, this.color);
}

class _RatioBar extends StatelessWidget {
  final String title;
  final List<_RatioData> data;

  const _RatioBar({required this.title, required this.data});

  @override
  Widget build(BuildContext context) {
    final total = data.fold(0, (sum, item) => sum + item.value);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (total == 0)
          Text(
            'No data available',
            style: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400], fontSize: 12),
          )
        else ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 12,
              child: Row(
                children: data
                    .map((item) => Expanded(
                          flex: item.value,
                          child: Container(color: item.color),
                        ))
                    .toList(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 4,
            children: data.map((item) {
              final percentage = (item.value / total * 100).toStringAsFixed(1);
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: item.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${item.label}: $percentage%',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ],
    );
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (calls.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'No insights found',
              style: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400], fontSize: 12),
            ),
          )
        else
          ...calls.map((call) => ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: _getStatusIcon(call),
                title: Text(
                  call.endpoint,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13),
                ),
                subtitle: Text(
                  '${call.method} · ${call.duration > 0 ? ConversionUtils.formatTime(call.duration) : 'Pending'} · ${ConversionUtils.formatBytes(call.response?.size ?? 0)}',
                  style: const TextStyle(fontSize: 11),
                ),
                trailing: const Icon(Icons.chevron_right, size: 16),
                onTap: () => Navigation.navigateToCallDetails(call: call, core: aliceCore),
              )),
      ],
    );
  }

  Widget _getStatusIcon(AliceHttpCall call) {
    if (call.loading) {
      return const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2));
    }
    final status = call.response?.status;
    Color color = Colors.grey;
    if (status.gte(200) && status.lt(300)) {
      color = Colors.green;
    } else if (status.gte(300) && status.lt(400)) {
      color = Colors.orange;
    } else if (status.gte(400) || status == 0 || status == -1) {
      color = Colors.red;
    }

    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
