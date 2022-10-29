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
    Brightness brightness,
  ) {
    _checkPermissions(context, calls, brightness);
  }

  static void _checkPermissions(
    BuildContext context,
    List<AliceHttpCall> calls,
    Brightness brightness,
  ) async {
    final status = await Permission.storage.status;
    if (status.isGranted) {
      _saveToFile(
        context,
        calls,
        brightness,
      );
    } else {
      final status = await Permission.storage.request();

      if (status.isGranted) {
        _saveToFile(context, calls, brightness);
      } else {
        AliceAlertHelper.showAlert(
          context,
          "Permission error",
          "Permission not granted. Couldn't save logs.",
          brightness: brightness,
        );
      }
    }
  }

  static Future<String> _saveToFile(
    BuildContext context,
    List<AliceHttpCall> calls,
    Brightness brightness,
  ) async {
    try {
      if (calls.isEmpty) {
        AliceAlertHelper.showAlert(
          context,
          "Error",
          "There are no logs to save",
          brightness: brightness,
        );
        return "";
      }
      final bool isAndroid = Platform.isAndroid;

      Directory? externalDir;
      if (isAndroid) {
        externalDir = await getExternalStorageDirectory();
      } else {
        externalDir = await getApplicationDocumentsDirectory();
      }
      if (externalDir != null) {
        final String fileName =
            "alice_log_${DateTime.now().millisecondsSinceEpoch}.txt";
        final File file = File("${externalDir.path}/$fileName");
        file.createSync();
        final IOSink sink = file.openWrite(mode: FileMode.append);
        sink.write(await _buildAliceLog());
        calls.forEach((AliceHttpCall call) {
          sink.write(_buildCallLog(call));
        });
        await sink.flush();
        await sink.close();
        AliceAlertHelper.showAlert(
          context,
          "Success",
          "Successfully saved logs in ${file.path}",
          secondButtonTitle: isAndroid ? "View file" : null,
          secondButtonAction: () =>
              isAndroid ? OpenFilex.open(file.path) : null,
          brightness: brightness,
        );
        return file.path;
      } else {
        AliceAlertHelper.showAlert(
          context,
          "Error",
          "Failed to save http calls to file",
        );
      }
    } catch (exception) {
      AliceAlertHelper.showAlert(
        context,
        "Error",
        "Failed to save http calls to file",
        brightness: brightness,
      );
      AliceUtils.log(exception.toString());
    }

    return "";
  }

  static Future<String> _buildAliceLog() async {
    final StringBuffer stringBuffer = StringBuffer();
    final packageInfo = await PackageInfo.fromPlatform();
    stringBuffer.write("Alice - HTTP Inspector\n");
    stringBuffer.write("App name:  ${packageInfo.appName}\n");
    stringBuffer.write("Package: ${packageInfo.packageName}\n");
    stringBuffer.write("Version: ${packageInfo.version}\n");
    stringBuffer.write("Build number: ${packageInfo.buildNumber}\n");
    stringBuffer.write("Generated: ${DateTime.now().toIso8601String()}\n");
    stringBuffer.write("\n");
    return stringBuffer.toString();
  }

  static String _buildCallLog(AliceHttpCall call) {
    final StringBuffer stringBuffer = StringBuffer();
    stringBuffer.write("===========================================\n");
    stringBuffer.write("Id: ${call.id}\n");
    stringBuffer.write("============================================\n");
    stringBuffer.write("--------------------------------------------\n");
    stringBuffer.write("General data\n");
    stringBuffer.write("--------------------------------------------\n");
    stringBuffer.write("Server: ${call.server} \n");
    stringBuffer.write("Method: ${call.method} \n");
    stringBuffer.write("Endpoint: ${call.endpoint} \n");
    stringBuffer.write("Client: ${call.client} \n");
    stringBuffer
        .write("Duration ${AliceConversionHelper.formatTime(call.duration)}\n");
    stringBuffer.write("Secured connection: ${call.secure}\n");
    stringBuffer.write("Completed: ${!call.loading} \n");
    stringBuffer.write("--------------------------------------------\n");
    stringBuffer.write("Request\n");
    stringBuffer.write("--------------------------------------------\n");
    stringBuffer.write("Request time: ${call.request!.time}\n");
    stringBuffer.write("Request content type: ${call.request!.contentType}\n");
    stringBuffer
        .write("Request cookies: ${_encoder.convert(call.request!.cookies)}\n");
    stringBuffer
        .write("Request headers: ${_encoder.convert(call.request!.headers)}\n");
    if (call.request!.queryParameters.isNotEmpty) {
      stringBuffer.write(
        "Request query params: ${_encoder.convert(call.request!.queryParameters)}\n",
      );
    }
    stringBuffer.write(
      "Request size: ${AliceConversionHelper.formatBytes(call.request!.size)}\n",
    );
    stringBuffer.write(
      "Request body: ${AliceParser.formatBody(call.request!.body, AliceParser.getContentType(call.request!.headers))}\n",
    );
    stringBuffer.write("--------------------------------------------\n");
    stringBuffer.write("Response\n");
    stringBuffer.write("--------------------------------------------\n");
    stringBuffer.write("Response time: ${call.response!.time}\n");
    stringBuffer.write("Response status: ${call.response!.status}\n");
    stringBuffer.write(
      "Response size: ${AliceConversionHelper.formatBytes(call.response!.size)}\n",
    );
    stringBuffer.write(
      "Response headers: ${_encoder.convert(call.response!.headers)}\n",
    );
    stringBuffer.write(
      "Response body: ${AliceParser.formatBody(call.response!.body, AliceParser.getContentType(call.response!.headers))}\n",
    );
    if (call.error != null) {
      stringBuffer.write("--------------------------------------------\n");
      stringBuffer.write("Error\n");
      stringBuffer.write("--------------------------------------------\n");
      stringBuffer.write("Error: ${call.error!.error}\n");
      if (call.error!.stackTrace != null) {
        stringBuffer.write("Error stacktrace: ${call.error!.stackTrace}\n");
      }
    }
    stringBuffer.write("--------------------------------------------\n");
    stringBuffer.write("Curl\n");
    stringBuffer.write("--------------------------------------------\n");
    stringBuffer.write(call.getCurlCommand());
    stringBuffer.write("\n");
    stringBuffer.write("==============================================\n");
    stringBuffer.write("\n");

    return stringBuffer.toString();
  }

  static Future<String> buildCallLog(AliceHttpCall call) async {
    try {
      return await _buildAliceLog() + _buildCallLog(call);
    } catch (exception) {
      return "Failed to generate call log";
    }
  }
}
