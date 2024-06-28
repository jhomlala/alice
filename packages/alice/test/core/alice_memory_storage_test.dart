import 'package:alice/core/alice_memory_storage.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_http_request.dart';
import 'package:alice/model/alice_http_response.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  late AliceMemoryStorage storage;
  setUp(() {
    storage = AliceMemoryStorage(maxCallsCount: 1000);
  });

  group("AliceMemoryStorage", () {
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
  });
}
