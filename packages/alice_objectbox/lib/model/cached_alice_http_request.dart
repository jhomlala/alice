import 'dart:convert' show jsonDecode, jsonEncode;
import 'dart:io' show Cookie;
import 'package:alice/model/alice_form_data_file.dart';
import 'package:alice/model/alice_from_data_field.dart';
import 'package:alice/model/alice_http_request.dart';
import 'package:alice_objectbox/json_converter/alice_form_data_field_converter.dart';
import 'package:alice_objectbox/json_converter/alice_form_data_file_converter.dart';
import 'package:alice_objectbox/json_converter/cookie_converter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cached_alice_http_request.g.dart';

@JsonSerializable(explicitToJson: true)
@CookieConverter.instance
@AliceFormDataFileConverter.instance
@AliceFormDataFieldConverter.instance
class CachedAliceHttpRequest implements AliceHttpRequest {
  CachedAliceHttpRequest({
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

  @override
  int size;

  @override
  DateTime time;

  @override
  Map<String, dynamic> headers;

  @override
  @JsonKey(toJson: jsonEncode, fromJson: jsonDecode)
  dynamic body;

  @override
  String? contentType;

  @override
  List<Cookie> cookies;

  @override
  Map<String, dynamic> queryParameters;

  @override
  List<AliceFormDataFile>? formDataFiles;

  @override
  List<AliceFormDataField>? formDataFields;

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

  factory CachedAliceHttpRequest.fromJson(Map<String, dynamic> json) =>
      _$CachedAliceHttpRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CachedAliceHttpRequestToJson(this);
}
