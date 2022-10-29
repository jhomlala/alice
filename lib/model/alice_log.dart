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
