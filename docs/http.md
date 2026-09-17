# Http

To use Alice with the `http` package, add the adapter to your project.

## Installation

Add this to your **pubspec.yaml** file:

```yaml
dependencies:
  alice_http: ^1.3.3
```

## Usage

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
