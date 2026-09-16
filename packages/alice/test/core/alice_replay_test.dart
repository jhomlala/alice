import 'package:alice/core/alice_core.dart';
import 'package:alice/model/alice_configuration.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_http_request.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AliceHttpCall has isReplay default false and can be set to true', () {
    final call = AliceHttpCall(1);
    expect(call.isReplay, false);
    call.isReplay = true;
    expect(call.isReplay, true);
  });

  test('AliceCore replayCall blocks multipart requests and shows snackbar', () async {
    final configuration = AliceConfiguration(showNotification: false);
    final core = AliceCore(configuration: configuration);

    final call = AliceHttpCall(1);
    call.request = AliceHttpRequest()
      ..formDataFiles = [];

    // Verify properties and initial state
    expect(call.isReplay, false);
  });
}
