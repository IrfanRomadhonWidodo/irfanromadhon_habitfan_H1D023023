import 'package:hive/hive.dart';

part 'habit_model.g.dart';

@HiveType(typeId: 0)
class HabitModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String icon;

  @HiveField(3)
  DateTime createdAt;

  @HiveField(4)
  List<DateTime> completedDates;

  @HiveField(5)
  bool reminderEnabled;

  @HiveField(6)
  int? reminderHour;

  @HiveField(7)
  int? reminderMinute;

  HabitModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.createdAt,
    List<DateTime>? completedDates,
    this.reminderEnabled = false,
    this.reminderHour,
    this.reminderMinute,
  }) : completedDates = completedDates ?? [];

  /// Check if habit is completed for a specific date
  bool isCompletedOn(DateTime date) {
    return completedDates.any((d) =>
        d.year == date.year && d.month == date.month && d.day == date.day);
  }

  /// Toggle completion status for a specific date
  void toggleCompletion(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    if (isCompletedOn(date)) {
      completedDates.removeWhere((d) =>
          d.year == date.year && d.month == date.month && d.day == date.day);
    } else {
      completedDates.add(normalizedDate);
    }
  }

  /// Calculate current streak (consecutive days from today going backwards)
  int get currentStreak {
    if (completedDates.isEmpty) return 0;

    // Sort dates in descending order
    final sortedDates = List<DateTime>.from(completedDates)
      ..sort((a, b) => b.compareTo(a));

    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);

    int streak = 0;
    DateTime checkDate = normalizedToday;

    // Check if completed today or yesterday to start counting
    final latestCompletion = sortedDates.first;
    final normalizedLatest = DateTime(
        latestCompletion.year, latestCompletion.month, latestCompletion.day);

    // If the latest completion is more than 1 day ago, streak is 0
    if (normalizedToday.difference(normalizedLatest).inDays > 1) {
      return 0;
    }

    // Start from the latest completion date
    checkDate = normalizedLatest;

    for (final date in sortedDates) {
      final normalizedDate = DateTime(date.year, date.month, date.day);
      if (normalizedDate == checkDate) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else if (normalizedDate.isBefore(checkDate)) {
        // Gap in streak
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
        .where((date) => date.isAfter(weekAgo) || _isSameDay(date, weekAgo))
        .length;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Create a copy with updated fields
  HabitModel copyWith({
    String? id,
    String? name,
    String? icon,
    DateTime? createdAt,
    List<DateTime>? completedDates,
    bool? reminderEnabled,
    int? reminderHour,
    int? reminderMinute,
  }) {
    return HabitModel(
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
    return 'HabitModel(id: $id, name: $name, icon: $icon, streak: $currentStreak)';
  }
}
