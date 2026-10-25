---
sidebar_label: 'Advanced Usage'
---

# Advanced Usage

## Show inspector manually

If you don't use shake or notifications, open the inspector manually:

```dart
alice.showInspector();
```

### Desktop and Web Usage (Floating Overlay Bubble)

While "shake to open" is mobile-only, Alice 2.0.0 includes a built-in draggable floating overlay bubble (`showOverlayBubble: true`) that works seamlessly across Mobile, Desktop, and Web:

```dart
Alice alice = Alice(
  configuration: AliceConfiguration(showOverlayBubble: true),
);
```

Or control it on demand:
```dart
alice.showOverlayBubble(); // Show bubble
alice.hideOverlayBubble(); // Hide bubble
final isVisible = alice.isOverlayBubbleVisible; // Check status
```

## Dart VM Service Extensions

In debug mode (`kDebugMode`), Alice automatically registers standard Dart VM Service extensions. IDE extensions, DevTools, CI test runners, or AI pair programming agents can query network traffic without needing to open the UI:

| Extension | Parameters | Description |
|---|---|---|
| `ext.alice.getCalls` | None | Returns summary of all captured calls (ID, method, endpoint, status, duration) |
| `ext.alice.getCallDetails` | `id` | Returns full request/response details, headers, query params, and body for a call |
| `ext.alice.getStats` | None | Returns aggregate statistics (total, successes, loading, redirects, errors) |
| `ext.alice.openInspector` | None | Navigates the app to the Alice inspector UI programmatically |
| `ext.alice.clearCalls` | None | Clears all captured calls from storage |

## Flutter logs

Log Flutter messages in Alice alongside your network traffic:

```dart
alice.addLog(log);

alice.addLogs(logList);
```

## Inspector state

Check whether the inspector is currently open:

```dart
final isOpened = alice.isInspectorOpened;
```

## Programmatic Call Tagging

To track which business logic or UI flow triggered a network call, tag upcoming requests programmatically. The tag attaches to intercepted calls and shows up as a badge in the Alice UI. You can also filter by tag using `tag:my-tag`.

```dart
// Tags the next HTTP call with 'login-flow'
alice.tag(tag: 'login-flow');
await authService.login(user, pass);

// Optionally specify how many upcoming calls this tag should apply to
alice.tag(tag: 'init-flow', maxCalls: 3);

// Clear the active tag manually
alice.clearTag();
```

## Custom & Generic HTTP Clients

If you use an in-house networking client or a library without an official adapter, log calls directly with `alice.addHttpCall()`:

```dart
import 'package:alice/alice.dart';

final call = AliceHttpCall(DateTime.now().millisecondsSinceEpoch)
  ..method = 'POST'
  ..endpoint = '/api/v1/auth'
  ..server = 'api.example.com'
  ..client = 'CustomClient'
  ..uri = 'https://api.example.com/api/v1/auth';

final request = AliceHttpRequest()
  ..size = 24
  ..body = '{"user": "alice"}'
  ..headers = {'content-type': 'application/json'};

final response = AliceHttpResponse()
  ..status = 200
  ..size = 18
  ..body = '{"token": "xyz"}';

call.request = request;
call.response = response;

alice.addHttpCall(call);
```

### Writing a Custom Adapter
Create reusable adapters by applying the `AliceAdapter` mixin:

```dart
import 'package:alice/alice.dart';

class CustomClientAdapter with AliceAdapter {
  void onCallFinished(AliceHttpCall call) {
    aliceCore.addCall(call);
  }
}

// Register with Alice:
final adapter = CustomClientAdapter();
alice.addAdapter(adapter);
```
