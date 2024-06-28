  import 'dart:io';

import 'package:alice/model/alice_translation.dart';
import 'package:alice/core/alice_translations.dart';
import 'package:flutter/material.dart';

extension AliceContextExt on BuildContext{
  String i18n(AliceTranslationKey key){
    try{
      final locale =Platform.localeName;

      final languageCode = locale.split("_").first;
      return AliceTranslations.get(languageCode: languageCode, key: key);

    } catch (error){
      return key.toString();
    }
  }
}