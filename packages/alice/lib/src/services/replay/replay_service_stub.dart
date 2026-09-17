import 'package:alice/src/core/alice_core.dart';
import 'package:alice/src/services/replay/replay_service.dart';
import 'package:alice/src/model/alice_http_call.dart';
import 'package:flutter/material.dart';

class ReplayServiceImpl implements ReplayService {
  final AliceCore core;

  ReplayServiceImpl(this.core);

  @override
  Future<void> replayCall({
    required AliceHttpCall originalCall,
    required BuildContext context,
  }) => throw UnimplementedError('Not supported on this platform');
}
