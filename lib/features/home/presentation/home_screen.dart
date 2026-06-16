import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:subh_warrior/features/challenge/presentation/challenge_controller.dart';
import 'package:subh_warrior/features/leaderboard/presentation/leaderboard_screen.dart';
import 'package:subh_warrior/features/prayer_times/presentation/prayer_times_controller.dart';
import 'package:subh_warrior/helpers/notification_permission.dart';
import 'package:subh_warrior/helpers/notification_service.dart';
import 'package:subh_warrior/screens/progress_screen.dart';
import 'package:subh_warrior/widgets/prayer_time_card.dart';
import 'package:subh_warrior/widgets/streak_card.dart';

import 'widgets/greeting_header.dart';
import 'widgets/inactive_challenge_view.dart';
import 'widgets/motivational_quote_card.dart';
import 'widgets/quick_stats_row.dart';
import 'widgets/today_status_card.dart';
import 'widgets/weekly_progress_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _loadPrayerTimes();
    await _checkNotificationPermission();
    _setupNotifications();
  }

  Future<void> _loadPrayerTimes() async {
    final challengeProvider = context.read<ChallengeProvider>();
    final prayerProvider = context.read<PrayerTimeProvider>();

    if (challengeProvider.hasLocation) {
      await prayerProvider.fetchPrayerTimes(
        challengeProvider.userLatitude,
        challengeProvider.userLongitude,
      );
    }
  }

  Future<void> _setupNotifications() async {
    final challengeProvider = context.read<ChallengeProvider>();
    final prayerProvider = context.read<PrayerTimeProvider>();
    NotificationService.updateNotifications(
      notificationsEnabled: challengeProvider.notificationsEnabled,
      fajrReminder: challengeProvider.fajrReminder,
      loggingReminder: challengeProvider.loggingReminder,
      fajrReminderMinutes: challengeProvider.fajrReminderMinutes,
      todayFajrTime: prayerProvider.todayFajrTime,
      isChallengeActive: challengeProvider.isChallengeActive,
    );
  }

  Future<void> _checkNotificationPermission() async {
    await incrementLaunchCount();
    if (mounted) {
      await ensureNotificationPermission(context);
    }
  }

  Future<void> _startChallenge(ChallengeProvider provider) async {
    await provider.startChallenge();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Challenge started — log your first day!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildDashboard(),
          const ProgressScreen(),
          const LeaderboardScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.timeline_outlined),
            selectedIcon: Icon(Icons.timeline),
            label: 'Progress',
          ),
          NavigationDestination(
            icon: Icon(Icons.leaderboard_outlined),
            selectedIcon: Icon(Icons.leaderboard),
            label: 'Leaderboard',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return SafeArea(
      child: Consumer<ChallengeProvider>(
        builder: (context, provider, _) {
          if (!provider.isChallengeActive) {
            return InactiveChallengeView(
              onStart: () => _startChallenge(provider),
            );
          }

          return CustomScrollView(
            slivers: [
              _buildAppBar(context),
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    GreetingHeader(userName: provider.userName),
                    const SizedBox(height: 20),
                    const PrayerTimeCard(),
                    const SizedBox(height: 16),
                    TodayStatusCard(
                      todayLog: provider.getTodayLog(),
                      canLog: provider.canLogToday(),
                    ),
                    const SizedBox(height: 16),
                    StreakCard(
                      currentStreak: provider.currentStreak,
                      totalDays: provider.totalQualifyingDays,
                    ),
                    const SizedBox(height: 16),
                    WeeklyProgressCard(
                      weeklyProgress: provider.weeklyProgress,
                      currentWeek: provider.currentWeek,
                    ),
                    const SizedBox(height: 16),
                    QuickStatsRow(
                      daysRemaining: provider.daysRemaining,
                      overallProgress: provider.overallProgress,
                      totalQualifyingDays: provider.totalQualifyingDays,
                    ),
                    const SizedBox(height: 20),
                    const MotivationalQuoteCard(),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Primary + its `on` color is a guaranteed-contrast pair in both light and
    // dark mode — no washout, no hardcoded colors.
    final onBanner = scheme.onPrimary;
    return SliverAppBar(
      expandedHeight: 96,
      pinned: true,
      // Solid primary when collapsed (the gradient lives in flexibleSpace and
      // fades out on collapse, otherwise the bar shows surface = looks
      // transparent over the scrolling content).
      backgroundColor: scheme.primary,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      foregroundColor: onBanner,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        titlePadding: const EdgeInsets.only(bottom: 14),
        title: Text(
          'Subh Warrior',
          style: TextStyle(
            color: onBanner,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        background: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [scheme.primary, scheme.tertiary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.settings, color: onBanner),
          onPressed: () => Navigator.pushNamed(context, '/settings'),
        ),
      ],
    );
  }
}
