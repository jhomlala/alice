import 'package:chopper/chopper.dart';
import 'package:example/models/album.dart';
import 'package:example/models/article.dart';
import 'package:example/models/todo.dart';
import 'package:example/models/user.dart';

part 'users_service.chopper.dart';

@ChopperApi(baseUrl: '/users')
abstract class UsersService extends ChopperService {
  static UsersService create([ChopperClient? client]) => _$UsersService(client);

  @Get(path: '/', timeout: Duration(seconds: 10))
  Future<Response<List<User>>> getAll({
    @Query('id') int? id,
    @Query('username') String? username,
    @Query('email') String? email,
    @Query('phone') String? phone,
    @Query('website') String? website,
  });

  @Get(path: '/{id}', timeout: Duration(seconds: 10))
  Future<Response<User?>> get(@Path() int id);

  @Get(path: '/{id}/albums', timeout: Duration(seconds: 10))
  Future<Response<List<Album>>> getAlbums(@Path() int id);

  @Get(path: '/{id}/todos', timeout: Duration(seconds: 10))
  Future<Response<List<Todo>>> getTodos(@Path() int id);

  @Get(path: '/{id}/posts', timeout: Duration(seconds: 10))
  Future<Response<List<Article>>> getArticles(@Path() int id);

  @Post(path: '/', timeout: Duration(seconds: 10))
  Future<Response<User?>> post(@Body() User body);

  @Put(path: '/{id}', timeout: Duration(seconds: 10))
  Future<Response<User?>> put(@Path() int id, @Body() User body);

  @Patch(path: '/{id}', timeout: Duration(seconds: 10))
  Future<Response<User?>> patch(@Path() int id, @Body() User body);

  @Delete(path: '/{id}', timeout: Duration(seconds: 10))
  Future<Response<void>> delete(@Path() int id);
}
