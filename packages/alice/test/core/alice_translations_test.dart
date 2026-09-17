import 'package:alice/core/translations.dart';
import 'package:alice/model/translation.dart';
import 'package:test/test.dart';

void main() {
  group("Translations", () {
    test("should return translated value", () {
      expect(
        Translations.get(languageCode: "en", key: TranslationKey.saveLogId),
        "Id:",
      );

      expect(
        Translations.get(languageCode: "en", key: TranslationKey.logsEmpty),
        "There are no logs to show",
      );
    });

    test(
      "should return english translation when there's no translation found",
      () {
        expect(
          Translations.get(languageCode: "xx", key: TranslationKey.saveLogId),
          "Id:",
        );

        expect(
          Translations.get(languageCode: "xx", key: TranslationKey.logsEmpty),
          "There are no logs to show",
        );
      },
    );

    test("should return translated key for other languages", () {
      expect(
        Translations.get(languageCode: "pl", key: TranslationKey.logsEmpty),
        "Brak rezultatów",
      );

      expect(
        Translations.get(
          languageCode: "pl",
          key: TranslationKey.saveLogRequest,
        ),
        "Żądanie",
      );
    });
    test("should return translated value for new search help keys", () {
      expect(
        Translations.get(
          languageCode: "en",
          key: TranslationKey.searchHelpTitle,
        ),
        "Advanced Search",
      );
      expect(
        Translations.get(
          languageCode: "pl",
          key: TranslationKey.searchHelpTitle,
        ),
        "Zaawansowane wyszukiwanie",
      );
    });

    test("should return translated value for replay key", () {
      expect(
        Translations.get(languageCode: "en", key: TranslationKey.replay),
        "♻️ Replay",
      );
      expect(
        Translations.get(languageCode: "pl", key: TranslationKey.replay),
        "♻️ Ponowne",
      );
    });
  });
}
