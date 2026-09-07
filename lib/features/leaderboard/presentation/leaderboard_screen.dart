import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:subh_warrior/core/l10n/app_localizations.dart';
import 'package:subh_warrior/core/l10n/l10n_utils.dart';
import 'package:subh_warrior/core/theme/app_colors.dart';
import 'package:subh_warrior/core/theme/app_spacing.dart';
import 'package:subh_warrior/features/challenge/presentation/challenge_controller.dart';
import 'package:subh_warrior/features/leaderboard/data/leaderboard_repository.dart';
import 'package:subh_warrior/features/leaderboard/domain/leaderboard_entry.dart';
import 'package:subh_warrior/shared/widgets/empty_view.dart';
import 'package:subh_warrior/shared/widgets/error_view.dart';
import 'package:subh_warrior/shared/widgets/loading_view.dart';

/// Leaderboard: a segmented scope control, a top-three podium, then ranked
/// rows with the current user emphasised and pinned in a footer strip.
///
/// Built from the design comps. Two deliberate departures, both because the
/// comp shows data this app does not have:
///  * the comp's segmented control offers "This Week / All Time", but the
///    repository exposes global/friends/local scopes, so those are the
///    segments. Period filtering needs server-side per-period aggregates
///    (IMPROVEMENT_PLAN A3 / Phase D).
///  * the comp uses profile photos; [LeaderboardEntry] carries no avatar, so
///    rows show a monogram instead of inventing an image.
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final LeaderboardRepository _repository = LeaderboardRepositoryImpl();
  int _scope = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.homeNavLeaderboard)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.md,
            ),
            child: _ScopeSelector(
              labels: [
                l10n.leaderboardTabGlobal,
                l10n.leaderboardTabFriends,
                l10n.leaderboardTabLocal,
              ],
              selected: _scope,
              onChanged: (i) => setState(() => _scope = i),
            ),
          ),
          Expanded(child: _buildScope()),
        ],
      ),
    );
  }

  Widget _buildScope() {
    switch (_scope) {
      case 1:
        return _buildFriendsLeaderboard();
      case 2:
        return _buildLocalLeaderboard();
      default:
        return _buildEntryStream(
          stream: _repository.global(),
          emptyBuilder: () => _buildEmptyLeaderboard(),
        );
    }
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
        action: FilledButton(
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

        final entries = snapshot.data ?? const <LeaderboardEntry>[];
        if (entries.isEmpty) return emptyBuilder();

        final currentUserName = context.read<ChallengeProvider>().userName;
        final myIndex =
            entries.indexWhere((e) => e.userName == currentUserName);
        final podium = entries.take(3).toList();
        final rest = entries.length > 3 ? entries.sublist(3) : const [];

        return Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                // Room for the pinned rank strip.
                AppSpacing.xxl + AppSpacing.md,
              ),
              children: [
                if (podium.length == 3) ...[
                  _Podium(
                    entries: podium,
                    currentUserName: currentUserName,
                  ),
                  AppSpacing.vGapLg,
                ],
                for (var i = 0; i < rest.length; i++) ...[
                  if (i > 0) AppSpacing.vGapSm,
                  _RankRow(
                    rank: i + 4,
                    entry: rest[i],
                    isCurrentUser: rest[i].userName == currentUserName,
                  ),
                ],
                if (podium.length < 3)
                  for (var i = 0; i < podium.length; i++) ...[
                    if (i > 0) AppSpacing.vGapSm,
                    _RankRow(
                      rank: i + 1,
                      entry: podium[i],
                      isCurrentUser: podium[i].userName == currentUserName,
                    ),
                  ],
              ],
            ),
            // Comp's sticky strip: only useful once the user is outside the
            // podium, otherwise it repeats what is already on screen.
            if (myIndex >= 3)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _RankStrip(rank: myIndex + 1, entry: entries[myIndex]),
              ),
          ],
        );
      },
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
}

/// Full-round segmented control: the active segment is a primary fill, the
/// rest are plain text on the canvas.
class _ScopeSelector extends StatelessWidget {
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;

  const _ScopeSelector({
    required this.labels,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: AppRadius.brFull,
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: Semantics(
                selected: i == selected,
                button: true,
                child: InkWell(
                  borderRadius: AppRadius.brFull,
                  onTap: () => onChanged(i),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: i == selected ? scheme.primary : null,
                      borderRadius: AppRadius.brFull,
                    ),
                    child: Text(
                      labels[i],
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: i == selected
                            ? scheme.onPrimary
                            : scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Top-three podium: 1st is centre and tallest, with medal-coloured badges.
class _Podium extends StatelessWidget {
  final List<LeaderboardEntry> entries;
  final String currentUserName;

  const _Podium({required this.entries, required this.currentUserName});

  @override
  Widget build(BuildContext context) {
    // Visual order places second on the left and third on the right.
    final order = [1, 0, 2];
    const heights = {0: 160.0, 1: 132.0, 2: 120.0};

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final rankIndex in order)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              child: _PodiumColumn(
                rank: rankIndex + 1,
                entry: entries[rankIndex],
                height: heights[rankIndex]!,
                isCurrentUser: entries[rankIndex].userName == currentUserName,
              ),
            ),
          ),
      ],
    );
  }
}

class _PodiumColumn extends StatelessWidget {
  final int rank;
  final LeaderboardEntry entry;
  final double height;
  final bool isCurrentUser;

