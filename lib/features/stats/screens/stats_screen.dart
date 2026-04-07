
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../habits/providers/habits_provider.dart';
import '../../habits/models/habit_model.dart';
import '../widgets/weekly_chart.dart';
import '../widgets/category_breakdown.dart';
import '../widgets/heatmap_widget.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<HabitsProvider>(
        builder: (context, provider, _) {
          return CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: Text(
                    'Statistics',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if (provider.isLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFF7C3AED)),
                  ),
                )
              else if (provider.habits.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: _EmptyStatsWidget(),
                    ),
                  ),
                )
              else ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _OverallStatsRow(provider: provider),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: WeeklyChart(habits: provider.habits),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: HeatmapWidget(habits: provider.habits),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: CategoryBreakdown(habits: provider.habits),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _HabitLeaderboard(habits: provider.habits),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _OverallStatsRow extends StatelessWidget {
  final HabitsProvider provider;

  const _OverallStatsRow({required this.provider});

  @override
  Widget build(BuildContext context) {
    final totalCompleted = provider.habits
        .fold<int>(0, (sum, h) => sum + h.completedDates.length);
    final avgStreak = provider.habits.isEmpty
        ? 0
        : provider.habits
                .fold<int>(0, (sum, h) => sum + h.currentStreak) ~/
            provider.habits.length;
    final bestRate = provider.habits.isEmpty
        ? 0.0
        : provider.habits
            .map((h) => h.completionRate)
            .reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Overview',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _OverviewCard(
                label: 'Total Completions',
                value: '$totalCompleted',
                icon: Icons.check_circle_outline,
                color: const Color(0xFF22C55E),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _OverviewCard(
                label: 'Avg Streak',
                value: '${avgStreak}d',
                icon: Icons.local_fire_department,
                color: const Color(0xFFF97316),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _OverviewCard(
                label: 'Best Rate',
                value: '${(bestRate * 100).toInt()}%',
                icon: Icons.star_outline,
                color: const Color(0xFFFBBF24),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _OverviewCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF18181B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF27272A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFA1A1AA),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _HabitLeaderboard extends StatelessWidget {
  final List<HabitModel> habits;

  const _HabitLeaderboard({required this.habits});

  @override
  Widget build(BuildContext context) {
    final sorted = List<HabitModel>.from(habits)
      ..sort((a, b) => b.currentStreak.compareTo(a.currentStreak));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF18181B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF27272A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.leaderboard, color: Color(0xFFFBBF24), size: 20),
              SizedBox(width: 8),
              Text(
                'Streak Leaderboard',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...sorted.take(5).toList().asMap().entries.map((e) {
            final index = e.key;
            final habit = e.value;
            final medals = ['🥇', '🥈', '🥉'];
            final medal = index < 3 ? medals[index] : '${index + 1}.';
            final color = Color(
                int.parse(habit.colorHex.replaceFirst('#', '0xFF')));

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Text(medal, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 12),
                  Text(habit.emoji, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      habit.title,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.local_fire_department,
                            color: Color(0xFFF97316), size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${habit.currentStreak}',
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _EmptyStatsWidget extends StatelessWidget {
  const _EmptyStatsWidget();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.bar_chart, color: Color(0xFF3F3F46), size: 80),
        const SizedBox(height: 16),
        const Text(
          'No Data Yet',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Start tracking habits to\nsee your statistics here.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 14),
        ),
      ],
    );
  }
}