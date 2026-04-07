
import 'package:flutter/material.dart';
import '../../habits/providers/habits_provider.dart';

class StreakSummaryCard extends StatelessWidget {
  final HabitsProvider provider;

  const StreakSummaryCard({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatItem(
            icon: Icons.local_fire_department,
            iconColor: const Color(0xFFF97316),
            label: 'Active Streaks',
            value: '${provider.habits.where((h) => h.currentStreak > 0).length}',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatItem(
            icon: Icons.emoji_events,
            iconColor: const Color(0xFFFBBF24),
            label: 'Longest Streak',
            value: '${provider.longestOverallStreak}d',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatItem(
            icon: Icons.check_circle,
            iconColor: const Color(0xFF22C55E),
            label: 'Total Habits',
            value: '${provider.habits.length}',
          ),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
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
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFA1A1AA),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}