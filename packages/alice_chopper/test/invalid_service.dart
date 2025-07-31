import 'package:chopper/chopper.dart';

import 'invalid_model.dart';

part 'invalid_service.chopper.dart';

@ChopperApi(baseUrl: '/posts')
abstract class InvalidService extends ChopperService {
  static InvalidService create([ChopperClient? client]) =>
      _$InvalidService(client);

  @GET(path: '/{id}', timeout: Duration(seconds: 10))
  Future<Response<InvalidModel?>> get(@Path() int id);
}
