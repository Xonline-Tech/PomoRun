import 'segment.dart';
import 'prompt_policy.dart';

enum ModeKind {
  steady,
  interval,
}

class ModeConfig {
  ModeConfig({
    required this.id,
    required this.name,
    required this.kind,
    required this.feel,
    required this.defaultDuration,
    required this.defaultBpm,
    required this.minBpm,
    required this.maxBpm,
    required this.suitableFor,
    required this.voiceRule,
    required this.notes,
    required this.promptPolicy,
    required this.intervalTemplate,
  });

  final String id;
  final String name;
  final ModeKind kind;
  final String feel;

  final Duration defaultDuration;
  final int defaultBpm;
  final int minBpm;
  final int maxBpm;

  final String suitableFor;
  final String voiceRule;
  final String notes;

  final PromptPolicy promptPolicy;

  /// Only used when [kind] == [ModeKind.interval].
  final IntervalTemplate? intervalTemplate;

  List<Segment> buildSegments({required int bpm, required Duration totalDuration}) {
    switch (kind) {
      case ModeKind.steady:
        return <Segment>[
          Segment(
            type: SegmentType.steady,
            duration: totalDuration,
            bpm: bpm,
            label: '稳态',
          ),
        ];
      case ModeKind.interval:
        final template = intervalTemplate;
        if (template == null) {
          throw StateError('Interval template is required for interval mode');
        }
        final segments = <Segment>[];
        for (var i = 0; i < template.sets; i++) {
          segments.add(
            Segment(
              type: SegmentType.fast,
              duration: template.fastDuration,
              bpm: template.fastBpm,
              label: '快跑',
            ),
          );
          segments.add(
            Segment(
              type: SegmentType.recovery,
              duration: template.recoveryDuration,
              bpm: template.recoveryBpm,
              label: '恢复',
            ),
          );
        }
        return segments;
    }
  }
}

class IntervalTemplate {
  const IntervalTemplate({
    required this.sets,
    required this.fastDuration,
    required this.fastBpm,
    required this.recoveryDuration,
    required this.recoveryBpm,
  });

  final int sets;
  final Duration fastDuration;
  final int fastBpm;
  final Duration recoveryDuration;
  final int recoveryBpm;
}
