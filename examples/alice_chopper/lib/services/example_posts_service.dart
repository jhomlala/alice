import 'package:chopper/chopper.dart';
import 'package:example/models/example_post.dart';

// this is necessary for the generated code to find your class
part 'example_posts_service.chopper.dart';

@ChopperApi(baseUrl: '/posts')
abstract class ExamplePostsService extends ChopperService {
  // helper methods that help you instantiate your service
  static ExamplePostsService create([ChopperClient? client]) =>
      _$ExamplePostsService(client);

  @Get(path: '/', timeout: Duration(seconds: 10))
  Future<Response<List<ExamplePost>>> getPosts();

  @Get(path: '/{id}', timeout: Duration(seconds: 10))
  Future<Response<ExamplePost?>> getPost(@Path() int id);

  @Post(path: '/', timeout: Duration(seconds: 10))
  Future<Response<ExamplePost?>> createPost(@Body() ExamplePost body);

  @Put(path: '/{id}', timeout: Duration(seconds: 10))
  Future<Response<ExamplePost?>> updatePost(
    @Path() int id,
    @Body() ExamplePost body,
  );

  @Delete(path: '/{id}', timeout: Duration(seconds: 10))
  Future<Response<void>> deletePost(@Path() int id);
}
