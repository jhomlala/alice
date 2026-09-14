import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'post.dart';

part 'rest_client.g.dart';

@RestApi(baseUrl: "https://jsonplaceholder.typicode.com/")
abstract class RestClient {
  factory RestClient(Dio dio, {String baseUrl}) = _RestClient;

  @GET("/posts/{id}")
  Future<Post> getPost(@Path("id") int id);
}
