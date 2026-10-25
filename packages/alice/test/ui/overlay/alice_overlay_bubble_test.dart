import 'package:alice/alice.dart';
import 'package:alice/src/services/overlay/alice_overlay_service.dart';
import 'package:alice/src/ui/overlay/alice_overlay_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AliceOverlayBubble & Service', () {
    testWidgets(
      'AliceOverlayBubble renders live call stats and taps callback',
      (tester) async {
        final storage = AliceMemoryStorage(maxCallsCount: 10);
        var tapped = false;
        var dismissed = false;

        final call = AliceHttpCall(1)
          ..method = 'GET'
          ..endpoint = '/test'
          ..request = AliceHttpRequest()
          ..response = (AliceHttpResponse()..status = 500);

        storage.addCall(call);
        storage.addResponse(call.response!, 1);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Stack(
                children: [
                  AliceOverlayBubble(
                    callsStream: storage.callsStream,
                    storage: storage,
                    onTap: () => tapped = true,
                    onDismiss: () => dismissed = true,
                  ),
                ],
              ),
            ),
          ),
        );

        await tester.pump();

        // Stats total should be 1, error badge 1
        expect(find.text('1'), findsNWidgets(2)); // Total and Error both 1

        // Tap the bubble
        await tester.tap(find.byType(AliceOverlayBubble));
        await tester.pump();

        expect(tapped, isTrue);
        expect(dismissed, isFalse);
      },
    );

    testWidgets(
      'AliceOverlayBubble renders green status dot when traffic is partially successful',
      (tester) async {
        final storage = AliceMemoryStorage(maxCallsCount: 10);

        final successfulCall = AliceHttpCall(1)
          ..method = 'GET'
          ..endpoint = '/success'
          ..request = AliceHttpRequest()
          ..response = (AliceHttpResponse()..status = 200);

        final failedCall = AliceHttpCall(2)
          ..method = 'GET'
          ..endpoint = '/fail'
          ..request = AliceHttpRequest()
          ..response = (AliceHttpResponse()..status = 500);

        storage.addCall(successfulCall);
        storage.addResponse(successfulCall.response!, 1);
        storage.addCall(failedCall);
        storage.addResponse(failedCall.response!, 2);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Stack(
                children: [
                  AliceOverlayBubble(
                    callsStream: storage.callsStream,
                    storage: storage,
                    onTap: () {},
                    onDismiss: () {},
                  ),
                ],
              ),
            ),
          ),
        );

        await tester.pump();

        // Total 2, error badge 1
        expect(find.text('2'), findsOneWidget); // Total calls
        expect(find.text('1'), findsOneWidget); // Errors badge
        expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);

        // Status dot is green (traffic succeeded)
        final dotFinder = find.byWidgetPredicate((widget) {
          if (widget is Container && widget.decoration is BoxDecoration) {
            final box = widget.decoration as BoxDecoration;
            return box.shape == BoxShape.circle && box.color == Colors.green;
          }
          return false;
        });
        expect(dotFinder, findsOneWidget);
      },
    );

    testWidgets(
      'AliceOverlayBubble renders loading indicator when calls are in-flight',
      (tester) async {
        final storage = AliceMemoryStorage(maxCallsCount: 10);

        // Active in-flight call (loading = true)
        final call = AliceHttpCall(1)
          ..method = 'GET'
          ..endpoint = '/loading'
          ..loading = true
          ..request = AliceHttpRequest();

        storage.addCall(call);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Stack(
                children: [
                  AliceOverlayBubble(
                    callsStream: storage.callsStream,
                    storage: storage,
                    onTap: () {},
                    onDismiss: () {},
                  ),
                ],
              ),
            ),
          ),
        );

        await tester.pump();

        // Total 1, loading badge 1, CircularProgressIndicator rendered
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.byIcon(Icons.sync), findsOneWidget);
        expect(find.text('1'), findsNWidgets(2)); // Total 1, Loading badge 1
      },
    );

    testWidgets('AliceOverlayService manages lifecycle', (tester) async {
      final service = AliceOverlayService();
      expect(service.isInserted, isFalse);

      final navKey = GlobalKey<NavigatorState>();
      final alice = Alice(
        configuration: AliceConfiguration(
          navigatorKey: navKey,
          showOverlayBubble: true,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navKey,
          home: const Scaffold(body: Center(child: Text('Home'))),
        ),
      );

      // Trigger showOverlayBubble
      alice.showOverlayBubble();
      await tester.pump();

      expect(find.byType(AliceOverlayBubble), findsOneWidget);
      expect(alice.isOverlayBubbleVisible, isTrue);

      // Hide bubble
      alice.hideOverlayBubble();
      await tester.pump();

      expect(find.byType(AliceOverlayBubble), findsNothing);
      expect(alice.isOverlayBubbleVisible, isFalse);

      // Show again
      alice.showOverlayBubble();
      await tester.pump();

      expect(find.byType(AliceOverlayBubble), findsOneWidget);

      // Call showInspector and ensure bubble becomes hidden (SizedBox.shrink)
      alice.showInspector();
      await tester.pumpAndSettle();

      expect(find.byType(AliceOverlayBubble), findsNothing);
    });
  });
}
