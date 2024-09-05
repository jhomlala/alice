// ignore_for_file: use_build_context_synchronously

import 'package:alice/core/alice_core.dart';
import 'package:alice/helper/operating_system.dart';
import 'package:alice/model/alice_export_result.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_translation.dart';
import 'package:alice/ui/call_details/model/alice_menu_item.dart';
import 'package:alice/ui/calls_list/model/alice_calls_list_sort_option.dart';
import 'package:alice/ui/calls_list/model/alice_calls_list_tab_item.dart';
import 'package:alice/ui/calls_list/widget/alice_inspector_screen.dart';
import 'package:alice/ui/calls_list/widget/alice_sort_dialog.dart';
import 'package:alice/ui/common/alice_context_ext.dart';
import 'package:alice/ui/common/alice_dialog.dart';
import 'package:alice/ui/common/alice_navigation.dart';
import 'package:alice/ui/common/alice_page.dart';
import 'package:alice/ui/calls_list/widget/alice_logs_screen.dart';
import 'package:alice/ui/common/alice_theme.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';

/// Page which displays list of calls caught by Alice. It displays tab view
/// where calls and logs can be inspected. It allows to sort calls, delete calls
/// and search calls.
class AliceCallsListPage extends StatefulWidget {
  final AliceCore core;

  const AliceCallsListPage({
    required this.core,
    super.key,
  });

  @override
  State<AliceCallsListPage> createState() => _AliceCallsListPageState();
}

