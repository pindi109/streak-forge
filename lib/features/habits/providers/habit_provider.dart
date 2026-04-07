import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/habit_model.dart';
import '../services/habit_service.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/streak_calculator.dart';

class HabitProvider extends ChangeNotifier {
  final HabitService _habitService = HabitService();

  List<HabitModel> _habits = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription<List<HabitModel>>? _subscription;
  String? _currentUserId;

  List<HabitModel> get habits => _habits;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<HabitModel> get todayHabits {
    final today = DateTime.now();
    final weekday = today.weekday % 7;
    return _habits
        .where((h) => !h.isArchived && h.weekDays.contains(weekday))
        .toList();
  }

  int get completedTodayCount {
    return todayHabits
        .where((h) =>
            StreakCalculator.isCompletedOnDate(h.completedDates, AppDateUtils.today))
        .length;
  }

  double get todayCompletionRate {
    if (todayHabits.isEmpty) return 0.0;
    return completedTodayCount / todayHabits.length;
  }

  int get totalCurrentStreaks =>
      _habits.fold(0, (sum, h) => sum + h.currentStreak);

  int get totalHabits => _habits.length;

  void initForUser(String userId) {
    if (_currentUserId == userId) return;
    _currentUserId = userId;
    _subscription?.cancel();
    _isLoading = true;
    notifyListeners();
    _subscription =
        _habitService.getHabitsStream(userId).listen((habits) {
      _habits = habits;
      _isLoading = false;
      _error = null;
      notifyListeners();
    }, onError: (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<bool> createHabit({
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
      await _habitService.createHabit(
        userId: userId,
        title: title,
        emoji: emoji,
        category: category,
        description: description,
        frequency: frequency,
        weekDays: weekDays,
        reminderTime: reminderTime,
      );
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateHabit(HabitModel habit) async {
    try {
      await _habitService.updateHabit(habit);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteHabit(String habitId) async {
    try {
      await _habitService.deleteHabit(habitId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleCompletion(HabitModel habit, DateTime date) async {
    try {
      final updated =
          await _habitService.toggleHabitCompletion(habit, date);
      final idx = _habits.indexWhere((h) => h.id == habit.id);
      if (idx != -1) {
        _habits[idx] = updated;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  bool isCompletedToday(HabitModel habit) {
    return StreakCalculator.isCompletedOnDate(
        habit.completedDates, AppDateUtils.today);
  }

  HabitModel? getHabitById(String id) {
    try {
      return _habits.firstWhere((h) => h.id == id);
    } catch (_) {
      return null;
    }
  }

  Map<DateTime, int> getCompletionMapLast30Days() {
    final days = AppDateUtils.getLast30Days();
    final Map<DateTime, int> result = {};
    for (final day in days) {
      int count = 0;
      for (final habit in _habits) {
        if (StreakCalculator.isCompletedOnDate(habit.completedDates, day)) {
          count++;
        }
      }
      result[day] = count;
    }
    return result;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
