import 'package:alice/core/alice_core.dart';
import 'package:alice/services/replay/alice_replay_service.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:flutter/material.dart';

class AliceReplayServiceImpl implements AliceReplayService {
  final AliceCore core;

  AliceReplayServiceImpl(this.core);

  @override
  Future<void> replayCall({
    required AliceHttpCall originalCall,
    required BuildContext context,
  }) => throw UnimplementedError('Not supported on this platform');
}
