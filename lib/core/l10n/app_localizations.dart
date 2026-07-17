import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// The application title shown in the task switcher
  ///
  /// In en, this message translates to:
  /// **'Subh Warrior Challenge'**
  String get appTitle;

  /// Branding text shown on the splash screen
  ///
  /// In en, this message translates to:
  /// **'Subh Warrior'**
  String get splashTitle;

  /// No description provided for @homeAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Subh Warrior'**
  String get homeAppBarTitle;

  /// Snackbar shown after the user starts the challenge
  ///
  /// In en, this message translates to:
  /// **'Challenge started — log your first day!'**
  String get homeChallengeStartedSnack;

  /// No description provided for @homeNavHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeNavHome;

  /// No description provided for @homeNavProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get homeNavProgress;

  /// No description provided for @homeNavLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get homeNavLeaderboard;

  /// No description provided for @homeGreetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get homeGreetingMorning;

  /// No description provided for @homeGreetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get homeGreetingAfternoon;

  /// No description provided for @homeGreetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get homeGreetingEvening;

  /// Name shown in the greeting header when the user has not set a name
  ///
  /// In en, this message translates to:
  /// **'Warrior'**
  String get homeGreetingFallbackName;

  /// No description provided for @inactiveChallengeTitle.
  ///
  /// In en, this message translates to:
  /// **'Ready to become a Subh Warrior?'**
  String get inactiveChallengeTitle;

  /// Call-to-action body text shown when no challenge is active
  ///
  /// In en, this message translates to:
  /// **'Start your {days}-day challenge to build a powerful morning routine with Fajr prayer and productive work.'**
  String inactiveChallengeBody(int days);

  /// No description provided for @inactiveChallengeStartButton.
  ///
  /// In en, this message translates to:
  /// **'Start Challenge'**
  String get inactiveChallengeStartButton;

  /// No description provided for @todayStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Status'**
  String get todayStatusTitle;

  /// Status chip when today's log meets the qualifying criteria
  ///
  /// In en, this message translates to:
  /// **'Qualifying ✓'**
  String get todayStatusChipQualifying;

  /// No description provided for @todayStatusChipLogged.
  ///
  /// In en, this message translates to:
  /// **'Logged'**
  String get todayStatusChipLogged;

  /// No description provided for @todayStatusChipPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get todayStatusChipPending;

  /// Status chip when the logging window for today has closed
  ///
  /// In en, this message translates to:
  /// **'Time\'s Up'**
  String get todayStatusChipTimeUp;

  /// No description provided for @todayStatusFajrPrayer.
  ///
  /// In en, this message translates to:
  /// **'Fajr Prayer'**
  String get todayStatusFajrPrayer;

  /// No description provided for @todayStatusFajrOnTime.
  ///
  /// In en, this message translates to:
  /// **'On Time'**
  String get todayStatusFajrOnTime;

  /// No description provided for @todayStatusFajrMissed.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get todayStatusFajrMissed;

  /// No description provided for @todayStatusWorkTime.
  ///
  /// In en, this message translates to:
  /// **'Work Time'**
  String get todayStatusWorkTime;

  /// Number of minutes worked today
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes'**
  String todayStatusMinutesWorked(int minutes);

  /// No description provided for @todayStatusWorkLabel.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get todayStatusWorkLabel;

  /// No description provided for @todayStatusLogTodayButton.
  ///
  /// In en, this message translates to:
  /// **'Log Today'**
  String get todayStatusLogTodayButton;

  /// Shown when logging is no longer allowed; cutoffTime is a formatted clock time such as 8:00 AM
  ///
  /// In en, this message translates to:
  /// **'Logging window closed (after {cutoffTime})'**
  String todayStatusWindowClosed(String cutoffTime);

  /// No description provided for @weeklyProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly Progress'**
  String get weeklyProgressTitle;

  /// Label for a week row in the weekly progress card
  ///
  /// In en, this message translates to:
  /// **'Week {week}'**
  String weeklyProgressWeekLabel(int week);

  /// Qualifying days achieved out of the weekly target, e.g. 3/4
  ///
  /// In en, this message translates to:
  /// **'{progress}/{target}'**
  String weeklyProgressRatio(int progress, int target);

  /// No description provided for @quickStatsDaysLeft.
  ///
  /// In en, this message translates to:
  /// **'Days Left'**
  String get quickStatsDaysLeft;

  /// No description provided for @quickStatsGoalProgress.
  ///
  /// In en, this message translates to:
  /// **'Goal Progress'**
  String get quickStatsGoalProgress;

  /// Overall progress percentage shown inside the circular indicator
  ///
  /// In en, this message translates to:
  /// **'{percent}%'**
  String quickStatsPercent(int percent);

  /// Qualifying days achieved out of the overall goal, e.g. 5/16
  ///
  /// In en, this message translates to:
  /// **'{count}/{goal}'**
  String quickStatsGoalRatio(int count, int goal);

  /// No description provided for @quote1.
  ///
  /// In en, this message translates to:
  /// **'\"O Allah, bless my Ummah in its early mornings.\" - Prophet Muhammad ﷺ (Abu Dawud, Tirmidhi)'**
  String get quote1;

  /// No description provided for @quote2.
  ///
  /// In en, this message translates to:
  /// **'\"The two Rak\'ah before Fajr are better than this world and all that it contains.\" - Prophet Muhammad ﷺ (Muslim)'**
  String get quote2;

  /// No description provided for @quote3.
  ///
  /// In en, this message translates to:
  /// **'\"Whoever prays the dawn prayer in congregation, it is as if he prayed the whole night.\" - Prophet Muhammad ﷺ (Muslim)'**
  String get quote3;

  /// No description provided for @quote4.
  ///
  /// In en, this message translates to:
  /// **'\"And [recite] the Qur\'an at dawn. Indeed, the recitation of dawn is ever witnessed.\" - Qur\'an 17:78'**
  String get quote4;

  /// No description provided for @quote5.
  ///
  /// In en, this message translates to:
  /// **'\"Indeed, the night prayer is most effective for the heart and most upright in speech.\" - Qur\'an 73:6'**
  String get quote5;

  /// No description provided for @quote6.
  ///
  /// In en, this message translates to:
  /// **'\"Take advantage of five before five: your youth before your old age, your health before your sickness, your wealth before your poverty, your free time before your busyness, and your life before your death.\" - Prophet Muhammad ﷺ (Al-Hakim)'**
  String get quote6;

  /// No description provided for @quote7.
  ///
  /// In en, this message translates to:
  /// **'\"The most beloved deeds to Allah are those done consistently, even if small.\" - Prophet Muhammad ﷺ (Bukhari & Muslim)'**
  String get quote7;

  /// No description provided for @quote8.
  ///
  /// In en, this message translates to:
  /// **'\"And when the prayer has ended, disperse in the land and seek the bounty of Allah.\" - Qur\'an 62:10'**
  String get quote8;

  /// No description provided for @quote9.
  ///
  /// In en, this message translates to:
  /// **'\"There are two blessings which many people lose: good health and free time.\" - Prophet Muhammad ﷺ (Bukhari)'**
  String get quote9;

  /// No description provided for @quote10.
  ///
  /// In en, this message translates to:
  /// **'\"Whoever rises in the morning safe in his home, healthy in body, with food for the day, it is as if the whole world were given to him.\" - Prophet Muhammad ﷺ (Tirmidhi)'**
  String get quote10;

  /// No description provided for @prayerCardErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Unable to load prayer times'**
  String get prayerCardErrorMessage;

  /// No description provided for @prayerCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Fajr Prayer'**
  String get prayerCardTitle;

  /// Badge shown while the Fajr prayer window is currently open
  ///
  /// In en, this message translates to:
  /// **'NOW'**
  String get prayerCardNowBadge;

  /// No description provided for @prayerCardToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get prayerCardToday;

  /// No description provided for @prayerCardTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get prayerCardTomorrow;

  /// Label above the countdown to the next Fajr prayer
  ///
  /// In en, this message translates to:
  /// **'Next Fajr In'**
  String get prayerCardNextFajrIn;

  /// No description provided for @prayerCardSunrise.
  ///
  /// In en, this message translates to:
  /// **'Sunrise'**
  String get prayerCardSunrise;

  /// No description provided for @prayerCardDhuhr.
  ///
  /// In en, this message translates to:
  /// **'Dhuhr'**
  String get prayerCardDhuhr;

  /// No description provided for @prayerCardAsr.
  ///
  /// In en, this message translates to:
  /// **'Asr'**
  String get prayerCardAsr;

  /// No description provided for @prayerCardMaghrib.
  ///
  /// In en, this message translates to:
  /// **'Maghrib'**
  String get prayerCardMaghrib;

  /// No description provided for @prayerCardIsha.
  ///
  /// In en, this message translates to:
  /// **'Isha'**
  String get prayerCardIsha;

  /// Streak label when the current streak is exactly 1 day
  ///
  /// In en, this message translates to:
  /// **'Day Streak'**
  String get streakCardDayStreak;

  /// Streak label when the current streak is not exactly 1 day
  ///
  /// In en, this message translates to:
  /// **'Days Streak'**
  String get streakCardDaysStreak;

  /// No description provided for @streakCardQualifyingDays.
  ///
  /// In en, this message translates to:
  /// **'Qualifying Days'**
  String get streakCardQualifyingDays;

  /// Denominator shown under the qualifying days count inside the progress ring
  ///
  /// In en, this message translates to:
  /// **'/16'**
  String get streakCardGoalDenominator;

  /// No description provided for @streakCardMsgLegendary.
  ///
  /// In en, this message translates to:
  /// **'LEGENDARY!'**
  String get streakCardMsgLegendary;

  /// No description provided for @streakCardMsgUnstoppable.
  ///
  /// In en, this message translates to:
  /// **'UNSTOPPABLE!'**
  String get streakCardMsgUnstoppable;

  /// No description provided for @streakCardMsgOnFire.
  ///
  /// In en, this message translates to:
  /// **'ON FIRE!'**
  String get streakCardMsgOnFire;

  /// No description provided for @streakCardMsgKeepGoing.
  ///
  /// In en, this message translates to:
  /// **'KEEP GOING!'**
  String get streakCardMsgKeepGoing;

  /// No description provided for @errorViewDefaultMessage.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorViewDefaultMessage;

  /// No description provided for @errorViewRetryButton.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get errorViewRetryButton;

  /// Divider label between alternative options, e.g. between manual entry and an automatic action
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get commonOr;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to\nSubh Warrior'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Transform your mornings with the power of Fajr prayer and focused productivity'**
  String get onboardingWelcomeSubtitle;

  /// No description provided for @onboardingFeatureFajrTracking.
  ///
  /// In en, this message translates to:
  /// **'Fajr Prayer Tracking'**
  String get onboardingFeatureFajrTracking;

  /// No description provided for @onboardingFeatureProductiveWork.
  ///
  /// In en, this message translates to:
  /// **'60+ Min Productive Work'**
  String get onboardingFeatureProductiveWork;

  /// No description provided for @onboardingFeatureChallengeDuration.
  ///
  /// In en, this message translates to:
  /// **'28-Day Challenge'**
  String get onboardingFeatureChallengeDuration;

  /// No description provided for @onboardingFeatureAchieveDays.
  ///
  /// In en, this message translates to:
  /// **'Achieve 16+ Days'**
  String get onboardingFeatureAchieveDays;

  /// No description provided for @onboardingRulesTitle.
  ///
  /// In en, this message translates to:
  /// **'Challenge Rules'**
  String get onboardingRulesTitle;

  /// No description provided for @onboardingRuleWakeUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Wake Up'**
  String get onboardingRuleWakeUpTitle;

  /// No description provided for @onboardingRuleWakeUpDesc.
  ///
  /// In en, this message translates to:
  /// **'Rise at or before Fajr time and stay awake'**
  String get onboardingRuleWakeUpDesc;

  /// No description provided for @onboardingRulePrayTitle.
  ///
  /// In en, this message translates to:
  /// **'Pray'**
  String get onboardingRulePrayTitle;

  /// No description provided for @onboardingRulePrayDesc.
  ///
  /// In en, this message translates to:
  /// **'Perform Fajr prayer within the time window'**
  String get onboardingRulePrayDesc;

  /// No description provided for @onboardingRuleWorkTitle.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get onboardingRuleWorkTitle;

  /// No description provided for @onboardingRuleWorkDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete 60+ minutes of productive work'**
  String get onboardingRuleWorkDesc;

  /// No description provided for @onboardingRuleLogTitle.
  ///
  /// In en, this message translates to:
  /// **'Log'**
  String get onboardingRuleLogTitle;

  /// Rule describing the daily logging deadline; cutoffTime is a formatted clock time such as 8:00 AM
  ///
  /// In en, this message translates to:
  /// **'Submit your day before {cutoffTime} (weekdays only)'**
  String onboardingRuleLogDesc(String cutoffTime);

  /// No description provided for @onboardingRulesGoal.
  ///
  /// In en, this message translates to:
  /// **'Complete 16+ qualifying days over 4 weeks'**
  String get onboardingRulesGoal;

  /// No description provided for @onboardingLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Set Your Location'**
  String get onboardingLocationTitle;

  /// No description provided for @onboardingLocationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We need this to calculate accurate prayer times'**
  String get onboardingLocationSubtitle;

  /// No description provided for @onboardingLocationFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'City/Location'**
  String get onboardingLocationFieldLabel;

  /// Example hint text inside the location input field
  ///
  /// In en, this message translates to:
  /// **'e.g., New York, USA'**
  String get onboardingLocationFieldHint;

  /// No description provided for @onboardingGettingLocation.
  ///
  /// In en, this message translates to:
  /// **'Getting Location...'**
  String get onboardingGettingLocation;

  /// No description provided for @onboardingUseCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Use Current Location'**
  String get onboardingUseCurrentLocation;

  /// No description provided for @onboardingReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re All Set!'**
  String get onboardingReadyTitle;

  /// Greeting on the final onboarding page; name is the user's entered name or a fallback
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name}!'**
  String onboardingWelcomeUser(String name);

  /// No description provided for @onboardingStartJourneyButton.
  ///
  /// In en, this message translates to:
  /// **'Start Your Journey'**
  String get onboardingStartJourneyButton;

  /// No description provided for @onboardingBackButton.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get onboardingBackButton;

  /// No description provided for @onboardingNextButton.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNextButton;

  /// No description provided for @onboardingSetLocationPrompt.
  ///
  /// In en, this message translates to:
  /// **'Please set your location'**
  String get onboardingSetLocationPrompt;

  /// No description provided for @onboardingLocationNotFound.
  ///
  /// In en, this message translates to:
  /// **'Could not find that location. Please check spelling.'**
  String get onboardingLocationNotFound;

  /// Snackbar shown when geocoding a typed location throws; error is the exception text
  ///
  /// In en, this message translates to:
  /// **'Error finding location: {error}'**
  String onboardingErrorFindingLocation(String error);

  /// No description provided for @onboardingCoordinatesNotFound.
  ///
  /// In en, this message translates to:
  /// **'Unable to find coordinates for that location.'**
  String get onboardingCoordinatesNotFound;

  /// No description provided for @onboardingLocationServicesDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location services are disabled. Please enable them in settings.'**
  String get onboardingLocationServicesDisabled;

  /// No description provided for @onboardingLocationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permissions are denied'**
  String get onboardingLocationPermissionDenied;

  /// No description provided for @onboardingLocationPermissionDeniedForever.
  ///
  /// In en, this message translates to:
  /// **'Location permissions are permanently denied. Please enable them in app settings.'**
  String get onboardingLocationPermissionDeniedForever;

  /// Snackbar action button that opens the app settings
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get onboardingSettingsAction;

  /// Fallback city name when reverse geocoding returns no locality
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get onboardingUnknownLocality;

  /// Location field text when only raw coordinates are available; latitude/longitude are formatted decimal strings
  ///
  /// In en, this message translates to:
  /// **'Location set ({latitude}, {longitude})'**
  String onboardingLocationSetCoords(String latitude, String longitude);

  /// Snackbar shown when fetching the device location throws; error is the exception text
  ///
  /// In en, this message translates to:
  /// **'Error getting location: {error}'**
  String onboardingErrorGettingLocation(String error);

  /// No description provided for @authCreateAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get authCreateAccountTitle;

  /// No description provided for @authWelcomeBackTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get authWelcomeBackTitle;

  /// No description provided for @authUsernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get authUsernameLabel;

  /// No description provided for @authEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmailLabel;

  /// No description provided for @authPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPasswordLabel;

  /// No description provided for @authForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get authForgotPassword;

  /// No description provided for @authCreateAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authCreateAccountButton;

  /// No description provided for @authLogInButton.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get authLogInButton;

  /// No description provided for @authToggleToLogin.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Log in'**
  String get authToggleToLogin;

  /// No description provided for @authToggleToRegister.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Register'**
  String get authToggleToRegister;

  /// No description provided for @authContinueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get authContinueWithGoogle;

  /// No description provided for @authErrorEmailInUse.
  ///
  /// In en, this message translates to:
  /// **'That email is already registered. Try logging in instead.'**
  String get authErrorEmailInUse;

  /// No description provided for @authErrorInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'That email address is not valid.'**
  String get authErrorInvalidEmail;

  /// No description provided for @authErrorWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password.'**
  String get authErrorWrongPassword;

  /// No description provided for @authErrorUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'No account found for that email.'**
  String get authErrorUserNotFound;

  /// No description provided for @authErrorUserDisabled.
  ///
  /// In en, this message translates to:
  /// **'This account has been disabled.'**
  String get authErrorUserDisabled;

  /// No description provided for @authErrorWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'Password is too weak (minimum 6 characters).'**
  String get authErrorWeakPassword;

  /// No description provided for @authErrorNetworkRequestFailed.
  ///
  /// In en, this message translates to:
  /// **'Network error. Check your connection and try again.'**
  String get authErrorNetworkRequestFailed;

  /// No description provided for @authErrorTooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please try again later.'**
  String get authErrorTooManyRequests;

  /// Fallback error when a Firebase auth error has no specific mapping
  ///
  /// In en, this message translates to:
  /// **'Authentication failed. Please try again.'**
  String get authErrorGeneric;

  /// No description provided for @authUsernameTaken.
  ///
  /// In en, this message translates to:
  /// **'That username is already taken. Please choose another.'**
  String get authUsernameTaken;

  /// No description provided for @authForgotPasswordEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email above first, then tap \"Forgot password\".'**
  String get authForgotPasswordEnterEmail;

  /// Snackbar confirming a password reset email was sent
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent to {email}.'**
  String authPasswordResetSent(String email);

  /// Short minutes label, e.g. in the reminder dropdown and work slider
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String commonMinutesShort(int minutes);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSaveTooltip.
  ///
  /// In en, this message translates to:
  /// **'Save Settings'**
  String get settingsSaveTooltip;

  /// No description provided for @settingsProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get settingsProfileTitle;

  /// No description provided for @settingsNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Your Name'**
  String get settingsNameLabel;

  /// No description provided for @settingsNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get settingsNameHint;

  /// No description provided for @settingsStatTotalDays.
  ///
  /// In en, this message translates to:
  /// **'Total Days'**
  String get settingsStatTotalDays;

  /// No description provided for @settingsStatCurrentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current Streak'**
  String get settingsStatCurrentStreak;

  /// No description provided for @settingsStatChallengeWeek.
  ///
  /// In en, this message translates to:
  /// **'Challenge Week'**
  String get settingsStatChallengeWeek;

  /// Current challenge week out of total weeks, e.g. 2/4
  ///
  /// In en, this message translates to:
  /// **'{week}/{totalWeeks}'**
  String settingsChallengeWeekRatio(int week, int totalWeeks);

  /// No description provided for @settingsLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get settingsLocationTitle;

  /// Saved coordinates shown below the location field; latitude/longitude are formatted decimal strings
  ///
  /// In en, this message translates to:
  /// **'Coordinates: {latitude}, {longitude}'**
  String settingsCoordinates(String latitude, String longitude);

  /// No description provided for @settingsPrayerSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Prayer Settings'**
  String get settingsPrayerSettingsTitle;

  /// No description provided for @settingsCalculationMethodLabel.
  ///
  /// In en, this message translates to:
  /// **'Calculation Method'**
  String get settingsCalculationMethodLabel;

  /// No description provided for @settingsJuristicMethodTitle.
  ///
  /// In en, this message translates to:
  /// **'Juristic Method'**
  String get settingsJuristicMethodTitle;

  /// No description provided for @settingsJuristicHanafi.
  ///
  /// In en, this message translates to:
  /// **'Hanafi (Later Asr time)'**
  String get settingsJuristicHanafi;

  /// No description provided for @settingsJuristicStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard (Shafi, Maliki, Hanbali)'**
  String get settingsJuristicStandard;

  /// No description provided for @settingsHanafiInfo.
  ///
  /// In en, this message translates to:
  /// **'Hanafi method calculates Asr time when shadow is twice the object length'**
  String get settingsHanafiInfo;

  /// No description provided for @settingsNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotificationsTitle;

  /// No description provided for @settingsEnableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get settingsEnableNotifications;

  /// No description provided for @settingsEnableNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get reminders and updates'**
  String get settingsEnableNotificationsSubtitle;

  /// No description provided for @settingsFajrReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Fajr Prayer Reminder'**
  String get settingsFajrReminderTitle;

  /// Subtitle for the Fajr reminder switch showing the configured lead time in minutes
  ///
  /// In en, this message translates to:
  /// **'Notify {minutes} min before Fajr'**
  String settingsFajrReminderSubtitle(int minutes);

  /// No description provided for @settingsRemindMe.
  ///
  /// In en, this message translates to:
  /// **'Remind me'**
  String get settingsRemindMe;

  /// Trailing part of the sentence 'Remind me [X min] before Fajr' around the minutes dropdown
  ///
  /// In en, this message translates to:
  /// **'before Fajr'**
  String get settingsBeforeFajr;

  /// No description provided for @settingsLoggingReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Logging Reminder'**
  String get settingsLoggingReminderTitle;

  /// Subtitle for the daily logging reminder switch; time is a formatted clock time such as 7:30 AM
  ///
  /// In en, this message translates to:
  /// **'Remind at {time} to log day'**
  String settingsLoggingReminderSubtitle(String time);

  /// No description provided for @settingsAppearanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearanceTitle;

  /// No description provided for @settingsThemeLabel.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsThemeLabel;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsTimeFormatLabel.
  ///
  /// In en, this message translates to:
  /// **'Time Format'**
  String get settingsTimeFormatLabel;

  /// No description provided for @settingsTimeFormat12.
  ///
  /// In en, this message translates to:
  /// **'12-hour'**
  String get settingsTimeFormat12;

  /// No description provided for @settingsTimeFormat24.
  ///
  /// In en, this message translates to:
  /// **'24-hour'**
  String get settingsTimeFormat24;

  /// No description provided for @settingsChallengeTitle.
  ///
  /// In en, this message translates to:
  /// **'Challenge'**
  String get settingsChallengeTitle;

  /// No description provided for @settingsChallengeStarted.
  ///
  /// In en, this message translates to:
  /// **'Challenge Started'**
  String get settingsChallengeStarted;

  /// No description provided for @settingsChallengeNotStarted.
  ///
  /// In en, this message translates to:
  /// **'Not started'**
  String get settingsChallengeNotStarted;

  /// No description provided for @settingsEndChallenge.
  ///
  /// In en, this message translates to:
  /// **'End Challenge'**
  String get settingsEndChallenge;

  /// No description provided for @settingsAboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAboutTitle;

  /// No description provided for @settingsAppVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get settingsAppVersion;

  /// No description provided for @settingsGuestAccount.
  ///
  /// In en, this message translates to:
  /// **'Guest account'**
  String get settingsGuestAccount;

  /// No description provided for @settingsSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Signed in'**
  String get settingsSignedIn;

  /// No description provided for @settingsLinkGooglePrompt.
  ///
  /// In en, this message translates to:
  /// **'Tap to back up your progress with Google'**
  String get settingsLinkGooglePrompt;

  /// No description provided for @settingsProgressSavedLocally.
  ///
  /// In en, this message translates to:
  /// **'Progress is saved on this device'**
  String get settingsProgressSavedLocally;

  /// Fallback subtitle for a signed-in account when no email is available
  ///
  /// In en, this message translates to:
  /// **'Synced'**
  String get settingsSynced;

  /// No description provided for @settingsGuidelines.
  ///
  /// In en, this message translates to:
  /// **'Guidelines'**
  String get settingsGuidelines;

  /// No description provided for @settingsSendFeedback.
  ///
  /// In en, this message translates to:
  /// **'Send Feedback'**
  String get settingsSendFeedback;

  /// No description provided for @settingsShareApp.
  ///
  /// In en, this message translates to:
  /// **'Share App'**
  String get settingsShareApp;

  /// No description provided for @settingsSignedInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Signed in with Google.'**
  String get settingsSignedInWithGoogle;

  /// Subject line pre-filled in the feedback email composer
  ///
  /// In en, this message translates to:
  /// **'Subh Warrior Feedback'**
  String get settingsFeedbackSubject;

  /// Footer of the pre-filled feedback email body identifying the installed app version
  ///
  /// In en, this message translates to:
  /// **'App version: {version} ({build})'**
  String settingsFeedbackAppVersion(String version, String build);

  /// Snackbar shown when no email app could be launched; email is the support address
  ///
  /// In en, this message translates to:
  /// **'No email app found. Reach us at {email}'**
  String settingsNoEmailApp(String email);

  /// Invite message shared via the system share sheet
  ///
  /// In en, this message translates to:
  /// **'Build powerful mornings with Subh Warrior — wake for Fajr, stay productive, and finish the 28-day challenge. 🌅'**
  String get settingsShareMessage;

  /// No description provided for @settingsEnterNamePrompt.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get settingsEnterNamePrompt;

  /// No description provided for @settingsSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Settings saved successfully'**
  String get settingsSavedSuccess;

  /// No description provided for @settingsEndChallengeDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'End Challenge?'**
  String get settingsEndChallengeDialogTitle;

  /// No description provided for @settingsEndChallengeDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to end the challenge? Your progress will be saved but the challenge will be marked as incomplete.'**
  String get settingsEndChallengeDialogContent;

  /// No description provided for @settingsCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get settingsCancel;

  /// No description provided for @settingsGuidelinesDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Challenge Guidelines'**
  String get settingsGuidelinesDialogTitle;

  /// Full challenge guidelines dialog body; cutoffTime is a formatted clock time such as 8:00 AM
  ///
  /// In en, this message translates to:
  /// **'🌅 SUBH WARRIOR CHALLENGE\n\n✓ Wake up at or before Fajr time\n✓ Stay awake and alert\n✓ Pray Fajr within the prayer window\n✓ Complete 60+ minutes of productive work\n✓ Log before {cutoffTime} daily\n✓ Complete 16+ days over 4 weeks\n✓ Minimum 4 qualifying days per week\n\nQUALIFYING WORK:\n• Deep work tasks\n• Strategic planning\n• Learning/skill development\n• Creative projects\n• Important communication\n\nNON-QUALIFYING:\n• Passive content consumption\n• Routine administrative tasks\n• Social media\n\nNote: Weekends do not count as qualifying days.'**
  String settingsGuidelinesContent(String cutoffTime);

  /// No description provided for @settingsGotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it!'**
  String get settingsGotIt;

  /// No description provided for @progressNoChallenge.
  ///
  /// In en, this message translates to:
  /// **'Start a challenge to track your progress'**
  String get progressNoChallenge;

  /// No description provided for @progressChallengeProgress.
  ///
  /// In en, this message translates to:
  /// **'Challenge Progress'**
  String get progressChallengeProgress;

  /// No description provided for @progressStatCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get progressStatCompleted;

  /// No description provided for @progressStatRemaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get progressStatRemaining;

  /// No description provided for @progressStatStreak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get progressStatStreak;

  /// No description provided for @progressWeeklyPerformance.
  ///
  /// In en, this message translates to:
  /// **'Weekly Performance'**
  String get progressWeeklyPerformance;

  /// Abbreviated week label on the weekly chart x-axis, e.g. W1
  ///
  /// In en, this message translates to:
  /// **'W{week}'**
  String progressWeekAxisLabel(int week);

  /// No description provided for @progressNoDaysLogged.
  ///
  /// In en, this message translates to:
  /// **'No days logged yet'**
  String get progressNoDaysLogged;

  /// No description provided for @progressRecentLogs.
  ///
  /// In en, this message translates to:
  /// **'Recent Logs'**
  String get progressRecentLogs;

  /// No description provided for @progressLogFajrPrayed.
  ///
  /// In en, this message translates to:
  /// **'✓ Fajr'**
  String get progressLogFajrPrayed;

  /// No description provided for @progressLogFajrMissed.
  ///
  /// In en, this message translates to:
  /// **'✗ Fajr'**
  String get progressLogFajrMissed;

  /// Recent log list subtitle; fajrStatus is progressLogFajrPrayed or progressLogFajrMissed
  ///
  /// In en, this message translates to:
  /// **'{fajrStatus} • {minutes} min work'**
  String progressLogSubtitle(String fajrStatus, int minutes);

  /// No description provided for @logDayWeekendTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekend Day'**
  String get logDayWeekendTitle;

  /// No description provided for @logDayWeekendBody.
  ///
  /// In en, this message translates to:
  /// **'Weekend days do not count toward the Subh Warrior Challenge.\n\nYou need 4 qualifying weekdays per week.'**
  String get logDayWeekendBody;

  /// No description provided for @logDayGoBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get logDayGoBack;

  /// No description provided for @logDayTimeUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Time\'s Up!'**
  String get logDayTimeUpTitle;

  /// Shown when the logging window has closed; cutoffTime is a formatted clock time such as 8:00 AM
  ///
  /// In en, this message translates to:
  /// **'Daily logs must be submitted before {cutoffTime}.'**
  String logDayTimeUpBody(String cutoffTime);

  /// Countdown banner until the logging deadline
  ///
  /// In en, this message translates to:
  /// **'Time remaining to log: {hours}h {minutes}m'**
  String logDayTimeRemaining(int hours, int minutes);

  /// No description provided for @logDayTodaysFajr.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Fajr'**
  String get logDayTodaysFajr;

  /// No description provided for @logDayPrayerTimeNow.
  ///
  /// In en, this message translates to:
  /// **'Prayer Time Now'**
  String get logDayPrayerTimeNow;

  /// No description provided for @logDayLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get logDayLoading;

  /// Sunrise time line under today's Fajr time; time is a formatted clock time
  ///
  /// In en, this message translates to:
  /// **'Sunrise: {time}'**
  String logDaySunrise(String time);

  /// No description provided for @logDayWakeUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Wake-Up Requirements'**
  String get logDayWakeUpTitle;

  /// No description provided for @logDayWokeUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Woke up at/before Fajr time'**
  String get logDayWokeUpTitle;

  /// No description provided for @logDayWokeUpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Not just temporary wake-up'**
  String get logDayWokeUpSubtitle;

  /// No description provided for @logDayStayedAwake.
  ///
  /// In en, this message translates to:
  /// **'Stayed awake and alert'**
  String get logDayStayedAwake;

  /// No description provided for @logDayStayedAwakeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Remained conscious after prayer'**
  String get logDayStayedAwakeSubtitle;

  /// No description provided for @logDayPrayedFajrOnTime.
  ///
  /// In en, this message translates to:
  /// **'Prayed Fajr on time'**
  String get logDayPrayedFajrOnTime;

  /// No description provided for @logDayWithinWindow.
  ///
  /// In en, this message translates to:
  /// **'Within the prayer window'**
  String get logDayWithinWindow;

  /// No description provided for @logDayPrayedAtMasjid.
  ///
  /// In en, this message translates to:
  /// **'Prayed at Masjid'**
  String get logDayPrayedAtMasjid;

  /// No description provided for @logDayMasjidSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Highly recommended (not required)'**
  String get logDayMasjidSubtitle;

  /// No description provided for @logDayProductiveWork.
  ///
  /// In en, this message translates to:
  /// **'Productive Work'**
  String get logDayProductiveWork;

  /// No description provided for @logDayTypeOfWork.
  ///
  /// In en, this message translates to:
  /// **'Type of Work'**
  String get logDayTypeOfWork;

  /// No description provided for @logDayWorkTypeDeepWork.
  ///
  /// In en, this message translates to:
  /// **'Deep Work'**
  String get logDayWorkTypeDeepWork;

  /// No description provided for @logDayWorkTypeStrategicPlanning.
  ///
  /// In en, this message translates to:
  /// **'Strategic Planning'**
  String get logDayWorkTypeStrategicPlanning;

  /// No description provided for @logDayWorkTypeLearning.
  ///
  /// In en, this message translates to:
  /// **'Learning/Skill Development'**
  String get logDayWorkTypeLearning;

  /// No description provided for @logDayWorkTypeCreativeProjects.
  ///
  /// In en, this message translates to:
  /// **'Creative Projects'**
  String get logDayWorkTypeCreativeProjects;

  /// No description provided for @logDayWorkTypeImportantCommunication.
  ///
  /// In en, this message translates to:
  /// **'Important Communication'**
  String get logDayWorkTypeImportantCommunication;

  /// No description provided for @logDayWorkTypePassiveConsumption.
  ///
  /// In en, this message translates to:
  /// **'❌ Passive Content Consumption'**
  String get logDayWorkTypePassiveConsumption;

  /// No description provided for @logDayWorkTypeRoutineAdmin.
  ///
  /// In en, this message translates to:
  /// **'❌ Routine Administrative Tasks'**
  String get logDayWorkTypeRoutineAdmin;

  /// No description provided for @logDayWorkTypeSocialMedia.
  ///
  /// In en, this message translates to:
  /// **'❌ Social Media'**
  String get logDayWorkTypeSocialMedia;

  /// No description provided for @logDayWorkNotQualify.
  ///
  /// In en, this message translates to:
  /// **'This type of work does not qualify'**
  String get logDayWorkNotQualify;

  /// Label above the work-minutes slider showing the selected value
  ///
  /// In en, this message translates to:
  /// **'Minutes of focused work: {minutes}'**
  String logDayMinutesFocused(int minutes);

  /// Warning under the slider when below the qualifying minimum
  ///
  /// In en, this message translates to:
  /// **'Minimum {minutes} minutes required for qualification'**
  String logDayMinimumMinutes(int minutes);

  /// No description provided for @logDayDescribeWorkLabel.
  ///
  /// In en, this message translates to:
  /// **'Describe your work'**
  String get logDayDescribeWorkLabel;

  /// No description provided for @logDayDescribeWorkHint.
  ///
  /// In en, this message translates to:
  /// **'What specific tasks did you complete?'**
  String get logDayDescribeWorkHint;

  /// No description provided for @logDayDescribeWorkError.
  ///
  /// In en, this message translates to:
  /// **'Please describe your work'**
  String get logDayDescribeWorkError;

  /// No description provided for @logDayMoreDetailError.
  ///
  /// In en, this message translates to:
  /// **'Please provide more detail'**
  String get logDayMoreDetailError;

  /// No description provided for @logDayReflectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Reflection (Optional)'**
  String get logDayReflectionTitle;

  /// No description provided for @logDayReflectionHint.
  ///
  /// In en, this message translates to:
  /// **'How did the early morning work feel?\nWhat did you accomplish?\nAny insights or breakthroughs?'**
  String get logDayReflectionHint;

  /// No description provided for @logDayQualifyingDay.
  ///
  /// In en, this message translates to:
  /// **'Qualifying Day!'**
  String get logDayQualifyingDay;

  /// No description provided for @logDayNotQualifyingYet.
  ///
  /// In en, this message translates to:
  /// **'Not Qualifying Yet'**
  String get logDayNotQualifyingYet;

  /// No description provided for @logDayReqAwake.
  ///
  /// In en, this message translates to:
  /// **'Awake at/before Fajr'**
  String get logDayReqAwake;

  /// Qualification checklist row for the minimum minutes of work
  ///
  /// In en, this message translates to:
  /// **'{minutes}+ minutes of work'**
  String logDayReqMinutesWork(int minutes);

  /// No description provided for @logDayReqQualifyingWorkType.
  ///
  /// In en, this message translates to:
  /// **'Qualifying work type'**
  String get logDayReqQualifyingWorkType;

  /// No description provided for @logDayBonusMasjid.
  ///
  /// In en, this message translates to:
  /// **'Bonus: Prayed at Masjid! 🌟'**
  String get logDayBonusMasjid;

  /// No description provided for @logDaySubmitButton.
  ///
  /// In en, this message translates to:
  /// **'Submit Log'**
  String get logDaySubmitButton;

  /// No description provided for @logDayMustBeAwake.
  ///
  /// In en, this message translates to:
  /// **'You must be awake and alert for Fajr'**
  String get logDayMustBeAwake;

  /// No description provided for @logDayExceptional.
  ///
  /// In en, this message translates to:
  /// **'Exceptional!'**
  String get logDayExceptional;

  /// No description provided for @logDayExcellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent!'**
  String get logDayExcellent;

  /// No description provided for @logDayDayLogged.
  ///
  /// In en, this message translates to:
  /// **'Day Logged'**
  String get logDayDayLogged;

  /// No description provided for @logDayMasjidSuccessContent.
  ///
  /// In en, this message translates to:
  /// **'Outstanding! You prayed at the masjid AND completed your morning work. True Subh Warrior spirit! 🌟'**
  String get logDayMasjidSuccessContent;

  /// No description provided for @logDayQualifyingSuccessContent.
  ///
  /// In en, this message translates to:
  /// **'You\'ve earned a qualifying day! Keep up the great work!'**
  String get logDayQualifyingSuccessContent;

  /// No description provided for @logDayLoggedContent.
  ///
  /// In en, this message translates to:
  /// **'Day logged successfully. Review the requirements and try again tomorrow!'**
  String get logDayLoggedContent;

  /// No description provided for @logDayContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get logDayContinue;

  /// Error when submitting after the cutoff; cutoffTime is a formatted clock time such as 8:00 AM
  ///
  /// In en, this message translates to:
  /// **'Logging window closed — log before {cutoffTime}.'**
  String logDayAfterCutoff(String cutoffTime);

  /// No description provided for @logDayWeekendError.
  ///
  /// In en, this message translates to:
  /// **'Weekends don\'t count toward the challenge.'**
  String get logDayWeekendError;

  /// No description provided for @logDayAlreadyLogged.
  ///
  /// In en, this message translates to:
  /// **'You\'ve already logged today.'**
  String get logDayAlreadyLogged;

  /// No description provided for @logDayNotesTooLong.
  ///
  /// In en, this message translates to:
  /// **'Your notes are too long — please shorten them.'**
  String get logDayNotesTooLong;

  /// No description provided for @leaderboardTabGlobal.
  ///
  /// In en, this message translates to:
  /// **'Global'**
  String get leaderboardTabGlobal;

  /// No description provided for @leaderboardTabFriends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get leaderboardTabFriends;

  /// No description provided for @leaderboardTabLocal.
  ///
  /// In en, this message translates to:
  /// **'Local'**
  String get leaderboardTabLocal;

  /// No description provided for @leaderboardFriendsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Friend leaderboard coming soon!'**
  String get leaderboardFriendsComingSoon;

  /// No description provided for @leaderboardFriendsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Connect with friends to compete together'**
  String get leaderboardFriendsSubtitle;

  /// No description provided for @leaderboardSetLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Set your location to see local warriors'**
  String get leaderboardSetLocationTitle;

  /// No description provided for @leaderboardSetLocationButton.
  ///
  /// In en, this message translates to:
  /// **'Set Location'**
  String get leaderboardSetLocationButton;

  /// No description provided for @leaderboardLoadError.
  ///
  /// In en, this message translates to:
  /// **'Error loading leaderboard'**
  String get leaderboardLoadError;

  /// Badge on the leaderboard row belonging to the current user
  ///
  /// In en, this message translates to:
  /// **'YOU'**
  String get leaderboardYouBadge;

  /// Qualifying days count on a leaderboard row
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String leaderboardDaysCount(int days);

  /// Current streak count on a leaderboard row
  ///
  /// In en, this message translates to:
  /// **'{streak} streak'**
  String leaderboardStreakCount(int streak);

  /// No description provided for @leaderboardEmptyLocalTitle.
  ///
  /// In en, this message translates to:
  /// **'No warriors in your area yet!'**
  String get leaderboardEmptyLocalTitle;

  /// No description provided for @leaderboardEmptyGlobalTitle.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get leaderboardEmptyGlobalTitle;

  /// No description provided for @leaderboardEmptyLocalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Be the first to start the challenge'**
  String get leaderboardEmptyLocalSubtitle;

  /// No description provided for @leaderboardEmptyGlobalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start your challenge to appear here'**
  String get leaderboardEmptyGlobalSubtitle;

  /// No description provided for @dayDetailQualifying.
  ///
  /// In en, this message translates to:
  /// **'Qualifying Day'**
  String get dayDetailQualifying;

  /// No description provided for @dayDetailNonQualifying.
  ///
  /// In en, this message translates to:
  /// **'Non-Qualifying Day'**
  String get dayDetailNonQualifying;

  /// No description provided for @dayDetailWorkDuration.
  ///
  /// In en, this message translates to:
  /// **'Work Duration'**
  String get dayDetailWorkDuration;

  /// No description provided for @dayDetailWorkDescription.
  ///
  /// In en, this message translates to:
  /// **'Work Description'**
  String get dayDetailWorkDescription;

  /// No description provided for @dayDetailNoDetails.
  ///
  /// In en, this message translates to:
  /// **'No details logged for this day.'**
  String get dayDetailNoDetails;

  /// No description provided for @dayDetailReflection.
  ///
  /// In en, this message translates to:
  /// **'Reflection'**
  String get dayDetailReflection;

  /// No description provided for @notifPermTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get notifPermTitle;

  /// No description provided for @notifPermContent.
  ///
  /// In en, this message translates to:
  /// **'Get reminded about Fajr prayer and daily logging to stay on track with your Subh Warrior challenge.'**
  String get notifPermContent;

  /// No description provided for @notifPermNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not Now'**
  String get notifPermNotNow;

  /// No description provided for @notifPermEnable.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get notifPermEnable;

  /// Tooltip for the settings icon button on the home screen
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get a11yOpenSettings;

  /// Tooltip for the password visibility toggle when the password is hidden
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get a11yShowPassword;

  /// Tooltip for the password visibility toggle when the password is visible
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get a11yHidePassword;

  /// Screen reader label for the sleeping emoji shown when the streak is zero
  ///
  /// In en, this message translates to:
  /// **'No active streak'**
  String get a11yStreakDormant;

  /// Screen reader label for the sparkles emoji shown for a 1-2 day streak
  ///
  /// In en, this message translates to:
  /// **'Streak building'**
  String get a11yStreakBuilding;

  /// Screen reader label for the fire emoji shown for a 3-6 day streak
  ///
  /// In en, this message translates to:
  /// **'Streak on fire'**
  String get a11yStreakOnFire;

  /// Screen reader label for the lightning emoji shown for a 7-13 day streak
  ///
  /// In en, this message translates to:
  /// **'Strong streak'**
  String get a11yStreakStrong;

  /// Screen reader label for the rocket emoji shown for a 14-20 day streak
  ///
  /// In en, this message translates to:
  /// **'Streak soaring'**
  String get a11yStreakSoaring;

  /// Screen reader label for the crown emoji shown for a 21+ day streak
  ///
  /// In en, this message translates to:
  /// **'Legendary streak'**
  String get a11yStreakLegendary;

  /// Screen reader label for the trophy icon shown when 8 or more qualifying days are reached
  ///
  /// In en, this message translates to:
  /// **'Goal milestone achieved'**
  String get a11yGoalTrophy;

  /// Screen reader label for the gold medal emoji on the leaderboard
  ///
  /// In en, this message translates to:
  /// **'First place'**
  String get a11yFirstPlace;

  /// Screen reader label for the silver medal emoji on the leaderboard
  ///
  /// In en, this message translates to:
  /// **'Second place'**
  String get a11ySecondPlace;

  /// Screen reader label for the bronze medal emoji on the leaderboard
  ///
  /// In en, this message translates to:
  /// **'Third place'**
  String get a11yThirdPlace;

  /// Screen reader label for the minutes-worked slider on the log day screen
  ///
  /// In en, this message translates to:
  /// **'Minutes of focused work'**
  String get a11yMinutesWorkedSlider;

  /// Screen reader label for the icon marking a qualifying day
  ///
  /// In en, this message translates to:
  /// **'Qualifying day'**
  String get a11yQualifyingDay;

  /// Screen reader label for the icon marking a non-qualifying day
  ///
  /// In en, this message translates to:
  /// **'Non-qualifying day'**
  String get a11yNonQualifyingDay;

  /// Screen reader label for the check icon next to a fulfilled requirement
  ///
  /// In en, this message translates to:
  /// **'Requirement met'**
  String get a11yRequirementMet;

  /// Screen reader label for the cross icon next to an unfulfilled requirement
  ///
  /// In en, this message translates to:
  /// **'Requirement not met'**
  String get a11yRequirementNotMet;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
