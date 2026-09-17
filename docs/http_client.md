# Http Client

To use Alice with `HttpClient` from `dart:io`, add the adapter to your project.

## Installation

Add this to your **pubspec.yaml** file:

```yaml
dependencies:
  alice_http_client: ^1.3.0
```

## Usage

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

## Example

[View the full Alice Http Client Example on GitHub](https://github.com/jhomlala/alice/tree/master/examples/alice_http_client)
