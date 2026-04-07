import 'package:flutter/foundation.dart';
import '../services/notification_service.dart';

class ReminderProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService.instance;
  final Map<String, String> _habitReminders = {};

  Map<String, String> get habitReminders => _habitReminders;

  Future<void> scheduleReminder({
    required String habitId,
    required String habitTitle,
    required String habitEmoji,
    required int hour,
    required int minute,
  }) async {
    try {
      final notifId = habitId.hashCode.abs();
      await _notificationService.scheduleHabitReminder(
        id: notifId,
        habitTitle: habitTitle,
        habitEmoji: habitEmoji,
        hour: hour,
        minute: minute,
      );
      final timeStr =
          '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
      _habitReminders[habitId] = timeStr;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> cancelReminder(String habitId) async {
    try {
      final notifId = habitId.hashCode.abs();
      await _notificationService.cancelNotification(notifId);
      _habitReminders.remove(habitId);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  String? getReminderTime(String habitId) => _habitReminders[habitId];

  bool hasReminder(String habitId) => _habitReminders.containsKey(habitId);
}
