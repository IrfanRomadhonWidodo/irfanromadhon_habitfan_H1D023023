import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';
import '../../utils/date_utils.dart';

/// Bar chart widget for displaying weekly habit statistics
class WeeklyChart extends StatelessWidget {
  final Map<DateTime, int> weeklyStats;
  final int totalHabits;

  const WeeklyChart({
    super.key,
    required this.weeklyStats,
    required this.totalHabits,
  });

  @override
  Widget build(BuildContext context) {
    final sortedDates = weeklyStats.keys.toList()
      ..sort((a, b) => a.compareTo(b));

    return Container(
      height: 250,
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
            'Progress Mingguan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Jumlah kebiasaan selesai per hari',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: totalHabits.toDouble() + 1,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => AppTheme.primaryColor,
                    tooltipRoundedRadius: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final date = sortedDates[group.x.toInt()];
                      return BarTooltipItem(
                        '${HabitDateUtils.formatShort(date)}\n${rod.toY.toInt()} selesai',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= sortedDates.length) {
                          return const SizedBox.shrink();
                        }
                        final date = sortedDates[index];
                        final isToday = HabitDateUtils.isToday(date);
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            HabitDateUtils.getDayAbbreviationId(date),
                            style: TextStyle(
                              color: isToday
                                  ? AppTheme.accentColor
                                  : AppTheme.textSecondary,
                              fontWeight:
                                  isToday ? FontWeight.bold : FontWeight.normal,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        if (value == value.toInt().toDouble()) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 10,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppTheme.surfaceColor,
                    strokeWidth: 1,
                  ),
                ),
                barGroups: _buildBarGroups(sortedDates),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups(List<DateTime> sortedDates) {
    return List.generate(sortedDates.length, (index) {
      final date = sortedDates[index];
      final count = weeklyStats[date] ?? 0;
      final isToday = HabitDateUtils.isToday(date);

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: count.toDouble(),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: isToday
                  ? [
                      AppTheme.accentColor,
                      AppTheme.primaryColor,
                    ]
                  : [
                      AppTheme.accentColor.withValues(alpha: 0.6),
                      AppTheme.primaryColor.withValues(alpha: 0.6),
                    ],
            ),
            width: 24,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: totalHabits.toDouble(),
              color: AppTheme.surfaceColor,
            ),
          ),
        ],
      );
    });
  }
}

/// Summary stats widget
class StatsSummary extends StatelessWidget {
  final int totalHabits;
  final double completionRate;
  final int totalStreak;
  final String? topHabitName;
  final int? topHabitStreak;

  const StatsSummary({
    super.key,
    required this.totalHabits,
    required this.completionRate,
    required this.totalStreak,
    this.topHabitName,
    this.topHabitStreak,
  });

  @override
  Widget build(BuildContext context) {
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
            'Ringkasan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: '📊',
                  label: 'Total Kebiasaan',
                  value: totalHabits.toString(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  icon: '✅',
                  label: 'Tingkat Selesai',
                  value: '${completionRate.toStringAsFixed(1)}%',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: '🔥',
                  label: 'Total Streak',
                  value: totalStreak.toString(),
                ),
              ),
              const SizedBox(width: 12),
              if (topHabitName != null && topHabitStreak != null)
                Expanded(
                  child: _buildStatItem(
                    icon: '🏆',
                    label: 'Streak Terbaik',
                    value: '$topHabitStreak hari',
                    subtitle: topHabitName,
                  ),
                )
              else
                const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String icon,
    required String label,
    required String value,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: AppTheme.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
