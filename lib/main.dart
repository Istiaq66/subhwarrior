import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:subh_warrior/helpers/notification_service.dart';
import 'package:subh_warrior/providers/challenge_provider.dart';
import 'package:subh_warrior/providers/prayer_time_provider.dart';
import 'package:subh_warrior/providers/theme_provider.dart';
import 'package:subh_warrior/screens/home.dart';
import 'package:provider/provider.dart';
import 'package:subh_warrior/screens/onboarding_screen.dart';
import 'package:subh_warrior/screens/settings_screen.dart';
import 'package:subh_warrior/screens/splash_screen.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize timezone
  tz.initializeTimeZones();

  // Initialize notifications
  NotificationService.initialize();

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
        ChangeNotifierProvider(create: (_) => PrayerTimeProvider(prefs)),
        ChangeNotifierProvider(create: (_) => ChallengeProvider(prefs)),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Subh Warrior Challenge',
            debugShowCheckedModeBanner: false,
            theme: _buildTheme(themeProvider.isDarkMode),
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

  ThemeData _buildTheme(bool isDarkMode) {
    return ThemeData(
      useMaterial3: true,
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1B5E20), // Islamic green
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}