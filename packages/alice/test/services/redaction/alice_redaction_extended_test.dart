import 'dart:convert';

import 'package:alice/alice.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AliceRedactionService Extended', () {
    test('redacts x-www-form-urlencoded string body', () {
      final config = AliceConfiguration(
        redactedBodyKeys: {'password', 'client_secret', 'refresh_token'},
      );
      final service = AliceRedactionService(configuration: config);

      final request = AliceHttpRequest()
        ..body =
            'grant_type=password&username=alice_dev&password=my_secret_123&client_secret=top_secret_xyz';

      service.redactRequest(request);

      expect(
        request.body,
        'grant_type=password&username=alice_dev&password=%5BREDACTED%5D&client_secret=%5BREDACTED%5D',
      );
    });

    test('redacts deeply nested mixed JSON array and objects', () {
      final config = AliceConfiguration(
        redactedHeaders: {'x-custom-token'},
        redactedBodyKeys: {'apiKey', 'ssn'},
      );
      final service = AliceRedactionService(configuration: config);

      final payload = {
        'items': [
          {
            'user': {
              'ssn': '000-11-2222',
              'profiles': [
                {'apiKey': 'api_val_1'},
                {'apiKey': 'api_val_2'},
              ],
            },
          },
        ],
      };

      final response = AliceHttpResponse()
        ..headers = {'X-Custom-Token': 'token_999'}
        ..body = jsonEncode(payload);

      service.redactResponse(response);

      expect(response.headers?['X-Custom-Token'], '[REDACTED]');
      final decoded =
          jsonDecode(response.body as String) as Map<String, dynamic>;
      final user =
          (decoded['items'] as List)[0]['user'] as Map<String, dynamic>;
      expect(user['ssn'], '[REDACTED]');
      final profiles = user['profiles'] as List;
      expect(profiles[0]['apiKey'], '[REDACTED]');
      expect(profiles[1]['apiKey'], '[REDACTED]');
    });

    test('ignores non-json and non-form-urlencoded raw strings safely', () {
      final config = AliceConfiguration(redactedBodyKeys: {'password'});
      final service = AliceRedactionService(configuration: config);

      final request = AliceHttpRequest()
        ..body = '<html><body>Hello World</body></html>';
      service.redactRequest(request);

      expect(request.body, '<html><body>Hello World</body></html>');
    });
  });
}
