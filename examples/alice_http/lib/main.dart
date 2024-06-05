
import 'package:alice/alice.dart';
import 'package:alice_http/alice_http_adapter.dart';
import 'package:alice_http/alice_http_extensions.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Alice _alice;
  late AliceHttpAdapter _aliceHttpAdapter;

  @override
  void initState() {
    _alice = Alice(
      showNotification: true,
      showInspectorOnShake: true,
      maxCallsCount: 1000,
    );
    _aliceHttpAdapter = AliceHttpAdapter();
    _alice.addAdapter(_aliceHttpAdapter);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      navigatorKey: _alice.getNavigatorKey(),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Alice + HTTP package - Example'),
        ),
        body: Container(
          padding: EdgeInsets.all(16),
          child: ListView(
            children: [
              const SizedBox(height: 8),
              _getTextWidget(
                  'Welcome to example of Alice Http Inspector. Click buttons below to generate sample data.'),

              ElevatedButton(
                child: Text(
                  'Run http/http HTTP Requests',
                ),
                onPressed: _runHttpHttpRequests,
              ),

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

  Widget _getTextWidget(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 14),
      textAlign: TextAlign.center,
    );
  }


  void _runHttpHttpRequests() async {
    Map<String, String> body = <String, String>{
      'title': 'foo',
      'body': 'bar',
      'userId': '1'
    };
    http
        .post(Uri.tryParse('https://jsonplaceholder.typicode.com/posts')!,
            body: body)
        .interceptWithAlice(_aliceHttpAdapter, body: body);

    http
        .get(Uri.tryParse('https://jsonplaceholder.typicode.com/posts')!)
        .interceptWithAlice(_aliceHttpAdapter);

    http
        .put(Uri.tryParse('https://jsonplaceholder.typicode.com/posts/1')!,
            body: body)
        .interceptWithAlice(_aliceHttpAdapter, body: body);

    http
        .patch(Uri.tryParse('https://jsonplaceholder.typicode.com/posts/1')!,
            body: body)
        .interceptWithAlice(_aliceHttpAdapter, body: body);

    http
        .delete(Uri.tryParse('https://jsonplaceholder.typicode.com/posts/1')!)
        .interceptWithAlice(_aliceHttpAdapter, body: body);

    http
        .get(Uri.tryParse('https://jsonplaceholder.typicode.com/test/test')!)
        .interceptWithAlice(_aliceHttpAdapter);

    http
        .post(Uri.tryParse('https://jsonplaceholder.typicode.com/posts')!,
            body: body)
        .then((response) {
      _aliceHttpAdapter.onResponse(response, body: body);
    });

    http
        .get(Uri.tryParse('https://jsonplaceholder.typicode.com/posts')!)
        .then((response) {
      _aliceHttpAdapter.onResponse(response);
    });

    http
        .put(Uri.tryParse('https://jsonplaceholder.typicode.com/posts/1')!,
            body: body)
        .then((response) {
      _aliceHttpAdapter.onResponse(response, body: body);
    });

    http
        .patch(Uri.tryParse('https://jsonplaceholder.typicode.com/posts/1')!,
            body: body)
        .then((response) {
      _aliceHttpAdapter.onResponse(response, body: body);
    });

    http
        .delete(Uri.tryParse('https://jsonplaceholder.typicode.com/posts/1')!)
        .then((response) {
      _aliceHttpAdapter.onResponse(response);
    });

    http
        .get(Uri.tryParse('https://jsonplaceholder.typicode.com/test/test')!)
        .then((response) {
      _aliceHttpAdapter.onResponse(response);
    });

    http
        .post(
            Uri.tryParse(
                'https://jsonplaceholder.typicode.com/posts?key1=value1')!,
            body: body)
        .interceptWithAlice(_aliceHttpAdapter, body: body);

    http
        .post(
            Uri.tryParse(
                'https://jsonplaceholder.typicode.com/posts?key1=value1&key2=value2&key3=value3')!,
            body: body)
        .interceptWithAlice(_aliceHttpAdapter, body: body);

    http
        .get(Uri.tryParse(
            'https://jsonplaceholder.typicode.com/test/test?key1=value1&key2=value2&key3=value3')!)
        .then((response) {
      _aliceHttpAdapter.onResponse(response);
    });
  }

  void _runHttpInspector() {
    _alice.showInspector();
  }
}
