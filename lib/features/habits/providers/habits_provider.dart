
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/habit_model.dart';
import '../repositories/habit_repository.dart';

class HabitsProvider extends ChangeNotifier {
  final HabitRepository _repository = HabitRepository();

  List<HabitModel> _habits = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription<List<HabitModel>>? _subscription;
  String? _userId;

  List<HabitModel> get habits => _habits;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<HabitModel> get todaysHabits => _habits
      .where((h) => h.frequency == HabitFrequency.daily)
      .toList();

  List<HabitModel> get completedToday =>
      _habits.where((h) => h.isCompletedToday()).toList();

  List<HabitModel> get pendingToday => todaysHabits
      .where((h) => !h.isCompletedToday())
      .toList();

  double get todayProgress {
    if (todaysHabits.isEmpty) return 0;
    return completedToday.length / todaysHabits.length;
  }

  int get totalStreaks =>
      _habits.fold(0, (sum, h) => sum + h.currentStreak);

  int get longestOverallStreak =>
      _habits.isEmpty
          ? 0
          : _habits.map((h) => h.longestStreak).reduce((a, b) => a > b ? a : b);

  void initForUser(String userId) {
    if (_userId == userId) return;
    _userId = userId;
    _subscription?.cancel();
    _isLoading = true;
    notifyListeners();

    _subscription = _repository.watchHabits(userId).listen(
      (habits) {
        _habits = habits;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<bool> createHabit(HabitModel habit) async {
    try {
      final id = await _repository.createHabit(_userId!, habit);
      return id != null;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateHabit(HabitModel habit) async {
    try {
      return await _repository.updateHabit(_userId!, habit);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteHabit(String habitId) async {
    try {
      return await _repository.deleteHabit(_userId!, habitId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleCompletion(HabitModel habit, {DateTime? date}) async {
    try {
      final targetDate = date ?? DateTime.now();
      return await _repository.toggleHabitCompletion(
          _userId!, habit, targetDate);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
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