import 'dart:async';

import 'package:alice/alice.dart';
import 'package:alice/core/alice_adapter.dart';
import 'package:alice/core/alice_core.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_http_error.dart';
import 'package:alice/model/alice_http_response.dart';
import 'package:alice_graphql_client/alice_graphql_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gql/language.dart' as lang;
import 'package:gql_exec/gql_exec.dart';
import 'package:mocktail/mocktail.dart';

class MockAlice extends Mock implements Alice {}

class MockAliceCore extends Mock implements AliceCore {}

class AliceAdapterFake extends Fake implements AliceAdapter {}

void main() {
  late MockAlice mockAlice;
  late MockAliceCore mockAliceCore;

  setUpAll(() {
    registerFallbackValue(AliceHttpCall(0));
    registerFallbackValue(AliceHttpResponse());
    registerFallbackValue(AliceHttpError());
    registerFallbackValue(
      Request(
        operation: Operation(
          document: lang.parseString('query { __typename }'),
        ),
      ),
    );
    registerFallbackValue(AliceAdapterFake());
  });

  setUp(() {
    mockAlice = MockAlice();
    mockAliceCore = MockAliceCore();

    // Stub addAdapter to inject our mock core
    when(() => mockAlice.addAdapter(any())).thenAnswer((invocation) {
      final adapter = invocation.positionalArguments[0] as AliceAdapter;
      adapter.injectCore(mockAliceCore);
    });
  });

  group('AliceGraphQLLink', () {
    test('logs request and response correctly with URL', () async {
      final link = AliceGraphQLLink(
        alice: mockAlice,
        url: 'https://api.example.com/graphql/v1',
      );
      final query = lang.parseString('query GetUser { user { id name } }');
      final request = Request(
        operation: Operation(document: query, operationName: 'GetUser'),
      );

      final responseData = {
        'user': {'id': '1', 'name': 'John'},
      };
      final response = Response(data: responseData, response: {});
      Stream<Response> forward(Request req) => Stream.fromIterable([response]);

      when(
        () => mockAliceCore.addCall(any()),
      ).thenAnswer((_) => Future.value());
      when(
        () => mockAliceCore.addResponse(any(), any()),
      ).thenAnswer((_) => Future.value());

      await link.request(request, forward).toList();

      final call =
          verify(() => mockAliceCore.addCall(captureAny())).captured.first
              as AliceHttpCall;
      expect(call.method, 'POST');
      expect(call.server, 'api.example.com');
      expect(call.endpoint, '/graphql/v1 / GetUser');
      expect(call.uri, 'https://api.example.com/graphql/v1');
      expect(call.request?.queryParameters['op'], 'GetUser');
      final body = call.request?.body as String;
      expect(body, contains('query'));
      expect(body, contains('variables'));
      expect(body, contains('GetUser'));

      final resp =
          verify(
                () => mockAliceCore.addResponse(captureAny(), any()),
              ).captured.first
              as AliceHttpResponse;
      expect(resp.status, 200);
      expect(resp.body, {'data': responseData});
    });

    test('logs correctly without URL', () async {
      final link = AliceGraphQLLink(alice: mockAlice);
      final query = lang.parseString('query { countries { name } }');
      final request = Request(operation: Operation(document: query));

      Stream<Response> forward(Request req) =>
          Stream.fromIterable([Response(data: {}, response: {})]);

      when(
        () => mockAliceCore.addCall(any()),
      ).thenAnswer((_) => Future.value());
      when(
        () => mockAliceCore.addResponse(any(), any()),
      ).thenAnswer((_) => Future.value());

      await link.request(request, forward).toList();

      final call =
          verify(() => mockAliceCore.addCall(captureAny())).captured.first
              as AliceHttpCall;
      expect(call.server, 'GraphQL');
      expect(call.endpoint, 'countries');
    });

    test('logs response with null data', () async {
      final link = AliceGraphQLLink(alice: mockAlice);
      final request = Request(
        operation: Operation(document: lang.parseString('query { test }')),
      );
      Stream<Response> forward(Request req) =>
          Stream.fromIterable([Response(data: null, response: {})]);

      when(
        () => mockAliceCore.addCall(any()),
      ).thenAnswer((_) => Future.value());
      when(
        () => mockAliceCore.addResponse(any(), any()),
      ).thenAnswer((_) => Future.value());

      await link.request(request, forward).toList();

      final resp =
          verify(
                () => mockAliceCore.addResponse(captureAny(), any()),
              ).captured.first
              as AliceHttpResponse;
      expect(resp.body, {});
      expect(resp.size, 2); // {} is 2 bytes
    });

    test('handles stream errors correctly', () async {
      final link = AliceGraphQLLink(alice: mockAlice);
      final request = Request(
        operation: Operation(document: lang.parseString('query { test }')),
      );
      final exception = Exception('Network error');
      Stream<Response> forward(Request req) =>
          Stream<Response>.error(exception);

      when(
        () => mockAliceCore.addCall(any()),
      ).thenAnswer((_) => Future.value());
      when(
        () => mockAliceCore.addError(any(), any()),
      ).thenAnswer((_) => Future.value());
      when(
        () => mockAliceCore.addResponse(any(), any()),
      ).thenAnswer((_) => Future.value());

      try {
        await link.request(request, forward).toList();
      } catch (e) {
        expect(e, exception);
      }

      verify(() => mockAliceCore.addError(any(), any())).called(1);
      final resp =
          verify(
                () => mockAliceCore.addResponse(captureAny(), any()),
              ).captured.first
              as AliceHttpResponse;
      expect(resp.status, -1);
    });

    test('is robust against AliceCore exceptions', () async {
      final link = AliceGraphQLLink(alice: mockAlice);
      final request = Request(
        operation: Operation(document: lang.parseString('query { test }')),
      );
      Stream<Response> forward(Request req) =>
          Stream.fromIterable([Response(data: {}, response: {})]);

      // Make AliceCore throw an exception
      when(
        () => mockAliceCore.addCall(any()),
      ).thenThrow(Exception('Alice crashed'));
      when(
        () => mockAliceCore.addResponse(any(), any()),
      ).thenThrow(Exception('Alice crashed again'));

      // The stream should still finish successfully despite Alice crashing
      final results = await link.request(request, forward).toList();
      expect(results.length, 1);
    });

    test('extracts operation name from nested query', () async {
      final link = AliceGraphQLLink(alice: mockAlice);
      // Query without explicit operation name
      final query = lang.parseString('query { user(id: 1) { name } }');
      final request = Request(operation: Operation(document: query));

      Stream<Response> forward(Request req) =>
          Stream.fromIterable([Response(data: {}, response: {})]);
      when(
        () => mockAliceCore.addCall(any()),
      ).thenAnswer((_) => Future.value());
      when(
        () => mockAliceCore.addResponse(any(), any()),
      ).thenAnswer((_) => Future.value());

      await link.request(request, forward).toList();

      final call =
          verify(() => mockAliceCore.addCall(captureAny())).captured.first
              as AliceHttpCall;
      expect(call.endpoint, 'user');
    });
  });
}
