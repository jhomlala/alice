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
  @override
  void initState() {
    alice = Alice(showNotification: true);
    dio = Dio();
    dio.interceptors.add(alice.getDioInterceptor());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: alice.getNavigatorKey(),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
            child: FlatButton(
          child: Text("Run"),
          onPressed: _onPressed,
        )),
      ),
    );
  }


  void _onPressed() async {


    /*http.Response response =  await http.get('https://google.com');
    print(response.request.url.toString());
    var body = {"aaa":"bbb"};
    alice.onHttpResponse(response,body: body);*/


    /*HttpClient http = HttpClient();
    try {
      // Use darts Uri builder
      var uri = Uri.parse("http://gosfdsfdogle.com");
      var request = await http.getUrl(uri);

      alice.onHttpClientRequest(request);
      var response = await request.close();
      var responseBody = await response.transform(utf8.decoder).join();
      alice.onHttpClientResponse(response,request, body: responseBody);

      // The dog.ceo API returns a JSON object with a property
      // called 'message', which actually is the URL.
    } catch (exception) {
      print(exception);
      print(exception.runtimeType.toString());
    }*/



    //http.get("http://wykop.pl")
    dio.get("https://my-json-server.typicode.com/typicode/demo/posts");
    //dio.get("https://httpstat.us/404");
    dio.get("http://slowwly.robertomurray.co.uk/delay/10000/url/http://www.google.co.uk");
    dio.get("https://thispersondoesnofsdfsdfdsfsdfsdfdsfsdfsdfsdfsdftexist.com/sdfsdfdsf/sdfsdfdsfs/fsdfsdfsdfsf/sdfsdfsdfsdf/sdfsdfsdfdsf/sdfsdf");


    startTimeout();
  }

  startTimeout() {
    print("Start timeout");
    var duration = Duration(seconds: 5);
    return new Timer(duration, handleTimeout);
  }

  void handleTimeout() {
    // callback function
    startTimeout();
    dio.get("https://my-json-server.typicode.com/typicode/demo/posts");
  }
}
