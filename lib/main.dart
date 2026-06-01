import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:subh_warrior/helpers/notification_service.dart';
import 'package:subh_warrior/features/challenge/presentation/challenge_controller.dart';
import 'package:subh_warrior/features/prayer_times/presentation/prayer_times_controller.dart';
import 'package:subh_warrior/providers/theme_provider.dart';
import 'package:subh_warrior/core/theme/app_theme.dart';
import 'package:subh_warrior/features/home/presentation/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:subh_warrior/screens/onboarding_screen.dart';
import 'package:subh_warrior/screens/settings_screen.dart';
import 'package:subh_warrior/screens/splash_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize notifications
  NotificationService().initBackground();

  // Load preferences
  final prefs = await SharedPreferences.getInstance();

  runApp(SubhWarriorApp(prefs: prefs));
}

class SubhWarriorApp extends StatelessWidget {
  final SharedPreferences prefs;

  const SubhWarriorApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(
            create: (_) => PrayerTimeProvider.fromPrefs(prefs)),
        ChangeNotifierProvider(
            create: (_) => ChallengeProvider.fromPrefs(prefs)),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Subh Warrior Challenge',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: themeProvider.themeMode,
            home: _getInitialScreen(),
            routes: {
              '/home': (context) => const HomeScreen(),
              '/onboarding': (context) => const OnboardingScreen(),
              '/settings': (context) => const SettingsScreen(),
            },
          );
        },
      ),
    );
  }

  Widget _getInitialScreen() {
    final isFirstTime = prefs.getBool('isFirstTime') ?? true;
    if (isFirstTime) {
      return const OnboardingScreen();
    }
    return const SplashScreen();
  }
}
