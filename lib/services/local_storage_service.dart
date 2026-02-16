import 'package:hive_flutter/hive_flutter.dart';
import '../models/task_model.dart';
import '../models/category_model.dart';
import '../models/achievement_model.dart';
import '../models/daily_goal_model.dart';
import '../models/streak_model.dart';
import '../models/subtask_model.dart';
import '../models/task_attachment_model.dart';
import '../utils/constants.dart';

class LocalStorageService {
  static LocalStorageService? _instance;
  static LocalStorageService get instance {
    _instance ??= LocalStorageService._();
    return _instance!;
  }

  LocalStorageService._();

  Box<Task>? _tasksBox;
  Box? _settingsBox;

  // Initialize Hive
  Future<void> init() async {
    try {
      await Hive.initFlutter();

      // Register adapters
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(TaskAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(RecurrencePatternAdapter());
      }
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(SubtaskAdapter());
      }
      if (!Hive.isAdapterRegistered(3)) {
        Hive.registerAdapter(TaskAttachmentAdapter());
      }
      if (!Hive.isAdapterRegistered(4)) {
        Hive.registerAdapter(CategoryAdapter());
      }
      if (!Hive.isAdapterRegistered(5)) {
        Hive.registerAdapter(AchievementTypeAdapter());
      }
      if (!Hive.isAdapterRegistered(6)) {
        Hive.registerAdapter(DailyGoalAdapter());
      }
      if (!Hive.isAdapterRegistered(7)) {
        Hive.registerAdapter(StreakAdapter());
      }
      if (!Hive.isAdapterRegistered(8)) {
        Hive.registerAdapter(AchievementAdapter());
      }

      // Open boxes
      _tasksBox = await Hive.openBox<Task>(AppConstants.tasksBoxName);
      _settingsBox = await Hive.openBox(AppConstants.settingsBoxName);

      // Reset delete permission on app start
      await _settingsBox?.put('delete_permission', false);
    } catch (e) {
      rethrow;
    }
  }

  // Tasks CRUD Operations

  Future<void> addTask(Task task) async {
    await _tasksBox?.put(task.id, task);
  }

  Future<void> updateTask(Task task) async {
    await _tasksBox?.put(task.id, task);
  }

  Future<void> deleteTask(String taskId) async {
    await _tasksBox?.delete(taskId);
  }

  Task? getTask(String taskId) {
    return _tasksBox?.get(taskId);
  }

  List<Task> getAllTasks() {
    return _tasksBox?.values.toList() ?? [];
  }

  List<Task> getTasksByCategory(String categoryId) {
    return _tasksBox?.values
            .where((task) => task.categoryId == categoryId)
            .toList() ??
        [];
  }

  List<Task> getCompletedTasks() {
    return _tasksBox?.values.where((task) => task.isCompleted).toList() ?? [];
  }

  List<Task> getIncompleteTasks() {
    return _tasksBox?.values.where((task) => !task.isCompleted).toList() ?? [];
  }

  List<Task> getOverdueTasks() {
    return _tasksBox?.values
            .where((task) => !task.isCompleted && task.isOverdue)
            .toList() ??
        [];
  }

  List<Task> getTasksDueToday() {
    return _tasksBox?.values
            .where((task) => !task.isCompleted && task.isDueToday)
            .toList() ??
        [];
  }

  Future<void> clearAllTasks() async {
    await _tasksBox?.clear();
  }

  // Settings Operations

  Future<void> saveSetting(String key, dynamic value) async {
    await _settingsBox?.put(key, value);
  }

  T? getSetting<T>(String key, {T? defaultValue}) {
    return _settingsBox?.get(key, defaultValue: defaultValue) as T?;
  }

  bool get notificationsEnabled {
    return _settingsBox?.get(
          AppConstants.notificationsEnabledKey,
          defaultValue: true,
        ) ??
        true;
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    await _settingsBox?.put(AppConstants.notificationsEnabledKey, enabled);
  }

  // Delete permission (resets on app restart)
  bool get hasDeletePermission {
    return _settingsBox?.get('delete_permission', defaultValue: false) ?? false;
  }

  Future<void> setDeletePermission(bool enabled) async {
    await _settingsBox?.put('delete_permission', enabled);
  }

  // Listen to task changes
  Stream<List<Task>> watchAllTasks() {
    return _tasksBox!.watch().map((_) => getAllTasks());
  }

  // Close boxes
  Future<void> close() async {
    await _tasksBox?.close();
    await _settingsBox?.close();
  }
}
