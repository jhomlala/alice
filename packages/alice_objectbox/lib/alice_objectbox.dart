import 'dart:math' show max;

import 'package:alice/alice.dart';
import 'package:alice_objectbox/alice_objectboxstore.dart';
import 'package:alice_objectbox/extensions/alice_http_call_extension.dart';
import 'package:alice_objectbox/model/cached_alice_http_call.dart';
import 'package:alice_objectbox/objectbox.g.dart';

/// Implementation of [AliceStorage] using ObjectBox.
class AliceObjectBox implements AliceStorage {
  const AliceObjectBox({
    required this.store,
    required this.maxCallsCount,
  }) : ,
       assert(maxCallsCount > 0, 'Max calls count should be greater than 0');

  final AliceObjectBoxStore store;

  @override
  final int maxCallsCount;

  @override
  Stream<List<AliceHttpCall>> get callsStream =>
      store.httpCalls
          .query()
          .order<int>(CachedAliceHttpCall_.createdTime, flags: Order.descending)
          .watch(triggerImmediately: true)
          .map((Query<CachedAliceHttpCall> query) => query.find())
          .asBroadcastStream();

  @override
  List<AliceHttpCall> getCalls() => store.httpCalls.getAll();

  @override
  CachedAliceHttpCall? selectCall(int requestId) =>
      store.httpCalls
          .query(CachedAliceHttpCall_.id.equals(requestId))
          .build()
          .findFirst();

  Future<void> _removeOverQuota() async {
    if (maxCallsCount > 0 && store.httpCalls.count() >= maxCallsCount) {
      final Query<CachedAliceHttpCall> overQuota =
          store.httpCalls
              .query()
              .order<int>(
                CachedAliceHttpCall_.createdTime,
                flags: Order.descending,
              )
              .build()
            ..offset = max(maxCallsCount - 1, 0);

      final List<int> overQuotaIds = await overQuota.findIdsAsync();

      if (overQuotaIds.isNotEmpty) {
        store.httpCalls.removeManyAsync(overQuotaIds);
      }
    }
  }

  @override
  void addCall(AliceHttpCall call) {
    _removeOverQuota();

    store.httpCalls.put(call.toCached());
  }

  @override
  void addError(AliceHttpError error, int requestId) {
    final CachedAliceHttpCall? selectedCall = selectCall(requestId);

    if (selectedCall != null) {
      selectedCall.error = error;

      store.httpCalls.put(selectedCall);
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

      store.httpCalls.put(selectedCall);
    } else {
      AliceUtils.log('Selected call is null');
    }
  }

  @override
  Future<void> removeCalls() => store.httpCalls.removeAllAsync();

  @override
  AliceStats getStats() => (
    total: store.httpCalls.count(),
    successes:
        (store.httpCalls.query()..link(
              CachedAliceHttpCall_.responseRel,
              CachedAliceHttpResponse_.status
                  .greaterOrEqual(200)
                  .and(CachedAliceHttpResponse_.status.lessThan(300)),
            ))
            .build()
            .count(),
    redirects:
        (store.httpCalls.query()..link(
              CachedAliceHttpCall_.responseRel,
              CachedAliceHttpResponse_.status
                  .greaterOrEqual(300)
                  .and(CachedAliceHttpResponse_.status.lessThan(400)),
            ))
            .build()
            .count(),
    errors:
        (store.httpCalls.query()..link(
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
        store.httpCalls
            .query(CachedAliceHttpCall_.loading.equals(true))
            .build()
            .count(),
  );
}
