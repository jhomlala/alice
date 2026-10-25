import 'package:alice/alice.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AliceVmService Extensions', () {
    late AliceCore core;

    setUp(() {
      core = AliceCore(
        configuration: AliceConfiguration(detectDuplicates: false),
      );
      AliceVmService.register(core);
    });

    test(
      'ext.alice endpoints register and respond properly to queries',
      () async {
        final call1 = AliceHttpCall(1)
          ..method = 'GET'
          ..server = 'https://api.github.com'
          ..endpoint = '/users'
          ..uri = 'https://api.github.com/users'
          ..client = 'Dio'
          ..request = (AliceHttpRequest()..size = 120)
          ..response = (AliceHttpResponse()
            ..status = 200
            ..size = 500);

        final call2 = AliceHttpCall(2)
          ..method = 'POST'
          ..server = 'https://api.github.com'
          ..endpoint = '/login'
          ..uri = 'https://api.github.com/login'
          ..client = 'Dio'
          ..request = (AliceHttpRequest()..body = '{"user":"test"}')
          ..response = (AliceHttpResponse()..status = 401)
          ..error = (AliceHttpError()..error = 'Unauthorized');

        await core.addCall(call1);
        await core.addResponse(call1.response!, 1);

        await core.addCall(call2);
        await core.addResponse(call2.response!, 2);
        await core.addError(call2.error!, 2);

        expect(core.getCalls().length, 2);
        final stats = core.configuration.aliceStorage.getStats();
        expect(stats.total, 2);
        expect(stats.successes, 1);
        expect(stats.errors, 1);
      },
    );

    test('ext.alice clearCalls cleans up all stored calls', () async {
      final call = AliceHttpCall(99)
        ..method = 'DELETE'
        ..endpoint = '/item/99'
        ..request = AliceHttpRequest()
        ..response = (AliceHttpResponse()..status = 204);

      await core.addCall(call);
      await core.addResponse(call.response!, 99);
      expect(core.getCalls().length, 1);

      await core.removeCalls();
      expect(core.getCalls().isEmpty, isTrue);
      expect(core.configuration.aliceStorage.getStats().total, 0);
    });
  });
}
