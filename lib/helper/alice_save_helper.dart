import 'dart:convert';
import 'dart:io';
import 'package:alice/helper/alice_conversion_helper.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/ui/utils/alice_parser.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../helper/alice_alert_helper.dart';

class AliceSaveHelper {
  static JsonEncoder _encoder = new JsonEncoder.withIndent('  ');

  /// Top level method used to save calls to file
  static void saveCalls(
      BuildContext context, List<AliceHttpCall> calls, Brightness brightness) {
    assert(context != null, "context can't be null");
    assert(calls != null, "calls can't be null");
    assert(brightness != null, "brightness can't be null");
    _checkPermissions(context, calls, brightness);
  }

  static void _checkPermissions(BuildContext context, List<AliceHttpCall> calls,
      Brightness brightness) async {
    assert(context != null, "context can't be null");
    assert(calls != null, "calls can't be null");
    assert(brightness != null, "brightness can't be null");
    var status = await Permission.storage.status;
    if (status.isGranted) {
      _saveToFile(context, calls, brightness);
    } else {
      var status = await Permission.storage.request();

      if (status.isGranted) {
        _saveToFile(context, calls, brightness);
      } else {
        AliceAlertHelper.showAlert(context, "Permission error",
            "Permission not granted. Couldn't save logs.",
            brightness: brightness);
      }
    }
  }

  static Future<String> _saveToFile(BuildContext context,
      List<AliceHttpCall> calls, Brightness brightness) async {
    assert(context != null, "context can't be null");
    assert(calls != null, "calls can't be null");
    assert(brightness != null, "brightness can't be null");
    try {
      if (calls.length == 0) {
        AliceAlertHelper.showAlert(
            context, "Error", "There are no logs to save",
            brightness: brightness);
        return "";
      }
      bool isAndroid = Platform.isAndroid;

      Directory externalDir = await (isAndroid
          ? getExternalStorageDirectory()
          : getApplicationDocumentsDirectory());
      String fileName =
          "alice_log_${DateTime.now().millisecondsSinceEpoch}.txt";
      File file = File(externalDir.path.toString() + "/" + fileName);
      file.createSync();
      IOSink sink = file.openWrite(mode: FileMode.append);
      sink.write(await _buildAliceLog());
      calls.forEach((AliceHttpCall call) {
        sink.write(_buildCallLog(call));
      });
      await sink.flush();
      await sink.close();
      AliceAlertHelper.showAlert(
          context, "Success", "Sucessfully saved logs in ${file.path}",
          secondButtonTitle: isAndroid ? "View file" : null,
          secondButtonAction: () => isAndroid ? OpenFile.open(file.path) : null,
          brightness: brightness);
      return file.path;
    } catch (exception) {
      AliceAlertHelper.showAlert(
          context, "Error", "Failed to save http calls to file",
          brightness: brightness);
      print(exception);
    }

    return "";
  }

  static Future<String> _buildAliceLog() async {
    StringBuffer stringBuffer = StringBuffer();
    var packageInfo = await PackageInfo.fromPlatform();
    stringBuffer.write("Alice - HTTP Inspector\n");
    stringBuffer.write("App name:  ${packageInfo.appName}\n");
    stringBuffer.write("Package: ${packageInfo.packageName}\n");
    stringBuffer.write("Version: ${packageInfo.version}\n");
    stringBuffer.write("Build number: ${packageInfo.buildNumber}\n");
    stringBuffer.write("Generated: " + DateTime.now().toIso8601String() + "\n");
    stringBuffer.write("\n");
    return stringBuffer.toString();
  }

  static String _buildCallLog(AliceHttpCall call) {
    assert(call != null, "call can't be null");
    StringBuffer stringBuffer = StringBuffer();
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
    stringBuffer.write("Request time: ${call.request.time}\n");
    stringBuffer.write("Request content type: ${call.request.contentType}\n");
    stringBuffer
        .write("Request cookies: ${_encoder.convert(call.request.cookies)}\n");
    stringBuffer
        .write("Request headers: ${_encoder.convert(call.request.headers)}\n");
    stringBuffer.write(
        "Request size: ${AliceConversionHelper.formatBytes(call.request.size)}\n");
    stringBuffer.write(
        "Request body: ${AliceParser.formatBody(call.request.body, AliceParser.getContentType(call.request.headers))}\n");
    stringBuffer.write("--------------------------------------------\n");
    stringBuffer.write("Response\n");
    stringBuffer.write("--------------------------------------------\n");
    stringBuffer.write("Response time: ${call.response.time}\n");
    stringBuffer.write("Response status: ${call.response.status}\n");
    stringBuffer.write(
        "Response size: ${AliceConversionHelper.formatBytes(call.response.size)}\n");
    stringBuffer.write(
        "Response headers: ${_encoder.convert(call.response.headers)}\n");
    stringBuffer.write(
        "Response body: ${AliceParser.formatBody(call.response.body, AliceParser.getContentType(call.response.headers))}\n");
    if (call.error != null) {
      stringBuffer.write("--------------------------------------------\n");
      stringBuffer.write("Error\n");
      stringBuffer.write("--------------------------------------------\n");
      stringBuffer.write("Error: ${call.error.error}\n");
      if (call.error.stackTrace != null) {
        stringBuffer.write("Error stacktrace: ${call.error.stackTrace}\n");
      }
    }
    stringBuffer.write("--------------------------------------------\n");
    stringBuffer.write("Curl\n");
    stringBuffer.write("--------------------------------------------\n");
    stringBuffer.write("${call.getCurlCommand()}");
    stringBuffer.write("\n");
    stringBuffer.write("==============================================\n");
    stringBuffer.write("\n");

    return stringBuffer.toString();
  }

  static Future<String> buildCallLog(AliceHttpCall call) async {
    assert(call != null, "call can't be null");
    try {
      return await _buildAliceLog() + _buildCallLog(call);
    } catch (exception) {
      return "Failed to generate call log";
    }
  }
}
