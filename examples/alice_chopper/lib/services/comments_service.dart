import 'package:chopper/chopper.dart';
import 'package:example/models/comment.dart';

part 'comments_service.chopper.dart';

@ChopperApi(baseUrl: '/comments')
abstract class CommentsService extends ChopperService {
  static CommentsService create([ChopperClient? client]) =>
      _$CommentsService(client);

  @Get(path: '/', timeout: Duration(seconds: 10))
  Future<Response<List<Comment>>> getAll({
    @Query('postId') int? articleId,
    @Query() String? email,
  });

  @Get(path: '/{id}', timeout: Duration(seconds: 10))
  Future<Response<Comment?>> get(@Path() int id);

  @Post(path: '/', timeout: Duration(seconds: 10))
  Future<Response<Comment?>> post(@Body() Comment body);

  @Put(path: '/{id}', timeout: Duration(seconds: 10))
  Future<Response<Comment?>> put(@Path() int id, @Body() Comment body);

  @Patch(path: '/{id}', timeout: Duration(seconds: 10))
  Future<Response<Comment?>> patch(@Path() int id, @Body() Comment body);

  @Delete(path: '/{id}', timeout: Duration(seconds: 10))
  Future<Response<void>> delete(@Path() int id);
}
