import 'dart:ui';

import 'package:material_ui/material_ui.dart';

/// Scroll behavior for Alice.
class CustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };
}
