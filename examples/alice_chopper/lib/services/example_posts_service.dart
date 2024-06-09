import 'package:chopper/chopper.dart';
import 'package:example/models/example_post.dart';

// this is necessary for the generated code to find your class
part 'example_posts_service.chopper.dart';

@ChopperApi(baseUrl: '/posts')
abstract class ExamplePostsService extends ChopperService {
  // helper methods that help you instantiate your service
  static ExamplePostsService create([ChopperClient? client]) =>
      _$ExamplePostsService(client);

  @Get(path: '/{id}', timeout: Duration(seconds: 10))
  Future<Response<ExamplePost?>> getExamplePost(@Path() int id);

  @Post(path: '/', timeout: Duration(seconds: 10))
  Future<Response<ExamplePost?>> createExamplePost(@Body() ExamplePost body);

  @Put(path: '/{id}', timeout: Duration(seconds: 10))
  Future<Response<ExamplePost?>> updateExamplePost(
    @Path() int id,
    @Body() ExamplePost body,
  );

  @Delete(path: '/{id}', timeout: Duration(seconds: 10))
  Future<Response<void>> deleteExamplePost(@Path() int id);
}
