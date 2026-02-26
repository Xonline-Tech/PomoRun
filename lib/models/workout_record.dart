class WorkoutRecord {
  const WorkoutRecord({
    required this.modeId,
    required this.startedAt,
    required this.duration,
    required this.bpm,
    required this.isInterval,
  });

  final String modeId;
  final DateTime startedAt;
  final Duration duration;
  final int bpm;
  final bool isInterval;

  int get durationSeconds => duration.inSeconds;

  Map<String, dynamic> toJson() {
    return {
      'modeId': modeId,
      'startedAt': startedAt.toIso8601String(),
      'durationSeconds': durationSeconds,
      'bpm': bpm,
      'isInterval': isInterval,
    };
  }

  factory WorkoutRecord.fromJson(Map<String, dynamic> json) {
    return WorkoutRecord(
      modeId: json['modeId'] as String? ?? '',
      startedAt: DateTime.tryParse(json['startedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      duration: Duration(seconds: json['durationSeconds'] as int? ?? 0),
      bpm: json['bpm'] as int? ?? 0,
      isInterval: json['isInterval'] as bool? ?? false,
    );
  }
}
