# Dio

To use Alice with Dio, add the adapter to your project.

## Installation

Add this to your **pubspec.yaml** file:

```yaml
dependencies:
  alice_dio: ^1.2.0
```

## Usage

```dart
/// Create Alice instance
Alice alice = Alice();

/// Create Alice Dio Adapter
AliceDioAdapter aliceDioAdapter = AliceDioAdapter();

/// Add adapter to Alice
alice.addAdapter(aliceDioAdapter);

/// Create Dio instance
Dio dio = Dio();

/// Add interceptor to Dio
dio.interceptors.add(aliceDioAdapter);
```
