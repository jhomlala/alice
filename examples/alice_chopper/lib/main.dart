import 'package:alice/alice.dart';
import 'package:alice_chopper/alice_chopper_adapter.dart';
import 'package:example/interceptors/json_content_type_inerceptor.dart';
import 'package:example/interceptors/json_headers_interceptor.dart';
import 'package:example/models/album.dart';
import 'package:example/models/article.dart';
import 'package:example/models/comment.dart';
import 'package:example/models/photo.dart';
import 'package:example/models/todo.dart';
import 'package:example/models/user.dart';
import 'package:example/services/albums_service.dart';
import 'package:example/services/comments_service.dart';
import 'package:example/services/converters/json_serializable_converter.dart';
import 'package:example/services/articles_service.dart';
import 'package:chopper/chopper.dart';
import 'package:example/services/photos_service.dart';
import 'package:example/services/todos_service.dart';
import 'package:example/services/users_service.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AliceChopperAdapter _aliceChopperAdapter = AliceChopperAdapter();

  late final Alice _alice = Alice(
    showNotification: true,
    showInspectorOnShake: true,
    maxCallsCount: 1000,
  )..addAdapter(_aliceChopperAdapter);

  late final ChopperClient _chopper = ChopperClient(
    baseUrl: Uri.https('jsonplaceholder.typicode.com'),
    services: [
      AlbumsService.create(),
      ArticlesService.create(),
      CommentsService.create(),
      PhotosService.create(),
      TodosService.create(),
      UsersService.create(),
    ],
    interceptors: [
      JsonHeadersInterceptor(),
      JsonContentTypeInterceptor(),
      _aliceChopperAdapter,
    ],
    converter: const JsonSerializableConverter({
      Album: Album.fromJson,
      Article: Article.fromJson,
      Comment: Comment.fromJson,
      Photo: Photo.fromJson,
      Todo: Todo.fromJson,
      User: User.fromJson,
    }),
  );

  late final ArticlesService articlesService =
      _chopper.getService<ArticlesService>();

  Future<void> _runChopperHttpRequests() async {
    const Article article = Article(
      title: 'foo',
      body: 'bar',
      userId: 1,
    );

    articlesService.getAll();
    articlesService.getAll(userId: 2);
    articlesService.post(article);
    articlesService.get(1);
    articlesService.put(1, article.copyWith(id: 1));
    articlesService.patch(1, article.copyWith(id: 1));
    articlesService.delete(1);
    articlesService.put(123456, article.copyWith(id: 123456));
    articlesService.patch(123456, article.copyWith(id: 123456));
    articlesService.get(123456);
    articlesService.delete(123456);
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
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              const SizedBox(height: 8),
              const Text(
                'Welcome to example of Alice Http Inspector. '
                'Click buttons below to generate sample data.',
              ),
              ElevatedButton(
                onPressed: _runChopperHttpRequests,
                child: const Text(
                  'Run Chopper HTTP Requests',
                ),
              ),
              const Text(
                'After clicking on buttons above, you should receive notification.'
                ' Click on it to show inspector. '
                'You can also shake your device or click button below.',
              ),
              ElevatedButton(
                onPressed: _runHttpInspector,
                child: const Text('Run HTTP Inspector'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
