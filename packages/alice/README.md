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

---

## Why Alice?

Alice is an advanced HTTP Inspector tool for Flutter that helps you debug network requests effortlessly. It catches and stores HTTP requests and responses, allowing you to view detailed network logs directly within your app via a simple and intuitive UI. 

Whether you are hunting down a broken API payload, checking headers, or monitoring performance, Alice provides all the details you need without requiring a proxy or external desktop tools. It's inspired by [Chuck](https://github.com/jgilfelt/chuck) and [Chucker](https://github.com/ChuckerTeam/chucker).

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
* Interactive tree-based JSON viewer for request and response bodies
* Gantt chart Timeline to visually inspect staggered HTTP calls
* Powerful HTTP calls search (with advanced syntax filters) and filtering
* Statistics dashboard (bandwidth, success rate, call counts, ratio bars)
* Flutter & Android native log integration

**🛠️ Broad Compatibility**
* Supports all major Dart HTTP clients: **Dio**, **Retrofit**, **http**, **HttpClient (dart:io)**, **Chopper**, and **GraphQL**

**📱 UX & Workflow**
* Request Replay - resend HTTP calls directly from the inspector
* Shake the device to open the inspector instantly
* System notifications on HTTP calls
* Export and save HTTP calls to file (TXT or **HAR**) for easy sharing
* Persistent storage support (via ObjectBox)

## Quick Start

### 1. Add dependency
Add the main Alice package (and any specific client plugins you need) to your `pubspec.yaml`:
```yaml
dependencies:
  alice: ^1.8.0
  # Add plugins as needed, e.g.:
  # alice_dio: ^1.3.0
```

### 2. Initialize Alice
Create an instance of Alice. You should generally keep it as a singleton or provide it via dependency injection.
```dart
import 'package:alice/alice.dart';

Alice alice = Alice(
  showNotification: true,
  showInspectorOnShake: true,
);
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
Alice works by attaching an interceptor to your HTTP client. For example, using **Dio**:
```dart
import 'package:dio/dio.dart';
import 'package:alice_dio/alice_dio_adapter.dart';

Dio dio = Dio();
dio.interceptors.add(AliceDioAdapter().getInterceptor(alice));

// Now make requests! Alice will automatically record them.
dio.get("https://jsonplaceholder.typicode.com/posts");
```
*For instructions on how to attach Alice to Chopper, standard http, or GraphQL, see the full documentation.*


## Architecture: Why Multiple Packages?

You may notice that Alice uses a multi-package architecture (e.g., `alice_dio`, `alice_http`, `alice_chopper`). This is a deliberate design choice!

Many similar inspector packages force you to pull in a massive dependency tree (Dio, HTTP, Chopper, GraphQL, etc.) all at once, even if your app only uses one of them. This is a **bad pattern** that bloats your app size, slows down build times, and causes version conflicts. 

With Alice, you only install the core `alice` package and the specific adapter you need (e.g., `alice_dio`). We strictly avoid enforcing unnecessary dependencies on your project.

## Documentation
For complete setup instructions, advanced configuration, and plugin details, please check the [Full Documentation](https://jhomlala.github.io/alice/).
