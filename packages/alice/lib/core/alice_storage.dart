import 'dart:async' show FutureOr;

import 'package:alice/core/alice_core.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_http_error.dart';
import 'package:alice/model/alice_http_response.dart';

typedef AliceStats = ({
  int total,
  int successes,
  int redirects,
  int errors,
  int loading,
});

abstract interface class AliceStorage {
  abstract final Stream<List<AliceHttpCall>> callsStream;

  abstract final int maxCallsCount;

  List<AliceHttpCall> getCalls();

  AliceStats getStats();

  AliceHttpCall? selectCall(int requestId);

  FutureOr<void> addCall(AliceHttpCall call);

  FutureOr<void> addError(AliceHttpError error, int requestId);

  FutureOr<void> addResponse(AliceHttpResponse response, int requestId);

  FutureOr<void> addHttpCall(AliceHttpCall aliceHttpCall);

  FutureOr<void> removeCalls();

  void subscribeToCallChanges(AliceOnCallsChanged callback);
}
