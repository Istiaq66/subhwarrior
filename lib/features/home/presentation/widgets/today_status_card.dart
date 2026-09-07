import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:subh_warrior/core/constants/app_constants.dart';
import 'package:subh_warrior/core/l10n/app_localizations.dart';
import 'package:subh_warrior/core/l10n/l10n_utils.dart';
import 'package:subh_warrior/core/theme/app_colors.dart';
import 'package:subh_warrior/core/theme/app_spacing.dart';
import 'package:subh_warrior/features/challenge/domain/day_log.dart';
import 'package:subh_warrior/features/prayer_times/presentation/prayer_times_controller.dart';
import 'package:subh_warrior/screens/logday_screen.dart';

/// The dashboard hero, per the design comps: today's Fajr time as a 60px
/// numeral, a live countdown beneath it, then the primary action.
///
/// The action area carries the four states the app already had — pending,
/// window closed, logged, and logged-and-qualifying. The comps show only the
/// pending and confirmed states, so the closed and qualifying variants keep
/// their existing copy rather than being dropped.
///
/// The countdown ticks every second, mirroring [PrayerTimeCard].
class TodayStatusCard extends StatefulWidget {
  final DayLog? todayLog;
  final bool canLog;

  const TodayStatusCard({
    super.key,
    required this.todayLog,
    required this.canLog,
  });

  @override
  State<TodayStatusCard> createState() => _TodayStatusCardState();
}

class _TodayStatusCardState extends State<TodayStatusCard> {
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

  /// Two digits in the active locale's numerals, so the clock does not jump
  /// between Latin and Bengali/Arabic digits.
  String _two(BuildContext context, int value) =>
      context.localizeNumber(value).padLeft(2, context.localizeNumber(0));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final prayer = context.watch<PrayerTimeProvider>();

    final fajr = prayer.todayFajrTime;
    // `formatTime` yields "05:42 AM" (or "05:42" on a 24-hour clock); the comp
    // sets the meridiem in a smaller muted face, so it is split out here.
    final formatted = prayer.formatTime(fajr);
    final parts = formatted.split(' ');
    final clock = parts.first;
    final meridiem = parts.length > 1 ? parts.sublist(1).join(' ') : null;

    final remaining = PrayerTimeProvider.durationUntilNextFajr(
      todayFajrTime: prayer.todayFajrTime,
      tomorrowFajrTime: prayer.tomorrowFajrTime,
      now: DateTime.now(),
    );

    return Card(
      child: Stack(
        children: [
          // `absolute inset-0 opacity-5` watermark from the comp.
          Positioned(
            top: -24,
            right: -24,
            child: IgnorePointer(
              child: Icon(
                Icons.mosque,
                size: 160,
                color: scheme.primary.withValues(alpha: 0.05),
              ),
            ),
          ),
          // Non-positioned Stack children get loose constraints, so this must
          // be pinned to full width or the hero shrink-wraps to its text and
          // the Log button stops spanning the card.
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.prayerCardTitle.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.6,
                  ),
                ),
                AppSpacing.vGapSm,
                _FajrTime(clock: clock, meridiem: meridiem),
                AppSpacing.vGapMd,
                _Countdown(
                  text: remaining == null
                      ? l10n.prayerCardCountdownUnknown
                      : '${_two(context, remaining.inHours)}:'
                          '${_two(context, remaining.inMinutes.remainder(60))}:'
                          '${_two(context, remaining.inSeconds.remainder(60))}',
                  isClock: remaining != null,
                ),
                AppSpacing.vGapXl,
                ..._buildAction(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAction(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final log = widget.todayLog;

    if (log != null) {
      final qualifying = log.isQualifying;
      final accent =
          qualifying ? context.appColors.success : context.appColors.warning;
      return [
        // Calm confirmed state: a status banner, then the day's details.
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 4,
          ),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.12),
            borderRadius: AppRadius.brMd,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, size: 20, color: accent),
              AppSpacing.hGapSm,
              Text(
                qualifying
                    ? l10n.todayStatusChipQualifying
                    : l10n.todayStatusChipLogged,
                style: theme.textTheme.titleSmall?.copyWith(color: accent),
              ),
            ],
          ),
        ),
        AppSpacing.vGapMd,
        _StatusRow(
          icon: Icons.mosque,
          label: l10n.todayStatusFajrPrayer,
          value: log.prayedFajrOnTime
              ? l10n.todayStatusFajrOnTime
              : l10n.todayStatusFajrMissed,
        ),
        _StatusRow(
          icon: Icons.timer_outlined,
          label: l10n.todayStatusWorkTime,
          value: l10n.todayStatusMinutesWorked(log.minutesWorked),
        ),
        if (log.workDescription.isNotEmpty)
          _StatusRow(
            icon: Icons.description_outlined,
            label: l10n.todayStatusWorkLabel,
            value: log.workDescription,
          ),
      ];
    }

    if (widget.canLog) {
      return [
        FilledButton.icon(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LogDayScreen()),
          ),
          icon: const Icon(Icons.check_circle, size: 22),
          label: Text(l10n.todayStatusLogTodayButton),
        ),
      ];
    }

    // Logging window closed — kept from the previous card, restyled as an
    // error-tinted notice so it reads as a state rather than a failure.
    return [
      Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 4,
        ),
        decoration: BoxDecoration(
          color: scheme.errorContainer,
          borderRadius: AppRadius.brMd,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_clock, size: 20, color: scheme.onErrorContainer),
            AppSpacing.hGapSm,
            Flexible(
              child: Text(
                l10n.todayStatusWindowClosed(
                  context
                      .watch<PrayerTimeProvider>()
                      .formatClock(AppConstants.logCutoffHour),
                ),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: scheme.onErrorContainer),
              ),
            ),
          ],
        ),
      ),
    ];
  }
}

/// `text-6xl` clock with the meridiem in `text-3xl` muted, tabular so the
/// digits do not shift width as the time changes.
class _FajrTime extends StatelessWidget {
  final String clock;
  final String? meridiem;

  const _FajrTime({required this.clock, this.meridiem});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text.rich(
      TextSpan(
        text: clock,
        children: [
          if (meridiem != null && meridiem!.isNotEmpty)
            TextSpan(
              text: ' $meridiem',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
      textAlign: TextAlign.center,
      style: theme.textTheme.displayLarge?.copyWith(
        color: theme.colorScheme.onSurface,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}

class _Countdown extends StatelessWidget {
  final String text;
  final bool isClock;

  const _Countdown({required this.text, required this.isClock});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.timer_outlined, size: 18, color: muted),
        AppSpacing.hGapSm,
        // Forced LTR: a H:MM:SS clock keeps its component order in RTL
        // locales, even though the digits themselves are localized.
        Directionality(
          textDirection: TextDirection.ltr,
          child: Text(
            text,
            style: theme.textTheme.titleLarge?.copyWith(
              color: muted,
              fontWeight: FontWeight.w500,
              fontFeatures: isClock
                  ? const [FontFeature.tabularFigures()]
                  : const <FontFeature>[],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatusRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          AppSpacing.hGapSm,
          Text(
            label,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              maxLines: 2,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall,
            ),
          ),
        ],
      ),
    );
  }
}
