import 'package:alice/model/alice_translation.dart';
import 'package:alice/core/alice_translations.dart';
import 'package:flutter/material.dart';

extension AliceContextExt on BuildContext {
  String i18n(AliceTranslationKey key) {
    try {
      final locale = Localizations.localeOf(this);
      return AliceTranslations.get(languageCode: locale.languageCode, key: key);
    } catch (error) {
      return key.toString();
    }
  }
}
