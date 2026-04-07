
class AppConstants {
  AppConstants._();

  // ── App Info ─────────────────────────────────────────────────────────────────
  static const String appName        = 'StreakForge';
  static const String appVersion     = '1.0.0';
  static const String appPackageName = 'com.futurebuild.streak_forge';

  // ── Routes ───────────────────────────────────────────────────────────────────
  static const String routeLogin        = '/login';
  static const String routeRegister     = '/register';
  static const String routeHome         = '/home';
  static const String routeHabits       = '/habits';
  static const String routeHabitDetail  = '/habit-detail';
  static const String routeCreateHabit  = '/create-habit';
  static const String routeStats        = '/stats';
  static const String routeProfile      = '/profile';
  static const String routeSettings     = '/settings';

  // ── Firestore Collections ────────────────────────────────────────────────────
  static const String colUsers         = 'users';
  static const String colHabits        = 'habits';
  static const String colCompletions   = 'completions';
  static const String colStreaks        = 'streaks';
  static const String colNotifications = 'notifications';

  // ── SharedPreferences Keys ───────────────────────────────────────────────────
  static const String keyOnboardingDone    = 'onboarding_done';
  static const String keyThemeMode         = 'theme_mode';
  static const String keyNotificationsOn   = 'notifications_on';
  static const String keyLastSyncTimestamp = 'last_sync_ts';
  static const String keyUserId            = 'user_id';

  // ── Firestore Document Fields ────────────────────────────────────────────────
  static const String fieldId          = 'id';
  static const String fieldUserId      = 'userId';
  static const String fieldTitle       = 'title';
  static const String fieldDescription = 'description';
  static const String fieldColor       = 'color';
  static const String fieldIcon        = 'icon';
  static const String fieldFrequency   = 'frequency';
  static const String fieldTargetDays  = 'targetDays';
  static const String fieldStreak      = 'streak';
  static const String fieldLongest     = 'longestStreak';
  static const String fieldCompleted   = 'completed';
  static const String fieldDate        = 'date';
  static const String fieldCreatedAt   = 'createdAt';
  static const String fieldUpdatedAt   = 'updatedAt';
  static const String fieldIsActive    = 'isActive';
  static const String fieldReminderOn  = 'reminderOn';
  static const String fieldReminderTime= 'reminderTime';
  static const String fieldEmail       = 'email';
  static const String fieldDisplayName = 'displayName';
  static const String fieldPhotoUrl    = 'photoUrl';
  static const String fieldFcmToken    = 'fcmToken';

  // ── Habit Frequencies ────────────────────────────────────────────────────────
  static const String freqDaily   = 'daily';
  static const String freqWeekly  = 'weekly';
  static const String freqCustom  = 'custom';

  // ── Notification ─────────────────────────────────────────────────────────────
  static const String notifChannelId   = 'streak_forge_reminders';
  static const String notifChannelName = 'Habit Reminders';
  static const String notifChannelDesc = 'Daily habit reminder notifications';

  // ── UI / Layout ───────────────────────────────────────────────────────────────
  static const double paddingXS   = 4.0;
  static const double paddingSM   = 8.0;
  static const double paddingMD   = 16.0;
  static const double paddingLG   = 24.0;
  static const double paddingXL   = 32.0;
  static const double paddingXXL  = 48.0;

  static const double radiusSM    = 8.0;
  static const double radiusMD    = 12.0;
  static const double radiusLG    = 16.0;
  static const double radiusXL    = 20.0;
  static const double radiusFull  = 999.0;

  static const double iconSizeSM  = 16.0;
  static const double iconSizeMD  = 24.0;
  static const double iconSizeLG  = 32.0;

  // ── Durations ────────────────────────────────────────────────────────────────
  static const Duration animFast    = Duration(milliseconds: 200);
  static const Duration animNormal  = Duration(milliseconds: 350);
  static const Duration animSlow    = Duration(milliseconds: 500);
  static const Duration snackDuration = Duration(seconds: 3);

  // ── Error / Validation Messages ───────────────────────────────────────────────
  static const String errRequired       = 'This field is required';
  static const String errEmailInvalid   = 'Please enter a valid email address';
  static const String errPasswordShort  = 'Password must be at least 6 characters';
  static const String errPasswordMatch  = 'Passwords do not match';
  static const String errGeneric        = 'Something went wrong. Please try again.';
  static const String errNetworkTimeout = 'Connection timed out. Check your internet.';
  static const String errUserNotFound   = 'No account found with this email.';
  static const String errWrongPassword  = 'Incorrect password. Please try again.';
  static const String errEmailInUse     = 'An account already exists with this email.';
  static const String errWeakPassword   = 'Password is too weak. Use a stronger password.';
  static const String errGoogleSignIn   = 'Google Sign-In failed. Please try again.';

  // ── Success Messages ──────────────────────────────────────────────────────────
  static const String successLogin      = 'Welcome back to StreakForge!';
  static const String successRegister   = 'Account created successfully!';
  static const String successLogout     = 'Logged out successfully.';
  static const String successHabitSaved = 'Habit saved!';
  static const String successHabitDone  = 'Habit completed! Keep the streak alive 🔥';

  // ── Habit Colours ─────────────────────────────────────────────────────────────
  static const List<String> habitColors = [
    '#7C3AED', // purple
    '#3B82F6', // blue
    '#22C55E', // green
    '#F59E0B', // amber
    '#EF4444', // red
    '#EC4899', // pink
    '#06B6D4', // cyan
    '#F97316', // orange
  ];
}