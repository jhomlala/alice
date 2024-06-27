import 'dart:convert' show jsonDecode, jsonEncode;

import 'package:alice/model/alice_http_error.dart';
import 'package:alice_objectbox/json_converter/stack_trace_converter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:objectbox/objectbox.dart';

part 'cached_alice_http_error.g.dart';

@Entity()
@JsonSerializable(explicitToJson: true)
@StackTraceConverter.instance
class CachedAliceHttpError implements AliceHttpError {
  CachedAliceHttpError({
    this.objectId = 0,
  });

  @Id()
  @JsonKey(includeFromJson: false, includeToJson: false)
  int objectId;

  @override
  @JsonKey(toJson: jsonEncode, fromJson: jsonDecode)
  @Transient()
  dynamic error;

  @JsonKey(includeFromJson: false, includeToJson: false)
  String? get dbError => jsonEncode(error);

  set dbError(String? value) =>
      error = value != null ? jsonDecode(value) : null;

  @override
  @Transient()
  StackTrace? stackTrace;

  @JsonKey(includeFromJson: false, includeToJson: false)
  String? get dbStackTrace => stackTrace.toString();

  set dbStackTrace(String? value) =>
      stackTrace = value != null ? StackTrace.fromString(value) : null;

  factory CachedAliceHttpError.fromAliceHttpError(AliceHttpError error) {
    return CachedAliceHttpError()
      ..error = error.error
      ..stackTrace = error.stackTrace;
  }

  factory CachedAliceHttpError.fromJson(Map<String, dynamic> json) =>
      _$CachedAliceHttpErrorFromJson(json);

  Map<String, dynamic> toJson() => _$CachedAliceHttpErrorToJson(this);
}
