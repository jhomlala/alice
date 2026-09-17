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

## Why Alice instead of Dart DevTools?

Flutter already provides a Network tab in Dart DevTools. So why use Alice? 

While Dart DevTools is excellent for developers actively writing code with a computer connected, Alice provides **runtime, on-device HTTP inspection** that unlocks entirely different workflows:

* **QA Testing:** QA engineers and beta testers can view network traffic and debug API errors directly on physical test devices without needing a computer, IDE, or debugger attached.
* **"On-the-go" Debugging:** Test your app in real-world conditions (e.g., walking outside to test cellular network drops) and instantly inspect failing requests.
* **Shareable Logs:** Encounter a backend error? Alice lets you instantly save and export the exact HTTP logs from the device to share with your backend team.
* **Persistent History:** Dart DevTools clears network logs upon app restart. Alice (when paired with the `alice_objectbox` plugin) persists logs across app restarts, allowing you to catch API calls leading up to a crash.

| Feature | Alice | Dart DevTools |
| :--- | :--- | :--- |
| **Requires IDE / Computer** | ❌ No (Runs natively on-device) | ✅ Yes |
| **Usable by QA / Testers** | ✅ Yes | ❌ No |
| **Export/Share from Device**| ✅ Yes | ❌ No |
| **Survives App Restarts** | ✅ Yes (with ObjectBox) | ❌ No |
| **Shake to Open** | ✅ Yes | ❌ No |

## Core Capabilities

Alice goes beyond simple logging by providing a fully-featured UI inside your Flutter app:

* **Detailed Request Logging:** Inspect headers, body, query parameters, and response times for every HTTP call. Includes an interactive tree-based JSON viewer for payloads.
* **On-Device Inspector UI:** No need to connect your phone to a computer. Simply view all network traffic directly on the device screen.
* **Shake to Open:** Easily trigger the inspector at any time by physically shaking your device.
* **Advanced Search & Filtering:** Filter through hundreds of API calls using powerful syntax (e.g., `status:500 method:POST`).
* **Stats & Timeline:** View a high-level metrics dashboard and a Gantt chart Timeline to visually inspect staggered HTTP calls.
* **Request Replay:** Resend logged HTTP calls directly from the Alice UI to instantly verify fixes without navigating through your app.
* **Save & Export:** Export HTTP call data to TXT or HAR (HTTP Archive) formats for deeper analysis in external tools.

## Extensive Client Support

Whether you use the default Dart libraries or third-party packages, Alice has you covered. Alice supports seamless interception for the most popular Dart HTTP clients:
* `Dio`
* `Chopper`
* `http` (from the `http/http` package)
* `HttpClient` (from `dart:io`)
* `Retrofit`
* `GraphQL`

## Quick Start

Add Alice to your `pubspec.yaml`:

```yaml
dependencies:
  alice: ^1.6.0
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