class _AliceCallsListPageState extends State<AliceCallsListPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _queryTextEditingController =
      TextEditingController();
  final List<AliceCallsListTabItem> _tabItems = AliceCallsListTabItem.values;
  final ScrollController _scrollController = ScrollController();
  late final TabController? _tabController;

  AliceCallsListSortOption _sortOption = AliceCallsListSortOption.time;
  bool _sortAscending = false;
  bool _searchEnabled = false;
  bool isAndroidRawLogsEnabled = false;
  int _selectedIndex = 0;

  AliceCore get aliceCore => widget.core;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      vsync: this,
      length: _tabItems.length,
      initialIndex: _tabItems.first.index,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tabController?.addListener(() {
        _onTabChanged(_tabController!.index);
      });
    });
  }

  @override
  void dispose() {
    _queryTextEditingController.dispose();
    _tabController?.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  /// Returns [true] when logger tab is opened.
  bool get isLoggerTab => _selectedIndex == 1;

  @override
  Widget build(BuildContext context) {
    return AlicePage(
      core: aliceCore,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _onBackPressed,
          ),
          title: _searchEnabled
              ? _SearchTextField(
                  textEditingController: _queryTextEditingController,
                  onChanged: _updateSearchQuery,
                )
              : Text(
                  context.i18n(
                    AliceTranslationKey.alice,
                  ),
                ),
          actions: isLoggerTab
              ? <Widget>[
                  IconButton(
                    icon: const Icon(Icons.terminal),
                    onPressed: _onLogsChangePressed,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: _onClearLogsPressed,
                  ),
                ]
              : <Widget>[
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: _onSearchPressed,
                  ),
                  _ContextMenuButton(
                    onMenuItemSelected: _onMenuItemSelected,
                  ),
                ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AliceTheme.lightRed,
            tabs: AliceCallsListTabItem.values.map((item) {
              return Tab(text: _getTabName(item: item));
            }).toList(),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            AliceInspectorScreen(
              aliceCore: aliceCore,
              queryTextEditingController: _queryTextEditingController,
              sortOption: _sortOption,
              sortAscending: _sortAscending,
              onListItemPressed: _onListItemPressed,
            ),
            AliceLogsScreen(
              scrollController: _scrollController,
              aliceLogger: widget.core.configuration.aliceLogger,
              isAndroidRawLogsEnabled: isAndroidRawLogsEnabled,
            ),
          ],
        ),
        floatingActionButton: isLoggerTab
            ? _LoggerFloatingActionButtons(
                scrollLogsList: _scrollLogsList,
              )
            : const SizedBox(),
      ),
    );
  }

  /// Get tab name based on [item] type.
  String _getTabName({required AliceCallsListTabItem item}) {
    switch (item) {
      case AliceCallsListTabItem.inspector:
        return context.i18n(AliceTranslationKey.callsListInspector);
      case AliceCallsListTabItem.logger:
        return context.i18n(AliceTranslationKey.callsListLogger);
    }
  }

  /// Called when back button has been pressed. It navigates back to original
  /// application.
  void _onBackPressed() {
    Navigator.of(context, rootNavigator: true).pop();
  }

  /// Called when clear logs has been pressed. It displays dialog and awaits for
  /// user confirmation.
  void _onClearLogsPressed() => AliceGeneralDialog.show(
        context: context,
        title: context.i18n(AliceTranslationKey.callsListDeleteLogsDialogTitle),
        description: context
            .i18n(AliceTranslationKey.callsListDeleteLogsDialogDescription),
        firstButtonTitle: context.i18n(AliceTranslationKey.callsListNo),
        secondButtonTitle: context.i18n(AliceTranslationKey.callsListYes),
        secondButtonAction: _onLogsClearPressed,
      );

  /// Called when logs type mode pressed.
  void _onLogsChangePressed() => setState(() {
        isAndroidRawLogsEnabled = !isAndroidRawLogsEnabled;
      });

  /// Called when logs clear button has been pressed.
  void _onLogsClearPressed() => setState(() {
        if (isAndroidRawLogsEnabled) {
          widget.core.configuration.aliceLogger.clearAndroidRawLogs();
        } else {
          widget.core.configuration.aliceLogger.clearLogs();
        }
      });

  /// Called when search button. It displays search text field.
  void _onSearchPressed() => setState(() {
        _searchEnabled = !_searchEnabled;
        if (!_searchEnabled) {
          _queryTextEditingController.text = '';
        }
      });

  /// Called on tab has been changed.
  void _onTabChanged(int index) => setState(
        () {
          _selectedIndex = index;
          if (_selectedIndex == 1) {
            _searchEnabled = false;
            _queryTextEditingController.text = '';
          }
        },
      );

  /// Called when menu item from overflow menu has been pressed.
  void _onMenuItemSelected(AliceCallDetailsMenuItemType menuItem) {
    switch (menuItem) {
      case AliceCallDetailsMenuItemType.sort:
        _onSortPressed();
      case AliceCallDetailsMenuItemType.delete:
        _onRemovePressed();
      case AliceCallDetailsMenuItemType.stats:
        _onStatsPressed();
      case AliceCallDetailsMenuItemType.save:
        _saveToFile();
    }
  }

  /// Called when item from the list has been pressed. It opens details page.
  void _onListItemPressed(AliceHttpCall call) =>
      AliceNavigation.navigateToCallDetails(call: call, core: aliceCore);

  /// Called when remove all calls button has been pressed.
  void _onRemovePressed() => AliceGeneralDialog.show(
        context: context,
        title:
            context.i18n(AliceTranslationKey.callsListDeleteCallsDialogTitle),
        description: context
            .i18n(AliceTranslationKey.callsListDeleteCallsDialogDescription),
        firstButtonTitle: context.i18n(AliceTranslationKey.callsListNo),
        firstButtonAction: () => <String, dynamic>{},
        secondButtonTitle: context.i18n(AliceTranslationKey.callsListYes),
        secondButtonAction: _removeCalls,
      );

  /// Removes all calls from Alice.
  void _removeCalls() => aliceCore.removeCalls();

  /// Called when stats button has been pressed. Navigates to stats page.
  void _onStatsPressed() {
    AliceNavigation.navigateToStats(core: aliceCore);
  }

  /// Called when save to file has been pressed. It saves data to file.
  void _saveToFile() async {
    final result = await aliceCore.saveCallsToFile(context);
    if (result.success) {
      AliceGeneralDialog.show(
        context: context,
        title: context.i18n(AliceTranslationKey.saveSuccessTitle),
        description: context
            .i18n(AliceTranslationKey.saveSuccessDescription)
            .replaceAll("[path]", result.path!),
        secondButtonTitle: OperatingSystem.isAndroid
            ? context.i18n(AliceTranslationKey.saveSuccessView)
            : null,
        secondButtonAction: () =>
            OperatingSystem.isAndroid && result.path != null
                ? OpenFilex.open(result.path!)
                : null,
      );
    } else {
      final [String title, String description] = switch (result.error) {
        AliceExportResultError.logGenerate => [
            context.i18n(AliceTranslationKey.saveDialogPermissionErrorTitle),
            context
                .i18n(AliceTranslationKey.saveDialogPermissionErrorDescription),
          ],
        AliceExportResultError.empty => [
            context.i18n(AliceTranslationKey.saveDialogEmptyErrorTitle),
            context.i18n(AliceTranslationKey.saveDialogEmptyErrorDescription),
          ],
        AliceExportResultError.permission => [
            context.i18n(AliceTranslationKey.saveDialogPermissionErrorTitle),
            context
                .i18n(AliceTranslationKey.saveDialogPermissionErrorDescription),
          ],
        AliceExportResultError.file => [
            context.i18n(AliceTranslationKey.saveDialogFileSaveErrorTitle),
            context
                .i18n(AliceTranslationKey.saveDialogFileSaveErrorDescription),
          ],
        _ => ["", ""],
      };

      AliceGeneralDialog.show(
        context: context,
        title: title,
        description: description,
      );
    }
  }

  /// Filters calls based on query.
  void _updateSearchQuery(String query) => setState(() {});

  /// Called when sort button has been pressed. It opens dialog where filters
  /// can be picked.
  Future<void> _onSortPressed() async {
    AliceSortDialogResult? result = await showDialog<AliceSortDialogResult>(
      context: context,
      builder: (BuildContext buildContext) => AliceSortDialog(
        sortOption: _sortOption,
        sortAscending: _sortAscending,
      ),
    );
    if (result != null) {
      setState(() {
        _sortOption = result.sortOption;
        _sortAscending = result.sortAscending;
      });
    }
  }

  /// Scrolls logs list based on [top] parameter.
  void _scrollLogsList(bool top) => top ? _scrollToTop() : _scrollToBottom();

  /// Scrolls logs list to the top.
  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: const Duration(microseconds: 500),
        curve: Curves.ease,
      );
    }
  }

  /// Scrolls logs list to the bottom.
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(microseconds: 500),
        curve: Curves.ease,
      );
    }
  }
}

