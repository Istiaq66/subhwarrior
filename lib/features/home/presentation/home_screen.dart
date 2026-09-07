import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:subh_warrior/core/l10n/app_localizations.dart';
import 'package:subh_warrior/core/theme/app_spacing.dart';
import 'package:subh_warrior/features/challenge/presentation/challenge_controller.dart';
import 'package:subh_warrior/features/leaderboard/presentation/leaderboard_screen.dart';
import 'package:subh_warrior/features/prayer_times/presentation/prayer_times_controller.dart';
import 'package:subh_warrior/features/share/presentation/share_sheet.dart';
import 'package:subh_warrior/helpers/notification_permission.dart';
import 'package:subh_warrior/helpers/notification_service.dart';
import 'package:subh_warrior/screens/progress_screen.dart';
import 'package:subh_warrior/widgets/prayer_time_card.dart';

import 'widgets/challenge_completion_view.dart';
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

    if (!challengeProvider.hasLocation) return;

    if (challengeProvider.hasUsableCoordinates) {
      await prayerProvider.fetchPrayerTimes(
        challengeProvider.userLatitude,
        challengeProvider.userLongitude,
      );
      return;
    }

    // Profile has a location name but no coordinates (sign-up writes 0,0, and
    // remote profiles saved without coordinates restore as 0,0). Looking the
    // city up by name is far better than fetching 0,0, which the API rejects
    // with HTTP 400 and which surfaced as a permanent "unable to load prayer
    // times" card.
    final parts = challengeProvider.userLocation.split(',');
    if (parts.length >= 2) {
      final city = parts.first.trim();
      final country = parts.sublist(1).join(',').trim();
      if (city.isNotEmpty && country.isNotEmpty) {
        await prayerProvider.fetchPrayerTimesByCity(city, country);
        return;
      }
    }

    // Only a bare name (or nothing usable) — ask the device instead.
    await prayerProvider.fetchPrayerTimesForCurrentLocation();
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
      SnackBar(
        content: Text(AppLocalizations.of(context)!.homeChallengeStartedSnack),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.homeNavHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.timeline_outlined),
            selectedIcon: const Icon(Icons.timeline),
            label: l10n.homeNavProgress,
          ),
          NavigationDestination(
            icon: const Icon(Icons.leaderboard_outlined),
            selectedIcon: const Icon(Icons.leaderboard),
            label: l10n.homeNavLeaderboard,
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
            if (provider.hasUnseenCompletion) {
              return ChallengeCompletionView(
                goalMet: provider.challengeGoalMet,
                finalStreak: provider.currentStreak,
                totalQualifyingDays: provider.totalQualifyingDays,
                currentWeek: provider.currentWeek,
                onShare: () => showShareSheet(
                  context,
                  currentStreak: provider.currentStreak,
                  totalQualifyingDays: provider.totalQualifyingDays,
                  currentWeek: provider.currentWeek,
                ),
                onRestart: () => _startChallenge(provider),
              );
            }
            return InactiveChallengeView(
              onStart: () => _startChallenge(provider),
            );
          }

          return CustomScrollView(
            slivers: [
              _buildAppBar(context),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.lg,
                ),
                sliver: SliverList(
                  // Section order follows the design comps: greeting, the
                  // today hero, then prayer times, week, stats, quote.
                  delegate: SliverChildListDelegate([
                    GreetingHeader(userName: provider.userName),
                    AppSpacing.vGapXl,
                    TodayStatusCard(
                      todayLog: provider.getTodayLog(),
                      canLog: provider.canLogToday(),
                    ),
                    AppSpacing.vGapXl,
                    // Not in the comps, which show Fajr only — kept because it
                    // carries the other five prayer times, and dropping it
                    // would remove a feature rather than restyle one.
                    const PrayerTimeCard(),
                    AppSpacing.vGapXl,
                    WeeklyProgressCard(dayLogs: provider.dayLogs),
                    AppSpacing.vGapXl,
                    QuickStatsRow(
                      currentStreak: provider.currentStreak,
                      totalQualifyingDays: provider.totalQualifyingDays,
                      daysRemaining: provider.daysRemaining,
                      onShare: () => showShareSheet(
                        context,
                        currentStreak: provider.currentStreak,
                        totalQualifyingDays: provider.totalQualifyingDays,
                        currentWeek: provider.currentWeek,
                      ),
                    ),
                    AppSpacing.vGapXl,
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

  /// Flat parchment bar with the wordmark leading and a circular settings
  /// button trailing, per the design comps.
  ///
  /// This replaces a `primary → tertiary` gradient banner. That gradient was
  /// fine while `tertiary` was a pale peach, but the palette makes it a warm
  /// ochre, which put the bar's white title at roughly 1.9:1 on the trailing
  /// end. A flat surface with primary-coloured text sidesteps it entirely.
  Widget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    // Mirrors the comp's `<header>`: `bg-background`, `px-4 py-3`, a 24px
    // leading icon, an 18px bold wordmark, and a 40x40 `bg-surface` circle
    // holding the settings action. py-3 + a 40px control = a 64px bar.
    return SliverAppBar(
      pinned: true,
      centerTitle: false,
      toolbarHeight: 64,
      titleSpacing: AppSpacing.md,
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      foregroundColor: scheme.primary,
      title: Row(
        children: [
          Icon(Icons.person, color: scheme.primary, size: 24),
          const SizedBox(width: 12),
          Text(
            AppLocalizations.of(context)!.homeAppBarTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsetsDirectional.only(end: AppSpacing.md),
          child: SizedBox(
            width: 40,
            height: 40,
            child: Material(
              color: scheme.surfaceContainerLow,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: IconButton(
                padding: EdgeInsets.zero,
                iconSize: 20,
                constraints: const BoxConstraints.tightFor(
                  width: 40,
                  height: 40,
                ),
                icon: Icon(Icons.settings, color: scheme.primary),
                tooltip: AppLocalizations.of(context)!.a11yOpenSettings,
                onPressed: () => Navigator.pushNamed(context, '/settings'),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
