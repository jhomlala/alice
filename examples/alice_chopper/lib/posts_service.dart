import "dart:async";

import 'package:chopper/chopper.dart';

// this is necessary for the generated code to find your class
part 'posts_service.chopper.dart';

@ChopperApi(baseUrl: 'https://jsonplaceholder.typicode.com/posts')
abstract class PostsService extends ChopperService {
  // helper methods that help you instantiate your service
  static PostsService create([ChopperClient? client]) =>
      _$PostsService(client!);

  @Get(path: '/{id}')
  Future<Response> getPost(@Path() String id);

  @Post(path: '/')
  Future<Response> postPost(@Body() String? body);

  @Put(path: '/{id}')
  Future<Response> putPost(@Path() String id, @Body() String? body);
}
