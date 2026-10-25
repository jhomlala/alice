import 'package:alice_notification/src/services/notification/notification_stub.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AliceLocalNotification stub initializes without error', () {
    final notification = AliceLocalNotification();
    expect(notification.notificationIcon, '@mipmap/ic_launcher');
    expect(notification.notificationLargeIcon, isNull);
    expect(
      () => notification.configure(openInspectorCallback: () {}),
      returnsNormally,
    );
    expect(() => notification.dispose(), returnsNormally);
  });
}
