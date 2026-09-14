import 'dart:async';
import 'package:alice/alice.dart';
import 'package:alice/core/alice_adapter.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_http_request.dart';
import 'package:alice/model/alice_http_response.dart';
import 'package:gql_link/gql_link.dart';
import 'package:gql_exec/gql_exec.dart';

class AliceGraphQLLink extends Link with AliceAdapter {
  AliceGraphQLLink(Alice alice) {
    alice.addAdapter(this);
  }

  @override
  Stream<Response> request(Request request, [NextLink? forward]) {
    final operationName = request.operation.operationName ?? 'UnknownOperation';
    
    final id = DateTime.now().millisecondsSinceEpoch;
    final call = AliceHttpCall(id);
    call.method = 'POST';
    call.endpoint = 'GraphQL';
    call.request = AliceHttpRequest();
    call.request!.body = request.operation.document.toString();
    call.request!.queryParameters = {'op': operationName};
    call.request!.time = DateTime.now();

    aliceCore.addCall(call);

    return forward!(request).map((response) {
      call.response = AliceHttpResponse();
      call.response!.body = response.data;
      call.response!.status = 200;
      call.response!.time = DateTime.now();
      
      aliceCore.addResponse(call.response!, id);
      return response;
    });
  }
}
