<p align="center">
<img src="https://raw.githubusercontent.com/jhomlala/alice/master/assets/media/logo.png" width="250px">
</p>

# Alice - HTTP Inspector for Flutter

[![pub package](https://img.shields.io/pub/v/alice.svg)](https://pub.dartlang.org/packages/alice)
[![platform](https://img.shields.io/badge/platform-flutter-blue.svg)](https://github.com/jhomlala/alice)

[![alice_dio](https://img.shields.io/pub/v/alice_dio.svg?label=alice_dio)](https://pub.dartlang.org/packages/alice_dio)
[![alice_chopper](https://img.shields.io/pub/v/alice_chopper.svg?label=alice_chopper)](https://pub.dartlang.org/packages/alice_chopper)
[![alice_http](https://img.shields.io/pub/v/alice_http.svg?label=alice_http)](https://pub.dartlang.org/packages/alice_http)
[![alice_http_client](https://img.shields.io/pub/v/alice_http_client.svg?label=alice_http_client)](https://pub.dartlang.org/packages/alice_http_client)
[![alice_graphql_client](https://img.shields.io/pub/v/alice_graphql_client.svg?label=alice_graphql_client)](https://pub.dartlang.org/packages/alice_graphql_client)
[![alice_objectbox](https://img.shields.io/pub/v/alice_objectbox.svg?label=alice_objectbox)](https://pub.dartlang.org/packages/alice_objectbox)
[![alice_notification](https://img.shields.io/pub/v/alice_notification.svg?label=alice_notification)](https://pub.dartlang.org/packages/alice_notification)

---

## Why Alice?

Alice catches your app's HTTP traffic so you can debug API issues without a proxy: headers, body, response times, the works. All viewable on-device via a built-in UI.

Whether you are hunting down a broken payload, checking headers, or monitoring performance, Alice gives you what you need directly inside your app. Inspired by [Chuck](https://github.com/jgilfelt/chuck) and [Chucker](https://github.com/ChuckerTeam/chucker).

## Screenshots

<table>
  <tr>
    <td><img width="250px" src="https://raw.githubusercontent.com/jhomlala/alice/master/assets/media/01_calls_list.png" alt="Calls List"></td>
    <td><img width="250px" src="https://raw.githubusercontent.com/jhomlala/alice/master/assets/media/02_request_details.png" alt="Request Details"></td>
    <td><img width="250px" src="https://raw.githubusercontent.com/jhomlala/alice/master/assets/media/03_json_viewer.png" alt="JSON Viewer"></td>
    <td><img width="250px" src="https://raw.githubusercontent.com/jhomlala/alice/master/assets/media/04_timeline.png" alt="Timeline"></td>
  </tr>
  <tr>
    <td align="center"><b>Calls List</b></td>
    <td align="center"><b>Request Details</b></td>
    <td align="center"><b>JSON Viewer</b></td>
    <td align="center"><b>Timeline</b></td>
  </tr>
  <tr>
    <td><img width="250px" src="https://raw.githubusercontent.com/jhomlala/alice/master/assets/media/05_stats_dashboard.png" alt="Stats Dashboard"></td>
    <td><img width="250px" src="https://raw.githubusercontent.com/jhomlala/alice/master/assets/media/06_advanced_search.png" alt="Advanced Search"></td>
    <td><img width="250px" src="https://raw.githubusercontent.com/jhomlala/alice/master/assets/media/07_request_replay.png" alt="Request Replay"></td>
    <td><img width="250px" src="https://raw.githubusercontent.com/jhomlala/alice/master/assets/media/08_dark_mode.png" alt="Dark Mode"></td>
  </tr>
  <tr>
    <td align="center"><b>Stats Dashboard</b></td>
    <td align="center"><b>Advanced Search</b></td>
    <td align="center"><b>Request Replay</b></td>
    <td align="center"><b>Dark Mode</b></td>
  </tr>
</table>

## Key Features

**🔍 Deep Inspection**
* Detailed logs for every HTTP call (Headers, Body, Query Parameters, Timestamps)
* Interactive tree-based JSON & XML viewer with node collapsing/expanding
* Copy JSONPath, values, or subtree on long press
* Gantt chart Timeline to visually inspect staggered HTTP calls
* Powerful HTTP calls search (with advanced syntax filters) and filtering
* Programmatic Call Tagging (e.g., `alice.tag(tag: 'login-flow')`)
* Automatic N+1 duplicate request detection
* Capture-time security redaction for sensitive headers, cookies, query params, and body keys
* Statistics dashboard (bandwidth, success rate, call counts, ratio bars)
* Flutter & Android native log integration
* Dart VM Service extensions (`ext.alice.*`) in debug builds for IDE and AI coding agent querying

**🛠️ Broad Compatibility**
* Supports all major Dart HTTP clients: **Dio**, **Retrofit**, **http**, **HttpClient (dart:io)**, **Chopper**, and **GraphQL**
* Standalone notification package (`alice_notification`) keeping core Alice free of native OS dependencies

**📱 UX & Workflow**
* Draggable in-app floating overlay bubble (`showOverlayBubble: true`) with live call stats, in-flight spinner, and color-coded badges
* Request Replay: resend HTTP calls directly from the inspector
* Shake the device to open the inspector
* Optional system notifications on HTTP calls via `alice_notification`
* Export and save HTTP calls to file (TXT or **HAR**) for easy sharing
* Persistent storage support (via ObjectBox)

## Quick Start

### 1. Add dependency
Add the core Alice package (and whichever client adapters you need) to your `pubspec.yaml`:
```yaml
dependencies:
  alice: ^2.0.0
  # Add client adapter(s) as needed, e.g.:
  # alice_dio: ^1.4.0
  # Add notifications if desired:
  # alice_notification: ^1.0.0
```

### 2. Initialize Alice
Create an instance of Alice with your preferred configuration:
```dart
import 'package:alice/alice.dart';
import 'package:alice_notification/alice_notification.dart'; // optional

final configuration = AliceConfiguration(
  showOverlayBubble: true, // Draggable in-app stats pill
  notificationAdapter: AliceLocalNotification(), // Optional OS notifications
  redactedHeaders: {'authorization', 'cookie', 'x-api-key'},
  redactedBodyKeys: {'password', 'token', 'secret'},
);

final alice = Alice(configuration: configuration);
```

### 3. Register the Navigator Key
Pass Alice's navigator key to your `MaterialApp` or `CupertinoApp` so she can open the UI:
```dart
MaterialApp(
  navigatorKey: alice.getNavigatorKey(),
  home: Scaffold(...),
)
```

### 4. Attach to your HTTP Client
Attach an adapter to your HTTP client. For example, using **Dio**:
```dart
import 'package:dio/dio.dart';
import 'package:alice_dio/alice_dio_adapter.dart';

final aliceDioAdapter = AliceDioAdapter();
alice.addAdapter(aliceDioAdapter);

final dio = Dio()..interceptors.add(aliceDioAdapter);

// Now make requests! Alice records them automatically.
dio.get("https://jsonplaceholder.typicode.com/posts");
```

## Floating Overlay Bubble

Set `showOverlayBubble: true` in `AliceConfiguration` to display a draggable floating pill counter over your application:
* **Auto-revealed**: Stays hidden until the first HTTP call is recorded.
* **Alice Color Scheme**: Green dot and badge for successful calls (`2xx`), orange spinner and badge for in-flight requests, and red badge for failed calls (`4xx`/`5xx`).
* **Tap to open**: Tapping the bubble opens the full inspector; dragging repositions it anywhere on screen.
* **Programmatic control**:
  * `alice.showOverlayBubble()`: Manually mounts or restores the bubble.
  * `alice.hideOverlayBubble()`: Manually hides the bubble.
  * `alice.isOverlayBubbleVisible`: Checks if the bubble is currently mounted.

## Security Redaction

Prevent API keys, passwords, and tokens from leaking into logs, exports, or screenshots:
```dart
AliceConfiguration(
  redactedHeaders: {'authorization', 'x-api-key', 'cookie'},
  redactedBodyKeys: {'password', 'token', 'secret', 'client_secret'},
  redactionReplacement: '***REDACTED***', // Defaults to '[REDACTED]'
)
```
Redaction happens at capture time before storage, covering JSON/Map objects recursively, query parameters, form fields, and `x-www-form-urlencoded` bodies.

## VM Service Extensions

In debug mode (`kDebugMode`), Alice registers VM Service extensions that IDEs, DevTools, or AI agents can query without opening the UI:
* `ext.alice.getCalls`: List intercepted calls with method, URI, duration, and status.
* `ext.alice.getCallDetails`: Retrieve full request/response details for a call by ID.
* `ext.alice.getStats`: Read live stats (total, loading, successes, redirects, errors).
* `ext.alice.openInspector`: Trigger Alice UI navigation programmatically.
* `ext.alice.clearCalls`: Flush in-memory calls.

## Architecture: Why Multiple Packages?

Alice uses a modular multi-package architecture (e.g., `alice_dio`, `alice_http`, `alice_notification`).

Many similar inspector packages force you to pull in a massive dependency tree (Dio, HTTP, Chopper, GraphQL, local notifications) all at once, even if your app only uses one. This bloats app size, slows build times, and causes dependency conflicts.

With Alice, you only install the core `alice` package and the specific adapter you need.

## Documentation
For complete setup instructions, advanced configuration, and plugin details, please check the [Full Documentation](https://jhomlala.github.io/alice/).

## Custom Integrations & Enterprise Support

Alice has been the go-to Flutter HTTP inspector since its first release, and the ecosystem keeps growing. If your team needs something beyond what's here (a custom adapter for an internal HTTP client, a bespoke export format, enterprise storage backend, or anything else), I'm available for consulting.

[Let's talk on LinkedIn →](https://pl.linkedin.com/in/jhomlala)
