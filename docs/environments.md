---
sidebar_label: 'Environments & Flavors'
---

# Handling Environments (Production / Flavors)

When developing a Flutter application, you often have multiple environments such as Development, Staging, and Production (frequently managed via flavors). 

While Alice is an incredible tool for debugging in Development and Staging, **you usually want to exclude it from your Production builds** to avoid unnecessary performance overhead and potential security concerns (such as exposing sensitive network traffic to end users).

Here are three common approaches to conditionally enable Alice based on your build environment.

## 1. Using `kDebugMode` (Simplest)

The easiest way to conditionally enable Alice is by using Flutter's built-in `kDebugMode` constant from the `foundation` package. Dart's compiler uses "tree-shaking" and will safely strip out the initialization code in release builds because it sits behind a constant boolean check.

`dart
import 'package:flutter/foundation.dart';

Alice? alice;

void initAlice() {
  if (kDebugMode) {
    alice = Alice();
  }
}
`

Later, when configuring your HTTP client (e.g., Dio or Http), simply check if Alice was initialized before adding the interceptor:

`dart
if (alice != null) {
  dio.interceptors.add(alice!.getDioInterceptor());
}
`

## 2. Using Custom Environment Flags (Flavors)

If you use custom Flavors, you might want Alice enabled in a specific "Staging" flavor, even if that flavor is compiled in Release mode (where `kDebugMode` would be false). In this case, use dart environment variables or your custom flavor configuration class.

`dart
class EnvironmentConfig {
  // Pass this during build: flutter build apk --dart-define=ENABLE_INSPECTOR=true
  static const bool enableInspector = String.fromEnvironment('ENABLE_INSPECTOR') == 'true';
}

Alice? alice;

void initAlice() {
  if (EnvironmentConfig.enableInspector) {
    alice = Alice();
  }
}
`

## 3. Dependency Injection & Interfaces (Advanced)

If you have a strict architecture and want to guarantee that the `alice` package isn't even imported or referenced in your production HTTP client code, you can abstract it behind an interface using Dependency Injection (e.g., with `get_it`).

**1. Create a generic inspector interface:**
`dart
abstract class NetworkInspector {
  dynamic getInterceptor();
}
`

**2. Create the Alice implementation (Used in Dev/Staging):**
`dart
import 'package:alice/alice.dart';

class AliceNetworkInspector implements NetworkInspector {
  final Alice _alice = Alice();

  @override
  dynamic getInterceptor() {
     return _alice.getDioInterceptor(); // Or whichever client you use
  }
}
`

**3. Create a No-Op implementation (Used in Production):**
`dart
class NoOpNetworkInspector implements NetworkInspector {
  @override
  dynamic getInterceptor() {
    return null; // Handle this gracefully when attaching to your client
  }
}
`

By injecting `NoOpNetworkInspector` during your production setup, you completely decouple your app's core logic from the Alice package, guaranteeing zero overhead.
