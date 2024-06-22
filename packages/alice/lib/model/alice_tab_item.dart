enum AliceTabItem {
  inspector,
  logger,
}

extension AliceTabItemExtension on AliceTabItem {
  String get title => switch (this) {
        AliceTabItem.inspector => 'Inspector',
        AliceTabItem.logger => 'Logger',
      };
}
