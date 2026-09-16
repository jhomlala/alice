import 'package:alice/core/alice_core.dart';
import 'alice_replay_service_stub.dart'
    if (dart.library.io) 'alice_replay_service_io.dart'
    if (dart.library.js_interop) 'alice_replay_service_web.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:flutter/material.dart';

abstract class AliceReplayService {
  factory AliceReplayService(AliceCore core) => AliceReplayServiceImpl(core);

  Future<void> replayCall({
    required AliceHttpCall originalCall,
    required BuildContext context,
  });
}
