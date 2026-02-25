import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../models/mode.dart';
import '../../models/segment.dart';
import '../../services/haptics.dart';
import '../../services/metronome_engine.dart';
import '../../services/prompt_engine.dart';
import '../../services/tick_player.dart';
import '../../services/tts_service.dart';
import 'session_state.dart';

class SessionController extends ChangeNotifier {
  SessionController({
    required this.mode,
    required int bpm,
    required Duration totalDuration,
    bool soundEnabled = true,
    bool voiceEnabled = true,
    bool hapticsEnabled = false,
  })  : _configuredBpm = bpm,
        _configuredDuration = totalDuration {
    _segments = mode.buildSegments(bpm: bpm, totalDuration: totalDuration);

    final first = _segments.first;
    _state = SessionState(
      status: SessionStatus.idle,
      totalDuration: _totalDuration,
      totalElapsed: Duration.zero,
      totalRemaining: _totalDuration,
      segmentIndex: 0,
      segmentElapsed: Duration.zero,
      segmentRemaining: first.duration,
      currentSegment: first,
      soundEnabled: soundEnabled,
      voiceEnabled: voiceEnabled,
      hapticsEnabled: hapticsEnabled,
    );
  }

  final ModeConfig mode;
  final TickPlayer _tickPlayer = TickPlayer();
  final HapticsService _haptics = HapticsService();
  final TtsService _tts = TtsService();
  final PromptEngine _prompts = PromptEngine();

  late List<Segment> _segments;
  MetronomeEngine? _metronome;
  Timer? _uiTimer;
  final Stopwatch _stopwatch = Stopwatch();
  Duration _pausedAccumulated = Duration.zero;
  Duration _pauseStartedAt = Duration.zero;

  final int _configuredBpm;
  final Duration _configuredDuration;

  SessionState _state;
  SessionState get state => _state;

  int get configuredBpm => _configuredBpm;
  Duration get configuredDuration => _configuredDuration;
  Duration get _totalDuration => mode.kind == ModeKind.interval ? _sumSegments(_segments) : _configuredDuration;

  List<Segment> get segments => List<Segment>.unmodifiable(_segments);

  void start() {
    if (_state.status == SessionStatus.running) return;

    if (_state.status == SessionStatus.idle || _state.status == SessionStatus.finished) {
      _reset();
    }

    if (_state.status == SessionStatus.paused) {
      _pausedAccumulated += (_stopwatch.elapsed - _pauseStartedAt);
    } else {
      _stopwatch.start();
      if (_state.voiceEnabled) {
        _tts.speak('开始训练');
      }
    }

    _state = _state.copyWith(status: SessionStatus.running);
    notifyListeners();

    _startSegmentMetronome(_state.currentSegment);
    _startUiTick();
  }

  void pause() {
    if (_state.status != SessionStatus.running) return;
    _pauseStartedAt = _stopwatch.elapsed;
    _metronome?.stop();
    _metronome = null;
    _uiTimer?.cancel();
    _uiTimer = null;
    _state = _state.copyWith(status: SessionStatus.paused);
    notifyListeners();
  }

  void finish() {
    if (_state.status == SessionStatus.finished) return;
    _metronome?.stop();
    _metronome = null;
    _uiTimer?.cancel();
    _uiTimer = null;
    _stopwatch.stop();
    _state = _state.copyWith(status: SessionStatus.finished);
    _tts.stop();
    notifyListeners();
  }

  void toggleSound(bool enabled) {
    _state = _state.copyWith(soundEnabled: enabled);
    notifyListeners();
  }

  void toggleVoice(bool enabled) {
    _state = _state.copyWith(voiceEnabled: enabled);
    if (!enabled) {
      _tts.stop();
    }
    notifyListeners();
  }

  void toggleHaptics(bool enabled) {
    _state = _state.copyWith(hapticsEnabled: enabled);
    notifyListeners();
  }

  @override
  void dispose() {
    _metronome?.stop();
    _uiTimer?.cancel();
    _tts.dispose();
    super.dispose();
  }

