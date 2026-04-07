
import 'package:flutter/material.dart';
import '../../habits/models/habit_model.dart';

class CategoryBreakdown extends StatelessWidget {
  final List<HabitModel> habits;

  const CategoryBreakdown({super.key, required this.habits});

  @override
  Widget build(BuildContext context) {
    final categoryMap = <HabitCategory, int>{};
    for (final habit in habits) {
      categoryMap[habit.category] = (categoryMap[habit.category] ?? 0) + 1;
    }

    final sortedEntries = categoryMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (sortedEntries.isEmpty) return const SizedBox.shrink();

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
            'Categories',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...sortedEntries.map((entry) {
            final fraction = entry.value / habits.length;
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        _categoryEmoji(entry.key),
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _categoryName(entry.key),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Text(
                        '${entry.value} habit${entry.value > 1 ? 's' : ''}',
                        style: const TextStyle(
                          color: Color(0xFFA1A1AA),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: fraction,
                      backgroundColor: const Color(0xFF27272A),
                      valueColor: AlwaysStoppedAnimation<Color>(
                          _categoryColor(entry.key)),
                      minHeight: 6,
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

  String _categoryEmoji(HabitCategory cat) {
    switch (cat) {
      case HabitCategory.health:
        return '🏥';
      case HabitCategory.fitness:
        return '💪';
      case HabitCategory.mindfulness:
        return '🧘';
      case HabitCategory.productivity:
        return '📈';
      case HabitCategory.learning:
        return '📚';
      case HabitCategory.social:
        return '🤝';
      case HabitCategory.finance:
        return '💰';
      case HabitCategory.other:
        return '✨';
    }
  }

  String _categoryName(HabitCategory cat) {
    return cat.name[0].toUpperCase() + cat.name.substring(1);
  }

  Color _categoryColor(HabitCategory cat) {
    switch (cat) {
      case HabitCategory.health:
        return const Color(0xFFEF4444);
      case HabitCategory.fitness:
        return const Color(0xFFF97316);
      case HabitCategory.mindfulness:
        return const Color(0xFF8B5CF6);
      case HabitCategory.productivity:
        return const Color(0xFF3B82F6);
      case HabitCategory.learning:
        return const Color(0xFF22C55E);
      case HabitCategory.social:
        return const Color(0xFFEC4899);
      case HabitCategory.finance:
        return const Color(0xFFFBBF24);
      case HabitCategory.other:
        return const Color(0xFF14B8A6);
    }
  }
}