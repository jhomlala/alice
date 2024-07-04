import 'package:flutter/foundation.dart';

/// Definition of OS.
abstract class OperatingSystem {
  static const String android = 'android';
  static const String fuchsia = 'fuchsia';
  static const String ios = 'ios';
  static const String linux = 'linux';
  static const String macos = 'macos';
  static const String windows = 'windows';

  /// Flag which determines whether current platform is Android.
  static bool get isAndroid => defaultTargetPlatform == TargetPlatform.android;

  /// Flag which determines whether current platform is iOS.
  static bool get isIOS => defaultTargetPlatform == TargetPlatform.iOS;

  /// Flag which determines whether current platform is MacOS.
  static bool get isMacOS => defaultTargetPlatform == TargetPlatform.macOS;

  /// Flag which determines whether current platform is Windows.
  static bool get isWindows => defaultTargetPlatform == TargetPlatform.windows;

  /// Flag which determines whether current platform is Linux.
  static bool get isLinux => defaultTargetPlatform == TargetPlatform.linux;

  /// Flag which determines whether current platform is Fuchsia.
  static bool get isFuchsia => defaultTargetPlatform == TargetPlatform.fuchsia;
}
