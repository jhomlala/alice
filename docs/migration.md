---
sidebar_label: 'Migrations'
---

# Migration Guide

## Migrating from 1.x to 2.0.0

Version 2.0.0 decouples OS notifications from core Alice, adds a built-in draggable overlay bubble, introduces capture-time security redaction, and adds Dart VM Service extensions.

### 1. Notifications Extracted to `alice_notification`
`showNotification`, `notificationIcon`, and `notificationLargeIcon` were removed from `AliceConfiguration` to decouple `flutter_local_notifications` from core Alice.

If your app uses system notifications, add `alice_notification` and plug in `AliceLocalNotification`:

```yaml
dependencies:
  alice: ^2.0.0
  alice_notification: ^1.0.0
```

```dart
// Before (1.x):
AliceConfiguration(
  showNotification: true,
  notificationIcon: 'ic_notification',
)

// After (2.0.0):
import 'package:alice_notification/alice_notification.dart';

AliceConfiguration(
  notificationAdapter: AliceLocalNotification(
    notificationIcon: 'ic_notification',
  ),
)
```

If you don't use OS notifications, you no longer have to bundle `flutter_local_notifications` or configure platform notification permissions.

### 2. Built-in Floating Overlay Bubble
Instead of wrapping your root widget in a custom floating button, enable the built-in draggable overlay:

```dart
AliceConfiguration(
  showOverlayBubble: true, // Appears automatically on first HTTP call
)
```

### 3. Capture-Time Security Redaction
Sensitive headers, cookies, query parameters, and JSON keys can now be sanitized at capture time before storage or display:

```dart
AliceConfiguration(
  redactedHeaders: {'authorization', 'cookie', 'x-api-key'},
  redactedBodyKeys: {'password', 'token', 'secret'},
  redactionReplacement: '***REDACTED***',
)
```

---

## Migrating from 0.x to 1.x

Version 1.0 extracted HTTP client interceptors from the core package into standalone packages to eliminate heavy transitive dependencies.

### 1. Standalone Adapters
Interceptors are no longer bundled into `package:alice`. Install only the adapters your app needs:

```yaml
dependencies:
  alice: ^1.11.1
  alice_dio: ^1.3.4       # For Dio
  alice_http: ^1.4.4      # For package:http
  alice_chopper: ^1.3.4   # For Chopper
```

### 2. Adapter Registration
Methods like `alice.getDioInterceptor()`, `alice.getChopperInterceptor()`, and `alice.onHttpResponse()` were removed from `Alice`.

Instead, create the adapter, register it with `alice.addAdapter()`, and attach it to your client:

```dart
// Before (0.x):
dio.interceptors.add(alice.getDioInterceptor());

// After (1.x):
final adapter = AliceDioAdapter();
alice.addAdapter(adapter);
dio.interceptors.add(adapter);
```

### 3. AliceConfiguration
Constructor parameters for storage, notifications, and gestures moved to `AliceConfiguration`:

```dart
// Before (0.x):
Alice alice = Alice(
  showNotification: true,
  showInspectorOnShake: false,
);

// After (1.x):
Alice alice = Alice(
  configuration: AliceConfiguration(
    showNotification: true,
    showInspectorOnShake: false,
  ),
);
```

---

## Migrating to 1.8.0

Version 1.8.0 reorganized Alice's internals to enforce a strict public API:

1. **Hidden Internal Implementation:** All internal files moved under `lib/src/`. Replace deep imports with the main package export:
```dart
import 'package:alice/alice.dart';
```
2. **Strict Public API:** Only core classes prefixed with `Alice` (`AliceConfiguration`, `AliceLogger`, `AliceHttpCall`, etc.) are exported.
3. **Service Renames:** Internal `Helper` classes (`ExportHelper`, `ReplayHelper`) were renamed to `Service` (`ExportService`, `ReplayService`).
4. **Utils Renamed:** Global `Utils` was renamed to `AliceUtils`.
