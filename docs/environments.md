---
sidebar_label: 'Environments & Flavors'
---

# Handling Environments (Production / Flavors)

When developing a Flutter application, you often have multiple environments like Development, Staging, and Production. 

While Alice is great for debugging in Development and Staging, you should exclude it from Production builds to prevent overhead and avoid exposing API traffic to end users.

Here are three common approaches to conditionally enable Alice based on your build environment.

## 1. Using `kDebugMode` (Simplest)

Use Flutter's built-in `kDebugMode` from `package:flutter/foundation.dart`. Dart tree-shakes code behind `kDebugMode` in release builds:

```dart
import 'package:flutter/foundation.dart';
import 'package:alice/alice.dart';
import 'package:alice_dio/alice_dio_adapter.dart';
import 'package:dio/dio.dart';

Alice? alice;

void initAlice() {
  if (kDebugMode) {
    alice = Alice();
  }
}

void configureDio(Dio dio) {
  if (alice != null) {
    final adapter = AliceDioAdapter();
    alice!.addAdapter(adapter);
    dio.interceptors.add(adapter);
  }
}
```

## 2. Using Custom Environment Flags (Flavors)

If you need Alice enabled in a Staging flavor running in release mode (where `kDebugMode` is false), use Dart environment declarations (`--dart-define`):

```dart
class EnvironmentConfig {
  // Pass during build: flutter build apk --dart-define=ENABLE_INSPECTOR=true
  static const bool enableInspector = bool.fromEnvironment('ENABLE_INSPECTOR', defaultValue: false);
}

Alice? alice;

void initAlice() {
  if (EnvironmentConfig.enableInspector) {
    alice = Alice();
  }
}
```

## 3. Dependency Injection & Interfaces (Advanced)

To decouple your networking layer from the `alice` package entirely, abstract the inspector behind an interface:

**1. Create a generic inspector interface:**
```dart
import 'package:dio/dio.dart';

abstract class NetworkInspector {
  void attachToDio(Dio dio);
}
```

**2. Create the Alice implementation (Dev / Staging):**
```dart
import 'package:alice/alice.dart';
import 'package:alice_dio/alice_dio_adapter.dart';
import 'package:dio/dio.dart';

class AliceNetworkInspector implements NetworkInspector {
  final Alice _alice = Alice();
  final AliceDioAdapter _adapter = AliceDioAdapter();

  AliceNetworkInspector() {
    _alice.addAdapter(_adapter);
  }

  @override
  void attachToDio(Dio dio) {
    dio.interceptors.add(_adapter);
  }
}
```

**3. Create a No-Op implementation (Production):**
```dart
import 'package:dio/dio.dart';

class NoOpNetworkInspector implements NetworkInspector {
  @override
  void attachToDio(Dio dio) {
    // No-op in production
  }
}
```

Inject `NoOpNetworkInspector` in production builds. Your networking code stays clean and Alice is completely bypassed.
