import 'package:alice/alice.dart';
import 'package:alice_chopper/alice_chopper_adapter.dart';
import 'package:example/interceptors/json_content_type_inerceptor.dart';
import 'package:example/interceptors/json_headers_interceptor.dart';
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
      JsonHeadersInterceptor(),
      JsonContentTypeInterceptor(),
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

    postService.getPosts();
    postService.getPosts(userId: 2);
    postService.createPost(post);
    postService.getPost(1);
    postService.putPost(1, post.copyWith(id: 1));
    postService.patchPost(1, post.copyWith(id: 1));
    postService.deletePost(1);
    postService.putPost(123456, post.copyWith(id: 123456));
    postService.patchPost(123456, post.copyWith(id: 123456));
    postService.getPost(123456);
    postService.deletePost(123456);
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
