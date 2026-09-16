import 'dart:convert' show utf8;
import 'dart:io' show HttpClient, HttpClientRequest, HttpClientResponse;
import 'package:alice/core/alice_core.dart';
import 'package:alice/helper/alice_replay_helper.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_http_error.dart';
import 'package:alice/model/alice_http_request.dart';
import 'package:alice/model/alice_http_response.dart';
import 'package:alice/ui/common/alice_dialog.dart';
import 'package:flutter/material.dart';

AliceReplayHelper getReplayHelper(AliceCore core) => AliceReplayHelperImpl(core);

class AliceReplayHelperImpl implements AliceReplayHelper {
  final AliceCore core;

  AliceReplayHelperImpl(this.core);

  @override
  Future<void> replayCall({
    required AliceHttpCall originalCall,
    required BuildContext context,
  }) async {
    if (originalCall.request?.formDataFiles != null &&
        originalCall.request!.formDataFiles!.isNotEmpty) {
      AliceGeneralDialog.show(
        context: context,
        title: 'Error',
        description: 'Multipart/FormData replays are not yet supported.',
      );
      return;
    }

    final int newId = DateTime.now().millisecondsSinceEpoch;
    final AliceHttpCall newCall = AliceHttpCall(newId)
      ..client = originalCall.client
      ..method = originalCall.method
      ..endpoint = originalCall.endpoint
      ..server = originalCall.server
      ..uri = originalCall.uri
      ..secure = originalCall.secure
      ..isReplay = true;

    final AliceHttpRequest newRequest = AliceHttpRequest()
      ..time = DateTime.now()
      ..contentType = originalCall.request?.contentType
      ..headers = Map<String, String>.from(originalCall.request?.headers ?? {})
      ..queryParameters = Map<String, dynamic>.from(originalCall.request?.queryParameters ?? {})
      ..body = originalCall.request?.body;

    newCall.request = newRequest;
    await core.addCall(newCall);

    final Stopwatch stopwatch = Stopwatch()..start();

    try {
      final HttpClient httpClient = HttpClient();
      final Uri parsedUri = Uri.parse(originalCall.uri);
      HttpClientRequest request;
      
      switch (originalCall.method.toUpperCase()) {
        case 'GET':
          request = await httpClient.getUrl(parsedUri);
          break;
        case 'POST':
          request = await httpClient.postUrl(parsedUri);
          break;
        case 'PUT':
          request = await httpClient.putUrl(parsedUri);
          break;
        case 'DELETE':
          request = await httpClient.deleteUrl(parsedUri);
          break;
        case 'PATCH':
          request = await httpClient.patchUrl(parsedUri);
          break;
        case 'HEAD':
          request = await httpClient.headUrl(parsedUri);
          break;
        default:
          request = await httpClient.openUrl(originalCall.method, parsedUri);
          break;
      }

      newRequest.headers.forEach((key, value) {
        if (key.toLowerCase() != 'content-length') {
          request.headers.set(key, value);
        }
      });

      if (newRequest.body != null &&
          newRequest.body.toString().isNotEmpty &&
          ['POST', 'PUT', 'PATCH', 'DELETE'].contains(originalCall.method.toUpperCase())) {
        if (newRequest.body is String) {
          request.write(newRequest.body);
        } else if (newRequest.body is List<int>) {
          request.add(newRequest.body);
        } else {
          request.write(newRequest.body.toString());
        }
      }

      final HttpClientResponse response = await request.close();
      stopwatch.stop();

      final List<int> responseBytes = await response.fold<List<int>>([], (buffer, chunk) => buffer..addAll(chunk));
      String responseBody = '';
      try {
        responseBody = utf8.decode(responseBytes);
      } catch (_) {
        responseBody = responseBytes.toString();
      }

      final Map<String, String> responseHeaders = {};
      response.headers.forEach((name, values) {
        responseHeaders[name] = values.join(', ');
      });

      final AliceHttpResponse aliceResponse = AliceHttpResponse()
        ..status = response.statusCode
        ..time = DateTime.now()
        ..size = responseBytes.length
        ..headers = responseHeaders
        ..body = responseBody;

      newCall.duration = stopwatch.elapsedMilliseconds;
      newCall.loading = false;
      await core.addResponse(aliceResponse, newId);

      if (context.mounted) {
        AliceGeneralDialog.show(
          context: context,
          title: 'Success',
          description: 'Request replayed successfully',
        );
      }
    } catch (error, stackTrace) {
      stopwatch.stop();
      newCall.duration = stopwatch.elapsedMilliseconds;
      newCall.loading = false;
      
      final AliceHttpError aliceError = AliceHttpError()
        ..error = error
        ..stackTrace = stackTrace;

      await core.addError(aliceError, newId);

      if (context.mounted) {
        AliceGeneralDialog.show(
          context: context,
          title: 'Error',
          description: 'Replay failed: $error',
        );
      }
    }
  }
}
