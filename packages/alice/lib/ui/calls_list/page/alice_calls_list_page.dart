import 'package:alice/core/alice_core.dart';
import 'package:alice/core/alice_logger.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/ui/call_details/model/alice_menu_item.dart';
import 'package:alice/ui/call_details/model/alice_sort_option.dart';
import 'package:alice/ui/calls_list/model/alice_calls_list_tab_item.dart';
import 'package:alice/ui/calls_list/widget/alice_sort_dialog.dart';
import 'package:alice/ui/common/alice_dialog.dart';
import 'package:alice/ui/common/alice_navigation.dart';
import 'package:alice/ui/common/alice_page.dart';
import 'package:alice/ui/calls_list/widget/alice_calls_list_screen.dart';
import 'package:alice/ui/calls_list/widget/alice_empty_logs_widget.dart';
import 'package:alice/ui/calls_list/widget/alice_logs_screen.dart';
import 'package:alice/utils/alice_theme.dart';
import 'package:flutter/material.dart';

class AliceCallsListPage extends StatefulWidget {
  final AliceCore core;
  final AliceLogger? logger;

  const AliceCallsListPage({
    required this.core,
    this.logger,
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

  AliceSortOption _sortOption = AliceSortOption.time;
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
              : const Text('Alice'),
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
            StreamBuilder<List<AliceHttpCall>>(
              stream: aliceCore.callsSubject,
              builder: (context, AsyncSnapshot<List<AliceHttpCall>> snapshot) {
                final List<AliceHttpCall> calls = snapshot.data ?? [];
                final String query = _queryTextEditingController.text.trim();
                if (query.isNotEmpty) {
                  calls.removeWhere((AliceHttpCall call) => !call.endpoint
                      .toLowerCase()
                      .contains(query.toLowerCase()));
                }
                if (calls.isNotEmpty) {
                  return AliceCallsListScreen(
                    calls: calls,
                    sortOption: _sortOption,
                    sortAscending: _sortAscending,
                    onListItemClicked: _onListItemPressed,
                  );
                } else {
                  return const AliceEmptyLogsWidget();
                }
              },
            ),
            AliceLogsScreen(
              scrollController: _scrollController,
              aliceLogger: widget.logger,
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

  String _getTabName({required AliceCallsListTabItem item}) {
    switch (item) {
      case AliceCallsListTabItem.inspector:
        return "Inspector";
      case AliceCallsListTabItem.logger:
        return "Logger";
    }
  }

  void _onBackPressed() {
    Navigator.of(context, rootNavigator: true).pop();
  }

  void _onClearLogsPressed() => AliceGeneralDialog.show(
        context: context,
        title: 'Delete logs',
        description: 'Do you want to clear logs?',
        firstButtonTitle: 'No',
        secondButtonTitle: 'Yes',
        secondButtonAction: _onLogsClearPressed,
      );

  void _onLogsChangePressed() => setState(() {
        isAndroidRawLogsEnabled = !isAndroidRawLogsEnabled;
      });

  void _onLogsClearPressed() => setState(() {
        if (isAndroidRawLogsEnabled) {
          widget.logger?.clearAndroidRawLogs();
        } else {
          widget.logger?.clearLogs();
        }
      });

  void _onSearchPressed() => setState(() {
        _searchEnabled = !_searchEnabled;
        if (!_searchEnabled) {
          _queryTextEditingController.text = '';
        }
      });

  void _onTabChanged(int index) => setState(
        () {
          _selectedIndex = index;
          if (_selectedIndex == 1) {
            _searchEnabled = false;
            _queryTextEditingController.text = '';
          }
        },
      );

  void _onMenuItemSelected(AliceMenuItemType menuItem) {
    switch (menuItem) {
      case AliceMenuItemType.sort:
        _onSortPressed();
      case AliceMenuItemType.delete:
        _onRemovePressed();
      case AliceMenuItemType.stats:
        _onStatsPressed();
      case AliceMenuItemType.save:
        _saveToFile();
    }
  }

  void _onListItemPressed(AliceHttpCall call) =>
      AliceNavigation.navigateToDetails(call: call, core: aliceCore);

  void _onRemovePressed() => AliceGeneralDialog.show(
        context: context,
        title: 'Delete calls',
        description: 'Do you want to delete http calls?',
        firstButtonTitle: 'No',
        firstButtonAction: () => <String, dynamic>{},
        secondButtonTitle: 'Yes',
        secondButtonAction: _removeCalls,
      );

  void _removeCalls() => aliceCore.removeCalls();

  void _onStatsPressed() {
    AliceNavigation.navigateToStats(core: aliceCore);
  }

  void _saveToFile() => aliceCore.saveHttpRequests(context);

  void _updateSearchQuery(String query) => setState(() {});

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

  void _scrollLogsList(bool top) => top ? _scrollToTop() : _scrollToBottom();

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: const Duration(microseconds: 500),
        curve: Curves.ease,
      );
    }
  }

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
      decoration: const InputDecoration(
        hintText: 'Search http request...',
        hintStyle: TextStyle(fontSize: 16, color: AliceTheme.grey),
        border: InputBorder.none,
      ),
      style: const TextStyle(fontSize: 16),
      onChanged: onChanged,
    );
  }
}

class _ContextMenuButton extends StatelessWidget {
  const _ContextMenuButton({required this.onMenuItemSelected});

  final void Function(AliceMenuItemType) onMenuItemSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<AliceMenuItemType>(
      onSelected: onMenuItemSelected,
      itemBuilder: (BuildContext context) => [
        for (final AliceMenuItemType item in AliceMenuItemType.values)
          PopupMenuItem<AliceMenuItemType>(
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
                Text(_getTitle(itemType: item)),
              ],
            ),
          ),
      ],
    );
  }

  String _getTitle({required AliceMenuItemType itemType}) {
    switch (itemType) {
      case AliceMenuItemType.sort:
        return "Sort";
      case AliceMenuItemType.delete:
        return "Delete";
      case AliceMenuItemType.stats:
        return "Stats";
      case AliceMenuItemType.save:
        return "Save";
    }
  }

  IconData _getIcon({required AliceMenuItemType itemType}) {
    switch (itemType) {
      case AliceMenuItemType.sort:
        return Icons.sort;
      case AliceMenuItemType.delete:
        return Icons.delete;
      case AliceMenuItemType.stats:
        return Icons.insert_chart;
      case AliceMenuItemType.save:
        return Icons.save;
    }
  }
}

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
