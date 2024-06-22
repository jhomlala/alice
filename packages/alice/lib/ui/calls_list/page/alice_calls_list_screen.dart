import 'package:alice/core/alice_core.dart';
import 'package:alice/core/alice_logger.dart';
import 'package:alice/helper/alice_alert_helper.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_menu_item.dart';
import 'package:alice/model/alice_sort_option.dart';
import 'package:alice/model/alice_tab_item.dart';
import 'package:alice/ui/call_details/page/alice_call_details_page.dart';
import 'package:alice/ui/calls_list/widget/alice_sort_dialog.dart';
import 'package:alice/ui/stats/alice_stats_screen.dart';
import 'package:alice/ui/calls_list/widget/alice_calls_list_widget.dart';
import 'package:alice/ui/calls_list/widget/alice_empty_logs_widget.dart';
import 'package:alice/ui/calls_list/widget/alice_logs_widget.dart';
import 'package:alice/utils/alice_constants.dart';
import 'package:alice/utils/alice_theme.dart';
import 'package:flutter/material.dart';

class AliceCallsListPage extends StatefulWidget {
  final AliceCore _aliceCore;
  final AliceLogger? _aliceLogger;

  const AliceCallsListPage(
    this._aliceCore,
    this._aliceLogger, {
    super.key,
  });

  @override
  State<AliceCallsListPage> createState() => _AliceCallsListPageState();
}

class _AliceCallsListPageState extends State<AliceCallsListPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _queryTextEditingController =
      TextEditingController();
  final List<AliceTabItem> _tabItems = AliceTabItem.values;
  final ScrollController _scrollController = ScrollController();
  late final TabController? _tabController;

  AliceSortOption _sortOption = AliceSortOption.time;
  bool _sortAscending = false;
  bool _searchEnabled = false;
  bool isAndroidRawLogsEnabled = false;
  int _selectedIndex = 0;

  AliceCore get aliceCore => widget._aliceCore;

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
    return Directionality(
      textDirection:
          widget._aliceCore.directionality ?? Directionality.of(context),
      child: Theme(
        data: AliceTheme.getTheme(),
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
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
                      onPressed: _onLogsChangeClicked,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: _showClearLogsDialog,
                    ),
                  ]
                : <Widget>[
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _onSearchClicked,
                    ),
                    _ContextMenuButton(
                      onMenuItemSelected: _onMenuItemSelected,
                    ),
                  ],
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: AliceConstants.lightRed,
              tabs: [
                for (final AliceTabItem item in _tabItems)
                  Tab(text: item.title.toUpperCase()),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              StreamBuilder<List<AliceHttpCall>>(
                stream: aliceCore.callsSubject,
                builder:
                    (context, AsyncSnapshot<List<AliceHttpCall>> snapshot) {
                  final List<AliceHttpCall> calls = snapshot.data ?? [];
                  final String query = _queryTextEditingController.text.trim();
                  if (query.isNotEmpty) {
                    calls.removeWhere((AliceHttpCall call) => !call.endpoint
                        .toLowerCase()
                        .contains(query.toLowerCase()));
                  }
                  if (calls.isNotEmpty) {
                    return AliceCallsListWidget(
                      calls: calls,
                      sortOption: _sortOption,
                      sortAscending: _sortAscending,
                      onListItemClicked: _onListItemClicked,
                    );
                  } else {
                    return const AliceEmptyLogsWidget();
                  }
                },
              ),
              AliceLogsWidget(
                scrollController: _scrollController,
                aliceLogger: widget._aliceLogger,
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
      ),
    );
  }

  void _showClearLogsDialog() => AliceAlertHelper.showAlert(
        context,
        'Delete logs',
        'Do you want to clear logs?',
        firstButtonTitle: 'No',
        secondButtonTitle: 'Yes',
        secondButtonAction: _onLogsClearClicked,
      );

  void _onLogsChangeClicked() => setState(() {
        isAndroidRawLogsEnabled = !isAndroidRawLogsEnabled;
      });

  void _onLogsClearClicked() => setState(() {
        if (isAndroidRawLogsEnabled) {
          widget._aliceLogger?.clearAndroidRawLogs();
        } else {
          widget._aliceLogger?.clearLogs();
        }
      });

  void _onSearchClicked() => setState(() {
        _searchEnabled = !_searchEnabled;
        if (!_searchEnabled) {
          _queryTextEditingController.text = '';
        }
      });

  void _onTabChanged(int index) => setState(() {
        _selectedIndex = index;
        if (_selectedIndex == 1) {
          _searchEnabled = false;
          _queryTextEditingController.text = '';
        }
      },);

  void _onMenuItemSelected(AliceMenuItem menuItem) {
    if (menuItem.title == 'Sort') {
      _showSortDialog();
    }
    if (menuItem.title == 'Delete') {
      _showRemoveDialog();
    }
    if (menuItem.title == 'Stats') {
      _showStatsScreen();
    }
    if (menuItem.title == 'Save') {
      _saveToFile();
    }
  }

  void _onListItemClicked(AliceHttpCall call) => Navigator.push<void>(
        widget._aliceCore.getContext()!,
        MaterialPageRoute(
          builder: (_) => AliceCallDetailsPage(call, widget._aliceCore),
        ),
      );

  void _showRemoveDialog() => AliceAlertHelper.showAlert(
        context,
        'Delete calls',
        'Do you want to delete http calls?',
        firstButtonTitle: 'No',
        firstButtonAction: () => <String, dynamic>{},
        secondButtonTitle: 'Yes',
        secondButtonAction: _removeCalls,
      );

  void _removeCalls() => aliceCore.removeCalls();

  void _showStatsScreen() {
    Navigator.push<void>(
      aliceCore.getContext()!,
      MaterialPageRoute(
        builder: (context) => AliceStatsScreen(widget._aliceCore),
      ),
    );
  }

  void _saveToFile() => aliceCore.saveHttpRequests(context);

  void _updateSearchQuery(String query) => setState(() {});

  Future<void> _showSortDialog() async {
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
        _sortAscending = result.sortAscending ?? false;
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
    super.key,
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
        hintStyle: TextStyle(fontSize: 16, color: AliceConstants.grey),
        border: InputBorder.none,
      ),
      style: const TextStyle(fontSize: 16),
      onChanged: onChanged,
    );
  }
}

