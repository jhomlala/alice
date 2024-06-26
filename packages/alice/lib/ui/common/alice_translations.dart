import 'package:alice/model/alice_translation.dart';

class AliceTranslations {
  static final List<AliceTranslationData> _translations = _initialise();

  static List<AliceTranslationData> _initialise() {
    List<AliceTranslationData> translations = [];
    translations.add(_buildEnTranslations());
    return translations;
  }

  static AliceTranslationData _buildEnTranslations() {
    return AliceTranslationData(languageCode: "en", values: {
      AliceTranslationKey.callDetailsRequest: "Request",
      AliceTranslationKey.callDetailsResponse: "Response",
      AliceTranslationKey.callDetailsOverview: "Overview",
      AliceTranslationKey.callDetailsError: "Error",
    });
  }

  static String get({
    required String languageCode,
    required AliceTranslationKey key,
  }) {
    try {
      final data = _translations
          .firstWhere((element) => element.languageCode == languageCode);
      final value = data.values[key] ?? key.toString();
      return value;
    } catch (error) {
      return key.toString();
    }
  }
}
