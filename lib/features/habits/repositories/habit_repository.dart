
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/habit_model.dart';

class HabitRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _habitsCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('habits');
  }

  Stream<List<HabitModel>> watchHabits(String userId) {
    return _habitsCollection(userId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map(HabitModel.fromFirestore).toList());
  }

  Future<HabitModel?> getHabit(String userId, String habitId) async {
    try {
      final doc = await _habitsCollection(userId).doc(habitId).get();
      if (doc.exists) return HabitModel.fromFirestore(doc);
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<String?> createHabit(String userId, HabitModel habit) async {
    try {
      final ref = await _habitsCollection(userId).add(habit.toFirestore());
      return ref.id;
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateHabit(String userId, HabitModel habit) async {
    try {
      await _habitsCollection(userId).doc(habit.id).update(habit.toFirestore());
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteHabit(String userId, String habitId) async {
    try {
      await _habitsCollection(userId).doc(habitId).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> toggleHabitCompletion(
      String userId, HabitModel habit, DateTime date) async {
    try {
      final dateStr = _dateString(date);
      List<String> completedDates = List.from(habit.completedDates);
      bool wasCompleted = completedDates.contains(dateStr);

      if (wasCompleted) {
        completedDates.remove(dateStr);
      } else {
        completedDates.add(dateStr);
      }

      final newStreak = _calculateStreak(completedDates);
      final newLongest =
          newStreak > habit.longestStreak ? newStreak : habit.longestStreak;

      await _habitsCollection(userId).doc(habit.id).update({
        'completedDates': completedDates,
        'currentStreak': newStreak,
        'longestStreak': newLongest,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  int _calculateStreak(List<String> completedDates) {
    if (completedDates.isEmpty) return 0;

    final sorted = List<String>.from(completedDates)..sort();
    int streak = 0;
    DateTime current = DateTime.now();

    for (int i = 0; i < 365; i++) {
      final dateStr = _dateString(current.subtract(Duration(days: i)));
      if (sorted.contains(dateStr)) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  String _dateString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}