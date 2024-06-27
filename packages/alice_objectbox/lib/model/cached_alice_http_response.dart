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

  String? get dbBody => jsonEncode(body);

  set dbBody(String? value) => body = value != null ? jsonDecode(value) : null;

  @override
  @Transient()
  Map<String, String>? headers;

  String? get dbHeaders => jsonEncode(headers);

  set dbHeaders(String? value) =>
      headers = value != null ? jsonDecode(value) : null;

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
