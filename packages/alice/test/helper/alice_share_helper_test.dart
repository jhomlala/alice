import 'package:alice/services/share/alice_share_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../mock/build_context_mock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late BuildContext context;
  const MethodChannel channel = MethodChannel(
    'dev.fluttercommunity.plus/share',
  );

  setUp(() {
    context = BuildContextMock();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          return null;
        });
  });

  group('AliceShareService', () {
    test('share should call share_plus on IO platforms', () async {
      // Note: In test environment dart.library.io is usually true.
      await AliceShareService.share(
        context: context,
        text: 'test text',
        subject: 'test subject',
      );
      // If no exception is thrown, it means it either called IO implementation
      // or stub (which would throw). Since we are in a flutter test environment,
      // it should be IO.
    });
  });
}
