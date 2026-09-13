import 'package:alice/core/alice_core.dart';
import 'package:alice/helper/alice_export_helper.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/ui/common/alice_theme.dart';
import 'package:flutter/material.dart';

class AliceCallDetailsFab extends StatefulWidget {
  final AliceHttpCall call;
  final AliceCore core;

  const AliceCallDetailsFab({
    required this.call,
    required this.core,
    super.key,
  });

  @override
  State<AliceCallDetailsFab> createState() => _AliceCallDetailsFabState();
}

class _AliceCallDetailsFabState extends State<AliceCallDetailsFab> {
  bool _isExpanded = false;

  static final GlobalKey _shareButtonKey = GlobalKey();
  static final GlobalKey _shareCurlButtonKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final showShare = widget.core.configuration.showShareButton;
    final showCurl = showShare; // Always show curl if share is shown

    if (!showShare) {
      return Container();
    }

    // Both enabled: show expandable FAB
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_isExpanded) ...[
          FloatingActionButton.extended(
            key: _shareCurlButtonKey,
            backgroundColor: AliceTheme.lightRed,
            onPressed: () => _shareCurlCall(),
            label: Text(context.i18n(AliceTranslationKey.actionShareCurl)),
            icon: const Icon(Icons.terminal, color: AliceTheme.white),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.extended(
            key: _shareButtonKey,
            backgroundColor: AliceTheme.lightRed,
            onPressed: () => _shareCall(),
            label: Text(context.i18n(AliceTranslationKey.actionShare)),
            icon: const Icon(Icons.share, color: AliceTheme.white),
          ),
          const SizedBox(height: 8),
        ],
        FloatingActionButton(
          backgroundColor: AliceTheme.lightRed,
          onPressed: () => setState(() => _isExpanded = !_isExpanded),
          child: Icon(
            _isExpanded ? Icons.close : Icons.share,
            color: AliceTheme.white,
          ),
        ),
      ],
    );
  }

  Future<void> _shareCall() async {
    final box = _shareButtonKey.currentContext?.findRenderObject() as RenderBox?;
    final sharePositionOrigin =
        box != null ? box.localToGlobal(Offset.zero) & box.size : null;
    await AliceExportHelper.shareCall(
      context: context,
      call: widget.call,
      sharePositionOrigin: sharePositionOrigin,
    );
    setState(() => _isExpanded = false);
  }

  Future<void> _shareCurlCall() async {
    final box =
        _shareCurlButtonKey.currentContext?.findRenderObject() as RenderBox?;
    final sharePositionOrigin =
        box != null ? box.localToGlobal(Offset.zero) & box.size : null;
    await AliceExportHelper.shareCurlCommand(
      context: context,
      call: widget.call,
      sharePositionOrigin: sharePositionOrigin,
    );
    setState(() => _isExpanded = false);
  }
}
