import '../models/honor.dart';
import '../models/workout_record.dart';
import 'workout_store.dart';

class HonorProgress {
  const HonorProgress({required this.summary, required this.badges});

  final HonorSummary summary;
  final List<HonorBadge> badges;
}

class HonorUpdate {
  const HonorUpdate({required this.progress, required this.newlyUnlocked});

  final HonorProgress progress;
  final List<HonorBadge> newlyUnlocked;
}

class HonorProgressService {
  HonorProgressService({WorkoutStore? store})
      : _store = store ?? WorkoutStore();

  final WorkoutStore _store;

  Future<HonorProgress> loadProgress() async {
    final records = await _store.loadRecords();
    return _compute(records);
  }

  Future<HonorUpdate> recordWorkout(WorkoutRecord record) async {
    final before = await _store.loadRecords();
    final beforeProgress = _compute(before);
    final updated = List<WorkoutRecord>.from(before)..add(record);
    await _store.saveRecords(updated);
    final afterProgress = _compute(updated);
    final newlyUnlocked = _diffUnlocked(
      beforeProgress.badges,
      afterProgress.badges,
    );
    return HonorUpdate(progress: afterProgress, newlyUnlocked: newlyUnlocked);
  }

  static List<HonorBadge> _diffUnlocked(
    List<HonorBadge> before,
    List<HonorBadge> after,
  ) {
    final beforeMap = {for (final b in before) b.id: b.status};
    return after.where((badge) {
      final prior = beforeMap[badge.id];
      return badge.status == HonorStatus.achieved &&
          prior != HonorStatus.achieved;
    }).toList();
  }

  HonorProgress _compute(List<WorkoutRecord> records) {
    final totalSessions = records.length;
    final totalMinutes = records.fold<int>(
      0,
      (sum, record) => sum + record.duration.inMinutes,
    );

    final streakStats = _computeStreaks(records);
    final currentStreak = streakStats.current;
    final longestStreak = streakStats.longest;

    final intervalSessions =
        records.where((record) => record.isInterval).length;
    final maxDurationMinutes = records.isEmpty
        ? 0
        : records
            .map((record) => record.duration.inMinutes)
            .reduce((a, b) => a > b ? a : b);
    final maxTempoMinutes = records
        .where((record) => record.bpm >= 185)
        .map((record) => record.duration.inMinutes)
        .fold<int>(0, (max, minutes) => minutes > max ? minutes : max);

    final badges = <HonorBadge>[
      _buildBadge(
        id: 'first_run',
        title: '首跑完成',
        description: '第一次启动节拍训练',
        criteria: '完成 1 次训练',
        category: HonorCategory.milestone,
        current: totalSessions,
        target: 1,
        unit: '次',
      ),
      _buildBadge(
        id: 'interval_starter',
        title: '间歇上手',
        description: '完成一次间歇跑',
        criteria: '间歇模式完成 1 次',
        category: HonorCategory.speed,
        current: intervalSessions,
        target: 1,
        unit: '次',
      ),
      _buildBadge(
        id: 'three_day_streak',
        title: '三日连跑',
        description: '把节奏变成习惯',
        criteria: '连续训练 3 天',
        category: HonorCategory.streak,
        current: currentStreak,
        target: 3,
        unit: '天',
      ),
      _buildBadge(
        id: 'steady_long',
        title: '稳态长跑',
        description: '坚持稳定输出',
        criteria: '单次训练 45 分钟',
        category: HonorCategory.duration,
        current: maxDurationMinutes,
        target: 45,
        unit: '分钟',
      ),
      _buildBadge(
        id: 'tempo_master',
        title: '节奏掌控',
        description: '速度与节拍合一',
        criteria: '完成 185 BPM 15 分钟',
        category: HonorCategory.speed,
        current: maxTempoMinutes,
        target: 15,
        unit: '分钟',
      ),
      _buildBadge(
        id: 'week_runner',
        title: '坚持一周',
        description: '把节拍融入生活',
        criteria: '连续训练 7 天',
        category: HonorCategory.streak,
        current: currentStreak,
        target: 7,
        unit: '天',
      ),
    ];

    final honorsEarned =
        badges.where((badge) => badge.status == HonorStatus.achieved).length;
    final summary = HonorSummary(
      totalSessions: totalSessions,
      totalMinutes: totalMinutes,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      honorsEarned: honorsEarned,
      honorsTotal: badges.length,
    );

    return HonorProgress(summary: summary, badges: badges);
  }

  HonorBadge _buildBadge({
    required String id,
    required String title,
    required String description,
    required String criteria,
    required HonorCategory category,
    required int current,
    required int target,
    required String unit,
  }) {
    final status = current >= target
        ? HonorStatus.achieved
        : (current > 0 ? HonorStatus.inProgress : HonorStatus.locked);
    return HonorBadge(
      id: id,
      title: title,
      description: description,
      criteria: criteria,
      category: category,
      status: status,
      current: current,
      target: target,
      unit: unit,
    );
  }

  _StreakStats _computeStreaks(List<WorkoutRecord> records) {
    if (records.isEmpty) {
      return const _StreakStats(current: 0, longest: 0);
    }

    final days = records
        .map((record) => DateTime(
              record.startedAt.year,
              record.startedAt.month,
              record.startedAt.day,
            ))
        .toSet()
        .toList()
      ..sort();

    var longest = 1;
    var current = 1;
    var streak = 1;

    for (var i = 1; i < days.length; i++) {
      final diff = days[i].difference(days[i - 1]).inDays;
      if (diff == 1) {
        streak += 1;
      } else if (diff > 1) {
        if (streak > longest) longest = streak;
        streak = 1;
      }
    }

    if (streak > longest) longest = streak;
    current = _computeCurrentStreak(days);

    return _StreakStats(current: current, longest: longest);
  }

  int _computeCurrentStreak(List<DateTime> sortedDays) {
    if (sortedDays.isEmpty) return 0;
    var streak = 1;
    for (var i = sortedDays.length - 1; i > 0; i--) {
      final diff = sortedDays[i].difference(sortedDays[i - 1]).inDays;
      if (diff == 1) {
        streak += 1;
      } else {
        break;
      }
    }
    return streak;
  }
}

class _StreakStats {
  const _StreakStats({required this.current, required this.longest});

  final int current;
  final int longest;
}
