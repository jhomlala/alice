# ObjectBox

Store HTTP requests and responses in an ObjectBox database so logs survive app restarts.

## Installation

Add this to your `pubspec.yaml` file:

```yaml
dependencies:
  alice: ^1.11.1
  alice_objectbox: ^1.3.4
  objectbox: ^4.0.3
```

## Usage

```dart
import 'package:flutter/material.dart';
import 'package:alice/alice.dart';
import 'package:alice_objectbox/alice_objectbox.dart';
import 'package:alice_objectbox/alice_objectbox_store.dart';

Future<void> main() async {
  // Required so ObjectBox can access the application directory
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize AliceObjectBoxStore before running the app
  final AliceObjectBoxStore store =
      await AliceObjectBoxStore.create(persistent: false);

  runApp(MyApp(store: store));
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
    required this.store,
  });

  final AliceObjectBoxStore store;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final configuration = AliceConfiguration(
    storage: AliceObjectBox(
      store: widget.store,
      maxCallsCount: 1000,
    ),
  );

  late final Alice _alice = Alice(configuration: configuration);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _alice.getNavigatorKey(),
      home: const Scaffold(),
    );
  }
}
```

## Example

[View the full Alice Objectbox Example on GitHub](https://github.com/jhomlala/alice/tree/master/examples/alice_objectbox)
