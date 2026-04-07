import 'package:flutter/material.dart';
import '../../habits/models/habit_model.dart';
import '../../../core/theme/app_theme.dart';

class HabitCardWidget extends StatefulWidget {
  final HabitModel habit;
  final bool isCompleted;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  const HabitCardWidget({
    super.key,
    required this.habit,
    required this.isCompleted,
    required this.onToggle,
    required this.onTap,
  });

  @override
  State<HabitCardWidget> createState() => _HabitCardWidgetState();
}

class _HabitCardWidgetState extends State<HabitCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleToggle() async {
    await _controller.forward();
    await _controller.reverse();
    widget.onToggle();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.isCompleted
                ? AppTheme.primary.withOpacity(0.08)
                : AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isCompleted
                  ? AppTheme.primary.withOpacity(0.4)
                  : AppTheme.border,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              _buildCheckButton(),
              const SizedBox(width: 14),
              _buildEmojiAvatar(),
              const SizedBox(width: 14),
              Expanded(child: _buildHabitInfo()),
              const SizedBox(width: 12),
              _buildStreakBadge(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckButton() {
    return GestureDetector(
      onTap: _handleToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.isCompleted ? AppTheme.primary : Colors.transparent,
          border: Border.all(
            color: widget.isCompleted ? AppTheme.primary : AppTheme.border,
            width: 2,
          ),
        ),
        child: widget.isCompleted
            ? const Icon(Icons.check, color: Colors.white, size: 16)
            : null,
      ),
    );
  }

  Widget _buildEmojiAvatar() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          widget.habit.emoji,
          style: const TextStyle(fontSize: 22),
        ),
      ),
    );
  }

  Widget _buildHabitInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.habit.title,
          style: TextStyle(
            color: widget.isCompleted
                ? AppTheme.textSecondary
                : AppTheme.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            decoration: widget.isCompleted
                ? TextDecoration.lineThrough
                : TextDecoration.none,
            decorationColor: AppTheme.textSecondary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (widget.habit.description.isNotEmpty) ...
          [
            const SizedBox(height: 2),
            Text(
              widget.habit.description,
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        const SizedBox(height: 4),
        _buildCategoryChip(),
      ],
    );
  }

  Widget _buildCategoryChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        widget.habit.category,
        style: const TextStyle(
          color: AppTheme.primaryLight,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildStreakBadge() {
    if (widget.habit.currentStreak == 0) return const SizedBox.shrink();
    return Column(
      children: [
        const Text('🔥', style: TextStyle(fontSize: 18)),
        Text(
          '${widget.habit.currentStreak}',
          style: const TextStyle(
            color: AppTheme.warning,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
