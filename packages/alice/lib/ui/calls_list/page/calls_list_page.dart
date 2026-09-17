// ignore_for_file: use_build_context_synchronously

import 'package:alice/core/alice_core.dart';
import 'package:alice/export/har_exporter.dart';
import 'package:alice/export/text_exporter.dart';
import 'package:alice/utils/operating_system.dart';
import 'package:alice/model/export_format.dart';
import 'package:alice/model/export_result.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/translation.dart';
import 'package:alice/ui/call_details/model/menu_item.dart';
import 'package:alice/ui/calls_list/model/calls_list_sort_option.dart';
import 'package:alice/ui/calls_list/model/calls_list_tab_item.dart';
import 'package:alice/ui/calls_list/widget/inspector_screen.dart';
import 'package:alice/ui/calls_list/widget/sort_dialog.dart';
import 'package:alice/ui/common/context_ext.dart';
import 'package:alice/ui/common/dialog.dart';
import 'package:alice/ui/common/export_format_dialog.dart';
import 'package:alice/ui/common/navigation.dart';
import 'package:alice/ui/common/page.dart';
import 'package:alice/ui/calls_list/widget/logs_screen.dart';
import 'package:alice/ui/common/theme.dart';
import 'package:material_ui/material_ui.dart';
import 'package:open_file/open_file.dart';

/// Page which displays list of calls caught by Alice. It displays tab view
/// where calls and logs can be inspected. It allows to sort calls, delete calls
/// and search calls.
class CallsListPage extends StatefulWidget {
  final AliceCore core;

  const CallsListPage({required this.core, super.key});

  @override
  State<CallsListPage> createState() => _AliceCallsListPageState();
}

