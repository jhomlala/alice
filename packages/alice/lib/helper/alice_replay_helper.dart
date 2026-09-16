import 'package:alice/core/alice_core.dart';
import 'package:alice/helper/alice_replay_helper_stub.dart'
    if (dart.library.io) 'package:alice/helper/alice_replay_helper_io.dart'
    if (dart.library.js_interop) 'package:alice/helper/alice_replay_helper_web.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:flutter/material.dart';

abstract class AliceReplayHelper {
  Future<void> replayCall({
    required AliceHttpCall originalCall,
    required BuildContext context,
  });

  factory AliceReplayHelper(AliceCore core) => getReplayHelper(core);
}
