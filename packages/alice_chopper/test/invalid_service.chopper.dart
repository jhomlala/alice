// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invalid_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$InvalidService extends InvalidService {
  _$InvalidService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = InvalidService;

  @override
  Future<Response<InvalidModel>> get(int id) {
    final Uri $url = Uri.parse('/posts/${id}');
    final Request $request = Request('GET', $url, client.baseUrl);
    return client
        .send<InvalidModel, InvalidModel>($request)
        .timeout(const Duration(microseconds: 10000000));
  }
}
