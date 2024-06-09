import 'package:chopper/chopper.dart';
import 'package:example/models/photo.dart';

part 'photos_service.chopper.dart';

@ChopperApi(baseUrl: '/photos')
abstract class PhotosService extends ChopperService {
  static PhotosService create([ChopperClient? client]) =>
      _$PhotosService(client);

  @Get(path: '/', timeout: Duration(seconds: 10))
  Future<Response<List<Photo>>> getAll({
    @Query('albumId') int? albumId,
  });

  @Get(path: '/{id}', timeout: Duration(seconds: 10))
  Future<Response<Photo?>> get(@Path() int id);

  @Post(path: '/', timeout: Duration(seconds: 10))
  Future<Response<Photo?>> post(@Body() Photo body);

  @Put(path: '/{id}', timeout: Duration(seconds: 10))
  Future<Response<Photo?>> put(@Path() int id, @Body() Photo body);

  @Patch(path: '/{id}', timeout: Duration(seconds: 10))
  Future<Response<Photo?>> patch(@Path() int id, @Body() Photo body);

  @Delete(path: '/{id}', timeout: Duration(seconds: 10))
  Future<Response<void>> delete(@Path() int id);
}
