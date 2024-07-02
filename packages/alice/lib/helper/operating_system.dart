import 'package:flutter/foundation.dart';

/// Definition of OS.
abstract class OperatingSystem {
  static const String android = 'android';
  static const String fuchsia = 'fuchsia';
  static const String ios = 'ios';
  static const String linux = 'linux';
  static const String macos = 'macos';
  static const String windows = 'windows';

  static bool isAndroid() {
    return defaultTargetPlatform == TargetPlatform.android;
  }

  static bool isIOS() {
    return defaultTargetPlatform == TargetPlatform.iOS;
  }

  static bool isMacOS() {
    return defaultTargetPlatform == TargetPlatform.macOS;
  }
}
