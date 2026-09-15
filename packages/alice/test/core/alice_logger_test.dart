import 'package:alice/core/alice_logger.dart';
import 'package:alice/model/alice_log.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AliceLogger aliceLogger;
  setUp(() {
    aliceLogger = AliceLogger(maximumSize: 1000);
  });

  group("AliceLogger", () {
    test("should add log", () {
      final log = AliceLog(message: "test");

      aliceLogger.add(log);

      expect(aliceLogger.logs, [log]);
    });

    test("should add logs", () {
      final logs = [AliceLog(message: "test"), AliceLog(message: "test2")];

      aliceLogger.addAll(logs);

      expect(aliceLogger.logs, logs);
    });

    test("should clear logs", () {
      final logs = [AliceLog(message: "test"), AliceLog(message: "test2")];

      aliceLogger.addAll(logs);

      expect(aliceLogger.logs.isNotEmpty, true);

      aliceLogger.clearLogs();

      expect(aliceLogger.logs.isEmpty, true);
    });

    test("should return empty android raw logs on non-android platforms", () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      final logs = await aliceLogger.getAndroidRawLogs();
      expect(logs, '');
      debugDefaultTargetPlatformOverride = null;
    });

    test("clearAndroidRawLogs should complete without throwing on non-android platforms", () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      expect(aliceLogger.clearAndroidRawLogs(), completes);
      debugDefaultTargetPlatformOverride = null;
    });
  });
}
