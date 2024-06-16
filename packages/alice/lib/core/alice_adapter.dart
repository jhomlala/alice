import 'package:alice/core/alice_core.dart';

mixin AliceAdapter {
  late final AliceCore aliceCore;

  void injectCore(AliceCore aliceCore) => this.aliceCore = aliceCore;
}
