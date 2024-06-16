import 'package:alice/core/alice_core.dart';
import 'package:alice/core/alice_logger.dart';
import 'package:alice/helper/alice_alert_helper.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_menu_item.dart';
import 'package:alice/model/alice_sort_option.dart';
import 'package:alice/model/alice_tab_item.dart';
import 'package:alice/ui/page/alice_call_details_screen.dart';
import 'package:alice/ui/page/alice_stats_screen.dart';
import 'package:alice/ui/widget/alice_calls_list_widget.dart';
import 'package:alice/ui/widget/alice_empty_logs_widget.dart';
import 'package:alice/ui/widget/alice_logs_widget.dart';
import 'package:alice/utils/alice_constants.dart';
import 'package:alice/utils/alice_theme.dart';
import 'package:flutter/material.dart';

class AliceCallsListScreen extends StatefulWidget {
  final AliceCore _aliceCore;
  final AliceLogger? _aliceLogger;

  const AliceCallsListScreen(
    this._aliceCore,
    this._aliceLogger, {
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _AliceCallsListScreenState();
}

class _AliceCallsListScreenState extends State<AliceCallsListScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _queryTextEditingController =
      TextEditingController();
  static const List<AliceMenuItem> _menuItems = [
    AliceMenuItem('Sort', Icons.sort),
    AliceMenuItem('Delete', Icons.delete),
    AliceMenuItem('Stats', Icons.insert_chart),
    AliceMenuItem('Save', Icons.save),
  ];
  final List<AliceTabItem> _tabItems = AliceTabItem.values;
  late final ScrollController _scrollController = ScrollController();

  AliceSortOption? _sortOption = AliceSortOption.time;
  bool _sortAscending = false;
  bool _searchEnabled = false;
  bool isAndroidRawLogsEnabled = false;
  int _selectedIndex = 0;

  late final TabController? _tabController;

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
        data: ThemeData(
          colorScheme: AliceTheme.getColorScheme(),
        ),
        child: Scaffold(
          appBar: AppBar(
            title: _searchEnabled
                ? TextField(
                    controller: _queryTextEditingController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Search http request...',
                      hintStyle:
                          TextStyle(fontSize: 16, color: AliceConstants.grey),
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(fontSize: 16),
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
                    PopupMenuButton<AliceMenuItem>(
                      onSelected: _onMenuItemSelected,
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
                    ),
                  ],
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: AliceConstants.orange,
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
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FloatingActionButton(
                      heroTag: 'h1',
                      backgroundColor: AliceConstants.orange,
                      onPressed: () => _scrollLogsList(true),
                      child: const Icon(
                        Icons.arrow_upward,
                        color: AliceConstants.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton(
                      heroTag: 'h2',
                      backgroundColor: AliceConstants.orange,
                      onPressed: () => _scrollLogsList(false),
                      child: const Icon(
                        Icons.arrow_downward,
                        color: AliceConstants.white,
                      ),
                    ),
                  ],
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
      });

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
          builder: (_) => AliceCallDetailsScreen(call, widget._aliceCore),
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

  Future<void> _showSortDialog() => showDialog<void>(
        context: context,
        builder: (BuildContext buildContext) => Theme(
          data: ThemeData(
            brightness: Brightness.light,
          ),
          child: AlertDialog(
            title: const Text('Select filter'),
            content: StatefulBuilder(
              builder: (context, setState) => Wrap(
                children: [
                  for (final AliceSortOption sortOption
                      in AliceSortOption.values)
                    RadioListTile<AliceSortOption>(
                      title: Text(sortOption.name),
                      value: sortOption,
                      groupValue: _sortOption,
                      onChanged: (AliceSortOption? value) {
                        setState(() {
                          _sortOption = value;
                        });
                      },
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Descending'),
                      Switch(
                        value: _sortAscending,
                        onChanged: (value) {
                          setState(() {
                            _sortAscending = value;
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
            ),
            actions: [
              TextButton(
                onPressed: Navigator.of(context).pop,
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  sortCalls();
                },
                child: const Text('Use filter'),
              ),
            ],
          ),
        ),
      );

  void sortCalls() => setState(() {});

  void _scrollLogsList(bool top) {
    if (top) {
      _scrollToTop();
    } else {
      _scrollToBottom();
    }
  }

  void _scrollToTop() => _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: const Duration(microseconds: 500),
        curve: Curves.ease,
      );

  void _scrollToBottom() => _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(microseconds: 500),
        curve: Curves.ease,
      );
}
