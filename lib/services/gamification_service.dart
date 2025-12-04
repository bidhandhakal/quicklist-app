import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/achievement_model.dart';
import '../models/daily_goal_model.dart';
import '../models/streak_model.dart';

class GamificationService extends ChangeNotifier {
  static final GamificationService instance = GamificationService._internal();
  factory GamificationService() => instance;
  GamificationService._internal();

  static const String _dailyGoalBoxName = 'dailyGoalBox';
  static const String _streakBoxName = 'streakBox';
  static const String _achievementsBoxName = 'achievementsBox';
  static const String _statsBoxName = 'statsBox';

  Box<DailyGoal>? _dailyGoalBox;
  Box<Streak>? _streakBox;
  Box<Achievement>? _achievementsBox;
  Box<dynamic>? _statsBox;

  DailyGoal? _dailyGoal;
  Streak? _streak;
  List<Achievement> _achievements = [];

  // Getters
  DailyGoal get dailyGoal => _dailyGoal ?? DailyGoal();
  Streak get streak => _streak ?? Streak();
  List<Achievement> get achievements => _achievements;
  List<Achievement> get unlockedAchievements =>
      _achievements.where((a) => a.isUnlocked).toList();
  int get totalTasksCompleted =>
      _statsBox?.get('totalCompleted', defaultValue: 0) ?? 0;
  int get totalTasksCreated =>
      _statsBox?.get('totalCreated', defaultValue: 0) ?? 0;
  int get perfectWeeksCount =>
      _statsBox?.get('perfectWeeks', defaultValue: 0) ?? 0;

  Future<void> init() async {
    try {
      // Open boxes
      _dailyGoalBox = await Hive.openBox<DailyGoal>(_dailyGoalBoxName);
      _streakBox = await Hive.openBox<Streak>(_streakBoxName);
      _achievementsBox = await Hive.openBox<Achievement>(_achievementsBoxName);
      _statsBox = await Hive.openBox(_statsBoxName);

      // Load or create daily goal
      _dailyGoal = _dailyGoalBox?.get('current');
      if (_dailyGoal == null) {
        _dailyGoal = DailyGoal();
        await _dailyGoalBox?.put('current', _dailyGoal!);
      }

      // Load or create streak
      _streak = _streakBox?.get('current');
      if (_streak == null) {
        _streak = Streak();
        await _streakBox?.put('current', _streak!);
      }

      // Check streak validity
      _streak!.checkStreakValidity();
      await _saveStreak();

      // Load or create achievements
      if (_achievementsBox?.isEmpty ?? true) {
        _achievements = _createDefaultAchievements();
        for (var achievement in _achievements) {
          await _achievementsBox?.put(achievement.id, achievement);
        }
      } else {
        _achievements = _achievementsBox?.values.toList() ?? [];
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing GamificationService: $e');
    }
  }

  // Create default achievements
  List<Achievement> _createDefaultAchievements() {
    return [
      // Tasks Completed
      Achievement(
        id: 'first_task',
        title: 'Getting Started',
        description: 'Complete your first task',
        icon: '🎯',
        requiredValue: 1,
        type: AchievementType.tasksCompleted,
      ),
      Achievement(
        id: 'task_10',
        title: 'On a Roll',
        description: 'Complete 10 tasks',
        icon: '⚡',
        requiredValue: 10,
        type: AchievementType.tasksCompleted,
      ),
      Achievement(
        id: 'task_50',
        title: 'Task Master',
        description: 'Complete 50 tasks',
        icon: '🏆',
        requiredValue: 50,
        type: AchievementType.tasksCompleted,
      ),
      Achievement(
        id: 'task_100',
        title: 'Centurion',
        description: 'Complete 100 tasks',
        icon: '💯',
        requiredValue: 100,
        type: AchievementType.tasksCompleted,
      ),
      Achievement(
        id: 'task_500',
        title: 'Legend',
        description: 'Complete 500 tasks',
        icon: '👑',
        requiredValue: 500,
        type: AchievementType.tasksCompleted,
      ),

      // Streaks
      Achievement(
        id: 'streak_3',
        title: 'Consistency',
        description: 'Maintain a 3-day streak',
        icon: '🔥',
        requiredValue: 3,
        type: AchievementType.streak,
      ),
      Achievement(
        id: 'streak_7',
        title: 'Week Warrior',
        description: 'Maintain a 7-day streak',
        icon: '💪',
        requiredValue: 7,
        type: AchievementType.streak,
      ),
      Achievement(
        id: 'streak_30',
        title: 'Unstoppable',
        description: 'Maintain a 30-day streak',
        icon: '🚀',
        requiredValue: 30,
        type: AchievementType.streak,
      ),
      Achievement(
        id: 'streak_100',
        title: 'Dedication',
        description: 'Maintain a 100-day streak',
        icon: '💎',
        requiredValue: 100,
        type: AchievementType.streak,
      ),

      // Daily Goals
      Achievement(
        id: 'goal_1',
        title: 'First Goal',
        description: 'Achieve your daily goal',
        icon: '🎪',
        requiredValue: 1,
        type: AchievementType.dailyGoal,
      ),
      Achievement(
        id: 'goal_10',
        title: 'Goal Getter',
        description: 'Achieve 10 daily goals',
        icon: '🌟',
        requiredValue: 10,
        type: AchievementType.dailyGoal,
      ),
      Achievement(
        id: 'goal_30',
        title: 'Goal Crusher',
        description: 'Achieve 30 daily goals',
        icon: '⭐',
        requiredValue: 30,
        type: AchievementType.dailyGoal,
      ),

      // Productivity
      Achievement(
        id: 'productive_5',
        title: 'Productive Day',
        description: 'Complete 5 tasks in one day',
        icon: '📈',
        requiredValue: 5,
        type: AchievementType.productivity,
      ),
      Achievement(
        id: 'productive_10',
        title: 'Super Productive',
        description: 'Complete 10 tasks in one day',
        icon: '🔥',
        requiredValue: 10,
        type: AchievementType.productivity,
      ),

      // Perfect Week
      Achievement(
        id: 'perfect_week_1',
        title: 'Perfect Week',
        description: 'Meet your daily goal for 7 days straight',
        icon: '✨',
        requiredValue: 1,
        type: AchievementType.perfectWeek,
      ),
    ];
  }

  // Called when a task is completed
  Future<void> onTaskCompleted() async {
    // Update stats
    final currentTotal = totalTasksCompleted;
    await _statsBox?.put('totalCompleted', currentTotal + 1);

    // Update daily goal progress
    _dailyGoal?.incrementToday();
    await _saveDailyGoal();

    // Check if daily goal is achieved
    if (_dailyGoal?.isTodayGoalAchieved ?? false) {
      await _onDailyGoalAchieved();
    }

    // Check achievements
    await _checkAchievements();

    notifyListeners();
  }

  // Called when a task completion is undone
  Future<void> onTaskUncompleted() async {
    final currentTotal = totalTasksCompleted;
    if (currentTotal > 0) {
      await _statsBox?.put('totalCompleted', currentTotal - 1);
    }

    _dailyGoal?.decrementToday();
    await _saveDailyGoal();

    notifyListeners();
  }

  // Called when a task is created
  Future<void> onTaskCreated() async {
    final currentTotal = totalTasksCreated;
    await _statsBox?.put('totalCreated', currentTotal + 1);
    notifyListeners();
  }

  // Called when daily goal is achieved
  Future<void> _onDailyGoalAchieved() async {
    // Update streak
    _streak?.updateStreak();
    await _saveStreak();

    // Check for perfect week
    await _checkPerfectWeek();
  }

  // Check if user has a perfect week
  Future<void> _checkPerfectWeek() async {
    if (_streak == null || _dailyGoal == null) return;

    final now = DateTime.now();
    bool isPerfectWeek = true;

    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      final completed = _dailyGoal!.getCompletedForDate(date);
      if (completed < _dailyGoal!.targetTasks) {
        isPerfectWeek = false;
        break;
      }
    }

    if (isPerfectWeek) {
      final count = perfectWeeksCount;
      await _statsBox?.put('perfectWeeks', count + 1);
    }
  }

