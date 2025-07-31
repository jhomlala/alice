import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_http_request.dart';
import 'package:alice/model/alice_http_response.dart';
import 'package:test/test.dart';

TypeMatcher<AliceHttpCall> buildCallMatcher({
  bool? checkId,
  bool? checkTime,
  bool? secured,
  bool? loading,
  String? client,
  String? method,
  String? endpoint,
  String? server,
  String? uri,
  int? duration,
  TypeMatcher<AliceHttpRequest>? request,
  TypeMatcher<AliceHttpResponse>? response,
}) {
  var matcher = const TypeMatcher<AliceHttpCall>();
  if (checkId == true) {
    matcher = matcher.having((call) => call.id, "id", greaterThan(0));
  }
  if (checkTime == true) {
    matcher = matcher.having(
      (call) => call.createdTime.millisecondsSinceEpoch,
      "createdTime",
      greaterThan(0),
    );
  }
  if (secured != null) {
    matcher = matcher.having((call) => call.secure, "secure", equals(secured));
  }
  if (loading != null) {
    matcher = matcher.having(
      (call) => call.loading,
      "loading",
      equals(loading),
    );
  }
  if (client != null) {
    matcher = matcher.having((call) => call.client, "client", equals(client));
  }
  if (method != null) {
    matcher = matcher.having((call) => call.method, "method", equals(method));
  }
  if (endpoint != null) {
    matcher = matcher.having(
      (call) => call.endpoint,
      "endpoint",
      equals(endpoint),
    );
  }
  if (server != null) {
    matcher = matcher.having((call) => call.server, "server", equals(server));
  }
  if (uri != null) {
    matcher = matcher.having((call) => call.uri, "uri", equals(uri));
  }
  if (duration != null) {
    matcher = matcher.having(
      (call) => call.duration,
      "duration",
      equals(duration),
    );
  }
  if (request != null) {
    matcher = matcher.having(
      (call) => call.request,
      "request",
      equals(request),
    );
  }
  if (response != null) {
    matcher = matcher.having(
      (call) => call.response,
      "response",
      equals(response),
    );
  }
  return matcher;
}
