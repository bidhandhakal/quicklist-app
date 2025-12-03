import 'package:hive/hive.dart';
import 'subtask_model.dart';
import 'task_attachment_model.dart';

part 'task_model.g.dart';

// Recurrence pattern enum
@HiveType(typeId: 1)
enum RecurrencePattern {
  @HiveField(0)
  daily,
  @HiveField(1)
  weekly,
  @HiveField(2)
  monthly,
  @HiveField(3)
  yearly,
}

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String? description;

  @HiveField(3)
  bool isCompleted;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  DateTime? deadline;

  @HiveField(6)
  String? categoryId;

  @HiveField(7)
  int priority; // 0: low, 1: medium, 2: high

  @HiveField(8)
  DateTime? completedAt;

  @HiveField(9)
  bool reminderEnabled;

  @HiveField(10)
  DateTime? reminderTime;

  @HiveField(11)
  List<String>? tags;

  @HiveField(12)
  RecurrencePattern? recurrence;

  @HiveField(13)
  List<Subtask>? subtasks;

  @HiveField(14)
  List<TaskAttachment>? attachments;

  @HiveField(15)
  DateTime? nextRecurrenceDate;

  Task({
    required this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    required this.createdAt,
    this.deadline,
    this.categoryId,
    this.priority = 1, // Default to medium
    this.completedAt,
    this.reminderEnabled = false,
    this.reminderTime,
    this.tags,
    this.recurrence,
    this.subtasks,
    this.attachments,
    this.nextRecurrenceDate,
  });

  // Copy with method
  Task copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? deadline,
    String? categoryId,
    int? priority,
    DateTime? completedAt,
    bool? reminderEnabled,
    DateTime? reminderTime,
    List<String>? tags,
    RecurrencePattern? recurrence,
    List<Subtask>? subtasks,
    List<TaskAttachment>? attachments,
    DateTime? nextRecurrenceDate,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      deadline: deadline ?? this.deadline,
      categoryId: categoryId ?? this.categoryId,
      priority: priority ?? this.priority,
      completedAt: completedAt ?? this.completedAt,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      tags: tags ?? this.tags,
      recurrence: recurrence ?? this.recurrence,
      subtasks: subtasks ?? this.subtasks,
      attachments: attachments ?? this.attachments,
      nextRecurrenceDate: nextRecurrenceDate ?? this.nextRecurrenceDate,
    );
  }

  // Check if task is overdue
  bool get isOverdue {
    if (deadline == null || isCompleted) return false;
    return deadline!.isBefore(DateTime.now());
  }

  // Check if task is due today
  bool get isDueToday {
    if (deadline == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDeadline = DateTime(
      deadline!.year,
      deadline!.month,
      deadline!.day,
    );
    return taskDeadline == today;
  }

  @override
  String toString() {
    return 'Task(id: $id, title: $title, isCompleted: $isCompleted, priority: $priority)';
  }
}
