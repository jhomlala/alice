import 'dart:convert';

import 'package:alice/alice.dart';
import 'package:alice_chopper/alice_chopper_response_interceptor.dart';
import 'package:example/posts_service.dart';
import 'package:chopper/chopper.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Alice _alice;
  late AliceChopperAdapter _aliceChopperAdapter;
  late ChopperClient _chopper;
  late PostsService _postsService;

  @override
  void initState() {
    _alice = Alice(
      showNotification: true,
      showInspectorOnShake: true,
      maxCallsCount: 1000,
    );
    _aliceChopperAdapter = AliceChopperAdapter();
    _alice.addAdapter(_aliceChopperAdapter);

    _chopper = ChopperClient(
      interceptors: [_aliceChopperAdapter],
    );
    _postsService = PostsService.create(_chopper);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _alice.getNavigatorKey(),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Alice + Chopper - Example'),
        ),
        body: Container(
          padding: EdgeInsets.all(16),
          child: ListView(
            children: [
              const SizedBox(height: 8),
              Text(
                  'Welcome to example of Alice Http Inspector. Click buttons below to generate sample data.'),
              ElevatedButton(
                child: Text(
                  'Run Chopper HTTP Requests',
                ),
                onPressed: _runChopperHttpRequests,
              ),
              Text(
                  'After clicking on buttons above, you should receive notification.'
                  ' Click on it to show inspector. You can also shake your device or click button below.'),
              ElevatedButton(
                child: Text(
                  'Run HTTP Inspector',
                ),
                onPressed: _runHttpInspector,
              )
            ],
          ),
        ),
      ),
    );
  }

  void _runChopperHttpRequests() async {
    String body = jsonEncode(
        <String, dynamic>{'title': 'foo', 'body': 'bar', 'userId': '1'});
    _postsService.getPost('1');
    _postsService.postPost(body);
    _postsService.putPost('1', body);
    _postsService.putPost('1231923', body);
    _postsService.putPost('1', null);
    _postsService.postPost(null);
    _postsService.getPost('123456');
  }

  void _runHttpInspector() {
    _alice.showInspector();
  }
}
