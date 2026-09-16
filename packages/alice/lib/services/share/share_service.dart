import 'package:flutter/widgets.dart';
import 'share_service_stub.dart'
    if (dart.library.io) 'share_service_io.dart'
    if (dart.library.js_interop) 'share_service_web.dart';

abstract class ShareService {
  static Future<void> share({
    required BuildContext context,
    required String text,
    required String subject,
    Rect? sharePositionOrigin,
  }) {
    return ShareProvider.share(
      context: context,
      text: text,
      subject: subject,
      sharePositionOrigin: sharePositionOrigin,
    );
  }
}
