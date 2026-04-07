import 'package:cloud_firestore/cloud_firestore.dart';

class HabitModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String emoji;
  final String category;
  final String frequency;
  final List<int> weekDays;
  final String? reminderTime;
  final int currentStreak;
  final int longestStreak;
  final int totalCompletions;
  final bool isArchived;
  final DateTime createdAt;
  final List<DateTime> completedDates;

  const HabitModel({
    required this.id,
    required this.userId,
    required this.title,
    this.description = '',
    required this.emoji,
    required this.category,
    this.frequency = 'daily',
    this.weekDays = const [0, 1, 2, 3, 4, 5, 6],
    this.reminderTime,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalCompletions = 0,
    this.isArchived = false,
    required this.createdAt,
    this.completedDates = const [],
  });

  factory HabitModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return HabitModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      emoji: data['emoji'] ?? '💪',
      category: data['category'] ?? 'Other',
      frequency: data['frequency'] ?? 'daily',
      weekDays: List<int>.from(data['weekDays'] ?? [0, 1, 2, 3, 4, 5, 6]),
      reminderTime: data['reminderTime'],
      currentStreak: data['currentStreak'] ?? 0,
      longestStreak: data['longestStreak'] ?? 0,
      totalCompletions: data['totalCompletions'] ?? 0,
      isArchived: data['isArchived'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completedDates: (data['completedDates'] as List<dynamic>? ?? [])
          .map((e) => (e as Timestamp).toDate())
          .toList(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'emoji': emoji,
      'category': category,
      'frequency': frequency,
      'weekDays': weekDays,
      'reminderTime': reminderTime,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'totalCompletions': totalCompletions,
      'isArchived': isArchived,
      'createdAt': Timestamp.fromDate(createdAt),
      'completedDates':
          completedDates.map((d) => Timestamp.fromDate(d)).toList(),
    };
  }

  HabitModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? emoji,
    String? category,
    String? frequency,
    List<int>? weekDays,
    String? reminderTime,
    int? currentStreak,
    int? longestStreak,
    int? totalCompletions,
    bool? isArchived,
    DateTime? createdAt,
    List<DateTime>? completedDates,
  }) {
    return HabitModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      emoji: emoji ?? this.emoji,
      category: category ?? this.category,
      frequency: frequency ?? this.frequency,
      weekDays: weekDays ?? this.weekDays,
      reminderTime: reminderTime ?? this.reminderTime,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalCompletions: totalCompletions ?? this.totalCompletions,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      completedDates: completedDates ?? this.completedDates,
    );
  }
}
