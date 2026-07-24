import 'dart:async';

import 'package:background_fetch/background_fetch.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:subh_warrior/core/analytics/analytics_service.dart';
import 'package:subh_warrior/core/analytics/firebase_analytics_service.dart';
import 'package:subh_warrior/core/l10n/app_localizations.dart';
import 'package:subh_warrior/core/theme/app_theme.dart';
import 'package:subh_warrior/features/auth/data/auth_service.dart';
import 'package:subh_warrior/features/challenge/data/challenge_local_data_source.dart';
import 'package:subh_warrior/features/challenge/presentation/challenge_controller.dart';
import 'package:subh_warrior/features/home/presentation/home_screen.dart';
import 'package:subh_warrior/features/prayer_times/data/fajr_widget_service.dart';
import 'package:subh_warrior/features/prayer_times/presentation/prayer_times_controller.dart';
import 'package:subh_warrior/helpers/notification_service.dart';
import 'package:subh_warrior/providers/locale_provider.dart';
import 'package:subh_warrior/providers/theme_provider.dart';
import 'package:subh_warrior/screens/auth_screen.dart';
import 'package:subh_warrior/screens/onboarding_screen.dart';
import 'package:subh_warrior/screens/settings_screen.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Ensure a signed-in user (anonymous at minimum) before any Firestore I/O.
  // The auth StreamBuilder in the app derives the live uid from here on.
  final authService = AuthService();
  final uid = await authService.ensureSignedIn();

  // Initialize analytics
  final analytics = FirebaseAnalyticsService();
  AnalyticsService.maybeInstance = analytics;

  // Initialize notifications
  NotificationService().initBackground();

  // Load preferences
  final prefs = await SharedPreferences.getInstance();

  await ChallengeLocalDataSource.migrateLegacyIfNeeded(prefs, uid);

  await _configureFajrWidgetBackgroundFetch();

  runApp(SubhWarriorApp(
    prefs: prefs,
    authService: authService,
    analytics: analytics,
  ));
}

/// Keeps the Android Fajr home-screen widget refreshed even when the app
/// isn't running: a 30-minute periodic base task (Android's practical floor
/// for background work) covers the in-between countdown ticking, and
/// FajrWidgetService self-reschedules an exact one-shot task right at each
/// Fajr boundary so the progress bar/countdown flip lands on time instead
/// of waiting for the next periodic tick.
Future<void> _configureFajrWidgetBackgroundFetch() async {
  await BackgroundFetch.configure(
    BackgroundFetchConfig(
      minimumFetchInterval: 30,
      forceAlarmManager: true,
      stopOnTerminate: false,
      enableHeadless: true,
      startOnBoot: true,
      requiredNetworkType: NetworkType.ANY,
    ),
    (String taskId) async {
      await FajrWidgetService.refresh();
      BackgroundFetch.finish(taskId);
    },
    (String taskId) async {
      // Timeout — OS is reclaiming background time; finish immediately.
      BackgroundFetch.finish(taskId);
    },
  );
  BackgroundFetch.registerHeadlessTask(_fajrWidgetBackgroundFetchHeadlessTask);

  // Kick off the first refresh immediately rather than waiting up to 30 min.
  unawaited(FajrWidgetService.refresh());
}

/// Entry point for background-fetch events firing while the app process is
/// dead. Must be a top-level function annotated `vm:entry-point` so the
/// Android-side plugin can find it via reflection after a fresh Dart VM
/// spin-up.
@pragma('vm:entry-point')
void _fajrWidgetBackgroundFetchHeadlessTask(HeadlessEvent task) async {
  if (task.timeout) {
    BackgroundFetch.finish(task.taskId);
    return;
  }
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FajrWidgetService.refresh();
  BackgroundFetch.finish(task.taskId);
}

class SubhWarriorApp extends StatelessWidget {
  final SharedPreferences prefs;
  final AuthService authService;
  final AnalyticsService analytics;

  const SubhWarriorApp({
    super.key,
    required this.prefs,
    required this.authService,
    required this.analytics,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>.value(value: authService),
        Provider<AnalyticsService>.value(value: analytics),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(
            create: (_) => PrayerTimeProvider.fromPrefs(prefs)),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeProvider, localeProvider, _) {
          return StreamBuilder<User?>(
            stream: authService.authStateChanges(),
            initialData: authService.currentUser,
            builder: (context, snapshot) {
              final user = snapshot.data;
              final uid = user?.uid ?? '';
              return ChangeNotifierProvider<ChallengeProvider>(
                key: ValueKey(uid),
                create: (_) => ChallengeProvider.fromPrefs(prefs,
                    uid: uid, analytics: analytics),
                child: MaterialApp(
                  onGenerateTitle: (context) =>
                      AppLocalizations.of(context)!.appTitle,
                  debugShowCheckedModeBanner: false,
                  localizationsDelegates:
                      AppLocalizations.localizationsDelegates,
                  supportedLocales: AppLocalizations.supportedLocales,
                  locale: localeProvider.locale,
                  builder: (context, child) {
                    // Keep intl's global locale in sync so bare DateFormat /
                    // NumberFormat calls (prayer times, dates) use the app
                    // locale's native digits and month names.
                    Intl.defaultLocale =
                        Localizations.localeOf(context).toString();
                    return child!;
                  },
                  theme: AppTheme.light(),
                  darkTheme: AppTheme.dark(),
                  themeMode: themeProvider.themeMode,
                  home: _RootRouter(user: user),
                  routes: {
                    '/auth': (context) => const AuthScreen(),
                    '/home': (context) => const HomeScreen(),
                    '/onboarding': (context) => const OnboardingScreen(),
                    '/settings': (context) => const SettingsScreen(),
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _RootRouter extends StatelessWidget {
  final User? user;

  const _RootRouter({required this.user});

  @override
  Widget build(BuildContext context) {
    // Signed out → entry screen.
    if (user == null) return const AuthScreen();

    final challenge = context.watch<ChallengeProvider>();

    // No username yet (anonymous boot, or signed in without a profile) → auth.
    if (challenge.userName.trim().isEmpty) return const AuthScreen();

    // Registered but no location → finish onboarding.
    if (!challenge.hasLocation) return const OnboardingScreen();

    return const HomeScreen();
  }
}
