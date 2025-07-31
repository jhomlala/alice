import 'package:alice/model/alice_http_call.dart';
import 'package:alice/ui/calls_list/model/alice_calls_list_sort_option.dart';
import 'package:alice/ui/calls_list/widget/alice_call_list_item_widget.dart';
import 'package:alice/ui/common/alice_scroll_behavior.dart';
import 'package:flutter/material.dart';

/// Widget which displays calls list. It's hosted in tab in calls list page.
class AliceCallsListScreen extends StatelessWidget {
  const AliceCallsListScreen({
    super.key,
    required this.calls,
    this.sortOption,
    this.sortAscending = false,
    required this.onListItemClicked,
  });

  final List<AliceHttpCall> calls;
  final AliceCallsListSortOption? sortOption;
  final bool sortAscending;
  final void Function(AliceHttpCall) onListItemClicked;

  /// Returns sorted calls based [sortOption] and [sortAscending].
  List<AliceHttpCall> get _sortedCalls => switch (sortOption) {
    AliceCallsListSortOption.time =>
      sortAscending
          ? (calls..sort(
            (AliceHttpCall call1, AliceHttpCall call2) =>
                call1.createdTime.compareTo(call2.createdTime),
          ))
          : (calls..sort(
            (AliceHttpCall call1, AliceHttpCall call2) =>
                call2.createdTime.compareTo(call1.createdTime),
          )),
    AliceCallsListSortOption.responseTime =>
      sortAscending
          ? (calls
            ..sort()
            ..sort(
              (AliceHttpCall call1, AliceHttpCall call2) =>
                  call1.response?.time.compareTo(call2.response!.time) ?? -1,
            ))
          : (calls..sort(
            (AliceHttpCall call1, AliceHttpCall call2) =>
                call2.response?.time.compareTo(call1.response!.time) ?? -1,
          )),
    AliceCallsListSortOption.responseCode =>
      sortAscending
          ? (calls..sort(
            (AliceHttpCall call1, AliceHttpCall call2) =>
                call1.response?.status?.compareTo(call2.response!.status!) ??
                -1,
          ))
          : (calls..sort(
            (AliceHttpCall call1, AliceHttpCall call2) =>
                call2.response?.status?.compareTo(call1.response!.status!) ??
                -1,
          )),
    AliceCallsListSortOption.responseSize =>
      sortAscending
          ? (calls..sort(
            (AliceHttpCall call1, AliceHttpCall call2) =>
                call1.response?.size.compareTo(call2.response!.size) ?? -1,
          ))
          : (calls..sort(
            (AliceHttpCall call1, AliceHttpCall call2) =>
                call2.response?.size.compareTo(call1.response!.size) ?? -1,
          )),
    AliceCallsListSortOption.endpoint =>
      sortAscending
          ? (calls..sort(
            (AliceHttpCall call1, AliceHttpCall call2) =>
                call1.endpoint.compareTo(call2.endpoint),
          ))
          : (calls..sort(
            (AliceHttpCall call1, AliceHttpCall call2) =>
                call2.endpoint.compareTo(call1.endpoint),
          )),
    _ => calls,
  };

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: AliceScrollBehavior(),
      child: ListView.builder(
        itemCount: calls.length,
        itemBuilder:
            (_, int index) =>
                AliceCallListItemWidget(_sortedCalls[index], onListItemClicked),
      ),
    );
  }
}
