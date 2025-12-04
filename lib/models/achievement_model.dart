import 'package:hive/hive.dart';

part 'achievement_model.g.dart';

@HiveType(typeId: 4)
class Achievement extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String icon;

  @HiveField(4)
  final int requiredValue;

  @HiveField(5)
  final AchievementType type;

  @HiveField(6)
  bool isUnlocked;

  @HiveField(7)
  DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.requiredValue,
    required this.type,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  void unlock() {
    isUnlocked = true;
    unlockedAt = DateTime.now();
  }
}

@HiveType(typeId: 5)
enum AchievementType {
  @HiveField(0)
  tasksCompleted, // Total tasks completed

  @HiveField(1)
  streak, // Consecutive days streak

  @HiveField(2)
  dailyGoal, // Daily goals achieved

  @HiveField(3)
  perfectWeek, // 7 days in a row meeting goal

  @HiveField(4)
  earlyBird, // Complete tasks before deadline

  @HiveField(5)
  productivity, // Complete X tasks in one day
}
