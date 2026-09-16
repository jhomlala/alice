import 'package:alice/core/alice_core.dart';
import 'package:alice/services/replay/alice_replay_service.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_translation.dart';
import 'package:alice/ui/common/alice_context_ext.dart';
import 'package:alice/ui/common/alice_dialog.dart';
import 'package:flutter/material.dart';

class AliceReplayServiceImpl implements AliceReplayService {
  final AliceCore core;

  AliceReplayServiceImpl(this.core);

  @override
  Future<void> replayCall({
    required AliceHttpCall originalCall,
    required BuildContext context,
  }) async {
    AliceGeneralDialog.show(
      context: context,
      title: context.i18n(AliceTranslationKey.callDetailsError),
      description: context.i18n(
        AliceTranslationKey.replayNotSupportedOnPlatform,
      ),
    );
  }
}
