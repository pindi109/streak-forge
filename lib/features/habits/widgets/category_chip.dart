
import 'package:flutter/material.dart';
import '../models/habit_model.dart';

class CategoryChip extends StatelessWidget {
  final HabitCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF7C3AED), Color(0xFF3B82F6)])
              : null,
          color: isSelected ? null : const Color(0xFF18181B),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : const Color(0xFF27272A),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _categoryEmoji(category),
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(width: 6),
            Text(
              _categoryName(category),
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : const Color(0xFFA1A1AA),
                fontSize: 13,
                fontWeight: isSelected
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ],
        ),
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
    switch (cat) {
      case HabitCategory.health:
        return 'Health';
      case HabitCategory.fitness:
        return 'Fitness';
      case HabitCategory.mindfulness:
        return 'Mindfulness';
      case HabitCategory.productivity:
        return 'Productivity';
      case HabitCategory.learning:
        return 'Learning';
      case HabitCategory.social:
        return 'Social';
      case HabitCategory.finance:
        return 'Finance';
      case HabitCategory.other:
        return 'Other';
    }
  }
}