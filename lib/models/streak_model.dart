import 'package:hive/hive.dart';

part 'streak_model.g.dart';

@HiveType(typeId: 7)
class Streak extends HiveObject {
  @HiveField(0)
  int currentStreak;

  @HiveField(1)
  int longestStreak;

  @HiveField(2)
  DateTime? lastCompletedDate;

  @HiveField(3)
  List<String> completedDates; // List of date strings

  Streak({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastCompletedDate,
    List<String>? completedDates,
  }) : completedDates = completedDates ?? [];

  // Get today's date key
  String get todayKey => _dateKey(DateTime.now());

  // Check if today is already counted
  bool get isTodayCompleted => completedDates.contains(todayKey);

  // Update streak when a daily goal is achieved
  void updateStreak() {
    final now = DateTime.now();
    final today = _dateKey(now);

    // Already counted today
    if (completedDates.contains(today)) {
      return;
    }

    // Add today to completed dates
    completedDates.add(today);

    if (lastCompletedDate == null) {
      // First time
      currentStreak = 1;
      longestStreak = 1;
    } else {
      final yesterday = now.subtract(const Duration(days: 1));
      final yesterdayKey = _dateKey(yesterday);

      if (completedDates.contains(yesterdayKey)) {
        // Continue streak
        currentStreak++;
        if (currentStreak > longestStreak) {
          longestStreak = currentStreak;
        }
      } else {
        // Streak broken, start new
        currentStreak = 1;
      }
    }

    lastCompletedDate = now;
  }

  // Check and reset streak if broken
  void checkStreakValidity() {
    if (lastCompletedDate == null) return;

    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final yesterdayKey = _dateKey(yesterday);
    final today = _dateKey(now);

    // If today is completed, streak is valid
    if (completedDates.contains(today)) {
      return;
    }

    // If yesterday was completed, we're still within grace period
    if (completedDates.contains(yesterdayKey)) {
      return;
    }

    // Streak is broken
    currentStreak = 0;
  }

  // Clean old data (keep last 365 days)
  void cleanOldData() {
    final oneYearAgo = DateTime.now().subtract(const Duration(days: 365));
    completedDates.removeWhere((dateStr) {
      final date = DateTime.tryParse(dateStr);
      return date != null && date.isBefore(oneYearAgo);
    });
  }

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
