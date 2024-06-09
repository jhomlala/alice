// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'example_posts_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$ExamplePostsService extends ExamplePostsService {
  _$ExamplePostsService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = ExamplePostsService;

  @override
  Future<Response<List<ExamplePost>>> getPosts({int? userId}) {
    final Uri $url = Uri.parse('/posts/');
    final Map<String, dynamic> $params = <String, dynamic>{'userId': userId};
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client
        .send<List<ExamplePost>, ExamplePost>($request)
        .timeout(const Duration(microseconds: 10000000));
  }

  @override
  Future<Response<ExamplePost>> getPost(int id) {
    final Uri $url = Uri.parse('/posts/${id}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<ExamplePost, ExamplePost>($request)
        .timeout(const Duration(microseconds: 10000000));
  }

  @override
  Future<Response<ExamplePost>> createPost(ExamplePost body) {
    final Uri $url = Uri.parse('/posts/');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client
        .send<ExamplePost, ExamplePost>($request)
        .timeout(const Duration(microseconds: 10000000));
  }

  @override
  Future<Response<ExamplePost>> putPost(
    int id,
    ExamplePost body,
  ) {
    final Uri $url = Uri.parse('/posts/${id}');
    final $body = body;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client
        .send<ExamplePost, ExamplePost>($request)
        .timeout(const Duration(microseconds: 10000000));
  }

  @override
  Future<Response<ExamplePost>> patchPost(
    int id,
    ExamplePost body,
  ) {
    final Uri $url = Uri.parse('/posts/${id}');
    final $body = body;
    final Request $request = Request(
      'PATCH',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client
        .send<ExamplePost, ExamplePost>($request)
        .timeout(const Duration(microseconds: 10000000));
  }

  @override
  Future<Response<void>> deletePost(int id) {
    final Uri $url = Uri.parse('/posts/${id}');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
    );
    return client
        .send<void, void>($request)
        .timeout(const Duration(microseconds: 10000000));
  }
}
