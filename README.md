# Alice
[![pub package](https://img.shields.io/pub/v/alice.svg)](https://pub.dartlang.org/packages/alice)
[![pub package](https://img.shields.io/github/license/jhomlala/alice.svg?style=flat)](https://github.com/jhomlala/alice)
[![pub package](https://img.shields.io/badge/platform-flutter-blue.svg)](https://github.com/jhomlala/alice)

Alice is an HTTP Inspector tool for Flutter which helps debugging http requests. It catches and stores http requests and responses, which can be viewed via simple UI. It is inspired from Chuck (https://github.com/jgilfelt/chuck).
<p align="center">
<img height="500" src="https://media.giphy.com/media/2aSpSGWDxmyEwKnvmM/giphy.gif">
</p>
<table>
  <tr>
    <td>
  <img width="250px" src="https://github.com/jhomlala/alice/blob/master/media/1.png">
    </td>
    <td>
       <img width="250px" src="https://github.com/jhomlala/alice/blob/master/media/2.png">
    </td>
    <td>
       <img width="250px" src="https://github.com/jhomlala/alice/blob/master/media/3.png">
    </td>
    <td>
       <img width="250px" src="https://github.com/jhomlala/alice/blob/master/media/4.png">
    </td>
     <td>
       <img width="250px" src="https://github.com/jhomlala/alice/blob/master/media/5.png">
    </td>
    <td>
       <img width="250px" src="https://github.com/jhomlala/alice/blob/master/media/6.png">
    </td>
  </tr>
  <tr>
</table>

Alice supports http clients:
* Dio
* HttpClient from dart:io package
* Http from http/http package 

## Install
1. Add this to your package's pubspec.yaml file:
```dart
dependencies:
  alice: ^0.0.5
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
Alice default behaviour is to show notification with http requests. You can disable it `Alice` constructor.

Add navigator key to your application:
```dart
  MaterialApp( navigatorKey: alice.getNavigatorKey(), home: ...)
```
You need to add this navigator key in order to show inspector UI.
You can use also your navigator key in Alice:
```dart
    Alice alice = Alice(showNotification: true, navigatorKey: yourNavigatorKeyHere);
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

To show inspector manually:
```dart
  alice.showInspector();
```

See complete example here: https://github.com/jhomlala/alice/blob/master/example/lib/main.dart

