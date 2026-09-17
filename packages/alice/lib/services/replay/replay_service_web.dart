import 'package:alice/core/alice_core.dart';
import 'package:alice/services/replay/replay_service.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/translation.dart';
import 'package:alice/ui/common/context_ext.dart';
import 'package:alice/ui/common/dialog.dart';
import 'package:flutter/material.dart';

class ReplayServiceImpl implements ReplayService {
  final AliceCore core;

  ReplayServiceImpl(this.core);

  @override
  Future<void> replayCall({
    required AliceHttpCall originalCall,
    required BuildContext context,
  }) async {
    AliceGeneralDialog.show(
      context: context,
      title: context.i18n(TranslationKey.callDetailsError),
      description: context.i18n(TranslationKey.replayNotSupportedOnPlatform),
    );
  }
}
