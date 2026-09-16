import 'dart:io';

class LogcatProvider {
  static Future<String> getAndroidRawLogs() async {
    final ProcessResult process = await Process.run('logcat', [
      '-v',
      'raw',
      '-d',
    ]);
    return process.stdout as String;
  }

  static Future<void> clearAndroidRawLogs() async {
    await Process.run('logcat', ['-c']);
  }
}
