import 'package:alice/model/alice_http_error.dart';
import 'package:alice_objectbox/model/cached_alice_http_error.dart';

/// Extension methods for [AliceHttpError].
extension AliceHttpErrorExtension on AliceHttpError {
  /// Converts [AliceHttpError] to [CachedAliceHttpError].
  CachedAliceHttpError toCached() =>
      CachedAliceHttpError()
        ..error = error
        ..stackTrace = stackTrace;
}
