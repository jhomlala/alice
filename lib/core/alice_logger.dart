import 'dart:io';

import 'package:alice/model/alice_log.dart';
import 'package:flutter/foundation.dart';

class AliceLogger {
  AliceLogger({int? maximumSize = 1000}) : _maximumSize = maximumSize;

  final _logs = ValueNotifier<List<AliceLog>>([]);

  ValueListenable<List<AliceLog>> get listenable => _logs;

  List<AliceLog> get logs => listenable.value;

  int? _maximumSize;

  /// The maximum number of logs to store or `null` for unlimited storage.
  ///
  /// If more logs arrive, the oldest ones (based on their [AliceLog.timestamp]) will
  /// be removed.
  int? get maximumSize => _maximumSize;

  set maximumSize(int? value) {
    _maximumSize = maximumSize;

    if (value != null && logs.length > value) {
      _logs.value = logs.sublist(logs.length - value, logs.length);
    }
  }

  void add(AliceLog log) {
    int index;
    if (logs.isEmpty || !log.timestamp.isBefore(logs.last.timestamp)) {
      // Quick path as new logs are usually more recent.
      index = logs.length;
    } else {
      // Binary search to find the insertion index.
      var min = 0;
      var max = logs.length;
      while (min < max) {
        final mid = min + ((max - min) >> 1);
        final item = logs[mid];
        if (log.timestamp.isBefore(item.timestamp)) {
          max = mid;
        } else {
          min = mid + 1;
        }
      }
      assert(min == max);
      index = min;
    }

    var startIndex = 0;
    if (maximumSize != null && logs.length >= maximumSize!) {
      if (index == 0) return;
      startIndex = logs.length - maximumSize! + 1;
    }
    _logs.value = [
      ...logs.sublist(startIndex, index),
      log,
      ...logs.sublist(index, logs.length),
    ];
  }

  void clear() => _logs.value = [];

  Future<String> getAndroidRawLogs() async {
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
    logs.clear();
  }
}
