
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../providers/habits_provider.dart';
import '../models/habit_model.dart';
import '../widgets/color_picker_row.dart';
import '../widgets/emoji_picker_modal.dart';
import '../widgets/category_chip.dart';

class AddHabitScreen extends StatefulWidget {
  final HabitModel? existingHabit;

  const AddHabitScreen({super.key, this.existingHabit});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  HabitCategory _selectedCategory = HabitCategory.health;
  HabitFrequency _selectedFrequency = HabitFrequency.daily;
  String _selectedEmoji = '✅';
  String _selectedColor = '#7C3AED';
  int _targetDays = 30;
  bool _reminderEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 8, minute: 0);
  bool _isLoading = false;

  bool get isEditing => widget.existingHabit != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final h = widget.existingHabit!;
      _titleController.text = h.title;
      _descriptionController.text = h.description;
      _selectedCategory = h.category;
      _selectedFrequency = h.frequency;
      _selectedEmoji = h.emoji;
      _selectedColor = h.colorHex;
      _targetDays = h.targetDays;
      _reminderEnabled = h.reminderEnabled;
      if (h.reminderTime != null) {
        _reminderTime = TimeOfDay.fromDateTime(h.reminderTime!);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final userId = context.read<AuthProvider>().user!.uid;
      DateTime? reminderDateTime;
      if (_reminderEnabled) {
        final now = DateTime.now();
        reminderDateTime = DateTime(
            now.year, now.month, now.day, _reminderTime.hour, _reminderTime.minute);
      }

      final habit = HabitModel(
        id: isEditing ? widget.existingHabit!.id : '',
        userId: userId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        frequency: _selectedFrequency,
        category: _selectedCategory,
        emoji: _selectedEmoji,
        targetDays: _targetDays,
        completedDates:
            isEditing ? widget.existingHabit!.completedDates : [],
        currentStreak: isEditing ? widget.existingHabit!.currentStreak : 0,
        longestStreak: isEditing ? widget.existingHabit!.longestStreak : 0,
        createdAt:
            isEditing ? widget.existingHabit!.createdAt : DateTime.now(),
        reminderTime: reminderDateTime,
        reminderEnabled: _reminderEnabled,
        colorHex: _selectedColor,
      );

      bool success;
      if (isEditing) {
        success = await context.read<HabitsProvider>().updateHabit(habit);
      } else {
        success = await context.read<HabitsProvider>().createHabit(habit);
      }

      if (mounted) {
        if (success) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isEditing
                  ? 'Habit updated successfully!'
                  : 'Habit created successfully!'),
              backgroundColor: const Color(0xFF7C3AED),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Something went wrong. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditing ? 'Edit Habit' : 'New Habit',
          style: const TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      color: Color(0xFF7C3AED), strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _save,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7C3AED), Color(0xFF3B82F6)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isEditing ? 'Update' : 'Save',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildEmojiAndColorSection(),
            const SizedBox(height: 24),
            _buildSection(
              title: 'Habit Name',
              child: TextFormField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('e.g. Morning Meditation'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Name is required' : null,
              ),
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: 'Description (optional)',
              child: TextFormField(
                controller: _descriptionController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('e.g. 10 minutes every morning'),
                maxLines: 3,
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'Category',
              child: _buildCategoryGrid(),
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'Frequency',
              child: _buildFrequencyToggle(),
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'Color',
              child: ColorPickerRow(
                selectedColor: _selectedColor,
                onColorSelected: (c) => setState(() => _selectedColor = c),
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'Target Days',
              child: _buildTargetDaysSlider(),
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'Reminder',
              child: _buildReminderToggle(),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildEmojiAndColorSection() {
    final color = _parseColor(_selectedColor);
    return Center(
      child: GestureDetector(
        onTap: () async {
          final emoji = await showModalBottomSheet<String>(
            context: context,
            backgroundColor: Colors.transparent,
            builder: (_) => const EmojiPickerModal(),
          );
          if (emoji != null) setState(() => _selectedEmoji = emoji);
        },
        child: Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: color.withOpacity(0.5), width: 2),
          ),
          child: Stack(
            children: [
              Center(
                child: Text(
                  _selectedEmoji,
                  style: const TextStyle(fontSize: 40),
                ),
              ),
              Positioned(
                bottom: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.edit, color: Colors.white, size: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryGrid() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: HabitCategory.values.map((cat) {
        return CategoryChip(
          category: cat,
          isSelected: _selectedCategory == cat,
          onTap: () => setState(() => _selectedCategory = cat),
        );
      }).toList(),
    );
  }

  Widget _buildFrequencyToggle() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF18181B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF27272A)),
      ),
      child: Row(
        children: HabitFrequency.values.map((freq) {
          final isSelected = _selectedFrequency == freq;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedFrequency = freq),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [Color(0xFF7C3AED), Color(0xFF3B82F6)])
                      : null,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  freq.name[0].toUpperCase() + freq.name.substring(1),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFFA1A1AA),
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTargetDaysSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$_targetDays days',
          style: const TextStyle(
            color: Color(0xFF7C3AED),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            thumbColor: const Color(0xFF7C3AED),
            activeTrackColor: const Color(0xFF7C3AED),
            inactiveTrackColor: const Color(0xFF27272A),
            overlayColor: const Color(0xFF7C3AED).withOpacity(0.2),
          ),
          child: Slider(
            value: _targetDays.toDouble(),
            min: 7,
            max: 365,
            divisions: 50,
            onChanged: (v) => setState(() => _targetDays = v.toInt()),
          ),
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('7 days',
                style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 12)),
            Text('365 days',
                style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 12)),
          ],
        ),
      ],
    );
  }

  Widget _buildReminderToggle() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Daily Reminder',
              style: TextStyle(color: Colors.white, fontSize: 15),
            ),
            Switch(
              value: _reminderEnabled,
              onChanged: (v) => setState(() => _reminderEnabled = v),
              activeColor: const Color(0xFF7C3AED),
            ),
          ],
        ),
        if (_reminderEnabled) ...[
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: _reminderTime,
                builder: (context, child) {
                  return Theme(
                    data: ThemeData.dark().copyWith(
                      colorScheme: const ColorScheme.dark(
                        primary: Color(0xFF7C3AED),
                        surface: Color(0xFF18181B),
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (time != null) setState(() => _reminderTime = time);
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF18181B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF27272A)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.access_time,
                          color: Color(0xFF7C3AED), size: 20),
                      SizedBox(width: 8),
                      Text('Reminder Time',
                          style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  Text(
                    _reminderTime.format(context),
                    style: const TextStyle(
                      color: Color(0xFF7C3AED),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFFA1A1AA),
            fontSize: 13,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF52525B)),
      filled: true,
      fillColor: const Color(0xFF18181B),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF27272A)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF27272A)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF7C3AED)),
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