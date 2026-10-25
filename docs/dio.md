# Dio

To use Alice with Dio, add the adapter to your project.

## Installation

Add this to your `pubspec.yaml` file:

```yaml
dependencies:
  alice: ^2.0.0
  alice_dio: ^1.4.0
```

## Usage

```dart
import 'package:alice/alice.dart';
import 'package:alice_dio/alice_dio_adapter.dart';
import 'package:dio/dio.dart';

// Create Alice instance
Alice alice = Alice();

// Create Alice Dio Adapter
AliceDioAdapter aliceDioAdapter = AliceDioAdapter();

// Add adapter to Alice
alice.addAdapter(aliceDioAdapter);

// Create Dio instance and add interceptor
Dio dio = Dio()..interceptors.add(aliceDioAdapter);
```

## Example

[View the full Alice Dio Example on GitHub](https://github.com/jhomlala/alice/tree/master/examples/alice_dio)
