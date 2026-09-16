import 'package:alice/core/alice_core.dart';
import 'package:alice/export/export_service.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/ui/common/theme.dart';
import 'package:material_ui/material_ui.dart';

class CallDetailsFab extends StatefulWidget {
  final AliceHttpCall call;
  final AliceCore core;

  const CallDetailsFab({
    required this.call,
    required this.core,
    super.key,
  });

  @override
  State<CallDetailsFab> createState() => _AliceCallDetailsFabState();
}

class _AliceCallDetailsFabState extends State<CallDetailsFab> {
  bool _isExpanded = false;

  static final GlobalKey _shareButtonKey = GlobalKey();
  static final GlobalKey _shareCurlButtonKey = GlobalKey();
  static final GlobalKey _replayButtonKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final showShare = widget.core.configuration.showShareButton;

    if (!showShare) {
      return const SizedBox.shrink();
    }

    // Both enabled: show expandable FAB
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_isExpanded) ...[
          FloatingActionButton(
            key: _replayButtonKey,
            mini: true,
            backgroundColor: AliceAppTheme.lightRed,
            onPressed: () => _replayCall(),
            child: const Icon(Icons.replay, color: AliceAppTheme.white),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            key: _shareCurlButtonKey,
            mini: true,
            backgroundColor: AliceAppTheme.lightRed,
            onPressed: () => _shareCurlCall(),
            child: const Icon(Icons.terminal, color: AliceAppTheme.white),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            key: _shareButtonKey,
            mini: true,
            backgroundColor: AliceAppTheme.lightRed,
            onPressed: () => _shareCall(),
            child: const Icon(Icons.share, color: AliceAppTheme.white),
          ),
          const SizedBox(height: 8),
        ],
        FloatingActionButton(
          backgroundColor: AliceAppTheme.lightRed,
          onPressed: () => setState(() => _isExpanded = !_isExpanded),
          child: Icon(
            _isExpanded ? Icons.close : Icons.menu,
            color: AliceAppTheme.white,
          ),
        ),
      ],
    );
  }

  Future<void> _shareCall() async {
    final box =
        _shareButtonKey.currentContext?.findRenderObject() as RenderBox?;
    final sharePositionOrigin =
        box != null ? box.localToGlobal(Offset.zero) & box.size : null;
    await ExportService.shareCall(
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
    await ExportService.shareCurlCommand(
      context: context,
      call: widget.call,
      sharePositionOrigin: sharePositionOrigin,
    );
    setState(() => _isExpanded = false);
  }

  Future<void> _replayCall() async {
    await widget.core.replayCall(originalCall: widget.call, context: context);
    setState(() => _isExpanded = false);
  }
}
