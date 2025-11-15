// lib/services/repeat_task_service.dart
import '../models/task.dart';

class RepeatTaskService {
  /// Generate next occurrence date based on repeat type
  static DateTime? getNextOccurrence(Task task, DateTime currentDate) {
    if (task.repeatType == null || task.repeatType == 'none') return null;
    if (task.deadline == null || task.deadline!.isEmpty) return null;

    try {
      final baseDate = DateTime.parse(task.deadline!);

      switch (task.repeatType) {
        case 'daily':
          return baseDate.add(const Duration(days: 1));

        case 'weekly':
          return baseDate.add(const Duration(days: 7));

        case 'monthly':
          // Same day next month
          return DateTime(
            baseDate.year,
            baseDate.month + 1,
            baseDate.day,
            baseDate.hour,
            baseDate.minute,
          );

        case 'yearly':
          // Same date next year
          return DateTime(
            baseDate.year + 1,
            baseDate.month,
            baseDate.day,
            baseDate.hour,
            baseDate.minute,
          );

        default:
          return null;
      }
    } catch (e) {
      print('Error calculating next occurrence: $e');
      return null;
    }
  }

  /// Generate task instances for a date range
  static List<Task> generateOccurrences(
    Task task,
    DateTime startDate,
    DateTime endDate,
  ) {
    if (task.repeatType == null || task.repeatType == 'none') {
      return [task];
    }

    final List<Task> occurrences = [];
    DateTime? current = DateTime.parse(task.deadline!);

    while (current != null &&
        current.isBefore(endDate) &&
        occurrences.length < 365) {
      // Safety limit
      if (current.isAfter(startDate) || isSameDay(current, startDate)) {
        // Create a copy of the task with new deadline
        final occurrence = Task(
          id: '${task.id}_${current.toIso8601String()}',
          title: task.title,
          description: task.description,
          category: task.category,
          priority: task.priority,
          status: task.status,
          deadline: current.toIso8601String(),
          startTime: task.startTime,
          endTime: task.endTime,
          isAllDay: task.isAllDay,
          repeatType: task.repeatType,
          reminders: task.reminders,
          color: task.color,
          location: task.location,
          url: task.url,
          groupId: task.groupId,
          creatorId: task.creatorId,
          assignedUsers: task.assignedUsers,
          tags: task.tags,
          attachments: task.attachments,
        );
        occurrences.add(occurrence);
      }

      current = getNextOccurrence(task, current);
    }

    return occurrences;
  }

  /// Check if two dates are the same day
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Get human-readable repeat description
  static String getRepeatDescription(String? repeatType) {
    switch (repeatType) {
      case 'daily':
        return 'Hàng ngày';
      case 'weekly':
        return 'Hàng tuần';
      case 'monthly':
        return 'Hàng tháng';
      case 'yearly':
        return 'Hàng năm';
      default:
        return 'Không lặp lại';
    }
  }

  /// Get list of repeat options
  static List<Map<String, String>> getRepeatOptions() {
    return [
      {'value': 'none', 'label': 'Không lặp lại'},
      {'value': 'daily', 'label': 'Hàng ngày'},
      {'value': 'weekly', 'label': 'Hàng tuần'},
      {'value': 'monthly', 'label': 'Hàng tháng'},
      {'value': 'yearly', 'label': 'Hàng năm'},
    ];
  }

  /// Check if task should be shown on a specific date
  static bool shouldShowOnDate(Task task, DateTime date) {
    if (task.deadline == null || task.deadline!.isEmpty) return false;

    try {
      final taskDate = DateTime.parse(task.deadline!);

      if (isSameDay(taskDate, date)) {
        return true;
      }

      if (task.repeatType == null || task.repeatType == 'none') {
        return false;
      }

      // Check if date falls on a repeat occurrence
      DateTime? current = taskDate;
      while (current != null &&
          current.isBefore(date.add(const Duration(days: 1)))) {
        if (isSameDay(current, date)) {
          return true;
        }
        current = getNextOccurrence(task, current);
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// Get reminder time options
  static List<String> getReminderOptions() {
    return [
      'Tại thời điểm sự kiện',
      '5 phút trước',
      '10 phút trước',
      '15 phút trước',
      '30 phút trước',
      '1 giờ trước',
      '2 giờ trước',
      '1 ngày trước',
      '2 ngày trước',
      '1 tuần trước',
    ];
  }
}
