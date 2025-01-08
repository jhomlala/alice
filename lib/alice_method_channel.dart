import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'alice_platform_interface.dart';

/// An implementation of [AlicePlatform] that uses method channels.
class MethodChannelAlice extends AlicePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('alice');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
