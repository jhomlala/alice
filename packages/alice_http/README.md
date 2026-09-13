# Alice HTTP

[![pub package](https://img.shields.io/pub/v/alice_http.svg)](https://pub.dartlang.org/packages/alice_http)

Alice + HTTP integration. It contains a plugin for Alice which allows you to use the http package.

## Setup

```dart
import 'package:alice/alice.dart';
import 'package:alice_http/alice_http_adapter.dart';
import 'package:alice_http/alice_http_extensions.dart';
import 'package:http/http.dart' as http;

AliceHttpAdapter aliceHttpAdapter = AliceHttpAdapter();
Alice alice = Alice()..addAdapter(aliceHttpAdapter);

http.get(Uri.https('jsonplaceholder.typicode.com', '/posts'))
    .interceptWithAlice(aliceHttpAdapter);
```

## Documentation

For full documentation, see [Alice documentation](https://jhomlala.github.io/alice/) or the [Main Repository](https://github.com/jhomlala/alice).