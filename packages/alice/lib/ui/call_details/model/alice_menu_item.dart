import 'package:flutter/material.dart';

/// Definition of menu item used in call details.
class AliceCallDetailsMenuItem {
  const AliceCallDetailsMenuItem(this.title, this.iconData);

  final String title;
  final IconData iconData;
}

/// Definition of all call details menu item types.
enum AliceCallDetailsMenuItemType { sort, delete, stats, save }
