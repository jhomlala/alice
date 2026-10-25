---
sidebar_label: 'Configuration'
---

# Configuration

Alice is designed to be quick to set up with sane defaults, plus full control when you need custom behavior.

## Basic Setup

Create an instance and attach its navigator key to your application so Alice can render its inspector UI over your app.

### 1. Create the Instance
Create a global instance of Alice:

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

### Notifications
Configure Alice to show a system notification whenever HTTP requests are made. Tapping this notification opens the inspector.

:::info Android 13+ Notification Permissions
On Android 13 (API level 33) and above, Alice automatically requests the required runtime notification permission on startup when `showNotification` is `true`.
:::

:::warning iOS Notification Configuration
For notification taps to work correctly on iOS, configure your `ios/Runner/AppDelegate.swift` file.

Add the `flutter_local_notifications` import at the top, then register the plugin callback and set the `UNUserNotificationCenter` delegate inside `didFinishLaunchingWithOptions`:

```swift
import UIKit
import Flutter
import flutter_local_notifications // Add this import

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    // Add these lines for Alice/Local Notifications:
    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
        GeneratedPluginRegistrant.register(with: registry)
    }
    
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }
    // End of Alice configuration

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```
:::

To customize notification icons on Android, use `notificationIcon` for the small icon (defaults to `@mipmap/ic_launcher`) or `notificationLargeIcon` for the large icon.

<div align="center">
<img src="https://developer.android.com/static/images/ui/notifications/notification-callouts_2x.png" height="120px"/>

*Source: [Android Developers - Notification Templates](https://developer.android.com/develop/ui/views/notifications#Templates)*
</div>

```dart
Alice alice = Alice(
  configuration: AliceConfiguration(
    showNotification: true,
    notificationIcon: "myNotificationSmallIconResourceName",
    notificationLargeIcon: "myNotificationLargeIconResourceName",
  ),
);
```

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
