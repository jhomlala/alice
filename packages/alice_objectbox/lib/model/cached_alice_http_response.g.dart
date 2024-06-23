// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cached_alice_http_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CachedAliceHttpResponse _$CachedAliceHttpResponseFromJson(
        Map<String, dynamic> json) =>
    CachedAliceHttpResponse(
      status: (json['status'] as num?)?.toInt() ?? 0,
      size: (json['size'] as num?)?.toInt() ?? 0,
      time:
          json['time'] == null ? null : DateTime.parse(json['time'] as String),
      body: jsonDecode(json['body'] as String),
      headers: (json['headers'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
    );

Map<String, dynamic> _$CachedAliceHttpResponseToJson(
        CachedAliceHttpResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'size': instance.size,
      'time': instance.time.toIso8601String(),
      'body': jsonEncode(instance.body),
      'headers': instance.headers,
    };