class _AliceCallsListPageState extends State<CallsListPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _queryTextEditingController =
      TextEditingController();
  final List<CallsListTabItem> _tabItems = CallsListTabItem.values;
  final ScrollController _scrollController = ScrollController();
  late final TabController? _tabController;

  CallsListSortOption _sortOption = CallsListSortOption.time;
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
        _onTabChanged(_tabController.index);
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
    return BasePage(
      core: aliceCore,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _onBackPressed,
          ),
          title:
              _searchEnabled
                  ? _SearchTextField(
                    textEditingController: _queryTextEditingController,
                    onChanged: _updateSearchQuery,
                  )
                  : Text(context.i18n(TranslationKey.alice)),
          actions:
              isLoggerTab
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
                    if (_searchEnabled)
                      IconButton(
                        icon: const Icon(Icons.help_outline),
                        onPressed: _showSearchHelpDialog,
                      ),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _onSearchPressed,
                    ),
                    _ContextMenuButton(onMenuItemSelected: _onMenuItemSelected),
                  ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AliceAppTheme.lightRed,
            tabs:
                CallsListTabItem.values.map((item) {
                  return Tab(text: _getTabName(item: item));
                }).toList(),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            InspectorScreen(
              aliceCore: aliceCore,
              queryTextEditingController: _queryTextEditingController,
              sortOption: _sortOption,
              sortAscending: _sortAscending,
              onListItemPressed: _onListItemPressed,
            ),
            LogsScreen(
              scrollController: _scrollController,
              aliceLogger: widget.core.configuration.aliceLogger,
              isAndroidRawLogsEnabled: isAndroidRawLogsEnabled,
            ),
          ],
        ),
        floatingActionButton:
            isLoggerTab
                ? _LoggerFloatingActionButtons(scrollLogsList: _scrollLogsList)
                : const SizedBox(),
      ),
    );
  }

  /// Get tab name based on [item] type.
  String _getTabName({required CallsListTabItem item}) {
    switch (item) {
      case CallsListTabItem.inspector:
        return context.i18n(TranslationKey.callsListInspector);
      case CallsListTabItem.logger:
        return context.i18n(TranslationKey.callsListLogger);
    }
  }

  /// Called when back button has been pressed. It navigates back to original
  /// application.
  void _onBackPressed() {
    Navigator.of(context).pop();
  }

  /// Called when clear logs has been pressed. It displays dialog and awaits for
  /// user confirmation.
  void _onClearLogsPressed() => AliceGeneralDialog.show(
    context: context,
    title: context.i18n(TranslationKey.callsListDeleteLogsDialogTitle),
    description: context.i18n(
      TranslationKey.callsListDeleteLogsDialogDescription,
    ),
    firstButtonTitle: context.i18n(TranslationKey.callsListNo),
    secondButtonTitle: context.i18n(TranslationKey.callsListYes),
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

  /// Displays dialog with search help.
  void _showSearchHelpDialog() {
    AliceGeneralDialog.show(
      context: context,
      title: context.i18n(TranslationKey.searchHelpTitle),
      description: context.i18n(TranslationKey.searchHelpDescription),
    );
  }

  /// Called on tab has been changed.
  void _onTabChanged(int index) => setState(() {
    _selectedIndex = index;
    if (_selectedIndex == 1) {
      _searchEnabled = false;
      _queryTextEditingController.text = '';
    }
  });

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
        _onExportPressed();
    }
  }

  /// Called when item from the list has been pressed. It opens details page.
  void _onListItemPressed(AliceHttpCall call) =>
      Navigation.navigateToCallDetails(call: call, core: aliceCore);

  /// Called when remove all calls button has been pressed.
  void _onRemovePressed() => AliceGeneralDialog.show(
    context: context,
    title: context.i18n(TranslationKey.callsListDeleteCallsDialogTitle),
    description: context.i18n(
      TranslationKey.callsListDeleteCallsDialogDescription,
    ),
    firstButtonTitle: context.i18n(TranslationKey.callsListNo),
    firstButtonAction: () => <String, dynamic>{},
    secondButtonTitle: context.i18n(TranslationKey.callsListYes),
    secondButtonAction: _removeCalls,
  );

  /// Removes all calls from Alice.
  void _removeCalls() => aliceCore.removeCalls();

  /// Called when stats button has been pressed. Navigates to stats page.
  void _onStatsPressed() {
    Navigation.navigateToStats(core: aliceCore);
  }

  /// Called when save to file has been pressed. It saves data to file.
  void _onExportPressed() async {
    if (!mounted) return;

    final format = await ExportFormatDialog.show(context);
    if (format == null) return;

    final result = await aliceCore.exportCalls(
      context: context,
      exporter: format == ExportFormat.txt ? TextExporter() : HarExporter(),
    );

    if (!mounted) return;
    if (result.success && result.path != null) {
      AliceGeneralDialog.show(
        context: context,
        title: context.i18n(TranslationKey.saveSuccessTitle),
        description: context
            .i18n(TranslationKey.saveSuccessDescription)
            .replaceAll("[path]", result.path!),
        secondButtonTitle:
            OperatingSystem.isAndroid
                ? context.i18n(TranslationKey.saveSuccessView)
                : null,
        secondButtonAction:
            () =>
                OperatingSystem.isAndroid ? OpenFile.open(result.path!) : null,
      );
    } else {
      final [String title, String description] = switch (result.error) {
        ExportResultError.logGenerate => [
          context.i18n(TranslationKey.saveDialogPermissionErrorTitle),
          context.i18n(TranslationKey.saveDialogPermissionErrorDescription),
        ],
        ExportResultError.empty => [
          context.i18n(TranslationKey.saveDialogEmptyErrorTitle),
          context.i18n(TranslationKey.saveDialogEmptyErrorDescription),
        ],
        ExportResultError.permission => [
          context.i18n(TranslationKey.saveDialogPermissionErrorTitle),
          context.i18n(TranslationKey.saveDialogPermissionErrorDescription),
        ],
        ExportResultError.file => [
          context.i18n(TranslationKey.saveDialogFileSaveErrorTitle),
          context.i18n(TranslationKey.saveDialogFileSaveErrorDescription),
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
      builder:
          (_) => SortDialog(
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
        hintText: context.i18n(TranslationKey.callsListSearchHint),
        hintStyle: const TextStyle(fontSize: 16, color: AliceAppTheme.grey),
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
      itemBuilder:
          (BuildContext context) => [
            for (final AliceCallDetailsMenuItemType item
                in AliceCallDetailsMenuItemType.values)
              PopupMenuItem<AliceCallDetailsMenuItemType>(
                value: item,
                child: Row(
                  children: [
                    Icon(
                      _getIcon(itemType: item),
                      color: AliceAppTheme.lightRed,
                    ),
                    const Padding(padding: EdgeInsets.only(left: 10)),
                    Text(_getTitle(context: context, itemType: item)),
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
        return context.i18n(TranslationKey.callsListSort);
      case AliceCallDetailsMenuItemType.delete:
        return context.i18n(TranslationKey.callsListDelete);
      case AliceCallDetailsMenuItemType.stats:
        return context.i18n(TranslationKey.callsListStats);
      case AliceCallDetailsMenuItemType.save:
        return context.i18n(TranslationKey.callsListSave);
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
          backgroundColor: AliceAppTheme.lightRed,
          onPressed: () => scrollLogsList(true),
          child: const Icon(Icons.arrow_upward, color: AliceAppTheme.white),
        ),
        const SizedBox(height: 8),
        FloatingActionButton(
          heroTag: 'h2',
          backgroundColor: AliceAppTheme.lightRed,
          onPressed: () => scrollLogsList(false),
          child: const Icon(Icons.arrow_downward, color: AliceAppTheme.white),
        ),
      ],
    );
  }
}
