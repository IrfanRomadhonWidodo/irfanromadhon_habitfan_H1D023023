import 'package:flutter_test/flutter_test.dart';
import 'package:irfanromadhon_habitfan_h1d023023/ui/viewmodels/habit_viewmodel.dart';
import 'package:irfanromadhon_habitfan_h1d023023/data/local/habit_local_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:irfanromadhon_habitfan_h1d023023/data/models/habit_model.dart';
import 'dart:io';

void main() {
  group('HabitViewModel Tests', () {
    late HabitViewModel viewModel;
    late HabitLocalService mockLocalService;
    late Directory tempDir;

    setUpAll(() async {
      // Create temporary directory for Hive
      tempDir = await Directory.systemTemp.createTemp('hive_test');
      Hive.init(tempDir.path);
      
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(HabitModelAdapter());
      }
    });

    setUp(() async {
      mockLocalService = HabitLocalService();
      viewModel = HabitViewModel(localService: mockLocalService);
    });

    tearDown(() async {
      await Hive.deleteFromDisk();
    });

    tearDownAll(() async {
      await Hive.close();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('initial state should have empty habits list', () {
      expect(viewModel.habits, isEmpty);
      expect(viewModel.isLoading, false);
      expect(viewModel.error, null);
    });

    test('addHabit should add a new habit', () async {
      await viewModel.addHabit(
        name: 'Test Habit',
        icon: '🎯',
      );

      expect(viewModel.habits.length, 1);
      expect(viewModel.habits.first.name, 'Test Habit');
      expect(viewModel.habits.first.icon, '🎯');
    });

    test('deleteHabit should remove the habit', () async {
      await viewModel.addHabit(
        name: 'Test Habit',
        icon: '🎯',
      );

      final habitId = viewModel.habits.first.id;
      await viewModel.deleteHabit(habitId);

      expect(viewModel.habits, isEmpty);
    });

    test('updateHabit should modify habit properties', () async {
      await viewModel.addHabit(
        name: 'Original Name',
        icon: '🎯',
      );

      final habitId = viewModel.habits.first.id;
      await viewModel.updateHabit(
        id: habitId,
        name: 'Updated Name',
        icon: '🔥',
      );

      expect(viewModel.habits.first.name, 'Updated Name');
      expect(viewModel.habits.first.icon, '🔥');
    });

    test('toggleTodayCompletion should toggle completion status', () async {
      await viewModel.addHabit(
        name: 'Test Habit',
        icon: '🎯',
      );

      final habitId = viewModel.habits.first.id;
      final today = DateTime.now();

      // Initially not completed
      expect(viewModel.habits.first.isCompletedOn(today), false);

      // Toggle to complete
      await viewModel.toggleTodayCompletion(habitId);
      expect(viewModel.habits.first.isCompletedOn(today), true);

      // Toggle to incomplete
      await viewModel.toggleTodayCompletion(habitId);
      expect(viewModel.habits.first.isCompletedOn(today), false);
    });

    test('getWeeklyStats should return correct data', () async {
      await viewModel.addHabit(name: 'Habit 1', icon: '🎯');
      await viewModel.addHabit(name: 'Habit 2', icon: '🔥');

      final habit1Id = viewModel.habits[0].id;
      final habit2Id = viewModel.habits[1].id;

      await viewModel.toggleTodayCompletion(habit1Id);
      await viewModel.toggleTodayCompletion(habit2Id);

      final stats = viewModel.getWeeklyStats();
      final today = DateTime.now();
      final todayKey = stats.keys.firstWhere((date) =>
          date.year == today.year &&
          date.month == today.month &&
          date.day == today.day);

      expect(stats[todayKey], 2);
    });

    test('getHabitById should return correct habit', () async {
      await viewModel.addHabit(name: 'Test Habit', icon: '🎯');

      final habitId = viewModel.habits.first.id;
      final foundHabit = viewModel.getHabitById(habitId);

      expect(foundHabit, isNotNull);
      expect(foundHabit!.name, 'Test Habit');
    });

    test('getHabitById should return null for non-existent id', () {
      final foundHabit = viewModel.getHabitById('non-existent-id');
      expect(foundHabit, isNull);
    });

    test('getWeeklyCompletionRate should calculate correctly', () async {
      await viewModel.addHabit(name: 'Habit 1', icon: '🎯');

      final habitId = viewModel.habits.first.id;
      await viewModel.toggleTodayCompletion(habitId);

      final rate = viewModel.getWeeklyCompletionRate();
      // 1 habit completed on 1 day out of 7 = 1/7 * 100 ≈ 14.28%
      expect(rate, closeTo(14.28, 0.1));
    });

    test('getTotalStreak should sum all habit streaks', () async {
      await viewModel.addHabit(name: 'Habit 1', icon: '🎯');
      await viewModel.addHabit(name: 'Habit 2', icon: '🔥');

      final habit1Id = viewModel.habits[0].id;
      final habit2Id = viewModel.habits[1].id;

      await viewModel.toggleTodayCompletion(habit1Id);
      await viewModel.toggleTodayCompletion(habit2Id);

      final totalStreak = viewModel.getTotalStreak();
      expect(totalStreak, 2); // Both habits have 1 day streak
    });
  });
}
