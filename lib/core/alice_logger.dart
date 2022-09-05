import 'dart:io';

import 'package:flutter/foundation.dart';

class AliceLogger {
  factory AliceLogger() {
    return _aliceLogger;
  }

  AliceLogger._internal();

  static final AliceLogger _aliceLogger = AliceLogger._internal();

  Future<String> getLogs() async {
    debugPrint('getLogs');
    if (Platform.isAndroid) {
      final process = await Process.run('logcat', ['-d']);
      final result = process.stdout as String;
      return result;
    }
    return 'Unsupported platform';
  }
}