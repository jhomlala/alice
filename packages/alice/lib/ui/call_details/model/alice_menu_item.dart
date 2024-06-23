import 'package:flutter/material.dart';

class AliceMenuItem {
  const AliceMenuItem(
    this.title,
    this.iconData,
  );

  final String title;
  final IconData iconData;
}

enum AliceMenuItemType { sort, delete, stats, save }
