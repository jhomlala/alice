# Alice Chopper

[![pub package](https://img.shields.io/pub/v/alice_chopper.svg)](https://pub.dartlang.org/packages/alice_chopper)

Alice + Chopper integration. It contains a plugin for Alice which allows you to use the Chopper package.

## Setup

```dart
import 'package:alice/alice.dart';
import 'package:alice_chopper/alice_chopper_adapter.dart';
import 'package:chopper/chopper.dart';

AliceChopperAdapter aliceChopperAdapter = AliceChopperAdapter();
Alice alice = Alice()..addAdapter(aliceChopperAdapter);

ChopperClient chopper = ChopperClient(
  interceptors: [
    aliceChopperAdapter,
  ],
);
```

## Documentation

For full documentation, see [Alice documentation](https://jhomlala.github.io/alice/) or the [Main Repository](https://github.com/jhomlala/alice).