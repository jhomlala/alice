import 'dart:convert';

import 'package:alice/core/alice_core.dart';
import 'package:alice/model/alice_form_data_file.dart';
import 'package:alice/model/alice_from_data_field.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_http_error.dart';
import 'package:alice/model/alice_http_request.dart';
import 'package:alice/model/alice_http_response.dart';
import 'package:dio/dio.dart';

class AliceDioInterceptor extends InterceptorsWrapper {
  /// AliceCore instance
  final AliceCore aliceCore;
  final Dio? retryDio;

  /// Creates dio interceptor
  AliceDioInterceptor(this.aliceCore, {this.retryDio});

  /// Handles dio request and creates alice http call based on it
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final AliceHttpCall call = AliceHttpCall(options.hashCode);

    final Uri uri = options.uri;
    call.method = options.method;
    var path = options.uri.path;
    if (path.isEmpty) {
      path = "/";
    }
    call.endpoint = path;
    call.server = uri.host;
    call.client = "Dio";
    call.uri = options.uri.toString();

    if (uri.scheme == "https") {
      call.secure = true;
    }

    final AliceHttpRequest request = AliceHttpRequest();

    final dynamic data = options.data;
    if (data == null) {
      request.size = 0;
      request.body = "";
    } else {
      if (data is FormData) {
        request.body += "Form data";

        if (data.fields.isNotEmpty == true) {
          final List<AliceFormDataField> fields = [];
          data.fields.forEach((entry) {
            fields.add(AliceFormDataField(entry.key, entry.value));
          });
          request.formDataFields = fields;
        }
        if (data.files.isNotEmpty == true) {
          final List<AliceFormDataFile> files = [];
          data.files.forEach((entry) {
            files.add(
              AliceFormDataFile(
                key: entry.key,
                fileName: entry.value.filename,
                contentType: entry.value.contentType.toString(),
                length: entry.value.length,
              ),
            );
          });

          request.formDataFiles = files;
        }
      } else {
        request.size = utf8.encode(data.toString()).length;
        request.body = data;
      }
    }
    final parentCall = options.extra['parent_call'] as AliceHttpCall?;
    if (parentCall != null) {
      aliceCore.removeCall(parentCall);
    }
    request.time = DateTime.now();
    request.headers = options.headers;
    request.contentType = options.contentType.toString();
    request.queryParameters = options.queryParameters;

    call.request = request;
    call.response = AliceHttpResponse();
    final isSupportRetryCallBack =
        retryDio != null && !(options.data is FormData);

    call.retryCallBack = isSupportRetryCallBack
        ? () {
            retryDio?.request<dynamic>(options.path,
                data: options.data,
                queryParameters: options.queryParameters,
                onReceiveProgress: options.onReceiveProgress,
                onSendProgress: options.onSendProgress,
                cancelToken: options.cancelToken,
                options: Options(
                    method: options.method,
                    sendTimeout: options.sendTimeout,
                    receiveTimeout: options.receiveTimeout,
                    extra: <String, dynamic>{
                      ...options.extra,
                      'parent_call': call
                    },
                    headers: options.headers,
                    responseType: options.responseType,
                    contentType: options.contentType,
                    validateStatus: options.validateStatus,
                    receiveDataWhenStatusError:
                        options.receiveDataWhenStatusError,
                    maxRedirects: options.maxRedirects,
                    followRedirects: options.followRedirects,
                    requestEncoder: options.requestEncoder,
                    responseDecoder: options.responseDecoder,
                    listFormat: options.listFormat));
          }
        : null;
    aliceCore.addCall(
      call,
    );
    handler.next(options);
  }

  /// Handles dio response and adds data to alice http call
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final httpResponse = AliceHttpResponse();
    httpResponse.status = response.statusCode;

    if (response.data == null) {
      httpResponse.body = "";
      httpResponse.size = 0;
    } else {
      httpResponse.body = response.data;
      httpResponse.size = utf8.encode(response.data.toString()).length;
    }

    httpResponse.time = DateTime.now();
    final Map<String, String> headers = {};
    response.headers.forEach((header, values) {
      headers[header] = values.toString();
    });
    httpResponse.headers = headers;

    aliceCore.addResponse(httpResponse, response.requestOptions.hashCode);
    handler.next(response);
  }

  /// Handles error and adds data to alice http call
  @override
  void onError(DioError error, ErrorInterceptorHandler handler) {
    final httpError = AliceHttpError();
    httpError.error = error.toString();
    if (error is Error) {
      final basicError = error as Error;
      httpError.stackTrace = basicError.stackTrace;
    }

    aliceCore.addError(httpError, error.requestOptions.hashCode);
    final httpResponse = AliceHttpResponse();
    httpResponse.time = DateTime.now();
    if (error.response == null) {
      httpResponse.status = -1;
      aliceCore.addResponse(httpResponse, error.requestOptions.hashCode);
    } else {
      httpResponse.status = error.response!.statusCode;

      if (error.response!.data == null) {
        httpResponse.body = "";
        httpResponse.size = 0;
      } else {
        httpResponse.body = error.response!.data;
        httpResponse.size = utf8.encode(error.response!.data.toString()).length;
      }
      final Map<String, String> headers = {};
      error.response!.headers.forEach((header, values) {
        headers[header] = values.toString();
      });
      httpResponse.headers = headers;
      aliceCore.addResponse(
        httpResponse,
        error.response!.requestOptions.hashCode,
      );
    }
    handler.next(error);
  }
}
