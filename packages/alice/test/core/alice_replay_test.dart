import 'package:alice/src/core/alice_core.dart';
import 'package:alice/src/services/replay/replay_service.dart';
import 'package:alice/src/model/alice_configuration.dart';
import 'package:alice/src/model/alice_form_data_file.dart';
import 'package:alice/src/model/alice_http_call.dart';
import 'package:alice/src/model/alice_http_request.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AliceHttpCall has isReplay default false and can be set to true', () {
    final call = AliceHttpCall(1);
    expect(call.isReplay, false);
    call.isReplay = true;
    expect(call.isReplay, true);
  });

  testWidgets('ReplayService blocks multipart requests and shows dialog', (
    WidgetTester tester,
  ) async {
    final core = AliceCore(
      configuration: AliceConfiguration(showNotification: false),
    );
    final service = ReplayService(core);

    final call = AliceHttpCall(1);
    call.request = AliceHttpRequest()
      ..formDataFiles = [AliceFormDataFile('file.txt', 'text/plain', 10)];

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () {
                service.replayCall(originalCall: call, context: context);
              },
              child: const Text('Replay'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Replay'));
    await tester.pumpAndSettle();

    // Should show an error dialog
    expect(find.text('Error'), findsOneWidget);
    expect(
      find.text('Multipart/FormData replays are not yet supported.'),
      findsOneWidget,
    );
  });
}
