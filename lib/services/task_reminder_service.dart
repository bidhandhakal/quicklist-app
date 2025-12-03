import 'dart:async';
import '../models/task_model.dart';
import '../services/local_storage_service.dart';
import '../services/notification_service.dart';
import '../utils/constants.dart';

class TaskReminderService {
  static TaskReminderService? _instance;
  static TaskReminderService get instance {
    _instance ??= TaskReminderService._();
    return _instance!;
  }

  TaskReminderService._();

  Timer? _dailyCheckTimer;

  // Initialize reminder service
  void init() {
    // Check for overdue tasks every hour
    _dailyCheckTimer = Timer.periodic(
      const Duration(hours: 1),
      (_) => _checkAndNotifyOverdueTasks(),
    );

    // Initial check
    _checkAndNotifyOverdueTasks();
  }

  // Check and notify about overdue tasks
  Future<void> _checkAndNotifyOverdueTasks() async {
    final storageService = LocalStorageService.instance;
    final notificationService = NotificationService.instance;

    // Check if notifications are enabled
    final notificationsEnabled = storageService.notificationsEnabled;
    if (!notificationsEnabled) return;

    // Get overdue tasks
    final overdueTasks = storageService.getOverdueTasks();

    if (overdueTasks.isNotEmpty) {
      // Send a summary notification for overdue tasks
      await notificationService.showNotification(
        id: AppConstants.overdueTaskNotificationId,
        title: 'Overdue Tasks',
        body:
            'You have ${overdueTasks.length} overdue task${overdueTasks.length > 1 ? 's' : ''}',
        payload: 'overdue_tasks',
      );
    }

    // Check tasks due today
    final tasksDueToday = storageService.getTasksDueToday();

    if (tasksDueToday.isNotEmpty) {
      await notificationService.showNotification(
        id: AppConstants.dailyReminderNotificationId,
        title: 'Tasks Due Today',
        body:
            'You have ${tasksDueToday.length} task${tasksDueToday.length > 1 ? 's' : ''} due today',
        payload: 'tasks_due_today',
      );
    }
  }

  // Schedule reminder for a specific task
  Future<void> scheduleTaskReminder(Task task) async {
    if (task.reminderEnabled &&
        task.reminderTime != null &&
        !task.isCompleted) {
      final notificationService = NotificationService.instance;
      await notificationService.scheduleTaskReminder(task);
    }
  }

  // Cancel reminder for a specific task
  Future<void> cancelTaskReminder(Task task) async {
    final notificationService = NotificationService.instance;
    await notificationService.cancelTaskReminder(task);
  }

  // Reschedule all task reminders
  Future<void> rescheduleAllReminders() async {
    final storageService = LocalStorageService.instance;
    final tasks = storageService.getIncompleteTasks();

    for (final task in tasks) {
      if (task.reminderEnabled && task.reminderTime != null) {
        await scheduleTaskReminder(task);
      }
    }
  }

  // Dispose timer
  void dispose() {
    _dailyCheckTimer?.cancel();
  }
}
