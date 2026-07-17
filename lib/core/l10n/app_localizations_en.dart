// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Subh Warrior Challenge';

  @override
  String get splashTitle => 'Subh Warrior';

  @override
  String get homeAppBarTitle => 'Subh Warrior';

  @override
  String get homeChallengeStartedSnack =>
      'Challenge started — log your first day!';

  @override
  String get homeNavHome => 'Home';

  @override
  String get homeNavProgress => 'Progress';

  @override
  String get homeNavLeaderboard => 'Leaderboard';

  @override
  String get homeGreetingMorning => 'Good Morning';

  @override
  String get homeGreetingAfternoon => 'Good Afternoon';

  @override
  String get homeGreetingEvening => 'Good Evening';

  @override
  String get homeGreetingFallbackName => 'Warrior';

  @override
  String get inactiveChallengeTitle => 'Ready to become a Subh Warrior?';

  @override
  String inactiveChallengeBody(int days) {
    return 'Start your $days-day challenge to build a powerful morning routine with Fajr prayer and productive work.';
  }

  @override
  String get inactiveChallengeStartButton => 'Start Challenge';

  @override
  String get todayStatusTitle => 'Today\'s Status';

  @override
  String get todayStatusChipQualifying => 'Qualifying ✓';

  @override
  String get todayStatusChipLogged => 'Logged';

  @override
  String get todayStatusChipPending => 'Pending';

  @override
  String get todayStatusChipTimeUp => 'Time\'s Up';

  @override
  String get todayStatusFajrPrayer => 'Fajr Prayer';

  @override
  String get todayStatusFajrOnTime => 'On Time';

  @override
  String get todayStatusFajrMissed => 'Missed';

  @override
  String get todayStatusWorkTime => 'Work Time';

  @override
  String todayStatusMinutesWorked(int minutes) {
    return '$minutes minutes';
  }

  @override
  String get todayStatusWorkLabel => 'Work';

  @override
  String get todayStatusLogTodayButton => 'Log Today';

  @override
  String todayStatusWindowClosed(String cutoffTime) {
    return 'Logging window closed (after $cutoffTime)';
  }

  @override
  String get weeklyProgressTitle => 'Weekly Progress';

  @override
  String weeklyProgressWeekLabel(int week) {
    return 'Week $week';
  }

  @override
  String weeklyProgressRatio(int progress, int target) {
    return '$progress/$target';
  }

  @override
  String get quickStatsDaysLeft => 'Days Left';

  @override
  String get quickStatsGoalProgress => 'Goal Progress';

  @override
  String quickStatsPercent(int percent) {
    return '$percent%';
  }

  @override
  String quickStatsGoalRatio(int count, int goal) {
    return '$count/$goal';
  }

  @override
  String get quote1 =>
      '\"O Allah, bless my Ummah in its early mornings.\" - Prophet Muhammad ﷺ (Abu Dawud, Tirmidhi)';

  @override
  String get quote2 =>
      '\"The two Rak\'ah before Fajr are better than this world and all that it contains.\" - Prophet Muhammad ﷺ (Muslim)';

  @override
  String get quote3 =>
      '\"Whoever prays the dawn prayer in congregation, it is as if he prayed the whole night.\" - Prophet Muhammad ﷺ (Muslim)';

  @override
  String get quote4 =>
      '\"And [recite] the Qur\'an at dawn. Indeed, the recitation of dawn is ever witnessed.\" - Qur\'an 17:78';

  @override
  String get quote5 =>
      '\"Indeed, the night prayer is most effective for the heart and most upright in speech.\" - Qur\'an 73:6';

  @override
  String get quote6 =>
      '\"Take advantage of five before five: your youth before your old age, your health before your sickness, your wealth before your poverty, your free time before your busyness, and your life before your death.\" - Prophet Muhammad ﷺ (Al-Hakim)';

  @override
  String get quote7 =>
      '\"The most beloved deeds to Allah are those done consistently, even if small.\" - Prophet Muhammad ﷺ (Bukhari & Muslim)';

  @override
  String get quote8 =>
      '\"And when the prayer has ended, disperse in the land and seek the bounty of Allah.\" - Qur\'an 62:10';

  @override
  String get quote9 =>
      '\"There are two blessings which many people lose: good health and free time.\" - Prophet Muhammad ﷺ (Bukhari)';

  @override
  String get quote10 =>
      '\"Whoever rises in the morning safe in his home, healthy in body, with food for the day, it is as if the whole world were given to him.\" - Prophet Muhammad ﷺ (Tirmidhi)';

  @override
  String get prayerCardErrorMessage => 'Unable to load prayer times';

  @override
  String get prayerCardTitle => 'Fajr Prayer';

  @override
  String get prayerCardNowBadge => 'NOW';

  @override
  String get prayerCardToday => 'Today';

  @override
  String get prayerCardTomorrow => 'Tomorrow';

  @override
  String get prayerCardNextFajrIn => 'Next Fajr In';

  @override
  String get prayerCardSunrise => 'Sunrise';

  @override
  String get prayerCardDhuhr => 'Dhuhr';

  @override
  String get prayerCardAsr => 'Asr';

  @override
  String get prayerCardMaghrib => 'Maghrib';

  @override
  String get prayerCardIsha => 'Isha';

  @override
  String get streakCardDayStreak => 'Day Streak';

  @override
  String get streakCardDaysStreak => 'Days Streak';

  @override
  String get streakCardQualifyingDays => 'Qualifying Days';

  @override
  String get streakCardGoalDenominator => '/16';

  @override
  String get streakCardMsgLegendary => 'LEGENDARY!';

  @override
  String get streakCardMsgUnstoppable => 'UNSTOPPABLE!';

  @override
  String get streakCardMsgOnFire => 'ON FIRE!';

  @override
  String get streakCardMsgKeepGoing => 'KEEP GOING!';

  @override
  String get errorViewDefaultMessage => 'Something went wrong';

  @override
  String get errorViewRetryButton => 'Retry';

  @override
  String get commonOr => 'OR';

  @override
  String get onboardingWelcomeTitle => 'Welcome to\nSubh Warrior';

  @override
  String get onboardingWelcomeSubtitle =>
      'Transform your mornings with the power of Fajr prayer and focused productivity';

  @override
  String get onboardingFeatureFajrTracking => 'Fajr Prayer Tracking';

  @override
  String get onboardingFeatureProductiveWork => '60+ Min Productive Work';

  @override
  String get onboardingFeatureChallengeDuration => '28-Day Challenge';

  @override
  String get onboardingFeatureAchieveDays => 'Achieve 16+ Days';

  @override
  String get onboardingRulesTitle => 'Challenge Rules';

  @override
  String get onboardingRuleWakeUpTitle => 'Wake Up';

  @override
  String get onboardingRuleWakeUpDesc =>
      'Rise at or before Fajr time and stay awake';

  @override
  String get onboardingRulePrayTitle => 'Pray';

  @override
  String get onboardingRulePrayDesc =>
      'Perform Fajr prayer within the time window';

  @override
  String get onboardingRuleWorkTitle => 'Work';

  @override
  String get onboardingRuleWorkDesc =>
      'Complete 60+ minutes of productive work';

  @override
  String get onboardingRuleLogTitle => 'Log';

  @override
  String onboardingRuleLogDesc(String cutoffTime) {
    return 'Submit your day before $cutoffTime (weekdays only)';
  }

  @override
  String get onboardingRulesGoal => 'Complete 16+ qualifying days over 4 weeks';

  @override
  String get onboardingLocationTitle => 'Set Your Location';

  @override
  String get onboardingLocationSubtitle =>
      'We need this to calculate accurate prayer times';

  @override
  String get onboardingLocationFieldLabel => 'City/Location';

  @override
  String get onboardingLocationFieldHint => 'e.g., New York, USA';

  @override
  String get onboardingGettingLocation => 'Getting Location...';

  @override
  String get onboardingUseCurrentLocation => 'Use Current Location';

  @override
  String get onboardingReadyTitle => 'You\'re All Set!';

  @override
  String onboardingWelcomeUser(String name) {
    return 'Welcome, $name!';
  }

  @override
  String get onboardingStartJourneyButton => 'Start Your Journey';

  @override
  String get onboardingBackButton => 'Back';

  @override
  String get onboardingNextButton => 'Next';

  @override
  String get onboardingSetLocationPrompt => 'Please set your location';

  @override
  String get onboardingLocationNotFound =>
      'Could not find that location. Please check spelling.';

  @override
  String onboardingErrorFindingLocation(String error) {
    return 'Error finding location: $error';
  }

  @override
  String get onboardingCoordinatesNotFound =>
      'Unable to find coordinates for that location.';

  @override
  String get onboardingLocationServicesDisabled =>
      'Location services are disabled. Please enable them in settings.';

  @override
  String get onboardingLocationPermissionDenied =>
      'Location permissions are denied';

  @override
  String get onboardingLocationPermissionDeniedForever =>
      'Location permissions are permanently denied. Please enable them in app settings.';

  @override
  String get onboardingSettingsAction => 'Settings';

  @override
  String get onboardingUnknownLocality => 'Unknown';

  @override
  String onboardingLocationSetCoords(String latitude, String longitude) {
    return 'Location set ($latitude, $longitude)';
  }

  @override
  String onboardingErrorGettingLocation(String error) {
    return 'Error getting location: $error';
  }

  @override
  String get authCreateAccountTitle => 'Create your account';

  @override
  String get authWelcomeBackTitle => 'Welcome back';

  @override
  String get authUsernameLabel => 'Username';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authForgotPassword => 'Forgot password?';

  @override
  String get authCreateAccountButton => 'Create account';

  @override
  String get authLogInButton => 'Log in';

  @override
  String get authToggleToLogin => 'Already have an account? Log in';

  @override
  String get authToggleToRegister => 'Don\'t have an account? Register';

  @override
  String get authContinueWithGoogle => 'Continue with Google';

  @override
  String get authErrorEmailInUse =>
      'That email is already registered. Try logging in instead.';

  @override
  String get authErrorInvalidEmail => 'That email address is not valid.';

  @override
  String get authErrorWrongPassword => 'Incorrect email or password.';

  @override
  String get authErrorUserNotFound => 'No account found for that email.';

  @override
  String get authErrorUserDisabled => 'This account has been disabled.';

  @override
  String get authErrorWeakPassword =>
      'Password is too weak (minimum 6 characters).';

  @override
  String get authErrorNetworkRequestFailed =>
      'Network error. Check your connection and try again.';

  @override
  String get authErrorTooManyRequests =>
      'Too many attempts. Please try again later.';

  @override
  String get authErrorGeneric => 'Authentication failed. Please try again.';

  @override
  String get authUsernameTaken =>
      'That username is already taken. Please choose another.';

  @override
  String get authForgotPasswordEnterEmail =>
      'Enter your email above first, then tap \"Forgot password\".';

  @override
  String authPasswordResetSent(String email) {
    return 'Password reset email sent to $email.';
  }

  @override
  String commonMinutesShort(int minutes) {
    return '$minutes min';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSaveTooltip => 'Save Settings';

  @override
  String get settingsProfileTitle => 'Profile';

  @override
  String get settingsNameLabel => 'Your Name';

  @override
  String get settingsNameHint => 'Enter your name';

  @override
  String get settingsStatTotalDays => 'Total Days';

  @override
  String get settingsStatCurrentStreak => 'Current Streak';

  @override
  String get settingsStatChallengeWeek => 'Challenge Week';

  @override
  String settingsChallengeWeekRatio(int week, int totalWeeks) {
    return '$week/$totalWeeks';
  }

  @override
  String get settingsLocationTitle => 'Location';

  @override
  String settingsCoordinates(String latitude, String longitude) {
    return 'Coordinates: $latitude, $longitude';
  }

  @override
  String get settingsPrayerSettingsTitle => 'Prayer Settings';

  @override
  String get settingsCalculationMethodLabel => 'Calculation Method';

  @override
  String get settingsJuristicMethodTitle => 'Juristic Method';

  @override
  String get settingsJuristicHanafi => 'Hanafi (Later Asr time)';

  @override
  String get settingsJuristicStandard => 'Standard (Shafi, Maliki, Hanbali)';

  @override
  String get settingsHanafiInfo =>
      'Hanafi method calculates Asr time when shadow is twice the object length';

  @override
  String get settingsNotificationsTitle => 'Notifications';

  @override
  String get settingsEnableNotifications => 'Enable Notifications';

  @override
  String get settingsEnableNotificationsSubtitle => 'Get reminders and updates';

  @override
  String get settingsFajrReminderTitle => 'Fajr Prayer Reminder';

  @override
  String settingsFajrReminderSubtitle(int minutes) {
    return 'Notify $minutes min before Fajr';
  }

  @override
  String get settingsRemindMe => 'Remind me';

  @override
  String get settingsBeforeFajr => 'before Fajr';

  @override
  String get settingsLoggingReminderTitle => 'Daily Logging Reminder';

  @override
  String settingsLoggingReminderSubtitle(String time) {
    return 'Remind at $time to log day';
  }

  @override
  String get settingsAppearanceTitle => 'Appearance';

  @override
  String get settingsThemeLabel => 'Theme';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsTimeFormatLabel => 'Time Format';

  @override
  String get settingsTimeFormat12 => '12-hour';

  @override
  String get settingsTimeFormat24 => '24-hour';

  @override
  String get settingsChallengeTitle => 'Challenge';

  @override
  String get settingsChallengeStarted => 'Challenge Started';

  @override
  String get settingsChallengeNotStarted => 'Not started';

  @override
  String get settingsEndChallenge => 'End Challenge';

  @override
  String get settingsAboutTitle => 'About';

  @override
  String get settingsAppVersion => 'App Version';

  @override
  String get settingsGuestAccount => 'Guest account';

  @override
  String get settingsSignedIn => 'Signed in';

  @override
  String get settingsLinkGooglePrompt =>
      'Tap to back up your progress with Google';

  @override
  String get settingsProgressSavedLocally => 'Progress is saved on this device';

  @override
  String get settingsSynced => 'Synced';

  @override
  String get settingsGuidelines => 'Guidelines';

  @override
  String get settingsSendFeedback => 'Send Feedback';

  @override
  String get settingsShareApp => 'Share App';

  @override
  String get settingsSignedInWithGoogle => 'Signed in with Google.';

  @override
  String get settingsFeedbackSubject => 'Subh Warrior Feedback';

  @override
  String settingsFeedbackAppVersion(String version, String build) {
    return 'App version: $version ($build)';
  }

  @override
  String settingsNoEmailApp(String email) {
    return 'No email app found. Reach us at $email';
  }

  @override
  String get settingsShareMessage =>
      'Build powerful mornings with Subh Warrior — wake for Fajr, stay productive, and finish the 28-day challenge. 🌅';

  @override
  String get settingsEnterNamePrompt => 'Please enter your name';

  @override
  String get settingsSavedSuccess => 'Settings saved successfully';

  @override
  String get settingsEndChallengeDialogTitle => 'End Challenge?';

  @override
  String get settingsEndChallengeDialogContent =>
      'Are you sure you want to end the challenge? Your progress will be saved but the challenge will be marked as incomplete.';

  @override
  String get settingsCancel => 'Cancel';

  @override
  String get settingsGuidelinesDialogTitle => 'Challenge Guidelines';

  @override
  String settingsGuidelinesContent(String cutoffTime) {
    return '🌅 SUBH WARRIOR CHALLENGE\n\n✓ Wake up at or before Fajr time\n✓ Stay awake and alert\n✓ Pray Fajr within the prayer window\n✓ Complete 60+ minutes of productive work\n✓ Log before $cutoffTime daily\n✓ Complete 16+ days over 4 weeks\n✓ Minimum 4 qualifying days per week\n\nQUALIFYING WORK:\n• Deep work tasks\n• Strategic planning\n• Learning/skill development\n• Creative projects\n• Important communication\n\nNON-QUALIFYING:\n• Passive content consumption\n• Routine administrative tasks\n• Social media\n\nNote: Weekends do not count as qualifying days.';
  }

  @override
  String get settingsGotIt => 'Got it!';

  @override
  String get progressNoChallenge => 'Start a challenge to track your progress';

  @override
  String get progressChallengeProgress => 'Challenge Progress';

  @override
  String get progressStatCompleted => 'Completed';

  @override
  String get progressStatRemaining => 'Remaining';

  @override
  String get progressStatStreak => 'Streak';

  @override
  String get progressWeeklyPerformance => 'Weekly Performance';

  @override
  String progressWeekAxisLabel(int week) {
    return 'W$week';
  }

  @override
  String get progressNoDaysLogged => 'No days logged yet';

  @override
  String get progressRecentLogs => 'Recent Logs';

  @override
  String get progressLogFajrPrayed => '✓ Fajr';

  @override
  String get progressLogFajrMissed => '✗ Fajr';

  @override
  String progressLogSubtitle(String fajrStatus, int minutes) {
    return '$fajrStatus • $minutes min work';
  }

  @override
  String get logDayWeekendTitle => 'Weekend Day';

  @override
  String get logDayWeekendBody =>
      'Weekend days do not count toward the Subh Warrior Challenge.\n\nYou need 4 qualifying weekdays per week.';

  @override
  String get logDayGoBack => 'Go Back';

  @override
  String get logDayTimeUpTitle => 'Time\'s Up!';

  @override
  String logDayTimeUpBody(String cutoffTime) {
    return 'Daily logs must be submitted before $cutoffTime.';
  }

  @override
  String logDayTimeRemaining(int hours, int minutes) {
    return 'Time remaining to log: ${hours}h ${minutes}m';
  }

  @override
  String get logDayTodaysFajr => 'Today\'s Fajr';

  @override
  String get logDayPrayerTimeNow => 'Prayer Time Now';

  @override
  String get logDayLoading => 'Loading...';

  @override
  String logDaySunrise(String time) {
    return 'Sunrise: $time';
  }

  @override
  String get logDayWakeUpTitle => 'Wake-Up Requirements';

  @override
  String get logDayWokeUpTitle => 'Woke up at/before Fajr time';

  @override
  String get logDayWokeUpSubtitle => 'Not just temporary wake-up';

  @override
  String get logDayStayedAwake => 'Stayed awake and alert';

  @override
  String get logDayStayedAwakeSubtitle => 'Remained conscious after prayer';

  @override
  String get logDayPrayedFajrOnTime => 'Prayed Fajr on time';

  @override
  String get logDayWithinWindow => 'Within the prayer window';

  @override
  String get logDayPrayedAtMasjid => 'Prayed at Masjid';

  @override
  String get logDayMasjidSubtitle => 'Highly recommended (not required)';

  @override
  String get logDayProductiveWork => 'Productive Work';

  @override
  String get logDayTypeOfWork => 'Type of Work';

  @override
  String get logDayWorkTypeDeepWork => 'Deep Work';

  @override
  String get logDayWorkTypeStrategicPlanning => 'Strategic Planning';

  @override
  String get logDayWorkTypeLearning => 'Learning/Skill Development';

  @override
  String get logDayWorkTypeCreativeProjects => 'Creative Projects';

  @override
  String get logDayWorkTypeImportantCommunication => 'Important Communication';

  @override
  String get logDayWorkTypePassiveConsumption =>
      '❌ Passive Content Consumption';

  @override
  String get logDayWorkTypeRoutineAdmin => '❌ Routine Administrative Tasks';

  @override
  String get logDayWorkTypeSocialMedia => '❌ Social Media';

  @override
  String get logDayWorkNotQualify => 'This type of work does not qualify';

  @override
  String logDayMinutesFocused(int minutes) {
    return 'Minutes of focused work: $minutes';
  }

  @override
  String logDayMinimumMinutes(int minutes) {
    return 'Minimum $minutes minutes required for qualification';
  }

  @override
  String get logDayDescribeWorkLabel => 'Describe your work';

  @override
  String get logDayDescribeWorkHint => 'What specific tasks did you complete?';

  @override
  String get logDayDescribeWorkError => 'Please describe your work';

  @override
  String get logDayMoreDetailError => 'Please provide more detail';

  @override
  String get logDayReflectionTitle => 'Reflection (Optional)';

  @override
  String get logDayReflectionHint =>
      'How did the early morning work feel?\nWhat did you accomplish?\nAny insights or breakthroughs?';

  @override
  String get logDayQualifyingDay => 'Qualifying Day!';

  @override
  String get logDayNotQualifyingYet => 'Not Qualifying Yet';

  @override
  String get logDayReqAwake => 'Awake at/before Fajr';

  @override
  String logDayReqMinutesWork(int minutes) {
    return '$minutes+ minutes of work';
  }

  @override
  String get logDayReqQualifyingWorkType => 'Qualifying work type';

  @override
  String get logDayBonusMasjid => 'Bonus: Prayed at Masjid! 🌟';

  @override
  String get logDaySubmitButton => 'Submit Log';

  @override
  String get logDayMustBeAwake => 'You must be awake and alert for Fajr';

  @override
  String get logDayExceptional => 'Exceptional!';

  @override
  String get logDayExcellent => 'Excellent!';

  @override
  String get logDayDayLogged => 'Day Logged';

  @override
  String get logDayMasjidSuccessContent =>
      'Outstanding! You prayed at the masjid AND completed your morning work. True Subh Warrior spirit! 🌟';

  @override
  String get logDayQualifyingSuccessContent =>
      'You\'ve earned a qualifying day! Keep up the great work!';

  @override
  String get logDayLoggedContent =>
      'Day logged successfully. Review the requirements and try again tomorrow!';

  @override
  String get logDayContinue => 'Continue';

  @override
  String logDayAfterCutoff(String cutoffTime) {
    return 'Logging window closed — log before $cutoffTime.';
  }

  @override
  String get logDayWeekendError =>
      'Weekends don\'t count toward the challenge.';

  @override
  String get logDayAlreadyLogged => 'You\'ve already logged today.';

  @override
  String get logDayNotesTooLong =>
      'Your notes are too long — please shorten them.';

  @override
  String get leaderboardTabGlobal => 'Global';

  @override
  String get leaderboardTabFriends => 'Friends';

  @override
  String get leaderboardTabLocal => 'Local';

  @override
  String get leaderboardFriendsComingSoon => 'Friend leaderboard coming soon!';

  @override
  String get leaderboardFriendsSubtitle =>
      'Connect with friends to compete together';

  @override
  String get leaderboardSetLocationTitle =>
      'Set your location to see local warriors';

  @override
  String get leaderboardSetLocationButton => 'Set Location';

  @override
  String get leaderboardLoadError => 'Error loading leaderboard';

  @override
  String get leaderboardYouBadge => 'YOU';

  @override
  String leaderboardDaysCount(int days) {
    return '$days days';
  }

  @override
  String leaderboardStreakCount(int streak) {
    return '$streak streak';
  }

  @override
  String get leaderboardEmptyLocalTitle => 'No warriors in your area yet!';

  @override
  String get leaderboardEmptyGlobalTitle => 'No data available';

  @override
  String get leaderboardEmptyLocalSubtitle =>
      'Be the first to start the challenge';

  @override
  String get leaderboardEmptyGlobalSubtitle =>
      'Start your challenge to appear here';

  @override
  String get dayDetailQualifying => 'Qualifying Day';

  @override
  String get dayDetailNonQualifying => 'Non-Qualifying Day';

  @override
  String get dayDetailWorkDuration => 'Work Duration';

  @override
  String get dayDetailWorkDescription => 'Work Description';

  @override
  String get dayDetailNoDetails => 'No details logged for this day.';

  @override
  String get dayDetailReflection => 'Reflection';

  @override
  String get notifPermTitle => 'Enable Notifications';

  @override
  String get notifPermContent =>
      'Get reminded about Fajr prayer and daily logging to stay on track with your Subh Warrior challenge.';

  @override
  String get notifPermNotNow => 'Not Now';

  @override
  String get notifPermEnable => 'Enable';

  @override
  String get a11yOpenSettings => 'Open settings';

  @override
  String get a11yShowPassword => 'Show password';

  @override
  String get a11yHidePassword => 'Hide password';

  @override
  String get a11yStreakDormant => 'No active streak';

  @override
  String get a11yStreakBuilding => 'Streak building';

  @override
  String get a11yStreakOnFire => 'Streak on fire';

  @override
  String get a11yStreakStrong => 'Strong streak';

  @override
  String get a11yStreakSoaring => 'Streak soaring';

  @override
  String get a11yStreakLegendary => 'Legendary streak';

  @override
  String get a11yGoalTrophy => 'Goal milestone achieved';

  @override
  String get a11yFirstPlace => 'First place';

  @override
  String get a11ySecondPlace => 'Second place';

  @override
  String get a11yThirdPlace => 'Third place';

  @override
  String get a11yMinutesWorkedSlider => 'Minutes of focused work';

  @override
  String get a11yQualifyingDay => 'Qualifying day';

  @override
  String get a11yNonQualifyingDay => 'Non-qualifying day';

  @override
  String get a11yRequirementMet => 'Requirement met';

  @override
  String get a11yRequirementNotMet => 'Requirement not met';
}