/// Text field displayed in app bar. Used to search call logs.
class _SearchTextField extends StatelessWidget {
  const _SearchTextField({
    required this.textEditingController,
    required this.onChanged,
  });

  final TextEditingController textEditingController;
  final void Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: textEditingController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: context.i18n(AliceTranslationKey.callsListSearchHint),
        hintStyle: const TextStyle(fontSize: 16, color: AliceTheme.grey),
        border: InputBorder.none,
      ),
      style: const TextStyle(fontSize: 16),
      onChanged: onChanged,
    );
  }
}

/// Menu button displayed in app bar. It displays overflow menu with additional
/// actions.
class _ContextMenuButton extends StatelessWidget {
  const _ContextMenuButton({required this.onMenuItemSelected});

  final void Function(AliceCallDetailsMenuItemType) onMenuItemSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<AliceCallDetailsMenuItemType>(
      onSelected: onMenuItemSelected,
      itemBuilder: (BuildContext context) => [
        for (final AliceCallDetailsMenuItemType item
            in AliceCallDetailsMenuItemType.values)
          PopupMenuItem<AliceCallDetailsMenuItemType>(
            value: item,
            child: Row(
              children: [
                Icon(
                  _getIcon(itemType: item),
                  color: AliceTheme.lightRed,
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 10),
                ),
                Text(
                  _getTitle(
                    context: context,
                    itemType: item,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// Get title of the menu item based on [itemType].
  String _getTitle({
    required BuildContext context,
    required AliceCallDetailsMenuItemType itemType,
  }) {
    switch (itemType) {
      case AliceCallDetailsMenuItemType.sort:
        return context.i18n(AliceTranslationKey.callsListSort);
      case AliceCallDetailsMenuItemType.delete:
        return context.i18n(AliceTranslationKey.callsListDelete);
      case AliceCallDetailsMenuItemType.stats:
        return context.i18n(AliceTranslationKey.callsListStats);
      case AliceCallDetailsMenuItemType.save:
        return context.i18n(AliceTranslationKey.callsListSave);
    }
  }

  /// Get icon of the menu item based [itemType].
  IconData _getIcon({required AliceCallDetailsMenuItemType itemType}) {
    switch (itemType) {
      case AliceCallDetailsMenuItemType.sort:
        return Icons.sort;
      case AliceCallDetailsMenuItemType.delete:
        return Icons.delete;
      case AliceCallDetailsMenuItemType.stats:
        return Icons.insert_chart;
      case AliceCallDetailsMenuItemType.save:
        return Icons.save;
    }
  }
}

/// FAB buttons used to scroll logs. Displayed only in logs tab.
class _LoggerFloatingActionButtons extends StatelessWidget {
  const _LoggerFloatingActionButtons({required this.scrollLogsList});

  final void Function(bool) scrollLogsList;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          heroTag: 'h1',
          backgroundColor: AliceTheme.lightRed,
          onPressed: () => scrollLogsList(true),
          child: const Icon(
            Icons.arrow_upward,
            color: AliceTheme.white,
          ),
        ),
        const SizedBox(height: 8),
        FloatingActionButton(
          heroTag: 'h2',
          backgroundColor: AliceTheme.lightRed,
          onPressed: () => scrollLogsList(false),
          child: const Icon(
            Icons.arrow_downward,
            color: AliceTheme.white,
          ),
        ),
      ],
    );
  }
}
