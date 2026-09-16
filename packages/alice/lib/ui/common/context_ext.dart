import 'package:alice/model/translation.dart';
import 'package:alice/core/translations.dart';
import 'package:material_ui/material_ui.dart';

/// Extension for [BuildContext].
extension ContextExt on BuildContext {
  /// Tries to translate given key based on current language code collected from
  /// locale. If it fails to translate [key], it will return [key] itself.
  String i18n(TranslationKey key) {
    try {
      final locale = Localizations.localeOf(this);
      return Translations.get(languageCode: locale.languageCode, key: key);
    } catch (error) {
      return key.toString();
    }
  }
}
