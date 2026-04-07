import 'date_utils.dart';

class StreakCalculator {
  static int calculateCurrentStreak(List<DateTime> completedDates) {
    if (completedDates.isEmpty) return 0;

    final sortedDates = completedDates
        .map((d) => AppDateUtils.startOfDay(d))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    final today = AppDateUtils.today;
    final yesterday = today.subtract(const Duration(days: 1));

    if (!AppDateUtils.isSameDay(sortedDates.first, today) &&
        !AppDateUtils.isSameDay(sortedDates.first, yesterday)) {
      return 0;
    }

    int streak = 1;
    for (int i = 1; i < sortedDates.length; i++) {
      final diff = sortedDates[i - 1].difference(sortedDates[i]).inDays;
      if (diff == 1) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  static int calculateLongestStreak(List<DateTime> completedDates) {
    if (completedDates.isEmpty) return 0;

    final sortedDates = completedDates
        .map((d) => AppDateUtils.startOfDay(d))
        .toSet()
        .toList()
      ..sort();

    int longest = 1;
    int current = 1;

    for (int i = 1; i < sortedDates.length; i++) {
      final diff = sortedDates[i].difference(sortedDates[i - 1]).inDays;
      if (diff == 1) {
        current++;
        if (current > longest) longest = current;
      } else {
        current = 1;
      }
    }
    return longest;
  }

  static double calculateCompletionRate(
      List<DateTime> completedDates, int totalDays) {
    if (totalDays == 0) return 0.0;
    final uniqueDays = completedDates
        .map((d) => AppDateUtils.startOfDay(d))
        .toSet()
        .length;
    return (uniqueDays / totalDays).clamp(0.0, 1.0);
  }

  static bool isCompletedOnDate(
      List<DateTime> completedDates, DateTime date) {
    final targetDay = AppDateUtils.startOfDay(date);
    return completedDates
        .any((d) => AppDateUtils.isSameDay(d, targetDay));
  }
}
