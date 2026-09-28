import 'dart:async';

import 'package:background_fetch/background_fetch.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:subh_warrior/core/analytics/analytics_service.dart';
import 'package:subh_warrior/core/analytics/firebase_analytics_service.dart';
import 'package:subh_warrior/core/l10n/app_localizations.dart';
import 'package:subh_warrior/core/perf/firebase_performance_service.dart';
import 'package:subh_warrior/core/perf/performance_service.dart';
import 'package:subh_warrior/core/perf/startup_trace.dart';
import 'package:subh_warrior/core/theme/app_theme.dart';
import 'package:subh_warrior/features/auth/data/auth_service.dart';
import 'package:subh_warrior/features/challenge/data/challenge_local_data_source.dart';
import 'package:subh_warrior/features/challenge/presentation/challenge_controller.dart';
import 'package:subh_warrior/features/home/presentation/home_screen.dart';
import 'package:subh_warrior/features/prayer_times/data/fajr_call_service.dart';
import 'package:subh_warrior/features/prayer_times/data/fajr_widget_service.dart';
import 'package:subh_warrior/features/prayer_times/presentation/prayer_times_controller.dart';
import 'package:subh_warrior/helpers/notification_service.dart';
import 'package:subh_warrior/providers/locale_provider.dart';
import 'package:subh_warrior/providers/theme_provider.dart';
import 'package:subh_warrior/screens/auth_screen.dart';
import 'package:subh_warrior/screens/onboarding_screen.dart';
import 'package:subh_warrior/screens/settings_screen.dart';
import 'package:subh_warrior/screens/splash_screen.dart';

import 'firebase_options.dart';

/// Everything the provider tree needs that depends on Firebase.
class _Services {
  const _Services({
    required this.authService,
    required this.analytics,
    required this.performance,
  });

  final AuthService authService;
  final AnalyticsService analytics;
  final PerformanceService performance;
}

void main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  StartupTrace.start();

  // Only SharedPreferences is awaited before the first frame — it costs a few
  // milliseconds and the theme, locale and prayer-times providers need it.
  //
  // Everything else used to be awaited here too, which meant nothing was drawn
  // until Firebase had initialized (measured at ~1.1s) and an anonymous
  // sign-in round-trip had completed (unbounded on a slow network, and the
  // very first launch always pays it). The user stared at the bare Android
  // launch window for all of it. Now that work runs behind the splash screen
  // instead — see [_AppShell].
  final prefs = await SharedPreferences.getInstance();
  StartupTrace.mark(StartupMarks.prefsLoaded);

  // The first entry lands once the splash has actually been rasterized, so
  // this is the moment the user stops looking at the bare launch window.
  late final TimingsCallback onTimings;
  onTimings = (_) {
    StartupTrace.mark(StartupMarks.firstFrame);
    binding.removeTimingsCallback(onTimings);
  };
  binding.addTimingsCallback(onTimings);

  runApp(SubhWarriorApp(prefs: prefs));
}

/// How long boot will wait on the prayer-times refresh before handing over to
/// Home regardless. The fetch itself carries on in the background — this only
/// bounds how much of it the splash is allowed to cover.
const Duration _prayerRefreshBootBudget = Duration(seconds: 2);

/// Firebase-dependent initialization, run after the first frame.
Future<_Services> _bootstrap(
  SharedPreferences prefs,
  PrayerTimeProvider prayerProvider,
) async {
  // Let the splash frame reach the screen first. Boot is kicked off from the
  // first build, so without this every plugin registration below lands while
  // that frame is still rasterizing — measured as a 642ms gap between first
  // frame and first frame rasterized, and 36 skipped frames.
  await SchedulerBinding.instance.endOfFrame;

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  StartupTrace.mark(StartupMarks.firebaseReady);

  // Ensure a signed-in user (anonymous at minimum) before any Firestore I/O.
  // The auth StreamBuilder in the app derives the live uid from here on.
  final authService = AuthService();
  final uid = await authService.ensureSignedIn();
  StartupTrace.mark(StartupMarks.authReady);

  final analytics = FirebaseAnalyticsService();
  AnalyticsService.maybeInstance = analytics;

  final performance = FirebasePerformanceService();
  PerformanceService.maybeInstance = performance;
  unawaited(FirebasePerformanceService.enableCollection());

  await ChallengeLocalDataSource.migrateLegacyIfNeeded(prefs, uid);

  // Neither is needed to render, and both are platform-channel heavy —
  // notification channel creation and an AlarmManager registration. Deferred
  // to after boot hands over so they compete with nothing the user is
  // waiting on; the widget refresh they trigger also does network I/O.
  SchedulerBinding.instance.addPostFrameCallback((_) {
    NotificationService().initBackground();
    unawaited(_configureFajrWidgetBackgroundFetch());
    // The Fajr call: alarm plumbing plus the listener that clears the call
    // screen once it has been answered or dismissed.
    unawaited(FajrCallService.initialize());
    FajrCallService.listenForAnswers();
    // Ends a call answered while the app was dead: the listener above misses
    // that event, and the plugin's ongoing-call notification would otherwise
    // sit in the shade until the next reboot.
    unawaited(FajrCallService.clearLingeringCalls());
  });

  await _refreshPrayerTimesWithinBudget(prefs, uid, prayerProvider);
  StartupTrace.mark(StartupMarks.prayerTimesSettled);

  // Fire and forget: the report is one analytics event, and boot should hand
  // over to Home without waiting on it.
  unawaited(
    StartupTrace.finish(analytics: analytics, performance: performance),
  );

  return _Services(
    authService: authService,
    analytics: analytics,
    performance: performance,
  );
}

