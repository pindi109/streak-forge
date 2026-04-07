
import 'package:flutter/material.dart';
import '../models/habit_model.dart';

class HabitStatsRow extends StatelessWidget {
  final HabitModel habit;

  const HabitStatsRow({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {
    final completionRate = habit.completionRate;
    final daysSinceStart =
        DateTime.now().difference(habit.createdAt).inDays + 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Statistics',
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
              child: _StatCard(
                label: 'Completion Rate',
                value: '${(completionRate * 100).toStringAsFixed(1)}%',
                icon: Icons.pie_chart_outline,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: 'Days Active',
                value: '$daysSinceStart',
                icon: Icons.calendar_today_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildProgressBar(completionRate),
      ],
    );
  }

  Widget _buildProgressBar(double rate) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF18181B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF27272A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Overall Progress',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              Text(
                '${habit.completedDates.length}/${habit.targetDays} days',
                style: const TextStyle(
                    color: Color(0xFFA1A1AA), fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: rate,
              backgroundColor: const Color(0xFF27272A),
              valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF7C3AED)),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF18181B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF27272A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF7C3AED), size: 20),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
                color: Color(0xFFA1A1AA), fontSize: 12),
          ),
        ],
      ),
    );
  }
}