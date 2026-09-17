import 'package:flutter/widgets.dart';

class ShareProvider {
  static Future<void> share({
    required BuildContext context,
    required String text,
    required String subject,
    Rect? sharePositionOrigin,
  }) {
    throw UnimplementedError(
      'ShareService is not implemented for this platform.',
    );
  }
}
