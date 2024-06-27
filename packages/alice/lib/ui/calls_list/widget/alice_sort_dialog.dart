import 'package:alice/ui/calls_list/model/alice_calls_list_sort_option.dart';
import 'package:flutter/material.dart';

/// Dialog which can be used to sort alice calls.
class AliceSortDialog extends StatelessWidget {
  final AliceCallsListSortOption sortOption;
  final bool sortAscending;

  const AliceSortDialog({
    super.key,
    required this.sortOption,
    required this.sortAscending,
  });

  @override
  Widget build(BuildContext context) {
    AliceCallsListSortOption currentSortOption = sortOption;
    bool currentSortAscending = sortAscending;
    return Theme(
      data: ThemeData(
        brightness: Brightness.light,
      ),
      child: StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Select filter'),
            content: Wrap(
              children: [
                for (final AliceCallsListSortOption sortOption
                    in AliceCallsListSortOption.values)
                  RadioListTile<AliceCallsListSortOption>(
                    title: Text(_getName(
                      option: sortOption,
                    )),
                    value: sortOption,
                    groupValue: currentSortOption,
                    onChanged: (AliceCallsListSortOption? value) {
                      if (value != null) {
                        setState(() {
                          currentSortOption = value;
                        });
                      }
                    },
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Descending'),
                    Switch(
                      value: currentSortAscending,
                      onChanged: (value) {
                        setState(() {
                          currentSortAscending = value;
                        });
                      },
                      activeTrackColor: Colors.grey,
                      activeColor: Colors.white,
                    ),
                    const Text('Ascending'),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: Navigator.of(context).pop,
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(
                    AliceSortDialogResult(
                      sortOption: currentSortOption,
                      sortAscending: currentSortAscending,
                    ),
                  );
                },
                child: const Text('Use filter'),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Get sort option name based on [option].
  String _getName({required AliceCallsListSortOption option}) {
    return switch (option) {
      AliceCallsListSortOption.time => 'Create time (default)',
      AliceCallsListSortOption.responseTime => 'Response time',
      AliceCallsListSortOption.responseCode => 'Response code',
      AliceCallsListSortOption.responseSize => 'Response size',
      AliceCallsListSortOption.endpoint => 'Endpoint',
    };
  }
}

/// Result of alice sort dialog.
class AliceSortDialogResult {
  final AliceCallsListSortOption sortOption;
  final bool sortAscending;

  AliceSortDialogResult({
    required this.sortOption,
    required this.sortAscending,
  });
}
