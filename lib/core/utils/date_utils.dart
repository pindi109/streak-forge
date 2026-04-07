import 'package:intl/intl.dart';

class AppDateUtils {
  static DateTime get today => DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      );

  static DateTime startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static String formatDate(DateTime date) =>
      DateFormat('MMM d, yyyy').format(date);

  static String formatDateShort(DateTime date) =>
      DateFormat('MMM d').format(date);

  static String formatDayOfWeek(DateTime date) =>
      DateFormat('EEE').format(date);

  static String formatTime(DateTime date) =>
      DateFormat('h:mm a').format(date);

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static bool isToday(DateTime date) => isSameDay(date, DateTime.now());

  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return isSameDay(date, yesterday);
  }

  static List<DateTime> getLast7Days() {
    final now = today;
    return List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));
  }

  static List<DateTime> getLast30Days() {
    final now = today;
    return List.generate(30, (i) => now.subtract(Duration(days: 29 - i)));
  }

  static String getRelativeDateLabel(DateTime date) {
    if (isToday(date)) return 'Today';
    if (isYesterday(date)) return 'Yesterday';
    return formatDateShort(date);
  }
}
