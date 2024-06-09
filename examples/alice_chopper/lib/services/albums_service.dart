import 'package:chopper/chopper.dart';
import 'package:example/models/album.dart';
import 'package:example/models/photo.dart';

part 'albums_service.chopper.dart';

@ChopperApi(baseUrl: '/albums')
abstract class AlbumsService extends ChopperService {
  static AlbumsService create([ChopperClient? client]) =>
      _$AlbumsService(client);

  @Get(path: '/', timeout: Duration(seconds: 10))
  Future<Response<List<Album>>> getAll({
    @Query('userId') int? userId,
  });

  @Get(path: '/{id}', timeout: Duration(seconds: 10))
  Future<Response<Album?>> get(@Path() int id);

  @Get(path: '/{id}/photos', timeout: Duration(seconds: 10))
  Future<Response<List<Photo>>> getPhotos(@Path() int id);

  @Post(path: '/', timeout: Duration(seconds: 10))
  Future<Response<Album?>> post(@Body() Album body);

  @Put(path: '/{id}', timeout: Duration(seconds: 10))
  Future<Response<Album?>> put(@Path() int id, @Body() Album body);

  @Patch(path: '/{id}', timeout: Duration(seconds: 10))
  Future<Response<Album?>> patch(@Path() int id, @Body() Album body);

  @Delete(path: '/{id}', timeout: Duration(seconds: 10))
  Future<Response<void>> delete(@Path() int id);
}
