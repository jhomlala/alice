class AliceConversionHelper {
  static int _kilobyteAsByte = 1000;
  static int _megabyteAsByte = 1000000;
  static int _secondAsMillisecond = 1000;
  static int _minuteAsMillisecond = 60000;

  /// Format bytes text
  static String formatBytes(int bytes) {
    if (bytes == null || bytes < 0) {
      return "-1 B";
    }
    if (bytes <= _kilobyteAsByte) {
      return "$bytes B";
    }
    if (bytes <= _megabyteAsByte) {
      return "${_formatDouble(bytes / _kilobyteAsByte)} kB";
    }

    return "${_formatDouble(bytes / _megabyteAsByte)} MB";
  }

  static String _formatDouble(double value) => value.toStringAsFixed(2);

  /// Format time in milliseconds
  static String formatTime(int timeInMillis) {
    if (timeInMillis == null || timeInMillis < 0) {
      return "-1 ms";
    }
    if (timeInMillis <= _secondAsMillisecond) {
      return "$timeInMillis ms";
    }
    if (timeInMillis <= _minuteAsMillisecond) {
      return "${_formatDouble(timeInMillis / _secondAsMillisecond)} s";
    }

    Duration duration = Duration(milliseconds: timeInMillis);

    return "${duration.inMinutes} min ${(duration.inSeconds.remainder(60))} s "
        "${duration.inMilliseconds.remainder(1000)} ms";
  }
}
