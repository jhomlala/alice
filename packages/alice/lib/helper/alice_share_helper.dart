import 'package:flutter/widgets.dart';
import 'alice_share_helper_stub.dart'
    if (dart.library.io) 'alice_share_helper_io.dart'
    if (dart.library.js_interop) 'alice_share_helper_web.dart';

abstract class AliceShareHelper {
  static Future<void> share({
    required BuildContext context,
    required String text,
    required String subject,
    Rect? sharePositionOrigin,
  }) {
    return AliceShareProvider.share(
      context: context,
      text: text,
      subject: subject,
      sharePositionOrigin: sharePositionOrigin,
    );
  }
}
