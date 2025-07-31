import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_http_request.dart';
import 'package:alice/model/alice_http_response.dart';

class MockedData {
  static AliceHttpCall getHttpCallWithResponseStatus({
    required int statusCode,
  }) {
    final httpCall = AliceHttpCall(DateTime.now().millisecondsSinceEpoch)
      ..loading = false;
    httpCall.request = AliceHttpRequest();
    httpCall.response = AliceHttpResponse()..status = statusCode;
    return httpCall;
  }

  static AliceHttpCall getLoadingHttpCall() {
    final httpCall = AliceHttpCall(DateTime.now().millisecondsSinceEpoch);
    return httpCall;
  }

  static AliceHttpCall getHttpCall({required int id}) {
    final httpCall = AliceHttpCall(id);
    return httpCall;
  }

  static AliceHttpCall getFilledHttpCall() =>
      AliceHttpCall(DateTime.now().microsecondsSinceEpoch)
        ..loading = false
        ..request =
            (AliceHttpRequest()
              ..headers = {}
              ..body = '{"id": 0}'
              ..contentType = "application/json"
              ..size = 0
              ..time = DateTime.now())
        ..response =
            (AliceHttpResponse()
              ..headers = {}
              ..body = '{"id": 0}'
              ..size = 0
              ..time = DateTime.now())
        ..method = "POST"
        ..endpoint = "/test"
        ..server = "https://test.com"
        ..secure = true;
}
