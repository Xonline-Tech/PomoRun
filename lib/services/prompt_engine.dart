import '../models/prompt_policy.dart';

class PromptEngine {
  final Set<String> _fired = <String>{};
  int? _lastEncourageBucket;
  int? _lastRemainingSec;

  void reset() {
    _fired.clear();
    _lastEncourageBucket = null;
    _lastRemainingSec = null;
  }

  PromptEvent? update({
    required PromptPolicy policy,
    required Duration totalElapsed,
    required Duration totalRemaining,
    required int segmentIndex,
    required Duration segmentRemaining,
    required String segmentLabel,
    required String nextSegmentLabel,
  }) {
    switch (policy) {
      case PromptPolicy.none:
        return null;
      case PromptPolicy.encourageEveryFiveMinutes:
        final bucket = totalElapsed.inSeconds ~/ (5 * 60);
        if (bucket <= 0) return null;
        if (_lastEncourageBucket == bucket) return null;
        _lastEncourageBucket = bucket;

        final key = 'encourage_$bucket';
        if (_fired.add(key)) {
          return const PromptEvent(text: '做得很好，保持轻松节奏。', kind: PromptKind.encourage);
        }
        return null;
      case PromptPolicy.tempoRemainingFiveAndOne:
        final remainingSec = totalRemaining.inSeconds;
        final last = _lastRemainingSec;
        _lastRemainingSec = remainingSec;
        if (last == null) return null;

        if (last > 5 * 60 && remainingSec <= 5 * 60) {
          if (_fired.add('tempo_5min')) {
            return const PromptEvent(text: '还剩五分钟，坚持住。', kind: PromptKind.milestone);
          }
        }
        if (last > 60 && remainingSec <= 60) {
          if (_fired.add('tempo_1min')) {
            return const PromptEvent(text: '还剩一分钟，稳住节奏。', kind: PromptKind.milestone);
          }
        }
        return null;
      case PromptPolicy.intervalTenSecondsBeforeSwitch:
        if (nextSegmentLabel == '结束') return null;
        if (segmentRemaining.inSeconds <= 10) {
          final key = 'interval_pre_$segmentIndex';
          if (_fired.add(key)) {
            return PromptEvent(
              text: '十秒后切换到$nextSegmentLabel。',
              kind: PromptKind.preSwitch,
            );
          }
        }
        return null;
    }
  }
}

enum PromptKind {
  encourage,
  milestone,
  preSwitch,
}

class PromptEvent {
  const PromptEvent({required this.text, required this.kind});
  final String text;
  final PromptKind kind;
}
