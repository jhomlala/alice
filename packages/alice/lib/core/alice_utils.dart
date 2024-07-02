import 'package:flutter/foundation.dart' show kReleaseMode, debugPrint;

/// Utils used across multiple classes in app.
class AliceUtils {
  static void log(dynamic logMessage) {
    if (!kReleaseMode) {
      debugPrint(logMessage);
    }
  }
}
