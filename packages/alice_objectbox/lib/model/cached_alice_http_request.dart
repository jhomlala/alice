import 'dart:convert' show jsonDecode, jsonEncode;
import 'dart:io' show Cookie;
import 'package:alice/model/alice_form_data_file.dart';
import 'package:alice/model/alice_from_data_field.dart';
import 'package:alice/model/alice_http_request.dart';
import 'package:alice_objectbox/json_converter/alice_form_data_field_converter.dart';
import 'package:alice_objectbox/json_converter/alice_form_data_file_converter.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class CachedAliceHttpRequest implements AliceHttpRequest {
  CachedAliceHttpRequest({
    this.objectId = 0,
    this.size = 0,
    DateTime? time,
    this.headers = const <String, dynamic>{},
    this.body = '',
    this.contentType = '',
    this.cookies = const [],
    this.queryParameters = const <String, dynamic>{},
    this.formDataFiles,
    this.formDataFields,
  }) : time = time ?? DateTime.now();

  @Id()
  int objectId;

  @override
  int size;

  @override
  @Property(type: PropertyType.dateNano)
  DateTime time;

  @override
  @Transient()
  Map<String, dynamic> headers;

  String get dbHeaders => jsonEncode(headers);

  set dbHeaders(String value) =>
      headers = jsonDecode(value) as Map<String, dynamic>;

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
  String? contentType;

  @override
  @Transient()
  List<Cookie> cookies;

  List<String> get dbCookies =>
      cookies.map((Cookie cookie) => cookie.toString()).toList();

  set dbCookies(List<String> value) => cookies =
      value.map((String cookie) => Cookie.fromSetCookieValue(cookie)).toList();

  @override
  @Transient()
  Map<String, dynamic> queryParameters;

  String get dbQueryParameters => jsonEncode(queryParameters);

  set dbQueryParameters(String value) =>
      queryParameters = jsonDecode(value) as Map<String, dynamic>;

  @override
  @Transient()
  List<AliceFormDataFile>? formDataFiles;

  List<String>? get dbFormDataFiles => formDataFiles
      ?.map(
        (AliceFormDataFile file) =>
            jsonEncode(AliceFormDataFileConverter.instance.toJson(file)),
      )
      .toList();

  set dbFormDataFiles(List<String>? value) => formDataFiles = value
      ?.map(
        (String file) =>
            AliceFormDataFileConverter.instance.fromJson(jsonDecode(file)),
      )
      .toList();

  @override
  @Transient()
  List<AliceFormDataField>? formDataFields;

  List<String>? get dbFormDataFields => formDataFields
      ?.map(
        (AliceFormDataField field) =>
            jsonEncode(AliceFormDataFieldConverter.instance.toJson(field)),
      )
      .toList();

  set dbFormDataFields(List<String>? value) => formDataFields = value
      ?.map(
        (String field) =>
            AliceFormDataFieldConverter.instance.fromJson(jsonDecode(field)),
      )
      .toList();

  factory CachedAliceHttpRequest.fromAliceHttpRequest(
    AliceHttpRequest request,
  ) =>
      CachedAliceHttpRequest(
        size: request.size,
        time: request.time,
        headers: request.headers,
        body: request.body,
        contentType: request.contentType,
        cookies: request.cookies,
        queryParameters: request.queryParameters,
        formDataFiles: request.formDataFiles,
        formDataFields: request.formDataFields,
      );
}
