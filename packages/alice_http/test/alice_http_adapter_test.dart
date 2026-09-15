import 'package:alice/core/alice_core.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_http_error.dart';
import 'package:alice/model/alice_http_response.dart';
import 'package:alice/model/alice_log.dart';
import 'package:alice_http/alice_http_adapter.dart';
import 'package:alice_http/alice_http_extensions.dart';
import 'package:alice_test/alice_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

void main() {
  late AliceCore aliceCore;
  late AliceHttpAdapter aliceHttpAdapter;

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

    aliceHttpAdapter = AliceHttpAdapter();
    aliceHttpAdapter.injectCore(aliceCore);
  });

  group('AliceHttpAdapter', () {
    test('interceptWithAlice records duration correctly', () async {
      final mockClient = MockClient((request) async {
        // Simulate a small delay to ensure duration > 0
        await Future.delayed(const Duration(milliseconds: 50));
        return http.Response(
          '{"result": "ok"}',
          200,
          request: request,
          headers: {'content-type': 'application/json'},
        );
      });

      await mockClient
          .get(Uri.parse('https://test.com/json'))
          .interceptWithAlice(aliceHttpAdapter);

      // Verify addCall was called and captured the call
      final captured = verify(() => aliceCore.addCall(captureAny())).captured;
      expect(captured.length, 1);
      final call = captured.first as AliceHttpCall;

      expect(call.client, 'HttpClient (http package)');
      expect(call.method, 'GET');
      expect(call.endpoint, '/json');
      expect(call.loading, false);
      expect(call.duration, greaterThanOrEqualTo(50));
    });

    test('manual onResponse records call correctly', () async {
      final request = http.Request('POST', Uri.parse('https://test.com/post'));
      request.body = '{"data":"test"}';

      final response = http.Response(
        '{"result": "ok"}',
        201,
        request: request,
        headers: {'content-type': 'application/json'},
      );

      aliceHttpAdapter.onResponse(response);

      final captured = verify(() => aliceCore.addCall(captureAny())).captured;
      expect(captured.length, 1);
      final call = captured.first as AliceHttpCall;

      expect(call.client, 'HttpClient (http package)');
      expect(call.method, 'POST');
      expect(call.endpoint, '/post');
      expect(call.response?.status, 201);
      expect(call.request?.body, '{"data":"test"}');
      expect(call.duration, 0); // No duration provided manually
    });

    test(
      'manual onResponse records call correctly with MultipartRequest',
      () async {
        final request = http.MultipartRequest(
          'POST',
          Uri.parse('https://test.com/upload'),
        );
        request.fields['test'] = 'value';
        request.files.add(
          http.MultipartFile.fromString(
            'file',
            'test content',
            filename: 'test.txt',
          ),
        );

        final response = http.Response(
          '{"result": "ok"}',
          201,
          request: request,
          headers: {'content-type': 'application/json'},
        );

        aliceHttpAdapter.onResponse(response);

        final captured = verify(() => aliceCore.addCall(captureAny())).captured;
        expect(captured.length, 1);
        final call = captured.first as AliceHttpCall;

        expect(call.client, 'HttpClient (http package)');
        expect(call.method, 'POST');
        expect(call.endpoint, '/upload');
        expect(call.response?.status, 201);
        final body = call.request?.body as Map<String, dynamic>;
        expect(body['fields'], {'test': 'value'});
        expect(body['files'][0]['filename'], 'test.txt');
      },
    );
  });
}
