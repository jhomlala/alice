---
slug: /
sidebar_position: 1
sidebar_label: 'Introduction'
---

# Introduction

Alice is a powerful HTTP Inspector tool for Flutter that helps you debug network requests effortlessly. It catches and stores HTTP requests and responses, allowing you to view them directly on your device via a simple, built-in UI.

:::info Inspiration
Alice was heavily inspired by the popular Android networking tools **Chuck** and **Chucker**.
:::

## Core Capabilities

Alice goes beyond simple logging by providing a fully-featured UI inside your Flutter app:

* **Detailed Request Logging:** Inspect headers, body, query parameters, and response times for every HTTP call.
* **On-Device Inspector UI:** No need to connect your phone to a computer. Simply view all network traffic directly on the device screen.
* **Shake to Open:** Easily trigger the inspector at any time by physically shaking your device.
* **Search and Statistics:** Filter through hundreds of API calls and view basic network usage statistics.
* **Save & Export:** Save HTTP call data to your device's file system or export the logs for deeper analysis.

## Extensive Client Support

Whether you use the default Dart libraries or third-party packages, Alice has you covered. Alice supports seamless interception for the most popular Dart HTTP clients:
* `Dio`
* `Chopper`
* `http` (from the `http/http` package)
* `HttpClient` (from `dart:io`)

## Quick Start

Add Alice to your `pubspec.yaml`:

```yaml
dependencies:
  alice: ^1.2.0
```

Initialize Alice and attach it to your app's navigation:

```dart
// 1. Create Alice instance
Alice alice = Alice();

// 2. Pass its navigator key to your app
MaterialApp(
  navigatorKey: alice.getNavigatorKey(),
  home: MyApp(),
);
```

> **Next Steps:** Head over to the **HTTP Clients** section in the sidebar to see how to connect Alice to your specific networking library!
