import 'dart:convert';
import 'dart:io';

import 'package:alice/alice.dart';
import 'package:alice/core/alice_http_client_extensions.dart';
import 'package:alice/core/alice_http_extensions.dart';
import 'package:alice_example/posts_service.dart';
import 'package:chopper/chopper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Alice _alice;
  late Dio _dio;
  late HttpClient _httpClient;
  ChopperClient? _chopper;
  late PostsService _postsService;
  Color _primaryColor = Color(0xffff5e57);
  Color _accentColor = Color(0xffff3f34);
  Color _buttonColor = Color(0xff008000);

  @override
  void initState() {
    _alice = Alice(
      showNotification: true,
      showInspectorOnShake: true,
      darkTheme: false,
      maxCallsCount: 1000,
    );
    _dio = Dio(BaseOptions(
      followRedirects: false,
    ));
    _dio.interceptors.add(_alice.getDioInterceptor());
    _httpClient = HttpClient();
    _chopper = ChopperClient(
      interceptors: _alice.getChopperInterceptor(),
    );
    _postsService = PostsService.create(_chopper);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ButtonStyle _buttonStyle = ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(_buttonColor));
    return MaterialApp(
      theme: ThemeData(
        primaryColor: _primaryColor,
        colorScheme: ColorScheme.light(secondary: _accentColor),
      ),
      navigatorKey: _alice.getNavigatorKey(),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
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
                child: Text("Run Dio HTTP Requests"),
                onPressed: _runDioRequests,
                style: _buttonStyle,
              ),
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
                child: Text("Run Chopper HTTP Requests"),
                onPressed: _runChopperHttpRequests,
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

  void _runChopperHttpRequests() async {
    String body = jsonEncode(
        <String, dynamic>{"title": "foo", "body": "bar", "userId": "1"});
    _postsService.getPost("1");
    _postsService.postPost(body);
    _postsService.putPost("1", body);
    _postsService.putPost("1231923", body);
    _postsService.putPost("1", null);
    _postsService.postPost(null);
    _postsService.getPost("123456");
  }

  void _runDioRequests() async {
    Map<String, dynamic> body = <String, dynamic>{
      "title": "foo",
      "body": "bar",
      "userId": "1"
    };
    _dio.get<void>(
        "https://httpbin.org/redirect-to?url=https%3A%2F%2Fhttpbin.org");
    _dio.delete<void>("https://httpbin.org/status/500");
    _dio.delete<void>("https://httpbin.org/status/400");
    _dio.delete<void>("https://httpbin.org/status/300");
    _dio.delete<void>("https://httpbin.org/status/200");
    _dio.delete<void>("https://httpbin.org/status/100");
    _dio.post<void>("https://jsonplaceholder.typicode.com/posts", data: body);
    _dio.get<void>("https://jsonplaceholder.typicode.com/posts",
        queryParameters: <String, dynamic>{"test": 1});
    _dio.put<void>("https://jsonplaceholder.typicode.com/posts/1", data: body);
    _dio.put<void>("https://jsonplaceholder.typicode.com/posts/1", data: body);
    _dio.delete<void>("https://jsonplaceholder.typicode.com/posts/1");
    _dio.get<void>("http://jsonplaceholder.typicode.com/test/test");

    _dio.get<void>("https://jsonplaceholder.typicode.com/photos");
    _dio.get<void>(
        "https://icons.iconarchive.com/icons/paomedia/small-n-flat/256/sign-info-icon.png");
    _dio.get<void>(
        "https://images.unsplash.com/photo-1542736705-53f0131d1e98?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&w=1000&q=80");
    _dio.get<void>(
        "https://findicons.com/files/icons/1322/world_of_aqua_5/128/bluetooth.png");
    _dio.get<void>(
        "https://upload.wikimedia.org/wikipedia/commons/4/4e/Pleiades_large.jpg");
    _dio.get<void>("http://techslides.com/demos/sample-videos/small.mp4");

    _dio.get<void>("https://www.cse.wustl.edu/~jain/cis677-97/ftp/e_3dlc2.pdf");

    final directory = await getApplicationDocumentsDirectory();
    File file = File("${directory.path}/test.txt");
    file.create();
    file.writeAsStringSync("123456789");

    String fileName = file.path.split('/').last;
    FormData formData = FormData.fromMap(<String, dynamic>{
      "file": await MultipartFile.fromFile(file.path, filename: fileName),
    });
    _dio.post<void>("https://jsonplaceholder.typicode.com/photos",
        data: formData);

    _dio.get<void>("http://dummy.restapiexample.com/api/v1/employees");
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
    _alice.showInspector();
  }
}
