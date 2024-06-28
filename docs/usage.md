# How to use

## Dio

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

## Chopper
```dart
/// Create Alice instance
Alice alice = Alice();

/// Create Alice Chopper Adapter
AliceChopperAdapter aliceChopperAdapter = AliceChopperAdapter();

///Add adapter to Alice
alice.addAdapter(aliceChopperAdapter);

/// Create chopper client
ChopperClient chopperClient = ChopperClient(
    interceptors: [_aliceChopperAdapter],
);

```


## HTTP
```dart
/// Create Alice instance
Alice alice = Alice();

/// Create Alice Http Adapter
AliceHttpAdapter aliceHttpAdapter = AliceHttpAdapter();

///Add adapter to Alice
alice.addAdapter(aliceHttpAdapter);
```

Use extension to intercept HTTP call:
```dart
http
    .post(Uri.tryParse('https://api.com')!, body: body)
    .interceptWithAlice(aliceHttpAdapter, body: body);
```

Use adapter to handle HTTP call:
```dart
http
    .put(Uri.tryParse('https://api.com')!, body: body)
    .then((response) {
      aliceHttpAdapter.onResponse(response, body: body);
    });
```

## HTTP Client
```dart
/// Create Alice instance
Alice alice = Alice();

/// Create Alice Http Adapter
AliceHttpClientAdapter aliceHttpClientAdapter = AliceHttpClientAdapter();

///Add adapter to Alice
alice.addAdapter(aliceHttpClientAdapter);

/// Http Client instance
HttpClient httpClient = HttpClient();
```

Use extension to intercept HTTP call:
```dart
httpClient
    .getUrl(Uri.parse('https://api.com'))
    .interceptWithAlice(aliceHttpClientAdapter);
```

Use adapter to handle HTTP call:
```dart
httpClient
    .getUrl(Uri.parse('https://api.com'))
    .then((request) async {
      aliceHttpClientAdapter.onRequest(request);
      var httpResponse = await request.close();
      var responseBody = await utf8.decoder.bind(httpResponse).join();
      aliceHttpClientAdapter.onResponse(httpResponse, request, body: responseBody);
});
```

## ObjectBox

Setting up ObjectBox with Alice is simple, however, there are a few crucial steps which need to be followed.

1. Add it to your dependencies

```yaml
dependencies:
  alice_objectbox: ^1.0.0
```

2. Follow the ObjectBox [example](https://github.com/objectbox/objectbox-dart/blob/main/objectbox/example/flutter/objectbox_demo/lib/main.dart)

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
