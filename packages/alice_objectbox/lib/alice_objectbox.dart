import 'dart:math' show max;

import 'package:alice/core/alice_storage.dart';
import 'package:alice/core/alice_utils.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_http_error.dart';
import 'package:alice/model/alice_http_response.dart';
import 'package:alice_objectbox/alice_objectbox_store.dart';
import 'package:alice_objectbox/extensions/alice_http_call_extension.dart';
import 'package:alice_objectbox/model/cached_alice_http_call.dart';
import 'package:alice_objectbox/objectbox.g.dart';

/// Implementation of [AliceStorage] using ObjectBox.
class AliceObjectBox implements AliceStorage {
  const AliceObjectBox({
    required AliceObjectBoxStore store,
    required this.maxCallsCount,
  }) : _store = store,
       assert(maxCallsCount > 0, 'Max calls count should be greater than 0');

  final AliceObjectBoxStore _store;

  @override
  final int maxCallsCount;

  @override
  Stream<List<AliceHttpCall>> get callsStream =>
      _store.httpCalls
          .query()
          .order<int>(CachedAliceHttpCall_.createdTime, flags: Order.descending)
          .watch(triggerImmediately: true)
          .map((Query<CachedAliceHttpCall> query) => query.find())
          .asBroadcastStream();

  @override
  List<AliceHttpCall> getCalls() => _store.httpCalls.getAll();

  @override
  CachedAliceHttpCall? selectCall(int requestId) =>
      _store.httpCalls
          .query(CachedAliceHttpCall_.id.equals(requestId))
          .build()
          .findFirst();

  Future<void> _removeOverQuota() async {
    if (maxCallsCount > 0 && _store.httpCalls.count() >= maxCallsCount) {
      final Query<CachedAliceHttpCall> overQuota =
          _store.httpCalls
              .query()
              .order<int>(
                CachedAliceHttpCall_.createdTime,
                flags: Order.descending,
              )
              .build()
            ..offset = max(maxCallsCount - 1, 0);

      final List<int> overQuotaIds = await overQuota.findIdsAsync();

      if (overQuotaIds.isNotEmpty) {
        _store.httpCalls.removeManyAsync(overQuotaIds);
      }
    }
  }

  @override
  void addCall(AliceHttpCall call) {
    _removeOverQuota();

    _store.httpCalls.put(call.toCached());
  }

  @override
  void addError(AliceHttpError error, int requestId) {
    final CachedAliceHttpCall? selectedCall = selectCall(requestId);

    if (selectedCall != null) {
      selectedCall.error = error;

      _store.httpCalls.put(selectedCall);
    } else {
      AliceUtils.log('Selected call is null');
    }
  }

  @override
  void addResponse(AliceHttpResponse response, int requestId) {
    final CachedAliceHttpCall? selectedCall = selectCall(requestId);

    if (selectedCall != null) {
      selectedCall
        ..loading = false
        ..response = response
        ..duration =
            response.time.millisecondsSinceEpoch -
            (selectedCall.request?.time.millisecondsSinceEpoch ?? 0);

      _store.httpCalls.put(selectedCall);
    } else {
      AliceUtils.log('Selected call is null');
    }
  }

  @override
  Future<void> removeCalls() => _store.httpCalls.removeAllAsync();

  @override
  AliceStats getStats() => (
    total: _store.httpCalls.count(),
    successes:
        (_store.httpCalls.query()..link(
              CachedAliceHttpCall_.responseRel,
              CachedAliceHttpResponse_.status
                  .greaterOrEqual(200)
                  .and(CachedAliceHttpResponse_.status.lessThan(300)),
            ))
            .build()
            .count(),
    redirects:
        (_store.httpCalls.query()..link(
              CachedAliceHttpCall_.responseRel,
              CachedAliceHttpResponse_.status
                  .greaterOrEqual(300)
                  .and(CachedAliceHttpResponse_.status.lessThan(400)),
            ))
            .build()
            .count(),
    errors:
        (_store.httpCalls.query()..link(
              CachedAliceHttpCall_.responseRel,
              CachedAliceHttpResponse_.status
                  .greaterOrEqual(400)
                  .and(CachedAliceHttpResponse_.status.lessThan(600))
                  .and(CachedAliceHttpResponse_.status.equals(-1))
                  .and(CachedAliceHttpResponse_.status.equals(0)),
            ))
            .build()
            .count(),
    loading:
        _store.httpCalls
            .query(CachedAliceHttpCall_.loading.equals(true))
            .build()
            .count(),
  );
}
