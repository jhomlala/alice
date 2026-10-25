# Http Client

To use Alice with `HttpClient` from `dart:io`, add the adapter to your project.

## Installation

Add this to your `pubspec.yaml` file:

```yaml
dependencies:
  alice: ^1.11.1
  alice_http_client: ^1.3.4
```

## Usage

```dart
import 'dart:convert';
import 'dart:io';
import 'package:alice/alice.dart';
import 'package:alice_http_client/alice_http_client_adapter.dart';
import 'package:alice_http_client/alice_http_client_extensions.dart';

// Create Alice instance
Alice alice = Alice();

// Create Alice Http Client Adapter
AliceHttpClientAdapter aliceHttpClientAdapter = AliceHttpClientAdapter();

// Add adapter to Alice
alice.addAdapter(aliceHttpClientAdapter);

// Http Client instance
HttpClient httpClient = HttpClient();
```

Intercept calls using the extension:
```dart
httpClient
    .getUrl(Uri.parse('https://api.com/posts'))
    .interceptWithAlice(aliceHttpClientAdapter);
```

Or handle manually with the adapter:
```dart
httpClient
    .getUrl(Uri.parse('https://api.com/posts'))
    .then((request) async {
      aliceHttpClientAdapter.onRequest(request);
      final httpResponse = await request.close();
      final responseBody = await utf8.decoder.bind(httpResponse).join();
      aliceHttpClientAdapter.onResponse(httpResponse, request, body: responseBody);
    });
```

## Example

[View the full Alice Http Client Example on GitHub](https://github.com/jhomlala/alice/tree/master/examples/alice_http_client)
