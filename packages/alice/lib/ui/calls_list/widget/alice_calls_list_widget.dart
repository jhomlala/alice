import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_sort_option.dart';
import 'package:alice/ui/calls_list/widget/alice_call_list_item_widget.dart';
import 'package:alice/utils/alice_scroll_behavior.dart';
import 'package:flutter/material.dart';

class AliceCallsListWidget extends StatelessWidget {
  const AliceCallsListWidget({
    super.key,
    required this.calls,
    this.sortOption,
    this.sortAscending = false,
    required this.onListItemClicked,
  });

  final List<AliceHttpCall> calls;
  final AliceSortOption? sortOption;
  final bool sortAscending;
  final void Function(AliceHttpCall) onListItemClicked;

  List<AliceHttpCall> get _sortedCalls => switch (sortOption) {
        AliceSortOption.time => sortAscending
            ? (calls
              ..sort((AliceHttpCall call1, AliceHttpCall call2) =>
                  call1.createdTime.compareTo(call2.createdTime)))
            : (calls
              ..sort((AliceHttpCall call1, AliceHttpCall call2) =>
                  call2.createdTime.compareTo(call1.createdTime))),
        AliceSortOption.responseTime => sortAscending
            ? (calls
              ..sort()
              ..sort((AliceHttpCall call1, AliceHttpCall call2) =>
                  call1.response?.time.compareTo(call2.response!.time) ?? -1))
            : (calls
              ..sort((AliceHttpCall call1, AliceHttpCall call2) =>
                  call2.response?.time.compareTo(call1.response!.time) ?? -1)),
        AliceSortOption.responseCode => sortAscending
            ? (calls
              ..sort((AliceHttpCall call1, AliceHttpCall call2) =>
                  call1.response?.status?.compareTo(call2.response!.status!) ??
                  -1))
            : (calls
              ..sort((AliceHttpCall call1, AliceHttpCall call2) =>
                  call2.response?.status?.compareTo(call1.response!.status!) ??
                  -1)),
        AliceSortOption.responseSize => sortAscending
            ? (calls
              ..sort((AliceHttpCall call1, AliceHttpCall call2) =>
                  call1.response?.size.compareTo(call2.response!.size) ?? -1))
            : (calls
              ..sort((AliceHttpCall call1, AliceHttpCall call2) =>
                  call2.response?.size.compareTo(call1.response!.size) ?? -1)),
        AliceSortOption.endpoint => sortAscending
            ? (calls
              ..sort((AliceHttpCall call1, AliceHttpCall call2) =>
                  call1.endpoint.compareTo(call2.endpoint)))
            : (calls
              ..sort((AliceHttpCall call1, AliceHttpCall call2) =>
                  call2.endpoint.compareTo(call1.endpoint))),
        _ => calls,
      };

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: AliceScrollBehavior(),
      child: ListView.builder(
        itemCount: calls.length,
        itemBuilder: (_, int index) => AliceCallListItemWidget(
          _sortedCalls[index],
          onListItemClicked,
        ),
      ),
    );
  }
}
