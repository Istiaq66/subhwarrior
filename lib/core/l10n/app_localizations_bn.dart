// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appTitle => 'Subh Warrior চ্যালেঞ্জ';

  @override
  String get splashTitle => 'Subh Warrior';

  @override
  String get homeAppBarTitle => 'Subh Warrior';

  @override
  String get homeChallengeStartedSnack =>
      'চ্যালেঞ্জ শুরু হয়েছে — আপনার প্রথম দিনটি লগ করুন!';

  @override
  String get homeNavHome => 'হোম';

  @override
  String get homeNavProgress => 'অগ্রগতি';

  @override
  String get homeNavLeaderboard => 'লিডারবোর্ড';

  @override
  String get homeGreetingMorning => 'শুভ সকাল';

  @override
  String get homeGreetingAfternoon => 'শুভ অপরাহ্ণ';

  @override
  String get homeGreetingEvening => 'শুভ সন্ধ্যা';

  @override
  String get homeGreetingFallbackName => 'ওয়ারিয়র';

  @override
  String get inactiveChallengeTitle => 'Subh Warrior হতে প্রস্তুত?';

  @override
  String inactiveChallengeBody(int days) {
    final intl.NumberFormat daysNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String daysString = daysNumberFormat.format(days);

    return 'ফজরের নামায ও ফলপ্রসূ কাজের মাধ্যমে একটি শক্তিশালী সকালের রুটিন গড়তে আপনার $daysString দিনের চ্যালেঞ্জ শুরু করুন।';
  }

  @override
  String get inactiveChallengeStartButton => 'চ্যালেঞ্জ শুরু করুন';

  @override
  String get challengeCompleteTitleGoalMet =>
      'চ্যালেঞ্জ সম্পন্ন — চমৎকার করেছেন!';

  @override
  String get challengeCompleteTitleFallShort =>
      'চ্যালেঞ্জ সম্পন্ন — আপনি ভালো অগ্রগতি অর্জন করেছেন';

  @override
  String challengeCompleteBody(
      int qualifyingDays, int goal, int streak, int week) {
    final intl.NumberFormat qualifyingDaysNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String qualifyingDaysString =
        qualifyingDaysNumberFormat.format(qualifyingDays);
    final intl.NumberFormat goalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String goalString = goalNumberFormat.format(goal);
    final intl.NumberFormat streakNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String streakString = streakNumberFormat.format(streak);
    final intl.NumberFormat weekNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String weekString = weekNumberFormat.format(week);

    return 'আপনি $goalString টির মধ্যে $qualifyingDaysString টি যোগ্য দিন লগ করেছেন, সেরা স্ট্রিক $streakString এবং সপ্তাহ $weekString পর্যন্ত পৌঁছেছেন।';
  }

  @override
  String get challengeCompleteRestartButton => 'নতুন চ্যালেঞ্জ শুরু করুন';

  @override
  String get todayStatusTitle => 'আজকের অবস্থা';

  @override
  String get todayStatusChipQualifying => 'যোগ্য ✓';

  @override
  String get todayStatusChipLogged => 'লগ করা হয়েছে';

  @override
  String get todayStatusChipPending => 'বাকি আছে';

  @override
  String get todayStatusChipTimeUp => 'সময় শেষ';

  @override
  String get todayStatusFajrPrayer => 'ফজরের নামায';

  @override
  String get todayStatusFajrOnTime => 'সময়মতো';

  @override
  String get todayStatusFajrMissed => 'ছুটে গেছে';

  @override
  String get todayStatusWorkTime => 'কাজের সময়';

  @override
  String todayStatusMinutesWorked(int minutes) {
    final intl.NumberFormat minutesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    return '$minutesString মিনিট';
  }

  @override
  String get todayStatusWorkLabel => 'কাজ';

  @override
  String get todayStatusLogTodayButton => 'আজকের দিন লগ করুন';

  @override
  String todayStatusWindowClosed(String cutoffTime) {
    return 'লগ করার সময় শেষ ($cutoffTime-এর পরে)';
  }

  @override
  String get weeklyProgressTitle => 'সাপ্তাহিক অগ্রগতি';

  @override
  String weeklyProgressWeekLabel(int week) {
    final intl.NumberFormat weekNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String weekString = weekNumberFormat.format(week);

    return 'সপ্তাহ $weekString';
  }

  @override
  String weeklyProgressRatio(int progress, int target) {
    final intl.NumberFormat progressNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String progressString = progressNumberFormat.format(progress);
    final intl.NumberFormat targetNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String targetString = targetNumberFormat.format(target);

    return '$progressString/$targetString';
  }

  @override
  String get quickStatsDaysLeft => 'দিন বাকি';

  @override
  String get quickStatsGoalProgress => 'লক্ষ্যের অগ্রগতি';

  @override
  String quickStatsPercent(int percent) {
    final intl.NumberFormat percentNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String percentString = percentNumberFormat.format(percent);

    return '$percentString%';
  }

  @override
  String quickStatsGoalRatio(int count, int goal) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);
    final intl.NumberFormat goalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String goalString = goalNumberFormat.format(goal);

    return '$countString/$goalString';
  }

  @override
  String get quote1 =>
      '\"হে আল্লাহ, আমার উম্মতের জন্য তাদের ভোরবেলায় বরকত দান করুন।\" - মহানবী মুহাম্মদ ﷺ (আবু দাউদ, তিরমিযী)';

  @override
  String get quote2 =>
      '\"ফজরের পূর্বের দুই রাকাত নামায দুনিয়া ও তার মধ্যকার সবকিছুর চেয়ে উত্তম।\" - মহানবী মুহাম্মদ ﷺ (মুসলিম)';

  @override
  String get quote3 =>
      '\"যে ব্যক্তি জামাতে ফজরের নামায আদায় করে, সে যেন সারা রাত নামায পড়ল।\" - মহানবী মুহাম্মদ ﷺ (মুসলিম)';

  @override
  String get quote4 =>
      '\"আর ফজরের কুরআন পাঠ [প্রতিষ্ঠিত করো]। নিশ্চয়ই ফজরের কুরআন পাঠ সাক্ষ্যপ্রাপ্ত।\" - কুরআন ১৭:৭৮';

  @override
  String get quote5 =>
      '\"নিশ্চয়ই রাতের নামায অন্তরের জন্য সবচেয়ে কার্যকর এবং কথায় সবচেয়ে সঠিক।\" - কুরআন ৭৩:৬';

  @override
  String get quote6 =>
      '\"পাঁচটি জিনিসের আগে পাঁচটি জিনিসের সদ্ব্যবহার করো: বার্ধক্যের আগে যৌবন, অসুস্থতার আগে সুস্থতা, দারিদ্র্যের আগে সচ্ছলতা, ব্যস্ততার আগে অবসর এবং মৃত্যুর আগে জীবন।\" - মহানবী মুহাম্মদ ﷺ (আল-হাকিম)';

  @override
  String get quote7 =>
      '\"আল্লাহর কাছে সবচেয়ে প্রিয় আমল হলো যা নিয়মিত করা হয়, তা অল্প হলেও।\" - মহানবী মুহাম্মদ ﷺ (বুখারী ও মুসলিম)';

  @override
  String get quote8 =>
      '\"অতঃপর নামায শেষ হলে তোমরা পৃথিবীতে ছড়িয়ে পড়ো এবং আল্লাহর অনুগ্রহ সন্ধান করো।\" - কুরআন ৬২:১০';

  @override
  String get quote9 =>
      '\"দুটি নিয়ামত এমন আছে, যাতে অনেক মানুষ ক্ষতিগ্রস্ত: সুস্থতা ও অবসর।\" - মহানবী মুহাম্মদ ﷺ (বুখারী)';

  @override
  String get quote10 =>
      '\"যে ব্যক্তি সকালে নিজ ঘরে নিরাপদে, সুস্থ শরীরে এবং সেই দিনের খাবারসহ জাগ্রত হয়, তাকে যেন সমগ্র দুনিয়া দান করা হলো।\" - মহানবী মুহাম্মদ ﷺ (তিরমিযী)';

  @override
  String get prayerCardErrorMessage => 'নামাযের সময় লোড করা যায়নি';

  @override
  String get prayerCardTitle => 'ফজরের নামায';

  @override
  String get prayerCardNowBadge => 'এখন';

  @override
  String get prayerCardToday => 'আজ';

  @override
  String get prayerCardTomorrow => 'আগামীকাল';

  @override
  String get prayerCardNextFajrIn => 'পরবর্তী ফজর';

  @override
  String prayerCardCountdownValue(int hours, int minutes) {
    final intl.NumberFormat hoursNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String hoursString = hoursNumberFormat.format(hours);
    final intl.NumberFormat minutesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    return '$hoursStringঘ $minutesStringমি';
  }

  @override
  String prayerCardCountdownValueWithSeconds(
      int hours, int minutes, int seconds) {
    final intl.NumberFormat hoursNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String hoursString = hoursNumberFormat.format(hours);
    final intl.NumberFormat minutesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);
    final intl.NumberFormat secondsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String secondsString = secondsNumberFormat.format(seconds);

    return '$hoursStringঘ $minutesStringমি $secondsStringসে';
  }

  @override
  String get prayerCardCountdownUnknown => 'অজানা';

  @override
  String get prayerCardSunrise => 'সূর্যোদয়';

  @override
  String get prayerCardDhuhr => 'যোহর';

  @override
  String get prayerCardAsr => 'আসর';

  @override
  String get prayerCardMaghrib => 'মাগরিব';

  @override
  String get prayerCardIsha => 'এশা';

  @override
  String get streakCardDayStreak => 'দিনের স্ট্রিক';

  @override
  String get streakCardDaysStreak => 'দিনের স্ট্রিক';

  @override
  String get streakCardQualifyingDays => 'যোগ্য দিন';

  @override
  String get streakCardGoalDenominator => '/16';

  @override
  String get streakCardMsgLegendary => 'কিংবদন্তি!';

  @override
  String get streakCardMsgUnstoppable => 'অপ্রতিরোধ্য!';

  @override
  String get streakCardMsgOnFire => 'দুর্দান্ত গতি!';

  @override
  String get streakCardMsgKeepGoing => 'চালিয়ে যান!';

  @override
  String get errorViewDefaultMessage => 'কিছু একটা ভুল হয়েছে';

  @override
  String get errorViewRetryButton => 'আবার চেষ্টা করুন';

  @override
  String get commonOr => 'অথবা';

  @override
  String get onboardingWelcomeTitle => 'স্বাগতম\nSubh Warrior-এ';

  @override
  String get onboardingWelcomeSubtitle =>
      'ফজরের নামায ও মনোযোগী কাজের শক্তিতে আপনার সকালগুলো বদলে দিন';

  @override
  String get onboardingFeatureFajrTracking => 'ফজরের নামায ট্র্যাকিং';

  @override
  String get onboardingFeatureProductiveWork => '৬০+ মিনিট ফলপ্রসূ কাজ';

  @override
  String get onboardingFeatureChallengeDuration => '২৮ দিনের চ্যালেঞ্জ';

  @override
  String get onboardingFeatureAchieveDays => '১৬+ দিন অর্জন করুন';

  @override
  String get onboardingRulesTitle => 'চ্যালেঞ্জের নিয়মাবলি';

  @override
  String get onboardingRuleWakeUpTitle => 'জাগুন';

  @override
  String get onboardingRuleWakeUpDesc =>
      'ফজরের সময় বা তার আগে জাগুন এবং জেগে থাকুন';

  @override
  String get onboardingRulePrayTitle => 'নামায পড়ুন';

  @override
  String get onboardingRulePrayDesc =>
      'নির্ধারিত সময়ের মধ্যে ফজরের নামায আদায় করুন';

  @override
  String get onboardingRuleWorkTitle => 'কাজ করুন';

  @override
  String get onboardingRuleWorkDesc => '৬০+ মিনিট ফলপ্রসূ কাজ সম্পন্ন করুন';

  @override
  String get onboardingRuleLogTitle => 'লগ করুন';

  @override
  String onboardingRuleLogDesc(String cutoffTime) {
    return '$cutoffTime-এর আগে আপনার দিনটি জমা দিন (শুধু কর্মদিবসে)';
  }

  @override
  String get onboardingRulesGoal => '৪ সপ্তাহে ১৬+ যোগ্য দিন সম্পন্ন করুন';

  @override
  String get onboardingLocationTitle => 'আপনার অবস্থান নির্ধারণ করুন';

  @override
  String get onboardingLocationSubtitle =>
      'সঠিক নামাযের সময় হিসাব করতে এটি প্রয়োজন';

  @override
  String get onboardingLocationFieldLabel => 'শহর/অবস্থান';

  @override
  String get onboardingLocationFieldHint => 'যেমন, ঢাকা, বাংলাদেশ';

  @override
  String get onboardingGettingLocation => 'অবস্থান নেওয়া হচ্ছে...';

  @override
  String get onboardingUseCurrentLocation => 'বর্তমান অবস্থান ব্যবহার করুন';

  @override
  String get onboardingReadyTitle => 'আপনি প্রস্তুত!';

  @override
  String onboardingWelcomeUser(String name) {
    return 'স্বাগতম, $name!';
  }

  @override
  String get onboardingStartJourneyButton => 'আপনার যাত্রা শুরু করুন';

  @override
  String get onboardingBackButton => 'পেছনে';

  @override
  String get onboardingNextButton => 'পরবর্তী';

  @override
  String get onboardingSetLocationPrompt =>
      'অনুগ্রহ করে আপনার অবস্থান নির্ধারণ করুন';

  @override
  String get onboardingLocationNotFound =>
      'ওই অবস্থানটি খুঁজে পাওয়া যায়নি। অনুগ্রহ করে বানান যাচাই করুন।';

  @override
  String onboardingErrorFindingLocation(String error) {
    return 'অবস্থান খুঁজতে সমস্যা হয়েছে: $error';
  }

  @override
  String get onboardingCoordinatesNotFound =>
      'ওই অবস্থানের স্থানাঙ্ক খুঁজে পাওয়া যায়নি।';

  @override
  String get onboardingLocationServicesDisabled =>
      'লোকেশন সার্ভিস বন্ধ আছে। অনুগ্রহ করে সেটিংসে গিয়ে চালু করুন।';

  @override
  String get onboardingLocationPermissionDenied =>
      'লোকেশন অনুমতি প্রত্যাখ্যান করা হয়েছে';

  @override
  String get onboardingLocationPermissionDeniedForever =>
      'লোকেশন অনুমতি স্থায়ীভাবে প্রত্যাখ্যান করা হয়েছে। অনুগ্রহ করে অ্যাপ সেটিংসে গিয়ে চালু করুন।';

  @override
  String get onboardingSettingsAction => 'সেটিংস';

  @override
  String get onboardingUnknownLocality => 'অজানা';

  @override
  String onboardingLocationSetCoords(String latitude, String longitude) {
    return 'অবস্থান নির্ধারিত ($latitude, $longitude)';
  }

  @override
  String onboardingErrorGettingLocation(String error) {
    return 'অবস্থান নিতে সমস্যা হয়েছে: $error';
  }

  @override
  String get authCreateAccountTitle => 'আপনার অ্যাকাউন্ট তৈরি করুন';

  @override
  String get authWelcomeBackTitle => 'আবারও স্বাগতম';

  @override
  String get authUsernameLabel => 'ইউজারনেম';

  @override
  String get authEmailLabel => 'ইমেইল';

  @override
  String get authPasswordLabel => 'পাসওয়ার্ড';

  @override
  String get authForgotPassword => 'পাসওয়ার্ড ভুলে গেছেন?';

  @override
  String get authCreateAccountButton => 'অ্যাকাউন্ট তৈরি করুন';

  @override
  String get authLogInButton => 'লগ ইন';

  @override
  String get authToggleToLogin => 'আগে থেকেই অ্যাকাউন্ট আছে? লগ ইন করুন';

  @override
  String get authToggleToRegister => 'অ্যাকাউন্ট নেই? নিবন্ধন করুন';

  @override
  String get authContinueWithGoogle => 'Google দিয়ে চালিয়ে যান';

  @override
  String get authErrorEmailInUse =>
      'এই ইমেইলটি ইতিমধ্যে নিবন্ধিত। পরিবর্তে লগ ইন করার চেষ্টা করুন।';

  @override
  String get authErrorInvalidEmail => 'এই ইমেইল ঠিকানাটি সঠিক নয়।';

  @override
  String get authErrorWrongPassword => 'ইমেইল বা পাসওয়ার্ড ভুল।';

  @override
  String get authErrorUserNotFound =>
      'এই ইমেইলের জন্য কোনো অ্যাকাউন্ট পাওয়া যায়নি।';

  @override
  String get authErrorUserDisabled => 'এই অ্যাকাউন্টটি নিষ্ক্রিয় করা হয়েছে।';

  @override
  String get authErrorWeakPassword =>
      'পাসওয়ার্ডটি খুব দুর্বল (কমপক্ষে ৬ অক্ষর)।';

  @override
  String get authErrorNetworkRequestFailed =>
      'নেটওয়ার্ক সমস্যা। আপনার সংযোগ যাচাই করে আবার চেষ্টা করুন।';

  @override
  String get authErrorTooManyRequests =>
      'অনেকবার চেষ্টা করা হয়েছে। অনুগ্রহ করে পরে আবার চেষ্টা করুন।';

  @override
  String get authErrorGeneric =>
      'প্রমাণীকরণ ব্যর্থ হয়েছে। অনুগ্রহ করে আবার চেষ্টা করুন।';

  @override
  String get authUsernameTaken =>
      'এই ইউজারনেমটি ইতিমধ্যে নেওয়া হয়েছে। অনুগ্রহ করে অন্যটি বেছে নিন।';

  @override
  String get authForgotPasswordEnterEmail =>
      'প্রথমে উপরে আপনার ইমেইল লিখুন, তারপর \"পাসওয়ার্ড ভুলে গেছেন?\"-এ চাপ দিন।';

  @override
  String authPasswordResetSent(String email) {
    return '$email-এ পাসওয়ার্ড রিসেট ইমেইল পাঠানো হয়েছে।';
  }

  @override
  String commonMinutesShort(int minutes) {
    final intl.NumberFormat minutesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    return '$minutesString মিনিট';
  }

  @override
  String get settingsTitle => 'সেটিংস';

  @override
  String get settingsSaveTooltip => 'সেটিংস সংরক্ষণ করুন';

  @override
  String get settingsProfileTitle => 'প্রোফাইল';

  @override
  String get settingsNameLabel => 'আপনার নাম';

  @override
  String get settingsNameHint => 'আপনার নাম লিখুন';

  @override
  String get settingsStatTotalDays => 'মোট দিন';

  @override
  String get settingsStatCurrentStreak => 'বর্তমান স্ট্রিক';

  @override
  String get settingsStatChallengeWeek => 'চ্যালেঞ্জ সপ্তাহ';

  @override
  String settingsChallengeWeekRatio(int week, int totalWeeks) {
    final intl.NumberFormat weekNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String weekString = weekNumberFormat.format(week);
    final intl.NumberFormat totalWeeksNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalWeeksString = totalWeeksNumberFormat.format(totalWeeks);

    return '$weekString/$totalWeeksString';
  }

  @override
  String get settingsLocationTitle => 'অবস্থান';

  @override
  String settingsCoordinates(String latitude, String longitude) {
    return 'স্থানাঙ্ক: $latitude, $longitude';
  }

  @override
  String get settingsPrayerSettingsTitle => 'নামাযের সেটিংস';

  @override
  String get settingsCalculationMethodLabel => 'গণনা পদ্ধতি';

  @override
  String get settingsJuristicMethodTitle => 'ফিকহি মাযহাব';

  @override
  String get settingsJuristicHanafi => 'হানাফি (আসরের সময় পরে)';

  @override
  String get settingsJuristicStandard =>
      'স্ট্যান্ডার্ড (শাফেয়ি, মালেকি, হাম্বলি)';

  @override
  String get settingsHanafiInfo =>
      'হানাফি পদ্ধতিতে ছায়া বস্তুর দৈর্ঘ্যের দ্বিগুণ হলে আসরের সময় ধরা হয়';

  @override
  String get settingsNotificationsTitle => 'নোটিফিকেশন';

  @override
  String get settingsEnableNotifications => 'নোটিফিকেশন চালু করুন';

  @override
  String get settingsEnableNotificationsSubtitle => 'রিমাইন্ডার ও আপডেট পান';

  @override
  String get settingsFajrReminderTitle => 'ফজরের নামাযের রিমাইন্ডার';

  @override
  String settingsFajrReminderSubtitle(int minutes) {
    final intl.NumberFormat minutesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    return 'ফজরের $minutesString মিনিট আগে জানান';
  }

  @override
  String get settingsRemindMe => 'আমাকে মনে করিয়ে দিন';

  @override
  String get settingsBeforeFajr => 'ফজরের আগে';

  @override
  String get settingsLoggingReminderTitle => 'দৈনিক লগ রিমাইন্ডার';

  @override
  String settingsLoggingReminderSubtitle(String time) {
    return 'দিন লগ করতে $time-এ মনে করিয়ে দিন';
  }

  @override
  String get settingsAppearanceTitle => 'চেহারা';

  @override
  String get settingsLanguageLabel => 'ভাষা';

  @override
  String get settingsLanguageSystem => 'সিস্টেম';

  @override
  String get settingsThemeLabel => 'থিম';

  @override
  String get settingsThemeSystem => 'সিস্টেম';

  @override
  String get settingsThemeLight => 'লাইট';

  @override
  String get settingsThemeDark => 'ডার্ক';

  @override
  String get settingsTimeFormatLabel => 'সময়ের ফরম্যাট';

  @override
  String get settingsTimeFormat12 => '১২ ঘণ্টা';

  @override
  String get settingsTimeFormat24 => '২৪ ঘণ্টা';

  @override
  String get settingsChallengeTitle => 'চ্যালেঞ্জ';

  @override
  String get settingsChallengeStarted => 'চ্যালেঞ্জ শুরু হয়েছে';

  @override
  String get settingsChallengeNotStarted => 'শুরু হয়নি';

  @override
  String get settingsEndChallenge => 'চ্যালেঞ্জ শেষ করুন';

  @override
  String get settingsAboutTitle => 'পরিচিতি';

  @override
  String get settingsAppVersion => 'অ্যাপ ভার্সন';

  @override
  String get settingsGuestAccount => 'অতিথি অ্যাকাউন্ট';

  @override
  String get settingsSignedIn => 'সাইন ইন করা আছে';

  @override
  String get settingsLinkGooglePrompt =>
      'Google দিয়ে আপনার অগ্রগতি ব্যাকআপ করতে চাপ দিন';

  @override
  String get settingsProgressSavedLocally => 'অগ্রগতি এই ডিভাইসে সংরক্ষিত আছে';

  @override
  String get settingsSynced => 'সিঙ্ক করা হয়েছে';

  @override
  String get settingsGuidelines => 'নির্দেশিকা';

  @override
  String get settingsSendFeedback => 'মতামত পাঠান';

  @override
  String get settingsShareApp => 'অ্যাপ শেয়ার করুন';

  @override
  String get settingsSignedInWithGoogle => 'Google দিয়ে সাইন ইন করা হয়েছে।';

  @override
  String get settingsFeedbackSubject => 'Subh Warrior মতামত';

  @override
  String settingsFeedbackAppVersion(String version, String build) {
    return 'অ্যাপ ভার্সন: $version ($build)';
  }

  @override
  String settingsNoEmailApp(String email) {
    return 'কোনো ইমেইল অ্যাপ পাওয়া যায়নি। আমাদের সাথে যোগাযোগ করুন: $email';
  }

  @override
  String get settingsShareMessage =>
      'Subh Warrior দিয়ে শক্তিশালী সকাল গড়ুন — ফজরে জাগুন, ফলপ্রসূ থাকুন এবং ২৮ দিনের চ্যালেঞ্জ সম্পন্ন করুন। 🌅';

  @override
  String get settingsEnterNamePrompt => 'অনুগ্রহ করে আপনার নাম লিখুন';

  @override
  String get settingsSavedSuccess => 'সেটিংস সফলভাবে সংরক্ষিত হয়েছে';

  @override
  String get settingsEndChallengeDialogTitle => 'চ্যালেঞ্জ শেষ করবেন?';

  @override
  String get settingsEndChallengeDialogContent =>
      'আপনি কি নিশ্চিত যে চ্যালেঞ্জটি শেষ করতে চান? আপনার অগ্রগতি সংরক্ষিত থাকবে, তবে চ্যালেঞ্জটি অসম্পূর্ণ হিসেবে চিহ্নিত হবে।';

  @override
  String get settingsCancel => 'বাতিল';

  @override
  String get settingsGuidelinesDialogTitle => 'চ্যালেঞ্জ নির্দেশিকা';

  @override
  String settingsGuidelinesContent(String cutoffTime) {
    return '🌅 SUBH WARRIOR চ্যালেঞ্জ\n\n✓ ফজরের সময় বা তার আগে জাগুন\n✓ জেগে ও সজাগ থাকুন\n✓ নির্ধারিত সময়ের মধ্যে ফজরের নামায পড়ুন\n✓ ৬০+ মিনিট ফলপ্রসূ কাজ সম্পন্ন করুন\n✓ প্রতিদিন $cutoffTime-এর আগে লগ করুন\n✓ ৪ সপ্তাহে ১৬+ দিন সম্পন্ন করুন\n✓ প্রতি সপ্তাহে কমপক্ষে ৪টি যোগ্য দিন\n\nযোগ্য কাজ:\n• গভীর মনোযোগের কাজ\n• কৌশলগত পরিকল্পনা\n• শেখা/দক্ষতা উন্নয়ন\n• সৃজনশীল প্রকল্প\n• গুরুত্বপূর্ণ যোগাযোগ\n\nঅযোগ্য:\n• নিষ্ক্রিয় কনটেন্ট ভোগ\n• গতানুগতিক প্রশাসনিক কাজ\n• সোশ্যাল মিডিয়া\n\nদ্রষ্টব্য: সাপ্তাহিক ছুটির দিন যোগ্য দিন হিসেবে গণ্য হয় না।';
  }

  @override
  String get settingsGotIt => 'বুঝেছি!';

  @override
  String get progressNoChallenge =>
      'অগ্রগতি ট্র্যাক করতে একটি চ্যালেঞ্জ শুরু করুন';

  @override
  String get progressChallengeProgress => 'চ্যালেঞ্জের অগ্রগতি';

  @override
  String get progressStatCompleted => 'সম্পন্ন';

  @override
  String get progressStatRemaining => 'বাকি';

  @override
  String get progressStatStreak => 'স্ট্রিক';

  @override
  String get progressWeeklyPerformance => 'সাপ্তাহিক পারফরম্যান্স';

  @override
  String progressWeekAxisLabel(int week) {
    final intl.NumberFormat weekNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String weekString = weekNumberFormat.format(week);

    return 'সপ্তাহ $weekString';
  }

  @override
  String get progressNoDaysLogged => 'এখনো কোনো দিন লগ করা হয়নি';

  @override
  String get progressRecentLogs => 'সাম্প্রতিক লগ';

  @override
  String get progressLogFajrPrayed => '✓ ফজর';

  @override
  String get progressLogFajrMissed => '✗ ফজর';

  @override
  String progressLogSubtitle(String fajrStatus, int minutes) {
    final intl.NumberFormat minutesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    return '$fajrStatus • $minutesString মিনিট কাজ';
  }

  @override
  String get logDayWeekendTitle => 'সাপ্তাহিক ছুটির দিন';

  @override
  String get logDayWeekendBody =>
      'সাপ্তাহিক ছুটির দিন Subh Warrior চ্যালেঞ্জে গণ্য হয় না।\n\nপ্রতি সপ্তাহে ৪টি যোগ্য কর্মদিবস প্রয়োজন।';

  @override
  String get logDayGoBack => 'ফিরে যান';

  @override
  String get logDayTimeUpTitle => 'সময় শেষ!';

  @override
  String logDayTimeUpBody(String cutoffTime) {
    return 'দৈনিক লগ $cutoffTime-এর আগে জমা দিতে হবে।';
  }

  @override
  String logDayTimeRemaining(int hours, int minutes) {
    final intl.NumberFormat hoursNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String hoursString = hoursNumberFormat.format(hours);
    final intl.NumberFormat minutesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    return 'লগ করার জন্য বাকি সময়: $hoursString ঘণ্টা $minutesString মিনিট';
  }

  @override
  String get logDayTodaysFajr => 'আজকের ফজর';

  @override
  String get logDayPrayerTimeNow => 'এখন নামাযের সময়';

  @override
  String get logDayLoading => 'লোড হচ্ছে...';

  @override
  String logDaySunrise(String time) {
    return 'সূর্যোদয়: $time';
  }

  @override
  String get logDayWakeUpTitle => 'জাগরণের শর্তাবলি';

  @override
  String get logDayWokeUpTitle => 'ফজরের সময় বা তার আগে জেগেছি';

  @override
  String get logDayWokeUpSubtitle => 'শুধু সাময়িক জাগরণ নয়';

  @override
  String get logDayStayedAwake => 'জেগে ও সজাগ ছিলাম';

  @override
  String get logDayStayedAwakeSubtitle => 'নামাযের পরেও জাগ্রত ছিলাম';

  @override
  String get logDayPrayedFajrOnTime => 'সময়মতো ফজরের নামায পড়েছি';

  @override
  String get logDayWithinWindow => 'নামাযের নির্ধারিত সময়ের মধ্যে';

  @override
  String get logDayPrayedAtMasjid => 'মসজিদে নামায পড়েছি';

  @override
  String get logDayMasjidSubtitle => 'অত্যন্ত উৎসাহিত (আবশ্যক নয়)';

  @override
  String get logDayProductiveWork => 'ফলপ্রসূ কাজ';

  @override
  String get logDayTypeOfWork => 'কাজের ধরন';

  @override
  String get logDayWorkTypeDeepWork => 'গভীর মনোযোগের কাজ';

  @override
  String get logDayWorkTypeStrategicPlanning => 'কৌশলগত পরিকল্পনা';

  @override
  String get logDayWorkTypeLearning => 'শেখা/দক্ষতা উন্নয়ন';

  @override
  String get logDayWorkTypeCreativeProjects => 'সৃজনশীল প্রকল্প';

  @override
  String get logDayWorkTypeImportantCommunication => 'গুরুত্বপূর্ণ যোগাযোগ';

  @override
  String get logDayWorkTypePassiveConsumption => '❌ নিষ্ক্রিয় কনটেন্ট ভোগ';

  @override
  String get logDayWorkTypeRoutineAdmin => '❌ গতানুগতিক প্রশাসনিক কাজ';

  @override
  String get logDayWorkTypeSocialMedia => '❌ সোশ্যাল মিডিয়া';

  @override
  String get logDayWorkNotQualify => 'এই ধরনের কাজ যোগ্য নয়';

  @override
  String logDayMinutesFocused(int minutes) {
    final intl.NumberFormat minutesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    return 'মনোযোগী কাজের মিনিট: $minutesString';
  }

  @override
  String logDayMinimumMinutes(int minutes) {
    final intl.NumberFormat minutesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    return 'যোগ্যতার জন্য কমপক্ষে $minutesString মিনিট প্রয়োজন';
  }

  @override
  String get logDayDescribeWorkLabel => 'আপনার কাজের বর্ণনা দিন';

  @override
  String get logDayDescribeWorkHint =>
      'আপনি কোন নির্দিষ্ট কাজগুলো সম্পন্ন করেছেন?';

  @override
  String get logDayDescribeWorkError => 'অনুগ্রহ করে আপনার কাজের বর্ণনা দিন';

  @override
  String get logDayMoreDetailError => 'অনুগ্রহ করে আরও বিস্তারিত লিখুন';

  @override
  String get logDayReflectionTitle => 'অনুভূতি (ঐচ্ছিক)';

  @override
  String get logDayReflectionHint =>
      'ভোরবেলার কাজ কেমন লাগল?\nআপনি কী অর্জন করলেন?\nকোনো উপলব্ধি বা নতুন ভাবনা?';

  @override
  String get logDayQualifyingDay => 'যোগ্য দিন!';

  @override
  String get logDayNotQualifyingYet => 'এখনো যোগ্য নয়';

  @override
  String get logDayReqAwake => 'ফজরের সময় বা তার আগে জাগ্রত';

  @override
  String logDayReqMinutesWork(int minutes) {
    final intl.NumberFormat minutesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    return '$minutesString+ মিনিট কাজ';
  }

  @override
  String get logDayReqQualifyingWorkType => 'যোগ্য ধরনের কাজ';

  @override
  String get logDayBonusMasjid => 'বোনাস: মসজিদে নামায পড়েছেন! 🌟';

  @override
  String get logDaySubmitButton => 'লগ জমা দিন';

  @override
  String get logDayMustBeAwake => 'ফজরের জন্য আপনাকে জাগ্রত ও সজাগ থাকতে হবে';

  @override
  String get logDayExceptional => 'অসাধারণ!';

  @override
  String get logDayExcellent => 'চমৎকার!';

  @override
  String get logDayDayLogged => 'দিন লগ হয়েছে';

  @override
  String get logDayMasjidSuccessContent =>
      'দুর্দান্ত! আপনি মসজিদে নামায পড়েছেন এবং সকালের কাজও সম্পন্ন করেছেন। প্রকৃত Subh Warrior-এর চেতনা! 🌟';

  @override
  String get logDayQualifyingSuccessContent =>
      'আপনি একটি যোগ্য দিন অর্জন করেছেন! এভাবেই চালিয়ে যান!';

  @override
  String get logDayLoggedContent =>
      'দিনটি সফলভাবে লগ হয়েছে। শর্তগুলো দেখে নিন এবং আগামীকাল আবার চেষ্টা করুন!';

  @override
  String get logDayContinue => 'চালিয়ে যান';

  @override
  String logDayAfterCutoff(String cutoffTime) {
    return 'লগ করার সময় শেষ — $cutoffTime-এর আগে লগ করুন।';
  }

  @override
  String get logDayWeekendError =>
      'সাপ্তাহিক ছুটির দিন চ্যালেঞ্জে গণ্য হয় না।';

  @override
  String get logDayAlreadyLogged => 'আপনি আজকের দিনটি ইতিমধ্যে লগ করেছেন।';

  @override
  String get logDayNotesTooLong =>
      'আপনার নোট খুব দীর্ঘ — অনুগ্রহ করে সংক্ষিপ্ত করুন।';

  @override
  String get leaderboardTabGlobal => 'বৈশ্বিক';

  @override
  String get leaderboardTabFriends => 'বন্ধুরা';

  @override
  String get leaderboardTabLocal => 'স্থানীয়';

  @override
  String get leaderboardFriendsComingSoon => 'বন্ধুদের লিডারবোর্ড শীঘ্রই আসছে!';

  @override
  String get leaderboardFriendsSubtitle =>
      'একসাথে প্রতিযোগিতা করতে বন্ধুদের সাথে যুক্ত হন';

  @override
  String get leaderboardSetLocationTitle =>
      'স্থানীয় ওয়ারিয়রদের দেখতে আপনার অবস্থান নির্ধারণ করুন';

  @override
  String get leaderboardSetLocationButton => 'অবস্থান নির্ধারণ করুন';

  @override
  String get leaderboardLoadError => 'লিডারবোর্ড লোড করতে সমস্যা হয়েছে';

  @override
  String get leaderboardYouBadge => 'আপনি';

  @override
  String leaderboardDaysCount(int days) {
    final intl.NumberFormat daysNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String daysString = daysNumberFormat.format(days);

    return '$daysString দিন';
  }

  @override
  String leaderboardStreakCount(int streak) {
    final intl.NumberFormat streakNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String streakString = streakNumberFormat.format(streak);

    return '$streakString স্ট্রিক';
  }

  @override
  String get leaderboardEmptyLocalTitle =>
      'আপনার এলাকায় এখনো কোনো ওয়ারিয়র নেই!';

  @override
  String get leaderboardEmptyGlobalTitle => 'কোনো তথ্য নেই';

  @override
  String get leaderboardEmptyLocalSubtitle =>
      'চ্যালেঞ্জ শুরু করা প্রথম ব্যক্তি হোন';

  @override
  String get leaderboardEmptyGlobalSubtitle =>
      'এখানে দেখা দিতে আপনার চ্যালেঞ্জ শুরু করুন';

  @override
  String get dayDetailQualifying => 'যোগ্য দিন';

  @override
  String get dayDetailNonQualifying => 'অযোগ্য দিন';

  @override
  String get dayDetailWorkDuration => 'কাজের সময়কাল';

  @override
  String get dayDetailWorkDescription => 'কাজের বর্ণনা';

  @override
  String get dayDetailNoDetails => 'এই দিনের জন্য কোনো বিবরণ লগ করা হয়নি।';

  @override
  String get dayDetailReflection => 'অনুভূতি';

  @override
  String notifFajrTitle(int minutes) {
    final intl.NumberFormat minutesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    return '🕌 ফজর $minutesString মিনিট পরে';
  }

  @override
  String get notifFajrBody => 'ফজরের নামাযের জন্য জেগে ওঠার সময় হয়েছে!';

  @override
  String get notifLogTitle => '⏰ আপনার দিন লগ করার সময়!';

  @override
  String get notifLogBody => 'সকালের রুটিন লগ করতে আর ৩০ মিনিট বাকি';

  @override
  String get notifChannelGeneralName => 'সাধারণ নোটিফিকেশন';

  @override
  String get notifChannelGeneralDesc => 'অ্যাপ নোটিফিকেশন';

  @override
  String get notifChannelScheduledName => 'নির্ধারিত নোটিফিকেশন';

  @override
  String get notifChannelScheduledDesc =>
      'নির্ধারিত নামায ও চ্যালেঞ্জ রিমাইন্ডার';

  @override
  String get notifPermTitle => 'নোটিফিকেশন চালু করুন';

  @override
  String get notifPermContent =>
      'আপনার Subh Warrior চ্যালেঞ্জে সঠিক পথে থাকতে ফজরের নামায ও দৈনিক লগের রিমাইন্ডার পান।';

  @override
  String get notifPermNotNow => 'এখন নয়';

  @override
  String get notifPermEnable => 'চালু করুন';

  @override
  String get shareCardTitle => 'সুবহ ওয়ারিয়র';

  @override
  String get shareCardStreakLabel => 'দিনের স্ট্রিক';

  @override
  String get shareCardQualifyingLabel => 'যোগ্য দিন';

  @override
  String shareCardWeekLabel(int week) {
    final intl.NumberFormat weekNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String weekString = weekNumberFormat.format(week);

    return '৪ সপ্তাহের মধ্যে $weekStringতম সপ্তাহ';
  }

  @override
  String get shareCardFooter => '২৮ দিনের ফজর চ্যালেঞ্জে আমার সাথে যোগ দিন!';

  @override
  String get shareCardButton => 'শেয়ার করুন';

  @override
  String get shareCardSheetTitle => 'আপনার অগ্রগতি শেয়ার করুন';

  @override
  String get a11yOpenSettings => 'সেটিংস খুলুন';

  @override
  String get a11yShowPassword => 'পাসওয়ার্ড দেখান';

  @override
  String get a11yHidePassword => 'পাসওয়ার্ড লুকান';

  @override
  String get a11yStreakDormant => 'কোনো সক্রিয় স্ট্রিক নেই';

  @override
  String get a11yStreakBuilding => 'স্ট্রিক গড়ে উঠছে';

  @override
  String get a11yStreakOnFire => 'স্ট্রিক দুর্দান্ত গতিতে';

  @override
  String get a11yStreakStrong => 'শক্তিশালী স্ট্রিক';

  @override
  String get a11yStreakSoaring => 'স্ট্রিক ঊর্ধ্বমুখী';

  @override
  String get a11yStreakLegendary => 'কিংবদন্তি স্ট্রিক';

  @override
  String get a11yGoalTrophy => 'লক্ষ্যের মাইলফলক অর্জিত';

  @override
  String get a11yFirstPlace => 'প্রথম স্থান';

  @override
  String get a11ySecondPlace => 'দ্বিতীয় স্থান';

  @override
  String get a11yThirdPlace => 'তৃতীয় স্থান';

  @override
  String get a11yMinutesWorkedSlider => 'মনোযোগী কাজের মিনিট';

  @override
  String get a11yQualifyingDay => 'যোগ্য দিন';

  @override
  String get a11yNonQualifyingDay => 'অযোগ্য দিন';

  @override
  String get a11yRequirementMet => 'শর্ত পূরণ হয়েছে';

  @override
  String get a11yRequirementNotMet => 'শর্ত পূরণ হয়নি';

  @override
  String get a11yShareStreak => 'আপনার স্ট্রিক শেয়ার করুন';
}
