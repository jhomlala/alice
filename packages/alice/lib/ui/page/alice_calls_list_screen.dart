import 'package:alice/core/alice_core.dart';
import 'package:alice/core/alice_logger.dart';
import 'package:alice/helper/alice_alert_helper.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_menu_item.dart';
import 'package:alice/model/alice_sort_option.dart';
import 'package:alice/model/alice_tab_item.dart';
import 'package:alice/ui/page/alice_call_details_screen.dart';
import 'package:alice/ui/page/alice_stats_screen.dart';
import 'package:alice/ui/widget/alice_call_list_item_widget.dart';
import 'package:alice/ui/widget/alice_log_list_widget.dart';
import 'package:alice/ui/widget/alice_raw_log_list_widger.dart';
import 'package:alice/utils/alice_constants.dart';
import 'package:alice/utils/alice_scroll_behavior.dart';
import 'package:alice/utils/alice_theme.dart';
import 'package:flutter/material.dart';

class AliceCallsListScreen extends StatefulWidget {
  final AliceCore _aliceCore;
  final AliceLogger? _aliceLogger;

  const AliceCallsListScreen(this._aliceCore, this._aliceLogger, {super.key});

  @override
  State<StatefulWidget> createState() => _AliceCallsListScreenState();
}

class _AliceCallsListScreenState extends State<AliceCallsListScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _queryTextEditingController =
      TextEditingController();
  final List<AliceMenuItem> _menuItems = [];
  final List<AliceTabItem> _tabItems = AliceTabItem.values;
  final ScrollController _scrollController = ScrollController();

  AliceSortOption? _sortOption = AliceSortOption.time;
  bool _sortAscending = false;
  bool _searchEnabled = false;
  bool isAndroidRawLogsEnabled = false;
  int _selectedIndex = 0;

  late final TabController? _tabController;

  AliceCore get aliceCore => widget._aliceCore;

  _AliceCallsListScreenState() {
    _menuItems.addAll([
      const AliceMenuItem('Sort', Icons.sort),
      const AliceMenuItem('Delete', Icons.delete),
      const AliceMenuItem('Stats', Icons.insert_chart),
      const AliceMenuItem('Save', Icons.save),
    ]);
  }

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

  @override
  Widget build(BuildContext context) {
    final bool isLoggerTab = _selectedIndex == 1;

    return Directionality(
      textDirection:
          widget._aliceCore.directionality ?? Directionality.of(context),
      child: Theme(
        data: ThemeData(
          colorScheme: AliceTheme.getColorScheme(),
        ),
        child: Scaffold(
          appBar: AppBar(
            title: _searchEnabled ? _buildSearchField() : _buildTitleWidget(),
            actions: _buildActionWidgets(isLoggerTab),
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
              _buildCallsListWrapper(),
              _buildLogsWidget(),
            ],
          ),
          floatingActionButton: _buildFloatingActionButton(isLoggerTab),
        ),
      ),
    );
  }

  List<Widget> _buildActionWidgets(bool isLoggerTab) => [
        if (isLoggerTab) ...[
          _buildLogsChangeButton(),
          _buildLogsClearButton(),
        ],
        ...[
          _buildSearchButton(),
          _buildMenuButton(),
        ],
      ];

  Widget _buildFloatingActionButton(bool isLoggerTab) {
    if (isLoggerTab) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'h1',
            backgroundColor: AliceConstants.orange,
            onPressed: () => _scrollLogsList(true),
            child: const Icon(Icons.arrow_upward, color: AliceConstants.white),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'h2',
            backgroundColor: AliceConstants.orange,
            onPressed: () => _scrollLogsList(false),
            child:
                const Icon(Icons.arrow_downward, color: AliceConstants.white),
          ),
        ],
      );
    }

    return const SizedBox();
  }

  Widget _buildSearchButton() => IconButton(
        icon: const Icon(Icons.search),
        onPressed: _onSearchClicked,
      );

  Widget _buildLogsChangeButton() => IconButton(
        icon: const Icon(Icons.terminal),
        onPressed: _onLogsChangeClicked,
      );

  Widget _buildLogsClearButton() => IconButton(
        icon: const Icon(Icons.delete),
        onPressed: _showClearLogsDialog,
      );

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

  Widget _buildMenuButton() {
    return PopupMenuButton<AliceMenuItem>(
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
    );
  }

  Widget _buildTitleWidget() => const Text('Alice');

  Widget _buildSearchField() => TextField(
        controller: _queryTextEditingController,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'Search http request...',
          hintStyle: TextStyle(fontSize: 16, color: AliceConstants.grey),
          border: InputBorder.none,
        ),
        style: const TextStyle(fontSize: 16),
        onChanged: _updateSearchQuery,
      );

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

  Widget _buildCallsListWrapper() => StreamBuilder<List<AliceHttpCall>>(
        stream: aliceCore.callsSubject,
        builder: (context, AsyncSnapshot<List<AliceHttpCall>> snapshot) {
          final List<AliceHttpCall> calls = snapshot.data ?? [];
          final String query = _queryTextEditingController.text.trim();
          if (query.isNotEmpty) {
            calls.removeWhere((AliceHttpCall call) =>
                !call.endpoint.toLowerCase().contains(query.toLowerCase()));
          }
          if (calls.isNotEmpty) {
            return _buildCallsListWidget(calls);
          } else {
            return _buildEmptyWidget();
          }
        },
      );

  Widget _buildEmptyWidget() => Container(
        margin: const EdgeInsets.symmetric(horizontal: 32),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: AliceConstants.orange,
              ),
              SizedBox(height: 6),
              Text(
                'There are no calls to show',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• Check if you send any http request',
                    style: TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    '• Check your Alice configuration',
                    style: TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    '• Check search filters',
                    style: TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  Widget _buildCallsListWidget(List<AliceHttpCall> calls) {
    final List<AliceHttpCall> callsSorted = [...calls];
    switch (_sortOption) {
      case AliceSortOption.time:
        if (_sortAscending) {
          callsSorted.sort(
            (AliceHttpCall call1, AliceHttpCall call2) =>
                call1.createdTime.compareTo(call2.createdTime),
          );
        } else {
          callsSorted.sort(
            (AliceHttpCall call1, AliceHttpCall call2) =>
                call2.createdTime.compareTo(call1.createdTime),
          );
        }
      case AliceSortOption.responseTime:
        if (_sortAscending) {
          callsSorted
            ..sort()
            ..sort(
              (AliceHttpCall call1, AliceHttpCall call2) =>
                  call1.response?.time.compareTo(call2.response!.time) ?? -1,
            );
        } else {
          callsSorted.sort(
            (AliceHttpCall call1, AliceHttpCall call2) =>
                call2.response?.time.compareTo(call1.response!.time) ?? -1,
          );
        }
      case AliceSortOption.responseCode:
        if (_sortAscending) {
          callsSorted.sort(
            (AliceHttpCall call1, AliceHttpCall call2) =>
                call1.response?.status?.compareTo(call2.response!.status!) ??
                -1,
          );
        } else {
          callsSorted.sort(
            (AliceHttpCall call1, AliceHttpCall call2) =>
                call2.response?.status?.compareTo(call1.response!.status!) ??
                -1,
          );
        }
      case AliceSortOption.responseSize:
        if (_sortAscending) {
          callsSorted.sort(
            (AliceHttpCall call1, AliceHttpCall call2) =>
                call1.response?.size.compareTo(call2.response!.size) ?? -1,
          );
        } else {
          callsSorted.sort(
            (AliceHttpCall call1, AliceHttpCall call2) =>
                call2.response?.size.compareTo(call1.response!.size) ?? -1,
          );
        }
      case AliceSortOption.endpoint:
        if (_sortAscending) {
          callsSorted.sort(
            (AliceHttpCall call1, AliceHttpCall call2) =>
                call1.endpoint.compareTo(call2.endpoint),
          );
        } else {
          callsSorted.sort(
            (AliceHttpCall call1, AliceHttpCall call2) =>
                call2.endpoint.compareTo(call1.endpoint),
          );
        }
      default:
    }

    return ScrollConfiguration(
      behavior: AliceScrollBehavior(),
      child: ListView.builder(
        itemCount: callsSorted.length,
        itemBuilder: (context, int index) => AliceCallListItemWidget(
          callsSorted[index],
          _onListItemClicked,
        ),
      ),
    );
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

  Widget _buildLogsWidget() {
    final AliceLogger? aliceLogger = widget._aliceLogger;
    final Widget emptyWidget = _buildEmptyLogsWidget();
    if (aliceLogger != null) {
      if (isAndroidRawLogsEnabled) {
        return AliceRawLogListWidget(
          scrollController: _scrollController,
          getRawLogs: aliceLogger.getAndroidRawLogs(),
          emptyWidget: emptyWidget,
        );
      }
      return AliceLogListWidget(
        logsListenable: aliceLogger.listenable,
        scrollController: _scrollController,
        emptyWidget: emptyWidget,
      );
    } else {
      return _buildEmptyLogsWidget();
    }
  }

  void sortCalls() => setState(() {});

  Widget _buildEmptyLogsWidget() => Container(
        margin: const EdgeInsets.symmetric(horizontal: 32),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: AliceConstants.orange,
              ),
              SizedBox(height: 6),
              Text(
                'There are no logs to show',
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      );

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
