import 'dart:convert' show jsonDecode, jsonEncode;

import 'package:alice/model/alice_http_error.dart';
import 'package:alice_objectbox/json_converter/stack_trace_converter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cached_alice_http_error.g.dart';

@JsonSerializable(explicitToJson: true)
@StackTraceConverter.instance
class CachedAliceHttpError implements AliceHttpError {
  CachedAliceHttpError();

  @override
  @JsonKey(toJson: jsonEncode, fromJson: jsonDecode)
  late dynamic error;

  @override
  StackTrace? stackTrace;

  factory CachedAliceHttpError.fromAliceHttpError(AliceHttpError error) {
    return CachedAliceHttpError()
      ..error = error.error
      ..stackTrace = error.stackTrace;
  }

  factory CachedAliceHttpError.fromJson(Map<String, dynamic> json) =>
      _$CachedAliceHttpErrorFromJson(json);

  Map<String, dynamic> toJson() => _$CachedAliceHttpErrorToJson(this);
}
