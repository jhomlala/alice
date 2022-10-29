import 'package:flutter/foundation.dart';

@immutable
class AliceLog {
  AliceLog({
    this.level = DiagnosticLevel.info,
    DateTime? timestamp,
    required this.message,
    this.error,
    this.stackTrace,
  })  : assert(
          level != DiagnosticLevel.off,
          '`DiagnosticLevel.off` is a "[special] level indicating that no '
          'diagnostics should be shown" and should not be used as a value.',
        ),
        assert(timestamp == null || !timestamp.isUtc),
        timestamp = timestamp ?? DateTime.now();

  final DiagnosticLevel level;
  final DateTime timestamp;
  final String message;
  final dynamic error;
  final StackTrace? stackTrace;

  @override
  int get hashCode => Object.hash(level, timestamp, message, error, stackTrace);

  @override
  bool operator ==(Object other) {
    return other is AliceLog &&
        level == other.level &&
        timestamp == other.timestamp &&
        message == other.message &&
        error == other.error &&
        stackTrace == other.stackTrace;
  }
}

class AliceLogCollection {
  AliceLogCollection({int? maximumSize = 1000}) : _maximumSize = maximumSize;

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
}
