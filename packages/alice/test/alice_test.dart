import 'package:alice/alice.dart';
import 'package:alice/core/alice_adapter.dart';
import 'package:alice/core/alice_logger.dart';
import 'package:alice/core/alice_storage.dart';
import 'package:alice/model/alice_configuration.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mock/mocked_data.dart';

void main() {
  group("Alice", () {
    late Alice alice;
    late AliceStorage aliceStorage;
    late AliceLogger aliceLogger;
    setUp(() {
      aliceStorage = AliceMemoryStorage(maxCallsCount: 1000);
      aliceLogger = AliceLogger(maximumSize: 1000);
      alice = Alice(
        configuration: AliceConfiguration(
          showInspectorOnShake: false,
          showNotification: false,
          logger: aliceLogger,
          storage: aliceStorage,
        ),
      );
    });

    test("should set new navigator key", () {
      final navigatorKey = GlobalKey<NavigatorState>();

      expect(alice.getNavigatorKey() != navigatorKey, true);

      alice.setNavigatorKey(navigatorKey);

      expect(alice.getNavigatorKey() == navigatorKey, true);
    });

    test("should add log", () {
      final log = AliceLog(message: "test");

      alice.addLog(log);

      expect(aliceLogger.logs, [log]);
    });

    test("should add logs", () {
      final logs = [AliceLog(message: "test 1"), AliceLog(message: "test 2")];

      alice.addLogs(logs);

      expect(aliceLogger.logs, logs);
    });

    test("should add call", () {
      final call = MockedData.getFilledHttpCall();

      alice.addHttpCall(call);

      expect(aliceStorage.getCalls(), [call]);
    });

    test("should add adapter", () {
      final call = MockedData.getFilledHttpCall();
      final adapter = FakeAdapter();
      alice.addAdapter(adapter);

      adapter.addCallLog(call);

      expect(aliceStorage.getCalls(), [call]);
    });

    test("should return is inspector opened flag", () {
      expect(alice.isInspectorOpened, false);
    });
  });
}

class FakeAdapter with AliceAdapter {
  void addCallLog(AliceHttpCall call) {
    aliceCore.addCall(call);
  }
}
