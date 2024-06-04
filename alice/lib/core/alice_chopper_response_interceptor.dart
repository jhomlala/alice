import 'dart:async';
import 'dart:convert';

import 'package:alice/core/alice_core.dart';
import 'package:alice/core/alice_utils.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_http_request.dart';
import 'package:alice/model/alice_http_response.dart';
import 'package:chopper/chopper.dart' as chopper;
import 'package:http/http.dart';

class AliceChopperInterceptor
    implements chopper.ResponseInterceptor, chopper.RequestInterceptor {
  /// AliceCore instance
  final AliceCore aliceCore;

  /// Creates instance of chopper interceptor
  AliceChopperInterceptor(this.aliceCore);

  /// Creates hashcode based on request
  int getRequestHashCode(BaseRequest baseRequest) {
    var hashCodeSum = 0;
    hashCodeSum += baseRequest.url.hashCode;
    hashCodeSum += baseRequest.method.hashCode;
    if (baseRequest.headers.isNotEmpty) {
      baseRequest.headers.forEach((key, value) {
        hashCodeSum += key.hashCode;
        hashCodeSum += value.hashCode;
      });
    }
    if (baseRequest.contentLength != null) {
      hashCodeSum += baseRequest.contentLength.hashCode;
    }

    return hashCodeSum.hashCode;
  }

  /// Handles chopper request and creates alice http call
  @override
  FutureOr<chopper.Request> onRequest(chopper.Request request) async {
    try {
      final headers = request.headers;
      headers['alice_token'] = DateTime.now().millisecondsSinceEpoch.toString();
      final changedRequest = request.copyWith(headers: headers);
      final baseRequest = await changedRequest.toBaseRequest();

      final call = AliceHttpCall(getRequestHashCode(baseRequest));
      var endpoint = '';
      var server = '';

      final split = request.url.toString().split('/');
      if (split.length > 2) {
        server = split[1] + split[2];
      }
      if (split.length > 4) {
        endpoint = '/';
        for (var splitIndex = 3; splitIndex < split.length; splitIndex++) {
          // ignore: use_string_buffers
          endpoint += '${split[splitIndex]}/';
        }
        endpoint = endpoint.substring(0, endpoint.length - 1);
      }

      call
        ..method = request.method
        ..endpoint = endpoint
        ..server = server
        ..client = 'Chopper';
      if (request.url.toString().contains('https')) {
        call.secure = true;
      }

      final aliceHttpRequest = AliceHttpRequest();

      if (request.body == null) {
        aliceHttpRequest
          ..size = 0
          ..body = '';
      } else {
        aliceHttpRequest
          ..size = utf8.encode(request.body as String).length
          ..body = request.body;
      }
      aliceHttpRequest
        ..time = DateTime.now()
        ..headers = request.headers;

      String? contentType = 'unknown';
      if (request.headers.containsKey('Content-Type')) {
        contentType = request.headers['Content-Type'];
      }
      aliceHttpRequest
        ..contentType = contentType
        ..queryParameters = request.parameters;

      call
        ..request = aliceHttpRequest
        ..response = AliceHttpResponse();

      aliceCore.addCall(call);
    } catch (exception) {
      AliceUtils.log(exception.toString());
    }
    return request;
  }

  /// Handles chopper response and adds data to existing alice http call
  @override
  // ignore: strict_raw_type
  FutureOr<chopper.Response> onResponse(chopper.Response response) {
    final httpResponse = AliceHttpResponse()..status = response.statusCode;
    if (response.body == null) {
      httpResponse
        ..body = ''
        ..size = 0;
    } else {
      httpResponse
        ..body = response.body
        ..size = utf8.encode(response.body.toString()).length;
    }

    httpResponse.time = DateTime.now();
    final headers = <String, String>{};
    response.headers.forEach((header, values) {
      headers[header] = values;
    });
    httpResponse.headers = headers;

    aliceCore.addResponse(
      httpResponse,
      getRequestHashCode(response.base.request!),
    );
    return response;
  }
}
