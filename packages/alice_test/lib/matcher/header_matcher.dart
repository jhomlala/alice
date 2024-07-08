import 'package:test/test.dart';

class HeaderMatcher extends Matcher {
  final MapEntry<String, String>? _expected;

  const HeaderMatcher(this._expected);

  @override
  bool matches(Object? item, Map matchState) {
    if (item is Map<String, String>) {
      final mapItem = item[_expected?.key];
      return mapItem == _expected?.value;
    }
    return false;
  }

  @override
  Description describe(Description description) =>
      description.add('contains header').addDescriptionOf(_expected);

  @override
  Description describeMismatch(
    Object? item,
    Description mismatchDescription,
    Map matchState,
    bool verbose,
  ) {
    mismatchDescription
        .add('does not contain header')
        .addDescriptionOf(_expected);
    return mismatchDescription;
  }
}