/// Starts the prayer-times refresh while the splash is still up, then stops
/// waiting after [_prayerRefreshBootBudget].
///
/// Startup must not depend on the network, so this is capped rather than
/// awaited: `timeout` gives up on *waiting*, not on the request, so a slow
/// fetch keeps going and lands in the provider once Home is already up. A
/// returning user usually has today's cache hydrated by then anyway; this
/// mainly buys a first-launch user a populated Home when the network is quick.
///
/// The profile is read straight from prefs — the same uid-namespaced read
/// `FajrWidgetService` does — because `ChallengeProvider` does not exist yet
/// this early. Device location is deliberately not consulted: no permission
/// dialog belongs over a splash screen.
Future<void> _refreshPrayerTimesWithinBudget(
  SharedPreferences prefs,
  String uid,
  PrayerTimeProvider prayerProvider,
) async {
  try {
    final challengeData = ChallengeLocalDataSource(prefs, uid: uid).load();
    final refresh = prayerProvider.loadForProfile(
      hasLocation: challengeData.hasLocation,
      hasUsableCoordinates: challengeData.hasUsableCoordinates,
      latitude: challengeData.userLatitude,
      longitude: challengeData.userLongitude,
      cityCountry: challengeData.cityCountry,
      allowDeviceLocation: false,
    );
    await refresh.timeout(_prayerRefreshBootBudget, onTimeout: () {});
  } catch (e) {
    // Boot must survive a failed prayer-times refresh: Home renders from
    // cache (or its own loading state) and retries there.
    debugPrint('Boot prayer-times refresh skipped: $e');
  }
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

class SubhWarriorApp extends StatefulWidget {
  final SharedPreferences prefs;

  const SubhWarriorApp({super.key, required this.prefs});

  @override
  State<SubhWarriorApp> createState() => _SubhWarriorAppState();
}

class _SubhWarriorAppState extends State<SubhWarriorApp> {
  /// Kicked off once so a rebuild never restarts boot; replaced only by an
  /// explicit retry from the splash screen.
  /// Built here rather than inside the provider tree so [_bootstrap] can start
  /// its prayer-times refresh against the very instance the UI will read.
  late final PrayerTimeProvider _prayerProvider =
      PrayerTimeProvider.fromPrefs(widget.prefs);

  late Future<_Services> _services = _bootstrap(widget.prefs, _prayerProvider);

  void _retry() =>
      setState(() => _services = _bootstrap(widget.prefs, _prayerProvider));

  @override
  void dispose() {
    _prayerProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Theme, locale and prayer-times providers need only SharedPreferences, so
    // they sit above the boot gate and the splash is themed and localized like
    // the rest of the app.
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider(widget.prefs)),
        ChangeNotifierProvider(create: (_) => LocaleProvider(widget.prefs)),
        // `.value`: this state owns the instance (and disposes it) so boot can
        // warm it before the tree mounts.
        ChangeNotifierProvider<PrayerTimeProvider>.value(
            value: _prayerProvider),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeProvider, localeProvider, _) {
          return FutureBuilder<_Services>(
            future: _services,
            builder: (context, snapshot) {
              final services = snapshot.data;
              return _AppShell(
                themeProvider: themeProvider,
                localeProvider: localeProvider,
                prefs: widget.prefs,
                services: services,
                error: snapshot.error,
                onRetry: _retry,
              );
            },
          );
        },
      ),
    );
  }
}

/// Builds the `MaterialApp`. Until [services] arrives the home is the splash
/// screen; after that the Firebase-dependent providers wrap the real router.
///
/// The auth providers have to sit *above* `MaterialApp` because named routes
/// like `/settings` read `ChallengeProvider`, so this rebuilds the whole
/// `MaterialApp` once when boot completes — a single swap, not per-frame work.
class _AppShell extends StatelessWidget {
  const _AppShell({
    required this.themeProvider,
    required this.localeProvider,
    required this.prefs,
    required this.services,
    required this.error,
    required this.onRetry,
  });

  final ThemeProvider themeProvider;
  final LocaleProvider localeProvider;
  final SharedPreferences prefs;
  final _Services? services;
  final Object? error;
  final VoidCallback onRetry;

  MaterialApp _app({required Widget home}) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: localeProvider.locale,
      builder: (context, child) {
        // Keep intl's global locale in sync so bare DateFormat /
        // NumberFormat calls (prayer times, dates) use the app locale's
        // native digits and month names.
        Intl.defaultLocale = Localizations.localeOf(context).toString();
        return child!;
      },
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeProvider.themeMode,
      home: home,
      routes: {
        '/auth': (context) => const AuthScreen(),
        '/home': (context) => const HomeScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ready = services;
    if (ready == null) {
      // Boot failed (no network on a first launch, Firebase misconfigured):
      // the splash offers a retry rather than hanging on the brand mark.
      return _app(
        home: SplashScreen(bootFailed: error != null, onRetry: onRetry),
      );
    }

    return MultiProvider(
      providers: [
        Provider<AuthService>.value(value: ready.authService),
        Provider<AnalyticsService>.value(value: ready.analytics),
        Provider<PerformanceService>.value(value: ready.performance),
      ],
      child: StreamBuilder<User?>(
        stream: ready.authService.authStateChanges(),
        initialData: ready.authService.currentUser,
        builder: (context, snapshot) {
          final user = snapshot.data;
          final uid = user?.uid ?? '';
          return ChangeNotifierProvider<ChallengeProvider>(
            key: ValueKey(uid),
            create: (_) => ChallengeProvider.fromPrefs(prefs,
                uid: uid, analytics: ready.analytics),
            child: _app(home: _RootRouter(user: user)),
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
