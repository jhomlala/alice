import 'package:meta/meta.dart';

@immutable
class AliceHttpError {
  final Object error;
  final StackTrace? stackTrace;
  final DateTime time;

  AliceHttpError({
    required this.error,
    required this.stackTrace,
    required this.time,
  });
}
