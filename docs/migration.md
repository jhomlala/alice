---
sidebar_label: 'Migrations'
---

# Migration Guide

## Migrating from 0.x to 1.x

Version 1.0 extracted HTTP client interceptors from the core package into standalone packages to eliminate heavy transitive dependencies.

### 1. Standalone Adapters
Interceptors are no longer bundled into `package:alice`. Install only the adapters your app needs:

```yaml
dependencies:
  alice: ^1.11.1
  alice_dio: ^1.3.4       # For Dio
  alice_http: ^1.4.4      # For package:http
  alice_chopper: ^1.3.4   # For Chopper
```

### 2. Adapter Registration
Methods like `alice.getDioInterceptor()`, `alice.getChopperInterceptor()`, and `alice.onHttpResponse()` were removed from `Alice`.

Instead, create the adapter, register it with `alice.addAdapter()`, and attach it to your client:

```dart
// Before (0.x):
dio.interceptors.add(alice.getDioInterceptor());

// After (1.x):
final adapter = AliceDioAdapter();
alice.addAdapter(adapter);
dio.interceptors.add(adapter);
```

### 3. AliceConfiguration
Constructor parameters for storage, notifications, and gestures moved to `AliceConfiguration`:

```dart
// Before (0.x):
Alice alice = Alice(
  showNotification: true,
  showInspectorOnShake: false,
);

// After (1.x):
Alice alice = Alice(
  configuration: AliceConfiguration(
    showNotification: true,
    showInspectorOnShake: false,
  ),
);
```

---

## Migrating to 1.8.0

Version 1.8.0 reorganized Alice's internals to enforce a strict public API:

1. **Hidden Internal Implementation:** All internal files moved under `lib/src/`. Replace deep imports with the main package export:
```dart
import 'package:alice/alice.dart';
```
2. **Strict Public API:** Only core classes prefixed with `Alice` (`AliceConfiguration`, `AliceLogger`, `AliceHttpCall`, etc.) are exported.
3. **Service Renames:** Internal `Helper` classes (`ExportHelper`, `ReplayHelper`) were renamed to `Service` (`ExportService`, `ReplayService`).
4. **Utils Renamed:** Global `Utils` was renamed to `AliceUtils`.
