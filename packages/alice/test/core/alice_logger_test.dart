import 'package:alice/core/alice_logger.dart';
import 'package:alice/model/alice_log.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

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
  });
}
