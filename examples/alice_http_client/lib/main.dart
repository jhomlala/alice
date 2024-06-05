import 'dart:convert';
import 'dart:io';

import 'package:alice/alice.dart';
import 'package:alice_http_client/alice_http_client_adapter.dart';
import 'package:alice_http_client/alice_http_client_extensions.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Alice _alice;
  late HttpClient _httpClient;
  late AliceHttpClientAdapter _httpClientAdapter;

  @override
  void initState() {
    _alice = Alice(
      showNotification: true,
      showInspectorOnShake: true,
      maxCallsCount: 1000,
    );
    _httpClient = HttpClient();
    _httpClientAdapter = AliceHttpClientAdapter();
    _alice.addAdapter(_httpClientAdapter);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _alice.getNavigatorKey(),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Alice + HTTP Client - Example'),
        ),
        body: Container(
          padding: EdgeInsets.all(16),
          child: ListView(
            children: [
              const SizedBox(height: 8),
              Text(
                  'Welcome to example of Alice Http Inspector. Click buttons below to generate sample data.'),
              ElevatedButton(
                child: Text(
                  'Run HttpClient Requests',
                ),
                onPressed: _runHttpHttpClientRequests,
              ),
              const SizedBox(height: 8),
              Text(
                  'After clicking on buttons above, you should receive notification.'
                  ' Click on it to show inspector. You can also shake your device or click button below.'),
              ElevatedButton(
                child: Text(
                  'Run HTTP Inspector',
                ),
                onPressed: _runHttpInspector,
              )
            ],
          ),
        ),
      ),
    );
  }

  void _runHttpHttpClientRequests() {
    Map<String, dynamic> body = <String, dynamic>{
      'title': 'foo',
      'body': 'bar',
      'userId': '1'
    };
    _httpClient
        .getUrl(Uri.parse('https://jsonplaceholder.typicode.com/posts'))
        .interceptWithAlice(_httpClientAdapter);

    _httpClient
        .postUrl(Uri.parse('https://jsonplaceholder.typicode.com/posts'))
        .interceptWithAlice(_httpClientAdapter,
            body: body, headers: <String, dynamic>{});

    _httpClient
        .putUrl(Uri.parse('https://jsonplaceholder.typicode.com/posts/1'))
        .interceptWithAlice(_httpClientAdapter, body: body);

    _httpClient
        .getUrl(Uri.parse('https://jsonplaceholder.typicode.com/test/test/'))
        .interceptWithAlice(_httpClientAdapter);

    _httpClient
        .postUrl(Uri.parse('https://jsonplaceholder.typicode.com/posts'))
        .then((request) async {
      _httpClientAdapter.onRequest(request, body: body);
      request.write(body);
      var httpResponse = await request.close();
      var responseBody = await utf8.decoder.bind(httpResponse).join();
      _httpClientAdapter.onResponse(httpResponse, request, body: responseBody);
    });

    _httpClient
        .putUrl(Uri.parse('https://jsonplaceholder.typicode.com/posts/1'))
        .then((request) async {
      _httpClientAdapter.onRequest(request, body: body);
      request.write(body);
      var httpResponse = await request.close();
      var responseBody = await utf8.decoder.bind(httpResponse).join();
      _httpClientAdapter.onResponse(httpResponse, request, body: responseBody);
    });

    _httpClient
        .patchUrl(Uri.parse('https://jsonplaceholder.typicode.com/posts/1'))
        .then((request) async {
      _httpClientAdapter.onRequest(request, body: body);
      request.write(body);
      var httpResponse = await request.close();
      var responseBody = await utf8.decoder.bind(httpResponse).join();
      _httpClientAdapter.onResponse(httpResponse, request, body: responseBody);
    });

    _httpClient
        .deleteUrl(Uri.parse('https://jsonplaceholder.typicode.com/posts/1'))
        .then((request) async {
      _httpClientAdapter.onRequest(request);
      var httpResponse = await request.close();
      var responseBody = await utf8.decoder.bind(httpResponse).join();
      _httpClientAdapter.onResponse(httpResponse, request, body: responseBody);
    });

    _httpClient
        .getUrl(Uri.parse('https://jsonplaceholder.typicode.com/test/test/'))
        .then((request) async {
      _httpClientAdapter.onRequest(request);
      var httpResponse = await request.close();
      var responseBody = await utf8.decoder.bind(httpResponse).join();
      _httpClientAdapter.onResponse(httpResponse, request, body: responseBody);
    });
  }

  void _runHttpInspector() {
    _alice.showInspector();
  }
}

