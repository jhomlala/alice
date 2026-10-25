# Http

To use Alice with the `http` package, add the adapter to your project.

## Installation

Add this to your `pubspec.yaml` file:

```yaml
dependencies:
  alice: ^1.11.1
  alice_http: ^1.4.4
```

## Usage

```dart
import 'package:alice/alice.dart';
import 'package:alice_http/alice_http_adapter.dart';
import 'package:alice_http/alice_http_extensions.dart';
import 'package:http/http.dart' as http;

// Create Alice instance
Alice alice = Alice();

// Create Alice Http Adapter
AliceHttpAdapter aliceHttpAdapter = AliceHttpAdapter();

// Add adapter to Alice
alice.addAdapter(aliceHttpAdapter);
```

Intercept calls using the extension:
```dart
http
    .post(Uri.parse('https://api.com/posts'), body: body)
    .interceptWithAlice(aliceHttpAdapter, body: body);
```

Or handle manually with the adapter:
```dart
http
    .put(Uri.parse('https://api.com/posts/1'), body: body)
    .then((response) {
      aliceHttpAdapter.onResponse(response, body: body);
    });
```

## Example

[View the full Alice Http Example on GitHub](https://github.com/jhomlala/alice/tree/master/examples/alice_http)
