import 'package:alice/src/model/alice_http_call.dart';
import 'package:alice/src/model/alice_http_request.dart';
import 'package:alice/src/model/alice_http_response.dart';
import 'package:alice/src/ui/call_details/widget/call_response_screen.dart';
import 'package:alice/src/ui/common/xml_viewer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../../utils/test_helper.dart';

AliceHttpCall _callWithContentType(String contentType, {dynamic body}) {
  return AliceHttpCall(DateTime.now().millisecondsSinceEpoch)
    ..loading = false
    ..request = (AliceHttpRequest()
      ..headers = {}
      ..size = 0
      ..time = DateTime.now())
    ..response = (AliceHttpResponse()
      ..headers = {'content-type': contentType}
      ..body = body ?? ''
      ..status = 200
      ..size = 0
      ..time = DateTime.now())
    ..method = 'GET'
    ..endpoint = '/test'
    ..server = 'https://example.com'
    ..secure = true;
}

void main() {
  group('CallResponseScreen — body type routing', () {
    testWidgets(
      'image/svg+xml does NOT render Image.network (the crash case)',
      (tester) async {
        const svgBody =
            '<svg xmlns="http://www.w3.org/2000/svg"><circle/></svg>';
        final call = _callWithContentType('image/svg+xml', body: svgBody);

        await tester.pumpWidget(
          TestHelper.wrapWithMaterialApp(CallResponseScreen(call: call)),
        );
        await tester.pump();

        expect(find.byType(Image), findsNothing);
      },
    );

    testWidgets('image/svg+xml routes to XmlViewer instead', (tester) async {
      const svgBody =
          '<svg xmlns="http://www.w3.org/2000/svg"><circle r="10"/></svg>';
      final call = _callWithContentType('image/svg+xml', body: svgBody);

      await tester.pumpWidget(
        TestHelper.wrapWithMaterialApp(CallResponseScreen(call: call)),
      );
      await tester.pump();

      expect(find.byType(XmlViewer), findsOneWidget);
    });

    testWidgets('application/xml routes to XmlViewer', (tester) async {
      const xmlBody = '<feed><entry><title>Test</title></entry></feed>';
      final call = _callWithContentType('application/xml', body: xmlBody);

      await tester.pumpWidget(
        TestHelper.wrapWithMaterialApp(CallResponseScreen(call: call)),
      );
      await tester.pump();

      expect(find.byType(XmlViewer), findsOneWidget);
    });

    testWidgets('text/xml routes to XmlViewer', (tester) async {
      const xmlBody = '<root><item>hello</item></root>';
      final call = _callWithContentType('text/xml', body: xmlBody);

      await tester.pumpWidget(
        TestHelper.wrapWithMaterialApp(CallResponseScreen(call: call)),
      );
      await tester.pump();

      expect(find.byType(XmlViewer), findsOneWidget);
    });

    testWidgets('image/png does NOT route to XmlViewer', (tester) async {
      final call = _callWithContentType('image/png', body: '');

      await tester.pumpWidget(
        TestHelper.wrapWithMaterialApp(CallResponseScreen(call: call)),
      );
      await tester.pump();
      tester.takeException(); // Consume NetworkImageLoadException from Image.network

      expect(find.byType(XmlViewer), findsNothing);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('image/jpeg does NOT route to XmlViewer', (tester) async {
      final call = _callWithContentType('image/jpeg', body: '');

      await tester.pumpWidget(
        TestHelper.wrapWithMaterialApp(CallResponseScreen(call: call)),
      );
      await tester.pump();
      tester.takeException(); // Consume NetworkImageLoadException from Image.network

      expect(find.byType(XmlViewer), findsNothing);
      expect(find.byType(Image), findsOneWidget);
    });
  });
}
