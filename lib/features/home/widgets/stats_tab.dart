import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../habits/providers/habit_provider.dart';
import '../../habits/models/habit_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/streak_calculator.dart';
import '../../../shared/widgets/loading_widget.dart';

class StatsTab extends StatefulWidget {
  const StatsTab({super.key});

  @override
  State<StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends State<StatsTab> {
  int _selectedPeriod = 7;

  @override
  Widget build(BuildContext context) {
    final habitProvider = context.watch<HabitProvider>();

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: _buildHeader(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: _buildPeriodSelector(),
              ),
            ),
            if (habitProvider.isLoading)
              const SliverToBoxAdapter(
                  child: Padding(
                padding: EdgeInsets.all(48),
                child: LoadingWidget(),
              ))
            else if (habitProvider.habits.isEmpty)
              const SliverToBoxAdapter(child: _EmptyStatsState())
            else
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCompletionChart(habitProvider),
                      const SizedBox(height: 24),
                      _buildHabitStreaksList(habitProvider),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistics',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Track your progress over time',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          _periodButton('7 Days', 7),
          _periodButton('30 Days', 30),
        ],
      ),
    );
  }

  Widget _periodButton(String label, int days) {
    final isSelected = _selectedPeriod == days;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPeriod = days),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : AppTheme.textSecondary,
              fontSize: 13,
              fontWeight:
                  isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionChart(HabitProvider habitProvider) {
    final days = _selectedPeriod == 7
        ? AppDateUtils.getLast7Days()
        : AppDateUtils.getLast30Days();

    final spots = <FlSpot>[];
    for (int i = 0; i < days.length; i++) {
      final day = days[i];
      int completed = 0;
      int total = 0;
      for (final habit in habitProvider.habits) {
        final weekday = day.weekday % 7;
        if (habit.weekDays.contains(weekday)) {
          total++;
          if (StreakCalculator.isCompletedOnDate(habit.completedDates, day)) {
            completed++;
          }
        }
      }
      final rate = total == 0 ? 0.0 : completed / total;
      spots.add(FlSpot(i.toDouble(), rate));
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
          const Text(
            'Completion Rate',
            style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          const Text(
            'Daily habit completion percentage',
            style:
                TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 0.25,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: AppTheme.border,
                    strokeWidth: 0.5,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      interval: 0.5,
                      getTitlesWidget: (value, meta) => Text(
                        '${(value * 100).toInt()}%',
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 10),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: _selectedPeriod == 7 ? 1 : 4,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= days.length)
                          return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            AppDateUtils.formatDayOfWeek(days[idx]),
                            style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 10),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (days.length - 1).toDouble(),
                minY: 0,
                maxY: 1,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    gradient: const LinearGradient(
                      colors: [AppTheme.gradientStart, AppTheme.gradientEnd],
                    ),
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, idx) =>
                          FlDotCirclePainter(
                        radius: 3,
                        color: AppTheme.primary,
                        strokeWidth: 1.5,
                        strokeColor: AppTheme.surface,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primary.withOpacity(0.25),
                          AppTheme.primary.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitStreaksList(HabitProvider habitProvider) {
    final sorted = List<HabitModel>.from(habitProvider.habits)
      ..sort((a, b) => b.currentStreak.compareTo(a.currentStreak));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Habit Streaks',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...sorted.map((habit) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _HabitStreakRow(habit: habit),
            )),
      ],
    );
  }
}

class _HabitStreakRow extends StatelessWidget {
  final HabitModel habit;
  const _HabitStreakRow({required this.habit});

  @override
  Widget build(BuildContext context) {
    final rate = habit.createdAt.isBefore(DateTime.now())
        ? StreakCalculator.calculateCompletionRate(
            habit.completedDates,
            DateTime.now().difference(habit.createdAt).inDays + 1)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(habit.emoji,
                  style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(habit.title,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: rate,
                    backgroundColor: AppTheme.border,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        AppTheme.primary),
                    minHeight: 4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(rate * 100).toStringAsFixed(0)}% completion rate',
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            children: [
              const Text('🔥', style: TextStyle(fontSize: 20)),
              Text(
                '${habit.currentStreak}',
                style: const TextStyle(
                    color: AppTheme.warning,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
              const Text('streak',
                  style: TextStyle(
                      color: AppTheme.textSecondary, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyStatsState extends StatelessWidget {
  const _EmptyStatsState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('📊', style: TextStyle(fontSize: 56)),
          SizedBox(height: 20),
          Text(
            'No data yet',
            style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8),
          Text(
            'Create habits and start tracking to see your statistics here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
