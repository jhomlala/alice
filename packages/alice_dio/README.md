# Alice Dio

[![pub package](https://img.shields.io/pub/v/alice_dio.svg)](https://pub.dartlang.org/packages/alice_dio)

Alice + Dio integration. It contains a plugin for Alice which allows you to use the Dio package.

## Setup

```dart
import 'package:alice/alice.dart';
import 'package:alice_dio/alice_dio_adapter.dart';
import 'package:dio/dio.dart';

AliceDioAdapter aliceDioAdapter = AliceDioAdapter();
Alice alice = Alice()..addAdapter(aliceDioAdapter);
Dio dio = Dio()..interceptors.add(aliceDioAdapter);
```

## Documentation

For full documentation, see [Alice documentation](https://jhomlala.github.io/alice/) or the [Main Repository](https://github.com/jhomlala/alice).