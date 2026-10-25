import 'package:alice/alice.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AliceRedactionService', () {
    test('does nothing when no redaction rules are configured', () {
      final config = AliceConfiguration();
      final call = AliceHttpCall(1)
        ..request = (AliceHttpRequest()
          ..headers = {'Authorization': 'Bearer 12345'}
          ..body = '{"password": "secret"}')
        ..response = (AliceHttpResponse()
          ..headers = {'Set-Cookie': 'session=abc'}
          ..body = {'token': 'xyz'});

      final service = AliceRedactionService(configuration: config);
      expect(service.isEnabled, isFalse);

      service.redactCall(call);

      expect(call.request?.headers['Authorization'], 'Bearer 12345');
      expect(call.request?.body, '{"password": "secret"}');
      expect(call.response?.headers?['Set-Cookie'], 'session=abc');
      expect((call.response?.body as Map)['token'], 'xyz');
    });

    test('redacts headers case-insensitively', () {
      final config = AliceConfiguration(
        redactedHeaders: {'authorization', 'x-api-key'},
      );
      final call = AliceHttpCall(1)
        ..request = (AliceHttpRequest()
          ..headers = {
            'AUTHORIZATION': 'Bearer secret_token',
            'X-Api-Key': '123-abc',
            'Content-Type': 'application/json',
          })
        ..response = (AliceHttpResponse()
          ..headers = {'x-api-key': 'echoed_key', 'Server': 'nginx'});

      final service = AliceRedactionService(configuration: config);
      service.redactCall(call);

      expect(call.request?.headers['AUTHORIZATION'], '[REDACTED]');
      expect(call.request?.headers['X-Api-Key'], '[REDACTED]');
      expect(call.request?.headers['Content-Type'], 'application/json');

      expect(call.response?.headers?['x-api-key'], '[REDACTED]');
      expect(call.response?.headers?['Server'], 'nginx');
    });

    test('redacts query parameters, form fields, and cookies', () {
      final config = AliceConfiguration(
        redactedHeaders: {'cookie'},
        redactedBodyKeys: {'token', 'password'},
      );
      final call = AliceHttpCall(1)
        ..request = (AliceHttpRequest()
          ..queryParameters = {'token': 'query_token_123', 'limit': 10}
          ..formDataFields = [
            AliceFormDataField('password', 'p@ssword'),
            AliceFormDataField('username', 'alice_user'),
          ]
          ..cookies = [
            AliceCookie('session', 'secret_session'),
            AliceCookie('theme', 'dark'),
          ]);

      final service = AliceRedactionService(configuration: config);
      service.redactCall(call);

      expect(call.request?.queryParameters['token'], '[REDACTED]');
      expect(call.request?.queryParameters['limit'], 10);

      expect(call.request?.formDataFields?[0].value, '[REDACTED]');
      expect(call.request?.formDataFields?[1].value, 'alice_user');

      expect(call.request?.cookies[0].value, '[REDACTED]');
      expect(call.request?.cookies[1].value, '[REDACTED]');
    });

    test('redacts JSON string and Map bodies recursively', () {
      final config = AliceConfiguration(
        redactedBodyKeys: {'password', 'credit_card', 'secret'},
      );
      final service = AliceRedactionService(configuration: config);

      // JSON string body
      final request = AliceHttpRequest()
        ..body =
            '{"user": {"Password": "my-password", "name": "John"}, "credit_CARD": "4111"}';

      service.redactRequest(request);

      expect(request.body, contains('"Password":"[REDACTED]"'));
      expect(request.body, contains('"credit_CARD":"[REDACTED]"'));
      expect(request.body, contains('"name":"John"'));

      // Map body
      final response = AliceHttpResponse()
        ..body = {
          'data': [
            {'Secret': 'top-secret', 'id': 1},
            {
              'id': 2,
              'nested': {'secret': 'nested-secret'},
            },
          ],
        };

      service.redactResponse(response);
      final responseData = (response.body as Map)['data'] as List;
      expect(responseData[0]['Secret'], '[REDACTED]');
      expect(responseData[0]['id'], 1);
      expect((responseData[1]['nested'] as Map)['secret'], '[REDACTED]');
    });
  });
}
