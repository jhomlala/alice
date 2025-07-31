import 'dart:async';

import 'package:alice/core/alice_storage.dart';
import 'package:alice/core/alice_utils.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_http_error.dart';
import 'package:alice/model/alice_http_response.dart';
import 'package:alice/utils/num_comparison.dart';
import 'package:collection/collection.dart';
import 'package:rxdart/subjects.dart';

/// Storage which uses memory to store calls data. It's a default storage
/// method.
class AliceMemoryStorage implements AliceStorage {
  AliceMemoryStorage({required this.maxCallsCount})
    : _callsSubject = BehaviorSubject.seeded([]),
      assert(maxCallsCount > 0, 'Max calls count should be greater than 0');
  @override
  final int maxCallsCount;

  /// Subject which stores all HTTP calls.
  final BehaviorSubject<List<AliceHttpCall>> _callsSubject;

  /// Stream which returns all HTTP calls on change.
  @override
  Stream<List<AliceHttpCall>> get callsStream => _callsSubject.stream;

  /// Returns all HTTP calls.
  @override
  List<AliceHttpCall> getCalls() => _callsSubject.value;

  /// Returns stats based on calls.
  @override
  AliceStats getStats() {
    final List<AliceHttpCall> calls = getCalls();

    return (
      total: calls.length,
      successes:
          calls
              .where(
                (AliceHttpCall call) =>
                    (call.response?.status.gte(200) ?? false) &&
                    (call.response?.status.lt(300) ?? false),
              )
              .length,
      redirects:
          calls
              .where(
                (AliceHttpCall call) =>
                    (call.response?.status.gte(300) ?? false) &&
                    (call.response?.status.lt(400) ?? false),
              )
              .length,
      errors:
          calls
              .where(
                (AliceHttpCall call) =>
                    ((call.response?.status.gte(400) ?? false) &&
                        (call.response?.status.lt(600) ?? false)) ||
                    const [-1, 0].contains(call.response?.status),
              )
              .length,
      loading: calls.where((AliceHttpCall call) => call.loading).length,
    );
  }

  /// Adds new call to calls list.
  @override
  void addCall(AliceHttpCall call) {
    final int callsCount = _callsSubject.value.length;
    if (callsCount >= maxCallsCount) {
      final List<AliceHttpCall> originalCalls = _callsSubject.value;
      originalCalls.removeAt(0);
      originalCalls.add(call);

      _callsSubject.add(originalCalls);
    } else {
      _callsSubject.add([..._callsSubject.value, call]);
    }
  }

  /// Adds error to a specific call.
  @override
  void addError(AliceHttpError error, int requestId) {
    final AliceHttpCall? selectedCall = selectCall(requestId);

    if (selectedCall == null) {
      return AliceUtils.log('Selected call is null');
    }

    selectedCall.error = error;
    _callsSubject.add([..._callsSubject.value]);
  }

  /// Adds response to a specific call.
  @override
  void addResponse(AliceHttpResponse response, int requestId) {
    final AliceHttpCall? selectedCall = selectCall(requestId);

    if (selectedCall == null) {
      return AliceUtils.log('Selected call is null');
    }

    selectedCall
      ..loading = false
      ..response = response
      ..duration =
          response.time.millisecondsSinceEpoch -
          (selectedCall.request?.time.millisecondsSinceEpoch ?? 0);

    _callsSubject.add([..._callsSubject.value]);
  }

  /// Removes all calls.
  @override
  void removeCalls() => _callsSubject.add([]);

  /// Searches for call with specific [requestId]. It may return null.
  @override
  AliceHttpCall? selectCall(int requestId) => _callsSubject.value
      .firstWhereOrNull((AliceHttpCall call) => call.id == requestId);
}
