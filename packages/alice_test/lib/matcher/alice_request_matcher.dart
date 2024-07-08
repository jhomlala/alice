import 'package:alice/model/alice_form_data_file.dart';
import 'package:alice/model/alice_from_data_field.dart';
import 'package:alice/model/alice_http_request.dart';
import 'package:alice_test/matcher/form_data_field_matcher.dart';
import 'package:alice_test/matcher/form_data_file_matcher.dart';
import 'package:alice_test/matcher/header_matcher.dart';
import 'package:test/test.dart';

TypeMatcher<AliceHttpRequest> buildRequestMatcher({
  bool? checkTime,
  Map<String, String>? headers,
  String? contentType,
  Map<String, dynamic>? queryParameters,
  dynamic body,
  List<AliceFormDataField>? formDataFields,
  List<AliceFormDataFile>? formDataFiles,
}) {
  var matcher = const TypeMatcher<AliceHttpRequest>();
  if (checkTime == true) {
    matcher = matcher.having(
      (request) => request.time.millisecondsSinceEpoch,
      "time",
      greaterThan(0),
    );
  }
  if (headers != null) {
    for (var header in headers.entries) {
      matcher = matcher.having(
        (request) {
          return request.headers;
        },
        "header",
        HeaderMatcher(header),
      );
    }
  }
  if (contentType != null) {
    matcher = matcher.having(
      (request) => request.contentType,
      "contentType",
      equals(contentType),
    );
  }
  if (queryParameters != null) {
    matcher = matcher.having(
      (request) => request.queryParameters,
      "queryParameters",
      equals(queryParameters),
    );
  }
  if (body != null) {
    matcher = matcher.having((request) => request.body, "body", equals(body));
  }
  if (formDataFields != null) {
    for (var field in formDataFields) {
      matcher = matcher.having(
        (request) => request.formDataFields,
        "form data field",
        FormDataFieldMatcher(field),
      );
    }
  }
  if (formDataFiles != null) {
    for (var file in formDataFiles) {
      matcher = matcher.having(
        (request) => request.formDataFiles,
        "form data file",
        FormDataFileMatcher(file),
      );
    }
  }

  return matcher;
}
