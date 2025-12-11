import 'package:hive_flutter/hive_flutter.dart';
import '../models/habit_model.dart';

/// Service class for Hive local storage operations
class HabitLocalService {
  static const String _boxName = 'habits';
  Box<HabitModel>? _box;

  /// Get the habits box, opening it if necessary
  Future<Box<HabitModel>> get box async {
    if (_box != null && _box!.isOpen) {
      return _box!;
    }
    _box = await Hive.openBox<HabitModel>(_boxName);
    return _box!;
  }

  /// Initialize Hive and register adapters
  static Future<void> initialize() async {
    try {
      await Hive.initFlutter();
      
      // Register adapters
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(HabitModelAdapter());
      }
      
      // Pre-open the box to catch any initialization errors early
      await Hive.openBox<HabitModel>(_boxName);
    } catch (e) {
      // If there's an error, try to delete and recreate the box
      print('Hive initialization error: $e');
      try {
        await Hive.deleteBoxFromDisk(_boxName);
        await Hive.openBox<HabitModel>(_boxName);
      } catch (e2) {
        print('Hive recovery failed: $e2');
      }
    }
  }

  /// Get all habits from storage
  Future<List<HabitModel>> getAllHabits() async {
    try {
      final habitBox = await box;
      return habitBox.values.toList();
    } catch (e) {
      print('Error getting habits: $e');
      return [];
    }
  }

  /// Get a habit by ID
  Future<HabitModel?> getHabit(String id) async {
    try {
      final habitBox = await box;
      return habitBox.values.firstWhere((habit) => habit.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Add a new habit
  Future<void> addHabit(HabitModel habit) async {
    try {
      final habitBox = await box;
      await habitBox.put(habit.id, habit);
    } catch (e) {
      print('Error adding habit: $e');
    }
  }

  /// Update an existing habit
  Future<void> updateHabit(HabitModel habit) async {
    try {
      final habitBox = await box;
      await habitBox.put(habit.id, habit);
    } catch (e) {
      print('Error updating habit: $e');
    }
  }

  /// Delete a habit by ID
  Future<void> deleteHabit(String id) async {
    try {
      final habitBox = await box;
      await habitBox.delete(id);
    } catch (e) {
      print('Error deleting habit: $e');
    }
  }

  /// Toggle habit completion for a specific date
  Future<void> toggleHabitCompletion(String id, DateTime date) async {
    try {
      final habit = await getHabit(id);
      if (habit != null) {
        habit.toggleCompletion(date);
        await habit.save();
      }
    } catch (e) {
      print('Error toggling completion: $e');
    }
  }

  /// Clear all habits (for testing)
  Future<void> clearAll() async {
    try {
      final habitBox = await box;
      await habitBox.clear();
    } catch (e) {
      print('Error clearing habits: $e');
    }
  }

  /// Close the box
  Future<void> close() async {
    if (_box != null && _box!.isOpen) {
      await _box!.close();
    }
  }
}
