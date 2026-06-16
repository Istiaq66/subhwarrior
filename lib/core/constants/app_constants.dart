/// App-wide domain constants. No magic literals scattered across the code —
/// every challenge rule number lives here (IMPROVEMENT_PLAN B2).
class AppConstants {
  AppConstants._();

  /// Hour (24h) after which the daily logging window is closed.
  /// 08:00 is already closed — the rule is "logged before 8 AM".
  static const int logCutoffHour = 8;

  /// Total length of the challenge in days (28-day morning routine).
  static const int challengeDays = 28;

  /// Number of qualifying weekdays needed to "win" the challenge
  /// (4 weeks × 4 qualifying weekdays).
  static const int qualifyingDaysGoal = 16;

  /// Minimum minutes of deep work for a day to qualify.
  static const int minDeepWorkMinutes = 60;

  /// Number of weeks the challenge spans.
  static const int challengeWeeks = 4;

  /// Default lead time (minutes) for the Fajr reminder.
  static const int defaultFajrReminderMinutes = 15;

  // --- Input limits (IMPROVEMENT_PLAN D5) ---

  /// Username length bounds (inclusive). Charset enforced separately.
  static const int usernameMinLength = 3;
  static const int usernameMaxLength = 20;

  /// Allowed username characters: letters, digits, underscore, single spaces.
  static final RegExp usernamePattern = RegExp(r'^[A-Za-z0-9_ ]+$');

  /// Max length of a day's free-text work description.
  static const int workDescriptionMaxLength = 280;

  /// Max length of a day's free-text reflection.
  static const int reflectionMaxLength = 500;
}
