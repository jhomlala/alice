import 'package:flutter/widgets.dart';
import 'package:share_plus/share_plus.dart';

class AliceShareProvider {
  static Future<void> share({
    required BuildContext context,
    required String text,
    required String subject,
    Rect? sharePositionOrigin,
  }) async {
    await SharePlus.instance.share(
      ShareParams(
        text: text,
        subject: subject,
        sharePositionOrigin: sharePositionOrigin,
      ),
    );
  }
}
