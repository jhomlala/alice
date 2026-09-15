import 'dart:async';
import 'dart:convert';

import 'package:alice/alice.dart';
import 'package:alice/core/alice_adapter.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_http_error.dart';
import 'package:alice/model/alice_http_request.dart';
import 'package:alice/model/alice_http_response.dart';
import 'package:gql_link/gql_link.dart';
import 'package:gql_exec/gql_exec.dart';
import 'package:gql/language.dart';
import 'package:gql/ast.dart';

class AliceGraphQLLink extends Link with AliceAdapter {
  AliceGraphQLLink({required Alice alice, this.url}) {
    alice.addAdapter(this);
  }

  final String? url;

  String _getOperationName(Request request) {
    if (request.operation.operationName != null) {
      return request.operation.operationName!;
    }
    try {
      final definition =
          request.operation.document.definitions
              .whereType<OperationDefinitionNode>()
              .first;
      if (definition.name != null) {
        return definition.name!.value;
      }
      final selections =
          definition.selectionSet.selections.whereType<FieldNode>();
      final firstSelection = selections.firstWhere(
        (sel) => sel.name.value != '__typename',
        orElse: () => selections.first,
      );
      return firstSelection.name.value;
    } catch (_) {
      return 'UnknownOperation';
    }
  }

  @override
  Stream<Response> request(Request request, [NextLink? forward]) {
    final id = DateTime.now().millisecondsSinceEpoch;
    final call = AliceHttpCall(id);

    try {
      final operationName = _getOperationName(request);

      call.method = 'POST';
      call.client = 'GraphQL';
      if (url != null) {
        final uri = Uri.tryParse(url!);
        if (uri != null) {
          call.server = uri.host;

          final path = uri.path == '/' || uri.path.isEmpty ? '' : uri.path;
          call.endpoint =
              path.isEmpty ? operationName : '$path / $operationName';

          call.uri = url!;
        } else {
          call.server = url!;
          call.endpoint = operationName;
          call.uri = url!;
        }
      } else {
        call.server = 'GraphQL';
        call.endpoint = operationName;
      }
      call.request = AliceHttpRequest();
      final queryStr = printNode(request.operation.document);
      final Map<String, dynamic> requestBody = {
        'query': queryStr,
        'variables': request.variables,
        'operationName': operationName,
      };
      final bodyStr = jsonEncode(requestBody);
      call.request!.body = bodyStr;
      call.request!.size = utf8.encode(bodyStr).length;
      call.request!.contentType = 'application/json';
      call.request!.headers = {'content-type': 'application/json'};
      call.request!.queryParameters = {'op': operationName};
      call.request!.time = DateTime.now();

      aliceCore.addCall(call);
    } catch (e) {
      // ignore
    }

    return forward!(request)
        .map((response) {
          try {
            call.response = AliceHttpResponse();

            final Map<String, dynamic> responseBody = {};
            if (response.data != null) responseBody['data'] = response.data;
            if (response.errors != null && response.errors!.isNotEmpty) {
              responseBody['errors'] =
                  response.errors!
                      .map((e) => e.message)
                      .toList(); // Or e.toJson() if available, but message is safe
            }

            call.response!.body = responseBody;
            call.response!.size = utf8.encode(jsonEncode(responseBody)).length;

            call.response!.headers = {'content-type': 'application/json'};
            call.response!.status =
                response.errors != null && response.errors!.isNotEmpty
                    ? 400
                    : 200; // Optionally indicate error in status
            call.response!.time = DateTime.now();

            aliceCore.addResponse(call.response!, id);
          } catch (e) {
            // ignore
          }
          return response;
        })
        .handleError((Object error, StackTrace stackTrace) {
          try {
            final aliceError = AliceHttpError();
            aliceError.error = error;
            aliceError.stackTrace = stackTrace;
            aliceCore.addError(aliceError, id);

            final httpResponse =
                AliceHttpResponse()
                  ..time = DateTime.now()
                  ..status = -1;
            aliceCore.addResponse(httpResponse, id);
          } catch (e) {
            // ignore
          }
          throw error;
        });
  }
}
