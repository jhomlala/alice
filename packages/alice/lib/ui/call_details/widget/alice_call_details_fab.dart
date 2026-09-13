import 'package:alice/core/alice_core.dart';
import 'package:alice/helper/alice_export_helper.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/ui/common/alice_theme.dart';
import 'package:flutter/material.dart';

class AliceCallDetailsFab extends StatelessWidget {
  final AliceHttpCall call;
  final AliceCore core;

  const AliceCallDetailsFab({
    required this.call,
    required this.core,
    super.key,
  });

  static final GlobalKey _shareButtonKey = GlobalKey();
  static final GlobalKey _shareCurlButtonKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final showShare = core.configuration.showShareButton;
    final showCurl = core.configuration.showShareCurlButton;

    if (!showShare && !showCurl) {
      return Container();
    }

    if (showShare && !showCurl) {
      return FloatingActionButton(
        backgroundColor: AliceTheme.lightRed,
        key: _shareButtonKey,
        onPressed: () => _shareCall(context),
        child: const Icon(Icons.share, color: AliceTheme.white),
      );
    }

    if (!showShare && showCurl) {
      return FloatingActionButton(
        backgroundColor: AliceTheme.lightRed,
        key: _shareCurlButtonKey,
        onPressed: () => _shareCurlCall(context),
        child: const Icon(Icons.terminal, color: AliceTheme.white),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          backgroundColor: AliceTheme.lightRed,
          key: _shareCurlButtonKey,
          heroTag: 'share_curl',
          onPressed: () => _shareCurlCall(context),
          child: const Icon(Icons.terminal, color: AliceTheme.white),
        ),
        const SizedBox(height: 8),
        FloatingActionButton(
          backgroundColor: AliceTheme.lightRed,
          key: _shareButtonKey,
          heroTag: 'share',
          onPressed: () => _shareCall(context),
          child: const Icon(Icons.share, color: AliceTheme.white),
        ),
      ],
    );
  }

  void _shareCall(BuildContext context) async {
    final box = _shareButtonKey.currentContext?.findRenderObject() as RenderBox?;
    final sharePositionOrigin = box != null
        ? box.localToGlobal(Offset.zero) & box.size
        : null;

    await AliceExportHelper.shareCall(
      context: context,
      call: call,
      sharePositionOrigin: sharePositionOrigin,
    );
  }

  void _shareCurlCall(BuildContext context) async {
    final box = _shareCurlButtonKey.currentContext?.findRenderObject() as RenderBox?;
    final sharePositionOrigin = box != null
        ? box.localToGlobal(Offset.zero) & box.size
        : null;

    await AliceExportHelper.shareCurlCommand(
      context: context,
      call: call,
      sharePositionOrigin: sharePositionOrigin,
    );
  }
}
