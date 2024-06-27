// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cached_alice_http_call.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CachedAliceHttpCall _$CachedAliceHttpCallFromJson(Map<String, dynamic> json) =>
    CachedAliceHttpCall(
      (json['id'] as num).toInt(),
      client: json['client'] as String? ?? '',
      loading: json['loading'] as bool? ?? true,
      secure: json['secure'] as bool? ?? false,
      method: json['method'] as String? ?? '',
      endpoint: json['endpoint'] as String? ?? '',
      server: json['server'] as String? ?? '',
      uri: json['uri'] as String? ?? '',
      duration: (json['duration'] as num?)?.toInt() ?? 0,
    )
      ..createdTime = DateTime.parse(json['createdTime'] as String)
      ..request = CachedAliceHttpRequest.fromJson(
          json['request'] as Map<String, dynamic>)
      ..response = CachedAliceHttpResponse.fromJson(
          json['response'] as Map<String, dynamic>)
      ..error =
          CachedAliceHttpError.fromJson(json['error'] as Map<String, dynamic>);

Map<String, dynamic> _$CachedAliceHttpCallToJson(
        CachedAliceHttpCall instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdTime': instance.createdTime.toIso8601String(),
      'client': instance.client,
      'loading': instance.loading,
      'secure': instance.secure,
      'method': instance.method,
      'endpoint': instance.endpoint,
      'server': instance.server,
      'uri': instance.uri,
      'duration': instance.duration,
      'request': CachedAliceHttpCall._aliceHttpRequestToJson(instance.request),
      'response':
          CachedAliceHttpCall._aliceHttpResponseToJson(instance.response),
      'error': CachedAliceHttpCall._aliceHttpErrorToJson(instance.error),
    };
