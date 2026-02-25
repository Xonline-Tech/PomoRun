enum SegmentType {
  steady,
  fast,
  recovery,
}

class Segment {
  const Segment({
    required this.type,
    required this.duration,
    required this.bpm,
    required this.label,
  });

  final SegmentType type;
  final Duration duration;
  final int bpm;
  final String label;
}
