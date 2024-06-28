import 'package:alice/core/alice_adapter.dart';
import 'package:alice/core/alice_core.dart';
import 'package:alice/core/alice_memory_storage.dart';
import 'package:alice/core/alice_storage.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_log.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

export 'package:alice/core/alice_store.dart';
export 'package:alice/model/alice_log.dart';

class Alice {
  /// Should user be notified with notification when there's new request caught
  /// by Alice
  final bool showNotification;

  /// Should inspector be opened on device shake (works only with physical
  /// with sensors)
  final bool showInspectorOnShake;

  /// Icon url for notification
  final String notificationIcon;

  /// Max number of calls that are stored in memory. When count is reached, FIFO
  /// method queue will be used to remove elements.
  final int maxCallsCount;

  /// Directionality of app. Directionality of the app will be used if set to
  /// null.
  final TextDirection? directionality;

  /// Flag used to show/hide share button
  final bool? showShareButton;

  GlobalKey<NavigatorState>? _navigatorKey;
  late final AliceCore _aliceCore;

  final AliceStorage? _aliceStorage;

  /// Creates alice instance.
  Alice({
    GlobalKey<NavigatorState>? navigatorKey,
    this.showNotification = true,
    this.showInspectorOnShake = false,
    this.notificationIcon = '@mipmap/ic_launcher',
    this.maxCallsCount = 1000,
    this.directionality,
    this.showShareButton = true,
    AliceStorage? aliceStorage,
  })  : _navigatorKey = navigatorKey ?? GlobalKey<NavigatorState>(),
        _aliceStorage = aliceStorage {
    _aliceCore = AliceCore(
      _navigatorKey,
      showNotification: showNotification,
      showInspectorOnShake: showInspectorOnShake,
      notificationIcon: notificationIcon,
      maxCallsCount: maxCallsCount,
      directionality: directionality,
      showShareButton: showShareButton,
      aliceStorage: _aliceStorage ??
          AliceMemoryStorage(
            maxCallsCount: maxCallsCount,
          ),
    );
  }

  /// Set custom navigation key. This will help if there's route library.
  void setNavigatorKey(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
    _aliceCore.navigatorKey = navigatorKey;
  }

  /// Get currently used navigation key
  GlobalKey<NavigatorState>? getNavigatorKey() => _navigatorKey;

  /// Opens Http calls inspector. This will navigate user to the new fullscreen
  /// page where all listened http calls can be viewed.
  void showInspector() => _aliceCore.navigateToCallListScreen();

  /// Handle generic http call. Can be used to any http client.
  void addHttpCall(AliceHttpCall aliceHttpCall) {
    assert(aliceHttpCall.request != null, "Http call request can't be null");
    assert(aliceHttpCall.response != null, "Http call response can't be null");

    _aliceCore.addCall(aliceHttpCall);
  }

  /// Adds new log to Alice logger.
  void addLog(AliceLog log) => _aliceCore.addLog(log);

  /// Adds list of logs to Alice logger
  void addLogs(List<AliceLog> logs) => _aliceCore.addLogs(logs);

  /// Returns flag which determines whether inspector is opened
  bool get isInspectorOpened => _aliceCore.isInspectorOpened;

  /// Adds new adapter to Alice.
  void addAdapter(AliceAdapter adapter) => adapter.injectCore(_aliceCore);
}
