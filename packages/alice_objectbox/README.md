# Alice ObjectBox

[![pub package](https://img.shields.io/pub/v/alice_objectbox.svg)](https://pub.dartlang.org/packages/alice_objectbox)

Alice + ObjectBox integration. It contains a plugin for Alice which stores HTTP requests and responses in an ObjectBox NoSQL database.

## Setup

```dart
import 'package:alice/alice.dart';
import 'package:alice_objectbox/alice_objectbox.dart';
import 'package:alice_objectbox/alice_objectbox_store.dart';

// Initialize AliceObjectBoxStore before running the app
AliceObjectBoxStore store = await AliceObjectBoxStore.create(persistent: false);

AliceConfiguration configuration = AliceConfiguration(
  storage: AliceObjectBox(store: store, maxCallsCount: 1000),
);

Alice alice = Alice(configuration: configuration);
```

## Documentation

For full documentation, see [Alice documentation](https://jhomlala.github.io/alice/) or the [Main Repository](https://github.com/jhomlala/alice).
