import 'package:alice/export/export_service.dart';
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

  test("should share curl command", () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    _setPackageInfo();
    _setShare();

    final result = await ExportService.shareCurlCommand(
      context: context,
      call: MockedData.getFilledHttpCall(),
    );
    expect(result.success, true);
    expect(result.error, null);
  });
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

void _setShare() {
  const MethodChannel channel = MethodChannel(
    'dev.fluttercommunity.plus/share',
  );
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        return ".";
      });
}
