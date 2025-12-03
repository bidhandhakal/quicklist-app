import 'package:intl/intl.dart';

class Helpers {
  // Date Formatting
  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck == today) {
      return 'Today';
    } else if (dateToCheck == tomorrow) {
      return 'Tomorrow';
    } else if (dateToCheck == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM dd, yyyy').format(date);
    }
  }

  static String formatTime(DateTime time) {
    return DateFormat('hh:mm a').format(time);
  }

  static String formatDateTime(DateTime dateTime) {
    return '${formatDate(dateTime)} at ${formatTime(dateTime)}';
  }

  static String formatDateShort(DateTime date) {
    return DateFormat('MMM dd').format(date);
  }

  // Check if task is overdue
  static bool isOverdue(DateTime? deadline) {
    if (deadline == null) return false;
    return deadline.isBefore(DateTime.now());
  }

  // Check if task is due today
  static bool isDueToday(DateTime? deadline) {
    if (deadline == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final deadlineDate = DateTime(deadline.year, deadline.month, deadline.day);
    return deadlineDate == today;
  }

  // Check if task is due this week
  static bool isDueThisWeek(DateTime? deadline) {
    if (deadline == null) return false;
    final now = DateTime.now();
    final weekFromNow = now.add(const Duration(days: 7));
    return deadline.isAfter(now) && deadline.isBefore(weekFromNow);
  }

  // Get days until deadline
  static int daysUntilDeadline(DateTime? deadline) {
    if (deadline == null) return -1;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final deadlineDate = DateTime(deadline.year, deadline.month, deadline.day);
    return deadlineDate.difference(today).inDays;
  }

  // Get deadline status message
  static String getDeadlineStatus(DateTime? deadline) {
    if (deadline == null) return '';

    if (isOverdue(deadline)) {
      final days = -daysUntilDeadline(deadline);
      return days == 0
          ? 'Overdue today'
          : 'Overdue by $days day${days > 1 ? 's' : ''}';
    } else if (isDueToday(deadline)) {
      return 'Due today';
    } else {
      final days = daysUntilDeadline(deadline);
      return 'Due in $days day${days > 1 ? 's' : ''}';
    }
  }
}
