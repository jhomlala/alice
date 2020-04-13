<p align="center">
<img src="https://raw.githubusercontent.com/jhomlala/alice/master/media/logo.png">
</p>

# Alice

[![pub package](https://img.shields.io/pub/v/alice.svg)](https://pub.dartlang.org/packages/alice)
[![pub package](https://img.shields.io/github/license/jhomlala/alice.svg?style=flat)](https://github.com/jhomlala/alice)
[![pub package](https://img.shields.io/badge/platform-flutter-blue.svg)](https://github.com/jhomlala/alice)

Alice is an HTTP Inspector tool for Flutter which helps debugging http requests. It catches and stores http requests and responses, which can be viewed via simple UI. It is inspired from Chuck ( https://github.com/jgilfelt/chuck ).

<p align="center">
<img height="500" src="https://github.com/jhomlala/comptf2/blob/master/media/appsmaller.gif">
</p>
<table>
  <tr>
    <td>
		<img width="250px" src="https://raw.githubusercontent.com/jhomlala/alice/master/media/1.png">
    </td>
    <td>
       <img width="250px" src="https://raw.githubusercontent.com/jhomlala/alice/master/media/2.png">
    </td>
    <td>
       <img width="250px" src="https://raw.githubusercontent.com/jhomlala/alice/master/media/3.png">
    </td>
    <td>
       <img width="250px" src="https://raw.githubusercontent.com/jhomlala/alice/master/media/4.png">
    </td>
     <td>
       <img width="250px" src="https://raw.githubusercontent.com/jhomlala/alice/master/media/5.png">
    </td>
    <td>
       <img width="250px" src="https://raw.githubusercontent.com/jhomlala/alice/master/media/6.png">
    </td>
  </tr>
  <tr>
    <td>
	<img width="250px" src="https://raw.githubusercontent.com/jhomlala/alice/master/media/7.png">
    </td>
    <td>
       <img width="250px" src="https://raw.githubusercontent.com/jhomlala/alice/master/media/8.png">
    </td>
    <td>
       <img width="250px" src="https://raw.githubusercontent.com/jhomlala/alice/master/media/9.png">
    </td>
    <td>
       <img width="250px" src="https://raw.githubusercontent.com/jhomlala/alice/master/media/darktheme_1.png">
    </td>
    <td>
       <img width="250px" src="https://raw.githubusercontent.com/jhomlala/alice/master/media/darktheme_2.png">
    </td>
     <td>
       <img width="250px" src="https://raw.githubusercontent.com/jhomlala/alice/master/media/darktheme_3.png">
    </td>
  </tr>

</table>

**Suported Dart http client plugins:**

- Dio
- HttpClient from dart:io package
- Http from http/http package
- Chopper

**Features:**  
✔️ Detailed logs for each HTTP calls (HTTP Request, HTTP Response)  
✔️ Inspector UI for viewing HTTP calls  
✔️ Save HTTP calls to file  
✔️ Statistics  
✔️ Notification on HTTP call  
✔️ Support for top used HTTP clients in Dart  
✔️ Error handling  
✔️ Shake to open inspector

## Install

1. Add this to your **pubspec.yaml** file:

```yaml
dependencies:
  alice: ^0.0.25
```

2. Install it

```bash
$ flutter packages get
```

3. Import it

```dart
import 'package:alice/alice.dart';
```

## Usage
### Alice configuration
Create Alice instance:

```dart
Alice alice = Alice(showNotification: true);
```

Alice default behaviour is to show notification with http requests. You can disable it in `Alice` constructor.

Add navigator key to your application:

```dart
MaterialApp( navigatorKey: alice.getNavigatorKey(), home: ...)
```

You need to add this navigator key in order to show inspector UI.
You can use also your navigator key in Alice:

```dart
Alice alice = Alice(showNotification: true, navigatorKey: yourNavigatorKeyHere);
```

If you need to pass navigatorKey lazily, you can use:
```dart
alice.setNavigatorKey(yourNavigatorKeyHere);
```


You can set `showInspectorOnShake` in Alice constructor to open inspector by shaking your device (default disabled):

```dart
Alice alice = Alice(showNotification: true, showInspectorOnShake: true, navigatorKey: yourNavigatorKeyHere);
```

If you want to use dark mode just add `darkTheme` flag:

```dart
Alice alice = Alice(..., darkTheme: true);
```

### HTTP Client configuration
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

If you're using Chopper. you need to add interceptor:

```dart
chopper = ChopperClient(
    interceptors: alice.getChopperInterceptor(),
);
```

To show inspector manually:

```dart
alice.showInspector();
```

## Saving calls

Alice supports saving logs to your mobile device storage. In order to make save feature works, you need to add in your Android application manifest:

```xml
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

## Extensions
You can use extensions to shorten your http and http client code. This is optional, but may improve your codebase.
Example:
1. Import:
```dart
import 'package:alice/core/alice_http_client_extensions.dart';
import 'package:alice/core/alice_http_extensions.dart';
```

2. Use extensions:
```dart
http
    .post('https://jsonplaceholder.typicode.com/posts', body: body)
    .interceptWithAlice(alice, body: body);
```

```dart
httpClient
    .postUrl(Uri.parse("https://jsonplaceholder.typicode.com/posts"))
    .interceptWithAlice(alice, body: body, headers: Map());
```


## Example

See complete example here: https://github.com/jhomlala/alice/blob/master/example/lib/main.dart
