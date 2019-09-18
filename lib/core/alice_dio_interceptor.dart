import 'dart:convert';

import 'package:alice/core/alice_core.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_http_error.dart';
import 'package:alice/model/alice_http_request.dart';
import 'package:alice/model/alice_http_response.dart';
import 'package:dio/dio.dart';

class AliceDioInterceptor extends InterceptorsWrapper {
  AliceCore _aliceCore;

  AliceDioInterceptor(AliceCore aliceCore) {
    _aliceCore = aliceCore;
  }

  @override
  onRequest(RequestOptions options) {
    AliceHttpCall call = new AliceHttpCall(options.hashCode);

    Uri uri = options.uri;
    call.method = options.method;
    var path = options.uri.path;
    if (path == null || path.length == 0) {
      path = "/";
    }
    call.endpoint = path;
    call.server = uri.host;
    call.client = "Dio";

    if (uri.scheme == "https") {
      call.secure = true;
    }

    AliceHttpRequest request = AliceHttpRequest();

    if (options.data == null) {
      request.size = 0;
      request.body = "";
    } else {
      request.size = utf8.encode(options.data.toString()).length;
      request.body = options.data;
    }
    request.time = DateTime.now();
    request.headers = options.headers;
    request.contentType = options.contentType.toString();
    request.queryParameters = options.queryParameters;

    call.request = request;
    call.response = AliceHttpResponse();

    _aliceCore.addCall(call);
    return super.onRequest(options);
  }

  @override
  onResponse(Response response) {
    var httpResponse = AliceHttpResponse();
    httpResponse.status = response.statusCode;

    if (response.data == null) {
      httpResponse.body = "";
      httpResponse.size = 0;
    } else {
      httpResponse.body = response.data;
      httpResponse.size = utf8.encode(response.data.toString()).length;
    }

    httpResponse.time = DateTime.now();
    Map<String, String> headers = Map();
    if (response.headers != null) {
      response.headers.forEach((header, values) {
        headers[header] = values.toString();
      });
    }
    httpResponse.headers = headers;

    _aliceCore.addResponse(httpResponse, response.request.hashCode);
    return super.onResponse(response);
  }

  @override
  onError(DioError err) {
    var httpError = AliceHttpError();
    httpError.error = err.toString();
    if (err is Error){
      var error = err as Error;
      httpError.stackTrace = error.stackTrace;
    }

    _aliceCore.addError(httpError, err.request.hashCode);
    var httpResponse = AliceHttpResponse();
    httpResponse.time = DateTime.now();
    if (err.response == null) {
      httpResponse.status = -1;
      _aliceCore.addResponse(httpResponse, err.request.hashCode);
    } else {
      httpResponse.status = err.response.statusCode;

      if (err.response.data == null) {
        httpResponse.body = "";
        httpResponse.size = 0;
      } else {
        httpResponse.body = err.response.data;
        httpResponse.size = utf8.encode(err.response.data.toString()).length;
      }
      Map<String, String> headers = Map();
      if (err.response.headers != null) {
        err.response.headers.forEach((header, values) {
          headers[header] = values.toString();
        });
      }
      httpResponse.headers = headers;
      _aliceCore.addResponse(httpResponse, err.response.request.hashCode);
    }

    return super.onError(err);
  }
}
