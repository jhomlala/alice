// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cached_alice_http_error.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CachedAliceHttpError _$CachedAliceHttpErrorFromJson(
        Map<String, dynamic> json) =>
    CachedAliceHttpError()
      ..error = jsonDecode(json['error'] as String)
      ..stackTrace =
          StackTraceConverter.instance.fromJson(json['stackTrace'] as String?);

Map<String, dynamic> _$CachedAliceHttpErrorToJson(
        CachedAliceHttpError instance) =>
    <String, dynamic>{
      'error': jsonEncode(instance.error),
      'stackTrace': StackTraceConverter.instance.toJson(instance.stackTrace),
    };
