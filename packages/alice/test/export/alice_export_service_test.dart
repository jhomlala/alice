import 'dart:io';

import 'package:alice/src/export/export_service.dart';
import 'package:alice/src/export/text_exporter.dart';
import 'package:alice/src/model/export_result.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../mock/build_context_mock.dart';
import '../mock/mocked_data.dart';

void main() {
  late BuildContext context;
  setUp(() {
    context = BuildContextMock();
  });

  group("ExportService", () {
    test("should build correct call log using TextExporter", () async {
      _setPackageInfo();

      final result = await TextExporter().buildFullCallLog(
        context: context,
        call: MockedData.getFilledHttpCall(),
      );
      _verifyLogLines(result!);
    });

    test("should save call log to file using exportCalls", () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      _setPackageInfo();
      _setPathProvider();
      _setDefaultTargetPlatform();

      final result = await ExportService.exportCalls(
        context: context,
        calls: [MockedData.getFilledHttpCall()],
        exporter: TextExporter(),
      );
      expect(result.success, true);
      expect(result.path != null, true);
      expect(result.error, null);

      final file = File(result.path!);
      expect(file.existsSync(), true);
      final content = await file.readAsString();
      _verifyLogLines(content);
      file.delete();
    });
  });

  test("should not save empty call log to file", () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    _setPackageInfo();
    _setPathProvider();
    _setDefaultTargetPlatform();

    final result = await ExportService.exportCalls(
      context: context,
      calls: [],
      exporter: TextExporter(),
    );

    expect(result.success, false);
    expect(result.path, null);
    expect(result.error, ExportResultError.empty);
  });

  test("should not save call log to file if file problem occurs", () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    _setPackageInfo();
    _setPathProvider(isFailing: true);
    _setDefaultTargetPlatform();

    final result = await ExportService.exportCalls(
      context: context,
      calls: [MockedData.getFilledHttpCall()],
      exporter: TextExporter(),
    );

    expect(result.success, false);
    expect(result.path, null);
    expect(result.error, ExportResultError.file);
  });

  test("should share call log", () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    _setPackageInfo();
    _setShare();

    final result = await ExportService.shareCall(
      context: context,
      call: MockedData.getFilledHttpCall(),
    );
    expect(result.success, true);
    expect(result.error, null);
  });
}

void _verifyLogLines(String result) {
  var lines = [
    'TranslationKey.saveHeaderTitle',
    'TranslationKey.saveHeaderAppName  Alice',
    'TranslationKey.saveHeaderPackage pl.hasoft.alice',
    'TranslationKey.saveHeaderTitle 1.0',
    'TranslationKey.saveHeaderBuildNumber 1',
    'TranslationKey.saveHeaderGenerated',
    '',
    '===========================================',
    'TranslationKey.saveLogId',
    '============================================',
    '--------------------------------------------',
    'TranslationKey.saveLogGeneralData',
    '--------------------------------------------',
    'TranslationKey.saveLogServer https://test.com ',
    'TranslationKey.saveLogMethod POST ',
    'TranslationKey.saveLogEndpoint /test ',
    'TranslationKey.saveLogClient  ',
    'TranslationKey.saveLogDuration 0 ms',
    'TranslationKey.saveLogSecured true',
    'TranslationKey.saveLogCompleted: true ',
    '--------------------------------------------',
    'TranslationKey.saveLogRequest',
    '--------------------------------------------',
    'TranslationKey.saveLogRequestTime',
    'TranslationKey.saveLogRequestContentType: application/json',
    'TranslationKey.saveLogRequestCookies []',
    'TranslationKey.saveLogRequestHeaders {}',
    'TranslationKey.saveLogRequestSize 0 B',
    'TranslationKey.saveLogRequestBody {',
    '  "id": 0',
    '}',
    '--------------------------------------------',
    'TranslationKey.saveLogResponse',
    '--------------------------------------------',
    'TranslationKey.saveLogResponseTime',
    'TranslationKey.saveLogResponseStatus 0',
    'TranslationKey.saveLogResponseSize 0 B',
    'TranslationKey.saveLogResponseHeaders {}',
    'TranslationKey.saveLogResponseBody {"id": 0}',
    '--------------------------------------------',
    'TranslationKey.saveLogCurl',
    '--------------------------------------------',
    'curl -X POST ',
    '==============================================',
    '',
  ];
  for (var line in lines) {
    expect(result.contains(line), true);
  }
}

void _setPackageInfo() {
  PackageInfo.setMockInitialValues(
    appName: "Alice",
    packageName: "pl.hasoft.alice",
    version: "1.0",
    buildNumber: "1",
    buildSignature: "buildSignature",
  );
}

void _setPathProvider({bool isFailing = false}) {
  const MethodChannel channel = MethodChannel(
    'plugins.flutter.io/path_provider',
  );
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (isFailing) {
          return "";
        } else {
          return ".";
        }
      });
}

void _setDefaultTargetPlatform() {
  debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
}

void _setShare() {
  const MethodChannel channel = MethodChannel(
    'dev.fluttercommunity.plus/share',
  );
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        return ".";
      });
}
