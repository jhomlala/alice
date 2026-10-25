# Retrofit

Alice supports [Retrofit](https://pub.dev/packages/retrofit) out of the box because Retrofit runs on top of [Dio](https://pub.dev/packages/dio).

Add the `alice_dio` adapter to the `Dio` instance passed to your Retrofit `RestClient`.

## Installation

Add dependencies to your `pubspec.yaml`:

```yaml
dependencies:
  alice: ^2.0.0
  alice_dio: ^1.4.0
  retrofit: ^4.4.2
```

## Setup

```dart
import 'package:alice/alice.dart';
import 'package:alice_dio/alice_dio_adapter.dart';
import 'package:dio/dio.dart';

// 1. Create Alice and adapter
final aliceDioAdapter = AliceDioAdapter();
final alice = Alice()..addAdapter(aliceDioAdapter);

// 2. Add adapter to Dio
final dio = Dio()..interceptors.add(aliceDioAdapter);

// 3. Pass Dio to your Retrofit RestClient
final client = RestClient(dio);
```

All network requests made by `RestClient` will appear in the Alice inspector.

## Example

[View the full Alice Retrofit Example on GitHub](https://github.com/jhomlala/alice/tree/master/examples/alice_retrofit)
