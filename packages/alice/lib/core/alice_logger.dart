import 'dart:io' show Process, ProcessResult;

import 'package:alice/helper/operating_system.dart';
import 'package:alice/model/alice_log.dart';
import 'package:rxdart/rxdart.dart';

/// Logger used to handle logs from application.
class AliceLogger {
  /// Maximum logs size. If 0, logs will be not rotated.
  final int maximumSize;

  /// Subject which keeps logs.
  final BehaviorSubject<List<AliceLog>> _logsSubject;

  AliceLogger({required this.maximumSize})
    : _logsSubject = BehaviorSubject.seeded([]);

  /// Getter of stream of logs
  Stream<List<AliceLog>> get logsStream => _logsSubject.stream;

  /// Getter of all logs
  List<AliceLog> get logs => _logsSubject.value;

  /// Adds all logs.
  void addAll(Iterable<AliceLog> logs) {
    for (var log in logs) {
      add(log);
    }
  }

  /// Add one log. It sorts logs after adding new element. If [maximumSize] is
  /// set and max size is reached, first log will be deleted.
  void add(AliceLog log) {
    final values = _logsSubject.value;
    final count = values.length;
    if (maximumSize > 0 && count >= maximumSize) {
      values.removeAt(0);
    }

    values.add(log);
    values.sort((log1, log2) => log1.timestamp.compareTo(log2.timestamp));
    _logsSubject.add(values);
  }

  /// Clears all logs.
  void clearLogs() => _logsSubject.add([]);

  /// Returns raw logs from Android via ADB.
  Future<String> getAndroidRawLogs() async {
    if (OperatingSystem.isAndroid) {
      final ProcessResult process = await Process.run('logcat', [
        '-v',
        'raw',
        '-d',
      ]);
      return process.stdout as String;
    }
    return '';
  }

  /// Clears all raw logs.
  Future<void> clearAndroidRawLogs() async {
    if (OperatingSystem.isAndroid) {
      await Process.run('logcat', ['-c']);
    }
  }
}
