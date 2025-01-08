import 'dart:async';
import 'dart:convert';
import 'dart:io';

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
    if (await _getPermissionStatus()) {
      await _saveToFile(context, calls);
    } else {
      final status = await _requestPermission();

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
      final isAndroid = Platform.isAndroid;
      final isIOS = Platform.isIOS;

      Directory? externalDir;
      if (isAndroid) {
        externalDir = await getExternalStorageDirectory();
      } else if (isIOS) {
        externalDir = await getApplicationDocumentsDirectory();
      } else {
        externalDir = await getApplicationCacheDirectory();
      }
      if (externalDir != null) {
        final fileName =
            'alice_log_${DateTime.now().millisecondsSinceEpoch}.txt';
        final file = File('${externalDir.path}/$fileName')..createSync();
        final sink = file.openWrite(mode: FileMode.append)
          ..write(await _buildAliceLog());
        calls.forEach((AliceHttpCall call) {
          sink.write(_buildCallLog(call));
        });
        await sink.flush();
        await sink.close();
        AliceAlertHelper.showAlert(
          context,
          'Success',
          'Successfully saved logs in ${file.path}',
          secondButtonTitle: isAndroid ? 'View file' : null,
          secondButtonAction: () =>
              isAndroid ? OpenFilex.open(file.path) : null,
        );
        return file.path;
      } else {
        AliceAlertHelper.showAlert(
          context,
          'Error',
          'Failed to save http calls to file',
        );
      }
    } catch (exception) {
      AliceAlertHelper.showAlert(
        context,
        'Error',
        'Failed to save http calls to file',
      );
      AliceUtils.log(exception.toString());
    }

    return '';
  }

  static Future<String> _buildAliceLog() async {
    final stringBuffer = StringBuffer();
    final packageInfo = await PackageInfo.fromPlatform();
    stringBuffer
      ..write('Alice - HTTP Inspector\n')
      ..write('App name:  ${packageInfo.appName}\n')
      ..write('Package: ${packageInfo.packageName}\n')
      ..write('Version: ${packageInfo.version}\n')
      ..write('Build number: ${packageInfo.buildNumber}\n')
      ..write('Generated: ${DateTime.now().toIso8601String()}\n')
      ..write('\n');
    return stringBuffer.toString();
  }

  static String _buildCallLog(AliceHttpCall call) {
    final stringBuffer = StringBuffer()
      ..write('===========================================\n')
      ..write('Id: ${call.id}\n')
      ..write('============================================\n')
      ..write('--------------------------------------------\n')
      ..write('General data\n')
      ..write('--------------------------------------------\n')
      ..write('Server: ${call.server} \n')
      ..write('Method: ${call.method} \n')
      ..write('Endpoint: ${call.endpoint} \n')
      ..write('Client: ${call.client} \n')
      ..write('Duration ${AliceConversionHelper.formatTime(call.duration)}\n')
      ..write('Secured connection: ${call.secure}\n')
      ..write('Completed: ${!call.loading} \n')
      ..write('--------------------------------------------\n')
      ..write('Request\n')
      ..write('--------------------------------------------\n')
      ..write('Request time: ${call.request!.time}\n')
      ..write('Request content type: ${call.request!.contentType}\n')
      ..write('Request cookies: ${_encoder.convert(call.request!.cookies)}\n')
      ..write('Request headers: ${_encoder.convert(call.request!.headers)}\n');
    if (call.request!.queryParameters.isNotEmpty) {
      stringBuffer.write(
        'Request query params: '
        '${_encoder.convert(call.request!.queryParameters)}\n',
      );
    }
    stringBuffer
      ..write(
        'Request size: '
        '${AliceConversionHelper.formatBytes(call.request!.size)}\n',
      )
      ..write(
        'Request body: ${AliceParser.formatBody(
          call.request!.body,
          AliceParser.getContentType(call.request!.headers),
        )}\n',
      )
      ..write('--------------------------------------------\n')
      ..write('Response\n')
      ..write('--------------------------------------------\n')
      ..write('Response time: ${call.response!.time}\n')
      ..write('Response status: ${call.response!.status}\n')
      ..write(
        'Response size: '
        '${AliceConversionHelper.formatBytes(call.response!.size)}\n',
      )
      ..write(
        'Response headers: ${_encoder.convert(call.response!.headers)}\n',
      )
      ..write(
        'Response body: ${AliceParser.formatBody(
          call.response!.body,
          AliceParser.getContentType(call.response!.headers),
        )}\n',
      );
    if (call.error != null) {
      stringBuffer
        ..write('--------------------------------------------\n')
        ..write('Error\n')
        ..write('--------------------------------------------\n')
        ..write('Error: ${call.error!.error}\n');
      if (call.error!.stackTrace != null) {
        stringBuffer.write('Error stacktrace: ${call.error!.stackTrace}\n');
      }
    }
    stringBuffer
      ..write('--------------------------------------------\n')
      ..write('Curl\n')
      ..write('--------------------------------------------\n')
      ..write(call.getCurlCommand())
      ..write('\n')
      ..write('==============================================\n')
      ..write('\n');

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
