import 'package:flutter/foundation.dart';

/// Definition of OS.
abstract class OperatingSystem {
  static const String android = 'android';
  static const String fuchsia = 'fuchsia';
  static const String ios = 'ios';
  static const String linux = 'linux';
  static const String macos = 'macos';
  static const String windows = 'windows';

  static bool get isAndroid => defaultTargetPlatform == TargetPlatform.android;

  static bool get isIOS => defaultTargetPlatform == TargetPlatform.iOS;

  static bool get isMacOS => defaultTargetPlatform == TargetPlatform.macOS;

  static bool get isWindows => defaultTargetPlatform == TargetPlatform.windows;

  static bool get isLinux => defaultTargetPlatform == TargetPlatform.linux;

  static bool get isFuchsia => defaultTargetPlatform == TargetPlatform.fuchsia;
}
