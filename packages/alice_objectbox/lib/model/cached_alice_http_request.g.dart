// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cached_alice_http_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CachedAliceHttpRequest _$CachedAliceHttpRequestFromJson(
        Map<String, dynamic> json) =>
    CachedAliceHttpRequest(
      size: (json['size'] as num?)?.toInt() ?? 0,
      time:
          json['time'] == null ? null : DateTime.parse(json['time'] as String),
      headers:
          json['headers'] as Map<String, dynamic>? ?? const <String, dynamic>{},
      body: json['body'] == null ? '' : jsonDecode(json['body'] as String),
      contentType: json['contentType'] as String? ?? '',
      cookies: (json['cookies'] as List<dynamic>?)
              ?.map((e) => CookieConverter.instance.fromJson(e as String))
              .toList() ??
          const [],
      queryParameters: json['queryParameters'] as Map<String, dynamic>? ??
          const <String, dynamic>{},
      formDataFiles: (json['formDataFiles'] as List<dynamic>?)
          ?.map((e) => AliceFormDataFileConverter.instance
              .fromJson(e as Map<String, dynamic>))
          .toList(),
      formDataFields: (json['formDataFields'] as List<dynamic>?)
          ?.map((e) => AliceFormDataFieldConverter.instance
              .fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CachedAliceHttpRequestToJson(
        CachedAliceHttpRequest instance) =>
    <String, dynamic>{
      'size': instance.size,
      'time': instance.time.toIso8601String(),
      'headers': instance.headers,
      'body': jsonEncode(instance.body),
      'contentType': instance.contentType,
      'cookies': instance.cookies.map(CookieConverter.instance.toJson).toList(),
      'queryParameters': instance.queryParameters,
      'formDataFiles': instance.formDataFiles
          ?.map(AliceFormDataFileConverter.instance.toJson)
          .toList(),
      'formDataFields': instance.formDataFields
          ?.map(AliceFormDataFieldConverter.instance.toJson)
          .toList(),
    };
