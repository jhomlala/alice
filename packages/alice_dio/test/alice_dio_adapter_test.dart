import 'package:alice/core/alice_core.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_http_request.dart';
import 'package:alice/model/alice_http_response.dart';
import 'package:alice_dio/alice_dio_adapter.dart';
import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'alice_core_mock.dart';

void main() {
  late AliceCore aliceCore;
  late AliceDioAdapter aliceDioAdapter;
  late Dio dio;
  setUp(() {
    registerFallbackValue(AliceHttpCall(0));
    registerFallbackValue(AliceHttpResponse());
    aliceCore = AliceCoreMock();
    when(() => aliceCore.addCall(any())).thenAnswer((_) => {});
    when(() => aliceCore.addResponse(any(), any())).thenAnswer((_) => {});
    aliceDioAdapter = AliceDioAdapter();
    aliceDioAdapter.injectCore(aliceCore);

    dio = Dio(BaseOptions(followRedirects: false))
      ..interceptors.add(aliceDioAdapter);
  });

  group("AliceDioAdapter", () {
    test("should handle GET call with json response", () async {
      await dio.get<void>('https://httpbin.org/json',
          options: Options(headers: {"Content-Type": "application/json"}));

      final requestMatcher = const TypeMatcher<AliceHttpRequest>()
          .having((call) => call.time.millisecondsSinceEpoch, "Time is set",
              greaterThan(0))
          .having(
            (call) => call.headers,
            "Headers are set",
            {"Content-Type": "application/json"},
          )
          .having(
            (call) => call.contentType,
            "Content type is set",
            "application/json",
          )
          .having(
            (call) => call.queryParameters,
            "Query params are not set",
            {},
          );

      final responseMatcher = const TypeMatcher<AliceHttpResponse>().having(
          (call) => call.time.millisecondsSinceEpoch,
          "Time is set",
          greaterThan(0));

      final callMatcher = const TypeMatcher<AliceHttpCall>()
          .having((call) => call.id, "Id is set", greaterThan(0))
          .having((call) => call.createdTime.millisecondsSinceEpoch,
              "Created time is set", greaterThan(0))
          .having((call) => call.secure, "Is secured", equals(true))
          .having((call) => call.loading, "Is loading", equals(true))
          .having((call) => call.client, "Client is set", equals("Dio"))
          .having((call) => call.method, "Method is set", equals("GET"))
          .having((call) => call.endpoint, "Endpoint is set", equals("/json"))
          .having((call) => call.server, "Server is set", equals("httpbin.org"))
          .having((call) => call.uri, "Uri is set",
              equals("https://httpbin.org/json"))
          .having((call) => call.duration, "Duration is 0", equals(0))
          .having((call) => call.request, "Request matcher", requestMatcher)
          .having((call) => call.response, "Response matcher", responseMatcher);

      // verify(() => aliceCore.addCall(AliceHttpCall(0)));
      verify(() => aliceCore.addCall(any(that: callMatcher)));
    });
  });
}
