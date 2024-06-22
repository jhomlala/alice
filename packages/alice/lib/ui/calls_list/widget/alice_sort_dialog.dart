import 'package:alice/model/alice_sort_option.dart';
import 'package:flutter/material.dart';

class AliceSortDialog extends StatelessWidget {
  final AliceSortOption sortOption;
  final bool sortAscending;

  const AliceSortDialog({
    super.key,
    required this.sortOption,
    required this.sortAscending,
  });

  @override
  Widget build(BuildContext context) {
    AliceSortOption currentSortOption = sortOption;
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
                for (final AliceSortOption sortOption in AliceSortOption.values)
                  RadioListTile<AliceSortOption>(
                    title: Text(sortOption.name),
                    value: sortOption,
                    groupValue: currentSortOption,
                    onChanged: (AliceSortOption? value) {
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
                      value: currentSortAscending ?? false,
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
}

class AliceSortDialogResult {
  final AliceSortOption sortOption;
  final bool sortAscending;

  AliceSortDialogResult({
    required this.sortOption,
    required this.sortAscending,
  });
}
