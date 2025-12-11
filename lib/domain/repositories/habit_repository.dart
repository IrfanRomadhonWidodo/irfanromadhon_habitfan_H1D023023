import '../../data/models/habit_model.dart';
import '../../data/local/habit_local_service.dart';

/// Abstract repository interface for habits
abstract class IHabitRepository {
  Future<List<HabitModel>> getAllHabits();
  Future<HabitModel?> getHabit(String id);
  Future<void> addHabit(HabitModel habit);
  Future<void> updateHabit(HabitModel habit);
  Future<void> deleteHabit(String id);
  Future<void> toggleHabitCompletion(String id, DateTime date);
}

/// Concrete implementation of IHabitRepository
class HabitRepository implements IHabitRepository {
  final HabitLocalService _localService;

  HabitRepository(this._localService);

  @override
  Future<List<HabitModel>> getAllHabits() async {
    return await _localService.getAllHabits();
  }

  @override
  Future<HabitModel?> getHabit(String id) async {
    return await _localService.getHabit(id);
  }

  @override
  Future<void> addHabit(HabitModel habit) async {
    await _localService.addHabit(habit);
  }

  @override
  Future<void> updateHabit(HabitModel habit) async {
    await _localService.updateHabit(habit);
  }

  @override
  Future<void> deleteHabit(String id) async {
    await _localService.deleteHabit(id);
  }

  @override
  Future<void> toggleHabitCompletion(String id, DateTime date) async {
    await _localService.toggleHabitCompletion(id, date);
  }
}
