import 'dart:io';

import 'package:alice/alice.dart';
import 'package:alice_dio/alice_dio_adapter.dart';
import 'package:alice_notification/alice_notification.dart';
import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AliceDioAdapter _aliceDioAdapter = AliceDioAdapter();

  late final AliceConfiguration _configuration = AliceConfiguration(
    showShareButton: true,
    showOverlayBubble: true,
    notificationAdapter: AliceLocalNotification(),
    redactedHeaders: {'authorization', 'x-api-key', 'cookie'},
    redactedBodyKeys: {'password', 'token', 'secret', 'client_secret'},
  );

  late final Alice _alice = Alice(configuration: _configuration)
    ..addAdapter(_aliceDioAdapter);

  late final Dio _dio = Dio(BaseOptions(followRedirects: false))
    ..interceptors.add(_aliceDioAdapter);

  @override
  Widget build(BuildContext context) {
    final isBubbleVisible = _alice.isOverlayBubbleVisible;

    return MaterialApp(
      navigatorKey: _alice.getNavigatorKey(),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('Alice + Dio - Example')),
        body: Container(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              const SizedBox(height: 8),
              const Text(
                'Welcome to the Alice + Dio Example.\n'
                'Test new features: Overlay Bubble, Security Redaction, JSON Tools, & VM Extensions.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.send),
                onPressed: _runDioRequests,
                label: const Text('Run Standard HTTP Requests'),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                icon: const Icon(Icons.hourglass_top),
                onPressed: _runSlowRequest,
                label: const Text('Run Slow Request (Observe Loading State)'),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                icon: const Icon(Icons.security),
                onPressed: _runRedactedRequests,
                label: const Text('Run Sensitive / Redacted Requests'),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                icon: const Icon(Icons.bubble_chart),
                onPressed: () {
                  if (_alice.isOverlayBubbleVisible) {
                    _alice.hideOverlayBubble();
                  } else {
                    _alice.showOverlayBubble();
                  }
                  setState(() {});
                },
                label: Text(
                  isBubbleVisible
                      ? 'Hide Floating Bubble'
                      : 'Show Floating Bubble',
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                icon: const Icon(Icons.remove_red_eye),
                onPressed: _runHttpInspector,
                label: const Text('Open Inspector'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _runSlowRequest() {
    // 2-second delay to clearly see the spinning loading indicator and in-flight badge
    _dio.get<void>('https://httpbin.org/delay/2');
  }

  void _runRedactedRequests() async {
    // 1. JSON POST with sensitive password and token fields
    await _dio.post<void>(
      'https://jsonplaceholder.typicode.com/posts',
      options: Options(
        headers: {
          'Authorization': 'Bearer super_secret_jwt_token_12345',
          'X-Api-Key': 'secret_key_99999',
          'Cookie': 'session_id=secret_cookie_val',
        },
      ),
      data: {
        'username': 'alice_developer',
        'password': 'very_secret_password',
        'token': 'private_access_token',
        'nested': {
          'secret': 'nested_secret_value',
          'public_info': 'hello world',
        },
      },
    );

    // 2. x-www-form-urlencoded body with sensitive fields
    await _dio.post<void>(
      'https://jsonplaceholder.typicode.com/posts',
      options: Options(contentType: Headers.formUrlEncodedContentType),
      data: 'grant_type=password&username=alice&password=secret_password&client_secret=top_secret',
    );
  }

  void _runDioRequests() async {
    final Map<String, dynamic> body = {
      'title': 'foo',
      'body': 'bar',
      'userId': '1',
    };

    final Map<String, dynamic> complexJsonBody = {
      'title': 'Alice JSON Viewer Example',
      'active': true,
      'id': 42,
      'tags': ['flutter', 'dio', 'inspector', 'json'],
      'user': {
        'name': 'John Doe',
        'email': 'john.doe@example.com',
        'roles': ['admin', 'user'],
      },
      'metadata': null,
    };

    _alice.tag(tag: 'test-flow', maxCalls: 2);
    _dio.post<void>(
      'https://jsonplaceholder.typicode.com/posts',
      data: complexJsonBody,
    );
    _dio.get<void>('https://jsonplaceholder.typicode.com/users/1');

    // Test duplicate detection by calling the same endpoint twice in a row
    _dio.get<void>('https://jsonplaceholder.typicode.com/todos/1');
    _dio.get<void>('https://jsonplaceholder.typicode.com/todos/1');
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

    _runXmlRequests();
  }

  void _runXmlRequests() {
    _dio.get<void>('https://httpbin.org/xml');
    _dio.get<void>('https://www.w3schools.com/xml/plant_catalog.xml');
    _dio.get<void>('https://www.w3.org/Graphics/SVG/1998/10/W3CFS.svg');
    _dio.get<void>(
      'https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/tiger.svg',
    );
  }

  void _runHttpInspector() {
    _alice.showInspector();
  }
}
