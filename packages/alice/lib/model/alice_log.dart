import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// Definition of log data holder.
@immutable
class AliceLog with EquatableMixin {
  AliceLog({
    required this.message,
    this.level = DiagnosticLevel.info,
    DateTime? timestamp,
    this.error,
    this.stackTrace,
  }) : assert(
         level != DiagnosticLevel.off,
         "`DiagnosticLevel.off` is a '[special] level indicating that no "
         "diagnostics should be shown' and should not be used as a value.",
       ),
       assert(timestamp == null || !timestamp.isUtc, 'Invalid timestamp'),
       timestamp = timestamp ?? DateTime.now();

  final DiagnosticLevel level;
  final DateTime timestamp;
  final String message;
  final dynamic error;
  final StackTrace? stackTrace;

  @override
  List<Object?> get props => [level, timestamp, message, error, stackTrace];
}
