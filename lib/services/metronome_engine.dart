import 'dart:async';

typedef BeatCallback = FutureOr<void> Function(int beatIndex);

class MetronomeEngine {
  MetronomeEngine({required int bpm, required BeatCallback onBeat})
      : _bpm = bpm,
        _onBeat = onBeat;

  final int _bpm;
  final BeatCallback _onBeat;

  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  var _running = false;
  var _beatIndex = 0;

  int get bpm => _bpm;

  void start() {
    if (_running) return;
    _running = true;
    _beatIndex = 0;
    _stopwatch
      ..reset()
      ..start();
    _scheduleNext();
  }

  void stop() {
    _running = false;
    _timer?.cancel();
    _timer = null;
    _stopwatch.stop();
  }

  void _scheduleNext() {
    if (!_running) return;

    final intervalUs = (60 * 1000 * 1000) ~/ _bpm;
    final targetUs = _beatIndex * intervalUs;
    final nowUs = _stopwatch.elapsedMicroseconds;
    final delayUs = targetUs - nowUs;

    final safeDelayUs = delayUs <= 0 ? 0 : delayUs;
    _timer = Timer(Duration(microseconds: safeDelayUs), () async {
      if (!_running) return;

      await _onBeat(_beatIndex);
      _beatIndex++;
      _scheduleNext();
    });
  }
}
