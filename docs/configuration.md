---
sidebar_label: 'Configuration'
---

# Configuration

Alice is designed to be quick to set up with sane defaults, plus full control when you need custom behavior.

## Basic Setup

Create an instance and attach its navigator key to your application so Alice can render its inspector UI over your app.

### 1. Create the Instance
Create an instance of Alice:

```dart
Alice alice = Alice();
```

### 2. Attach the Navigator Key
Pass Alice's navigator key to your root `MaterialApp` or `CupertinoApp`:

```dart
MaterialApp(
  navigatorKey: alice.getNavigatorKey(),
  home: MyHomePage(),
);
```

#### Using an Existing Navigator Key
If your application already manages its own custom navigator key, pass it directly via `AliceConfiguration`:

```dart
Alice alice = Alice(
  configuration: AliceConfiguration(navigatorKey: yourNavigatorKeyHere),
);
```

Or set it after initialization:
```dart
alice.setNavigatorKey(yourNavigatorKeyHere);
```

---

## Advanced Configuration

Customize Alice's behavior by passing an `AliceConfiguration` object to the constructor.

### Floating Overlay Bubble

*Added in Alice 2.0.0*

Display an interactive, draggable floating pill counter over your application. It stays hidden until the first HTTP call is recorded, then appears with live statistics:

```dart
Alice alice = Alice(
  configuration: AliceConfiguration(showOverlayBubble: true),
);
```

* **Color Scheme**:
  * **Green**: Successful calls (`2xx`).
  * **Orange**: In-flight requests with spinning indicator (`↻`).
  * **Red**: Failed requests (`4xx`/`5xx` or network errors, `⚠`).
* **Programmatic Control**:
  * `alice.showOverlayBubble()`: Manually mounts or reveals the bubble.
  * `alice.hideOverlayBubble()`: Manually hides the bubble.
  * `alice.isOverlayBubbleVisible`: Returns whether the bubble is currently mounted.

### Security Redaction

*Added in Alice 2.0.0*

Redact sensitive credentials at capture time before calls are stored, displayed, or exported:

```dart
Alice alice = Alice(
  configuration: AliceConfiguration(
    redactedHeaders: {'authorization', 'x-api-key', 'cookie'},
    redactedBodyKeys: {'password', 'token', 'secret', 'client_secret'},
    redactionReplacement: '***REDACTED***', // Defaults to '[REDACTED]'
  ),
);
```

Redaction covers:
* Request & response headers
* Cookie values
* Query parameters
* JSON and Map bodies (applied recursively)
* Form data fields and `x-www-form-urlencoded` payloads

### Notifications (via `alice_notification`)

In Alice 2.0.0, native OS notifications were extracted into the standalone `alice_notification` package to keep core Alice free of native platform dependencies:

```yaml
dependencies:
  alice: ^2.0.0
  alice_notification: ^2.0.0
```

Attach `AliceLocalNotification` to `AliceConfiguration`:

```dart
import 'package:alice/alice.dart';
import 'package:alice_notification/alice_notification.dart';

Alice alice = Alice(
  configuration: AliceConfiguration(
    notificationAdapter: AliceLocalNotification(
      notificationIcon: '@mipmap/ic_launcher',
    ),
  ),
);
```

:::info Android 13+ Notification Permissions
On Android 13 (API level 33) and above, `AliceLocalNotification` automatically requests the required runtime notification permission on startup.
:::

:::warning iOS Notification Configuration
For notification taps to work correctly on iOS, configure your `ios/Runner/AppDelegate.swift` file:

```swift
import UIKit
import Flutter
import flutter_local_notifications

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
        GeneratedPluginRegistrant.register(with: registry)
    }
    
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```
:::

### Shake to Open
Opening the inspector by shaking the device is enabled by default on physical mobile devices. To disable it:

```dart
Alice alice = Alice(
  configuration: AliceConfiguration(showInspectorOnShake: false),
);
```

### UI Directionality
Override the default text direction (e.g., RTL or LTR) for the Alice UI. If omitted, Alice inherits your app's directionality.

```dart
Alice alice = Alice(
  configuration: AliceConfiguration(directionality: TextDirection.ltr),
);
```

### Share Button
The inspector includes a share button by default. To hide it:

```dart
Alice alice = Alice(
  configuration: AliceConfiguration(showShareButton: false),
);
```

### Duplicate Request Detection
Alice automatically detects and highlights N+1 duplicate requests (identical HTTP requests made within a short time window). This helps catch duplicate API calls in UI rebuilds or missing caching layers.

```dart
Alice alice = Alice(
  configuration: AliceConfiguration(
    detectDuplicates: true, // Enabled by default
    duplicateDetectionWindow: Duration(milliseconds: 500), // Default: 500ms
  ),
);
```

### Custom Storage & Logger
Alice uses in-memory storage (`AliceMemoryStorage`, max 1000 calls) and an internal logger (`AliceLogger`, max 1000 logs) by default. You can supply custom instances, such as persistent storage with ObjectBox:

```dart
Alice alice = Alice(
  configuration: AliceConfiguration(
    storage: AliceObjectBox(store: store, maxCallsCount: 1000), // Custom storage
    logger: AliceLogger(maximumSize: 500),                      // Custom logger
  ),
);
```
