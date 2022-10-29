import 'dart:io';

import 'package:alice/logger/logs/data.dart';
import 'package:flutter/foundation.dart';

class AliceLogger {
  final LogCollection logCollection;

  AliceLogger({required this.logCollection});

  Future<String> getAndroidRawLogs() async {
    debugPrint('getLogs');
    if (Platform.isAndroid) {
      final process = await Process.run('logcat', ['-v', 'raw', '-d']);
      final result = process.stdout as String;
      return result;
    }
    return '';
  }

  Future<void> clearAndroidRawLogs() async {
    if (Platform.isAndroid) {
      await Process.run('logcat', ['-c']);
    }
  }

  void clearLogs() {
    logCollection.clear();
  }
}