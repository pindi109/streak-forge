import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../habits/providers/habit_provider.dart';
import '../../habits/models/habit_model.dart';
import '../../habits/screens/habit_detail_screen.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/streak_calculator.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/custom_error_widget.dart';
import 'streak_summary_card.dart';
import 'habit_card_widget.dart';

class TodayHabitsTab extends StatelessWidget {
  const TodayHabitsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AppAuthProvider>();
    final habitProvider = context.watch<HabitProvider>();

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: _buildHeader(auth.user?.displayName ?? 'User'),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: StreakSummaryCard(
                  completedCount: habitProvider.completedTodayCount,
                  totalCount: habitProvider.todayHabits.length,
                  completionRate: habitProvider.todayCompletionRate,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Today's Habits",
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      AppDateUtils.formatDateShort(DateTime.now()),
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            if (habitProvider.isLoading)
              const SliverToBoxAdapter(child: LoadingWidget())
            else if (habitProvider.error != null)
              SliverToBoxAdapter(
                child: CustomErrorWidget(
                  message: habitProvider.error!,
                  onRetry: () {
                    final uid = auth.user?.uid;
                    if (uid != null) habitProvider.initForUser(uid);
                  },
                ),
              )
            else if (habitProvider.todayHabits.isEmpty)
              const SliverToBoxAdapter(child: _EmptyHabitsState())
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final habit = habitProvider.todayHabits[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: HabitCardWidget(
                          habit: habit,
                          isCompleted: habitProvider.isCompletedToday(habit),
                          onToggle: () => habitProvider.toggleCompletion(
                              habit, DateTime.now()),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  HabitDetailScreen(habit: habit),
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: habitProvider.todayHabits.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String name) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Good morning';
    } else if (hour < 17) {
      greeting = 'Good afternoon';
    } else {
      greeting = 'Good evening';
    }
    final firstName = name.split(' ').first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$greeting, $firstName! 👋',
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Let\'s keep the streak going!',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
        ),
      ],
    );
  }
}

class _EmptyHabitsState extends StatelessWidget {
  const _EmptyHabitsState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('💡', style: TextStyle(fontSize: 36)),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No habits yet',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap the + button to create your first habit and start building your streak!',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
