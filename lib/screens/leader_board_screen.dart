import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:subh_warrior/providers/challenge_provider.dart';
import 'package:subh_warrior/core/theme/app_colors.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Global'),
            Tab(text: 'Friends'),
            Tab(text: 'Local'),
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
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('challenges')
          .orderBy('totalQualifyingDays', descending: true)
          .limit(100)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingView();
        }

        if (snapshot.hasError) {
          return ErrorView(detail: snapshot.error.toString());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyLeaderboard();
        }

        final docs = snapshot.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            return _buildLeaderboardItem(
              rank: index + 1,
              name: data['userName'] ?? 'Anonymous',
              location: data['location'] ?? '',
              qualifyingDays: data['totalQualifyingDays'] ?? 0,
              currentStreak: data['currentStreak'] ?? 0,
              isCurrentUser: _isCurrentUser(data['userName']),
            );
          },
        );
      },
    );
  }

  Widget _buildFriendsLeaderboard() {
    return const EmptyView(
      icon: Icons.people_outline,
      title: 'Friend leaderboard coming soon!',
      subtitle: 'Connect with friends to compete together',
    );
  }

  Widget _buildLocalLeaderboard() {
    final userLocation = context.read<ChallengeProvider>().userLocation;

    if (userLocation.isEmpty) {
      return EmptyView(
        icon: Icons.location_off,
        title: 'Set your location to see local warriors',
        action: ElevatedButton(
          onPressed: () => Navigator.pushNamed(context, '/settings'),
          child: const Text('Set Location'),
        ),
      );
    }

    // FIXED: Remove the orderBy to avoid needing composite index
    // Just filter by location
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('challenges')
          .where('location', isEqualTo: userLocation)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingView();
        }

        if (snapshot.hasError) {
          return ErrorView(
            message: 'Error loading leaderboard',
            detail: snapshot.error.toString(),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyLeaderboard(isLocal: true);
        }

        // Sort in-memory after fetching
        final docs = snapshot.data!.docs.toList();
        docs.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          final aScore = aData['totalQualifyingDays'] ?? 0;
          final bScore = bData['totalQualifyingDays'] ?? 0;
          return bScore.compareTo(aScore); // Descending order
        });

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            return _buildLeaderboardItem(
              rank: index + 1,
              name: data['userName'] ?? 'Anonymous',
              location: data['location'] ?? '',
              qualifyingDays: data['totalQualifyingDays'] ?? 0,
              currentStreak: data['currentStreak'] ?? 0,
              isCurrentUser: _isCurrentUser(data['userName']),
            );
          },
        );
      },
    );
  }

  Widget _buildLeaderboardItem({
    required int rank,
    required String name,
    required String location,
    required int qualifyingDays,
    required int currentStreak,
    bool isCurrentUser = false,
  }) {
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
                  )
                : Text(
                    '$rank',
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
                name,
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
                  'YOU',
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
          location,
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
                  '$qualifyingDays days',
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
                  color: currentStreak > 0
                      ? context.appColors.warning
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  '$currentStreak streak',
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
    return EmptyView(
      icon: Icons.emoji_events_outlined,
      title: isLocal ? 'No warriors in your area yet!' : 'No data available',
      subtitle: isLocal
          ? 'Be the first to start the challenge'
          : 'Start your challenge to appear here',
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
