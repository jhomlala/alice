# Alice HTTP Client

[![pub package](https://img.shields.io/pub/v/alice_http_client.svg)](https://pub.dartlang.org/packages/alice_http_client)

Alice + HTTP Client integration. It contains a plugin for Alice which allows you to use the dart:io HttpClient.

## Setup

```dart
import 'dart:io';
import 'package:alice/alice.dart';
import 'package:alice_http_client/alice_http_client_adapter.dart';
import 'package:alice_http_client/alice_http_client_extensions.dart';

HttpClient httpClient = HttpClient();
AliceHttpClientAdapter httpClientAdapter = AliceHttpClientAdapter();
Alice alice = Alice()..addAdapter(httpClientAdapter);

httpClient
    .getUrl(Uri.https('jsonplaceholder.typicode.com', '/posts'))
    .interceptWithAlice(httpClientAdapter);
```

## Documentation

For full documentation, see [Alice documentation](https://jhomlala.github.io/alice/) or the [Main Repository](https://github.com/jhomlala/alice).