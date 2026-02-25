import 'package:flutter/services.dart';

class TickPlayer {
  Future<void> prime() async {}

  Future<void> tick() async {
    await SystemSound.play(SystemSoundType.click);
  }

  Future<void> accent() async {
    await tick();
    await Future<void>.delayed(const Duration(milliseconds: 70));
    await tick();
  }
}
