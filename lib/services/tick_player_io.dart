import 'dart:io' show Platform;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

import 'beep_wav.dart';

class TickPlayer {
  static const MethodChannel _channel = MethodChannel('pomorun/tick');

  AudioPlayer? _player;
  Uint8List? _tickBytes;

  Future<void> prime() async {
    if (Platform.isAndroid) return;
    _player ??= AudioPlayer();
    _tickBytes ??= buildBeepWav(frequencyHz: 880);
  }

  Future<void> tick() async {
    if (Platform.isAndroid) {
      try {
        await _channel.invokeMethod<void>('tick');
        return;
      } catch (_) {
        // Fall back.
      }
    }

    try {
      await prime();
      final player = _player;
      final bytes = _tickBytes;
      if (player != null && bytes != null) {
        await player.stop();
        await player.play(BytesSource(bytes));
        return;
      }
    } catch (_) {
      // Fall back.
    }

    await SystemSound.play(SystemSoundType.click);
  }

  Future<void> accent() async {
    if (Platform.isAndroid) {
      try {
        await _channel.invokeMethod<void>('accent');
        return;
      } catch (_) {
        // Fall back.
      }
    }

    await tick();
    await Future<void>.delayed(const Duration(milliseconds: 70));
    await tick();
  }
}
