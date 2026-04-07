
import 'package:flutter/material.dart';
import '../../habits/screens/add_habit_screen.dart';

class EmptyHabitsWidget extends StatelessWidget {
  const EmptyHabitsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7C3AED), Color(0xFF3B82F6)],
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Icon(
              Icons.rocket_launch_outlined,
              color: Colors.white,
              size: 44,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Start Building Habits',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Track your daily habits, build\nconsistency, and forge streaks.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFA1A1AA),
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddHabitScreen()),
            ),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7C3AED), Color(0xFF3B82F6)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                'Create First Habit',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}