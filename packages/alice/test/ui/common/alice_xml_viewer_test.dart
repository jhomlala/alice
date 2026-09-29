import 'package:alice/src/ui/common/xml_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

void main() {
  group('XmlViewer', () {
    testWidgets('renders a simple element with text content', (tester) async {
      const xml = '<root><name>Alice</name></root>';

      await tester.pumpWidget(_wrap(const XmlViewer(xml)));
      await tester.pump();

      // Root with 1 child is rendered as an expandable header.
      expect(find.textContaining('<root>'), findsOneWidget);
      expect(find.textContaining('<name>:'), findsOneWidget);
      expect(find.text('"Alice"'), findsOneWidget);
    });

    testWidgets('toggles collapse and expand when tapping header', (
      tester,
    ) async {
      const xml = '<root><name>Alice</name><version>1</version></root>';

      await tester.pumpWidget(_wrap(const XmlViewer(xml)));
      await tester.pump();

      // Root is initially expanded, children are visible.
      expect(find.textContaining('<name>:'), findsOneWidget);
      expect(find.text('"Alice"'), findsOneWidget);

      // Tap root header to collapse.
      await tester.tap(find.textContaining('<root>'));
      await tester.pumpAndSettle();

      // Children are now hidden.
      expect(find.textContaining('<name>:'), findsNothing);
      expect(find.text('"Alice"'), findsNothing);

      // Tap root header to expand again.
      await tester.tap(find.textContaining('<root>'));
      await tester.pumpAndSettle();

      // Children are visible again.
      expect(find.textContaining('<name>:'), findsOneWidget);
      expect(find.text('"Alice"'), findsOneWidget);
    });

    testWidgets('expands nested non-root elements on tap', (tester) async {
      const xml = '<root><parent><child>Nested text</child></parent></root>';

      await tester.pumpWidget(_wrap(const XmlViewer(xml)));
      await tester.pump();

      // Root is initially expanded, but nested <parent> is collapsed.
      expect(find.textContaining('<parent>'), findsOneWidget);
      expect(find.textContaining('<child>:'), findsNothing);

      // Tap <parent> header to expand it.
      await tester.tap(find.textContaining('<parent>'));
      await tester.pumpAndSettle();

      // <child> is now visible.
      expect(find.textContaining('<child>:'), findsOneWidget);
      expect(find.text('"Nested text"'), findsOneWidget);
    });

    testWidgets('renders attributes for elements', (tester) async {
      const xml = '<root><item id="42" type="test">value</item></root>';

      await tester.pumpWidget(_wrap(const XmlViewer(xml)));
      await tester.pump();

      // Root is initially expanded; _AttributesRow renders `@attr: ` prefix.
      expect(find.textContaining('@id:'), findsOneWidget);
      expect(find.text('"42"'), findsOneWidget);
      expect(find.textContaining('@type:'), findsOneWidget);
      expect(find.text('"test"'), findsOneWidget);
    });

    testWidgets('shows empty indicator for elements with no text', (
      tester,
    ) async {
      const xml = '<root><child/></root>';

      await tester.pumpWidget(_wrap(const XmlViewer(xml)));
      await tester.pump();

      expect(find.text('(empty)'), findsOneWidget);
    });

    testWidgets('handles invalid XML gracefully', (tester) async {
      const invalidXml = 'this is not xml at all';

      await tester.pumpWidget(_wrap(const XmlViewer(invalidXml)));
      await tester.pump();

      expect(find.textContaining('Invalid XML'), findsOneWidget);
      expect(find.textContaining('this is not xml at all'), findsOneWidget);
    });

    testWidgets('renders real-world SVG-like XML without crashing', (
      tester,
    ) async {
      const svgXml =
          '<svg xmlns="http://www.w3.org/2000/svg" width="100">'
          '<circle cx="50" cy="50" r="40"/>'
          '</svg>';

      await tester.pumpWidget(_wrap(const XmlViewer(svgXml)));
      await tester.pump();

      expect(find.textContaining('<svg>'), findsOneWidget);
      expect(find.textContaining('<circle>:'), findsOneWidget);
    });

    testWidgets('handles null body without crashing', (tester) async {
      await tester.pumpWidget(_wrap(const XmlViewer(null)));
      await tester.pump();
    });
  });
}