  // Check and unlock achievements
  Future<void> _checkAchievements() async {
    bool anyUnlocked = false;

    for (var achievement in _achievements) {
      if (achievement.isUnlocked) continue;

      bool shouldUnlock = false;

      switch (achievement.type) {
        case AchievementType.tasksCompleted:
          shouldUnlock = totalTasksCompleted >= achievement.requiredValue;
          break;
        case AchievementType.streak:
          shouldUnlock =
              (_streak?.currentStreak ?? 0) >= achievement.requiredValue;
          break;
        case AchievementType.dailyGoal:
          final goalsAchieved =
              _dailyGoal?.dailyProgress.values
                  .where((count) => count >= (_dailyGoal?.targetTasks ?? 0))
                  .length ??
              0;
          shouldUnlock = goalsAchieved >= achievement.requiredValue;
          break;
        case AchievementType.perfectWeek:
          shouldUnlock = perfectWeeksCount >= achievement.requiredValue;
          break;
        case AchievementType.productivity:
          shouldUnlock =
              (_dailyGoal?.todayCompleted ?? 0) >= achievement.requiredValue;
          break;
        case AchievementType.earlyBird:
          // Can be implemented with task deadline tracking
          break;
      }

      if (shouldUnlock) {
        achievement.unlock();
        await achievement.save();
        anyUnlocked = true;
      }
    }

    if (anyUnlocked) {
      notifyListeners();
    }
  }

  // Update daily goal target
  Future<void> updateDailyGoalTarget(int newTarget) async {
    _dailyGoal?.updateTarget(newTarget);
    await _saveDailyGoal();
    notifyListeners();
  }

  // Save methods
  Future<void> _saveDailyGoal() async {
    if (_dailyGoal != null) {
      await _dailyGoalBox?.put('current', _dailyGoal!);
    }
  }

  Future<void> _saveStreak() async {
    if (_streak != null) {
      await _streakBox?.put('current', _streak!);
    }
  }

  // Clean old data periodically
  Future<void> cleanOldData() async {
    _dailyGoal?.cleanOldData();
    _streak?.cleanOldData();
    await _saveDailyGoal();
    await _saveStreak();
  }

  // Reset all data (for testing)
  Future<void> resetAll() async {
    await _dailyGoalBox?.clear();
    await _streakBox?.clear();
    await _achievementsBox?.clear();
    await _statsBox?.clear();
    await init();
  }
}
