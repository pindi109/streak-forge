import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habit_model.dart';
import '../providers/habit_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/loading_widget.dart';

class EditHabitScreen extends StatefulWidget {
  final HabitModel habit;
  const EditHabitScreen({super.key, required this.habit});

  @override
  State<EditHabitScreen> createState() => _EditHabitScreenState();
}

class _EditHabitScreenState extends State<EditHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late String _selectedEmoji;
  late String _selectedCategory;
  late List<int> _selectedDays;
  TimeOfDay? _reminderTime;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.habit.title);
    _descController =
        TextEditingController(text: widget.habit.description);
    _selectedEmoji = widget.habit.emoji;
    _selectedCategory = widget.habit.category;
    _selectedDays = List.from(widget.habit.weekDays);
    if (widget.habit.reminderTime != null) {
      final parts = widget.habit.reminderTime!.split(':');
      if (parts.length == 2) {
        _reminderTime = TimeOfDay(
            hour: int.tryParse(parts[0]) ?? 9,
            minute: int.tryParse(parts[1]) ?? 0);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      String? reminderTimeStr;
      if (_reminderTime != null) {
        reminderTimeStr =
            '${_reminderTime!.hour.toString().padLeft(2, '0')}:${_reminderTime!.minute.toString().padLeft(2, '0')}';
      }
      final updatedHabit = widget.habit.copyWith(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        emoji: _selectedEmoji,
        category: _selectedCategory,
        weekDays: _selectedDays,
        reminderTime: reminderTimeStr,
      );
      final success =
          await context.read<HabitProvider>().updateHabit(updatedHabit);
      if (mounted) {
        if (success) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Habit updated!'),
                backgroundColor: AppTheme.success),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Failed to update habit'),
                backgroundColor: AppTheme.error),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime ?? TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppTheme.primary,
            surface: AppTheme.surface,
            onSurface: AppTheme.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _reminderTime = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Habit'),
        leading: IconButton(
          icon: const Icon(Icons.close, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppTheme.primary))
                : TextButton(
                    onPressed: _handleUpdate,
                    child: const Text('Save',
                        style: TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w600)),
                  ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                _buildEmojiPicker(),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _titleController,
                  textCapitalization: TextCapitalization.sentences,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(labelText: 'Habit name'),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty)
                      return 'Name is required';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descController,
                  textCapitalization: TextCapitalization.sentences,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  maxLines: 2,
                  decoration: const InputDecoration(
                      labelText: 'Description (optional)'),
                ),
                const SizedBox(height: 24),
                _buildCategoryPicker(),
                const SizedBox(height: 24),
                _buildDayPicker(),
                const SizedBox(height: 24),
                _buildReminderPicker(),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: _isLoading
                      ? const LoadingWidget()
                      : Container(
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ElevatedButton(
                            onPressed: _handleUpdate,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Save Changes',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white)),
                          ),
                        ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmojiPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Icon',
            style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        SizedBox(
          height: 50,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: AppConstants.habitEmojis.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final emoji = AppConstants.habitEmojis[index];
              final isSelected = emoji == _selectedEmoji;
              return GestureDetector(
                onTap: () => setState(() => _selectedEmoji = emoji),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primary.withOpacity(0.2)
                        : AppTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppTheme.primary : AppTheme.border,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Center(
                      child: Text(emoji,
                          style: const TextStyle(fontSize: 22))),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Category',
            style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AppConstants.habitCategories.map((cat) {
            final isSelected = cat == _selectedCategory;
            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primary.withOpacity(0.2)
                      : AppTheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color:
                          isSelected ? AppTheme.primary : AppTheme.border),
                ),
                child: Text(cat,
                    style: TextStyle(
                      color: isSelected
                          ? AppTheme.primaryLight
                          : AppTheme.textSecondary,
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    )),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDayPicker() {
    const days = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Repeat',
            style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (index) {
            final isSelected = _selectedDays.contains(index);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    if (_selectedDays.length > 1)
                      _selectedDays.remove(index);
                  } else {
                    _selectedDays.add(index);
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color:
                      isSelected ? AppTheme.primary : AppTheme.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: isSelected
                          ? AppTheme.primary
                          : AppTheme.border),
                ),
                child: Center(
                  child: Text(days[index],
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : AppTheme.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      )),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildReminderPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Reminder',
            style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _pickReminderTime,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _reminderTime != null
                    ? AppTheme.primary
                    : AppTheme.border,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.notifications_outlined,
                    color: _reminderTime != null
                        ? AppTheme.primary
                        : AppTheme.textSecondary,
                    size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _reminderTime != null
                        ? 'Reminder at ${_reminderTime!.format(context)}'
                        : 'Set a daily reminder (optional)',
                    style: TextStyle(
                        color: _reminderTime != null
                            ? AppTheme.textPrimary
                            : AppTheme.textSecondary,
                        fontSize: 14),
                  ),
                ),
                if (_reminderTime != null)
                  GestureDetector(
                    onTap: () => setState(() => _reminderTime = null),
                    child: const Icon(Icons.close,
                        color: AppTheme.textSecondary, size: 18),
                  )
                else
                  const Icon(Icons.chevron_right,
                      color: AppTheme.textSecondary, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
