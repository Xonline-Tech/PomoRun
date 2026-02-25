import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

import 'beep_wav.dart';

class TickPlayer {
  AudioPlayer? _player;
  String? _tickDataUri;

  Future<void> prime() async {
    _player ??= AudioPlayer();
    _tickDataUri ??= _buildDataUri();

    final player = _player;
    final uri = _tickDataUri;
    if (player == null || uri == null) return;
    try {
      await player.play(UrlSource(uri), volume: 0);
      await player.stop();
    } catch (_) {
      // Ignore autoplay policy failures.
    }
  }

  String _buildDataUri() {
    final bytes = buildBeepWav(frequencyHz: 880);
    final b64 = base64Encode(bytes);
    return 'data:audio/wav;base64,$b64';
  }

  Future<void> tick() async {
    try {
      await prime();
      final player = _player;
      final uri = _tickDataUri;
      if (player != null && uri != null) {
        await player.stop();
        await player.play(UrlSource(uri));
        return;
      }
    } catch (_) {
      // Fall back.
    }

    await SystemSound.play(SystemSoundType.click);
  }

  Future<void> accent() async {
    await tick();
    await Future<void>.delayed(const Duration(milliseconds: 70));
    await tick();
  }
}
