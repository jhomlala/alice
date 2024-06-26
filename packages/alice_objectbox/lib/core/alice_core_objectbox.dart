import 'package:alice/core/alice_core.dart';
import 'package:alice/core/alice_utils.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_http_error.dart';
import 'package:alice/model/alice_http_response.dart';
import 'package:alice_objectbox/alice_store.dart';
import 'package:alice_objectbox/model/cached_alice_http_call.dart';
import 'package:alice_objectbox/model/cached_alice_http_error.dart';
import 'package:alice_objectbox/objectbox.g.dart';

class AliceCoreObjectBox extends AliceCore {
  AliceCoreObjectBox(
    super.navigatorKey, {
    required AliceStore store,
    required super.showNotification,
    required super.showInspectorOnShake,
    required super.notificationIcon,
    required super.maxCallsCount,
  }) : _store = store;

  final AliceStore _store;
  late final Box<CachedAliceHttpCall> httpCallsBox = _store.httpCalls;

  @override
  void addCall(AliceHttpCall call) =>
      httpCallsBox.put(CachedAliceHttpCall.fromAliceHttpCall(call));

  @override
  void addError(AliceHttpError error, int requestId) {
    final CachedAliceHttpCall? selectedCall = _selectCall(requestId);

    if (selectedCall != null) {
      selectedCall.error = CachedAliceHttpError.fromAliceHttpError(error);

      httpCallsBox.put(selectedCall);
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

      httpCallsBox.put(selectedCall);
    } else {
      return AliceUtils.log('Selected call is null');
    }
  }

  @override
  void addHttpCall(AliceHttpCall aliceHttpCall) {
    assert(aliceHttpCall.request != null, "Http call request can't be null");
    assert(aliceHttpCall.response != null, "Http call response can't be null");

    httpCallsBox.put(CachedAliceHttpCall.fromAliceHttpCall(aliceHttpCall));
  }

  @override
  void removeCalls() => httpCallsBox.removeAll();

  CachedAliceHttpCall? _selectCall(int requestId) => httpCallsBox
      .query(CachedAliceHttpCall_.id.equals(requestId))
      .build()
      .findFirst();
}
