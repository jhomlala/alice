import 'package:alice/model/alice_http_error.dart';
import 'package:alice/model/alice_http_request.dart';
import 'package:alice/model/alice_http_response.dart';

/// Definition of http calls data holder.
class AliceHttpCall {
  AliceHttpCall(this.id) {
    loading = true;
    createdTime = DateTime.now();
  }

  final int id;
  late DateTime createdTime;
  String client = '';
  bool loading = true;
  bool secure = false;
  String method = '';
  String endpoint = '';
  String server = '';
  String uri = '';
  int duration = 0;

  AliceHttpRequest? request;
  AliceHttpResponse? response;
  AliceHttpError? error;

  void setResponse(AliceHttpResponse response) {
    this.response = response;
    loading = false;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AliceHttpCall &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          createdTime == other.createdTime &&
          client == other.client &&
          loading == other.loading &&
          secure == other.secure &&
          method == other.method &&
          endpoint == other.endpoint &&
          server == other.server &&
          uri == other.uri &&
          duration == other.duration &&
          request == other.request &&
          response == other.response &&
          error == other.error;

  @override
  int get hashCode =>
      id.hashCode ^
      createdTime.hashCode ^
      client.hashCode ^
      loading.hashCode ^
      secure.hashCode ^
      method.hashCode ^
      endpoint.hashCode ^
      server.hashCode ^
      uri.hashCode ^
      duration.hashCode ^
      request.hashCode ^
      response.hashCode ^
      error.hashCode;

  @override
  String toString() {
    return 'AliceHttpCall{id: $id, createdTime: $createdTime, client: $client,'
        ' loading: $loading, secure: $secure, method: $method, endpoint: '
        '$endpoint, server: $server, uri: $uri, duration: $duration, '
        'request: $request, response: $response, error: $error}';
  }
}
