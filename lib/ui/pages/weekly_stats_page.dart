import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../viewmodels/habit_viewmodel.dart';
import '../widgets/weekly_chart.dart';

/// Page displaying weekly statistics and habit analytics
class WeeklyStatsPage extends StatelessWidget {
  const WeeklyStatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistik Mingguan'),
        backgroundColor: AppTheme.backgroundColor,
      ),
      body: Consumer<HabitViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.habits.isEmpty) {
            return _buildEmptyState();
          }

          final weeklyStats = viewModel.getWeeklyStats();
          final completionRate = viewModel.getWeeklyCompletionRate();
          final totalStreak = viewModel.getTotalStreak();
          final topHabit = viewModel.getTopStreakHabit();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Weekly Chart
                WeeklyChart(
                  weeklyStats: weeklyStats,
                  totalHabits: viewModel.habits.length,
                ),
                const SizedBox(height: 20),

                // Summary Stats
                StatsSummary(
                  totalHabits: viewModel.habits.length,
                  completionRate: completionRate,
                  totalStreak: totalStreak,
                  topHabitName: topHabit?.name,
                  topHabitStreak: topHabit?.currentStreak,
                ),
                const SizedBox(height: 20),

                // Individual Habit Stats
                _buildHabitStatsSection(viewModel),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              shape: BoxShape.circle,
            ),
            child: const Text(
              '📊',
              style: TextStyle(fontSize: 48),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Belum ada data',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tambahkan kebiasaan untuk\nmelihat statistik',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitStatsSection(HabitViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detail Kebiasaan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...viewModel.habits.map((habit) => _buildHabitStatItem(habit)),
        ],
      ),
    );
  }

  Widget _buildHabitStatItem(habit) {
    final streak = habit.currentStreak;
    final weeklyCount = habit.weeklyCompletions;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                habit.icon,
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '$weeklyCount/7 hari minggu ini',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Streak
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: streak > 0
                  ? AppTheme.streakColor.withValues(alpha: 0.2)
                  : AppTheme.cardColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  streak > 0 ? '🔥' : '💤',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(width: 4),
                Text(
                  '$streak',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: streak > 0
                        ? AppTheme.streakColor
                        : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
