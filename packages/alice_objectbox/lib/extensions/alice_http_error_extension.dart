import 'package:alice/model/alice_http_error.dart';
import 'package:alice_objectbox/model/cached_alice_http_error.dart';

extension AliceHttpErrorExtension on AliceHttpError {
  CachedAliceHttpError toCached() => CachedAliceHttpError()
    ..error = error
    ..stackTrace = stackTrace;
}
