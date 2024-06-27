/// Helper used in unit conversion.
class AliceConversionHelper {
  static const int _kilobyteAsByte = 1000;
  static const int _megabyteAsByte = 1000000;
  static const int _secondAsMillisecond = 1000;
  static const int _minuteAsMillisecond = 60000;

  /// Format bytes text
  static String formatBytes(int bytes) => switch (bytes) {
        int bytes when bytes < 0 => '-1 B',
        int bytes when bytes <= _kilobyteAsByte => '$bytes B',
        int bytes when bytes <= _megabyteAsByte =>
          '${_formatDouble(bytes / _kilobyteAsByte)} kB',
        _ => '${_formatDouble(bytes / _megabyteAsByte)} MB',
      };

  /// Formats double with two numbers after dot.
  static String _formatDouble(double value) => value.toStringAsFixed(2);

  /// Format time in milliseconds
  static String formatTime(int timeInMillis) {
    if (timeInMillis < 0) {
      return '-1 ms';
    }
    if (timeInMillis <= _secondAsMillisecond) {
      return '$timeInMillis ms';
    }
    if (timeInMillis <= _minuteAsMillisecond) {
      return '${_formatDouble(timeInMillis / _secondAsMillisecond)} s';
    }

    final Duration duration = Duration(milliseconds: timeInMillis);

    return '${duration.inMinutes} min ${duration.inSeconds.remainder(60)} s '
        '${duration.inMilliseconds.remainder(1000)} ms';
  }
}