  void _reset() {
    _prompts.reset();
    _pausedAccumulated = Duration.zero;
    _pauseStartedAt = Duration.zero;
    _stopwatch
      ..stop()
      ..reset();
    _segments = mode.buildSegments(bpm: _configuredBpm, totalDuration: _configuredDuration);
    final first = _segments.first;
    _state = SessionState(
      status: SessionStatus.idle,
      totalDuration: _totalDuration,
      totalElapsed: Duration.zero,
      totalRemaining: _totalDuration,
      segmentIndex: 0,
      segmentElapsed: Duration.zero,
      segmentRemaining: first.duration,
      currentSegment: first,
      soundEnabled: _state.soundEnabled,
      voiceEnabled: _state.voiceEnabled,
      hapticsEnabled: _state.hapticsEnabled,
    );
  }

  void _startUiTick() {
    _uiTimer?.cancel();
    _uiTimer = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (_state.status != SessionStatus.running) return;
      _recompute();
    });
  }

  void _recompute() {
    final elapsed = _stopwatch.elapsed - _pausedAccumulated;
    final safeElapsed = elapsed.isNegative ? Duration.zero : elapsed;
    final totalRemaining = _clampNonNegative(_totalDuration - safeElapsed);

    var segmentIndex = _state.segmentIndex;
    var segmentElapsed = _computeSegmentElapsed(safeElapsed, segmentIndex);
    while (segmentIndex < _segments.length && segmentElapsed >= _segments[segmentIndex].duration) {
      segmentIndex++;
      if (segmentIndex >= _segments.length) {
        _state = _state.copyWith(
          totalElapsed: _totalDuration,
          totalRemaining: Duration.zero,
          segmentIndex: _segments.length - 1,
          segmentElapsed: _segments.last.duration,
          segmentRemaining: Duration.zero,
        );
        finish();
        return;
      }
      segmentElapsed = _computeSegmentElapsed(safeElapsed, segmentIndex);
      _onSegmentSwitched(segmentIndex);
    }

    final current = _segments[segmentIndex];
    final segmentRemaining = _clampNonNegative(current.duration - segmentElapsed);

    _state = _state.copyWith(
      totalElapsed: safeElapsed,
      totalRemaining: totalRemaining,
      segmentIndex: segmentIndex,
      segmentElapsed: segmentElapsed,
      segmentRemaining: segmentRemaining,
      currentSegment: current,
    );
    notifyListeners();

    final nextLabel = segmentIndex + 1 < _segments.length ? _segments[segmentIndex + 1].label : '结束';
    final event = _prompts.update(
      policy: mode.promptPolicy,
      totalElapsed: safeElapsed,
      totalRemaining: totalRemaining,
      segmentIndex: segmentIndex,
      segmentRemaining: segmentRemaining,
      segmentLabel: current.label,
      nextSegmentLabel: nextLabel,
    );
    if (event != null) {
      _handlePrompt(event);
    }
  }

  void _onSegmentSwitched(int segmentIndex) {
    final current = _segments[segmentIndex];
    _startSegmentMetronome(current);
    if (_state.hapticsEnabled) {
      _haptics.doublePulse();
    }
    if (_state.voiceEnabled) {
      _tts.speak('切换到${current.label}');
    }
  }

  void _startSegmentMetronome(Segment segment) {
    _metronome?.stop();
    _metronome = MetronomeEngine(
      bpm: segment.bpm,
      onBeat: (beatIndex) async {
        if (_state.status != SessionStatus.running) return;
        if (_state.soundEnabled) {
          if (beatIndex == 0) {
            await _tickPlayer.accent();
          } else {
            await _tickPlayer.tick();
          }
        }
      },
    )..start();
  }

  Duration _computeSegmentElapsed(Duration totalElapsed, int segmentIndex) {
    var consumed = Duration.zero;
    for (var i = 0; i < segmentIndex; i++) {
      consumed += _segments[i].duration;
    }
    return _clampNonNegative(totalElapsed - consumed);
  }

  void _handlePrompt(PromptEvent event) {
    if (_state.voiceEnabled) {
      _tts.speak(event.text);
    }
    if (_state.hapticsEnabled) {
      _haptics.shortPulse();
    }
  }

  static Duration _clampNonNegative(Duration value) {
    return value.isNegative ? Duration.zero : value;
  }

  static Duration _sumSegments(List<Segment> segments) {
    var sum = Duration.zero;
    for (final s in segments) {
      sum += s.duration;
    }
    return sum;
  }
}
