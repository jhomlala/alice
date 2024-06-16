import 'dart:convert' show JsonEncoder;
import 'dart:io' show Directory, File, FileMode, IOSink, Platform;

import 'package:alice/core/alice_utils.dart';
import 'package:alice/helper/alice_alert_helper.dart';
import 'package:alice/helper/alice_conversion_helper.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/utils/alice_parser.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AliceSaveHelper {
  static const JsonEncoder _encoder = JsonEncoder.withIndent('  ');

  /// Top level method used to save calls to file
  static void saveCalls(
    BuildContext context,
    List<AliceHttpCall> calls,
  ) {
    _checkPermissions(context, calls);
  }

  static Future<bool> _getPermissionStatus() async {
    if (Platform.isAndroid || Platform.isIOS) {
      return Permission.storage.status.isGranted;
    } else {
      return true;
    }
  }

  static Future<bool> _requestPermission() async {
    if (Platform.isAndroid || Platform.isIOS) {
      return Permission.storage.request().isGranted;
    } else {
      return true;
    }
  }

  static Future<void> _checkPermissions(
    BuildContext context,
    List<AliceHttpCall> calls,
  ) async {
    final bool permissionStatus = await _getPermissionStatus();

    if (!context.mounted) return;

    if (permissionStatus) {
      await _saveToFile(context, calls);
    } else {
      final bool status = await _requestPermission();

      if (!context.mounted) return;

      if (status) {
        await _saveToFile(context, calls);
      } else {
        AliceAlertHelper.showAlert(
          context,
          'Permission error',
          "Permission not granted. Couldn't save logs.",
        );
      }
    }
  }

  static Future<String> _saveToFile(
    BuildContext context,
    List<AliceHttpCall> calls,
  ) async {
    try {
      if (calls.isEmpty) {
        AliceAlertHelper.showAlert(
          context,
          'Error',
          'There are no logs to save',
        );
        return '';
      }

      final Directory? externalDir = switch (Platform.operatingSystem) {
        "android" => await getExternalStorageDirectory(),
        "ios" => await getApplicationDocumentsDirectory(),
        _ => await getApplicationCacheDirectory(),
      };

      if (externalDir != null) {
        final String fileName =
            'alice_log_${DateTime.now().millisecondsSinceEpoch}.txt';
        final File file = File('${externalDir.path}/$fileName')..createSync();
        final IOSink sink = file.openWrite(mode: FileMode.append)
          ..write(await _buildAliceLog());
        for (final AliceHttpCall call in calls) {
          sink.write(_buildCallLog(call));
        }
        await sink.flush();
        await sink.close();

        if (context.mounted) {
          AliceAlertHelper.showAlert(
            context,
            'Success',
            'Successfully saved logs in ${file.path}',
            secondButtonTitle: Platform.isAndroid ? 'View file' : null,
            secondButtonAction: () =>
                Platform.isAndroid ? OpenFilex.open(file.path) : null,
          );
        }

        return file.path;
      } else {
        if (context.mounted) {
          AliceAlertHelper.showAlert(
            context,
            'Error',
            'Failed to save http calls to file',
          );
        }
      }
    } catch (exception) {
      if (context.mounted) {
        AliceAlertHelper.showAlert(
          context,
          'Error',
          'Failed to save http calls to file',
        );
        AliceUtils.log(exception.toString());
      }
    }

    return '';
  }

  static Future<String> _buildAliceLog() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();

    return 'Alice - HTTP Inspector\n'
        'App name:  ${packageInfo.appName}\n'
        'Package: ${packageInfo.packageName}\n'
        'Version: ${packageInfo.version}\n'
        'Build number: ${packageInfo.buildNumber}\n'
        'Generated: ${DateTime.now().toIso8601String()}\n'
        '\n';
  }

  static String _buildCallLog(AliceHttpCall call) {
    final StringBuffer stringBuffer = StringBuffer()
      ..writeAll([
        '===========================================\n',
        'Id: ${call.id}\n',
        '============================================\n',
        '--------------------------------------------\n',
        'General data\n',
        '--------------------------------------------\n',
        'Server: ${call.server} \n',
        'Method: ${call.method} \n',
        'Endpoint: ${call.endpoint} \n',
        'Client: ${call.client} \n',
        'Duration ${AliceConversionHelper.formatTime(call.duration)}\n',
        'Secured connection: ${call.secure}\n',
        'Completed: ${!call.loading} \n',
        '--------------------------------------------\n',
        'Request\n',
        '--------------------------------------------\n',
        'Request time: ${call.request?.time}\n',
        'Request content type: ${call.request?.contentType}\n',
        'Request cookies: ${_encoder.convert(call.request?.cookies)}\n',
        'Request headers: ${_encoder.convert(call.request?.headers)}\n',
      ]);

    if (call.request?.queryParameters.isNotEmpty ?? false) {
      stringBuffer.write(
        'Request query params: ${_encoder.convert(call.request?.queryParameters)}\n',
      );
    }

    stringBuffer.writeAll([
      'Request size: ${AliceConversionHelper.formatBytes(call.request?.size ?? 0)}\n',
      'Request body: ${AliceParser.formatBody(call.request?.body, call.request?.contentType)}\n',
      '--------------------------------------------\n',
      'Response\n',
      '--------------------------------------------\n',
      'Response time: ${call.response?.time}\n',
      'Response status: ${call.response?.status}\n',
      'Response size: ${AliceConversionHelper.formatBytes(call.response?.size ?? 0)}\n',
      'Response headers: ${_encoder.convert(call.response?.headers)}\n',
      'Response body: ${AliceParser.formatBody(call.response?.body, AliceParser.getContentType(call.response?.headers))}\n',
    ]);

    if (call.error != null) {
      stringBuffer.writeAll([
        '--------------------------------------------\n',
        'Error\n',
        '--------------------------------------------\n',
        'Error: ${call.error?.error}\n',
      ]);

      if (call.error?.stackTrace != null) {
        stringBuffer.write('Error stacktrace: ${call.error?.stackTrace}\n');
      }
    }

    stringBuffer.writeAll([
      '--------------------------------------------\n',
      'Curl\n',
      '--------------------------------------------\n',
      call.getCurlCommand(),
      '\n',
      '==============================================\n',
      '\n',
    ]);

    return stringBuffer.toString();
  }

  static Future<String> buildCallLog(AliceHttpCall call) async {
    try {
      return await _buildAliceLog() + _buildCallLog(call);
    } catch (exception) {
      return 'Failed to generate call log';
    }
  }
}
