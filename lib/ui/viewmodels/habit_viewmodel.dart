import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/habit_model.dart';
import '../../data/local/habit_local_service.dart';
import '../../utils/notification_service.dart';

/// ViewModel for managing habits using Provider
class HabitViewModel extends ChangeNotifier {
  final HabitLocalService _localService;
  final NotificationService _notificationService;
  final Uuid _uuid = const Uuid();

  List<HabitModel> _habits = [];
  bool _isLoading = false;
  String? _error;

  HabitViewModel({
    HabitLocalService? localService,
    NotificationService? notificationService,
  })  : _localService = localService ?? HabitLocalService(),
        _notificationService = notificationService ?? NotificationService();

  // Getters
  List<HabitModel> get habits => _habits;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load all habits from storage
  Future<void> loadHabits() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _habits = await _localService.getAllHabits();
      // Sort by creation date (newest first)
      _habits.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      _error = 'Gagal memuat kebiasaan: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add a new habit
  Future<void> addHabit({
    required String name,
    required String icon,
    bool reminderEnabled = false,
    int? reminderHour,
    int? reminderMinute,
  }) async {
    try {
      final habit = HabitModel(
        id: _uuid.v4(),
        name: name,
        icon: icon,
        createdAt: DateTime.now(),
        reminderEnabled: reminderEnabled,
        reminderHour: reminderHour,
        reminderMinute: reminderMinute,
      );

      await _localService.addHabit(habit);
      _habits.insert(0, habit);

      // Schedule reminder if enabled
      if (reminderEnabled && reminderHour != null && reminderMinute != null) {
        await _scheduleReminder(habit);
      }

      notifyListeners();
    } catch (e) {
      _error = 'Gagal menambah kebiasaan: $e';
      notifyListeners();
    }
  }

  /// Update an existing habit
  Future<void> updateHabit({
    required String id,
    required String name,
    required String icon,
    bool? reminderEnabled,
    int? reminderHour,
    int? reminderMinute,
  }) async {
    try {
      final index = _habits.indexWhere((h) => h.id == id);
      if (index == -1) return;

      final oldHabit = _habits[index];
      final updatedHabit = oldHabit.copyWith(
        name: name,
        icon: icon,
        reminderEnabled: reminderEnabled,
        reminderHour: reminderHour,
        reminderMinute: reminderMinute,
      );

      await _localService.updateHabit(updatedHabit);
      _habits[index] = updatedHabit;

      // Update reminder
      await _cancelReminder(oldHabit);
      if (updatedHabit.reminderEnabled &&
          updatedHabit.reminderHour != null &&
          updatedHabit.reminderMinute != null) {
        await _scheduleReminder(updatedHabit);
      }

      notifyListeners();
    } catch (e) {
      _error = 'Gagal mengupdate kebiasaan: $e';
      notifyListeners();
    }
  }

  /// Delete a habit
  Future<void> deleteHabit(String id) async {
    try {
      final habit = _habits.firstWhere((h) => h.id == id);
      await _cancelReminder(habit);
      await _localService.deleteHabit(id);
      _habits.removeWhere((h) => h.id == id);
      notifyListeners();
    } catch (e) {
      _error = 'Gagal menghapus kebiasaan: $e';
      notifyListeners();
    }
  }

  /// Toggle habit completion for today
  Future<void> toggleTodayCompletion(String id) async {
    try {
      final index = _habits.indexWhere((h) => h.id == id);
      if (index == -1) return;

      final habit = _habits[index];
      habit.toggleCompletion(DateTime.now());
      await habit.save();

      notifyListeners();
    } catch (e) {
      _error = 'Gagal mengupdate progress: $e';
      notifyListeners();
    }
  }

  /// Toggle habit completion for a specific date
  Future<void> toggleDateCompletion(String id, DateTime date) async {
    try {
      final index = _habits.indexWhere((h) => h.id == id);
      if (index == -1) return;

      final habit = _habits[index];
      habit.toggleCompletion(date);
      await habit.save();

      notifyListeners();
    } catch (e) {
      _error = 'Gagal mengupdate progress: $e';
      notifyListeners();
    }
  }

  /// Get habit by ID
  HabitModel? getHabitById(String id) {
    try {
      return _habits.firstWhere((h) => h.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get weekly stats: Map of date to number of completed habits
  Map<DateTime, int> getWeeklyStats() {
    final stats = <DateTime, int>{};
    final now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: i));
      int count = 0;

      for (final habit in _habits) {
        if (habit.isCompletedOn(date)) {
          count++;
        }
      }

      stats[date] = count;
    }

    return stats;
  }

  /// Get completion rate for the week (percentage)
  double getWeeklyCompletionRate() {
    if (_habits.isEmpty) return 0;

    final stats = getWeeklyStats();
    final totalPossible = _habits.length * 7;
    final totalCompleted = stats.values.fold(0, (sum, count) => sum + count);

    return (totalCompleted / totalPossible) * 100;
  }

  /// Get total streak across all habits
  int getTotalStreak() {
    if (_habits.isEmpty) return 0;
    return _habits.fold(0, (sum, habit) => sum + habit.currentStreak);
  }

  /// Get habit with the longest streak
  HabitModel? getTopStreakHabit() {
    if (_habits.isEmpty) return null;
    return _habits.reduce((a, b) => 
        a.currentStreak > b.currentStreak ? a : b);
  }

  /// Schedule notification reminder for a habit
  Future<void> _scheduleReminder(HabitModel habit) async {
    if (!habit.reminderEnabled ||
        habit.reminderHour == null ||
        habit.reminderMinute == null) {
      return;
    }

    await _notificationService.scheduleHabitReminder(
      id: habit.id.hashCode,
      habitName: habit.name,
      habitIcon: habit.icon,
      hour: habit.reminderHour!,
      minute: habit.reminderMinute!,
    );
  }

  /// Cancel notification reminder for a habit
  Future<void> _cancelReminder(HabitModel habit) async {
    await _notificationService.cancelHabitReminder(habit.id.hashCode);
  }

  /// Reschedule all enabled habit reminders
  Future<void> rescheduleAllReminders() async {
    for (final habit in _habits) {
      if (habit.reminderEnabled &&
          habit.reminderHour != null &&
          habit.reminderMinute != null) {
        await _scheduleReminder(habit);
      }
    }
  }

  /// Cancel all habit reminders
  Future<void> cancelAllReminders() async {
    await _notificationService.cancelAllReminders();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
