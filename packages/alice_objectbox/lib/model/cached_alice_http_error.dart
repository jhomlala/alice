import 'dart:convert' show jsonDecode, jsonEncode;

import 'package:alice/model/alice_http_error.dart';
import 'package:meta/meta.dart';
import 'package:objectbox/objectbox.dart';

/// ObjectBox [Entity] of [AliceHttpError].
@Entity()
// ignore: must_be_immutable
class CachedAliceHttpError implements AliceHttpError {
  CachedAliceHttpError({this.objectId = 0});

  /// ObjectBox internal ID.
  @internal
  @Id()
  int objectId;

  @override
  @Transient()
  dynamic error;

  /// Custom data type converter of [error].
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

  /// Custom data type converter of [error].
  set dbError(String? value) =>
      error = value != null ? jsonDecode(value) : null;

  @override
  @Transient()
  StackTrace? stackTrace;

  /// Custom data type converter of [error].
  String? get dbStackTrace => stackTrace?.toString();

  /// Custom data type converter of [error].
  set dbStackTrace(String? value) =>
      stackTrace = value != null ? StackTrace.fromString(value) : null;

  @override
  List<Object?> get props => [error, stackTrace];

  @override
  bool? get stringify => true;
}
