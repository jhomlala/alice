# ObjectBox

Setting up ObjectBox with Alice is simple, however, there are a few crucial steps which need to be followed.

## Installation

Add this to your **pubspec.yaml** file:

```yaml
dependencies:
  objectbox: any
  alice_objectbox: ^1.2.3
```

## Usage

```dart
Future<void> main() async {
  /// This is required so ObjectBox can get the application directory
  /// to store the database in.
  WidgetsFlutterBinding.ensureInitialized();

  /// Initialize [AliceObjectBoxStore] before running the app.
  final AliceObjectBoxStore store =
      await AliceObjectBoxStore.create(persistent: false);

  /// Pass [AliceObjectBoxStore] to the app
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
  late final Alice _alice = Alice(
    showNotification: true,
    showInspectorOnShake: true,
    maxCallsCount: 1000,
    /// Pass [AliceObjectBox] to the [Alice] constructor
    aliceStorage: AliceObjectBox(
      store: widget.store,
      maxCallsCount: 1000,
    ),
  );

  // your custom stuff...
}
```
