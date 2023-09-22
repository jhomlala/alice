import 'dart:convert';
import 'dart:io';

import 'package:alice/alice.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Color _primaryColor = Color(0xffff5e57);
  Color _accentColor = Color(0xffff3f34);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: _primaryColor,
        colorScheme: ColorScheme.light(secondary: _accentColor),
      ),
      // navigatorKey: _alice.getNavigatorKey(),
      debugShowCheckedModeBanner: false,
      home: _ExampleBody(),
    );
  }
}

class _ExampleBody extends StatefulWidget {
  const _ExampleBody({super.key});

  @override
  State<_ExampleBody> createState() => _ExampleBodyState();
}

class _ExampleBodyState extends State<_ExampleBody> {
  final _buttonColor = const Color(0xff008000);

  late Alice _alice;
  late HttpClient _httpClient;

  @override
  void initState() {
    _alice = Alice(
      darkTheme: false,
      maxCallsCount: 1000,
    );
    _httpClient = HttpClient();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ButtonStyle _buttonStyle = ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(_buttonColor));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alice HTTP Inspector - Example'),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            const SizedBox(height: 8),
            _getTextWidget(
                "Welcome to example of Alice Http Inspector. Click buttons below to generate sample data."),
            ElevatedButton(
              child: Text("Run http/http HTTP Requests"),
              onPressed: _runHttpHttpRequests,
              style: _buttonStyle,
            ),
            ElevatedButton(
              child: Text("Run HttpClient Requests"),
              onPressed: _runHttpHttpClientRequests,
              style: _buttonStyle,
            ),
            ElevatedButton(
              child: Text("Log example data"),
              onPressed: _logExampleData,
              style: _buttonStyle,
            ),
            const SizedBox(height: 24),
            _getTextWidget(
                "After clicking on buttons above, you should receive notification."
                " Click on it to show inspector. You can also shake your device or click button below."),
            ElevatedButton(
              child: Text("Run HTTP Inspector"),
              onPressed: _runHttpInspector,
              style: _buttonStyle,
            )
          ],
        ),
      ),
    );
  }

  Widget _getTextWidget(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 14),
      textAlign: TextAlign.center,
    );
  }

  void _logExampleData() {
    final List<AliceLog> logs = [];
    logs.add(
      AliceLog(
        level: DiagnosticLevel.info,
        timestamp: DateTime.now(),
        message: 'Info log',
      ),
    );
    logs.add(
      AliceLog(
        level: DiagnosticLevel.debug,
        timestamp: DateTime.now(),
        message: 'Debug log',
      ),
    );
    logs.add(
      AliceLog(
        level: DiagnosticLevel.warning,
        timestamp: DateTime.now(),
        message: 'Warning log',
      ),
    );
    final notNumber = 'afs';
    try {
      int.parse(notNumber);
    } catch (e, stacktrace) {
      logs.add(
        AliceLog(
          level: DiagnosticLevel.error,
          timestamp: DateTime.now(),
          message: 'Error log',
          error: e,
          stackTrace: stacktrace,
        ),
      );
    }
    _alice.addLogs(logs);
  }

  void _runHttpHttpRequests() async {
    Map<String, String> body = <String, String>{
      "title": "foo",
      "body": "bar",
      "userId": "1"
    };
    http
        .post(Uri.tryParse('https://jsonplaceholder.typicode.com/posts')!,
            body: body)
        .interceptWithAlice(_alice, body: body);

    http
        .get(Uri.tryParse('https://jsonplaceholder.typicode.com/posts')!)
        .interceptWithAlice(_alice);

    http
        .put(Uri.tryParse('https://jsonplaceholder.typicode.com/posts/1')!,
            body: body)
        .interceptWithAlice(_alice, body: body);

    http
        .patch(Uri.tryParse('https://jsonplaceholder.typicode.com/posts/1')!,
            body: body)
        .interceptWithAlice(_alice, body: body);

    http
        .delete(Uri.tryParse('https://jsonplaceholder.typicode.com/posts/1')!)
        .interceptWithAlice(_alice, body: body);

    http
        .get(Uri.tryParse('https://jsonplaceholder.typicode.com/test/test')!)
        .interceptWithAlice(_alice);

    http
        .post(Uri.tryParse('https://jsonplaceholder.typicode.com/posts')!,
            body: body)
        .then((response) {
      _alice.onHttpResponse(response, body: body);
    });

    http
        .get(Uri.tryParse('https://jsonplaceholder.typicode.com/posts')!)
        .then((response) {
      _alice.onHttpResponse(response);
    });

    http
        .put(Uri.tryParse('https://jsonplaceholder.typicode.com/posts/1')!,
            body: body)
        .then((response) {
      _alice.onHttpResponse(response, body: body);
    });

    http
        .patch(Uri.tryParse('https://jsonplaceholder.typicode.com/posts/1')!,
            body: body)
        .then((response) {
      _alice.onHttpResponse(response, body: body);
    });

    http
        .delete(Uri.tryParse('https://jsonplaceholder.typicode.com/posts/1')!)
        .then((response) {
      _alice.onHttpResponse(response);
    });

    http
        .get(Uri.tryParse('https://jsonplaceholder.typicode.com/test/test')!)
        .then((response) {
      _alice.onHttpResponse(response);
    });

    http
        .post(
            Uri.tryParse(
                'https://jsonplaceholder.typicode.com/posts?key1=value1')!,
            body: body)
        .interceptWithAlice(_alice, body: body);

    http
        .post(
            Uri.tryParse(
                'https://jsonplaceholder.typicode.com/posts?key1=value1&key2=value2&key3=value3')!,
            body: body)
        .interceptWithAlice(_alice, body: body);

    http
        .get(Uri.tryParse(
            'https://jsonplaceholder.typicode.com/test/test?key1=value1&key2=value2&key3=value3')!)
        .then((response) {
      _alice.onHttpResponse(response);
    });
  }

  void _runHttpHttpClientRequests() {
    Map<String, dynamic> body = <String, dynamic>{
      "title": "foo",
      "body": "bar",
      "userId": "1"
    };
    _httpClient
        .getUrl(Uri.parse("https://jsonplaceholder.typicode.com/posts"))
        .interceptWithAlice(_alice);

    _httpClient
        .postUrl(Uri.parse("https://jsonplaceholder.typicode.com/posts"))
        .interceptWithAlice(_alice, body: body, headers: <String, dynamic>{});

    _httpClient
        .putUrl(Uri.parse("https://jsonplaceholder.typicode.com/posts/1"))
        .interceptWithAlice(_alice, body: body);

    _httpClient
        .getUrl(Uri.parse("https://jsonplaceholder.typicode.com/test/test/"))
        .interceptWithAlice(_alice);

    _httpClient
        .postUrl(Uri.parse("https://jsonplaceholder.typicode.com/posts"))
        .then((request) async {
      _alice.onHttpClientRequest(request, body: body);
      request.write(body);
      var httpResponse = await request.close();
      var responseBody = await utf8.decoder.bind(httpResponse).join();
      _alice.onHttpClientResponse(httpResponse, request, body: responseBody);
    });

    _httpClient
        .putUrl(Uri.parse("https://jsonplaceholder.typicode.com/posts/1"))
        .then((request) async {
      _alice.onHttpClientRequest(request, body: body);
      request.write(body);
      var httpResponse = await request.close();
      var responseBody = await utf8.decoder.bind(httpResponse).join();
      _alice.onHttpClientResponse(httpResponse, request, body: responseBody);
    });

    _httpClient
        .patchUrl(Uri.parse("https://jsonplaceholder.typicode.com/posts/1"))
        .then((request) async {
      _alice.onHttpClientRequest(request, body: body);
      request.write(body);
      var httpResponse = await request.close();
      var responseBody = await utf8.decoder.bind(httpResponse).join();
      _alice.onHttpClientResponse(httpResponse, request, body: responseBody);
    });

    _httpClient
        .deleteUrl(Uri.parse("https://jsonplaceholder.typicode.com/posts/1"))
        .then((request) async {
      _alice.onHttpClientRequest(request);
      var httpResponse = await request.close();
      var responseBody = await utf8.decoder.bind(httpResponse).join();
      _alice.onHttpClientResponse(httpResponse, request, body: responseBody);
    });

    _httpClient
        .getUrl(Uri.parse("https://jsonplaceholder.typicode.com/test/test/"))
        .then((request) async {
      _alice.onHttpClientRequest(request);
      var httpResponse = await request.close();
      var responseBody = await utf8.decoder.bind(httpResponse).join();
      _alice.onHttpClientResponse(httpResponse, request, body: responseBody);
    });
  }

  void _runHttpInspector() {
    _alice.showInspector(context);
  }
}
