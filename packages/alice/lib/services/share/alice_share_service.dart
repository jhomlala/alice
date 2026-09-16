import 'package:flutter/widgets.dart';
import 'alice_share_service_stub.dart'
    if (dart.library.io) 'alice_share_service_io.dart'
    if (dart.library.js_interop) 'alice_share_service_web.dart';

abstract class AliceShareService {
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
