# Alice
[![pub package](https://img.shields.io/pub/v/alice.svg)](https://pub.dartlang.org/packages/alice)
[![pub package](https://img.shields.io/github/license/jhomlala/alice.svg?style=flat)](https://github.com/jhomlala/alice)
[![pub package](https://img.shields.io/badge/platform-flutter-blue.svg)](https://github.com/jhomlala/alice)

Alice is an HTTP Inspector tool for FLutter which helps debugging http requests. It catches and stores http requests and responses, which can be viewed via simple UI. It is inspired from Chuck (https://github.com/jgilfelt/chuck).
<p align="center">
<img height="500" src="https://github.com/jhomlala/alice/blob/master/media/alice.gif">
</p>

Alice supports http clients:
* Dio
* HttpClient from dart:io package
* Http from http/http package 

## Install
1. Add this to your package's pubspec.yaml file:
```dart
dependencies:
  alice: ^0.0.2
```
2. Install it
```bash
$ flutter packages get
```

3. Import it
```dash
import 'package:alice/alice.dart';
```

## How to use
Create Alice instance:
```dart
  Alice alice = Alice(showNotification: true);
```

Add navigator key to your application:
```dart
  MaterialApp( navigatorKey: alice.getNavigatorKey(), home: ...)
```

If you're using Dio, you just need to add interceptor.
```dart
  Dio dio = Dio();
  dio.interceptors.add(alice.getDioInterceptor());
```

If you're using HttpClient from dart:io package:
```dart
    httpClient
        .getUrl(Uri.parse("https://jsonplaceholder.typicode.com/posts"))
        .then((request) async {
      alice.onHttpClientRequest(request);
      var httpResponse = await request.close();
      var responseBody = await httpResponse.transform(utf8.decoder).join();
      alice.onHttpClientResponse(httpResponse, request, body: responseBody);
    });
```

If you're using http from http/http package:
```dart
    http.get('https://jsonplaceholder.typicode.com/posts').then((response) {
      alice.onHttpResponse(response);
    });
```
