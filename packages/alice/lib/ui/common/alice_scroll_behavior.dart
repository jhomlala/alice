import 'dart:ui';

import 'package:flutter/material.dart';

/// Scroll behavior for Alice.
class AliceScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };
}
