import 'package:alice/src/core/alice_core.dart';
import 'replay_service_stub.dart'
    if (dart.library.io) 'replay_service_io.dart'
    if (dart.library.js_interop) 'replay_service_web.dart';
import 'package:alice/src/model/alice_http_call.dart';
import 'package:flutter/material.dart';

abstract class ReplayService {
  factory ReplayService(AliceCore core) => ReplayServiceImpl(core);

  Future<void> replayCall({
    required AliceHttpCall originalCall,
    required BuildContext context,
  });
}
