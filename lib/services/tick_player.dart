import 'package:flutter/services.dart';

class TickPlayer {
  Future<void> tick() async {
    await SystemSound.play(SystemSoundType.click);
  }

  Future<void> accent() async {
    await SystemSound.play(SystemSoundType.click);
    await Future<void>.delayed(const Duration(milliseconds: 60));
    await SystemSound.play(SystemSoundType.click);
  }
}
