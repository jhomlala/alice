import 'package:alice/src/services/notification/notification_stub.dart';
import 'package:alice/src/services/storage/alice_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cupertino_ui/cupertino_ui.dart';

class MockBuildContext extends Mock implements BuildContext {}

void main() {
  group('AliceNotificationService Stub', () {
    late AliceNotificationService notificationService;

    setUp(() {
      notificationService = AliceNotificationService();
    });

    test('should have configure method as no-op', () {
      expect(
        () => notificationService.configure(
          notificationIcon: 'app_icon',
          openInspectorCallback: () {},
        ),
        returnsNormally,
      );
    });

    test('should have showStatsNotification method as no-op', () async {
      final context = MockBuildContext();
      final stats = (
        total: 0,
        successes: 0,
        redirects: 0,
        errors: 0,
        loading: 0,
      );

      expect(
        () => notificationService.showStatsNotification(
          context: context,
          stats: stats,
        ),
        returnsNormally,
      );
    });
  });
}
