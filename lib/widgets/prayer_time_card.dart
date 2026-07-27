import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:subh_warrior/core/l10n/app_localizations.dart';
import 'package:subh_warrior/core/l10n/l10n_utils.dart';
import 'package:subh_warrior/core/theme/app_colors.dart';
import 'package:subh_warrior/features/prayer_times/presentation/prayer_times_controller.dart';
import 'package:subh_warrior/shared/widgets/animated_odometer.dart';
import 'package:subh_warrior/shared/widgets/error_view.dart';
import 'package:subh_warrior/shared/widgets/skeleton.dart';

class PrayerTimeCard extends StatelessWidget {
  const PrayerTimeCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<PrayerTimeProvider>(
      builder: (context, prayerProvider, _) {
        if (prayerProvider.isLoading) {
          return const PrayerCardSkeleton();
        }

        if (prayerProvider.error.isNotEmpty) {
          return Card(
            child: SizedBox(
              height: 160,
              child: ErrorView(
                message: l10n.prayerCardErrorMessage,
                onRetry: () =>
                    prayerProvider.fetchPrayerTimesForCurrentLocation(),
              ),
            ),
          );
        }

        final fajrTime = prayerProvider.todayFajrTime;
        final tomorrowFajr = prayerProvider.tomorrowFajrTime;
        final isWithinWindow = prayerProvider.isWithinFajrTime();

        return Card(
          elevation: 8,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: isWithinWindow
                    ? [
                        context.appColors.success,
                        context.appColors.success.withValues(alpha: 0.85),
                      ]
                    : [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                      ],
                begin: AlignmentDirectional.topStart,
                end: AlignmentDirectional.bottomEnd,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.mosque,
                            color: Theme.of(context).colorScheme.onPrimary,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            l10n.prayerCardTitle,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      if (isWithinWindow)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimary
                                .withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.circle,
                                color: Theme.of(context).colorScheme.onPrimary,
                                size: 8,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                l10n.prayerCardNowBadge,
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildTimeColumn(
                        context,
                        l10n.prayerCardToday,
                        prayerProvider.formatTime(fajrTime),
                        isHighlighted: isWithinWindow,
                      ),
                      Container(
                        height: 40,
                        width: 1,
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimary
                            .withValues(alpha: 0.3),
                      ),
                      _buildTimeColumn(
                        context,
                        l10n.prayerCardTomorrow,
                        prayerProvider.formatTime(tomorrowFajr),
                      ),
                      Container(
                        height: 40,
                        width: 1,
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimary
                            .withValues(alpha: 0.3),
                      ),
                      _LiveFajrCountdown(
                        todayFajrTime: fajrTime,
                        tomorrowFajrTime: tomorrowFajr,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _FajrProgressBar(
                    todayFajrTime: fajrTime,
                    tomorrowFajrTime: tomorrowFajr,
                  ),
                  if (prayerProvider.todayPrayerTimes != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimary
                            .withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildSmallTimeInfo(
                              context,
                              l10n.prayerCardSunrise,
                              prayerProvider.formatTimeStringCompact(
                                  prayerProvider.todayPrayerTimes!.sunrise),
                            ),
                          ),
                          Expanded(
                            child: _buildSmallTimeInfo(
                              context,
                              l10n.prayerCardDhuhr,
                              prayerProvider.formatTimeStringCompact(
                                  prayerProvider.todayPrayerTimes!.dhuhr),
                            ),
                          ),
                          Expanded(
                            child: _buildSmallTimeInfo(
                              context,
                              l10n.prayerCardAsr,
                              prayerProvider.formatTimeStringCompact(
                                  prayerProvider.todayPrayerTimes!.asr),
                            ),
                          ),
                          Expanded(
                            child: _buildSmallTimeInfo(
                              context,
                              l10n.prayerCardMaghrib,
                              prayerProvider.formatTimeStringCompact(
                                  prayerProvider.todayPrayerTimes!.maghrib),
                            ),
                          ),
                          Expanded(
                            child: _buildSmallTimeInfo(
                              context,
                              l10n.prayerCardIsha,
                              prayerProvider.formatTimeStringCompact(
                                  prayerProvider.todayPrayerTimes!.isha),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimeColumn(
    BuildContext context,
    String label,
    String time, {
    bool isHighlighted = false,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color:
                Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.8),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSmallTimeInfo(BuildContext context, String label, String time) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Scale with the space this column actually gets (narrow phones vs.
        // tablets), clamped to a sensible range — responsive without relying
        // on FittedBox to shrink text as a fallback for a too-long string.
        final timeFontSize = (constraints.maxWidth * 0.18).clamp(13.0, 16.0);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onPrimary
                      .withValues(alpha: 0.9),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  time,
                  maxLines: 1,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: timeFontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Live HH:MM:SS countdown to the next Fajr — ticks itself every second
/// (the provider only rebuilds on a network fetch, not on a clock).
class _LiveFajrCountdown extends StatefulWidget {
  const _LiveFajrCountdown({
    required this.todayFajrTime,
    required this.tomorrowFajrTime,
  });

  final DateTime? todayFajrTime;
  final DateTime? tomorrowFajrTime;

  @override
  State<_LiveFajrCountdown> createState() => _LiveFajrCountdownState();
}

class _LiveFajrCountdownState extends State<_LiveFajrCountdown> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final remaining = PrayerTimeProvider.durationUntilNextFajr(
      todayFajrTime: widget.todayFajrTime,
      tomorrowFajrTime: widget.tomorrowFajrTime,
      now: DateTime.now(),
    );
    final style = TextStyle(
      color: Theme.of(context).colorScheme.onPrimary,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    );

    return Column(
      children: [
        Text(
          l10n.prayerCardNextFajrIn,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary.withValues(
                  alpha: 0.8,
                ),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        remaining == null
            ? Text(l10n.prayerCardCountdownUnknown, style: style)
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _rollingSegment(context, remaining.inHours, style),
                  Text(l10n.prayerCardCountdownHourSuffix, style: style),
                  const SizedBox(width: 3),
                  _rollingSegment(context, remaining.inMinutes % 60, style),
                  Text(l10n.prayerCardCountdownMinuteSuffix, style: style),
                  const SizedBox(width: 3),
                  _rollingSegment(context, remaining.inSeconds % 60, style),
                  Text(l10n.prayerCardCountdownSecondSuffix, style: style),
                ],
              ),
      ],
    );
  }

  /// Rolls only when [value] itself changes — the seconds segment ticks
  /// every second, but minutes/hours stay static until they actually roll
  /// over, instead of the whole countdown sliding together on every tick.
  /// `digitGlyph` keeps the roll in the user's chosen locale's numerals
  /// (Bengali/Arabic-Indic/etc), matching the rest of the app.
  Widget _rollingSegment(BuildContext context, int value, TextStyle style) {
    return AnimatedOdometer(
      value: value,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
      textStyle: style,
      digitGlyph: (rawDigit) => context.localizeNumber(int.parse(rawDigit)),
    );
  }
}

/// Linear progress bar filling across the current Fajr-to-Fajr cycle —
/// reaches 100% right at the next Fajr, then drops back to 0% and starts
/// filling again. Ticks itself every 30s (the provider only rebuilds on a
/// network fetch, not on a clock) so the fill keeps advancing in between.
class _FajrProgressBar extends StatefulWidget {
  const _FajrProgressBar({
    required this.todayFajrTime,
    required this.tomorrowFajrTime,
  });

  final DateTime? todayFajrTime;
  final DateTime? tomorrowFajrTime;

  @override
  State<_FajrProgressBar> createState() => _FajrProgressBarState();
}

class _FajrProgressBarState extends State<_FajrProgressBar> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = PrayerTimeProvider.fajrCycleProgress(
      todayFajrTime: widget.todayFajrTime,
      tomorrowFajrTime: widget.tomorrowFajrTime,
      now: DateTime.now(),
    );
    if (progress == null) return const SizedBox.shrink();

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: progress,
        minHeight: 6,
        backgroundColor:
            Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.25),
        valueColor: AlwaysStoppedAnimation(
          Theme.of(context).colorScheme.onPrimary,
        ),
      ),
    );
  }
}
