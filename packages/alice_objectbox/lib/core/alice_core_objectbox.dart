import 'dart:io' show Platform;

import 'package:alice/core/alice_core.dart';
import 'package:alice/core/alice_utils.dart';
import 'package:alice/helper/alice_save_helper.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_http_error.dart';
import 'package:alice/model/alice_http_response.dart';
import 'package:alice/utils/shake_detector.dart';
import 'package:alice_objectbox/alice_store.dart';
import 'package:alice_objectbox/model/cached_alice_http_call.dart';
import 'package:alice_objectbox/model/cached_alice_http_error.dart';
import 'package:alice_objectbox/objectbox.g.dart';
import 'package:flutter/widgets.dart';

class AliceCoreObjectBox extends AliceCore {
  final AliceStore _store;

  late final Stream<List<AliceHttpCall>> _callsStream = _store.httpCalls
      .query()
      .order<int>(CachedAliceHttpCall_.dbCreatedTime, flags: Order.descending)
      .watch(triggerImmediately: true)
      .map((Query<CachedAliceHttpCall> query) => query.find());

  bool _isInspectorOpened = false;

  @override
  bool get isInspectorOpened => _isInspectorOpened;

  AliceCoreObjectBox(
    super.navigatorKey, {
    required AliceStore store,
    required super.showNotification,
    required super.showInspectorOnShake,
    required super.notificationIcon,
    required super.maxCallsCount,
    super.directionality,
    super.showShareButton,
  }) : _store = store {
    if (showNotification) {
      initializeNotificationsPlugin();
      requestNotificationPermissions();
      callsSubscription = _callsStream.listen(_onCallsChanged);
    }
    if (showInspectorOnShake) {
      if (Platform.isAndroid || Platform.isIOS) {
        shakeDetector = ShakeDetector.autoStart(
          onPhoneShake: navigateToCallListScreen,
          shakeThresholdGravity: 4,
        );
      }
    }
  }

  Future<void> _onCallsChanged(List<AliceHttpCall> calls) async {
    if (calls.isNotEmpty) {
      notificationMessage = _getNotificationMessage();
      if (notificationMessage != notificationMessageShown &&
          !notificationProcessing) {
        await _showLocalNotification();
      }
    }
  }

  String _getNotificationMessage() {
    // TODO: Implement this method
    throw UnimplementedError();
  }

  Future<void> _showLocalNotification() async {
    // TODO: Implement this method
    throw UnimplementedError();
  }

  CachedAliceHttpCall? _selectCall(int requestId) => _store.httpCalls
      .query(CachedAliceHttpCall_.id.equals(requestId))
      .build()
      .findFirst();

  @override
  void addCall(AliceHttpCall call) =>
      _store.httpCalls.put(CachedAliceHttpCall.fromAliceHttpCall(call));

  @override
  void addError(AliceHttpError error, int requestId) {
    final CachedAliceHttpCall? selectedCall = _selectCall(requestId);

    if (selectedCall != null) {
      selectedCall.error = CachedAliceHttpError.fromAliceHttpError(error);

      _store.httpCalls.put(selectedCall);
    } else {
      return AliceUtils.log('Selected call is null');
    }
  }

  @override
  void addResponse(AliceHttpResponse response, int requestId) {
    final CachedAliceHttpCall? selectedCall = _selectCall(requestId);

    if (selectedCall != null) {
      selectedCall
        ..loading = false
        ..response = response
        ..duration = response.time.millisecondsSinceEpoch -
            (selectedCall.request?.time.millisecondsSinceEpoch ?? 0);

      _store.httpCalls.put(selectedCall);
    } else {
      return AliceUtils.log('Selected call is null');
    }
  }

  @override
  void addHttpCall(AliceHttpCall aliceHttpCall) {
    assert(aliceHttpCall.request != null, "Http call request can't be null");
    assert(aliceHttpCall.response != null, "Http call response can't be null");

    _store.httpCalls.put(CachedAliceHttpCall.fromAliceHttpCall(aliceHttpCall));
  }

  @override
  void removeCalls() => _store.httpCalls.removeAll();

  @override
  void saveHttpRequests(BuildContext context) =>
      AliceSaveHelper.saveCalls(context, _store.httpCalls.getAll());
}
