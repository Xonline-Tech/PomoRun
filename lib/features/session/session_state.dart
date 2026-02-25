import '../../models/segment.dart';

enum SessionStatus {
  idle,
  running,
  paused,
  finished,
}

class SessionState {
  const SessionState({
    required this.status,
    required this.totalDuration,
    required this.totalElapsed,
    required this.totalRemaining,
    required this.segmentIndex,
    required this.segmentElapsed,
    required this.segmentRemaining,
    required this.currentSegment,
    required this.soundEnabled,
    required this.voiceEnabled,
    required this.hapticsEnabled,
  });

  final SessionStatus status;

  final Duration totalDuration;
  final Duration totalElapsed;
  final Duration totalRemaining;

  final int segmentIndex;
  final Duration segmentElapsed;
  final Duration segmentRemaining;
  final Segment currentSegment;

  final bool soundEnabled;
  final bool voiceEnabled;
  final bool hapticsEnabled;

  SessionState copyWith({
    SessionStatus? status,
    Duration? totalElapsed,
    Duration? totalRemaining,
    int? segmentIndex,
    Duration? segmentElapsed,
    Duration? segmentRemaining,
    Segment? currentSegment,
    bool? soundEnabled,
    bool? voiceEnabled,
    bool? hapticsEnabled,
  }) {
    return SessionState(
      status: status ?? this.status,
      totalDuration: totalDuration,
      totalElapsed: totalElapsed ?? this.totalElapsed,
      totalRemaining: totalRemaining ?? this.totalRemaining,
      segmentIndex: segmentIndex ?? this.segmentIndex,
      segmentElapsed: segmentElapsed ?? this.segmentElapsed,
      segmentRemaining: segmentRemaining ?? this.segmentRemaining,
      currentSegment: currentSegment ?? this.currentSegment,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      voiceEnabled: voiceEnabled ?? this.voiceEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
    );
  }
}
