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
  Future<Response<ExamplePost>> getExamplePost(String id) {
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
  Future<Response<ExamplePost>> createExamplePost(ExamplePost body) {
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
  Future<Response<ExamplePost>> updateExamplePost(
    String id,
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
  Future<Response<void>> deleteExamplePost(String id) {
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
