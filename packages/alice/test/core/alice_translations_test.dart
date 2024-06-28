import 'package:alice/core/alice_translations.dart';
import 'package:alice/model/alice_translation.dart';
import 'package:test/test.dart';

void main() {
  group("AliceTranslations", () {
    test("should return translated key", () {
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

    test("should return key when there's no translation found", () {
      expect(
        AliceTranslations.get(
          languageCode: "xx",
          key: AliceTranslationKey.saveLogId,
        ),
        AliceTranslationKey.saveLogId.toString(),
      );

      expect(
        AliceTranslations.get(
          languageCode: "xx",
          key: AliceTranslationKey.logsEmpty,
        ),
        AliceTranslationKey.logsEmpty.toString(),
      );
    });
  });
}
