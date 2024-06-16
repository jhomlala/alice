///Available sort options in inspector UI.
enum AliceSortOption {
  time,
  responseTime,
  responseCode,
  responseSize,
  endpoint,
}

extension AliceSortOptionsExtension on AliceSortOption {
  String get name => switch (this) {
        AliceSortOption.time => 'Create time (default)',
        AliceSortOption.responseTime => 'Response time',
        AliceSortOption.responseCode => 'Response code',
        AliceSortOption.responseSize => 'Response size',
        AliceSortOption.endpoint => 'Endpoint',
      };
}
