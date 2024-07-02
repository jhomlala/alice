

import 'package:alice/model/alice_http_error.dart';
import 'package:alice/model/alice_http_request.dart';
import 'package:alice/model/alice_http_response.dart';
import 'package:equatable/equatable.dart';

/// Definition of http calls data holder.
class AliceHttpCall with EquatableMixin {
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
  List<Object?> get props => [
        id,
        createdTime,
        client,
        loading,
        secure,
        method,
        endpoint,
        server,
        uri,
        duration,
        request,
        response,
        error
      ];
}
