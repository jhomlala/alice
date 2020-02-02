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

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Alice alice;
  Dio dio;
  HttpClient httpClient;
  ChopperClient chopper;
  PostsService postsService;

  @override
  void initState() {
    alice = Alice(
        showNotification: true, showInspectorOnShake: true, darkTheme: true);
    dio = Dio();
    dio.interceptors.add(alice.getDioInterceptor());
    httpClient = HttpClient();
    chopper = ChopperClient(
      interceptors: alice.getChopperInterceptor(),
    );
    postsService = PostsService.create(chopper);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: alice.getNavigatorKey(),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Alice HTTP Inspector example'),
        ),
        body: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          RaisedButton(
            child: Text("Run HTTP Requests"),
            onPressed: _runHttpRequests,
          ),
          RaisedButton(
            child: Text("Run HTTP Insepctor"),
            onPressed: _runHttpInspector,
          )
        ])),
      ),
    );
  }

  void _runChopperHttpRequests() async {
    Map<String, dynamic> body = {"title": "foo", "body": "bar", "userId": "1"};
    postsService.getPost("1");
    postsService.postPost(body);
    postsService.putPost("1", body);
    postsService.putPost("1231923", body);
    postsService.putPost("1", null);
    postsService.postPost(null);
    postsService.getPost("123456");
  }

  void _runHttpRequests() async {
    _runChopperHttpRequests();
    Map<String, dynamic> body = {"title": "foo", "body": "bar", "userId": "1"};

    http
        .post('https://jsonplaceholder.typicode.com/posts', body: body)
        .interceptWithAlice(alice, body: body);

    http
        .get('https://jsonplaceholder.typicode.com/posts')
        .interceptWithAlice(alice);

    http
        .put('https://jsonplaceholder.typicode.com/posts/1', body: body)
        .interceptWithAlice(alice, body: body);

    http
        .patch('https://jsonplaceholder.typicode.com/posts/1', body: body)
        .interceptWithAlice(alice, body: body);

    http
        .delete('https://jsonplaceholder.typicode.com/posts/1')
        .interceptWithAlice(alice, body: body);

    http
        .get('https://jsonplaceholder.typicode.com/test/test')
        .interceptWithAlice(alice);

    http
        .post('https://jsonplaceholder.typicode.com/posts', body: body)
        .then((response) {
      alice.onHttpResponse(response, body: body);
    });

    http.get('https://jsonplaceholder.typicode.com/posts').then((response) {
      alice.onHttpResponse(response);
    });

    http
        .put('https://jsonplaceholder.typicode.com/posts/1', body: body)
        .then((response) {
      alice.onHttpResponse(response, body: body);
    });

    http
        .patch('https://jsonplaceholder.typicode.com/posts/1', body: body)
        .then((response) {
      alice.onHttpResponse(response, body: body);
    });

    http
        .delete('https://jsonplaceholder.typicode.com/posts/1')
        .then((response) {
      alice.onHttpResponse(response);
    });

    http.get('https://jsonplaceholder.typicode.com/test/test').then((response) {
      alice.onHttpResponse(response);
    });

    httpClient
        .getUrl(Uri.parse("https://jsonplaceholder.typicode.com/posts"))
        .interceptWithAlice(alice);

    httpClient
        .postUrl(Uri.parse("https://jsonplaceholder.typicode.com/posts"))
        .interceptWithAlice(alice, body: body, headers: Map());

    httpClient
        .putUrl(Uri.parse("https://jsonplaceholder.typicode.com/posts/1"))
        .interceptWithAlice(alice, body: body);

    httpClient
        .getUrl(Uri.parse("https://jsonplaceholder.typicode.com/test/test/"))
        .interceptWithAlice(alice);

    httpClient
        .postUrl(Uri.parse("https://jsonplaceholder.typicode.com/posts"))
        .then((request) async {
      alice.onHttpClientRequest(request, body: body);
      request.write(body);
      var httpResponse = await request.close();
      var responseBody = await utf8.decoder.bind(httpResponse).join();
      alice.onHttpClientResponse(httpResponse, request, body: responseBody);
    });

    httpClient
        .putUrl(Uri.parse("https://jsonplaceholder.typicode.com/posts/1"))
        .then((request) async {
      alice.onHttpClientRequest(request, body: body);
      request.write(body);
      var httpResponse = await request.close();
      var responseBody = await utf8.decoder.bind(httpResponse).join();
      alice.onHttpClientResponse(httpResponse, request, body: responseBody);
    });

    httpClient
        .patchUrl(Uri.parse("https://jsonplaceholder.typicode.com/posts/1"))
        .then((request) async {
      alice.onHttpClientRequest(request, body: body);
      request.write(body);
      var httpResponse = await request.close();
      var responseBody = await utf8.decoder.bind(httpResponse).join();
      alice.onHttpClientResponse(httpResponse, request, body: responseBody);
    });

    httpClient
        .deleteUrl(Uri.parse("https://jsonplaceholder.typicode.com/posts/1"))
        .then((request) async {
      alice.onHttpClientRequest(request);
      var httpResponse = await request.close();
      var responseBody = await utf8.decoder.bind(httpResponse).join();
      alice.onHttpClientResponse(httpResponse, request, body: responseBody);
    });

    httpClient
        .getUrl(Uri.parse("https://jsonplaceholder.typicode.com/test/test/"))
        .then((request) async {
      alice.onHttpClientRequest(request);
      var httpResponse = await request.close();
      var responseBody = await utf8.decoder.bind(httpResponse).join();
      alice.onHttpClientResponse(httpResponse, request, body: responseBody);
    });

    /*dio.post("https://jsonplaceholder.typicode.com/posts", data: body);
    dio.get("https://jsonplaceholder.typicode.com/posts",
        queryParameters: {"test": 1});
    dio.put("https://jsonplaceholder.typicode.com/posts/1", data: body);
    dio.put("https://jsonplaceholder.typicode.com/posts/1", data: body);
    dio.delete("https://jsonplaceholder.typicode.com/posts/1");
    dio.get("http://jsonplaceholder.typicode.com/test/test");

    dio.get("https://jsonplaceholder.typicode.com/photos");
    dio.get(
        "https://icons.iconarchive.com/icons/paomedia/small-n-flat/256/sign-info-icon.png");
    dio.get(
        "https://images.unsplash.com/photo-1542736705-53f0131d1e98?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&w=1000&q=80");
    dio.get(
        "https://findicons.com/files/icons/1322/world_of_aqua_5/128/bluetooth.png");
    dio.get(
        "https://upload.wikimedia.org/wikipedia/commons/4/4e/Pleiades_large.jpg");
    dio.get("http://techslides.com/demos/sample-videos/small.mp4");*/
  }

  void _runHttpInspector() {
    alice.showInspector();
  }
}
