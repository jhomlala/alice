import 'package:json_annotation/json_annotation.dart';

class StackTraceConverter implements JsonConverter<StackTrace?, String?> {
  const StackTraceConverter();

  static const StackTraceConverter instance = StackTraceConverter();

  @override
  StackTrace? fromJson(String? json) =>
      json != null ? StackTrace.fromString(json) : null;

  @override
  String? toJson(StackTrace? object) => object?.toString();
}
