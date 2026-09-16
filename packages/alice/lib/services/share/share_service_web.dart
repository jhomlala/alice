import 'package:alice/model/translation.dart';
import 'package:alice/ui/common/context_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ShareProvider {
  static Future<void> share({
    required BuildContext context,
    required String text,
    required String subject,
    Rect? sharePositionOrigin,
  }) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.i18n(TranslationKey.logsCopied))),
      );
    }
  }
}
