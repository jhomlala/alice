import 'package:alice/alice.dart';
import 'package:alice_http/alice_http_adapter.dart';
import 'package:alice_http/alice_http_extensions.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AliceHttpAdapter _aliceHttpAdapter = AliceHttpAdapter();

  late final Alice _alice = Alice(
    showNotification: true,
    showInspectorOnShake: true,
    maxCallsCount: 1000,
  )..addAdapter(_aliceHttpAdapter);

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
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              const SizedBox(height: 8),
              const Text(
                style: TextStyle(fontSize: 14),
                'Welcome to example of Alice Http Inspector. '
                'Click buttons below to generate sample data.',
              ),
              ElevatedButton(
                onPressed: _runHttpHttpRequests,
                child: const Text(
                  'Run http/http HTTP Requests',
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                style: TextStyle(fontSize: 14),
                'After clicking on buttons above, you should receive notification.'
                ' Click on it to show inspector. '
                'You can also shake your device or click button below.',
              ),
              ElevatedButton(
                onPressed: _runHttpInspector,
                child: const Text(
                  'Run HTTP Inspector',
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _runHttpHttpRequests() async {
    final Map<String, String> body = {
      'title': 'foo',
      'body': 'bar',
      'userId': '1'
    };

    http
        .post(Uri.https('jsonplaceholder.typicode.com', '/posts'), body: body)
        .interceptWithAlice(_aliceHttpAdapter, body: body);

    http
        .get(Uri.https('jsonplaceholder.typicode.com', '/posts'))
        .interceptWithAlice(_aliceHttpAdapter);

    http
        .put(Uri.https('jsonplaceholder.typicode.com', '/posts/1'), body: body)
        .interceptWithAlice(_aliceHttpAdapter, body: body);

    http
        .patch(
          Uri.https('jsonplaceholder.typicode.com', '/posts/1'),
          body: body,
        )
        .interceptWithAlice(_aliceHttpAdapter, body: body);

    http
        .delete(Uri.https('jsonplaceholder.typicode.com', '/posts/1'))
        .interceptWithAlice(_aliceHttpAdapter, body: body);

    http
        .get(Uri.https('jsonplaceholder.typicode.com', '/test/test'))
        .interceptWithAlice(_aliceHttpAdapter);

    http
        .post(Uri.https('jsonplaceholder.typicode.com', '/posts'), body: body)
        .then((response) => _aliceHttpAdapter.onResponse(response, body: body));

    http
        .get(Uri.https('jsonplaceholder.typicode.com', '/posts'))
        .then((response) => _aliceHttpAdapter.onResponse(response));

    http
        .put(Uri.https('jsonplaceholder.typicode.com', '/posts/1'), body: body)
        .then((response) => _aliceHttpAdapter.onResponse(response, body: body));

    http
        .patch(
          Uri.https('jsonplaceholder.typicode.com', '/posts/1'),
          body: body,
        )
        .then((response) => _aliceHttpAdapter.onResponse(response, body: body));

    http
        .delete(Uri.https('jsonplaceholder.typicode.com', '/posts/1'))
        .then((response) => _aliceHttpAdapter.onResponse(response));

    http
        .get(Uri.https('jsonplaceholder.typicode.com', '/test/test'))
        .then((response) => _aliceHttpAdapter.onResponse(response));

    http
        .post(
          Uri.https(
            'jsonplaceholder.typicode.com',
            '/posts',
            {'key1': 'value1'},
          ),
          body: body,
        )
        .interceptWithAlice(_aliceHttpAdapter, body: body);

    http
        .post(
          Uri.https(
            'jsonplaceholder.typicode.com',
            '/posts',
            {
              'key1': 'value1',
              'key2': 'value2',
              'key3': 'value3',
            },
          ),
          body: body,
        )
        .interceptWithAlice(_aliceHttpAdapter, body: body);

    http
        .get(
          Uri.https(
            'jsonplaceholder.typicode.com',
            '/test/test',
            {
              'key1': 'value1',
              'key2': 'value2',
              'key3': 'value3',
            },
          ),
        )
        .then((response) => _aliceHttpAdapter.onResponse(response));
  }

  void _runHttpInspector() {
    _alice.showInspector();
  }
}
