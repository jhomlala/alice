import 'dart:convert';

import 'package:alice/export/alice_exporter.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_http_request.dart';
import 'package:material_ui/material_ui.dart';
import 'package:alice/services/package_info/package_info_provider.dart';

class AliceHarExporter implements AliceExporter {
  @override
  String get fileExtension => 'har';

  @override
  Future<String> generate({
    required BuildContext? context,
    required List<AliceHttpCall> calls,
  }) async {
    final packageInfo = await PackageInfoProvider.getPackageInfo();

    final Map<String, dynamic> har = {
      'log': {
        'version': '1.2',
        'creator': {'name': 'Alice', 'version': packageInfo.version},
        'entries': calls.map(_mapCallToEntry).toList(),
      },
    };

    return const JsonEncoder.withIndent('  ').convert(har);
  }

  Map<String, dynamic> _mapCallToEntry(AliceHttpCall call) {
    final request = call.request;
    final response = call.response;

    return {
      'startedDateTime': call.createdTime.toUtc().toIso8601String(),
      'time': call.duration,
      'request': {
        'method': call.method,
        'url': call.uri,
        'httpVersion': 'HTTP/1.1',
        'cookies': request?.cookies.map((c) => c.toJson()).toList() ?? [],
        'headers':
            request?.headers.entries
                .map((e) => {'name': e.key, 'value': e.value})
                .toList() ??
            [],
        'queryString':
            request?.queryParameters.entries
                .map((e) => {'name': e.key, 'value': e.value.toString()})
                .toList() ??
            [],
        'postData': _getPostData(request),
        'headersSize': -1,
        'bodySize': request?.size ?? -1,
      },
      'response': {
        'status': response?.status ?? 0,
        'statusText': _getStatusText(response?.status),
        'httpVersion': 'HTTP/1.1',
        'cookies':
            [], // Alice does not currently track response cookies separately
        'headers':
            response?.headers?.entries
                .map((e) => {'name': e.key, 'value': e.value})
                .toList() ??
            [],
        'content': {
          'size': response?.size ?? 0,
          'mimeType':
              response?.headers?['content-type'] ?? 'application/octet-stream',
          'text': _convertBodyToString(response?.body),
        },
        'redirectURL': response?.headers?['location'] ?? '',
        'headersSize': -1,
        'bodySize': response?.size ?? -1,
      },
      'cache': {},
      'timings': {
        'send': 0,
        'wait': call.duration,
        'receive': 0,
        'dns': -1,
        'connect': -1,
        'ssl': -1,
      },
    };
  }

  Map<String, dynamic>? _getPostData(AliceHttpRequest? request) {
    if (request == null || request.body == null || request.body == '') {
      return null;
    }

    return {
      'mimeType': request.contentType ?? 'application/octet-stream',
      'text': _convertBodyToString(request.body),
    };
  }

  String _convertBodyToString(dynamic body) {
    if (body == null) return '';
    if (body is String) return body;
    try {
      return jsonEncode(body);
    } catch (_) {
      return body.toString();
    }
  }

  String _getStatusText(int? status) {
    switch (status) {
      case 200:
        return 'OK';
      case 201:
        return 'Created';
      case 204:
        return 'No Content';
      case 400:
        return 'Bad Request';
      case 401:
        return 'Unauthorized';
      case 403:
        return 'Forbidden';
      case 404:
        return 'Not Found';
      case 500:
        return 'Internal Server Error';
      default:
        return '';
    }
  }
}
