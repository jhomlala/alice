import 'dart:io';

class AliceLogger {
  factory AliceLogger() {
    return _aliceLogger;
  }

  AliceLogger._internal();

  static final AliceLogger _aliceLogger = AliceLogger._internal();

  Future<String> getLogs() async {
    print('getLogs');
    final process = await Process.run('logcat', ['-d']);
    final result = process.stdout as String;
    return result;
  }

  Future<String> getLogs2() async {
    return '';
  }
}