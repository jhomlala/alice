---
sidebar_label: 'Advanced Usage'
---

# Advanced Usage

## Show inspector manually

You may need that if you won't use shake or notification:

```dart
alice.showInspector();
```

### Desktop and Web Usage (Floating Action Button)

Since features like "shake to open" and system notifications are heavily mobile-centric, Web and Desktop users need a different way to access the inspector. A common approach is to add a Floating Action Button (FAB) that triggers `alice.showInspector()`. 

Below is a lightweight, copy-pasteable wrapper widget that adds a FAB over your application. It automatically ensures the button only shows up in `debug` mode and on Desktop/Web platforms.

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

**Usage:** Just wrap your root widget with it.

```dart
runApp(
  AliceWebWrapper(
    alice: alice,
    child: const MyApp(),
  ),
);
```

## Flutter logs

If you want to log Flutter logs in Alice, you may use these methods:

```dart
alice.addLog(log);

alice.addLogs(logList);
```


## Inspector state

Check current inspector state (opened/closed) with:

```dart
alice.isInspectorOpened();
```

## Programmatic Call Tagging

If you want to track which business logic or UI flow triggered a network call, you can programmatically tag upcoming requests. The tag will be attached to the next intercepted HTTP calls and displayed as a colored badge in the Alice UI. You can also search for tags using the `tag:my-tag` filter in the inspector.

```dart
// Tags the next HTTP call with 'login-flow'
alice.tag(tag: 'login-flow');
await authService.login(user, pass);

// Optionally specify how many upcoming calls this tag should apply to
alice.tag(tag: 'init-flow', maxCalls: 3);

// Manually clear the active tag if needed
alice.clearTag();
```
## Programmatic Call Tagging

If you want to track which business logic or UI flow triggered a network call, you can programmatically tag upcoming requests. The tag will be attached to the next intercepted HTTP calls and displayed as a colored badge in the Alice UI. You can also search for tags using the `tag:my-tag` filter in the inspector.

```dart
// Tags the next HTTP call with 'login-flow'
alice.tag(tag: 'login-flow');
await authService.login(user, pass);

// Optionally specify how many upcoming calls this tag should apply to
alice.tag(tag: 'init-flow', maxCalls: 3);

// Manually clear the active tag if needed
alice.clearTag();
```