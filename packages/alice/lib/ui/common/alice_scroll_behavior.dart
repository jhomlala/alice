import 'dart:ui';

import 'package:material_ui/material_ui.dart';

/// Scroll behavior for Alice.
class AliceScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };
}
