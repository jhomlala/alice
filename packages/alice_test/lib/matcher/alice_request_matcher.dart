import 'package:alice/model/alice_http_request.dart';
import 'package:alice_test/matcher/header_matcher.dart';
import 'package:test/test.dart';

TypeMatcher<AliceHttpRequest> buildRequestMatcher({
  bool? checkTime,
  Map<String, String>? headers,
  String? contentType,
  Map<String, dynamic>? queryParameters,
}) {
  var matcher = const TypeMatcher<AliceHttpRequest>();
  if (checkTime == true) {
    matcher = matcher.having((request) => request.time.millisecondsSinceEpoch,
        "time", greaterThan(0));
  }
  if (headers != null) {
    for (var header in headers.entries) {
      matcher = matcher.having((request) {
        return request.headers;
      }, "header", HeaderMatcher(header));
    }
  }
  if (contentType != null) {
    matcher = matcher.having(
        (request) => request.contentType, "contentType", equals(contentType));
  }
  if (queryParameters != null) {
    matcher = matcher.having((request) => request.queryParameters,
        "queryParameters", equals(queryParameters));
  }

  return matcher;
}
