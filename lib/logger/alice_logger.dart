import 'dart:io';

import 'package:alice/logger/logs/data.dart';
import 'package:flutter/foundation.dart';

class AliceLogger {
  final LogCollection logCollection;

  AliceLogger({required this.logCollection});

  Future<String> getAndroidRawLogs() async {
    debugPrint('getLogs');
    if (Platform.isAndroid) {
      final process = await Process.run('logcat', ['-d']);
      final result = process.stdout as String;
      return result;
    }
    return '';
  }
}