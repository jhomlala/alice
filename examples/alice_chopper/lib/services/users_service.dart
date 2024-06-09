import 'package:chopper/chopper.dart';
import 'package:example/models/user.dart';

part 'users_service.chopper.dart';

@ChopperApi(baseUrl: '/users')
abstract class UsersService extends ChopperService {
  static UsersService create([ChopperClient? client]) => _$UsersService(client);

  @Get(path: '/', timeout: Duration(seconds: 10))
  Future<Response<List<User>>> getAll();

  @Get(path: '/{id}', timeout: Duration(seconds: 10))
  Future<Response<User?>> get(@Path() int id);

  @Post(path: '/', timeout: Duration(seconds: 10))
  Future<Response<User?>> post(@Body() User body);

  @Put(path: '/{id}', timeout: Duration(seconds: 10))
  Future<Response<User?>> put(@Path() int id, @Body() User body);

  @Patch(path: '/{id}', timeout: Duration(seconds: 10))
  Future<Response<User?>> patch(@Path() int id, @Body() User body);

  @Delete(path: '/{id}', timeout: Duration(seconds: 10))
  Future<Response<void>> delete(@Path() int id);
}
