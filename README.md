<p align="center">
  <img src="https://raw.githubusercontent.com/jhomlala/alice/master/assets/media/logo.png" width="250" alt="Alice logo">
</p>

# Alice

[![pub package](https://img.shields.io/pub/v/alice.svg)](https://pub.dev/packages/alice)
[![platform](https://img.shields.io/badge/platform-flutter-blue.svg)](https://github.com/jhomlala/alice)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/jhomlala/alice/blob/master/LICENSE)

Alice catches your app's HTTP traffic so you can debug API issues without an external proxy: headers, body, response times, the works. View and inspect everything on-device in a dedicated UI.

Inspired by [Chuck](https://github.com/jgilfelt/chuck) and [Chucker](https://github.com/ChuckerTeam/chucker).

---

## Screenshots

<table>
  <tr>
    <td><img width="250" src="https://raw.githubusercontent.com/jhomlala/alice/master/assets/media/01_calls_list.png" alt="Calls List"></td>
    <td><img width="250" src="https://raw.githubusercontent.com/jhomlala/alice/master/assets/media/02_request_details.png" alt="Request Details"></td>
    <td><img width="250" src="https://raw.githubusercontent.com/jhomlala/alice/master/assets/media/03_json_viewer.png" alt="JSON Viewer"></td>
    <td><img width="250" src="https://raw.githubusercontent.com/jhomlala/alice/master/assets/media/04_timeline.png" alt="Timeline"></td>
  </tr>
  <tr>
    <td align="center"><b>Calls List</b></td>
    <td align="center"><b>Request Details</b></td>
    <td align="center"><b>JSON Viewer</b></td>
    <td align="center"><b>Timeline</b></td>
  </tr>
  <tr>
    <td><img width="250" src="https://raw.githubusercontent.com/jhomlala/alice/master/assets/media/05_stats_dashboard.png" alt="Stats Dashboard"></td>
    <td><img width="250" src="https://raw.githubusercontent.com/jhomlala/alice/master/assets/media/06_advanced_search.png" alt="Advanced Search"></td>
    <td><img width="250" src="https://raw.githubusercontent.com/jhomlala/alice/master/assets/media/07_request_replay.png" alt="Request Replay"></td>
    <td><img width="250" src="https://raw.githubusercontent.com/jhomlala/alice/master/assets/media/08_dark_mode.png" alt="Dark Mode"></td>
  </tr>
  <tr>
    <td align="center"><b>Stats Dashboard</b></td>
    <td align="center"><b>Advanced Search</b></td>
    <td align="center"><b>Request Replay</b></td>
    <td align="center"><b>Dark Mode</b></td>
  </tr>
</table>

## Features

- **On-device inspector**: Complete logs for every HTTP request and response (headers, bodies, query params, status codes, and timing).
- **Tree viewers**: Collapsible JSON and XML viewer with node search and long-press shortcuts to copy values, JSONPath, or subtrees.
- **Timeline**: Gantt chart view to spot waterfall bottlenecks and slow endpoints at a glance.
- **Floating overlay**: Draggable in-app pill with real-time stats, in-flight spinner, and color-coded status badges.
- **Request replay**: Re-run captured HTTP calls right from the inspector.
- **Search & filtering**: Filter by method, status code, endpoint URI, query params, or headers.
- **Security redaction**: Strip sensitive headers, cookies, query parameters, and body fields before storage.
- **Call tagging & duplicate detection**: Tag calls programmatically by user flow (`alice.tag()`) and spot accidental N+1 duplicate queries.
- **Exporting**: Save logs as plain text or standard HAR files for Charles, Proxyman, or Postman.
- **VM Service extensions**: Query network state headlessly (`ext.alice.*`) via Dart VM Service from IDEs, scripts, or AI coding agents.
- **Modular design**: Core Alice has zero native dependencies and does not force any specific HTTP client onto your app.

## Quick Start

### 1. Add dependencies

Add `alice` and the adapter matching your HTTP client to `pubspec.yaml`:

```yaml
dependencies:
  alice: ^2.0.0
  alice_dio: ^1.4.0 # or alice_http, alice_http_client, alice_chopper, etc.
```

### 2. Initialize Alice

```dart
import 'package:alice/alice.dart';

final configuration = AliceConfiguration(
  showOverlayBubble: true,
  redactedHeaders: {'authorization', 'cookie', 'x-api-key'},
  redactedBodyKeys: {'password', 'token', 'secret'},
);

final alice = Alice(configuration: configuration);
```

### 3. Attach navigator key

Alice needs access to your app's navigation stack to display the inspector:

```dart
MaterialApp(
  navigatorKey: alice.getNavigatorKey(),
  home: const MyHomePage(),
);
```

### 4. Hook into your HTTP client

Register the adapter with Alice and attach it to your client. Here is Dio:

```dart
import 'package:alice_dio/alice_dio_adapter.dart';
import 'package:dio/dio.dart';

final aliceDioAdapter = AliceDioAdapter();
alice.addAdapter(aliceDioAdapter);

final dio = Dio()..interceptors.add(aliceDioAdapter);
```

Make your requests as usual. Alice logs them automatically.

## Packages

Alice is split into focused packages so you only pull in dependencies your app actually uses:

| Package | Description | Pub |
|---|---|---|
| [`alice`](https://pub.dev/packages/alice) | Core inspector, overlay bubble, HAR export | [![pub](https://img.shields.io/pub/v/alice.svg)](https://pub.dev/packages/alice) |
| [`alice_dio`](https://pub.dev/packages/alice_dio) | Adapter for [Dio](https://pub.dev/packages/dio) | [![pub](https://img.shields.io/pub/v/alice_dio.svg)](https://pub.dev/packages/alice_dio) |
| [`alice_http`](https://pub.dev/packages/alice_http) | Adapter for [`package:http`](https://pub.dev/packages/http) | [![pub](https://img.shields.io/pub/v/alice_http.svg)](https://pub.dev/packages/alice_http) |
| [`alice_http_client`](https://pub.dev/packages/alice_http_client) | Adapter for `dart:io` `HttpClient` | [![pub](https://img.shields.io/pub/v/alice_http_client.svg)](https://pub.dev/packages/alice_http_client) |
| [`alice_chopper`](https://pub.dev/packages/alice_chopper) | Adapter for [Chopper](https://pub.dev/packages/chopper) | [![pub](https://img.shields.io/pub/v/alice_chopper.svg)](https://pub.dev/packages/alice_chopper) |
| [`alice_graphql_client`](https://pub.dev/packages/alice_graphql_client) | Adapter for [GraphQL](https://pub.dev/packages/graphql_flutter) | [![pub](https://img.shields.io/pub/v/alice_graphql_client.svg)](https://pub.dev/packages/alice_graphql_client) |
| [`alice_notification`](https://pub.dev/packages/alice_notification) | Local OS notifications on HTTP traffic | [![pub](https://img.shields.io/pub/v/alice_notification.svg)](https://pub.dev/packages/alice_notification) |
| [`alice_objectbox`](https://pub.dev/packages/alice_objectbox) | Persistent call storage via ObjectBox | [![pub](https://img.shields.io/pub/v/alice_objectbox.svg)](https://pub.dev/packages/alice_objectbox) |

## Overlay Bubble

Set `showOverlayBubble: true` in `AliceConfiguration` to float a draggable pill over your application:

- **Status at a glance**: Displays an in-flight spinner, success count (`2xx`), redirect count (`3xx`), and error count (`4xx`/`5xx`).
- **Quiet until traffic**: Stays hidden until your app records its first HTTP call.
- **Interactive**: Drag to position anywhere on screen. Tap to open the full inspector.

You can also control visibility programmatically:

```dart
alice.showOverlayBubble();
alice.hideOverlayBubble();
final isVisible = alice.isOverlayBubbleVisible;
```

## Security Redaction

Keep tokens, cookies, and passwords out of memory, logs, exports, and screenshots:

```dart
AliceConfiguration(
  redactedHeaders: {'authorization', 'x-api-key', 'cookie'},
  redactedBodyKeys: {'password', 'token', 'secret', 'client_secret'},
  redactionReplacement: '***REDACTED***', // defaults to '[REDACTED]'
)
```

Redaction runs at capture time before calls are stored or rendered. Handles nested JSON objects recursively, query parameters, form fields, and `x-www-form-urlencoded` request bodies.

## VM Service Extensions

In debug mode (`kDebugMode`), Alice exposes Dart VM Service RPCs so external tools can read network traffic headlessly:

| Method | Description |
|---|---|
| `ext.alice.getCalls` | Intercepted calls list with URI, method, duration, and status code |
| `ext.alice.getCallDetails` | Full request and response payload for a specific call ID |
| `ext.alice.getStats` | Live call totals (in-flight, success, redirect, error) |
| `ext.alice.openInspector` | Programmatically open the inspector UI on device |
| `ext.alice.clearCalls` | Flush all captured calls from memory |

## Documentation

Full guides, configuration options, and adapter setups are in the [documentation](https://jhomlala.github.io/alice/).

## Consulting

Need a custom adapter, bespoke export format, or specialized storage backend? I am available for consulting.

[Get in touch on LinkedIn](https://pl.linkedin.com/in/jhomlala)
