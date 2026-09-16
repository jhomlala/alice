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

## Search & Filtering

Alice features a powerful search bar in the Inspector UI to help you quickly find specific HTTP calls. You can use plain text to search through request endpoints, or use the advanced syntax filters for pinpoint precision:

- `method:GET` (or POST, PUT, DELETE, etc.)
- `status:200` (or 404, 500, etc.)
- `host:google.com` (matches the server/host name)
- `client:dio` (matches the HTTP client used)
- `duration:>1000` (finds requests that took longer than 1000ms. Supports `<`, `>`, and `=`)

You can combine multiple filters. For example, typing `status:500 method:POST api/users` will filter for all failed POST requests to the `api/users` endpoint.

## Exporting Calls (HAR & TXT)

Alice allows you to export your captured HTTP calls for offline sharing or analysis. You can trigger this from the overflow menu in the Calls List. Alice supports two formats:
- **TXT**: A simple, human-readable text file containing the headers, bodies, and metadata of your calls.
- **HAR (HTTP Archive 1.2)**: An industry-standard JSON-based format. HAR files can be imported into tools like Google Chrome DevTools, Postman, or Charles Proxy for deep analysis.