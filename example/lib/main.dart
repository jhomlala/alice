import 'dart:convert';
import 'dart:io';
import 'package:alice/alice.dart';
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

  @override
  void initState() {
    alice = Alice(showNotification: true);
    dio = Dio();
    dio.interceptors.add(alice.getDioInterceptor());
    httpClient = HttpClient();
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

  void _runHttpRequests() async {
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
    dio.get("https://jsonplaceholder.typicode.com/posts", queryParameters: {
      "test":1
    });
    dio.put("https://jsonplaceholder.typicode.com/posts/1", data: body);
    dio.put("https://jsonplaceholder.typicode.com/posts/1", data: body);
    dio.delete("https://jsonplaceholder.typicode.com/posts/1");
    dio.get("http://jsonplaceholder.typicode.com/test/test");

  }

  void _runHttpInspector() {
    alice.showInspector();
  }
}
