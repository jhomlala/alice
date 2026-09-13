import 'dart:async';
import 'dart:math';

import 'package:sensors_plus/sensors_plus.dart';

/// Callback for phone shakes
typedef PhoneShakeCallback = void Function();

/// ShakeDetector class for phone shake functionality
class ShakeDetector {
  /// User callback for phone shake
  final PhoneShakeCallback? onPhoneShake;

  /// Shake detection threshold
  final double shakeThresholdGravity;

  /// Minimum time between shake
  final int shakeSlopTimeMS;

  /// Time before shake count resets
  final int shakeCountResetTime;

  int _shakeTimestamp = DateTime.now().millisecondsSinceEpoch;
  // ignore: unused_field
  int _shakeCount = 0;

  /// StreamSubscription for Accelerometer events
  StreamSubscription<AccelerometerEvent>? streamSubscription;

  /// This constructor waits until [startListening] is called
  ShakeDetector.waitForStart({
    this.onPhoneShake,
    this.shakeThresholdGravity = 2.7,
    this.shakeSlopTimeMS = 500,
    this.shakeCountResetTime = 3000,
  });

  /// This constructor automatically calls [startListening] and starts detection and callbacks.\
  ShakeDetector.autoStart({
    this.onPhoneShake,
    this.shakeThresholdGravity = 2.7,
    this.shakeSlopTimeMS = 500,
    this.shakeCountResetTime = 3000,
  }) {
    startListening();
  }

  /// Starts listening to accelerometer events
  void startListening() {
    streamSubscription = accelerometerEventStream().listen(
      _onAccelerometerEvent,
    );
  }

  void _onAccelerometerEvent(AccelerometerEvent event) {
    const double g = 9.80665;
    final double gX = event.x / g;
    final double gY = event.y / g;
    final double gZ = event.z / g;

    // gForce will be close to 1 when there is no movement.
    final double gForce = sqrt(gX * gX + gY * gY + gZ * gZ);

    if (gForce > shakeThresholdGravity) {
      final int now = DateTime.now().millisecondsSinceEpoch;
      // ignore shake events too close to each other (500ms)
      if (_shakeTimestamp + shakeSlopTimeMS > now) {
        return;
      }

      // reset the shake count after 3 seconds of no shakes
      if (_shakeTimestamp + shakeCountResetTime < now) {
        _shakeCount = 0;
      }

      _shakeTimestamp = now;
      _shakeCount++;

      onPhoneShake?.call();
    }
  }

  /// Stops listening to accelerometer events
  void stopListening() {
    dispose();
  }

  /// Disposes all subscriptions.
  void dispose() {
    streamSubscription?.cancel();
    streamSubscription = null;
  }
}
