import 'package:alice/model/alice_http_response.dart';
import 'package:alice_test/matcher/header_matcher.dart';
import 'package:test/test.dart';

TypeMatcher<AliceHttpResponse> buildResponseMatcher({
  int? status,
  int? size,
  bool? checkTime,
  String? body,
  Map<String, String>? headers,
}) {
  var matcher = const TypeMatcher<AliceHttpResponse>();
  if (status != null) {
    matcher = matcher.having(
      (response) => response.status,
      "status",
      equals(status),
    );
  }
  if (size != null) {
    matcher = matcher.having((response) => response.size, "size", equals(size));
  }
  if (checkTime == true) {
    matcher = matcher.having(
      (response) => response.time.millisecondsSinceEpoch,
      "time",
      greaterThan(0),
    );
  }
  if (body != null) {
    matcher = matcher.having(
      (response) => response.body.toString(),
      "body",
      equals(body),
    );
  }
  if (headers != null) {
    for (var header in headers.entries) {
      matcher = matcher.having(
        (response) {
          return response.headers;
        },
        "header",
        HeaderMatcher(header),
      );
    }
  }
  return matcher;
}
