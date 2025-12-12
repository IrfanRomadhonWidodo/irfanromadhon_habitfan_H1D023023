import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../viewmodels/habit_viewmodel.dart';
import '../widgets/habit_card.dart';
import 'add_habit_page.dart';


/// Home page displaying list of habits with daily checklist
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Timer _timer;
  
  @override
  void initState() {
    super.initState();
    // Load habits when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HabitViewModel>().loadHabits();
    });
    
    // Check for day change every minute
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        setState(() {}); // Rebuild to update date and 'Today' status
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            _buildDateHeader(),
            _buildHabitList(),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      floating: true,
      backgroundColor: AppTheme.backgroundColor,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.accentColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              '🎯',
              style: TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'HabitFan',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildDateHeader() {
    final now = DateTime.now();
    final dayNames = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    final monthNames = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor,
              AppTheme.accentColor,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dayNames[now.weekday % 7],
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${now.day} ${monthNames[now.month - 1]} ${now.year}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Consumer<HabitViewModel>(
                  builder: (context, viewModel, child) {
                    final habits = viewModel.habits;
                    final completedToday = habits
                        .where((h) => h.isCompletedOn(DateTime.now()))
                        .length;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '$completedToday/${habits.length}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Text(
                            'Selesai',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitList() {
    return Consumer<HabitViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const SliverFillRemaining(
            child: Center(
              child: CircularProgressIndicator(
                color: AppTheme.accentColor,
              ),
            ),
          );
        }

        if (viewModel.habits.isEmpty) {
          return SliverFillRemaining(
            child: _buildEmptyState(),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final habit = viewModel.habits[index];
              final isCompletedToday = habit.isCompletedOn(DateTime.now());

              return HabitCard(
                habit: habit,
                isCompletedToday: isCompletedToday,
                onToggle: () => viewModel.toggleTodayCompletion(habit.id),
                onEdit: () => _navigateToEdit(habit.id),
                onDelete: () => viewModel.deleteHabit(habit.id),
              );
            },
            childCount: viewModel.habits.length,
          ),
        );
      },
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
              '🎯',
              style: TextStyle(fontSize: 48),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Belum ada kebiasaan',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap tombol + untuk menambah\nkebiasaan baru',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _navigateToAddHabit(),
            icon: const Icon(Icons.add),
            label: const Text('Tambah Kebiasaan'),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: () => _navigateToAddHabit(),
      icon: const Icon(Icons.add),
      label: const Text('Tambah'),
      backgroundColor: AppTheme.accentColor,
    );
  }

  void _navigateToAddHabit() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddHabitPage(),
      ),
    );
  }

  void _navigateToEdit(String habitId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddHabitPage(editHabitId: habitId),
      ),
    );
  }


}
