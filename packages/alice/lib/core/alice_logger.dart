import 'dart:io' show Platform, Process, ProcessResult;

import 'package:alice/model/alice_log.dart';
import 'package:alice/utils/num_comparison.dart';
import 'package:flutter/foundation.dart';

/// Logger used to handle logs from application.
class AliceLogger {
  AliceLogger({int? maximumSize = 1000}) : _maximumSize = maximumSize;

  final ValueNotifier<List<AliceLog>> _logs = ValueNotifier<List<AliceLog>>([]);

  ValueListenable<List<AliceLog>> get listenable => _logs;

  List<AliceLog> get logs => listenable.value;

  int? _maximumSize;

  /// The maximum number of logs to store or `null` for unlimited storage.
  ///
  /// If more logs arrive, the oldest ones (based on their [
  /// AliceLog.timestamp]) will be removed.
  int? get maximumSize => _maximumSize;

  set maximumSize(int? value) {
    _maximumSize = maximumSize;

    if (value != null && logs.length > value) {
      _logs.value = logs.sublist(logs.length - value, logs.length);
    }
  }

  void add(AliceLog log) {
    late final int index;
    if (logs.isEmpty || !log.timestamp.isBefore(logs.last.timestamp)) {
      // Quick path as new logs are usually more recent.
      index = logs.length;
    } else {
      // Binary search to find the insertion index.
      int min = 0;
      int max = logs.length;
      while (min < max) {
        final int mid = min + ((max - min) >> 1);
        final AliceLog item = logs[mid];
        if (log.timestamp.isBefore(item.timestamp)) {
          max = mid;
        } else {
          min = mid + 1;
        }
      }
      assert(min == max, '');
      index = min;
    }

    int startIndex = 0;
    if (maximumSize != null && logs.length.gte(maximumSize)) {
      if (index == 0) return;
      startIndex = logs.length - maximumSize! + 1;
    }
    _logs.value = <AliceLog>[
      ...logs.sublist(startIndex, index),
      log,
      ...logs.sublist(index, logs.length),
    ];
  }

  /// Clears all logs.
  void clearLogs() => _logs.value.clear();

  /// Returns raw logs from Android via ADB.
  Future<String> getAndroidRawLogs() async {
    if (Platform.isAndroid) {
      final ProcessResult process =
          await Process.run('logcat', ['-v', 'raw', '-d']);
      return process.stdout as String;
    }
    return '';
  }

  /// Clears all raw logs.
  Future<void> clearAndroidRawLogs() async {
    if (Platform.isAndroid) {
      await Process.run('logcat', ['-c']);
    }
  }
}
