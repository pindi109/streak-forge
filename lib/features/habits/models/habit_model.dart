
import 'package:cloud_firestore/cloud_firestore.dart';

enum HabitFrequency { daily, weekly }

enum HabitCategory {
  health,
  fitness,
  mindfulness,
  productivity,
  learning,
  social,
  finance,
  other,
}

class HabitModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final HabitFrequency frequency;
  final HabitCategory category;
  final String emoji;
  final int targetDays;
  final List<String> completedDates;
  final int currentStreak;
  final int longestStreak;
  final DateTime createdAt;
  final DateTime? reminderTime;
  final bool reminderEnabled;
  final String colorHex;

  const HabitModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.frequency,
    required this.category,
    required this.emoji,
    required this.targetDays,
    required this.completedDates,
    required this.currentStreak,
    required this.longestStreak,
    required this.createdAt,
    this.reminderTime,
    required this.reminderEnabled,
    required this.colorHex,
  });

  factory HabitModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return HabitModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      frequency: HabitFrequency.values.firstWhere(
        (e) => e.name == (data['frequency'] ?? 'daily'),
        orElse: () => HabitFrequency.daily,
      ),
      category: HabitCategory.values.firstWhere(
        (e) => e.name == (data['category'] ?? 'other'),
        orElse: () => HabitCategory.other,
      ),
      emoji: data['emoji'] ?? '✅',
      targetDays: data['targetDays'] ?? 30,
      completedDates: List<String>.from(data['completedDates'] ?? []),
      currentStreak: data['currentStreak'] ?? 0,
      longestStreak: data['longestStreak'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      reminderTime: (data['reminderTime'] as Timestamp?)?.toDate(),
      reminderEnabled: data['reminderEnabled'] ?? false,
      colorHex: data['colorHex'] ?? '#7C3AED',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'frequency': frequency.name,
      'category': category.name,
      'emoji': emoji,
      'targetDays': targetDays,
      'completedDates': completedDates,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'createdAt': Timestamp.fromDate(createdAt),
      'reminderTime':
          reminderTime != null ? Timestamp.fromDate(reminderTime!) : null,
      'reminderEnabled': reminderEnabled,
      'colorHex': colorHex,
    };
  }

  HabitModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    HabitFrequency? frequency,
    HabitCategory? category,
    String? emoji,
    int? targetDays,
    List<String>? completedDates,
    int? currentStreak,
    int? longestStreak,
    DateTime? createdAt,
    DateTime? reminderTime,
    bool? reminderEnabled,
    String? colorHex,
  }) {
    return HabitModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      frequency: frequency ?? this.frequency,
      category: category ?? this.category,
      emoji: emoji ?? this.emoji,
      targetDays: targetDays ?? this.targetDays,
      completedDates: completedDates ?? this.completedDates,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      createdAt: createdAt ?? this.createdAt,
      reminderTime: reminderTime ?? this.reminderTime,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      colorHex: colorHex ?? this.colorHex,
    );
  }

  bool isCompletedToday() {
    final today = _dateString(DateTime.now());
    return completedDates.contains(today);
  }

  bool isCompletedOnDate(DateTime date) {
    return completedDates.contains(_dateString(date));
  }

  double get completionRate {
    if (targetDays == 0) return 0;
    final daysSinceCreation =
        DateTime.now().difference(createdAt).inDays + 1;
    final totalDays = daysSinceCreation < targetDays ? daysSinceCreation : targetDays;
    if (totalDays == 0) return 0;
    return (completedDates.length / totalDays).clamp(0.0, 1.0);
  }

  static String _dateString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}