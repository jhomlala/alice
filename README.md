# Alice

A HTTP inspector plugin for Flutter.
<p align="center">
<img src="https://github.com/jhomlala/alice/blob/master/media/alice.gif">
</p>

## Install



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

If you're using HttpClient
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

If you're using http:
```dart
  http.get('https://jsonplaceholder.typicode.com/posts').then((response) {
      alice.onHttpResponse(response);
    });
```
