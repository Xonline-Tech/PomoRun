import 'dart:math' as math;
import 'dart:typed_data';

Uint8List buildBeepWav({
  required double frequencyHz,
  int sampleRateHz = 44100,
  int durationMs = 24,
  double volume = 0.25,
}) {
  final sampleCount = (sampleRateHz * durationMs) ~/ 1000;
  final dataSize = sampleCount * 2;

  final buffer = Uint8List(44 + dataSize);
  final header = ByteData.sublistView(buffer, 0, 44);
  final data = ByteData.sublistView(buffer, 44);

  void writeAscii(int offset, String s) {
    for (var i = 0; i < s.length; i++) {
      buffer[offset + i] = s.codeUnitAt(i);
    }
  }

  writeAscii(0, 'RIFF');
  header.setUint32(4, 36 + dataSize, Endian.little);
  writeAscii(8, 'WAVE');
  writeAscii(12, 'fmt ');
  header.setUint32(16, 16, Endian.little);
  header.setUint16(20, 1, Endian.little);
  header.setUint16(22, 1, Endian.little);
  header.setUint32(24, sampleRateHz, Endian.little);
  header.setUint32(28, sampleRateHz * 2, Endian.little);
  header.setUint16(32, 2, Endian.little);
  header.setUint16(34, 16, Endian.little);
  writeAscii(36, 'data');
  header.setUint32(40, dataSize, Endian.little);

  final maxAmplitude = (volume.clamp(0.0, 1.0) * 32767.0).round();
  final fadeSamples = math.min(sampleCount ~/ 8, sampleRateHz ~/ 200);

  for (var i = 0; i < sampleCount; i++) {
    var envelope = 1.0;
    if (fadeSamples > 0) {
      if (i < fadeSamples) {
        envelope = i / fadeSamples;
      } else if (i > sampleCount - fadeSamples) {
        envelope = (sampleCount - i) / fadeSamples;
      }
    }
    final t = i / sampleRateHz;
    final v = math.sin(2.0 * math.pi * frequencyHz * t) * envelope;
    data.setInt16(i * 2, (v * maxAmplitude).round(), Endian.little);
  }

  return buffer;
}
