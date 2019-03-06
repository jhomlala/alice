import 'dart:convert';
import 'dart:io';
import 'package:alice/alice.dart';
import 'package:http/http.dart' as http;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';

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
    Map<String,dynamic> body = {"title": "foo", "body": "bar", "userId": "1"};
    http.Response response =
        await http.post('https://jsonplaceholder.typicode.com/posts', body: body);
    alice.onHttpResponse(response, body: body);


    response =
    await http.get('https://jsonplaceholder.typicode.com/posts');
    alice.onHttpResponse(response);

    response =
    await http.put('https://jsonplaceholder.typicode.com/posts/1',body:body);
    alice.onHttpResponse(response,body:body);

    response =
    await http.patch('https://jsonplaceholder.typicode.com/posts/1',body:body);
    alice.onHttpResponse(response, body: body);

    response =
    await http.delete('https://jsonplaceholder.typicode.com/posts/1');
    alice.onHttpResponse(response);

    response =
    await http.get('https://jsonplaceholder.typicode.com/test/test');
    alice.onHttpResponse(response);



    var request = await httpClient.postUrl(Uri.parse("https://jsonplaceholder.typicode.com/posts"));
    request.write(body);
    alice.onHttpClientRequest(request,body:body);
    var httpResponse = await request.close();
    var responseBody = await httpResponse.transform(utf8.decoder).join();
    alice.onHttpClientResponse(httpResponse,request, body: responseBody);

    request = await httpClient.getUrl(Uri.parse("https://jsonplaceholder.typicode.com/posts"));
    alice.onHttpClientRequest(request);
    httpResponse = await request.close();
    responseBody = await httpResponse.transform(utf8.decoder).join();
    alice.onHttpClientResponse(httpResponse,request, body: responseBody);

    request = await httpClient.putUrl(Uri.parse("https://jsonplaceholder.typicode.com/posts/1"));
    request.write(body);
    alice.onHttpClientRequest(request,body:body);
    httpResponse = await request.close();
    responseBody = await httpResponse.transform(utf8.decoder).join();
    alice.onHttpClientResponse(httpResponse,request, body: responseBody);


    request = await httpClient.patchUrl(Uri.parse("https://jsonplaceholder.typicode.com/posts/1"));
    request.write(body);
    alice.onHttpClientRequest(request,body:body);
    httpResponse = await request.close();
    responseBody = await httpResponse.transform(utf8.decoder).join();
    alice.onHttpClientResponse(httpResponse,request, body: responseBody);


    request = await httpClient.deleteUrl(Uri.parse("https://jsonplaceholder.typicode.com/posts/1"));
    alice.onHttpClientRequest(request);
    httpResponse = await request.close();
    responseBody = await httpResponse.transform(utf8.decoder).join();
    alice.onHttpClientResponse(httpResponse,request, body: responseBody);

    request = await httpClient.getUrl(Uri.parse("https://jsonplaceholder.typicode.com/test/test"));
    alice.onHttpClientRequest(request);
    httpResponse = await request.close();
    responseBody = await httpResponse.transform(utf8.decoder).join();
    alice.onHttpClientResponse(httpResponse,request, body: responseBody);

    dio.post("https://jsonplaceholder.typicode.com/posts",data:body);
    dio.get("https://jsonplaceholder.typicode.com/posts");
    dio.put("https://jsonplaceholder.typicode.com/posts/1",data:body);
    dio.put("https://jsonplaceholder.typicode.com/posts/1",data:body);
    dio.delete("https://jsonplaceholder.typicode.com/posts/1");
    dio.get("https://jsonplaceholder.typicode.com/test/test");

  }
  

  void _runHttpInspector() {
    alice.showInspector();
  }
}
