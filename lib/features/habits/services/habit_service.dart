import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/habit_model.dart';
import '../../../core/utils/streak_calculator.dart';
import '../../../core/utils/date_utils.dart';

class HabitService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  CollectionReference get _habitsRef => _firestore.collection('habits');

  Stream<List<HabitModel>> getHabitsStream(String userId) {
    return _habitsRef
        .where('userId', isEqualTo: userId)
        .where('isArchived', isEqualTo: false)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => HabitModel.fromFirestore(doc)).toList());
  }

  Future<HabitModel> createHabit({
    required String userId,
    required String title,
    required String emoji,
    required String category,
    String description = '',
    String frequency = 'daily',
    List<int> weekDays = const [0, 1, 2, 3, 4, 5, 6],
    String? reminderTime,
  }) async {
    try {
      final id = _uuid.v4();
      final habit = HabitModel(
        id: id,
        userId: userId,
        title: title,
        description: description,
        emoji: emoji,
        category: category,
        frequency: frequency,
        weekDays: weekDays,
        reminderTime: reminderTime,
        createdAt: DateTime.now(),
      );
      await _habitsRef.doc(id).set(habit.toFirestore());
      return habit;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateHabit(HabitModel habit) async {
    try {
      await _habitsRef.doc(habit.id).update(habit.toFirestore());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteHabit(String habitId) async {
    try {
      await _habitsRef.doc(habitId).delete();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> archiveHabit(String habitId) async {
    try {
      await _habitsRef.doc(habitId).update({'isArchived': true});
    } catch (e) {
      rethrow;
    }
  }

  Future<HabitModel> toggleHabitCompletion(
      HabitModel habit, DateTime date) async {
    try {
      final targetDate = AppDateUtils.startOfDay(date);
      List<DateTime> updatedDates = List.from(habit.completedDates);

      final isCompleted = StreakCalculator.isCompletedOnDate(
          habit.completedDates, targetDate);

      if (isCompleted) {
        updatedDates
            .removeWhere((d) => AppDateUtils.isSameDay(d, targetDate));
      } else {
        updatedDates.add(targetDate);
      }

      final currentStreak =
          StreakCalculator.calculateCurrentStreak(updatedDates);
      final longestStreak = StreakCalculator.calculateLongestStreak(
          updatedDates);

      final updatedHabit = habit.copyWith(
        completedDates: updatedDates,
        currentStreak: currentStreak,
        longestStreak: longestStreak,
        totalCompletions: updatedDates.length,
      );

      await _habitsRef.doc(habit.id).update({
        'completedDates': updatedDates
            .map((d) => Timestamp.fromDate(d))
            .toList(),
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
        'totalCompletions': updatedDates.length,
      });

      return updatedHabit;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<HabitModel>> getArchivedHabits(String userId) async {
    try {
      final snapshot = await _habitsRef
          .where('userId', isEqualTo: userId)
          .where('isArchived', isEqualTo: true)
          .get();
      return snapshot.docs
          .map((doc) => HabitModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
