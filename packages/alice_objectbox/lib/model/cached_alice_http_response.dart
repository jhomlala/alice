import 'dart:convert' show jsonDecode, jsonEncode;

import 'package:alice/model/alice_http_response.dart';
import 'package:meta/meta.dart';
import 'package:objectbox/objectbox.dart';

/// ObjectBox [Entity] of [AliceHttpResponse].
@Entity()
// ignore: must_be_immutable
class CachedAliceHttpResponse implements AliceHttpResponse {
  CachedAliceHttpResponse({
    this.objectId = 0,
    this.status = 0,
    this.size = 0,
    DateTime? time,
    this.body,
    this.headers,
  }) : time = time ?? DateTime.now();

  /// ObjectBox internal ID.
  @internal
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

  /// Custom data type converter of [body].
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

  /// Custom data type converter of [body].
  set dbBody(String? value) => body = value != null ? jsonDecode(value) : null;

  @override
  @Transient()
  Map<String, String>? headers;

  /// Custom data type converter of [headers].
  String? get dbHeaders => headers != null ? jsonEncode(headers) : null;

  /// Custom data type converter of [headers].
  set dbHeaders(String? value) =>
      headers =
          value != null
              ? (jsonDecode(value) as Map<String, dynamic>?)?.map(
                (key, value) => MapEntry(key, value.toString()),
              )
              : null;

  @override
  List<Object?> get props => [status, size, time, body, headers];

  @override
  bool? get stringify => true;
}