class _ContextMenuButton extends StatelessWidget {
  static const List<AliceMenuItem> _menuItems = [
    AliceMenuItem('Sort', Icons.sort),
    AliceMenuItem('Delete', Icons.delete),
    AliceMenuItem('Stats', Icons.insert_chart),
    AliceMenuItem('Save', Icons.save),
  ];

  const _ContextMenuButton({super.key, required this.onMenuItemSelected});

  final void Function(AliceMenuItem) onMenuItemSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<AliceMenuItem>(
      onSelected: onMenuItemSelected,
      itemBuilder: (BuildContext context) => [
        for (final AliceMenuItem item in _menuItems)
          PopupMenuItem<AliceMenuItem>(
            value: item,
            child: Row(
              children: [
                Icon(
                  item.iconData,
                  color: AliceConstants.lightRed,
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 10),
                ),
                Text(item.title),
              ],
            ),
          ),
      ],
    );
  }
}

class _LoggerFloatingActionButtons extends StatelessWidget {
  const _LoggerFloatingActionButtons({super.key, required this.scrollLogsList});

  final void Function(bool) scrollLogsList;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          heroTag: 'h1',
          backgroundColor: AliceConstants.orange,
          onPressed: () => scrollLogsList(true),
          child: const Icon(
            Icons.arrow_upward,
            color: AliceConstants.white,
          ),
        ),
        const SizedBox(height: 8),
        FloatingActionButton(
          heroTag: 'h2',
          backgroundColor: AliceConstants.orange,
          onPressed: () => scrollLogsList(false),
          child: const Icon(
            Icons.arrow_downward,
            color: AliceConstants.white,
          ),
        ),
      ],
    );
  }
}
