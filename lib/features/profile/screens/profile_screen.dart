
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../habits/providers/habits_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer2<AuthProvider, HabitsProvider>(
        builder: (context, auth, habitsProvider, _) {
          final user = auth.user;
          final displayName = user?.displayName ?? 'Habit Builder';
          final email = user?.email ?? '';
          final photoUrl = user?.photoURL;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Profile',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      _SignOutButton(auth: auth),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: _ProfileHeader(
                  displayName: displayName,
                  email: email,
                  photoUrl: photoUrl,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _AchievementsSection(provider: habitsProvider),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _HabitSummarySection(provider: habitsProvider),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _SettingsSection(auth: auth),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
    );
  }
}

class _SignOutButton extends StatelessWidget {
  final AuthProvider auth;

  const _SignOutButton({required this.auth});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF18181B),
            title: const Text('Sign Out',
                style: TextStyle(color: Colors.white)),
            content: const Text(
              'Are you sure you want to sign out?',
              style: TextStyle(color: Color(0xFFA1A1AA)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel',
                    style: TextStyle(color: Color(0xFFA1A1AA))),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Sign Out',
                    style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
        if (confirmed == true) {
          await auth.signOut();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: const Text(
          'Sign Out',
          style: TextStyle(color: Colors.red, fontSize: 13),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String displayName;
  final String email;
  final String? photoUrl;

  const _ProfileHeader({
    required this.displayName,
    required this.email,
    this.photoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF7C3AED), Color(0xFF3B82F6)],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.2),
                image: photoUrl != null
                    ? DecorationImage(
                        image: NetworkImage(photoUrl!),
                        fit: BoxFit.cover)
                    : null,
              ),
              child: photoUrl == null
                  ? Center(
                      child: Text(
                        displayName.isNotEmpty
                            ? displayName[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '🔥 Streak Forger',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AchievementsSection extends StatelessWidget {
  final HabitsProvider provider;

  const _AchievementsSection({required this.provider});

  @override
  Widget build(BuildContext context) {
    final habits = provider.habits;
    final totalCompleted =
        habits.fold<int>(0, (sum, h) => sum + h.completedDates.length);
    final longestStreak = provider.longestOverallStreak;

    final achievements = <Map<String, dynamic>>[
      {
        'title': 'First Habit',
        'desc': 'Create your first habit',
        'icon': '🌱',
        'unlocked': habits.isNotEmpty,
      },
      {
        'title': 'Week Warrior',
        'desc': 'Maintain a 7-day streak',
        'icon': '⚔️',
        'unlocked': longestStreak >= 7,
      },
      {
        'title': 'Month Master',
        'desc': 'Maintain a 30-day streak',
        'icon': '👑',
        'unlocked': longestStreak >= 30,
      },
      {
        'title': 'Centurion',
        'desc': 'Complete 100 habits total',
        'icon': '💯',
        'unlocked': totalCompleted >= 100,
      },
      {
        'title': 'Habit Collector',
        'desc': 'Track 5+ habits at once',
        'icon': '🏆',
        'unlocked': habits.length >= 5,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Achievements',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: achievements.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final a = achievements[index];
              final unlocked = a['unlocked'] as bool;
              return Container(
                width: 100,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: unlocked
                      ? const Color(0xFF7C3AED).withOpacity(0.15)
                      : const Color(0xFF18181B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: unlocked
                        ? const Color(0xFF7C3AED).withOpacity(0.4)
                        : const Color(0xFF27272A),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      unlocked ? a['icon'] : '🔒',
                      style: const TextStyle(fontSize: 28),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      a['title'],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: unlocked
                            ? Colors.white
                            : const Color(0xFF52525B),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _HabitSummarySection extends StatelessWidget {
  final HabitsProvider provider;

  const _HabitSummarySection({required this.provider});

  @override
  Widget build(BuildContext context) {
    final habits = provider.habits;
    if (habits.isEmpty) return const SizedBox.shrink();

    final totalCompleted =
        habits.fold<int>(0, (sum, h) => sum + h.completedDates.length);
    final avgCompletion = habits.isEmpty
        ? 0.0
        : habits
                .fold<double>(0, (sum, h) => sum + h.completionRate) /
            habits.length;

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
            'Your Journey',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _JourneyRow(
            icon: Icons.checklist,
            label: 'Total habits tracked',
            value: '${habits.length}',
          ),
          _JourneyRow(
            icon: Icons.check_circle_outline,
            label: 'Total completions',
            value: '$totalCompleted',
          ),
          _JourneyRow(
            icon: Icons.trending_up,
            label: 'Average completion rate',
            value: '${(avgCompletion * 100).toStringAsFixed(1)}%',
          ),
          _JourneyRow(
            icon: Icons.local_fire_department,
            label: 'Longest streak ever',
            value: '${provider.longestOverallStreak} days',
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _JourneyRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  const _JourneyRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF7C3AED), size: 18),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                      color: Color(0xFFA1A1AA), fontSize: 14),
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(color: Color(0xFF27272A), height: 1),
      ],
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final AuthProvider auth