  const _PodiumColumn({
    required this.rank,
    required this.entry,
    required this.height,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final medalColor = _medalColor(context, rank);
    final avatarSize = rank == 1 ? 72.0 : 56.0;

    // The avatar overlaps the pedestal by half its height, so all three
    // columns share one overlap regardless of pedestal height.
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Padding(
          padding: EdgeInsets.only(top: avatarSize / 2),
          child: Card(
          shape: isCurrentUser
              ? RoundedRectangleBorder(
                  borderRadius: AppRadius.brLg,
                  side: BorderSide(color: scheme.secondary),
                )
              : null,
          color: isCurrentUser ? scheme.primaryContainer : null,
          child: SizedBox(
            width: double.infinity,
            height: height,
            child: Padding(
              // Top inset clears the avatar overlapping the pedestal — the
              // comp's `pt-8` serves the same purpose.
              padding: EdgeInsets.only(
                top: avatarSize / 2 + AppSpacing.md,
                left: AppSpacing.sm,
                right: AppSpacing.sm,
                bottom: AppSpacing.sm,
              ),
              child: Column(
                children: [
                  Text(
                    entry.userName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(color: scheme.primary),
                  ),
                  const Spacer(),
                  _StreakCount(value: entry.currentStreak, large: rank == 1),
                  AppSpacing.vGapXs,
                  Text(
                    l10n.leaderboardDaysCount(entry.qualifyingDays),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
          ),
        ),
        Semantics(
          label: _medalLabel(l10n, rank),
          child: SizedBox(
            height: avatarSize + 8,
            child: Stack(
              alignment: Alignment.topCenter,
              clipBehavior: Clip.none,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: _Monogram(name: entry.userName, size: avatarSize),
                ),
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: medalColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: scheme.surfaceContainerLow,
                      width: 2,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    context.localizeNumber(rank),
                    // Gold and silver are light enough that white numerals sat
                    // at ~2.4:1 and ~2.7:1; bronze needs the opposite ink.
                    // Let the framework pick per medal colour.
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: ThemeData.estimateBrightnessForColor(medalColor) ==
                              Brightness.dark
                          ? Colors.white
                          : theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Ranked row for 4th place and below.
class _RankRow extends StatelessWidget {
  final int rank;
  final LeaderboardEntry entry;
  final bool isCurrentUser;

  const _RankRow({
    required this.rank,
    required this.entry,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      color: isCurrentUser ? scheme.primaryContainer : null,
      shape: isCurrentUser
          ? RoundedRectangleBorder(
              borderRadius: AppRadius.brLg,
              side: BorderSide(color: scheme.secondary),
            )
          : null,
      child: Stack(
        children: [
          // Leading accent bar marks the current user's row.
          if (isCurrentUser)
            PositionedDirectional(
              start: 0,
              top: 0,
              bottom: 0,
              child: Container(width: 6, color: scheme.primary),
            ),
          Padding
              (padding: const EdgeInsets.all(AppSpacing.sm + 4),
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  child: Text(
                    context.localizeNumber(rank),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                AppSpacing.hGapSm,
                _Monogram(name: entry.userName, size: 40),
                AppSpacing.hGapSm,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              entry.userName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall,
                            ),
                          ),
                          if (isCurrentUser) ...[
                            AppSpacing.hGapXs,
                            _YouBadge(label: l10n.leaderboardYouBadge),
                          ],
                        ],
                      ),
                      Text(
                        l10n.leaderboardDaysCount(entry.qualifyingDays),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                AppSpacing.hGapSm,
                _StreakCount(value: entry.currentStreak),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Pinned strip showing the signed-in user's own rank.
class _RankStrip extends StatelessWidget {
  final int rank;
  final LeaderboardEntry entry;

  const _RankStrip({required this.rank, required this.entry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 2,
      ),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
      ),
      child: Row(
        children: [
          Text(
            l10n.leaderboardYouBadge,
            style: theme.textTheme.labelSmall
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
          AppSpacing.hGapSm,
          Text(
            context.localizeNumber(rank),
            style: theme.textTheme.titleSmall?.copyWith(color: scheme.primary),
          ),
          const Spacer(),
          _StreakCount(value: entry.currentStreak),
        ],
      ),
    );
  }
}

/// Circle with the first letter of the display name — the entries carry no
/// photo, so a monogram stands in for the comp's avatar.
class _Monogram extends StatelessWidget {
  final String name;
  final double size;

  const _Monogram({required this.name, required this.size});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.12),
        shape: BoxShape.circle,
        border: Border.all(color: scheme.surfaceContainerLow, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: theme.textTheme.titleMedium?.copyWith(
          color: scheme.primary,
          fontSize: size * 0.4,
        ),
      ),
    );
  }
}

class _StreakCount extends StatelessWidget {
  final int value;
  final bool large;

  const _StreakCount({required this.value, this.large = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = context.appColors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.local_fire_department,
          size: large ? 20 : 16,
          color: value > 0
              ? appColors.streakGradientEnd
              : theme.colorScheme.onSurfaceVariant,
        ),
        AppSpacing.hGapXs,
        Text(
          context.localizeNumber(value),
          style: (large
                  ? theme.textTheme.headlineSmall
                  : theme.textTheme.titleSmall)
              ?.copyWith(
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

class _YouBadge extends StatelessWidget {
  final String label;

  const _YouBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 1),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: AppRadius.brFull,
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

Color _medalColor(BuildContext context, int rank) {
  switch (rank) {
    case 1:
      return context.appColors.gold;
    case 2:
      return context.appColors.silver;
    default:
      return context.appColors.bronze;
  }
}

String? _medalLabel(AppLocalizations l10n, int rank) {
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
