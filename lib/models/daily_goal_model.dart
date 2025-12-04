import 'package:hive/hive.dart';

part 'daily_goal_model.g.dart';

@HiveType(typeId: 6)
class DailyGoal extends HiveObject {
  @HiveField(0)
  int targetTasks;

  @HiveField(1)
  DateTime lastUpdated;

  @HiveField(2)
  Map<String, int> dailyProgress; // date -> completed tasks count

  DailyGoal({
    this.targetTasks = 5,
    DateTime? lastUpdated,
    Map<String, int>? dailyProgress,
  }) : lastUpdated = lastUpdated ?? DateTime.now(),
       dailyProgress = dailyProgress ?? {};

  // Get today's date key
  String get todayKey => _dateKey(DateTime.now());

  // Get completed tasks for today
  int get todayCompleted => dailyProgress[todayKey] ?? 0;

  // Get progress percentage for today
  double get todayProgress =>
      targetTasks > 0 ? (todayCompleted / targetTasks).clamp(0.0, 1.0) : 0.0;

  // Check if today's goal is achieved
  bool get isTodayGoalAchieved => todayCompleted >= targetTasks;

  // Increment today's count
  void incrementToday() {
    dailyProgress[todayKey] = todayCompleted + 1;
    lastUpdated = DateTime.now();
  }

  // Decrement today's count
  void decrementToday() {
    final current = todayCompleted;
    if (current > 0) {
      dailyProgress[todayKey] = current - 1;
      lastUpdated = DateTime.now();
    }
  }

  // Get completed count for a specific date
  int getCompletedForDate(DateTime date) {
    return dailyProgress[_dateKey(date)] ?? 0;
  }

  // Update target
  void updateTarget(int newTarget) {
    targetTasks = newTarget;
    lastUpdated = DateTime.now();
  }

  // Clean old data (keep last 30 days)
  void cleanOldData() {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    dailyProgress.removeWhere((key, value) {
      final date = DateTime.tryParse(key);
      return date != null && date.isBefore(thirtyDaysAgo);
    });
  }

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
