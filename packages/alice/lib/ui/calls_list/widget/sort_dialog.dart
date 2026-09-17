import 'package:alice/model/translation.dart';
import 'package:alice/ui/calls_list/model/calls_list_sort_option.dart';
import 'package:alice/ui/common/context_ext.dart';
import 'package:alice/ui/common/theme.dart';
import 'package:material_ui/material_ui.dart';

/// Dialog which can be used to sort alice calls.
class SortDialog extends StatelessWidget {
  final CallsListSortOption sortOption;
  final bool sortAscending;

  const SortDialog({
    super.key,
    required this.sortOption,
    required this.sortAscending,
  });

  @override
  Widget build(BuildContext context) {
    CallsListSortOption currentSortOption = sortOption;
    bool currentSortAscending = sortAscending;
    return Theme(
      data: AliceAppTheme.getTheme(),
      child: StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(context.i18n(TranslationKey.sortDialogTitle)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioGroup<CallsListSortOption>(
                    groupValue: currentSortOption,
                    onChanged: (value) {
                      setState(() {
                        if (value != null) currentSortOption = value;
                      });
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children:
                          CallsListSortOption.values
                              .map(
                                (option) =>
                                    RadioListTile<CallsListSortOption>.adaptive(
                                      title: Text(
                                        _getName(
                                          context: context,
                                          option: option,
                                        ),
                                      ),
                                      value: option,
                                    ),
                              )
                              .toList(),
                    ),
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(context.i18n(TranslationKey.sortDialogDescending)),
                      Switch(
                        value: currentSortAscending,
                        onChanged: (value) {
                          setState(() {
                            currentSortAscending = value;
                          });
                        },
                        activeThumbColor: Colors.white,
                      ),
                      Text(context.i18n(TranslationKey.sortDialogAscending)),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: Navigator.of(context).pop,
                child: Text(context.i18n(TranslationKey.sortDialogCancel)),
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
                child: Text(context.i18n(TranslationKey.sortDialogAccept)),
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
    required CallsListSortOption option,
  }) {
    return switch (option) {
      CallsListSortOption.time => context.i18n(TranslationKey.sortDialogTime),
      CallsListSortOption.responseTime => context.i18n(
        TranslationKey.sortDialogResponseTime,
      ),
      CallsListSortOption.responseCode => context.i18n(
        TranslationKey.sortDialogResponseCode,
      ),
      CallsListSortOption.responseSize => context.i18n(
        TranslationKey.sortDialogResponseSize,
      ),
      CallsListSortOption.endpoint => context.i18n(
        TranslationKey.sortDialogEndpoint,
      ),
    };
  }
}

/// Result of alice sort dialog.
class AliceSortDialogResult {
  final CallsListSortOption sortOption;
  final bool sortAscending;

  AliceSortDialogResult({
    required this.sortOption,
    required this.sortAscending,
  });
}
