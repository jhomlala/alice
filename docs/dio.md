# Dio

To use Alice with Dio, add the adapter to your project.

## Installation

Add this to your **pubspec.yaml** file:

```yaml
dependencies:
  alice_dio: ^1.3.0
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

## Example

[View the full Alice Dio Example on GitHub](https://github.com/jhomlala/alice/tree/master/examples/alice_dio)
