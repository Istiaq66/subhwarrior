import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:subh_warrior/core/l10n/app_localizations.dart';
import 'package:subh_warrior/core/theme/app_spacing.dart';
import 'package:subh_warrior/core/utils/date_time_utils.dart';
import 'package:subh_warrior/features/challenge/domain/day_log.dart';

/// This week at a glance: one chip per day of the current week, plus a bar for
/// how much of the week has been logged.
///
/// Replaces the previous four-bars-per-challenge-week layout. Status is encoded
/// with an icon as well as a fill colour, so the three states stay
/// distinguishable without relying on colour alone.
class WeeklyProgressCard extends StatelessWidget {
  final List<DayLog> dayLogs;

  const WeeklyProgressCard({super.key, required this.dayLogs});

  static const int _daysPerWeek = 7;

  /// Sunday of the current week. `DateTime.weekday` is Mon=1..Sun=7, so
  /// `weekday % 7` is exactly the number of days back to Sunday.
  DateTime _startOfWeek(DateTime today) =>
      today.subtract(Duration(days: today.weekday % 7));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final narrowDay = DateFormat('EEEEE', locale);

    final today = AppDateUtils.dateOnly(DateTime.now());
    final weekStart = _startOfWeek(today);

    final qualifyingDates = {
      for (final log in dayLogs)
        if (log.isQualifying) AppDateUtils.dateOnly(log.date),
    };

    final days = List.generate(
      _daysPerWeek,
      (i) => weekStart.add(Duration(days: i)),
    );
    final loggedThisWeek =
        days.where((d) => qualifyingDates.contains(d)).length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // The title and the percent chip together overran the row on
                // a 320dp screen, where this card only gets 272dp inside its
                // padding. The chip is fixed-width content, so the title is
                // the part that gives.
                Flexible(
                  child: Text(
                    l10n.weeklyProgressTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: scheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.secondary.withValues(alpha: 0.12),
                    borderRadius: AppRadius.brFull,
                  ),
                  child: Text(
                    l10n.quickStatsPercent(
                      ((loggedThisWeek / _daysPerWeek) * 100).round(),
                    ),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: scheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Seven fixed 40dp circles exactly filled the row on a 360dp
            // phone and overflowed below that, so the chips sat edge to edge
            // with no breathing room. Size them from the width this card
            // actually gets instead, keeping a real gap between them.
            LayoutBuilder(
              builder: (context, constraints) {
                const gap = 8.0;
                final diameter =
                    ((constraints.maxWidth - gap * (_daysPerWeek - 1)) /
                            _daysPerWeek)
                        .clamp(24.0, 40.0);

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (final day in days)
                      _DayChip(
                        label: narrowDay.format(day),
                        diameter: diameter,
                        isToday: day == today,
                        isFuture: day.isAfter(today),
                        isQualifying: qualifyingDates.contains(day),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            ClipRRect(
              borderRadius: AppRadius.brFull,
              child: LinearProgressIndicator(
                value: loggedThisWeek / _daysPerWeek,
                minHeight: 8,
                backgroundColor: scheme.outlineVariant,
                valueColor: AlwaysStoppedAnimation<Color>(scheme.secondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  final String label;
  final double diameter;
  final bool isToday;
  final bool isFuture;
  final bool isQualifying;

  const _DayChip({
    required this.label,
    required this.diameter,
    required this.isToday,
    required this.isFuture,
    required this.isQualifying,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    // Glyph and dot scale with the circle so a shrunken chip keeps its
    // proportions instead of a full-size icon crowding a smaller disc.
    final glyphSize = diameter * 0.4;
    final dotSize = diameter * 0.2;

    late final Widget circle;
    if (isQualifying) {
      circle = _Circle(
        diameter: diameter,
        color: scheme.primary,
        child: Icon(Icons.check, size: glyphSize, color: scheme.onPrimary),
      );
    } else if (isToday) {
      circle = _Circle(
        diameter: diameter,
        color: scheme.surface,
        border: Border.all(color: scheme.primary, width: 2),
        child: Container(
          width: dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            color: scheme.primary,
            shape: BoxShape.circle,
          ),
        ),
      );
    } else if (isFuture) {
      circle = _Circle(
        diameter: diameter,
        color: scheme.outlineVariant.withValues(alpha: 0.5),
      );
    } else {
      circle = _Circle(
        diameter: diameter,
        color: scheme.outlineVariant.withValues(alpha: 0.5),
        child: Icon(
          Icons.close,
          size: glyphSize * 0.875,
          color: scheme.onSurfaceVariant,
        ),
      );
    }

    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: isToday ? scheme.primary : scheme.onSurfaceVariant,
            fontWeight: isToday ? FontWeight.bold : FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        circle,
      ],
    );
  }
}

class _Circle extends StatelessWidget {
  final double diameter;
  final Color color;
  final BoxBorder? border;
  final Widget? child;

  const _Circle({
    required this.diameter,
    required this.color,
    this.border,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: border,
      ),
      child: child,
    );
  }
}
