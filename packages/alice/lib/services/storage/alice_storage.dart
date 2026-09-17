import 'package:alice/model/alice_http_call.dart';
import 'dart:async' show FutureOr;

import 'package:alice/model/alice_http_error.dart';
import 'package:alice/model/alice_http_response.dart';

/// Definition of call stats.
typedef AliceStats =
    ({int total, int successes, int redirects, int errors, int loading});

/// Definition of storage
abstract interface class AliceStorage {
  /// Stream which returns all HTTP calls on change.
  abstract final Stream<List<AliceHttpCall>> callsStream;

  /// Max calls number which should be stored.
  abstract final int maxCallsCount;

  /// Returns all HTTP calls.
  List<AliceHttpCall> getCalls();

  /// Returns stats based on calls.
  AliceStats getStats();

  /// Searches for call with specific [requestId]. It may return null.
  AliceHttpCall? selectCall(int requestId);

  /// Adds new call to calls list.
  FutureOr<void> addCall(AliceHttpCall call);

  /// Adds error to a specific call.
  FutureOr<void> addError(AliceHttpError error, int requestId);

  /// Adds response to a specific call.
  FutureOr<void> addResponse(AliceHttpResponse response, int requestId);

  /// Removes all calls.
  FutureOr<void> removeCalls();
}
