enum AliceTabItem { inspector, logger }

extension AliceTabItemExtension on AliceTabItem {
  String get title {
    switch (this) {
      case AliceTabItem.inspector:
        return 'Inspector';
      case AliceTabItem.logger:
        return 'Logger';
    }
  }
}
