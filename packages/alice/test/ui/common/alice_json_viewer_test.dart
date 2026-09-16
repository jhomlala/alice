import 'package:alice/ui/common/json_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('JsonViewer renders Map correctly', (
    WidgetTester tester,
  ) async {
    final Map<String, dynamic> testJson = {
      'title': 'Alice',
      'active': true,
      'id': 123,
    };

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: JsonViewer(testJson, initiallyExpanded: true),
        ),
      ),
    );

    expect(find.text('Object {3}'), findsOneWidget);
    expect(find.text('title: '), findsOneWidget);
    expect(find.text('"Alice"'), findsOneWidget);
    expect(find.text('active: '), findsOneWidget);
    expect(find.text('true'), findsOneWidget);
    expect(find.text('id: '), findsOneWidget);
    expect(find.text('123'), findsOneWidget);
  });

  testWidgets('JsonViewer renders List correctly', (
    WidgetTester tester,
  ) async {
    final List<dynamic> testList = ['item1', 42, false];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: JsonViewer(testList, initiallyExpanded: true),
        ),
      ),
    );

    expect(find.text('Array [3]'), findsOneWidget);
    expect(find.text('[0]: '), findsOneWidget);
    expect(find.text('"item1"'), findsOneWidget);
    expect(find.text('[1]: '), findsOneWidget);
    expect(find.text('42'), findsOneWidget);
    expect(find.text('[2]: '), findsOneWidget);
    expect(find.text('false'), findsOneWidget);
  });

  testWidgets('JsonViewer parses JSON string correctly', (
    WidgetTester tester,
  ) async {
    const String jsonString = '{"name": "test", "value": 99}';

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: JsonViewer(jsonString, initiallyExpanded: true),
        ),
      ),
    );

    expect(find.text('Object {2}'), findsOneWidget);
    expect(find.text('name: '), findsOneWidget);
    expect(find.text('"test"'), findsOneWidget);
    expect(find.text('value: '), findsOneWidget);
    expect(find.text('99'), findsOneWidget);
  });

  testWidgets('JsonViewer handles invalid JSON string gracefully', (
    WidgetTester tester,
  ) async {
    const String invalidJson = 'invalid json string';

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: JsonViewer(invalidJson))),
    );

    expect(find.textContaining('Invalid JSON'), findsOneWidget);
    expect(find.textContaining('invalid json string'), findsOneWidget);
  });
}
