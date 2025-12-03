import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import '../models/task_model.dart';

class NotificationService {
  static NotificationService? _instance;
  static NotificationService get instance {
    _instance ??= NotificationService._();
    return _instance!;
  }

  NotificationService._();

  bool _initialized = false;

  // Initialize notifications
  Future<void> init() async {
    if (_initialized) return;

    await AwesomeNotifications().initialize(
      null, // Use default app icon
      [
        NotificationChannel(
          channelKey: 'task_channel',
          channelName: 'Task Notifications',
          channelDescription: 'Notifications for task reminders and updates',
          defaultColor: const Color(0xFF9D50DD),
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          playSound: true,
          enableVibration: true,
        ),
      ],
      debug: false,
    );

    _initialized = true;
  }

  // Request permissions
  Future<bool> requestPermissions() async {
    if (!_initialized) await init();

    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      isAllowed = await AwesomeNotifications()
          .requestPermissionToSendNotifications();
    }
    return isAllowed;
  }

  // Show instant notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_initialized) await init();

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'task_channel',
        title: title,
        body: body,
        payload: payload != null ? {'task_id': payload} : null,
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }

  // Schedule notification
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    if (!_initialized) await init();

    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: id,
          channelKey: 'task_channel',
          title: title,
          body: body,
          payload: payload != null ? {'task_id': payload} : null,
          notificationLayout: NotificationLayout.Default,
        ),
        schedule: NotificationCalendar.fromDate(
          date: scheduledTime,
          preciseAlarm: true,
          allowWhileIdle: true,
        ),
      );
    } catch (e) {
      rethrow;
    }
  }

  // Schedule task reminder
  Future<void> scheduleTaskReminder(Task task) async {
    if (!_initialized) await init();

    if (task.reminderTime != null &&
        task.reminderEnabled &&
        !task.isCompleted) {
      final reminderTime = task.reminderTime!;

      // Always schedule the notification at the specified time
      await scheduleNotification(
        id: task.id.hashCode,
        title: 'Task Reminder',
        body: task.title,
        scheduledTime: reminderTime,
        payload: task.id,
      );

      // Show confirmation that reminder is set
      await showNotification(
        id: task.id.hashCode + 1000000, // Different ID to avoid conflict
        title: 'Reminder Set',
        body: 'Reminder scheduled for: ${task.title}',
      );
    }
  }

  // Cancel notification
  Future<void> cancelNotification(int id) async {
    await AwesomeNotifications().cancel(id);
  }

  // Cancel task reminder
  Future<void> cancelTaskReminder(Task task) async {
    await cancelNotification(task.id.hashCode);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await AwesomeNotifications().cancelAll();
  }

  // Get pending notifications (scheduled notifications)
  Future<List<NotificationModel>> getPendingNotifications() async {
    return await AwesomeNotifications().listScheduledNotifications();
  }

  // Set up notification listeners (call this from main.dart)
  static void setupListeners() {
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
      onNotificationCreatedMethod: onNotificationCreatedMethod,
      onNotificationDisplayedMethod: onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: onDismissActionReceivedMethod,
    );
  }

  // Handle notification action (tap)
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    // Handle notification tap - can be extended to navigate to specific task
    // You can access the payload with: receivedAction.payload
  }

  // Handle notification creation
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    // Handle notification created event
  }

  // Handle notification displayed
  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    // Handle notification displayed event
  }

  // Handle notification dismissed
  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    // Handle notification dismissed event
  }
}
