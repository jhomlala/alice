import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'alice_method_channel.dart';

abstract class AlicePlatform extends PlatformInterface {
  /// Constructs a AlicePlatform.
  AlicePlatform() : super(token: _token);

  static final Object _token = Object();

  static AlicePlatform _instance = MethodChannelAlice();

  /// The default instance of [AlicePlatform] to use.
  ///
  /// Defaults to [MethodChannelAlice].
  static AlicePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AlicePlatform] when
  /// they register themselves.
  static set instance(AlicePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
