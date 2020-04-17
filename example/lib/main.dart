import 'dart:convert';
import 'dart:io';
import 'package:alice/alice.dart';
import 'package:alice_example/posts_service.dart';
import 'package:chopper/chopper.dart';
import 'package:http/http.dart' as http;
import 'package:alice/core/alice_http_client_extensions.dart';
import 'package:alice/core/alice_http_extensions.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Alice _alice;
  Dio _dio;
  HttpClient _httpClient;
  ChopperClient _chopper;
  PostsService _postsService;

  @override
  void initState() {
    _alice = Alice(
        showNotification: true, showInspectorOnShake: true, darkTheme: false);
    _dio = Dio(BaseOptions(followRedirects: false));
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
    return MaterialApp(
      theme: ThemeData(
          primaryColor: Color(0xffff5e57), accentColor: Color(0xffff3f34)),
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
              RaisedButton(
                child: Text("Run Dio HTTP Requests"),
                onPressed: _runDioRequests,
              ),
              RaisedButton(
                child: Text("Run http/http HTTP Requests"),
                onPressed: _runHttpHttpRequests,
              ),
              RaisedButton(
                child: Text("Run HttpClient Requests"),
                onPressed: _runHttpHttpClientRequests,
              ),
              RaisedButton(
                child: Text("Run Chopper HTTP Requests"),
                onPressed: _runChopperHttpRequests,
              ),
              const SizedBox(height: 24),
              _getTextWidget(
                  "After clicking on buttons above, you should receive notification."
                  " Click on it to show inspector. You can also shake your device or click button below."),
              RaisedButton(
                child: Text("Run HTTP Insepctor"),
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

  void _runChopperHttpRequests() async {
    Map<String, dynamic> body = {"title": "foo", "body": "bar", "userId": "1"};
    _postsService.getPost("1");
    _postsService.postPost(body);
    _postsService.putPost("1", body);
    _postsService.putPost("1231923", body);
    _postsService.putPost("1", null);
    _postsService.postPost(null);
    _postsService.getPost("123456");
  }

  void _runDioRequests() async {
    Map<String, dynamic> body = {"title": "foo", "body": "bar", "userId": "1"};
    _dio.get("https://httpbin.org/redirect-to?url=https%3A%2F%2Fhttpbin.org");
    _dio.delete("https://httpbin.org/status/500");
    _dio.delete("https://httpbin.org/status/400");
    _dio.delete("https://httpbin.org/status/300");
    _dio.delete("https://httpbin.org/status/200");
    _dio.delete("https://httpbin.org/status/100");
    _dio.post("https://jsonplaceholder.typicode.com/posts", data: body);
    _dio.get("https://jsonplaceholder.typicode.com/posts",
        queryParameters: {"test": 1});
    _dio.put("https://jsonplaceholder.typicode.com/posts/1", data: body);
    _dio.put("https://jsonplaceholder.typicode.com/posts/1", data: body);
    _dio.delete("https://jsonplaceholder.typicode.com/posts/1");
    _dio.get("http://jsonplaceholder.typicode.com/test/test");

    _dio.get("https://jsonplaceholder.typicode.com/photos");
    _dio.get(
        "https://icons.iconarchive.com/icons/paomedia/small-n-flat/256/sign-info-icon.png");
    _dio.get(
        "https://images.unsplash.com/photo-1542736705-53f0131d1e98?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&w=1000&q=80");
    _dio.get(
        "https://findicons.com/files/icons/1322/world_of_aqua_5/128/bluetooth.png");
    _dio.get(
        "https://upload.wikimedia.org/wikipedia/commons/4/4e/Pleiades_large.jpg");
    _dio.get("http://techslides.com/demos/sample-videos/small.mp4");

    _dio.get("https://www.cse.wustl.edu/~jain/cis677-97/ftp/e_3dlc2.pdf");

    final directory = await getApplicationDocumentsDirectory();
    File file = File("${directory.path}/test.txt");
    file.create();
    file.writeAsStringSync("123456789");

    String fileName = file.path.split('/').last;
    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(file.path, filename: fileName),
    });
    _dio.post("https://jsonplaceholder.typicode.com/photos", data: formData);

    _dio.get("http://dummy.restapiexample.com/api/v1/employees");
  }

  void _runHttpHttpRequests() async {
    Map<String, dynamic> body = {"title": "foo", "body": "bar", "userId": "1"};
    http
        .post('https://jsonplaceholder.typicode.com/posts', body: body)
        .interceptWithAlice(_alice, body: body);

    http
        .get('https://jsonplaceholder.typicode.com/posts')
        .interceptWithAlice(_alice);

    http
        .put('https://jsonplaceholder.typicode.com/posts/1', body: body)
        .interceptWithAlice(_alice, body: body);

    http
        .patch('https://jsonplaceholder.typicode.com/posts/1', body: body)
        .interceptWithAlice(_alice, body: body);

    http
        .delete('https://jsonplaceholder.typicode.com/posts/1')
        .interceptWithAlice(_alice, body: body);

    http
        .get('https://jsonplaceholder.typicode.com/test/test')
        .interceptWithAlice(_alice);

    http
        .post('https://jsonplaceholder.typicode.com/posts', body: body)
        .then((response) {
      _alice.onHttpResponse(response, body: body);
    });

    http.get('https://jsonplaceholder.typicode.com/posts').then((response) {
      _alice.onHttpResponse(response);
    });

    http
        .put('https://jsonplaceholder.typicode.com/posts/1', body: body)
        .then((response) {
      _alice.onHttpResponse(response, body: body);
    });

    http
        .patch('https://jsonplaceholder.typicode.com/posts/1', body: body)
        .then((response) {
      _alice.onHttpResponse(response, body: body);
    });

    http
        .delete('https://jsonplaceholder.typicode.com/posts/1')
        .then((response) {
      _alice.onHttpResponse(response);
    });

    http.get('https://jsonplaceholder.typicode.com/test/test').then((response) {
      _alice.onHttpResponse(response);
    });
  }

  void _runHttpHttpClientRequests() {
    Map<String, dynamic> body = {"title": "foo", "body": "bar", "userId": "1"};
    _httpClient
        .getUrl(Uri.parse("https://jsonplaceholder.typicode.com/posts"))
        .interceptWithAlice(_alice);

    _httpClient
        .postUrl(Uri.parse("https://jsonplaceholder.typicode.com/posts"))
        .interceptWithAlice(_alice, body: body, headers: Map());

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
