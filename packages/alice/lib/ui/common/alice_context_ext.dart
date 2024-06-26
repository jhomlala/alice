  import 'package:alice/model/alice_translation.dart';
import 'package:alice/ui/common/alice_translations.dart';
import 'package:flutter/material.dart';

extension AliceContextExt on BuildContext{
  String i18n(AliceTranslationKey key){
    try{
      final locale = Localizations.localeOf(this);
      final languageCode = locale.languageCode;
      return AliceTranslations.get(languageCode: languageCode, key: key);

    } catch (error){
      return key.toString();
    }
  }
}