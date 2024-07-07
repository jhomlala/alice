import 'package:alice/model/alice_http_error.dart';
import 'package:test/test.dart';

TypeMatcher<AliceHttpError> buildErrorMatcher(
    {bool? checkError, bool? checkStacktrace}) {
  var matcher = const TypeMatcher<AliceHttpError>();
  if (checkError == true) {
    matcher = matcher.having((error) => error.error, "error", isNotEmpty);
  }
  if (checkStacktrace == true) {
    matcher = matcher.having((error) => error.error, "stackTrace", isNotEmpty);
  }

  return matcher;
}
