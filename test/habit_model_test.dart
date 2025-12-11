import 'package:flutter_test/flutter_test.dart';
import 'package:irfanromadhon_habitfan_h1d023023/data/models/habit_model.dart';

void main() {
  group('HabitModel Tests', () {
    late HabitModel habit;

    setUp(() {
      habit = HabitModel(
        id: 'test-id',
        name: 'Test Habit',
        icon: '🎯',
        createdAt: DateTime.now(),
      );
    });

    test('should create a habit with default empty completedDates', () {
      expect(habit.completedDates, isEmpty);
      expect(habit.name, 'Test Habit');
      expect(habit.icon, '🎯');
    });

    test('isCompletedOn should return false for incomplete date', () {
      final today = DateTime.now();
      expect(habit.isCompletedOn(today), false);
    });

    test('toggleCompletion should add date when not completed', () {
      final today = DateTime.now();
      habit.toggleCompletion(today);
      expect(habit.isCompletedOn(today), true);
      expect(habit.completedDates.length, 1);
    });

    test('toggleCompletion should remove date when already completed', () {
      final today = DateTime.now();
      habit.toggleCompletion(today);
      expect(habit.isCompletedOn(today), true);

      habit.toggleCompletion(today);
      expect(habit.isCompletedOn(today), false);
      expect(habit.completedDates.length, 0);
    });

    test('currentStreak should return 0 for new habit', () {
      expect(habit.currentStreak, 0);
    });

    test('currentStreak should return 1 after completing today', () {
      final today = DateTime.now();
      habit.toggleCompletion(today);
      expect(habit.currentStreak, 1);
    });

    test('currentStreak should count consecutive days', () {
      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));
      final twoDaysAgo = today.subtract(const Duration(days: 2));

      habit.toggleCompletion(today);
      habit.toggleCompletion(yesterday);
      habit.toggleCompletion(twoDaysAgo);

      expect(habit.currentStreak, 3);
    });

    test('currentStreak should break on gap', () {
      final today = DateTime.now();
      final twoDaysAgo = today.subtract(const Duration(days: 2));

      habit.toggleCompletion(today);
      habit.toggleCompletion(twoDaysAgo);

      // Streak should be 1 because yesterday is missing
      expect(habit.currentStreak, 1);
    });

    test('weeklyCompletions should count completions in last 7 days', () {
      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));
      final twoDaysAgo = today.subtract(const Duration(days: 2));
      final eightDaysAgo = today.subtract(const Duration(days: 8));

      habit.toggleCompletion(today);
      habit.toggleCompletion(yesterday);
      habit.toggleCompletion(twoDaysAgo);
      habit.completedDates.add(eightDaysAgo); // Should not count

      expect(habit.weeklyCompletions, 3);
    });

    test('copyWith should create copy with updated fields', () {
      final copy = habit.copyWith(name: 'Updated Name', icon: '🔥');

      expect(copy.name, 'Updated Name');
      expect(copy.icon, '🔥');
      expect(copy.id, habit.id);
      expect(copy.createdAt, habit.createdAt);
    });
  });

  group('HabitModel Reminder Tests', () {
    test('should have reminder disabled by default', () {
      final habit = HabitModel(
        id: 'test-id',
        name: 'Test Habit',
        icon: '🎯',
        createdAt: DateTime.now(),
      );

      expect(habit.reminderEnabled, false);
      expect(habit.reminderHour, null);
      expect(habit.reminderMinute, null);
    });

    test('should save reminder settings', () {
      final habit = HabitModel(
        id: 'test-id',
        name: 'Test Habit',
        icon: '🎯',
        createdAt: DateTime.now(),
        reminderEnabled: true,
        reminderHour: 8,
        reminderMinute: 30,
      );

      expect(habit.reminderEnabled, true);
      expect(habit.reminderHour, 8);
      expect(habit.reminderMinute, 30);
    });
  });
}
