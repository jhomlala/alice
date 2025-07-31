import 'package:alice/core/alice_translations.dart';
import 'package:alice/model/alice_translation.dart';
import 'package:test/test.dart';

void main() {
  group("AliceTranslations", () {
    test("should return translated value", () {
      expect(
        AliceTranslations.get(
          languageCode: "en",
          key: AliceTranslationKey.saveLogId,
        ),
        "Id:",
      );

      expect(
        AliceTranslations.get(
          languageCode: "en",
          key: AliceTranslationKey.logsEmpty,
        ),
        "There are no logs to show",
      );
    });

    test(
      "should return english translation when there's no translation found",
      () {
        expect(
          AliceTranslations.get(
            languageCode: "xx",
            key: AliceTranslationKey.saveLogId,
          ),
          "Id:",
        );

        expect(
          AliceTranslations.get(
            languageCode: "xx",
            key: AliceTranslationKey.logsEmpty,
          ),
          "There are no logs to show",
        );
      },
    );

    test("should return translated key for other languages", () {
      expect(
        AliceTranslations.get(
          languageCode: "pl",
          key: AliceTranslationKey.logsEmpty,
        ),
        "Brak rezultatów",
      );

      expect(
        AliceTranslations.get(
          languageCode: "pl",
          key: AliceTranslationKey.saveLogRequest,
        ),
        "Żądanie",
      );
    });
  });
}
