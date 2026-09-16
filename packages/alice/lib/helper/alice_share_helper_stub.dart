import 'package:flutter/widgets.dart';

class AliceShareProvider {
  static Future<void> share({
    required BuildContext context,
    required String text,
    required String subject,
    Rect? sharePositionOrigin,
  }) {
    throw UnimplementedError(
      'AliceShareHelper is not implemented for this platform.',
    );
  }
}
