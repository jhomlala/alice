import 'package:alice/model/alice_translation.dart';
import 'package:alice/ui/calls_list/model/alice_calls_list_sort_option.dart';
import 'package:alice/ui/common/alice_context_ext.dart';
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
      data: ThemeData(brightness: Brightness.light),
      child: StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(context.i18n(AliceTranslationKey.sortDialogTitle)),
            content: Wrap(
              children: [
                for (final AliceCallsListSortOption sortOption
                    in AliceCallsListSortOption.values)
                  RadioListTile<AliceCallsListSortOption>(
                    title: Text(_getName(context: context, option: sortOption)),
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
                    Text(
                      context.i18n(AliceTranslationKey.sortDialogDescending),
                    ),
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
                    Text(context.i18n(AliceTranslationKey.sortDialogAscending)),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: Navigator.of(context).pop,
                child: Text(context.i18n(AliceTranslationKey.sortDialogCancel)),
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
                child: Text(context.i18n(AliceTranslationKey.sortDialogAccept)),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Get sort option name based on [option].
  String _getName({
    required BuildContext context,
    required AliceCallsListSortOption option,
  }) {
    return switch (option) {
      AliceCallsListSortOption.time => context.i18n(
        AliceTranslationKey.sortDialogTime,
      ),
      AliceCallsListSortOption.responseTime => context.i18n(
        AliceTranslationKey.sortDialogResponseTime,
      ),
      AliceCallsListSortOption.responseCode => context.i18n(
        AliceTranslationKey.sortDialogResponseCode,
      ),
      AliceCallsListSortOption.responseSize => context.i18n(
        AliceTranslationKey.sortDialogResponseSize,
      ),
      AliceCallsListSortOption.endpoint => context.i18n(
        AliceTranslationKey.sortDialogEndpoint,
      ),
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
