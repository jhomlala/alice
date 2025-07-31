import 'package:alice/core/alice_core.dart';
import 'package:alice/ui/common/alice_theme.dart';
import 'package:flutter/material.dart';

/// Common page widget which is used across Alice pages.
class AlicePage extends StatelessWidget {
  const AlicePage({super.key, required this.core, required this.child});

  final AliceCore core;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          core.configuration.directionality ?? Directionality.of(context),
      child: Theme(data: AliceTheme.getTheme(), child: child),
    );
  }
}
