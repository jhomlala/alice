import 'dart:convert' show jsonDecode, jsonEncode;

import 'package:alice/model/alice_http_response.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class CachedAliceHttpResponse implements AliceHttpResponse {
  CachedAliceHttpResponse({
    this.objectId = 0,
    this.status = 0,
    this.size = 0,
    DateTime? time,
    this.body,
    this.headers,
  }) : time = time ?? DateTime.now();

  @Id()
  int objectId;

  @override
  int? status;

  @override
  int size;

  @override
  @Property(type: PropertyType.dateNano)
  DateTime time;

  @override
  @Transient()
  dynamic body;

  String? get dbBody {
    if (body != null) {
      try {
        return jsonEncode(body);
      } catch (_) {
        return jsonEncode(body.toString());
      }
    }
    return null;
  }

  set dbBody(String? value) => body = value != null ? jsonDecode(value) : null;

  @override
  @Transient()
  Map<String, String>? headers;

  String? get dbHeaders => headers != null ? jsonEncode(headers) : null;

  set dbHeaders(String? value) => headers = value != null
      ? (jsonDecode(value) as Map<String, dynamic>?)?.map(
          (key, value) => MapEntry(key, value.toString()),
        )
      : null;

  factory CachedAliceHttpResponse.fromAliceHttpResponse(
    AliceHttpResponse response,
  ) =>
      CachedAliceHttpResponse(
        status: response.status,
        size: response.size,
        time: response.time,
        body: response.body,
        headers: response.headers,
      );
}
