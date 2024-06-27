import 'dart:convert' show jsonDecode, jsonEncode;

import 'package:alice/model/alice_http_response.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:objectbox/objectbox.dart';

part 'cached_alice_http_response.g.dart';

@Entity()
@JsonSerializable(explicitToJson: true)
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
  @JsonKey(includeFromJson: false, includeToJson: false)
  int objectId;

  @override
  int? status;

  @override
  int size;

  @override
  @Property(type: PropertyType.dateNano)
  DateTime time;

  @override
  @JsonKey(toJson: jsonEncode, fromJson: jsonDecode)
  @Transient()
  dynamic body;

  @JsonKey(includeFromJson: false, includeToJson: false)
  String? get dbBody => jsonEncode(body);

  set dbBody(String? value) => body = value != null ? jsonDecode(value) : null;

  @override
  @Transient()
  Map<String, String>? headers;

  @JsonKey(includeFromJson: false, includeToJson: false)
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

  factory CachedAliceHttpResponse.fromJson(Map<String, dynamic> json) =>
      _$CachedAliceHttpResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CachedAliceHttpResponseToJson(this);
}
