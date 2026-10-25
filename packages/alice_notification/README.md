# alice_notification

Local OS notifications adapter for [Alice](https://pub.dev/packages/alice) HTTP Inspector using `flutter_local_notifications`.

## Getting Started

Add `alice_notification` to your `pubspec.yaml`:

```yaml
dependencies:
  alice: ^2.0.0
  alice_notification: ^1.0.0
```

Configure Alice with the notification adapter:

```dart
import 'package:alice/alice.dart';
import 'package:alice_notification/alice_notification.dart';

final alice = Alice(
  configuration: AliceConfiguration(
    notificationAdapter: AliceLocalNotification(
      notificationIcon: '@mipmap/ic_launcher',
    ),
  ),
);
```
