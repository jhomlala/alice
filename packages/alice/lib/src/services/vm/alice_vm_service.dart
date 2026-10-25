import 'dart:convert';
import 'dart:developer' as developer;

import 'package:alice/src/core/alice_core.dart';
import 'package:flutter/foundation.dart';

/// Registers and routes Dart VM Service extensions for Alice in debug mode.
class AliceVmService {
  static bool _registered = false;
  static AliceCore? _activeCore;

  /// Registers `ext.alice.*` extensions once per isolate.
  static void register(AliceCore core) {
    _activeCore = core;

    if (!kDebugMode || _registered) {
      return;
    }

    _registered = true;

    developer.registerExtension('ext.alice.getCalls', (
      method,
      parameters,
    ) async {
      final targetCore = _activeCore;
      if (targetCore == null) {
        return developer.ServiceExtensionResponse.error(
          developer.ServiceExtensionResponse.extensionError,
          'AliceCore is not active',
        );
      }

      final calls = targetCore.getCalls();
      final statusFilter = int.tryParse(parameters['status'] ?? '');
      final methodFilter = parameters['method']?.toUpperCase();
      final searchFilter = parameters['search']?.toLowerCase();
      final limit = int.tryParse(parameters['limit'] ?? '') ?? 50;

      final filtered = calls
          .where((c) {
            if (statusFilter != null && c.response?.status != statusFilter) {
              return false;
            }
            if (methodFilter != null &&
                c.method.toUpperCase() != methodFilter) {
              return false;
            }
            if (searchFilter != null) {
              final uriMatch = c.uri.toLowerCase().contains(searchFilter);
              final endpointMatch = c.endpoint.toLowerCase().contains(
                searchFilter,
              );
              if (!uriMatch && !endpointMatch) {
                return false;
              }
            }
            return true;
          })
          .take(limit);

      final result = filtered
          .map(
            (c) => {
              'id': c.id,
              'createdTime': c.createdTime.toIso8601String(),
              'client': c.client,
              'method': c.method,
              'server': c.server,
              'endpoint': c.endpoint,
              'uri': c.uri,
              'status': c.response?.status,
              'duration': c.duration,
              'loading': c.loading,
              'isReplay': c.isReplay,
              'isDuplicate': c.isDuplicate,
              'tag': c.tag,
              'hasError': c.error != null,
            },
          )
          .toList();

      return developer.ServiceExtensionResponse.result(
        jsonEncode({'result': result}, toEncodable: (o) => o.toString()),
      );
    });

    developer.registerExtension('ext.alice.getCallDetails', (
      method,
      parameters,
    ) async {
      final targetCore = _activeCore;
      if (targetCore == null) {
        return developer.ServiceExtensionResponse.error(
          developer.ServiceExtensionResponse.extensionError,
          'AliceCore is not active',
        );
      }

      final id = int.tryParse(parameters['id'] ?? '');
      if (id == null) {
        return developer.ServiceExtensionResponse.error(
          developer.ServiceExtensionResponse.invalidParams,
          'Missing or invalid "id" parameter',
        );
      }

      final call = targetCore.getCalls().where((c) => c.id == id).firstOrNull;

      if (call == null) {
        return developer.ServiceExtensionResponse.error(
          developer.ServiceExtensionResponse.invalidParams,
          'Call with id $id not found',
        );
      }

      final result = {
        'id': call.id,
        'createdTime': call.createdTime.toIso8601String(),
        'client': call.client,
        'method': call.method,
        'server': call.server,
        'endpoint': call.endpoint,
        'uri': call.uri,
        'duration': call.duration,
        'secure': call.secure,
        'loading': call.loading,
        'isReplay': call.isReplay,
        'isDuplicate': call.isDuplicate,
        'tag': call.tag,
        'request': call.request == null
            ? null
            : {
                'time': call.request!.time.toIso8601String(),
                'headers': call.request!.headers,
                'queryParameters': call.request!.queryParameters,
                'contentType': call.request!.contentType,
                'size': call.request!.size,
                'body': call.request!.body,
              },
        'response': call.response == null
            ? null
            : {
                'time': call.response!.time.toIso8601String(),
                'status': call.response!.status,
                'headers': call.response!.headers,
                'size': call.response!.size,
                'body': call.response!.body,
              },
        'error': call.error == null
            ? null
            : {
                'error': call.error!.error?.toString(),
                'stackTrace': call.error!.stackTrace?.toString(),
              },
      };

      return developer.ServiceExtensionResponse.result(
        jsonEncode({'result': result}, toEncodable: (o) => o.toString()),
      );
    });

    developer.registerExtension('ext.alice.getStats', (
      method,
      parameters,
    ) async {
      final targetCore = _activeCore;
      if (targetCore == null) {
        return developer.ServiceExtensionResponse.error(
          developer.ServiceExtensionResponse.extensionError,
          'AliceCore is not active',
        );
      }

      final stats = targetCore.configuration.aliceStorage.getStats();
      return developer.ServiceExtensionResponse.result(
        jsonEncode({
          'result': {
            'total': stats.total,
            'successes': stats.successes,
            'redirects': stats.redirects,
            'errors': stats.errors,
            'loading': stats.loading,
          },
        }),
      );
    });

    developer.registerExtension('ext.alice.clearCalls', (
      method,
      parameters,
    ) async {
      final targetCore = _activeCore;
      if (targetCore == null) {
        return developer.ServiceExtensionResponse.error(
          developer.ServiceExtensionResponse.extensionError,
          'AliceCore is not active',
        );
      }

      await targetCore.removeCalls();
      return developer.ServiceExtensionResponse.result(
        jsonEncode({
          'result': {'cleared': true},
        }),
      );
    });

    developer.registerExtension('ext.alice.openInspector', (
      method,
      parameters,
    ) async {
      final targetCore = _activeCore;
      if (targetCore == null) {
        return developer.ServiceExtensionResponse.error(
          developer.ServiceExtensionResponse.extensionError,
          'AliceCore is not active',
        );
      }

      await targetCore.navigateToCallListScreen();
      return developer.ServiceExtensionResponse.result(
        jsonEncode({
          'result': {'opened': true},
        }),
      );
    });
  }
}
