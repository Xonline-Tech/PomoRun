import 'package:vibration/vibration.dart';

class HapticsService {
  Future<bool> get hasVibrator async {
    final value = await Vibration.hasVibrator();
    return value ?? false;
  }

  Future<void> shortPulse() async {
    if (!await hasVibrator) return;
    await Vibration.vibrate(duration: 25, amplitude: 96);
  }

  Future<void> doublePulse() async {
    if (!await hasVibrator) return;
    await Vibration.vibrate(pattern: <int>[0, 30, 50, 40], amplitudes: <int>[0, 128, 0, 160]);
  }
}
