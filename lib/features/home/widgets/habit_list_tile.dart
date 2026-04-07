
import 'package:flutter/material.dart';
import '../../habits/models/habit_model.dart';

class HabitListTile extends StatelessWidget {
  final HabitModel habit;
  final VoidCallback onTap;
  final VoidCallback onToggle;

  const HabitListTile({
    super.key,
    required this.habit,
    required this.onTap,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = habit.isCompletedToday();
    final color = _parseColor(habit.colorHex);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isCompleted
              ? color.withOpacity(0.12)
              : const Color(0xFF18181B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCompleted ? color.withOpacity(0.4) : const Color(0xFF27272A),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  habit.emoji,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.title,
                    style: TextStyle(
                      color: isCompleted
                          ? const Color(0xFFA1A1AA)
                          : Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        size: 14,
                        color: habit.currentStreak > 0
                            ? const Color(0xFFF97316)
                            : const Color(0xFF71717A),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${habit.currentStreak} day streak',
                        style: const TextStyle(
                          color: Color(0xFFA1A1AA),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          habit.category.name,
                          style: TextStyle(
                            color: color,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: onToggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isCompleted ? color : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isCompleted ? color : const Color(0xFF27272A),
                    width: 2,
                  ),
                ),
                child: isCompleted
                    ? const Icon(Icons.check, color: Colors.white, size: 18)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return const Color(0xFF7C3AED);
    }
  }
}