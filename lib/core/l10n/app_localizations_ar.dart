// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'تحدي Subh Warrior';

  @override
  String get splashTitle => 'Subh Warrior';

  @override
  String get homeAppBarTitle => 'Subh Warrior';

  @override
  String get homeChallengeStartedSnack => 'بدأ التحدي — سجّل يومك الأول!';

  @override
  String get homeNavHome => 'الرئيسية';

  @override
  String get homeNavProgress => 'التقدم';

  @override
  String get homeNavLeaderboard => 'لوحة الصدارة';

  @override
  String get homeGreetingMorning => 'صباح الخير';

  @override
  String get homeGreetingAfternoon => 'مساء الخير';

  @override
  String get homeGreetingEvening => 'مساء الخير';

  @override
  String get homeGreetingFallbackName => 'أيها المحارب';

  @override
  String get inactiveChallengeTitle => 'هل أنت مستعد لتصبح محارب الصبح؟';

  @override
  String inactiveChallengeBody(int days) {
    final intl.NumberFormat daysNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String daysString = daysNumberFormat.format(days);

    return 'ابدأ تحديك لمدة $daysString يومًا لبناء روتين صباحي قوي مع صلاة الفجر والعمل المنتج.';
  }

  @override
  String get inactiveChallengeStartButton => 'ابدأ التحدي';

  @override
  String get todayStatusTitle => 'حالة اليوم';

  @override
  String get todayStatusChipQualifying => 'يوم مؤهَّل ✓';

  @override
  String get todayStatusChipLogged => 'مسجَّل';

  @override
  String get todayStatusChipPending => 'قيد الانتظار';

  @override
  String get todayStatusChipTimeUp => 'انتهى الوقت';

  @override
  String get todayStatusFajrPrayer => 'صلاة الفجر';

  @override
  String get todayStatusFajrOnTime => 'في وقتها';

  @override
  String get todayStatusFajrMissed => 'فائتة';

  @override
  String get todayStatusWorkTime => 'وقت العمل';

  @override
  String todayStatusMinutesWorked(int minutes) {
    final intl.NumberFormat minutesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    return '$minutesString دقيقة';
  }

  @override
  String get todayStatusWorkLabel => 'العمل';

  @override
  String get todayStatusLogTodayButton => 'سجّل اليوم';

  @override
  String todayStatusWindowClosed(String cutoffTime) {
    return 'أُغلقت نافذة التسجيل (بعد $cutoffTime)';
  }

  @override
  String get weeklyProgressTitle => 'التقدم الأسبوعي';

  @override
  String weeklyProgressWeekLabel(int week) {
    final intl.NumberFormat weekNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String weekString = weekNumberFormat.format(week);

    return 'الأسبوع $weekString';
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
  String get quickStatsDaysLeft => 'الأيام المتبقية';

  @override
  String get quickStatsGoalProgress => 'تقدم الهدف';

  @override
  String quickStatsPercent(int percent) {
    final intl.NumberFormat percentNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String percentString = percentNumberFormat.format(percent);

    return '$percentString٪';
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
      '«اللهم بارك لأمتي في بكورها» - النبي محمد ﷺ (أبو داود والترمذي)';

  @override
  String get quote2 =>
      '«ركعتا الفجر خير من الدنيا وما فيها» - النبي محمد ﷺ (مسلم)';

  @override
  String get quote3 =>
      '«من صلى الصبح في جماعة فكأنما صلى الليل كله» - النبي محمد ﷺ (مسلم)';

  @override
  String get quote4 =>
      '﴿وَقُرْآنَ الْفَجْرِ ۖ إِنَّ قُرْآنَ الْفَجْرِ كَانَ مَشْهُودًا﴾ - القرآن 17:78';

  @override
  String get quote5 =>
      '﴿إِنَّ نَاشِئَةَ اللَّيْلِ هِيَ أَشَدُّ وَطْئًا وَأَقْوَمُ قِيلًا﴾ - القرآن 73:6';

  @override
  String get quote6 =>
      '«اغتنم خمسًا قبل خمس: شبابك قبل هرمك، وصحتك قبل سقمك، وغناك قبل فقرك، وفراغك قبل شغلك، وحياتك قبل موتك» - النبي محمد ﷺ (الحاكم)';

  @override
  String get quote7 =>
      '«أحب الأعمال إلى الله أدومها وإن قل» - النبي محمد ﷺ (البخاري ومسلم)';

  @override
  String get quote8 =>
      '﴿فَإِذَا قُضِيَتِ الصَّلَاةُ فَانتَشِرُوا فِي الْأَرْضِ وَابْتَغُوا مِن فَضْلِ اللَّهِ﴾ - القرآن 62:10';

  @override
  String get quote9 =>
      '«نعمتان مغبون فيهما كثير من الناس: الصحة والفراغ» - النبي محمد ﷺ (البخاري)';

  @override
  String get quote10 =>
      '«من أصبح منكم آمنًا في سربه، معافى في جسده، عنده قوت يومه، فكأنما حيزت له الدنيا» - النبي محمد ﷺ (الترمذي)';

  @override
  String get prayerCardErrorMessage => 'تعذّر تحميل مواقيت الصلاة';

  @override
  String get prayerCardTitle => 'صلاة الفجر';

  @override
  String get prayerCardNowBadge => 'الآن';

  @override
  String get prayerCardToday => 'اليوم';

  @override
  String get prayerCardTomorrow => 'غدًا';

  @override
  String get prayerCardNextFajrIn => 'الفجر القادم بعد';

  @override
  String prayerCardCountdownValue(int hours, int minutes) {
    final intl.NumberFormat hoursNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String hoursString = hoursNumberFormat.format(hours);
    final intl.NumberFormat minutesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    return '$hoursStringس $minutesStringد';
  }

  @override
  String get prayerCardCountdownUnknown => 'غير معروف';

  @override
  String get prayerCardSunrise => 'الشروق';

  @override
  String get prayerCardDhuhr => 'الظهر';

  @override
  String get prayerCardAsr => 'العصر';

  @override
  String get prayerCardMaghrib => 'المغرب';

  @override
  String get prayerCardIsha => 'العشاء';

  @override
  String get streakCardDayStreak => 'يوم متتالٍ';

  @override
  String get streakCardDaysStreak => 'أيام متتالية';

  @override
  String get streakCardQualifyingDays => 'الأيام المؤهَّلة';

  @override
  String get streakCardGoalDenominator => '/16';

  @override
  String get streakCardMsgLegendary => 'أسطوري!';

  @override
  String get streakCardMsgUnstoppable => 'لا يمكن إيقافك!';

  @override
  String get streakCardMsgOnFire => 'متألق!';

  @override
  String get streakCardMsgKeepGoing => 'واصل التقدم!';

  @override
  String get errorViewDefaultMessage => 'حدث خطأ ما';

  @override
  String get errorViewRetryButton => 'إعادة المحاولة';

  @override
  String get commonOr => 'أو';

  @override
  String get onboardingWelcomeTitle => 'مرحبًا بك في\nSubh Warrior';

  @override
  String get onboardingWelcomeSubtitle =>
      'غيّر صباحاتك بقوة صلاة الفجر والإنتاجية المركّزة';

  @override
  String get onboardingFeatureFajrTracking => 'متابعة صلاة الفجر';

  @override
  String get onboardingFeatureProductiveWork => 'عمل منتج لأكثر من 60 دقيقة';

  @override
  String get onboardingFeatureChallengeDuration => 'تحدي 28 يومًا';

  @override
  String get onboardingFeatureAchieveDays => 'حقّق 16+ يومًا';

  @override
  String get onboardingRulesTitle => 'قواعد التحدي';

  @override
  String get onboardingRuleWakeUpTitle => 'الاستيقاظ';

  @override
  String get onboardingRuleWakeUpDesc =>
      'استيقظ عند وقت الفجر أو قبله وابقَ مستيقظًا';

  @override
  String get onboardingRulePrayTitle => 'الصلاة';

  @override
  String get onboardingRulePrayDesc => 'أدِّ صلاة الفجر ضمن وقتها';

  @override
  String get onboardingRuleWorkTitle => 'العمل';

  @override
  String get onboardingRuleWorkDesc => 'أنجز أكثر من 60 دقيقة من العمل المنتج';

  @override
  String get onboardingRuleLogTitle => 'التسجيل';

  @override
  String onboardingRuleLogDesc(String cutoffTime) {
    return 'سجّل يومك قبل $cutoffTime (أيام الأسبوع فقط)';
  }

  @override
  String get onboardingRulesGoal => 'أكمل 16+ يومًا مؤهَّلًا خلال 4 أسابيع';

  @override
  String get onboardingLocationTitle => 'حدّد موقعك';

  @override
  String get onboardingLocationSubtitle =>
      'نحتاج إلى ذلك لحساب مواقيت الصلاة بدقة';

  @override
  String get onboardingLocationFieldLabel => 'المدينة/الموقع';

  @override
  String get onboardingLocationFieldHint => 'مثال: القاهرة، مصر';

  @override
  String get onboardingGettingLocation => 'جارٍ تحديد الموقع...';

  @override
  String get onboardingUseCurrentLocation => 'استخدم الموقع الحالي';

  @override
  String get onboardingReadyTitle => 'كل شيء جاهز!';

  @override
  String onboardingWelcomeUser(String name) {
    return 'مرحبًا، $name!';
  }

  @override
  String get onboardingStartJourneyButton => 'ابدأ رحلتك';

  @override
  String get onboardingBackButton => 'رجوع';

  @override
  String get onboardingNextButton => 'التالي';

  @override
  String get onboardingSetLocationPrompt => 'يرجى تحديد موقعك';

  @override
  String get onboardingLocationNotFound =>
      'تعذّر العثور على هذا الموقع. يرجى التحقق من الإملاء.';

  @override
  String onboardingErrorFindingLocation(String error) {
    return 'خطأ في العثور على الموقع: $error';
  }

  @override
  String get onboardingCoordinatesNotFound =>
      'تعذّر العثور على إحداثيات هذا الموقع.';

  @override
  String get onboardingLocationServicesDisabled =>
      'خدمات الموقع معطّلة. يرجى تفعيلها من الإعدادات.';

  @override
  String get onboardingLocationPermissionDenied => 'تم رفض أذونات الموقع';

  @override
  String get onboardingLocationPermissionDeniedForever =>
      'تم رفض أذونات الموقع نهائيًا. يرجى تفعيلها من إعدادات التطبيق.';

  @override
  String get onboardingSettingsAction => 'الإعدادات';

  @override
  String get onboardingUnknownLocality => 'غير معروف';

  @override
  String onboardingLocationSetCoords(String latitude, String longitude) {
    return 'تم تحديد الموقع ($latitude، $longitude)';
  }

  @override
  String onboardingErrorGettingLocation(String error) {
    return 'خطأ في الحصول على الموقع: $error';
  }

  @override
  String get authCreateAccountTitle => 'أنشئ حسابك';

  @override
  String get authWelcomeBackTitle => 'مرحبًا بعودتك';

  @override
  String get authUsernameLabel => 'اسم المستخدم';

  @override
  String get authEmailLabel => 'البريد الإلكتروني';

  @override
  String get authPasswordLabel => 'كلمة المرور';

  @override
  String get authForgotPassword => 'هل نسيت كلمة المرور؟';

  @override
  String get authCreateAccountButton => 'إنشاء حساب';

  @override
  String get authLogInButton => 'تسجيل الدخول';

  @override
  String get authToggleToLogin => 'لديك حساب بالفعل؟ سجّل الدخول';

  @override
  String get authToggleToRegister => 'ليس لديك حساب؟ سجّل الآن';

  @override
  String get authContinueWithGoogle => 'المتابعة عبر Google';

  @override
  String get authErrorEmailInUse =>
      'هذا البريد الإلكتروني مسجَّل بالفعل. جرّب تسجيل الدخول بدلًا من ذلك.';

  @override
  String get authErrorInvalidEmail => 'عنوان البريد الإلكتروني غير صالح.';

  @override
  String get authErrorWrongPassword =>
      'البريد الإلكتروني أو كلمة المرور غير صحيحة.';

  @override
  String get authErrorUserNotFound =>
      'لا يوجد حساب مرتبط بهذا البريد الإلكتروني.';

  @override
  String get authErrorUserDisabled => 'تم تعطيل هذا الحساب.';

  @override
  String get authErrorWeakPassword =>
      'كلمة المرور ضعيفة جدًا (6 أحرف على الأقل).';

  @override
  String get authErrorNetworkRequestFailed =>
      'خطأ في الشبكة. تحقق من اتصالك وحاول مرة أخرى.';

  @override
  String get authErrorTooManyRequests =>
      'محاولات كثيرة جدًا. يرجى المحاولة لاحقًا.';

  @override
  String get authErrorGeneric => 'فشلت المصادقة. يرجى المحاولة مرة أخرى.';

  @override
  String get authUsernameTaken =>
      'اسم المستخدم هذا مستخدم بالفعل. يرجى اختيار اسم آخر.';

  @override
  String get authForgotPasswordEnterEmail =>
      'أدخل بريدك الإلكتروني أعلاه أولًا، ثم اضغط على \"هل نسيت كلمة المرور\".';

  @override
  String authPasswordResetSent(String email) {
    return 'تم إرسال رسالة إعادة تعيين كلمة المرور إلى $email.';
  }

  @override
  String commonMinutesShort(int minutes) {
    final intl.NumberFormat minutesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    return '$minutesString دقيقة';
  }

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsSaveTooltip => 'حفظ الإعدادات';

  @override
  String get settingsProfileTitle => 'الملف الشخصي';

  @override
  String get settingsNameLabel => 'اسمك';

  @override
  String get settingsNameHint => 'أدخل اسمك';

  @override
  String get settingsStatTotalDays => 'إجمالي الأيام';

  @override
  String get settingsStatCurrentStreak => 'التتابع الحالي';

  @override
  String get settingsStatChallengeWeek => 'أسبوع التحدي';

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
  String get settingsLocationTitle => 'الموقع';

  @override
  String settingsCoordinates(String latitude, String longitude) {
    return 'الإحداثيات: $latitude، $longitude';
  }

  @override
  String get settingsPrayerSettingsTitle => 'إعدادات الصلاة';

  @override
  String get settingsCalculationMethodLabel => 'طريقة الحساب';

  @override
  String get settingsJuristicMethodTitle => 'المذهب الفقهي';

  @override
  String get settingsJuristicHanafi => 'الحنفي (وقت عصر متأخر)';

  @override
  String get settingsJuristicStandard => 'الجمهور (الشافعي والمالكي والحنبلي)';

  @override
  String get settingsHanafiInfo =>
      'يحسب المذهب الحنفي وقت العصر عندما يصبح الظل ضعف طول الشيء';

  @override
  String get settingsNotificationsTitle => 'الإشعارات';

  @override
  String get settingsEnableNotifications => 'تفعيل الإشعارات';

  @override
  String get settingsEnableNotificationsSubtitle => 'احصل على تذكيرات وتحديثات';

  @override
  String get settingsFajrReminderTitle => 'تذكير صلاة الفجر';

  @override
  String settingsFajrReminderSubtitle(int minutes) {
    final intl.NumberFormat minutesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    return 'تنبيه قبل الفجر بـ $minutesString دقيقة';
  }

  @override
  String get settingsRemindMe => 'ذكّرني';

  @override
  String get settingsBeforeFajr => 'قبل الفجر';

  @override
  String get settingsLoggingReminderTitle => 'تذكير التسجيل اليومي';

  @override
  String settingsLoggingReminderSubtitle(String time) {
    return 'تذكير في $time لتسجيل يومك';
  }

  @override
  String get settingsAppearanceTitle => 'المظهر';

  @override
  String get settingsLanguageLabel => 'اللغة';

  @override
  String get settingsLanguageSystem => 'النظام';

  @override
  String get settingsThemeLabel => 'السمة';

  @override
  String get settingsThemeSystem => 'النظام';

  @override
  String get settingsThemeLight => 'فاتح';

  @override
  String get settingsThemeDark => 'داكن';

  @override
  String get settingsTimeFormatLabel => 'تنسيق الوقت';

  @override
  String get settingsTimeFormat12 => '12 ساعة';

  @override
  String get settingsTimeFormat24 => '24 ساعة';

  @override
  String get settingsChallengeTitle => 'التحدي';

  @override
  String get settingsChallengeStarted => 'بدأ التحدي';

  @override
  String get settingsChallengeNotStarted => 'لم يبدأ بعد';

  @override
  String get settingsEndChallenge => 'إنهاء التحدي';

  @override
  String get settingsAboutTitle => 'حول التطبيق';

  @override
  String get settingsAppVersion => 'إصدار التطبيق';

  @override
  String get settingsGuestAccount => 'حساب ضيف';

  @override
  String get settingsSignedIn => 'مسجَّل الدخول';

  @override
  String get settingsLinkGooglePrompt => 'اضغط لنسخ تقدمك احتياطيًا عبر Google';

  @override
  String get settingsProgressSavedLocally => 'يتم حفظ التقدم على هذا الجهاز';

  @override
  String get settingsSynced => 'متزامن';

  @override
  String get settingsGuidelines => 'الإرشادات';

  @override
  String get settingsSendFeedback => 'إرسال ملاحظات';

  @override
  String get settingsShareApp => 'مشاركة التطبيق';

  @override
  String get settingsSignedInWithGoogle => 'تم تسجيل الدخول عبر Google.';

  @override
  String get settingsFeedbackSubject => 'ملاحظات Subh Warrior';

  @override
  String settingsFeedbackAppVersion(String version, String build) {
    return 'إصدار التطبيق: $version ($build)';
  }

  @override
  String settingsNoEmailApp(String email) {
    return 'لم يتم العثور على تطبيق بريد إلكتروني. تواصل معنا على $email';
  }

  @override
  String get settingsShareMessage =>
      'ابنِ صباحات قوية مع Subh Warrior — استيقظ للفجر، وحافظ على إنتاجيتك، وأكمل تحدي الـ 28 يومًا. 🌅';

  @override
  String get settingsEnterNamePrompt => 'يرجى إدخال اسمك';

  @override
  String get settingsSavedSuccess => 'تم حفظ الإعدادات بنجاح';

  @override
  String get settingsEndChallengeDialogTitle => 'إنهاء التحدي؟';

  @override
  String get settingsEndChallengeDialogContent =>
      'هل أنت متأكد من رغبتك في إنهاء التحدي؟ سيتم حفظ تقدمك لكن سيُعتبر التحدي غير مكتمل.';

  @override
  String get settingsCancel => 'إلغاء';

  @override
  String get settingsGuidelinesDialogTitle => 'إرشادات التحدي';

  @override
  String settingsGuidelinesContent(String cutoffTime) {
    return '🌅 تحدي SUBH WARRIOR\n\n✓ استيقظ عند وقت الفجر أو قبله\n✓ ابقَ مستيقظًا ومنتبهًا\n✓ صلِّ الفجر ضمن وقته\n✓ أنجز أكثر من 60 دقيقة من العمل المنتج\n✓ سجّل قبل $cutoffTime يوميًا\n✓ أكمل 16+ يومًا خلال 4 أسابيع\n✓ 4 أيام مؤهَّلة كحد أدنى في الأسبوع\n\nالعمل المؤهِّل:\n• مهام العمل العميق\n• التخطيط الاستراتيجي\n• التعلّم/تطوير المهارات\n• المشاريع الإبداعية\n• التواصل المهم\n\nغير المؤهِّل:\n• الاستهلاك السلبي للمحتوى\n• المهام الإدارية الروتينية\n• وسائل التواصل الاجتماعي\n\nملاحظة: لا تُحتسب عطلات نهاية الأسبوع أيامًا مؤهَّلة.';
  }

  @override
  String get settingsGotIt => 'فهمت!';

  @override
  String get progressNoChallenge => 'ابدأ تحديًا لمتابعة تقدمك';

  @override
  String get progressChallengeProgress => 'تقدم التحدي';

  @override
  String get progressStatCompleted => 'مكتمل';

  @override
  String get progressStatRemaining => 'متبقٍ';

  @override
  String get progressStatStreak => 'التتابع';

  @override
  String get progressWeeklyPerformance => 'الأداء الأسبوعي';

  @override
  String progressWeekAxisLabel(int week) {
    final intl.NumberFormat weekNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String weekString = weekNumberFormat.format(week);

    return 'أ$weekString';
  }

  @override
  String get progressNoDaysLogged => 'لم تُسجَّل أي أيام بعد';

  @override
  String get progressRecentLogs => 'السجلات الأخيرة';

  @override
  String get progressLogFajrPrayed => '✓ الفجر';

  @override
  String get progressLogFajrMissed => '✗ الفجر';

  @override
  String progressLogSubtitle(String fajrStatus, int minutes) {
    final intl.NumberFormat minutesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    return '$fajrStatus • $minutesString دقيقة عمل';
  }

  @override
  String get logDayWeekendTitle => 'يوم عطلة';

  @override
  String get logDayWeekendBody =>
      'لا تُحتسب أيام عطلة نهاية الأسبوع في تحدي Subh Warrior.\n\nتحتاج إلى 4 أيام مؤهَّلة من أيام الأسبوع كل أسبوع.';

  @override
  String get logDayGoBack => 'رجوع';

  @override
  String get logDayTimeUpTitle => 'انتهى الوقت!';

  @override
  String logDayTimeUpBody(String cutoffTime) {
    return 'يجب تقديم السجلات اليومية قبل $cutoffTime.';
  }

  @override
  String logDayTimeRemaining(int hours, int minutes) {
    final intl.NumberFormat hoursNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String hoursString = hoursNumberFormat.format(hours);
    final intl.NumberFormat minutesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    return 'الوقت المتبقي للتسجيل: $hoursStringس $minutesStringد';
  }

  @override
  String get logDayTodaysFajr => 'فجر اليوم';

  @override
  String get logDayPrayerTimeNow => 'وقت الصلاة الآن';

  @override
  String get logDayLoading => 'جارٍ التحميل...';

  @override
  String logDaySunrise(String time) {
    return 'الشروق: $time';
  }

  @override
  String get logDayWakeUpTitle => 'متطلبات الاستيقاظ';

  @override
  String get logDayWokeUpTitle => 'استيقظت عند وقت الفجر أو قبله';

  @override
  String get logDayWokeUpSubtitle => 'ليس مجرد استيقاظ مؤقت';

  @override
  String get logDayStayedAwake => 'بقيت مستيقظًا ومنتبهًا';

  @override
  String get logDayStayedAwakeSubtitle => 'بقيت واعيًا بعد الصلاة';

  @override
  String get logDayPrayedFajrOnTime => 'صليت الفجر في وقته';

  @override
  String get logDayWithinWindow => 'ضمن وقت الصلاة';

  @override
  String get logDayPrayedAtMasjid => 'صليت في المسجد';

  @override
  String get logDayMasjidSubtitle => 'مستحب بشدة (غير مطلوب)';

  @override
  String get logDayProductiveWork => 'العمل المنتج';

  @override
  String get logDayTypeOfWork => 'نوع العمل';

  @override
  String get logDayWorkTypeDeepWork => 'عمل عميق';

  @override
  String get logDayWorkTypeStrategicPlanning => 'تخطيط استراتيجي';

  @override
  String get logDayWorkTypeLearning => 'تعلّم/تطوير مهارات';

  @override
  String get logDayWorkTypeCreativeProjects => 'مشاريع إبداعية';

  @override
  String get logDayWorkTypeImportantCommunication => 'تواصل مهم';

  @override
  String get logDayWorkTypePassiveConsumption => '❌ استهلاك سلبي للمحتوى';

  @override
  String get logDayWorkTypeRoutineAdmin => '❌ مهام إدارية روتينية';

  @override
  String get logDayWorkTypeSocialMedia => '❌ وسائل التواصل الاجتماعي';

  @override
  String get logDayWorkNotQualify => 'هذا النوع من العمل غير مؤهِّل';

  @override
  String logDayMinutesFocused(int minutes) {
    final intl.NumberFormat minutesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    return 'دقائق العمل المركّز: $minutesString';
  }

  @override
  String logDayMinimumMinutes(int minutes) {
    final intl.NumberFormat minutesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    return 'الحد الأدنى $minutesString دقيقة للتأهّل';
  }

  @override
  String get logDayDescribeWorkLabel => 'صف عملك';

  @override
  String get logDayDescribeWorkHint => 'ما المهام المحددة التي أنجزتها؟';

  @override
  String get logDayDescribeWorkError => 'يرجى وصف عملك';

  @override
  String get logDayMoreDetailError => 'يرجى تقديم مزيد من التفاصيل';

  @override
  String get logDayReflectionTitle => 'تأمل (اختياري)';

  @override
  String get logDayReflectionHint =>
      'كيف كان شعورك بالعمل في الصباح الباكر؟\nماذا أنجزت؟\nهل من أفكار أو اكتشافات؟';

  @override
  String get logDayQualifyingDay => 'يوم مؤهَّل!';

  @override
  String get logDayNotQualifyingYet => 'غير مؤهَّل بعد';

  @override
  String get logDayReqAwake => 'مستيقظ عند الفجر أو قبله';

  @override
  String logDayReqMinutesWork(int minutes) {
    final intl.NumberFormat minutesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    return '$minutesString+ دقيقة من العمل';
  }

  @override
  String get logDayReqQualifyingWorkType => 'نوع عمل مؤهِّل';

  @override
  String get logDayBonusMasjid => 'إضافة: صليت في المسجد! 🌟';

  @override
  String get logDaySubmitButton => 'إرسال السجل';

  @override
  String get logDayMustBeAwake => 'يجب أن تكون مستيقظًا ومنتبهًا للفجر';

  @override
  String get logDayExceptional => 'استثنائي!';

  @override
  String get logDayExcellent => 'ممتاز!';

  @override
  String get logDayDayLogged => 'تم تسجيل اليوم';

  @override
  String get logDayMasjidSuccessContent =>
      'رائع! صليت في المسجد وأكملت عملك الصباحي. روح محارب الصبح الحقيقية! 🌟';

  @override
  String get logDayQualifyingSuccessContent =>
      'لقد حققت يومًا مؤهَّلًا! واصل العمل الرائع!';

  @override
  String get logDayLoggedContent =>
      'تم تسجيل اليوم بنجاح. راجع المتطلبات وحاول مجددًا غدًا!';

  @override
  String get logDayContinue => 'متابعة';

  @override
  String logDayAfterCutoff(String cutoffTime) {
    return 'أُغلقت نافذة التسجيل — سجّل قبل $cutoffTime.';
  }

  @override
  String get logDayWeekendError => 'لا تُحتسب عطلات نهاية الأسبوع في التحدي.';

  @override
  String get logDayAlreadyLogged => 'لقد سجّلت اليوم بالفعل.';

  @override
  String get logDayNotesTooLong => 'ملاحظاتك طويلة جدًا — يرجى اختصارها.';

  @override
  String get leaderboardTabGlobal => 'عالمي';

  @override
  String get leaderboardTabFriends => 'الأصدقاء';

  @override
  String get leaderboardTabLocal => 'محلي';

  @override
  String get leaderboardFriendsComingSoon =>
      'لوحة صدارة الأصدقاء قادمة قريبًا!';

  @override
  String get leaderboardFriendsSubtitle => 'تواصل مع أصدقائك للتنافس معًا';

  @override
  String get leaderboardSetLocationTitle =>
      'حدّد موقعك لرؤية المحاربين في منطقتك';

  @override
  String get leaderboardSetLocationButton => 'تحديد الموقع';

  @override
  String get leaderboardLoadError => 'خطأ في تحميل لوحة الصدارة';

  @override
  String get leaderboardYouBadge => 'أنت';

  @override
  String leaderboardDaysCount(int days) {
    final intl.NumberFormat daysNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String daysString = daysNumberFormat.format(days);

    return '$daysString يومًا';
  }

  @override
  String leaderboardStreakCount(int streak) {
    final intl.NumberFormat streakNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String streakString = streakNumberFormat.format(streak);

    return 'تتابع $streakString';
  }

  @override
  String get leaderboardEmptyLocalTitle => 'لا يوجد محاربون في منطقتك بعد!';

  @override
  String get leaderboardEmptyGlobalTitle => 'لا توجد بيانات متاحة';

  @override
  String get leaderboardEmptyLocalSubtitle => 'كن أول من يبدأ التحدي';

  @override
  String get leaderboardEmptyGlobalSubtitle => 'ابدأ تحديك لتظهر هنا';

  @override
  String get dayDetailQualifying => 'يوم مؤهَّل';

  @override
  String get dayDetailNonQualifying => 'يوم غير مؤهَّل';

  @override
  String get dayDetailWorkDuration => 'مدة العمل';

  @override
  String get dayDetailWorkDescription => 'وصف العمل';

  @override
  String get dayDetailNoDetails => 'لا توجد تفاصيل مسجَّلة لهذا اليوم.';

  @override
  String get dayDetailReflection => 'تأمل';

  @override
  String notifFajrTitle(int minutes) {
    final intl.NumberFormat minutesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    return '🕌 الفجر بعد $minutesString دقيقة';
  }

  @override
  String get notifFajrBody => 'حان وقت الاستيقاظ لصلاة الفجر!';

  @override
  String get notifLogTitle => '⏰ حان وقت تسجيل يومك!';

  @override
  String get notifLogBody => 'تبقّى لديك ٣٠ دقيقة لتسجيل روتينك الصباحي';

  @override
  String get notifChannelGeneralName => 'إشعارات عامة';

  @override
  String get notifChannelGeneralDesc => 'إشعارات التطبيق';

  @override
  String get notifChannelScheduledName => 'إشعارات مجدولة';

  @override
  String get notifChannelScheduledDesc => 'تذكيرات مجدولة للصلاة والتحدي';

  @override
  String get notifPermTitle => 'تفعيل الإشعارات';

  @override
  String get notifPermContent =>
      'احصل على تذكيرات بصلاة الفجر والتسجيل اليومي لتبقى ملتزمًا بتحدي Subh Warrior.';

  @override
  String get notifPermNotNow => 'ليس الآن';

  @override
  String get notifPermEnable => 'تفعيل';

  @override
  String get shareCardTitle => 'محارب الصبح';

  @override
  String get shareCardStreakLabel => 'يومًا متتاليًا';

  @override
  String get shareCardQualifyingLabel => 'أيام مؤهّلة';

  @override
  String shareCardWeekLabel(int week) {
    final intl.NumberFormat weekNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String weekString = weekNumberFormat.format(week);

    return 'الأسبوع $weekString من 4';
  }

  @override
  String get shareCardFooter => 'انضم إليّ في تحدي الفجر لمدة 28 يومًا!';

  @override
  String get shareCardButton => 'مشاركة';

  @override
  String get shareCardSheetTitle => 'شارك تقدمك';

  @override
  String get a11yOpenSettings => 'فتح الإعدادات';

  @override
  String get a11yShowPassword => 'إظهار كلمة المرور';

  @override
  String get a11yHidePassword => 'إخفاء كلمة المرور';

  @override
  String get a11yStreakDormant => 'لا يوجد تتابع نشط';

  @override
  String get a11yStreakBuilding => 'التتابع في ازدياد';

  @override
  String get a11yStreakOnFire => 'تتابع متوهج';

  @override
  String get a11yStreakStrong => 'تتابع قوي';

  @override
  String get a11yStreakSoaring => 'تتابع محلّق';

  @override
  String get a11yStreakLegendary => 'تتابع أسطوري';

  @override
  String get a11yGoalTrophy => 'تم تحقيق هدف مرحلي';

  @override
  String get a11yFirstPlace => 'المركز الأول';

  @override
  String get a11ySecondPlace => 'المركز الثاني';

  @override
  String get a11yThirdPlace => 'المركز الثالث';

  @override
  String get a11yMinutesWorkedSlider => 'دقائق العمل المركّز';

  @override
  String get a11yQualifyingDay => 'يوم مؤهَّل';

  @override
  String get a11yNonQualifyingDay => 'يوم غير مؤهَّل';

  @override
  String get a11yRequirementMet => 'تم استيفاء المتطلب';

  @override
  String get a11yRequirementNotMet => 'لم يتم استيفاء المتطلب';
}
