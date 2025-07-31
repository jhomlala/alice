import 'dart:io';

import 'package:alice/core/alice_core.dart';
import 'package:alice/model/alice_form_data_file.dart';
import 'package:alice/model/alice_from_data_field.dart';
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

import 'invalid_model.dart';
import 'invalid_service.dart';
import 'json_serializable_converter.dart';

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
        interceptors: [aliceChopperAdapter],
      );

      await chopperClient.get(
        Uri(path: 'json'),
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
        () => aliceCore.addResponse(any(that: nextResponseMatcher), any()),
      );
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
        interceptors: [aliceChopperAdapter],
      );

      await chopperClient.post(
        Uri(path: 'json', queryParameters: {'sort': 'asc'}),
        body: '{"data":"test"}',
        headers: {'content-type': 'application/json'},
      );

      final requestMatcher = buildRequestMatcher(
        checkTime: true,
        headers: {"content-type": "application/json"},
        contentType: "application/json",
        body: '{"data":"test"}',
        queryParameters: {
          "sort": ["asc"],
        },
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
        () => aliceCore.addResponse(any(that: nextResponseMatcher), any()),
      );
    });

    test("should handle form data", () async {
      final name = '${DateTime.now().microsecondsSinceEpoch}.png';
      final file = File(name);
      file.createSync();

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
        interceptors: [aliceChopperAdapter],
      );

      await chopperClient.post(
        Uri(path: 'form'),
        parts: [
          const PartValue('name', 'Alice'),
          const PartValue('surname', 'test'),
          PartValueFile('image', file.path),
        ],
        multipart: true,
        headers: {'content-type': 'multipart/form-data'},
      );

      final requestMatcher = buildRequestMatcher(
        checkTime: true,
        formDataFields: [
          const AliceFormDataField('name', 'Alice'),
          const AliceFormDataField('surname', 'test'),
        ],
        formDataFiles: [AliceFormDataFile(name, "", 0)],
        body: '',
        headers: {'content-type': 'multipart/form-data'},
        contentType: 'multipart/form-data',
      );
      final responseMatcher = buildResponseMatcher(checkTime: true);

      final callMatcher = buildCallMatcher(
        checkId: true,
        checkTime: true,
        secured: true,
        loading: true,
        client: 'Chopper',
        method: 'POST',
        endpoint: '/form',
        server: 'test.com',
        uri: 'https://test.com/form',
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
        () => aliceCore.addResponse(any(that: nextResponseMatcher), any()),
      );
      file.deleteSync();
    });

    test("should handle call with empty response", () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          '',
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      chopperClient = ChopperClient(
        baseUrl: baseUrl,
        client: mockClient,
        interceptors: [aliceChopperAdapter],
      );

      await chopperClient.get(
        Uri(path: 'json'),
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
        response: responseMatcher,
      );

      verify(() => aliceCore.addCall(any(that: callMatcher)));

      final nextResponseMatcher = buildResponseMatcher(
        status: 200,
        size: 0,
        checkTime: true,
        body: '',
      );

      verify(
        () => aliceCore.addResponse(any(that: nextResponseMatcher), any()),
      );
    });

    test("should handle call with error", () async {
      final mockClient = MockClient((request) async {
        return http.Response('error', 404);
      });

      chopperClient = ChopperClient(
        baseUrl: baseUrl,
        client: mockClient,
        interceptors: [aliceChopperAdapter],
      );

      await chopperClient.get(Uri(path: 'json'));

      final requestMatcher = buildRequestMatcher(checkTime: true);

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
        response: responseMatcher,
      );

      verify(() => aliceCore.addCall(any(that: callMatcher)));

      final nextResponseMatcher = buildResponseMatcher(
        status: 404,
        size: 0,
        checkTime: true,
      );

      verify(
        () => aliceCore.addResponse(any(that: nextResponseMatcher), any()),
      );

      final errorMatcher = buildErrorMatcher(checkError: true);

      verify(() => aliceCore.addError(any(that: errorMatcher), any()));
    });

    test("should handle call with error when model fails", () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          '{"id": 0}',
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      chopperClient = ChopperClient(
        baseUrl: baseUrl,
        client: mockClient,
        interceptors: [aliceChopperAdapter],
        services: [InvalidService.create()],
        converter: const JsonSerializableConverter({
          InvalidModel: InvalidModel.fromJson,
        }),
      );

      final service = chopperClient.getService<InvalidService>();
      try {
        await service.get(0);
      } catch (_) {}

      final requestMatcher = buildRequestMatcher(checkTime: true);

      final responseMatcher = buildResponseMatcher(checkTime: true);

      final callMatcher = buildCallMatcher(
        checkId: true,
        checkTime: true,
        secured: true,
        loading: true,
        client: 'Chopper',
        method: 'GET',
        endpoint: '/posts/0',
        server: 'test.com',
        uri: 'https://test.com/posts/0',
        duration: 0,
        request: requestMatcher,
        response: responseMatcher,
      );

      verify(() => aliceCore.addCall(any(that: callMatcher)));

      final nextResponseMatcher = buildResponseMatcher(
        status: -1,
        size: 0,
        checkTime: true,
      );

      verify(
        () => aliceCore.addResponse(any(that: nextResponseMatcher), any()),
      );

      final errorMatcher = buildErrorMatcher(
        checkError: true,
        checkStacktrace: true,
      );

      verify(() => aliceCore.addError(any(that: errorMatcher), any()));

      final logMatcher = buildLogMatcher(
        checkMessage: true,
        checkError: true,
        checkStacktrace: true,
        checkTime: true,
      );
      verify(() => aliceCore.addLog(any(that: logMatcher)));
    });
  });
}
