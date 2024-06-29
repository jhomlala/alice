import 'package:alice/core/alice_memory_storage.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_http_request.dart';
import 'package:alice/model/alice_http_response.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

import '../mocked_data.dart';

void main() {
  late AliceMemoryStorage storage;
  setUp(() {
    storage = AliceMemoryStorage(maxCallsCount: 1000);
  });

  group("AliceMemoryStorage", () {
    test("should return HTTP call stats", () {
      expect(storage.getStats(), (
        total: 0,
        successes: 0,
        redirects: 0,
        errors: 0,
        loading: 0,
      ));

      storage
          .addCall(MockedData.getHttpCallWithResponseStatus(statusCode: 200));
      storage
          .addCall(MockedData.getHttpCallWithResponseStatus(statusCode: 201));
      storage
          .addCall(MockedData.getHttpCallWithResponseStatus(statusCode: 300));
      storage
          .addCall(MockedData.getHttpCallWithResponseStatus(statusCode: 301));
      storage
          .addCall(MockedData.getHttpCallWithResponseStatus(statusCode: 400));
      storage
          .addCall(MockedData.getHttpCallWithResponseStatus(statusCode: 404));
      storage
          .addCall(MockedData.getHttpCallWithResponseStatus(statusCode: 500));
      storage.addCall(MockedData.getLoadingHttpCall());

      expect(storage.getStats(), (
        total: 8,
        successes: 2,
        redirects: 2,
        errors: 3,
        loading: 1,
      ));
    });

    test("should save HTTP calls", () {
      final httpCall = AliceHttpCall(1);
      httpCall.request = AliceHttpRequest();
      httpCall.response = AliceHttpResponse();

      storage.addCall(httpCall);
      expect(storage.getCalls(), [httpCall]);

      final anotherHttpCall = AliceHttpCall(1);
      anotherHttpCall.request = AliceHttpRequest();
      anotherHttpCall.response = AliceHttpResponse();

      storage.addCall(anotherHttpCall);
      expect(storage.getCalls(), [httpCall, anotherHttpCall]);
    });

    test("should replace HTTP call if over limit", () {
      storage = AliceMemoryStorage(maxCallsCount: 2);
      final firstCall = MockedData.getLoadingHttpCall();
      final secondCall = MockedData.getLoadingHttpCall();
      final thirdCall = MockedData.getLoadingHttpCall();

      storage.addCall(firstCall);
      storage.addCall(secondCall);
      storage.addCall(thirdCall);

      expect(storage.getCalls(), [secondCall, thirdCall]);
    });
  });
}
