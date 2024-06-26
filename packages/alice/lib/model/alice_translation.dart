/// Definition of translations for specific locale
class AliceTranslationData {
  final String languageCode;
  final Map<AliceTranslationKey, String> values;

  AliceTranslationData({
    required this.languageCode,
    required this.values,
  });
}

/// Translation keys
enum AliceTranslationKey {
  callDetailsOverview,
  callDetailsRequest,
  callDetailsResponse,
  callDetailsError
}
