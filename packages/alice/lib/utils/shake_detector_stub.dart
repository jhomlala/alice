/// Callback for phone shakes
typedef PhoneShakeCallback = void Function();

/// No-op ShakeDetector for platforms that don't support accelerometer sensors
/// (e.g. Windows, Linux, macOS).
class ShakeDetector {
  final PhoneShakeCallback? onPhoneShake;
  final double shakeThresholdGravity;
  final int shakeSlopTimeMS;
  final int shakeCountResetTime;

  ShakeDetector.waitForStart({
    this.onPhoneShake,
    this.shakeThresholdGravity = 2.7,
    this.shakeSlopTimeMS = 500,
    this.shakeCountResetTime = 3000,
  });

  ShakeDetector.autoStart({
    this.onPhoneShake,
    this.shakeThresholdGravity = 2.7,
    this.shakeSlopTimeMS = 500,
    this.shakeCountResetTime = 3000,
  });

  /// No-op on unsupported platforms.
  void startListening() {}

  /// No-op on unsupported platforms.
  void stopListening() {}

  /// No-op on unsupported platforms.
  void dispose() {}
}
