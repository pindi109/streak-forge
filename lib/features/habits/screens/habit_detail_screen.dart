import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/habit_model.dart';
import '../providers/habit_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/streak_calculator.dart';
import 'edit_habit_screen.dart';

class HabitDetailScreen extends StatelessWidget {
  final HabitModel habit;
  const HabitDetailScreen({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {
    final habitProvider = context.watch<HabitProvider>();
    final currentHabit =
        habitProvider.getHabitById(habit.id) ?? habit;

    return Scaffold(
      appBar: AppBar(
        title: Text(currentHabit.emoji + ' ' + currentHabit.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => EditHabitScreen(habit: currentHabit)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20, color: AppTheme.error),
            onPressed: () => _confirmDelete(context, habitProvider),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildStatsRow(currentHabit),
              const SizedBox(height: 24),
              _buildWeekCalendar(currentHabit),
              const SizedBox(height: 24),
              _buildBarChart(currentHabit),
              const SizedBox(height: 24),
              _buildDetails(currentHabit),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(HabitModel habit) {
    final totalDays =
        DateTime.now().difference(habit.createdAt).inDays + 1;
    final rate =
        StreakCalculator.calculateCompletionRate(habit.completedDates, totalDays);

    return Row(
      children: [
        Expanded(
            child: _statCard('Current\nStreak', '${habit.currentStreak}🔥',
                AppTheme.warning)),
        const SizedBox(width: 12),
        Expanded(
            child: _statCard(
                'Longest\nStreak', '${habit.longestStreak}', AppTheme.primary)),
        const SizedBox(width: 12),
        Expanded(
            child: _statCard('Completion\nRate',
                '${(rate * 100).toStringAsFixed(0)}%', AppTheme.success)),
        const SizedBox(width: 12),
        Expanded(
            child: _statCard('Total\nDone', '${habit.totalCompletions}',
                AppTheme.gradientEnd)),
      ],
    );
  }

  Widget _statCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.w700),
              textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 10),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildWeekCalendar(HabitModel habit) {
    final days = AppDateUtils.getLast7Days();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('This Week',
            style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: days.map((day) {
            final isCompleted =
                StreakCalculator.isCompletedOnDate(habit.completedDates, day);
            final isToday = AppDateUtils.isToday(day);
            return Column(
              children: [
                Text(
                  AppDateUtils.formatDayOfWeek(day),
                  style: TextStyle(
                    color: isToday
                        ? AppTheme.primary
                        : AppTheme.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppTheme.primary
                        : AppTheme.surface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isToday
                          ? AppTheme.primary
                          : AppTheme.border,
                      width: isToday ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check,
                            color: Colors.white, size: 16)
                        : Text(
                            '${day.day}',
                            style: TextStyle(
                              color: isToday
                                  ? AppTheme.primary
                                  : AppTheme.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBarChart(HabitModel habit) {
    final days = AppDateUtils.getLast30Days();
    final barGroups = <BarChartGroupData>[];

    for (int i = 0; i < days.length; i++) {
      final isCompleted =
          StreakCalculator.isCompletedOnDate(habit.completedDates, days[i]);
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: isCompleted ? 1 : 0,
              gradient: isCompleted ? AppTheme.primaryGradient : null,
              color: isCompleted ? null : AppTheme.border,
              width: 6,
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(3)),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Last 30 Days',
              style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 1,
                minY: 0,
                barTouchData: BarTouchData(enabled: false),
                titlesData: const FlTitlesData(
                  show: false,
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
                barGroups: barGroups,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetails(HabitModel habit) {
    const days = [
      'Sunday', 'Monday', 'Tuesday', 'Wednesday',
      'Thursday', 'Friday', 'Saturday'
    ];
    final selectedDays = habit.weekDays.map((d) => days[d]).join(', ');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          _detailRow('Category', habit.category),
          const Divider(color: AppTheme.border, height: 20),
          _detailRow('Repeat', selectedDays),
          if (habit.reminderTime != null) ...
            [
              const Divider(color: AppTheme.border, height: 20),
              _detailRow(
                  'Reminder', '${habit.reminderTime} daily'),
            ],
          const Divider(color: AppTheme.border, height: 20),
          _detailRow('Created',
              AppDateUtils.formatDate(habit.createdAt)),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 14)),
        Flexible(
          child: Text(value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, HabitProvider habitProvider) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Habit',
            style: TextStyle(color: AppTheme.textPrimary)),
        content: const Text(
          'Are you sure you want to delete this habit? All streak data will be lost.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete',
                style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await habitProvider.deleteHabit(habit.id);
      if (context.mounted) Navigator.pop(context);
    }
  }
}
