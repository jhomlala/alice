/// Extension used to compare numbers.
extension NumComparison on num? {
  bool get isZero => this != null && this! == 0;

  bool get notZero => this != null && this! != 0;

  bool lt(num? n) => this != null && n != null && this! < n;

  bool lte(num? n) => this != null && n != null && this! <= n;

  bool eq(num? n) => this != null && n != null && this! == n;

  bool gte(num? n) => this != null && n != null && this! >= n;

  bool gt(num? n) => this != null && n != null && this! > n;
}
