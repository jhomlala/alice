import 'package:alice/model/alice_configuration.dart';
import 'package:alice/core/alice_core.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_http_response.dart';
import 'package:alice/model/alice_http_request.dart';
import 'package:alice/model/alice_http_error.dart';
import 'package:alice/ui/stats/stats_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAliceCore extends Mock implements AliceCore {}
class MockAliceConfiguration extends Mock implements AliceConfiguration {}

void main() {
  late MockAliceCore mockAliceCore;
  late MockAliceConfiguration mockAliceConfiguration;

  setUp(() {
    mockAliceCore = MockAliceCore();
    mockAliceConfiguration = MockAliceConfiguration();
    when(() => mockAliceConfiguration.directionality).thenReturn(TextDirection.ltr);
    when(() => mockAliceCore.configuration).thenReturn(mockAliceConfiguration);
  });

  Widget _createTestWidget(Widget child) {
    return MaterialApp(
      home: child,
    );
  }

  testWidgets('StatsPage renders overview and insights tabs correctly', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1000, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final calls = [
      AliceHttpCall(1)
        ..method = 'GET'
        ..server = 'api.example.com'
        ..endpoint = '/api/v1/users'
        ..duration = 1500
        ..loading = false
        ..request = (AliceHttpRequest()..size = 200)
        ..response = (AliceHttpResponse()..status = 200..size = 1000),
      AliceHttpCall(2)
        ..method = 'POST'
        ..server = 'api.example.com'
        ..endpoint = '/api/v1/upload'
        ..duration = 3000
        ..loading = false
        ..error = (AliceHttpError()..error = 'Timeout')
        ..request = (AliceHttpRequest()..size = 5000)
        ..response = (AliceHttpResponse()..status = 500..size = 50),
    ];

    when(() => mockAliceCore.callsStream).thenAnswer((_) => Stream.value(calls));
    when(() => mockAliceCore.getCalls()).thenReturn(calls);

    await tester.pumpWidget(_createTestWidget(StatsPage(mockAliceCore)));
    await tester.pumpAndSettle();

    // Verify tabs
    expect(find.text('Overview'), findsOneWidget);
    expect(find.text('Stats'), findsOneWidget);

    // Verify overview tab components
    expect(find.text('Total Data'), findsOneWidget);
    expect(find.text('Status Distribution'), findsOneWidget);
    expect(find.text('HTTP Methods'), findsOneWidget);

    // Switch to insights tab
    await tester.tap(find.text('Stats'));
    await tester.pumpAndSettle();

    // Verify insights tab components
    expect(find.text('Top 3 Slowest', skipOffstage: false), findsOneWidget);
    expect(find.text('Recent Errors', skipOffstage: false), findsOneWidget);
    expect(find.text('Largest Payloads', skipOffstage: false), findsOneWidget);
    
    // Verify some insight data is rendered
    expect(find.text('/api/v1/users', skipOffstage: false), findsWidgets);
    expect(find.text('/api/v1/upload', skipOffstage: false), findsWidgets);
  });
}
