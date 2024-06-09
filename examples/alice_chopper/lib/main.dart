import 'package:alice/alice.dart';
import 'package:alice_chopper/alice_chopper_adapter.dart';
import 'package:example/models/example_post.dart';
import 'package:example/services/converters/json_serializable_converter.dart';
import 'package:example/services/example_posts_service.dart';
import 'package:chopper/chopper.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AliceChopperAdapter _aliceChopperAdapter = AliceChopperAdapter();
  late final Alice _alice = Alice(
    showNotification: true,
    showInspectorOnShake: true,
    maxCallsCount: 1000,
  )..addAdapter(_aliceChopperAdapter);

  final JsonSerializableConverter converter = JsonSerializableConverter({
    ExamplePost: ExamplePost.fromJson,
  });

  late final ChopperClient _chopper = ChopperClient(
    baseUrl: Uri.https('jsonplaceholder.typicode.com'),
    services: [
      ExamplePostsService.create(),
    ],
    interceptors: [
      _aliceChopperAdapter,
    ],
    converter: converter,
  );

  Future<void> _runChopperHttpRequests() async {
    final ExamplePostsService postService =
        _chopper.getService<ExamplePostsService>();

    final ExamplePost post = ExamplePost(
      title: 'foo',
      body: 'bar',
      userId: 1,
    );

    postService.createExamplePost(post);
    postService.getExamplePost(1);
    postService.updateExamplePost(1, post.copyWith(id: 1));
    postService.deleteExamplePost(1);
    postService.updateExamplePost(123456, post.copyWith(id: 123456));
    postService.getExamplePost(123456);
    postService.deleteExamplePost(123456);
  }

  void _runHttpInspector() {
    _alice.showInspector();
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
                'Welcome to example of Alice Http Inspector. Click buttons below to generate sample data.',
              ),
              ElevatedButton(
                child: Text(
                  'Run Chopper HTTP Requests',
                ),
                onPressed: _runChopperHttpRequests,
              ),
              Text(
                'After clicking on buttons above, you should receive notification.'
                ' Click on it to show inspector. You can also shake your device or click button below.',
              ),
              ElevatedButton(
                child: Text('Run HTTP Inspector'),
                onPressed: _runHttpInspector,
              )
            ],
          ),
        ),
      ),
    );
  }
}
