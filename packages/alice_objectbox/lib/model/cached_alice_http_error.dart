import 'dart:convert' show jsonDecode, jsonEncode;

import 'package:alice/model/alice_http_error.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class CachedAliceHttpError implements AliceHttpError {
  CachedAliceHttpError({
    this.objectId = 0,
  });

  @Id()
  int objectId;

  @override
  @Transient()
  dynamic error;

  String? get dbError {
    if (error != null) {
      try {
        return jsonEncode(error);
      } catch (_) {
        return jsonEncode(error.toString());
      }
    }
    return null;
  }

  set dbError(String? value) =>
      error = value != null ? jsonDecode(value) : null;

  @override
  @Transient()
  StackTrace? stackTrace;

  String? get dbStackTrace => stackTrace?.toString();

  set dbStackTrace(String? value) =>
      stackTrace = value != null ? StackTrace.fromString(value) : null;

  factory CachedAliceHttpError.fromAliceHttpError(AliceHttpError error) {
    return CachedAliceHttpError()
      ..error = error.error
      ..stackTrace = error.stackTrace;
  }
}
