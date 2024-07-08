import 'package:alice/core/alice_core.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_http_error.dart';
import 'package:alice/model/alice_http_response.dart';
import 'package:alice/model/alice_log.dart';
import 'package:alice_chopper/alice_chopper_adapter.dart';
import 'package:alice_test/alice_test.dart';
import 'package:chopper/chopper.dart';
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;

void main() {
  final baseUrl = Uri.parse('https://test.com');
  late AliceCore aliceCore;
  late AliceChopperAdapter aliceChopperAdapter;
  late ChopperClient chopperClient;
  setUp(() {
    registerFallbackValue(AliceHttpCall(0));
    registerFallbackValue(AliceHttpResponse());
    registerFallbackValue(AliceHttpError());
    registerFallbackValue(AliceLog(message: ''));

    aliceCore = AliceCoreMock();
    when(() => aliceCore.addCall(any())).thenAnswer((_) => {});
    when(() => aliceCore.addResponse(any(), any())).thenAnswer((_) => {});
    when(() => aliceCore.addError(any(), any())).thenAnswer((_) => {});
    when(() => aliceCore.addLog(any())).thenAnswer((_) => {});

    aliceChopperAdapter = AliceChopperAdapter();
    aliceChopperAdapter.injectCore(aliceCore);
  });

  group('AliceChopperAdapter', () {
    test("should handle GET call with json response", () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          '{"result": "ok"}',
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      chopperClient = ChopperClient(
          baseUrl: baseUrl,
          client: mockClient,
          interceptors: [aliceChopperAdapter]);

      await chopperClient.get(
        Uri(
          path: 'json',
        ),
        headers: {'content-type': 'application/json'},
      );

      final requestMatcher = buildRequestMatcher(
        checkTime: true,
        headers: {"content-type": "application/json"},
        contentType: "application/json",
        queryParameters: {},
      );

      final responseMatcher = buildResponseMatcher(checkTime: true);

      final callMatcher = buildCallMatcher(
          checkId: true,
          checkTime: true,
          secured: true,
          loading: true,
          client: 'Chopper',
          method: 'GET',
          endpoint: '/json',
          server: 'test.com',
          uri: 'https://test.com/json',
          duration: 0,
          request: requestMatcher,
          response: responseMatcher);

      verify(() => aliceCore.addCall(any(that: callMatcher)));

      final nextResponseMatcher = buildResponseMatcher(
        status: 200,
        size: 16,
        checkTime: true,
        body: '{"result": "ok"}',
        headers: {'content-type': 'application/json'},
      );

      verify(
          () => aliceCore.addResponse(any(that: nextResponseMatcher), any()));
    });

    test("should handle POST call with json response", () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          '{"result": "ok"}',
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      chopperClient = ChopperClient(
          baseUrl: baseUrl,
          client: mockClient,
          interceptors: [aliceChopperAdapter]);

      await chopperClient.post(
        Uri(
          path: 'json',
          queryParameters: {'sort': 'asc'},
        ),
        body: '{"data":"test"}',
        headers: {'content-type': 'application/json'},
      );

      final requestMatcher = buildRequestMatcher(
        checkTime: true,
        headers: {"content-type": "application/json"},
        contentType: "application/json",
        body: '{"data":"test"}',
        queryParameters: {"sort": ["asc"]},
      );

      final responseMatcher = buildResponseMatcher(checkTime: true);

      final callMatcher = buildCallMatcher(
        checkId: true,
        checkTime: true,
        secured: true,
        loading: true,
        client: 'Chopper',
        method: 'POST',
        endpoint: '/json',
        server: 'test.com',
        uri: 'https://test.com/json?sort=asc',
        duration: 0,
        request: requestMatcher,
        response: responseMatcher,
      );

      verify(() => aliceCore.addCall(any(that: callMatcher)));

      final nextResponseMatcher = buildResponseMatcher(
        status: 200,
        size: 16,
        checkTime: true,
        body: '{"result": "ok"}',
        headers: {'content-type': 'application/json'},
      );

      verify(
          () => aliceCore.addResponse(any(that: nextResponseMatcher), any()));
    });
  });
}
