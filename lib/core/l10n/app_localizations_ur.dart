// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class AppLocalizationsUr extends AppLocalizations {
  AppLocalizationsUr([String locale = 'ur']) : super(locale);

  @override
  String get appTitle => 'Subh Warrior چیلنج';

  @override
  String get splashTitle => 'Subh Warrior';

  @override
  String get homeAppBarTitle => 'Subh Warrior';

  @override
  String get homeChallengeStartedSnack =>
      'چیلنج شروع ہو گیا — اپنا پہلا دن لاگ کریں!';

  @override
  String get homeNavHome => 'ہوم';

  @override
  String get homeNavProgress => 'پیش رفت';

  @override
  String get homeNavLeaderboard => 'لیڈر بورڈ';

  @override
  String get homeGreetingMorning => 'صبح بخیر';

  @override
  String get homeGreetingAfternoon => 'دوپہر بخیر';

  @override
  String get homeGreetingEvening => 'شام بخیر';

  @override
  String get homeGreetingFallbackName => 'واریئر';

  @override
  String get inactiveChallengeTitle => 'Subh Warrior بننے کے لیے تیار ہیں؟';

  @override
  String inactiveChallengeBody(int days) {
    final intl.NumberFormat daysNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String daysString = daysNumberFormat.format(days);

    return 'فجر کی نماز اور نتیجہ خیز کام کے ساتھ ایک مضبوط صبح کا معمول بنانے کے لیے اپنا $daysString دن کا چیلنج شروع کریں۔';
  }

  @override
  String get inactiveChallengeStartButton => 'چیلنج شروع کریں';

  @override
  String get todayStatusTitle => 'آج کی صورتحال';

  @override
  String get todayStatusChipQualifying => 'کوالیفائنگ ✓';

  @override
  String get todayStatusChipLogged => 'لاگ ہو گیا';

  @override
  String get todayStatusChipPending => 'زیر التوا';

  @override
  String get todayStatusChipTimeUp => 'وقت ختم';

  @override
  String get todayStatusFajrPrayer => 'نمازِ فجر';

  @override
  String get todayStatusFajrOnTime => 'وقت پر';

  @override
  String get todayStatusFajrMissed => 'چھوٹ گئی';

  @override
  String get todayStatusWorkTime => 'کام کا وقت';

  @override
  String todayStatusMinutesWorked(int minutes) {
    final intl.NumberFormat minutesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    return '$minutesString منٹ';
  }

  @override
  String get todayStatusWorkLabel => 'کام';

  @override
  String get todayStatusLogTodayButton => 'آج کا دن لاگ کریں';

  @override
  String todayStatusWindowClosed(String cutoffTime) {
    return 'لاگ کرنے کا وقت ختم ہو گیا ($cutoffTime کے بعد)';
  }

  @override
  String get weeklyProgressTitle => 'ہفتہ وار پیش رفت';

  @override
  String weeklyProgressWeekLabel(int week) {
    final intl.NumberFormat weekNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String weekString = weekNumberFormat.format(week);

    return 'ہفتہ $weekString';
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
  String get quickStatsDaysLeft => 'باقی دن';

  @override
  String get quickStatsGoalProgress => 'ہدف کی پیش رفت';

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
      '\"اے اللہ! میری امت کے لیے اس کی صبح کے اوقات میں برکت عطا فرما۔\" - نبی کریم ﷺ (ابو داؤد، ترمذی)';

  @override
  String get quote2 =>
      '\"فجر سے پہلے کی دو رکعتیں دنیا اور اس کی ہر چیز سے بہتر ہیں۔\" - نبی کریم ﷺ (مسلم)';

  @override
  String get quote3 =>
      '\"جس نے فجر کی نماز باجماعت ادا کی، گویا اس نے پوری رات قیام کیا۔\" - نبی کریم ﷺ (مسلم)';

  @override
  String get quote4 =>
      '\"اور فجر کے وقت قرآن پڑھا کرو، بے شک فجر کی قراءت پر فرشتے گواہ ہوتے ہیں۔\" - قرآن ۱۷:۷۸';

  @override
  String get quote5 =>
      '\"بے شک رات کا اٹھنا نفس کو خوب کچلتا ہے اور بات زیادہ درست نکلتی ہے۔\" - قرآن ۷۳:۶';

  @override
  String get quote6 =>
      '\"پانچ چیزوں کو پانچ سے پہلے غنیمت جانو: جوانی کو بڑھاپے سے پہلے، صحت کو بیماری سے پہلے، مال کو تنگ دستی سے پہلے، فراغت کو مصروفیت سے پہلے، اور زندگی کو موت سے پہلے۔\" - نبی کریم ﷺ (الحاکم)';

  @override
  String get quote7 =>
      '\"اللہ کے نزدیک سب سے محبوب عمل وہ ہے جو ہمیشہ کیا جائے، خواہ تھوڑا ہی ہو۔\" - نبی کریم ﷺ (بخاری و مسلم)';

  @override
  String get quote8 =>
      '\"پھر جب نماز پوری ہو جائے تو زمین میں پھیل جاؤ اور اللہ کا فضل تلاش کرو۔\" - قرآن ۶۲:۱۰';

  @override
  String get quote9 =>
      '\"دو نعمتیں ایسی ہیں جن کے بارے میں بہت سے لوگ خسارے میں ہیں: صحت اور فراغت۔\" - نبی کریم ﷺ (بخاری)';

  @override
  String get quote10 =>
      '\"جس نے اس حال میں صبح کی کہ وہ اپنے گھر میں امن سے ہو، جسمانی طور پر تندرست ہو اور اس کے پاس دن بھر کا کھانا ہو، تو گویا اس کے لیے پوری دنیا جمع کر دی گئی۔\" - نبی کریم ﷺ (ترمذی)';

  @override
  String get prayerCardErrorMessage => 'نماز کے اوقات لوڈ نہیں ہو سکے';

  @override
  String get prayerCardTitle => 'نمازِ فجر';

  @override
  String get prayerCardNowBadge => 'ابھی';

  @override
  String get prayerCardToday => 'آج';

  @override
  String get prayerCardTomorrow => 'کل';

  @override
  String get prayerCardNextFajrIn => 'اگلی فجر میں';

  @override
  String prayerCardCountdownValue(int hours, int minutes) {
    final intl.NumberFormat hoursNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String hoursString = hoursNumberFormat.format(hours);
    final intl.NumberFormat minutesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    return '$hoursString گھنٹے $minutesString منٹ';
  }

  @override
  String get prayerCardCountdownUnknown => 'نامعلوم';

  @override
  String get prayerCardSunrise => 'طلوعِ آفتاب';

  @override
  String get prayerCardDhuhr => 'ظہر';

  @override
  String get prayerCardAsr => 'عصر';

  @override
  String get prayerCardMaghrib => 'مغرب';

  @override
  String get prayerCardIsha => 'عشاء';

  @override
  String get streakCardDayStreak => 'دن کا سلسلہ';

  @override
  String get streakCardDaysStreak => 'دنوں کا سلسلہ';

  @override
  String get streakCardQualifyingDays => 'کوالیفائنگ دن';

  @override
  String get streakCardGoalDenominator => '/16';

  @override
  String get streakCardMsgLegendary => 'لاجواب!';

  @override
  String get streakCardMsgUnstoppable => 'ناقابلِ شکست!';

  @override
  String get streakCardMsgOnFire => 'زبردست رفتار!';

  @override
  String get streakCardMsgKeepGoing => 'جاری رکھیں!';

  @override
  String get errorViewDefaultMessage => 'کچھ غلط ہو گیا';

  @override
  String get errorViewRetryButton => 'دوبارہ کوشش کریں';

  @override
  String get commonOr => 'یا';

  @override
  String get onboardingWelcomeTitle => 'خوش آمدید\nSubh Warrior میں';

  @override
  String get onboardingWelcomeSubtitle =>
      'فجر کی نماز اور بھرپور توجہ والے کام کی طاقت سے اپنی صبحوں کو بدل دیں';

  @override
  String get onboardingFeatureFajrTracking => 'فجر کی نماز کی ٹریکنگ';

  @override
  String get onboardingFeatureProductiveWork => '60+ منٹ نتیجہ خیز کام';

  @override
  String get onboardingFeatureChallengeDuration => '28 دن کا چیلنج';

  @override
  String get onboardingFeatureAchieveDays => '16+ دن حاصل کریں';

  @override
  String get onboardingRulesTitle => 'چیلنج کے اصول';

  @override
  String get onboardingRuleWakeUpTitle => 'جاگیں';

  @override
  String get onboardingRuleWakeUpDesc =>
      'فجر کے وقت یا اس سے پہلے اٹھیں اور جاگتے رہیں';

  @override
  String get onboardingRulePrayTitle => 'نماز پڑھیں';

  @override
  String get onboardingRulePrayDesc => 'فجر کی نماز اس کے وقت کے اندر ادا کریں';

  @override
  String get onboardingRuleWorkTitle => 'کام کریں';

  @override
  String get onboardingRuleWorkDesc => '60+ منٹ کا نتیجہ خیز کام مکمل کریں';

  @override
  String get onboardingRuleLogTitle => 'لاگ کریں';

  @override
  String onboardingRuleLogDesc(String cutoffTime) {
    return '$cutoffTime سے پہلے اپنا دن جمع کریں (صرف ہفتے کے کام کے دن)';
  }

  @override
  String get onboardingRulesGoal => '4 ہفتوں میں 16+ کوالیفائنگ دن مکمل کریں';

  @override
  String get onboardingLocationTitle => 'اپنا مقام سیٹ کریں';

  @override
  String get onboardingLocationSubtitle =>
      'درست نماز کے اوقات معلوم کرنے کے لیے ہمیں اس کی ضرورت ہے';

  @override
  String get onboardingLocationFieldLabel => 'شہر/مقام';

  @override
  String get onboardingLocationFieldHint => 'مثلاً کراچی، پاکستان';

  @override
  String get onboardingGettingLocation => 'مقام حاصل کیا جا رہا ہے...';

  @override
  String get onboardingUseCurrentLocation => 'موجودہ مقام استعمال کریں';

  @override
  String get onboardingReadyTitle => 'آپ بالکل تیار ہیں!';

  @override
  String onboardingWelcomeUser(String name) {
    return 'خوش آمدید، $name!';
  }

  @override
  String get onboardingStartJourneyButton => 'اپنا سفر شروع کریں';

  @override
  String get onboardingBackButton => 'واپس';

  @override
  String get onboardingNextButton => 'آگے';

  @override
  String get onboardingSetLocationPrompt => 'براہ کرم اپنا مقام سیٹ کریں';

  @override
  String get onboardingLocationNotFound =>
      'وہ مقام نہیں مل سکا۔ براہ کرم ہجے چیک کریں۔';

  @override
  String onboardingErrorFindingLocation(String error) {
    return 'مقام تلاش کرنے میں خرابی: $error';
  }

  @override
  String get onboardingCoordinatesNotFound =>
      'اس مقام کے متناسقات (کوآرڈینیٹس) نہیں مل سکے۔';

  @override
  String get onboardingLocationServicesDisabled =>
      'لوکیشن سروسز بند ہیں۔ براہ کرم انہیں سیٹنگز میں فعال کریں۔';

  @override
  String get onboardingLocationPermissionDenied =>
      'لوکیشن کی اجازت نہیں دی گئی';

  @override
  String get onboardingLocationPermissionDeniedForever =>
      'لوکیشن کی اجازت مستقل طور پر مسترد کر دی گئی ہے۔ براہ کرم ایپ سیٹنگز میں اسے فعال کریں۔';

  @override
  String get onboardingSettingsAction => 'سیٹنگز';

  @override
  String get onboardingUnknownLocality => 'نامعلوم';

  @override
  String onboardingLocationSetCoords(String latitude, String longitude) {
    return 'مقام سیٹ ہو گیا ($latitude, $longitude)';
  }

  @override
  String onboardingErrorGettingLocation(String error) {
    return 'مقام حاصل کرنے میں خرابی: $error';
  }

  @override
  String get authCreateAccountTitle => 'اپنا اکاؤنٹ بنائیں';

  @override
  String get authWelcomeBackTitle => 'خوش آمدید، واپسی مبارک';

  @override
  String get authUsernameLabel => 'صارف نام';

  @override
  String get authEmailLabel => 'ای میل';

  @override
  String get authPasswordLabel => 'پاس ورڈ';

  @override
  String get authForgotPassword => 'پاس ورڈ بھول گئے؟';

  @override
  String get authCreateAccountButton => 'اکاؤنٹ بنائیں';

  @override
  String get authLogInButton => 'لاگ اِن';

  @override
  String get authToggleToLogin => 'پہلے سے اکاؤنٹ ہے؟ لاگ اِن کریں';

  @override
  String get authToggleToRegister => 'اکاؤنٹ نہیں ہے؟ رجسٹر کریں';

  @override
  String get authContinueWithGoogle => 'Google کے ساتھ جاری رکھیں';

  @override
  String get authErrorEmailInUse =>
      'یہ ای میل پہلے سے رجسٹرڈ ہے۔ اس کے بجائے لاگ اِن کرنے کی کوشش کریں۔';

  @override
  String get authErrorInvalidEmail => 'یہ ای میل ایڈریس درست نہیں ہے۔';

  @override
  String get authErrorWrongPassword => 'ای میل یا پاس ورڈ غلط ہے۔';

  @override
  String get authErrorUserNotFound => 'اس ای میل کے لیے کوئی اکاؤنٹ نہیں ملا۔';

  @override
  String get authErrorUserDisabled => 'یہ اکاؤنٹ غیر فعال کر دیا گیا ہے۔';

  @override
  String get authErrorWeakPassword => 'پاس ورڈ بہت کمزور ہے (کم از کم 6 حروف)۔';

  @override
  String get authErrorNetworkRequestFailed =>
      'نیٹ ورک کی خرابی۔ اپنا کنکشن چیک کریں اور دوبارہ کوشش کریں۔';

  @override
  String get authErrorTooManyRequests =>
      'بہت زیادہ کوششیں۔ براہ کرم بعد میں دوبارہ کوشش کریں۔';

  @override
  String get authErrorGeneric =>
      'تصدیق ناکام ہو گئی۔ براہ کرم دوبارہ کوشش کریں۔';

  @override
  String get authUsernameTaken =>
      'یہ صارف نام پہلے سے لیا جا چکا ہے۔ براہ کرم کوئی اور منتخب کریں۔';

  @override
  String get authForgotPasswordEnterEmail =>
      'پہلے اوپر اپنا ای میل درج کریں، پھر \"پاس ورڈ بھول گئے\" پر ٹیپ کریں۔';

  @override
  String authPasswordResetSent(String email) {
    return 'پاس ورڈ ری سیٹ کرنے کی ای میل $email پر بھیج دی گئی ہے۔';
  }

  @override
  String commonMinutesShort(int minutes) {
    final intl.NumberFormat minutesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    return '$minutesString منٹ';
  }

  @override
  String get settingsTitle => 'سیٹنگز';

  @override
  String get settingsSaveTooltip => 'سیٹنگز محفوظ کریں';

  @override
  String get settingsProfileTitle => 'پروفائل';

  @override
  String get settingsNameLabel => 'آپ کا نام';

  @override
  String get settingsNameHint => 'اپنا نام درج کریں';

  @override
  String get settingsStatTotalDays => 'کل دن';

  @override
  String get settingsStatCurrentStreak => 'موجودہ سلسلہ';

  @override
  String get settingsStatChallengeWeek => 'چیلنج کا ہفتہ';

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
  String get settingsLocationTitle => 'مقام';

  @override
  String settingsCoordinates(String latitude, String longitude) {
    return 'متناسقات: $latitude, $longitude';
  }

  @override
  String get settingsPrayerSettingsTitle => 'نماز کی سیٹنگز';

  @override
  String get settingsCalculationMethodLabel => 'حساب کا طریقہ';

  @override
  String get settingsJuristicMethodTitle => 'فقہی طریقہ';

  @override
  String get settingsJuristicHanafi => 'حنفی (عصر کا وقت بعد میں)';

  @override
  String get settingsJuristicStandard => 'معیاری (شافعی، مالکی، حنبلی)';

  @override
  String get settingsHanafiInfo =>
      'حنفی طریقے میں عصر کا وقت اُس وقت شمار ہوتا ہے جب سایہ چیز کی لمبائی کا دوگنا ہو جائے';

  @override
  String get settingsNotificationsTitle => 'اطلاعات';

  @override
  String get settingsEnableNotifications => 'اطلاعات فعال کریں';

  @override
  String get settingsEnableNotificationsSubtitle =>
      'یاد دہانیاں اور اپ ڈیٹس حاصل کریں';

  @override
  String get settingsFajrReminderTitle => 'فجر کی نماز کی یاد دہانی';

  @override
  String settingsFajrReminderSubtitle(int minutes) {
    final intl.NumberFormat minutesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    return 'فجر سے $minutesString منٹ پہلے اطلاع دیں';
  }

  @override
  String get settingsRemindMe => 'مجھے یاد دلائیں';

  @override
  String get settingsBeforeFajr => 'فجر سے پہلے';

  @override
  String get settingsLoggingReminderTitle => 'روزانہ لاگ کی یاد دہانی';

  @override
  String settingsLoggingReminderSubtitle(String time) {
    return 'دن لاگ کرنے کے لیے $time پر یاد دلائیں';
  }

  @override
  String get settingsAppearanceTitle => 'ظاہری شکل';

  @override
  String get settingsLanguageLabel => 'زبان';

  @override
  String get settingsLanguageSystem => 'سسٹم';

  @override
  String get settingsThemeLabel => 'تھیم';

  @override
  String get settingsThemeSystem => 'سسٹم';

  @override
  String get settingsThemeLight => 'لائٹ';

  @override
  String get settingsThemeDark => 'ڈارک';

  @override
  String get settingsTimeFormatLabel => 'وقت کا فارمیٹ';

  @override
  String get settingsTimeFormat12 => '12 گھنٹے';

  @override
  String get settingsTimeFormat24 => '24 گھنٹے';

  @override
  String get settingsChallengeTitle => 'چیلنج';

  @override
  String get settingsChallengeStarted => 'چیلنج شروع ہوا';

  @override
  String get settingsChallengeNotStarted => 'شروع نہیں ہوا';

  @override
  String get settingsEndChallenge => 'چیلنج ختم کریں';

  @override
  String get settingsAboutTitle => 'ایپ کے بارے میں';

  @override
  String get settingsAppVersion => 'ایپ ورژن';

  @override
  String get settingsGuestAccount => 'مہمان اکاؤنٹ';

  @override
  String get settingsSignedIn => 'سائن اِن ہے';

  @override
  String get settingsLinkGooglePrompt =>
      'اپنی پیش رفت کا Google کے ساتھ بیک اپ لینے کے لیے ٹیپ کریں';

  @override
  String get settingsProgressSavedLocally => 'پیش رفت اسی ڈیوائس پر محفوظ ہے';

  @override
  String get settingsSynced => 'ہم آہنگ (Synced)';

  @override
  String get settingsGuidelines => 'ہدایات';

  @override
  String get settingsSendFeedback => 'رائے بھیجیں';

  @override
  String get settingsShareApp => 'ایپ شیئر کریں';

  @override
  String get settingsSignedInWithGoogle => 'Google کے ساتھ سائن اِن ہے۔';

  @override
  String get settingsFeedbackSubject => 'Subh Warrior کے بارے میں رائے';

  @override
  String settingsFeedbackAppVersion(String version, String build) {
    return 'ایپ ورژن: $version ($build)';
  }

  @override
  String settingsNoEmailApp(String email) {
    return 'کوئی ای میل ایپ نہیں ملی۔ ہم سے $email پر رابطہ کریں';
  }

  @override
  String get settingsShareMessage =>
      'Subh Warrior کے ساتھ طاقتور صبحیں بنائیں — فجر کے لیے جاگیں، نتیجہ خیز رہیں، اور 28 دن کا چیلنج مکمل کریں۔ 🌅';

  @override
  String get settingsEnterNamePrompt => 'براہ کرم اپنا نام درج کریں';

  @override
  String get settingsSavedSuccess => 'سیٹنگز کامیابی سے محفوظ ہو گئیں';

  @override
  String get settingsEndChallengeDialogTitle => 'چیلنج ختم کریں؟';

  @override
  String get settingsEndChallengeDialogContent =>
      'کیا آپ واقعی چیلنج ختم کرنا چاہتے ہیں؟ آپ کی پیش رفت محفوظ رہے گی لیکن چیلنج نامکمل شمار ہوگا۔';

  @override
  String get settingsCancel => 'منسوخ کریں';

  @override
  String get settingsGuidelinesDialogTitle => 'چیلنج کی ہدایات';

  @override
  String settingsGuidelinesContent(String cutoffTime) {
    return '🌅 SUBH WARRIOR چیلنج\n\n✓ فجر کے وقت یا اس سے پہلے جاگیں\n✓ جاگتے اور چوکس رہیں\n✓ فجر کی نماز اس کے وقت کے اندر پڑھیں\n✓ 60+ منٹ نتیجہ خیز کام مکمل کریں\n✓ روزانہ $cutoffTime سے پہلے لاگ کریں\n✓ 4 ہفتوں میں 16+ دن مکمل کریں\n✓ ہر ہفتے کم از کم 4 کوالیفائنگ دن\n\nکوالیفائنگ کام:\n• گہری توجہ والے کام (ڈیپ ورک)\n• حکمتِ عملی کی منصوبہ بندی\n• سیکھنا/مہارت کی ترقی\n• تخلیقی منصوبے\n• اہم رابطہ کاری\n\nغیر کوالیفائنگ:\n• غیر فعال مواد دیکھنا\n• معمول کے انتظامی کام\n• سوشل میڈیا\n\nنوٹ: ویک اینڈ کے دن کوالیفائنگ دنوں میں شمار نہیں ہوتے۔';
  }

  @override
  String get settingsGotIt => 'سمجھ گیا!';

  @override
  String get progressNoChallenge =>
      'اپنی پیش رفت ٹریک کرنے کے لیے چیلنج شروع کریں';

  @override
  String get progressChallengeProgress => 'چیلنج کی پیش رفت';

  @override
  String get progressStatCompleted => 'مکمل';

  @override
  String get progressStatRemaining => 'باقی';

  @override
  String get progressStatStreak => 'سلسلہ';

  @override
  String get progressWeeklyPerformance => 'ہفتہ وار کارکردگی';

  @override
  String progressWeekAxisLabel(int week) {
    final intl.NumberFormat weekNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String weekString = weekNumberFormat.format(week);

    return 'ہفتہ $weekString';
  }

  @override
  String get progressNoDaysLogged => 'ابھی تک کوئی دن لاگ نہیں ہوا';

  @override
  String get progressRecentLogs => 'حالیہ لاگز';

  @override
  String get progressLogFajrPrayed => '✓ فجر';

  @override
  String get progressLogFajrMissed => '✗ فجر';

  @override
  String progressLogSubtitle(String fajrStatus, int minutes) {
    final intl.NumberFormat minutesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    return '$fajrStatus • $minutesString منٹ کام';
  }

  @override
  String get logDayWeekendTitle => 'ویک اینڈ کا دن';

  @override
  String get logDayWeekendBody =>
      'ویک اینڈ کے دن Subh Warrior چیلنج میں شمار نہیں ہوتے۔\n\nآپ کو ہر ہفتے 4 کوالیفائنگ کام کے دن درکار ہیں۔';

  @override
  String get logDayGoBack => 'واپس جائیں';

  @override
  String get logDayTimeUpTitle => 'وقت ختم!';

  @override
  String logDayTimeUpBody(String cutoffTime) {
    return 'روزانہ کے لاگز $cutoffTime سے پہلے جمع کرنا ضروری ہیں۔';
  }

  @override
  String logDayTimeRemaining(int hours, int minutes) {
    final intl.NumberFormat hoursNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String hoursString = hoursNumberFormat.format(hours);
    final intl.NumberFormat minutesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    return 'لاگ کرنے کے لیے باقی وقت: $hoursString گھنٹے $minutesString منٹ';
  }

  @override
  String get logDayTodaysFajr => 'آج کی فجر';

  @override
  String get logDayPrayerTimeNow => 'ابھی نماز کا وقت ہے';

  @override
  String get logDayLoading => 'لوڈ ہو رہا ہے...';

  @override
  String logDaySunrise(String time) {
    return 'طلوعِ آفتاب: $time';
  }

  @override
  String get logDayWakeUpTitle => 'جاگنے کی شرائط';

  @override
  String get logDayWokeUpTitle => 'فجر کے وقت یا اس سے پہلے جاگا';

  @override
  String get logDayWokeUpSubtitle => 'صرف عارضی طور پر جاگنا کافی نہیں';

  @override
  String get logDayStayedAwake => 'جاگتا اور چوکس رہا';

  @override
  String get logDayStayedAwakeSubtitle => 'نماز کے بعد بھی جاگتا رہا';

  @override
  String get logDayPrayedFajrOnTime => 'فجر وقت پر پڑھی';

  @override
  String get logDayWithinWindow => 'نماز کے وقت کے اندر';

  @override
  String get logDayPrayedAtMasjid => 'مسجد میں نماز پڑھی';

  @override
  String get logDayMasjidSubtitle => 'انتہائی مستحسن (لازمی نہیں)';

  @override
  String get logDayProductiveWork => 'نتیجہ خیز کام';

  @override
  String get logDayTypeOfWork => 'کام کی قسم';

  @override
  String get logDayWorkTypeDeepWork => 'گہری توجہ والا کام (ڈیپ ورک)';

  @override
  String get logDayWorkTypeStrategicPlanning => 'حکمتِ عملی کی منصوبہ بندی';

  @override
  String get logDayWorkTypeLearning => 'سیکھنا/مہارت کی ترقی';

  @override
  String get logDayWorkTypeCreativeProjects => 'تخلیقی منصوبے';

  @override
  String get logDayWorkTypeImportantCommunication => 'اہم رابطہ کاری';

  @override
  String get logDayWorkTypePassiveConsumption => '❌ غیر فعال مواد دیکھنا';

  @override
  String get logDayWorkTypeRoutineAdmin => '❌ معمول کے انتظامی کام';

  @override
  String get logDayWorkTypeSocialMedia => '❌ سوشل میڈیا';

  @override
  String get logDayWorkNotQualify => 'اس قسم کا کام کوالیفائی نہیں کرتا';

  @override
  String logDayMinutesFocused(int minutes) {
    final intl.NumberFormat minutesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    return 'مرکوز کام کے منٹ: $minutesString';
  }

  @override
  String logDayMinimumMinutes(int minutes) {
    final intl.NumberFormat minutesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    return 'کوالیفائی کرنے کے لیے کم از کم $minutesString منٹ درکار ہیں';
  }

  @override
  String get logDayDescribeWorkLabel => 'اپنے کام کی وضاحت کریں';

  @override
  String get logDayDescribeWorkHint => 'آپ نے کون سے مخصوص کام مکمل کیے؟';

  @override
  String get logDayDescribeWorkError => 'براہ کرم اپنے کام کی وضاحت کریں';

  @override
  String get logDayMoreDetailError => 'براہ کرم مزید تفصیل فراہم کریں';

  @override
  String get logDayReflectionTitle => 'غور و فکر (اختیاری)';

  @override
  String get logDayReflectionHint =>
      'صبح سویرے کام کرنا کیسا لگا؟\nآپ نے کیا حاصل کیا؟\nکوئی نئی بات یا کامیابی؟';

  @override
  String get logDayQualifyingDay => 'کوالیفائنگ دن!';

  @override
  String get logDayNotQualifyingYet => 'ابھی کوالیفائی نہیں ہوا';

  @override
  String get logDayReqAwake => 'فجر کے وقت یا اس سے پہلے جاگنا';

  @override
  String logDayReqMinutesWork(int minutes) {
    final intl.NumberFormat minutesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    return '$minutesString+ منٹ کام';
  }

  @override
  String get logDayReqQualifyingWorkType => 'کوالیفائنگ کام کی قسم';

  @override
  String get logDayBonusMasjid => 'بونس: مسجد میں نماز پڑھی! 🌟';

  @override
  String get logDaySubmitButton => 'لاگ جمع کریں';

  @override
  String get logDayMustBeAwake =>
      'فجر کے لیے آپ کا جاگتا اور چوکس ہونا ضروری ہے';

  @override
  String get logDayExceptional => 'غیر معمولی!';

  @override
  String get logDayExcellent => 'بہترین!';

  @override
  String get logDayDayLogged => 'دن لاگ ہو گیا';

  @override
  String get logDayMasjidSuccessContent =>
      'شاندار! آپ نے مسجد میں نماز پڑھی اور اپنا صبح کا کام بھی مکمل کیا۔ یہی اصل Subh Warrior جذبہ ہے! 🌟';

  @override
  String get logDayQualifyingSuccessContent =>
      'آپ نے ایک کوالیفائنگ دن حاصل کر لیا! اسی طرح محنت جاری رکھیں!';

  @override
  String get logDayLoggedContent =>
      'دن کامیابی سے لاگ ہو گیا۔ شرائط کا جائزہ لیں اور کل دوبارہ کوشش کریں!';

  @override
  String get logDayContinue => 'جاری رکھیں';

  @override
  String logDayAfterCutoff(String cutoffTime) {
    return 'لاگ کرنے کا وقت ختم ہو گیا — $cutoffTime سے پہلے لاگ کریں۔';
  }

  @override
  String get logDayWeekendError => 'ویک اینڈ چیلنج میں شمار نہیں ہوتے۔';

  @override
  String get logDayAlreadyLogged => 'آپ آج کا دن پہلے ہی لاگ کر چکے ہیں۔';

  @override
  String get logDayNotesTooLong =>
      'آپ کے نوٹس بہت لمبے ہیں — براہ کرم انہیں مختصر کریں۔';

  @override
  String get leaderboardTabGlobal => 'عالمی';

  @override
  String get leaderboardTabFriends => 'دوست';

  @override
  String get leaderboardTabLocal => 'مقامی';

  @override
  String get leaderboardFriendsComingSoon =>
      'دوستوں کا لیڈر بورڈ جلد آ رہا ہے!';

  @override
  String get leaderboardFriendsSubtitle =>
      'دوستوں کے ساتھ جُڑ کر مل کر مقابلہ کریں';

  @override
  String get leaderboardSetLocationTitle =>
      'مقامی واریئرز دیکھنے کے لیے اپنا مقام سیٹ کریں';

  @override
  String get leaderboardSetLocationButton => 'مقام سیٹ کریں';

  @override
  String get leaderboardLoadError => 'لیڈر بورڈ لوڈ کرنے میں خرابی';

  @override
  String get leaderboardYouBadge => 'آپ';

  @override
  String leaderboardDaysCount(int days) {
    final intl.NumberFormat daysNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String daysString = daysNumberFormat.format(days);

    return '$daysString دن';
  }

  @override
  String leaderboardStreakCount(int streak) {
    final intl.NumberFormat streakNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String streakString = streakNumberFormat.format(streak);

    return '$streakString سلسلہ';
  }

  @override
  String get leaderboardEmptyLocalTitle =>
      'آپ کے علاقے میں ابھی کوئی واریئر نہیں!';

  @override
  String get leaderboardEmptyGlobalTitle => 'کوئی ڈیٹا دستیاب نہیں';

  @override
  String get leaderboardEmptyLocalSubtitle =>
      'چیلنج شروع کرنے والے پہلے شخص بنیں';

  @override
  String get leaderboardEmptyGlobalSubtitle =>
      'یہاں نظر آنے کے لیے اپنا چیلنج شروع کریں';

  @override
  String get dayDetailQualifying => 'کوالیفائنگ دن';

  @override
  String get dayDetailNonQualifying => 'غیر کوالیفائنگ دن';

  @override
  String get dayDetailWorkDuration => 'کام کا دورانیہ';

  @override
  String get dayDetailWorkDescription => 'کام کی تفصیل';

  @override
  String get dayDetailNoDetails => 'اس دن کی کوئی تفصیلات لاگ نہیں ہوئیں۔';

  @override
  String get dayDetailReflection => 'غور و فکر';

  @override
  String notifFajrTitle(int minutes) {
    final intl.NumberFormat minutesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    return '🕌 فجر $minutesString منٹ میں';
  }

  @override
  String get notifFajrBody => 'فجر کی نماز کے لیے جاگنے کا وقت ہو گیا!';

  @override
  String get notifLogTitle => '⏰ اپنا دن لاگ کرنے کا وقت!';

  @override
  String get notifLogBody => 'صبح کا معمول لاگ کرنے کے لیے 30 منٹ باقی ہیں';

  @override
  String get notifChannelGeneralName => 'عام اطلاعات';

  @override
  String get notifChannelGeneralDesc => 'ایپ کی اطلاعات';

  @override
  String get notifChannelScheduledName => 'شیڈول شدہ اطلاعات';

  @override
  String get notifChannelScheduledDesc =>
      'شیڈول شدہ نماز اور چیلنج یاد دہانیاں';

  @override
  String get notifPermTitle => 'اطلاعات فعال کریں';

  @override
  String get notifPermContent =>
      'اپنے Subh Warrior چیلنج پر قائم رہنے کے لیے فجر کی نماز اور روزانہ لاگ کی یاد دہانیاں حاصل کریں۔';

  @override
  String get notifPermNotNow => 'ابھی نہیں';

  @override
  String get notifPermEnable => 'فعال کریں';

  @override
  String get a11yOpenSettings => 'سیٹنگز کھولیں';

  @override
  String get a11yShowPassword => 'پاس ورڈ دکھائیں';

  @override
  String get a11yHidePassword => 'پاس ورڈ چھپائیں';

  @override
  String get a11yStreakDormant => 'کوئی فعال سلسلہ نہیں';

  @override
  String get a11yStreakBuilding => 'سلسلہ بن رہا ہے';

  @override
  String get a11yStreakOnFire => 'سلسلہ زوروں پر ہے';

  @override
  String get a11yStreakStrong => 'مضبوط سلسلہ';

  @override
  String get a11yStreakSoaring => 'سلسلہ بلندیوں پر';

  @override
  String get a11yStreakLegendary => 'لاجواب سلسلہ';

  @override
  String get a11yGoalTrophy => 'ہدف کا سنگِ میل حاصل ہو گیا';

  @override
  String get a11yFirstPlace => 'پہلی پوزیشن';

  @override
  String get a11ySecondPlace => 'دوسری پوزیشن';

  @override
  String get a11yThirdPlace => 'تیسری پوزیشن';

  @override
  String get a11yMinutesWorkedSlider => 'مرکوز کام کے منٹ';

  @override
  String get a11yQualifyingDay => 'کوالیفائنگ دن';

  @override
  String get a11yNonQualifyingDay => 'غیر کوالیفائنگ دن';

  @override
  String get a11yRequirementMet => 'شرط پوری ہوئی';

  @override
  String get a11yRequirementNotMet => 'شرط پوری نہیں ہوئی';
}
