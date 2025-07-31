import 'package:alice/alice.dart';
import 'package:alice/core/alice_core.dart';
import 'package:alice/core/alice_logger.dart';
import 'package:alice/core/alice_storage.dart';
import 'package:alice/model/alice_configuration.dart';
import 'package:alice/model/alice_http_error.dart';
import 'package:alice/model/alice_http_response.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../mock/alice_logger_mock.dart';
import '../mock/alice_storage_mock.dart';
import '../mock/mocked_data.dart';

void main() {
  late AliceCore aliceCore;
  late AliceStorage aliceStorage;
  late AliceLogger aliceLogger;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerFallbackValue(MockedData.getLoadingHttpCall());
    registerFallbackValue(AliceHttpError());
    registerFallbackValue(AliceHttpResponse());
    registerFallbackValue(AliceLog(message: ""));
    aliceStorage = AliceStorageMock();
    aliceLogger = AliceLoggerMock();

    when(
      () => aliceStorage.callsStream,
    ).thenAnswer((_) => const Stream.empty());
    aliceCore = AliceCore(
      configuration: AliceConfiguration(
        showNotification: false,
        showInspectorOnShake: false,
        storage: aliceStorage,
        logger: aliceLogger,
      ),
    );
  });

  group("AliceCore", () {
    test("should use storage to add call", () {
      when(() => aliceStorage.addCall(any())).thenAnswer((_) => () {});

      aliceCore.addCall(MockedData.getLoadingHttpCall());

      verify(() => aliceStorage.addCall(any()));
    });

    test("should use storage to add error", () {
      when(() => aliceStorage.addError(any(), any())).thenAnswer((_) => () {});

      aliceCore.addError(AliceHttpError(), 0);

      verify(() => aliceStorage.addError(any(), any()));
    });

    test("should use storage to add response", () {
      when(
        () => aliceStorage.addResponse(any(), any()),
      ).thenAnswer((_) => () {});

      aliceCore.addResponse(AliceHttpResponse(), 0);

      verify(() => aliceStorage.addResponse(any(), any()));
    });

    test("should use storage to remove calls", () {
      when(() => aliceStorage.removeCalls()).thenAnswer((_) => () {});

      aliceCore.removeCalls();

      verify(() => aliceStorage.removeCalls());
    });

    test("should use storage to get calls stream", () async {
      final calls = [MockedData.getLoadingHttpCall()];
      when(
        () => aliceStorage.callsStream,
      ).thenAnswer((_) => Stream.value(calls));

      expect(await aliceCore.callsStream.first, calls);

      verify(() => aliceStorage.callsStream);
    });

    test("should use storage to get calls", () {
      final calls = [MockedData.getLoadingHttpCall()];
      when(() => aliceStorage.getCalls()).thenAnswer((_) => calls);

      expect(aliceCore.getCalls(), calls);

      verify(() => aliceStorage.getCalls());
    });

    test("should use logger to add log", () {
      when(() => aliceLogger.add(any())).thenAnswer((_) => {});

      aliceCore.addLog(AliceLog(message: "test"));

      verify(() => aliceCore.addLog(any()));
    });

    test("should use logger to add logs", () {
      when(() => aliceLogger.addAll(any())).thenAnswer((_) => {});

      aliceCore.addLogs([AliceLog(message: "test")]);

      verify(() => aliceCore.addLogs(any()));
    });
  });
}
