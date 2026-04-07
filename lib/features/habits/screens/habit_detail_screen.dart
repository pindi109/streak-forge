
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habit_model.dart';
import '../providers/habits_provider.dart';
import '../widgets/habit_calendar.dart';
import '../widgets/habit_stats_row.dart';
import 'add_habit_screen.dart';

class HabitDetailScreen extends StatefulWidget {
  final HabitModel habit;

  const HabitDetailScreen({super.key, required this.habit});

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  HabitModel get _habit {
    final provider = context.read<HabitsProvider>();
    return provider.habits.firstWhere(
      (h) => h.id == widget.habit.id,
      orElse: () => widget.habit,
    );
  }

  Color get _color {
    try {
      return Color(
          int.parse(_habit.colorHex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return const Color(0xFF7C3AED);
    }
  }

  Future<void> _deleteHabit() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF18181B),
        title: const Text('Delete Habit',
            style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete "${_habit.title}"? This action cannot be undone.',
          style: const TextStyle(color: Color(0xFFA1A1AA)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFFA1A1AA))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<HabitsProvider>().deleteHabit(_habit.id);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitsProvider>(
      builder: (context, provider, _) {
        final habit = provider.habits.firstWhere(
          (h) => h.id == widget.habit.id,
          orElse: () => widget.habit,
        );
        final color = Color(
          int.parse(habit.colorHex.replaceFirst('#', '0xFF')));

        return Scaffold(
          backgroundColor: const Color(0xFF0A0A0F),
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: const Color(0xFF0A0A0F),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios,
                      color: Colors.white, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Colors.white),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AddHabitScreen(existingHabit: habit),
                      ),
                    ),
                  ),
                  IconButton(
                    icon:
                        const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: _deleteHabit,
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          color.withOpacity(0.3),
                          const Color(0xFF0A0A0F),
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 60),
                        Text(
                          habit.emoji,
                          style: const TextStyle(fontSize: 56),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          habit.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (habit.description.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              habit.description,
                              style: const TextStyle(
                                color: Color(0xFFA1A1AA),
                                fontSize: 13,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStreakHero(habit, color),
                      const SizedBox(height: 24),
                      HabitStatsRow(habit: habit),
                      const SizedBox(height: 24),
                      const Text(
                        'Progress Calendar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      HabitCalendar(habit: habit, accentColor: color),
                      const SizedBox(height: 24),
                      _buildTodayButton(habit, provider),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStreakHero(HabitModel habit, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF18181B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _streakItem(
            '${habit.currentStreak}',
            'Current\nStreak',
            Icons.local_fire_department,
            const Color(0xFFF97316),
          ),
          Container(width: 1, height: 50, color: const Color(0xFF27272A)),
          _streakItem(
            '${habit.longestStreak}',
            'Longest\nStreak',
            Icons.emoji_events,
            const Color(0xFFFBBF24),
          ),
          Container(width: 1, height: 50, color: const Color(0xFF27272A)),
          _streakItem(
            '${habit.completedDates.length}',
            'Total\nDays',
            Icons.check_circle,
            const Color(0xFF22C55E),
          ),
        ],
      ),
    );
  }

  Widget _streakItem(
      String value, String label, IconData icon, Color iconColor) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFFA1A1AA),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildTodayButton(HabitModel habit, HabitsProvider provider) {
    final isCompleted = habit.isCompletedToday();
    return GestureDetector(
      onTap: () => provider.toggleCompletion(habit),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: isCompleted
              ? null
              : const LinearGradient(
                  colors: [Color(0xFF7C3AED), Color(0xFF3B82F6)]),
          color: isCompleted ? const Color(0xFF18181B) : null,
          borderRadius: BorderRadius.circular(16),
          border: isCompleted
              ? Border.all(color: const Color(0xFF27272A))
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isCompleted
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: isCompleted
                  ? const Color(0xFF22C55E)
                  : Colors.white,
            ),
            const SizedBox(width: 10),
            Text(
              isCompleted ? 'Completed Today' : 'Mark as Done Today',
              style: TextStyle(
                color: isCompleted ? const Color(0xFF22C55E) : Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}