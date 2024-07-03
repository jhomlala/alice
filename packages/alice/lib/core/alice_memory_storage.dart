import 'dart:async';

import 'package:alice/core/alice_storage.dart';
import 'package:alice/core/alice_utils.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_http_error.dart';
import 'package:alice/model/alice_http_response.dart';
import 'package:alice/utils/num_comparison.dart';
import 'package:collection/collection.dart';
import 'package:rxdart/subjects.dart';

class AliceMemoryStorage implements AliceStorage {
  AliceMemoryStorage({
    required this.maxCallsCount,
  })  : callsSubject = BehaviorSubject.seeded([]),
        assert(maxCallsCount > 0, 'Max calls count should be greater than 0');

  @override
  final int maxCallsCount;

  final BehaviorSubject<List<AliceHttpCall>> callsSubject;

  @override
  Stream<List<AliceHttpCall>> get callsStream => callsSubject.stream;

  @override
  List<AliceHttpCall> getCalls() => callsSubject.value;

  @override
  AliceStats getStats() {
    final List<AliceHttpCall> calls = getCalls();

    return (
      total: calls.length,
      successes: calls
          .where(
            (AliceHttpCall call) =>
                (call.response?.status.gte(200) ?? false) &&
                (call.response?.status.lt(300) ?? false),
          )
          .length,
      redirects: calls
          .where((AliceHttpCall call) =>
              (call.response?.status.gte(300) ?? false) &&
              (call.response?.status.lt(400) ?? false))
          .length,
      errors: calls
          .where(
            (AliceHttpCall call) =>
                ((call.response?.status.gte(400) ?? false) &&
                    (call.response?.status.lt(600) ?? false)) ||
                call.response?.status == -1 ||
                call.response?.status == 0,
          )
          .length,
      loading: calls.where((AliceHttpCall call) => call.loading).length,
    );
  }

  @override
  void addCall(AliceHttpCall call) {
    final int callsCount = callsSubject.value.length;
    if (callsCount >= maxCallsCount) {
      final List<AliceHttpCall> originalCalls = callsSubject.value;
      originalCalls.removeAt(0);
      originalCalls.add(call);

      callsSubject.add(originalCalls);
    } else {
      callsSubject.add([...callsSubject.value, call]);
    }
  }

  @override
  void addError(AliceHttpError error, int requestId) {
    final AliceHttpCall? selectedCall = selectCall(requestId);

    if (selectedCall == null) {
      return AliceUtils.log('Selected call is null');
    }

    selectedCall.error = error;
    callsSubject.add([...callsSubject.value]);
  }

  @override
  void addResponse(AliceHttpResponse response, int requestId) {
    final AliceHttpCall? selectedCall = selectCall(requestId);

    if (selectedCall == null) {
      return AliceUtils.log('Selected call is null');
    }

    selectedCall
      ..loading = false
      ..response = response
      ..duration = response.time.millisecondsSinceEpoch -
          (selectedCall.request?.time.millisecondsSinceEpoch ?? 0);

    callsSubject.add([...callsSubject.value]);
  }

  @override
  void removeCalls() => callsSubject.add([]);

  @override
  AliceHttpCall? selectCall(int requestId) => callsSubject.value
      .firstWhereOrNull((AliceHttpCall call) => call.id == requestId);
}
