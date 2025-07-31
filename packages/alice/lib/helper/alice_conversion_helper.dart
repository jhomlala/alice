/// Helper used in unit conversion.
class AliceConversionHelper {
  static const int _kilobyteAsByte = 1000;
  static const int _megabyteAsByte = 1000000;
  static const int _secondAsMillisecond = 1000;
  static const int _minuteAsMillisecond = 60000;
  static const String _bytes = "B";
  static const String _kiloBytes = "kB";
  static const String _megaBytes = "MB";
  static const String _milliseconds = "ms";
  static const String _seconds = "s";
  static const String _minutes = "min";

  /// Format bytes text
  static String formatBytes(int bytes) => switch (bytes) {
    int bytes when bytes < 0 => '-1 $_bytes',
    int bytes when bytes <= _kilobyteAsByte => '$bytes $_bytes',
    int bytes when bytes <= _megabyteAsByte =>
      '${_formatDouble(bytes / _kilobyteAsByte)} $_kiloBytes',
    _ => '${_formatDouble(bytes / _megabyteAsByte)} $_megaBytes',
  };

  /// Formats double with two numbers after dot.
  static String _formatDouble(double value) => value.toStringAsFixed(2);

  /// Format time in milliseconds
  static String formatTime(int timeInMillis) {
    if (timeInMillis < 0) {
      return '-1 $_milliseconds';
    }
    if (timeInMillis <= _secondAsMillisecond) {
      return '$timeInMillis $_milliseconds';
    }
    if (timeInMillis <= _minuteAsMillisecond) {
      return '${_formatDouble(timeInMillis / _secondAsMillisecond)} $_seconds';
    }

    final Duration duration = Duration(milliseconds: timeInMillis);

    return '${duration.inMinutes} $_minutes ${duration.inSeconds.remainder(60)} $_seconds '
        '${duration.inMilliseconds.remainder(1000)} $_milliseconds';
  }
}
