import 'dart:convert';
import 'dart:io';

import 'package:alice/model/alice_http_error.dart';
import 'package:alice/ui/alice_calls_list_screen.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_http_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:package_info/package_info.dart';
import 'package:open_file/open_file.dart';

class AliceCore {
  FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  GlobalKey<NavigatorState> _navigatorKey;
  bool _showNotification = false;
  JsonEncoder _encoder = new JsonEncoder.withIndent('  ');

  List<AliceHttpCall> calls;
  PublishSubject<int> changesSubject;
  PublishSubject<AliceHttpCall> callUpdateSubject;


  AliceCore(GlobalKey<NavigatorState> navigatorKey, bool showNotification) {
    _navigatorKey = navigatorKey;
    calls = List();
    changesSubject = PublishSubject();
    callUpdateSubject = PublishSubject();
    _initializeNotificationsPlugin();
    _showNotification = showNotification;
  }

  dispose() {
    changesSubject.close();
    callUpdateSubject.close();
  }

  void _initializeNotificationsPlugin() {
    _flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid =
        new AndroidInitializationSettings("@mipmap/ic_launcher");
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: _onSelectedNotification);
  }

  Future _onSelectedNotification(String payload) {
    navigateToCallListScreen();
    return Future.sync(() {});
  }

  void navigateToCallListScreen() {
    var context = getContext();
    if (context == null) {
      print(
          "Cant start Alice HTTP Inspector. Please add NavigatorKey to your application");
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AliceCallsListScreen(this)),
    );
  }

  BuildContext getContext() {
    if (_navigatorKey != null &&
        _navigatorKey.currentState != null &&
        _navigatorKey.currentState.overlay != null) {
      return _navigatorKey.currentState.overlay.context;
    } else {
      return null;
    }
  }

  void _showLocalNotification() async {
    var channelId = "Alice";
    var channelName = "Alice";
    var channelDescription = "Alice";
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        channelId, channelName, channelDescription,
        enableVibration: false,
        importance: Importance.Default,
        priority: Priority.Default);
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
        0, "Alice", "HTTP Requests: ${calls.length}", platformChannelSpecifics,
        payload: "");
  }

  void addCall(AliceHttpCall call) {
    calls.add(call);
    if (_showNotification) {
      _showLocalNotification();
    }
  }

  void addError(AliceHttpError error, int requestId) {
    AliceHttpCall selectedCall = _selectCall(requestId);

    if (selectedCall == null) {
      print("Selected call is null");
      return;
    }

    selectedCall.error = error;
    changesSubject.sink.add(requestId);
    callUpdateSubject.sink.add(selectedCall);
  }

  void addResponse(AliceHttpResponse response, int requestId) {
    AliceHttpCall selectedCall = _selectCall(requestId);

    if (selectedCall == null) {
      print("Selected call is null");
      return;
    }
    selectedCall.loading = false;
    selectedCall.response = response;
    selectedCall.duration = response.time.millisecondsSinceEpoch -
        selectedCall.request.time.millisecondsSinceEpoch;

    changesSubject.sink.add(requestId);
    callUpdateSubject.sink.add(selectedCall);
  }

  void removeCalls() {
    calls = List();
    changesSubject.sink.add(0);
  }

  AliceHttpCall _selectCall(int requestId) {
    AliceHttpCall requestedCall;
    calls.forEach((call) {
      if (call.id == requestId) {
        requestedCall = call;
      }
    });
    return requestedCall;
  }

  void saveHttpRequests(BuildContext context) {
    _checkPermissions(context);
  }

  void _checkPermissions(BuildContext context) async {
    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);
    if (permission == PermissionStatus.granted) {
      _saveToFile(context);
    } else {
      Map<PermissionGroup, PermissionStatus> permissions =
          await PermissionHandler()
              .requestPermissions([PermissionGroup.storage]);
      if (permissions.containsKey(PermissionGroup.storage) &&
          permissions[PermissionGroup.storage] == PermissionStatus.granted) {
        _saveToFile(context);
      } else {
        _showAlert(context, "Permission error",
            "Permission not granted. Couldn't save logs.");
      }
    }
  }

  Future<String> _saveToFile(BuildContext context) async {
    try {
      if (calls.length == 0) {
        _showAlert(context, "Error", "There are no logs to save");
      }

      Directory externalDir = await getExternalStorageDirectory();
      String fileName =
          "alice_log_${DateTime.now().millisecondsSinceEpoch}.txt";
      File file = File(externalDir.path.toString() + "/" + fileName);
      file.createSync();
      IOSink sink = file.openWrite(mode: FileMode.append);

      var packageInfo = await PackageInfo.fromPlatform();
      sink.write("Alice inspector logs\n");
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
      _showAlert(context, "Success", "Sucessfully saved logs in ${file.path}",
          fileUrl: file.path);
      return file.path;
    } catch (exception) {
      _showAlert(context, "Error", "Failed to save http calls to file");
      print(exception);
    }

    return "";
  }

  void _showAlert(BuildContext context, String title, String description,
      {String fileUrl}) {
    List<Widget> actions = List();
    if (fileUrl != null) {
      actions.add(FlatButton(
        child: Text("View file"),
        onPressed: () {
          Navigator.of(context).pop();
          OpenFile.open(fileUrl);
        },
      ));
      actions.add(FlatButton(
        child: Text("OK"),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ));
    }

    showDialog(
        context: context,
        builder: (BuildContext buildContext) {
          return AlertDialog(
              title: Text(title), content: Text(description), actions: actions);
        });
  }
}
