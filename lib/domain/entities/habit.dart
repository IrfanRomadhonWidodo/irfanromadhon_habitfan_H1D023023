import '../../data/models/habit_model.dart';

/// Business entity for Habit
/// This entity wraps the HabitModel and provides additional business logic
class Habit {
  final String id;
  final String name;
  final String icon;
  final DateTime createdAt;
  final List<DateTime> completedDates;
  final bool reminderEnabled;
  final int? reminderHour;
  final int? reminderMinute;

  Habit({
    required this.id,
    required this.name,
    required this.icon,
    required this.createdAt,
    required this.completedDates,
    this.reminderEnabled = false,
    this.reminderHour,
    this.reminderMinute,
  });

  /// Create from HabitModel
  factory Habit.fromModel(HabitModel model) {
    return Habit(
      id: model.id,
      name: model.name,
      icon: model.icon,
      createdAt: model.createdAt,
      completedDates: List.from(model.completedDates),
      reminderEnabled: model.reminderEnabled,
      reminderHour: model.reminderHour,
      reminderMinute: model.reminderMinute,
    );
  }

  /// Convert to HabitModel
  HabitModel toModel() {
    return HabitModel(
      id: id,
      name: name,
      icon: icon,
      createdAt: createdAt,
      completedDates: List.from(completedDates),
      reminderEnabled: reminderEnabled,
      reminderHour: reminderHour,
      reminderMinute: reminderMinute,
    );
  }

  /// Check if habit is completed for a specific date
  bool isCompletedOn(DateTime date) {
    return completedDates.any((d) =>
        d.year == date.year && d.month == date.month && d.day == date.day);
  }

  /// Calculate current streak
  int get currentStreak {
    if (completedDates.isEmpty) return 0;

    final sortedDates = List<DateTime>.from(completedDates)
      ..sort((a, b) => b.compareTo(a));

    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);

    int streak = 0;
    DateTime checkDate = normalizedToday;

    final latestCompletion = sortedDates.first;
    final normalizedLatest = DateTime(
        latestCompletion.year, latestCompletion.month, latestCompletion.day);

    if (normalizedToday.difference(normalizedLatest).inDays > 1) {
      return 0;
    }

    checkDate = normalizedLatest;

    for (final date in sortedDates) {
      final normalizedDate = DateTime(date.year, date.month, date.day);
      if (normalizedDate == checkDate) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else if (normalizedDate.isBefore(checkDate)) {
        break;
      }
    }

    return streak;
  }

  /// Get completions count for the last 7 days
  int get weeklyCompletions {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return completedDates
        .where((date) => date.isAfter(weekAgo))
        .length;
  }

  /// Create a copy with updated fields
  Habit copyWith({
    String? id,
    String? name,
    String? icon,
    DateTime? createdAt,
    List<DateTime>? completedDates,
    bool? reminderEnabled,
    int? reminderHour,
    int? reminderMinute,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
      completedDates: completedDates ?? List.from(this.completedDates),
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
    );
  }

  @override
  String toString() {
    return 'Habit(id: $id, name: $name, icon: $icon, streak: $currentStreak)';
  }
}
