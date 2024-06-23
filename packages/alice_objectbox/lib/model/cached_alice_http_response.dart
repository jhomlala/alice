import 'dart:convert' show jsonDecode, jsonEncode;

import 'package:alice/model/alice_http_response.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cached_alice_http_response.g.dart';

@JsonSerializable(explicitToJson: true)
class CachedAliceHttpResponse implements AliceHttpResponse {
  CachedAliceHttpResponse({
    this.status = 0,
    this.size = 0,
    DateTime? time,
    this.body,
    this.headers,
  }) : time = time ?? DateTime.now();

  @override
  int? status;

  @override
  int size;

  @override
  DateTime time;

  @override
  @JsonKey(toJson: jsonEncode, fromJson: jsonDecode)
  dynamic body;

  @override
  Map<String, String>? headers;

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
