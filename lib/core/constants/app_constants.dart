class AppConstants {
  static const String appName = 'StreakForge';
  static const String appVersion = '1.0.0';

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String habitsCollection = 'habits';
  static const String completionsCollection = 'completions';

  // SharedPreferences Keys
  static const String keyOnboarded = 'onboarded';
  static const String keyUserId = 'user_id';
  static const String keyTheme = 'theme';

  // Notification Channels
  static const String notificationChannelId = 'streak_forge_reminders';
  static const String notificationChannelName = 'Habit Reminders';
  static const String notificationChannelDesc = 'Daily reminders to complete your habits';

  // Habit Categories
  static const List<String> habitCategories = [
    'Health',
    'Fitness',
    'Learning',
    'Mindfulness',
    'Productivity',
    'Social',
    'Finance',
    'Creativity',
    'Other',
  ];

  // Habit Icons
  static const List<String> habitEmojis = [
    '💪', '🧘', '📚', '💧', '🏃', '🍎', '😴', '🧠',
    '✍️', '🎯', '💡', '🌿', '🎵', '🎨', '💰', '🤝',
    '☀️', '🌙', '🏋️', '🚴', '🧹', '📝', '🫁', '❤️',
  ];

  // Frequency Types
  static const String frequencyDaily = 'daily';
  static const String frequencyWeekly = 'weekly';

  // Chart periods
  static const int chartWeekDays = 7;
  static const int chartMonthDays = 30;

  // Animation durations
  static const Duration animDurationShort = Duration(milliseconds: 200);
  static const Duration animDurationMedium = Duration(milliseconds: 400);
  static const Duration animDurationLong = Duration(milliseconds: 600);

  // Max streak display
  static const int maxStreakBadge = 365;
}
