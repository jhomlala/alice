import 'dart:convert';
import 'dart:io';
import 'package:alice/model/alice_http_call.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'alice_alert_helper.dart';

class AliceSaveHelper {
  static JsonEncoder _encoder = new JsonEncoder.withIndent('  ');

  static void saveCalls(BuildContext context, List<AliceHttpCall> calls) {
    checkPermissions(context, calls);
  }

  static void checkPermissions(
      BuildContext context, List<AliceHttpCall> calls) async {
    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);
    if (permission == PermissionStatus.granted) {
      _saveToFile(context, calls);
    } else {
      Map<PermissionGroup, PermissionStatus> permissions =
          await PermissionHandler()
              .requestPermissions([PermissionGroup.storage]);
      if (permissions.containsKey(PermissionGroup.storage) &&
          permissions[PermissionGroup.storage] == PermissionStatus.granted) {
        _saveToFile(context, calls);
      } else {
        AliceAlertHelper.showAlert(context, "Permission error",
            "Permission not granted. Couldn't save logs.");
      }
    }
  }

  static Future<String> _saveToFile(
      BuildContext context, List<AliceHttpCall> calls) async {
    try {
      if (calls.length == 0) {
        AliceAlertHelper.showAlert(
            context, "Error", "There are no logs to save");
        return "";
      }

      Directory externalDir = await getExternalStorageDirectory();
      String fileName =
          "alice_log_${DateTime.now().millisecondsSinceEpoch}.txt";
      File file = File(externalDir.path.toString() + "/" + fileName);
      file.createSync();
      IOSink sink = file.openWrite(mode: FileMode.append);

      var packageInfo = await PackageInfo.fromPlatform();
      sink.write("Alice - HTTP Inspector\n");
      sink.write("App name:  ${packageInfo.appName}\n");
      sink.write("Package: ${packageInfo.packageName}\n");
      sink.write("Version: ${packageInfo.version}\n");
      sink.write("Build number: ${packageInfo.buildNumber}\n");
      sink.write("Generated: " + DateTime.now().toIso8601String() + "\n");
      calls.forEach((AliceHttpCall call) {
        sink.write("\n");
        sink.write("==============================================\n");
        sink.write("Id: ${call.id}\n");
        sink.write("==============================================\n");
        sink.write("Server: ${call.server} \n");
        sink.write("Method: ${call.method} \n");
        sink.write("Endpoint: ${call.endpoint} \n");
        sink.write("Client: ${call.client} \n");
        sink.write("Duration ${call.duration} ms\n");
        sink.write("Secured connection: ${call.duration}\n");
        sink.write("Completed: ${!call.loading} \n");
        sink.write("Request time: ${call.request.time}\n");
        sink.write("Request content type: ${call.request.contentType}\n");
        sink.write(
            "Request cookies: ${_encoder.convert(call.request.cookies)}\n");
        sink.write(
            "Request headers: ${_encoder.convert(call.request.headers)}\n");
        sink.write("Request size: ${call.request.size} bytes\n");
        sink.write("Request body: ${_encoder.convert(call.request.body)}\n");
        sink.write("Response time: ${call.response.time}\n");
        sink.write("Response status: ${call.response.status}\n");
        sink.write("Response size: ${call.response.size} bytes\n");
        sink.write(
            "Response headers: ${_encoder.convert(call.response.headers)}\n");
        sink.write("Response body: ${_encoder.convert(call.response.body)}\n");
        if (call.error != null) {
          sink.write("Error: ${call.error.error}\n");
          if (call.error.stackTrace != null) {
            sink.write("Error stacktrace: ${call.error.stackTrace}\n");
          }
        }
        sink.write("==============================================\n");
        sink.write("\n");
      });

      await sink.flush();
      await sink.close();
      AliceAlertHelper.showAlert(
          context, "Success", "Sucessfully saved logs in ${file.path}",
          secondButtonTitle: "View file",
          secondButtonAction: () => OpenFile.open(file.path));
      return file.path;
    } catch (exception) {
      AliceAlertHelper.showAlert(
          context, "Error", "Failed to save http calls to file");
      print(exception);
    }

    return "";
  }
}
