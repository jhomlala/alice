import 'package:alice/core/alice_core.dart';
import 'package:alice/helper/alice_replay_helper.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/ui/common/alice_dialog.dart';
import 'package:flutter/material.dart';

class AliceReplayHelperImpl implements AliceReplayHelper {
  final AliceCore core;

  AliceReplayHelperImpl(this.core);

  @override
  Future<void> replayCall({
    required AliceHttpCall originalCall,
    required BuildContext context,
  }) async {
    AliceGeneralDialog.show(
      context: context,
      title: 'Error',
      description: 'Replay is not supported on this platform.',
    );
  }
}
