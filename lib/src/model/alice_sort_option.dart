///Available sort options in inspector UI.
enum AliceSortOption {
  time,
  responseTime,
  responseCode,
  responseSize,
  endpoint,
}

extension AliceSortOptionsExtension on AliceSortOption {
  String get name {
    switch (this) {
      case AliceSortOption.time:
        return "Create time (default)";
      case AliceSortOption.responseTime:
        return "Response time";
      case AliceSortOption.responseCode:
        return "Response code";
      case AliceSortOption.responseSize:
        return "Response size";
      case AliceSortOption.endpoint:
        return "Endpoint";
    }
  }
}
