import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:subh_warrior/core/l10n/app_localizations.dart';
import 'package:subh_warrior/core/theme/app_theme.dart';
import 'package:subh_warrior/features/auth/data/auth_service.dart';
import 'package:subh_warrior/features/challenge/data/challenge_local_data_source.dart';
import 'package:subh_warrior/features/challenge/presentation/challenge_controller.dart';
import 'package:subh_warrior/features/home/presentation/home_screen.dart';
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

  // Initialize notifications
  NotificationService().initBackground();

  // Load preferences
  final prefs = await SharedPreferences.getInstance();

  await ChallengeLocalDataSource.migrateLegacyIfNeeded(prefs, uid);

  runApp(SubhWarriorApp(prefs: prefs, authService: authService));
}

class SubhWarriorApp extends StatelessWidget {
  final SharedPreferences prefs;
  final AuthService authService;

  const SubhWarriorApp({
    super.key,
    required this.prefs,
    required this.authService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>.value(value: authService),
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
                create: (_) => ChallengeProvider.fromPrefs(prefs, uid: uid),
                child: MaterialApp(
                  onGenerateTitle: (context) =>
                      AppLocalizations.of(context)!.appTitle,
                  debugShowCheckedModeBanner: false,
                  localizationsDelegates:
                      AppLocalizations.localizationsDelegates,
                  supportedLocales: AppLocalizations.supportedLocales,
                  locale: localeProvider.locale,
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
