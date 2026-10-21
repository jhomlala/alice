import 'package:alice/alice.dart';
import 'package:alice/src/ui/call_details/page/call_details_page.dart';
import 'package:alice/src/ui/calls_list/model/calls_list_sort_option.dart';
import 'package:alice/src/ui/calls_list/page/calls_list_page.dart';
import 'package:alice/src/ui/calls_list/widget/sort_dialog.dart';
import 'package:alice/src/ui/common/dialog.dart';
import 'package:alice/src/ui/common/export_format_dialog.dart';
import 'package:alice/src/ui/common/loading_dialog.dart';
import 'package:alice/src/ui/common/page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'AliceGeneralDialog renders without MaterialLocalizations error in Flutter app',
    (WidgetTester tester) async {
      final alice = Alice(
        configuration: AliceConfiguration(showNotification: false),
      );

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: alice.getNavigatorKey(),
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    AliceGeneralDialog.show(
                      context: context,
                      title: 'Test Title',
                      description: 'Test Description',
                    );
                  },
                  child: const Text('Show Dialog'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('Test Description'), findsOneWidget);
    },
  );

  testWidgets(
    'AliceGeneralDialog inside BasePage renders without MaterialLocalizations error in Flutter app',
    (WidgetTester tester) async {
      final core = AliceCore(
        configuration: AliceConfiguration(showNotification: false),
      );

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: core.configuration.navigatorKey,
          home: Scaffold(
            body: BasePage(
              core: core,
              child: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      AliceGeneralDialog.show(
                        context: context,
                        title: 'Test Title 2',
                        description: 'Test Description 2',
                      );
                    },
                    child: const Text('Show Dialog 2'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog 2'));
      await tester.pumpAndSettle();

      expect(find.text('Test Title 2'), findsOneWidget);
      expect(find.text('Test Description 2'), findsOneWidget);
    },
  );

  testWidgets(
    'ExportFormatDialog renders without MaterialLocalizations error in Flutter app',
    (WidgetTester tester) async {
      final alice = Alice(
        configuration: AliceConfiguration(showNotification: false),
      );

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: alice.getNavigatorKey(),
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    ExportFormatDialog.show(context);
                  },
                  child: const Text('Export'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Export'));
      await tester.pumpAndSettle();

      expect(find.text('Select export format'), findsOneWidget);
    },
  );

  testWidgets(
    'LoadingDialog renders without MaterialLocalizations error in Flutter app',
    (WidgetTester tester) async {
      final alice = Alice(
        configuration: AliceConfiguration(showNotification: false),
      );

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: alice.getNavigatorKey(),
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    LoadingDialog.show(context);
                  },
                  child: const Text('Load'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Load'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(LoadingDialog), findsOneWidget);
      expect(find.text('Loading...'), findsOneWidget);
    },
  );

  testWidgets(
    'SortDialog with showAliceDialog renders without MaterialLocalizations error in Flutter app',
    (WidgetTester tester) async {
      final alice = Alice(
        configuration: AliceConfiguration(showNotification: false),
      );

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: alice.getNavigatorKey(),
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    AliceGeneralDialog.showAliceDialog<AliceSortDialogResult>(
                      context: context,
                      builder: (_) => const SortDialog(
                        sortOption: CallsListSortOption.time,
                        sortAscending: false,
                      ),
                    );
                  },
                  child: const Text('Sort'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Sort'));
      await tester.pumpAndSettle();

      expect(find.text('Select filter'), findsOneWidget);
    },
  );

  testWidgets(
    'CallDetailsPage retry FAB on multipart call displays error dialog',
    (WidgetTester tester) async {
      final core = AliceCore(
        configuration: AliceConfiguration(showNotification: false),
      );

      final call = AliceHttpCall(1)
        ..method = 'POST'
        ..endpoint = '/upload'
        ..server = 'api.example.com'
        ..uri = 'https://api.example.com/upload'
        ..loading = false
        ..request = (AliceHttpRequest()
          ..formDataFiles = [
            const AliceFormDataFile('test.txt', 'text/plain', 12),
          ])
        ..response = AliceHttpResponse();

      core.addCall(call);

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: core.configuration.navigatorKey,
          home: CallDetailsPage(call: call, core: core),
        ),
      );
      await tester.pumpAndSettle();

      // Expand FAB menu
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Tap Replay FAB
      await tester.tap(find.byIcon(Icons.replay));
      await tester.pumpAndSettle();

      // Verify error dialog appears with correct title, description, and action
      expect(
        find.descendant(
          of: find.byWidgetPredicate(
            (w) => w.runtimeType.toString() == 'AlertDialog',
          ),
          matching: find.text('Error'),
        ),
        findsOneWidget,
      );
      expect(
        find.text('Multipart/FormData replays are not yet supported.'),
        findsOneWidget,
      );
      expect(find.text('Accept'), findsOneWidget);

      // Dismiss dialog
      await tester.tap(find.text('Accept'));
      await tester.pumpAndSettle();

      expect(
        find.text('Multipart/FormData replays are not yet supported.'),
        findsNothing,
      );
    },
  );

  testWidgets('CallsListPage overflow menu Sort displays SortDialog', (
    WidgetTester tester,
  ) async {
    final core = AliceCore(
      configuration: AliceConfiguration(showNotification: false),
    );

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: core.configuration.navigatorKey,
        home: CallsListPage(core: core),
      ),
    );
    await tester.pumpAndSettle();

    // Open context menu
    await tester.tap(
      find.byWidgetPredicate(
        (w) => w.runtimeType.toString().contains('PopupMenuButton'),
      ),
    );
    await tester.pumpAndSettle();

    // Tap Sort item
    await tester.tap(find.text('Sort'));
    await tester.pumpAndSettle();

    // Verify sort dialog is displayed
    expect(find.text('Select filter'), findsOneWidget);
    expect(find.byType(SortDialog), findsOneWidget);
  });

  testWidgets(
    'CallsListPage overflow menu Delete displays confirmation dialog and deletes calls on confirm',
    (WidgetTester tester) async {
      final core = AliceCore(
        configuration: AliceConfiguration(showNotification: false),
      );

      final call = AliceHttpCall(1)
        ..method = 'GET'
        ..endpoint = '/test'
        ..server = 'api.example.com'
        ..uri = 'https://api.example.com/test'
        ..loading = false
        ..request = AliceHttpRequest()
        ..response = AliceHttpResponse();
      core.addCall(call);

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: core.configuration.navigatorKey,
          home: CallsListPage(core: core),
        ),
      );
      await tester.pumpAndSettle();

      // Open context menu
      await tester.tap(
        find.byWidgetPredicate(
          (w) => w.runtimeType.toString().contains('PopupMenuButton'),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Delete
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Verify confirmation dialog
      expect(find.text('Delete calls'), findsOneWidget);
      expect(find.text('Do you want to delete HTTP calls?'), findsOneWidget);
      expect(find.text('No'), findsOneWidget);
      expect(find.text('Yes'), findsOneWidget);

      // Tap No to cancel
      await tester.tap(find.text('No'));
      await tester.pumpAndSettle();

      expect(find.text('Delete calls'), findsNothing);
      expect(core.getCalls().length, 1);

      // Open context menu again
      await tester.tap(
        find.byWidgetPredicate(
          (w) => w.runtimeType.toString().contains('PopupMenuButton'),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Delete
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Tap Yes to confirm
      await tester.tap(find.text('Yes'));
      await tester.pumpAndSettle();

      expect(find.text('Delete calls'), findsNothing);
      expect(core.getCalls(), isEmpty);
    },
  );

  testWidgets('CallsListPage overflow menu Save displays ExportFormatDialog', (
    WidgetTester tester,
  ) async {
    final core = AliceCore(
      configuration: AliceConfiguration(showNotification: false),
    );

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: core.configuration.navigatorKey,
        home: CallsListPage(core: core),
      ),
    );
    await tester.pumpAndSettle();

    // Open context menu
    await tester.tap(
      find.byWidgetPredicate(
        (w) => w.runtimeType.toString().contains('PopupMenuButton'),
      ),
    );
    await tester.pumpAndSettle();

    // Tap Save
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Verify ExportFormatDialog is displayed
    expect(find.text('Select export format'), findsOneWidget);
    expect(find.byType(ExportFormatDialog), findsOneWidget);
  });

  testWidgets(
    'CallsListPage Logger tab delete action displays confirmation dialog and clears logs on confirm',
    (WidgetTester tester) async {
      final core = AliceCore(
        configuration: AliceConfiguration(showNotification: false),
      );

      core.addLog(AliceLog(message: 'Test log', timestamp: DateTime.now()));

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: core.configuration.navigatorKey,
          home: CallsListPage(core: core),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to Logger tab
      await tester.tap(find.text('Logger'));
      await tester.pumpAndSettle();

      // Tap delete icon in AppBar
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      // Verify confirmation dialog
      expect(find.text('Delete logs'), findsOneWidget);
      expect(find.text('Do you want to clear logs?'), findsOneWidget);
      expect(find.text('No'), findsOneWidget);
      expect(find.text('Yes'), findsOneWidget);

      // Tap No to cancel
      await tester.tap(find.text('No'));
      await tester.pumpAndSettle();

      expect(find.text('Delete logs'), findsNothing);
      expect(core.configuration.aliceLogger.logs.isNotEmpty, isTrue);

      // Tap delete icon again
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      // Tap Yes to confirm
      await tester.tap(find.text('Yes'));
      await tester.pumpAndSettle();

      expect(find.text('Delete logs'), findsNothing);
      expect(core.configuration.aliceLogger.logs, isEmpty);
    },
  );

  testWidgets(
    'CallsListPage search help button displays help dialog and dismisses on tap',
    (WidgetTester tester) async {
      final core = AliceCore(
        configuration: AliceConfiguration(showNotification: false),
      );

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: core.configuration.navigatorKey,
          home: CallsListPage(core: core),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Search icon to enable search mode
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Tap Help icon
      await tester.tap(find.byIcon(Icons.help_outline));
      await tester.pumpAndSettle();

      // Verify help dialog
      expect(find.text('Advanced Search'), findsOneWidget);
      expect(find.text('Accept'), findsOneWidget);

      await tester.tap(find.text('Accept'));
      await tester.pumpAndSettle();

      expect(find.text('Advanced Search'), findsNothing);
    },
  );
}
