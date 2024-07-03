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

  static AliceHttpCall getFilledHttpCall() {
    final httpCall = AliceHttpCall(DateTime.now().millisecondsSinceEpoch)
      ..loading = false;

    final request = AliceHttpRequest();
    request.headers = {};
    request.body = '{"id": 0}';
    request.contentType = "application/json";
    request.size = 0;
    request.time = DateTime.now();
    httpCall.request = request;
    final response = AliceHttpResponse();
    response.headers = {};
    response.body = '{"id": 0}';
    response.size = 0;
    response.time = DateTime.now();

    httpCall.response = response;
    httpCall.method = "POST";
    httpCall.endpoint = "/test";
    httpCall.server = "https://test.com";
    httpCall.secure = true;
    return httpCall;
  }
}
