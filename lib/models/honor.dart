enum HonorCategory {
  streak,
  duration,
  speed,
  milestone,
}

enum HonorStatus {
  locked,
  inProgress,
  achieved,
}

class HonorBadge {
  const HonorBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.criteria,
    required this.category,
    required this.status,
    required this.current,
    required this.target,
    required this.unit,
  });

  final String id;
  final String title;
  final String description;
  final String criteria;
  final HonorCategory category;
  final HonorStatus status;
  final int current;
  final int target;
  final String unit;

  double get progress {
    if (target <= 0) return 0;
    return (current / target).clamp(0, 1);
  }
}

class HonorSummary {
  const HonorSummary({
    required this.totalSessions,
    required this.totalMinutes,
    required this.currentStreak,
    required this.longestStreak,
    required this.honorsEarned,
    required this.honorsTotal,
  });

  final int totalSessions;
  final int totalMinutes;
  final int currentStreak;
  final int longestStreak;
  final int honorsEarned;
  final int honorsTotal;
}
