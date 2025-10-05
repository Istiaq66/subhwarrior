import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:subh_warrior/providers/challenge_provider.dart';
import 'package:subh_warrior/providers/prayer_time_provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:subh_warrior/screens/leader_board_screen.dart';
import 'package:subh_warrior/screens/progress_screen.dart';
import 'package:subh_warrior/widgets/prayer_time_card.dart';
import 'package:subh_warrior/widgets/streak_card.dart';
import 'logday_screen.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPrayerTimes();
    });
  }

  Future<void> _loadPrayerTimes() async {
    final challengeProvider = context.read<ChallengeProvider>();
    final prayerProvider = context.read<PrayerTimeProvider>();

    if (challengeProvider.userLatitude != 0 && challengeProvider.userLongitude != 0) {
      await prayerProvider.fetchPrayerTimes(
        challengeProvider.userLatitude,
        challengeProvider.userLongitude,
      );
    }
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
        builder: (context, challengeProvider, _) {
          if (!challengeProvider.isChallengeActive) {
            return _buildInactiveChallenge(challengeProvider);
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 120,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text('Subh Warrior'),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.settings,color: Colors.white,),
                    onPressed: () {
                      Navigator.pushNamed(context, '/settings');
                    },
                  ),
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildGreeting(challengeProvider),
                    const SizedBox(height: 20),
                    const PrayerTimeCard(),
                    const SizedBox(height: 16),
                    _buildTodayStatus(challengeProvider),
                    const SizedBox(height: 16),
                    StreakCard(
                      currentStreak: challengeProvider.currentStreak,
                      totalDays: challengeProvider.totalQualifyingDays,
                    ),
                    const SizedBox(height: 16),
                    _buildWeeklyProgress(challengeProvider),
                    const SizedBox(height: 16),
                    _buildQuickStats(challengeProvider),
                    const SizedBox(height: 20),
                    _buildMotivationalQuote(),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGreeting(ChallengeProvider provider) {
    final hour = DateTime.now().hour;
    String greeting = 'Assalamu Alaikum';

    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        Text(
          provider.userName.isNotEmpty ? provider.userName : 'Warrior',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTodayStatus(ChallengeProvider provider) {
    final todayLog = provider.getTodayLog();
    final canLog = provider.canLogToday();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Today\'s Status',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Chip(
                  label: Text(
                    todayLog != null
                        ? (todayLog.isQualifying ? 'Qualifying ✓' : 'Logged')
                        : (canLog ? 'Pending' : 'Time\'s Up'),
                  ),
                  backgroundColor: todayLog != null
                      ? (todayLog.isQualifying ? Colors.green : Colors.orange)
                      : (canLog ? Colors.blue : Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (todayLog != null) ...[
              _buildStatusRow(Icons.mosque, 'Fajr Prayer',
                  todayLog.prayedFajrOnTime ? 'On Time' : 'Missed'),
              _buildStatusRow(Icons.work, 'Work Time',
                  '${todayLog.minutesWorked} minutes'),
              if (todayLog.workDescription.isNotEmpty)
                _buildStatusRow(Icons.description, 'Work',
                    todayLog.workDescription),
            ] else if (canLog) ...[
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LogDayScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_circle),
                  label: const Text('Log Today'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ] else ...[
              Text(
                'Logging window closed (after 8 AM)',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Text(label),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              maxLines: 2,
              style: const TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyProgress(ChallengeProvider provider) {
    final weekProgress = provider.weeklyProgress;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Progress',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ...List.generate(4, (index) {
              final week = index + 1;
              final progress = weekProgress[week] ?? 0;
              final isCurrentWeek = provider.currentWeek == week;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Week $week',
                          style: TextStyle(
                            fontWeight: isCurrentWeek
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        Text('$progress/4'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: progress / 4,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progress >= 4
                            ? Colors.green
                            : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(ChallengeProvider provider) {
    return Row(
      children: [
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 32,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${provider.daysRemaining}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const Text('Days Left'),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  CircularPercentIndicator(
                    radius: 30.0,
                    lineWidth: 5.0,
                    percent: provider.overallProgress.clamp(0, 1),
                    center: Text('${(provider.overallProgress * 100).toInt()}%'),
                    progressColor: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${provider.totalQualifyingDays}/16',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const Text('Goal Progress'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMotivationalQuote() {
    final quotes = [
      '"The early morning has gold in its mouth." - Benjamin Franklin',
      '"Lose an hour in the morning, and you will spend all day looking for it." - Richard Whately',
      '"Success comes to those who have the willpower to win over their snooze buttons." - Unknown',
      '"The sun has not caught me in bed in fifty years." - Thomas Jefferson',
      '"Every morning we are born again. What we do today is what matters most." - Buddha',
    ];

    final quoteIndex = DateTime.now().day % quotes.length;

    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(
              Icons.format_quote,
              size: 32,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            const SizedBox(height: 8),
            Text(
              quotes[quoteIndex],
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontStyle: FontStyle.italic,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInactiveChallenge(ChallengeProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wb_sunny,
              size: 100,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Ready to become a Subh Warrior?',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Start your 28-day challenge to build a powerful morning routine with Fajr prayer and productive work.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () async {
                await provider.startChallenge();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Challenge starts this Sunday!'),
                  ),
                );
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Challenge'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}