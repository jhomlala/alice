<p align="center">
<img src="https://raw.githubusercontent.com/jhomlala/alice/master/packages/alice/media/logo.png" width="250px">
</p>

# Alice - HTTP Inspector for Flutter

[![pub package](https://img.shields.io/pub/v/alice.svg)](https://pub.dartlang.org/packages/alice)
[![platform](https://img.shields.io/badge/platform-flutter-blue.svg)](https://github.com/jhomlala/alice)
[![melos](https://img.shields.io/badge/maintained%20with-melos-f700ff.svg?style=flat-square)](https://github.com/invertase/melos)

**Plugins:**
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
    <td><img width="250px" src="https://raw.githubusercontent.com/jhomlala/alice/master/packages/alice/media/1.png" alt="Calls List"></td>
    <td><img width="250px" src="https://raw.githubusercontent.com/jhomlala/alice/master/packages/alice/media/2.png" alt="Request Details"></td>
    <td><img width="250px" src="https://raw.githubusercontent.com/jhomlala/alice/master/packages/alice/media/3.png" alt="Response Details"></td>
    <td><img width="250px" src="https://raw.githubusercontent.com/jhomlala/alice/master/packages/alice/media/4.png" alt="Error Details"></td>
  </tr>
  <tr>
    <td><img width="250px" src="https://raw.githubusercontent.com/jhomlala/alice/master/packages/alice/media/5.png" alt="Stats"></td>
    <td><img width="250px" src="https://raw.githubusercontent.com/jhomlala/alice/master/packages/alice/media/7.png" alt="Search"></td>
    <td><img width="250px" src="https://raw.githubusercontent.com/jhomlala/alice/master/packages/alice/media/8.png" alt="Dark Mode"></td>
    <td><img width="250px" src="https://raw.githubusercontent.com/jhomlala/alice/master/packages/alice/media/10.png" alt="Export"></td>
  </tr>
</table>

## Key Features

**🔍 Deep Inspection**
* Detailed logs for every HTTP call (Headers, Body, Query Parameters, Timestamps)
* Powerful HTTP calls search and filtering
* Statistics overview (bandwidth, success rate, call counts)
* Flutter & Android native log integration

**🛠️ Broad Compatibility**
* Supports all major Dart HTTP clients: **Dio**, **Retrofit**, **http**, **HttpClient (dart:io)**, **Chopper**, and **GraphQL**

**📱 UX & Workflow**
* Shake the device to open the inspector instantly
* System notifications on HTTP calls
* Export and save HTTP calls to file for easy sharing
* Persistent storage support (via ObjectBox)

## Quick Start

### 1. Add dependency
Add the main Alice package (and any specific client plugins you need) to your `pubspec.yaml`:
```yaml
dependencies:
  alice: ^1.4.0
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

## Documentation
For complete setup instructions, advanced configuration, and plugin details, please check the [Full Documentation](https://jhomlala.github.io/alice/).
