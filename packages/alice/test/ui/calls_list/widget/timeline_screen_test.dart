import 'package:alice/src/core/alice_core.dart';
import 'package:alice/src/model/alice_http_call.dart';
import 'package:alice/src/model/alice_http_response.dart';
import 'package:alice/src/ui/calls_list/widget/timeline_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAliceCore extends Mock implements AliceCore {}

// ignore: must_be_immutable
class TestAliceHttpCall extends AliceHttpCall {
  final DateTime _customCreatedTime;

  TestAliceHttpCall(super.id, this._customCreatedTime);

  @override
  DateTime get createdTime => _customCreatedTime;
}

void main() {
  late MockAliceCore mockAliceCore;
  late List<AliceHttpCall> pressedCalls;

  setUp(() {
    mockAliceCore = MockAliceCore();
    pressedCalls = [];
  });

  Widget createTestWidget(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  testWidgets('TimelineScreen displays "No calls" when calls list is empty', (
    WidgetTester tester,
  ) async {
    when(() => mockAliceCore.callsStream).thenAnswer((_) => Stream.value([]));

    await tester.pumpWidget(
      createTestWidget(
        TimelineScreen(
          aliceCore: mockAliceCore,
          onListItemPressed: (call) => pressedCalls.add(call),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No calls'), findsOneWidget);
  });

  testWidgets(
    'TimelineScreen renders grid lines and staggered call bars correctly',
    (WidgetTester tester) async {
      final baseTime = DateTime(2026, 9, 17, 10, 0, 0);

      final call1 = TestAliceHttpCall(1, baseTime)
        ..endpoint = '/api/v1/users'
        ..loading = false
        ..response = (AliceHttpResponse()
          ..status = 200
          ..time = baseTime.add(const Duration(milliseconds: 200)));

      final call2 =
          TestAliceHttpCall(2, baseTime.add(const Duration(milliseconds: 100)))
            ..endpoint = '/api/v1/posts'
            ..loading = false
            ..response = (AliceHttpResponse()
              ..status = 500
              ..time = baseTime.add(const Duration(milliseconds: 500)));

      final call3 =
          TestAliceHttpCall(3, baseTime.add(const Duration(milliseconds: 300)))
            ..endpoint = '/api/v1/pending'
            ..loading = true;

      final calls = [call1, call2, call3];

      when(() => mockAliceCore.callsStream)
          .thenAnswer((_) => Stream.value(calls));

      await tester.pumpWidget(
        createTestWidget(
          TimelineScreen(
            aliceCore: mockAliceCore,
            onListItemPressed: (call) => pressedCalls.add(call),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify endpoint texts along with their durations are rendered
      expect(find.textContaining('/api/v1/users'), findsOneWidget);
      expect(find.textContaining('/api/v1/posts'), findsOneWidget);
      expect(find.textContaining('/api/v1/pending'), findsOneWidget);

      // Verify grid labels are present
      expect(find.text('0ms'), findsOneWidget);
      expect(find.text('250ms'), findsOneWidget);
      expect(find.text('500ms'), findsOneWidget);

      // Tap on the first call bar to test interaction
      await tester.tap(find.textContaining('/api/v1/users'));
      await tester.pumpAndSettle();

      expect(pressedCalls.length, 1);
      expect(pressedCalls.first.id, 1);
    },
  );
}
