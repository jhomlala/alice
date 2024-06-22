import 'dart:io';

import 'package:alice/alice.dart';
import 'package:alice_dio/alice_dio_adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AliceDioAdapter _aliceDioAdapter = AliceDioAdapter();

  late final Alice _alice = Alice(
    showNotification: true,
    showInspectorOnShake: true,
    maxCallsCount: 1000,
  )..addAdapter(_aliceDioAdapter);

  late final Dio _dio = Dio(BaseOptions(followRedirects: false))
    ..interceptors.add(_aliceDioAdapter);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _alice.getNavigatorKey(),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Alice + Dio - Example'),
        ),
        body: Container(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              const SizedBox(height: 8),
              const Text(
                style: TextStyle(fontSize: 14),
                'Welcome to example of Alice + Dio Example. '
                'Click buttons below to generate sample data.',
              ),
              ElevatedButton(
                onPressed: _runDioRequests,
                child: const Text(
                  'Run Dio HTTP Requests',
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                  style: TextStyle(fontSize: 14),
                  'After clicking on buttons above, you should receive notification.'
                  ' Click on it to show inspector. You can also shake your device or click button below.'),
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

  void _runDioRequests() async {
    final Map<String, dynamic> body = {
      'title': 'foo',
      'body': 'bar',
      'userId': '1'
    };
    _dio.get<void>(
      'https://httpbin.org/redirect-to?url=https%3A%2F%2Fhttpbin.org',
    );
    _dio.delete<void>('https://httpbin.org/status/500');
    _dio.delete<void>('https://httpbin.org/status/400');
    _dio.delete<void>('https://httpbin.org/status/300');
    _dio.delete<void>('https://httpbin.org/status/200');
    _dio.delete<void>('https://httpbin.org/status/100');
    _dio.post<void>('https://jsonplaceholder.typicode.com/posts', data: body);
    _dio.get<void>(
      'https://jsonplaceholder.typicode.com/posts',
      queryParameters: {'test': 1},
    );
    _dio.put<void>('https://jsonplaceholder.typicode.com/posts/1', data: body);
    _dio.put<void>('https://jsonplaceholder.typicode.com/posts/1', data: body);
    _dio.delete<void>('https://jsonplaceholder.typicode.com/posts/1');
    _dio.get<void>('http://jsonplaceholder.typicode.com/test/test');

    _dio.get<void>('https://jsonplaceholder.typicode.com/photos');
    _dio.get<void>(
      'https://icons.iconarchive.com/icons/paomedia/small-n-flat/256/sign-info-icon.png',
    );
    _dio.get<void>(
      'https://images.unsplash.com/photo-1542736705-53f0131d1e98?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&w=1000&q=80',
    );
    _dio.get<void>(
      'https://findicons.com/files/icons/1322/world_of_aqua_5/128/bluetooth.png',
    );
    _dio.get<void>(
      'https://upload.wikimedia.org/wikipedia/commons/4/4e/Pleiades_large.jpg',
    );
    _dio.get<void>('http://techslides.com/demos/sample-videos/small.mp4');

    _dio.get<void>('https://www.cse.wustl.edu/~jain/cis677-97/ftp/e_3dlc2.pdf');

    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File(p.join(directory.path, 'test.txt'));
    if (!await file.exists()) {
      await file.create();
    }
    await file.writeAsString('123456789');

    final String fileName = file.path.split('/').last;
    final FormData formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: fileName),
    });
    _dio.post<void>(
      'https://jsonplaceholder.typicode.com/photos',
      data: formData,
    );

    _dio.get<void>('http://dummy.restapiexample.com/api/v1/employees');
  }

  void _runHttpInspector() {
    _alice.showInspector();
  }
}
