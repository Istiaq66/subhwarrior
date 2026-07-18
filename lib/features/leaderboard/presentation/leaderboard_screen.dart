import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:subh_warrior/core/l10n/app_localizations.dart';
import 'package:subh_warrior/core/l10n/l10n_utils.dart';
import 'package:subh_warrior/core/theme/app_colors.dart';
import 'package:subh_warrior/features/challenge/presentation/challenge_controller.dart';
import 'package:subh_warrior/features/leaderboard/data/leaderboard_repository.dart';
import 'package:subh_warrior/features/leaderboard/domain/leaderboard_entry.dart';
import 'package:subh_warrior/shared/widgets/empty_view.dart';
import 'package:subh_warrior/shared/widgets/error_view.dart';
import 'package:subh_warrior/shared/widgets/loading_view.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final LeaderboardRepository _repository = LeaderboardRepositoryImpl();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeNavLeaderboard),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.leaderboardTabGlobal),
            Tab(text: l10n.leaderboardTabFriends),
            Tab(text: l10n.leaderboardTabLocal),
          ],
        ),
      ),
      // Period filter (week/month/all-time) was removed: it changed the UI
      // but never filtered the query. Re-add once per-period aggregates are
      // stored server-side (see IMPROVEMENT_PLAN A3 / Phase D).
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGlobalLeaderboard(),
          _buildFriendsLeaderboard(),
          _buildLocalLeaderboard(),
        ],
      ),
    );
  }

  Widget _buildGlobalLeaderboard() {
    return _buildEntryStream(
      stream: _repository.global(),
      emptyBuilder: () => _buildEmptyLeaderboard(),
    );
  }

  Widget _buildFriendsLeaderboard() {
    final l10n = AppLocalizations.of(context)!;
    return EmptyView(
      icon: Icons.people_outline,
      title: l10n.leaderboardFriendsComingSoon,
      subtitle: l10n.leaderboardFriendsSubtitle,
    );
  }

  Widget _buildLocalLeaderboard() {
    final l10n = AppLocalizations.of(context)!;
    final userLocation = context.read<ChallengeProvider>().userLocation;

    if (userLocation.isEmpty) {
      return EmptyView(
        icon: Icons.location_off,
        title: l10n.leaderboardSetLocationTitle,
        action: ElevatedButton(
          onPressed: () => Navigator.pushNamed(context, '/settings'),
          child: Text(l10n.leaderboardSetLocationButton),
        ),
      );
    }

    return _buildEntryStream(
      stream: _repository.local(userLocation),
      emptyBuilder: () => _buildEmptyLeaderboard(isLocal: true),
    );
  }

  /// Shared list/loading/error/empty handling for an entry stream.
  Widget _buildEntryStream({
    required Stream<List<LeaderboardEntry>> stream,
    required Widget Function() emptyBuilder,
  }) {
    return StreamBuilder<List<LeaderboardEntry>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingView();
        }

        if (snapshot.hasError) {
          return ErrorView(
            message: AppLocalizations.of(context)!.leaderboardLoadError,
            detail: snapshot.error.toString(),
          );
        }

        final entries = snapshot.data ?? const [];
        if (entries.isEmpty) {
          return emptyBuilder();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            return _buildLeaderboardItem(
              rank: index + 1,
              entry: entry,
              isCurrentUser: _isCurrentUser(entry.userName),
            );
          },
        );
      },
    );
  }

  Widget _buildLeaderboardItem({
    required int rank,
    required LeaderboardEntry entry,
    bool isCurrentUser = false,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final medal = _getMedal(rank);
    final rankColor = _getRankColor(rank);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color:
          isCurrentUser ? Theme.of(context).colorScheme.primaryContainer : null,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: rankColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: rankColor,
              width: 2,
            ),
          ),
          child: Center(
            child: medal != null
                ? Text(
                    medal,
                    style: const TextStyle(fontSize: 24),
                    semanticsLabel: _getMedalSemanticsLabel(l10n, rank),
                  )
                : Text(
                    context.localizeNumber(rank),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: rankColor,
                    ),
                  ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                entry.userName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isCurrentUser
                      ? Theme.of(context).colorScheme.onPrimaryContainer
                      : null,
                ),
              ),
            ),
            if (isCurrentUser)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  l10n.leaderboardYouBadge,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Text(
          entry.location,
          style: TextStyle(
            fontSize: 12,
            color: isCurrentUser
                ? Theme.of(context)
                    .colorScheme
                    .onPrimaryContainer
                    .withValues(alpha: 0.7)
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle,
                    size: 16, color: context.appColors.success),
                const SizedBox(width: 4),
                Text(
                  l10n.leaderboardDaysCount(entry.qualifyingDays),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.local_fire_department,
                  size: 14,
                  color: entry.currentStreak > 0
                      ? context.appColors.warning
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  l10n.leaderboardStreakCount(entry.currentStreak),
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyLeaderboard({bool isLocal = false}) {
    final l10n = AppLocalizations.of(context)!;
    return EmptyView(
      icon: Icons.emoji_events_outlined,
      title: isLocal
          ? l10n.leaderboardEmptyLocalTitle
          : l10n.leaderboardEmptyGlobalTitle,
      subtitle: isLocal
          ? l10n.leaderboardEmptyLocalSubtitle
          : l10n.leaderboardEmptyGlobalSubtitle,
    );
  }

  bool _isCurrentUser(String userName) {
    final currentUserName = context.read<ChallengeProvider>().userName;
    return userName == currentUserName;
  }

  String? _getMedal(int rank) {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return null;
    }
  }

  String? _getMedalSemanticsLabel(AppLocalizations l10n, int rank) {
    switch (rank) {
      case 1:
        return l10n.a11yFirstPlace;
      case 2:
        return l10n.a11ySecondPlace;
      case 3:
        return l10n.a11yThirdPlace;
      default:
        return null;
    }
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return context.appColors.gold;
      case 2:
        return context.appColors.silver;
      case 3:
        return context.appColors.bronze;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }
}
