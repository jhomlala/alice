---
sidebar_label: 'Advanced Usage'
---

# Advanced Usage

## Show inspector manually

If you don't use shake or notifications, open the inspector manually:

```dart
alice.showInspector();
```

### Desktop and Web Usage (Floating Action Button)

Since "shake to open" and system notifications are mobile-centric, Web and Desktop apps need a different way to access the inspector. A common approach is a Floating Action Button (FAB) that calls `alice.showInspector()`. 

Below is a lightweight wrapper widget that adds a FAB over your app in debug mode on Desktop and Web:

```dart
import 'package:flutter/material.dart';
import 'package:alice/alice.dart';
import 'package:flutter/foundation.dart';

class AliceWebWrapper extends StatelessWidget {
  final Alice alice;
  final Widget child;

  const AliceWebWrapper({
    super.key,
    required this.alice,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktopOrWeb = kIsWeb || 
        defaultTargetPlatform == TargetPlatform.windows || 
        defaultTargetPlatform == TargetPlatform.macOS || 
        defaultTargetPlatform == TargetPlatform.linux;

    if (!kDebugMode || !isDesktopOrWeb) {
      return child;
    }

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          child,
          Positioned(
            bottom: 16,
            right: 16,
            child: Material(
              color: Colors.transparent,
              child: FloatingActionButton(
                heroTag: 'alice_web_fab',
                onPressed: () => alice.showInspector(),
                child: const Icon(Icons.bug_report),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

Wrap your root widget with it:

```dart
runApp(
  AliceWebWrapper(
    alice: alice,
    child: const MyApp(),
  ),
);
```

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
