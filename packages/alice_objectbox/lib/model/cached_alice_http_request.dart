import 'dart:convert' show jsonDecode, jsonEncode;
import 'dart:io' show Cookie;

import 'package:alice/model/alice_form_data_file.dart';
import 'package:alice/model/alice_from_data_field.dart';
import 'package:alice/model/alice_http_request.dart';
import 'package:alice/utils/alice_parser.dart';
import 'package:alice_objectbox/json_converter/alice_form_data_field_converter.dart';
import 'package:alice_objectbox/json_converter/alice_form_data_file_converter.dart';
import 'package:meta/meta.dart';
import 'package:objectbox/objectbox.dart';

/// ObjectBox [Entity] of [AliceHttpRequest].
@Entity()
// ignore: must_be_immutable
class CachedAliceHttpRequest implements AliceHttpRequest {
  CachedAliceHttpRequest({
    this.objectId = 0,
    this.size = 0,
    DateTime? time,
    this.headers = const <String, String>{},
    this.body = '',
    this.contentType = '',
    this.cookies = const [],
    this.queryParameters = const <String, dynamic>{},
    this.formDataFiles,
    this.formDataFields,
  }) : time = time ?? DateTime.now();

  /// ObjectBox internal ID.
  @internal
  @Id()
  int objectId;

  @override
  int size;

  @override
  @Property(type: PropertyType.dateNano)
  DateTime time;

  @override
  @Transient()
  Map<String, String> headers;

  /// Custom data type converter of [headers].
  String get dbHeaders => jsonEncode(headers);

  /// Custom data type converter of [headers].
  set dbHeaders(String value) =>
      headers = AliceParser.parseHeaders(headers: jsonDecode(value));
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
  String? contentType;

  @override
  @Transient()
  List<Cookie> cookies;

  /// Custom data type converter of [cookies].
  List<String> get dbCookies =>
      cookies.map((Cookie cookie) => cookie.toString()).toList();

  /// Custom data type converter of [cookies].
  set dbCookies(List<String> value) =>
      cookies =
          value
              .map((String cookie) => Cookie.fromSetCookieValue(cookie))
              .toList();

  @override
  @Transient()
  Map<String, dynamic> queryParameters;

  /// Custom data type converter of [queryParameters].
  String get dbQueryParameters => jsonEncode(queryParameters);

  /// Custom data type converter of [queryParameters].
  set dbQueryParameters(String value) =>
      queryParameters = jsonDecode(value) as Map<String, dynamic>;

  @override
  @Transient()
  List<AliceFormDataFile>? formDataFiles;

  /// Custom data type converter of [formDataFiles].
  List<String>? get dbFormDataFiles =>
      formDataFiles
          ?.map(
            (AliceFormDataFile file) =>
                jsonEncode(AliceFormDataFileConverter.instance.toJson(file)),
          )
          .toList();

  /// Custom data type converter of [formDataFiles].
  set dbFormDataFiles(List<String>? value) =>
      formDataFiles =
          value
              ?.map(
                (String file) => AliceFormDataFileConverter.instance.fromJson(
                  jsonDecode(file),
                ),
              )
              .toList();

  @override
  @Transient()
  List<AliceFormDataField>? formDataFields;

  /// Custom data type converter of [formDataFields].
  List<String>? get dbFormDataFields =>
      formDataFields
          ?.map(
            (AliceFormDataField field) =>
                jsonEncode(AliceFormDataFieldConverter.instance.toJson(field)),
          )
          .toList();

  /// Custom data type converter of [formDataFields].
  set dbFormDataFields(List<String>? value) =>
      formDataFields =
          value
              ?.map(
                (String field) => AliceFormDataFieldConverter.instance.fromJson(
                  jsonDecode(field),
                ),
              )
              .toList();

  @override
  List<Object?> get props => [
    size,
    time,
    headers,
    body,
    contentType,
    cookies,
    queryParameters,
    formDataFiles,
    formDataFields,
  ];

  @override
  bool? get stringify => true;
}
