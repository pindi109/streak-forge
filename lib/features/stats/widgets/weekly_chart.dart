
import 'package:flutter/material.dart';
import '../../habits/models/habit_model.dart';

class WeeklyChart extends StatelessWidget {
  final List<HabitModel> habits;

  const WeeklyChart({super.key, required this.habits});

  @override
  Widget build(BuildContext context) {
    final weekData = _buildWeekData();
    final maxVal = weekData.map((d) => d['count'] as int).reduce(
        (a, b) => a > b ? a : b);
    final max = maxVal == 0 ? 1 : maxVal;

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
          const Text(
            'This Week',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${_totalThisWeek()} completions this week',
            style: const TextStyle(
              color: Color(0xFFA1A1AA),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: weekData.map((day) {
                final count = day['count'] as int;
                final label = day['label'] as String;
                final isToday = day['isToday'] as bool;
                final heightFraction = count / max;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '$count',
                      style: TextStyle(
                        color: isToday
                            ? const Color(0xFF7C3AED)
                            : const Color(0xFFA1A1AA),
                        fontSize: 12,
                        fontWeight: isToday
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 6),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 600),
                      width: 32,
                      height: 100 * heightFraction + 4,
                      decoration: BoxDecoration(
                        gradient: isToday
                            ? const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                    Color(0xFF7C3AED),
                                    Color(0xFF3B82F6)
                                  ])
                            : null,
                        color: isToday
                            ? null
                            : count > 0
                                ? const Color(0xFF3F3F46)
                                : const Color(0xFF27272A),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      label,
                      style: TextStyle(
                        color: isToday
                            ? const Color(0xFF7C3AED)
                            : const Color(0xFF71717A),
                        fontSize: 11,
                        fontWeight: isToday
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _buildWeekData() {
    const dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final now = DateTime.now();
    final weekday = now.weekday;
    final startOfWeek = now.subtract(Duration(days: weekday - 1));

    return List.generate(7, (i) {
      final date = startOfWeek.add(Duration(days: i));
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final count =
          habits.where((h) => h.completedDates.contains(dateStr)).length;
      final isToday = date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
      return {
        'label': dayLabels[i],
        'count': count,
        'isToday': isToday,
      };
    });
  }

  int _totalThisWeek() {
    return _buildWeekData()
        .fold<int>(0, (sum, d) => sum + (d['count'] as int));
  }
}