import 'package:vibration/vibration.dart';

class HapticsService {
  Future<bool> get hasVibrator async {
    final value = await Vibration.hasVibrator();
    return value ?? false;
  }

  Future<void> shortPulse() async {
    if (!await hasVibrator) return;
    try {
      await Vibration.vibrate(duration: 25);
    } catch (_) {
      // Ignore haptics failures on unsupported devices.
    }
  }

  Future<void> doublePulse() async {
    if (!await hasVibrator) return;
    try {
      await Vibration.vibrate(pattern: <int>[0, 30, 50, 40]);
    } catch (_) {
      // Ignore haptics failures on unsupported devices.
    }
  }
}
