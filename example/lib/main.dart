import 'dart:convert';
import 'dart:io';
import 'package:alice/alice.dart';
import 'package:alice_example/posts_service.dart';
import 'package:chopper/chopper.dart';
import 'package:http/http.dart' as http;

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
        .postUrl(Uri.parse("https://jsonplaceholder.typicode.com/posts"))
        .then((request) async {
      alice.onHttpClientRequest(request, body: body);
      request.write(body);
      var httpResponse = await request.close();
      var responseBody = await utf8.decoder.bind(httpResponse).join();
      alice.onHttpClientResponse(httpResponse, request, body: responseBody);
    });

    httpClient
        .getUrl(Uri.parse("https://jsonplaceholder.typicode.com/posts"))
        .then((request) async {
      alice.onHttpClientRequest(request);
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

    dio.post("https://jsonplaceholder.typicode.com/posts", data: body);
    dio.get("https://jsonplaceholder.typicode.com/posts",
        queryParameters: {"test": 1});
    dio.put("https://jsonplaceholder.typicode.com/posts/1", data: body);
    dio.put("https://jsonplaceholder.typicode.com/posts/1", data: body);
    dio.delete("https://jsonplaceholder.typicode.com/posts/1");
    dio.get("http://jsonplaceholder.typicode.com/test/test");
  }

  void _runHttpInspector() {
    alice.showInspector();
  }
}
