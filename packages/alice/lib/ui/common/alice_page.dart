import 'package:alice/core/alice_core.dart';
import 'package:alice/utils/alice_theme.dart';
import 'package:flutter/material.dart';

class AlicePage extends StatelessWidget {
  const AlicePage({super.key, required this.core, required this.child});

  final AliceCore core;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: core.directionality ?? Directionality.of(context),
      child: Theme(
        data: AliceTheme.getTheme(),
        child: child,
      ),
    );
  }
}
