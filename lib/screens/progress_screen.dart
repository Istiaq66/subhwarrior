import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:subh_warrior/core/constants/app_constants.dart';
import 'package:subh_warrior/core/l10n/app_localizations.dart';
import 'package:subh_warrior/core/l10n/l10n_utils.dart';
import 'package:subh_warrior/core/theme/app_colors.dart';
import 'package:subh_warrior/core/theme/app_spacing.dart';
import 'package:subh_warrior/features/challenge/domain/day_log.dart';
import 'package:subh_warrior/features/challenge/domain/work_type.dart';
import 'package:subh_warrior/features/challenge/presentation/challenge_controller.dart';
import 'package:subh_warrior/features/challenge/presentation/widgets/day_detail_sheet.dart';
import 'package:subh_warrior/shared/widgets/empty_view.dart';
import 'package:table_calendar/table_calendar.dart';

/// Challenge progress: a completion ring, three stat tiles, the month log
/// calendar, weekly performance, and recent day logs.
///
/// Laid out from the design comps. The weekly bar chart is not in the comps but
/// is kept — it is existing functionality — restyled into the same card
/// language as everything else.
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.homeNavProgress)),
      body: Consumer<ChallengeProvider>(
        builder: (context, provider, _) {
          if (!provider.isChallengeActive) {
            return EmptyView(
              icon: Icons.flag_outlined,
              title: l10n.progressNoChallenge,
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ProgressRing(
                  percent: provider.overallProgress.clamp(0, 1),
                  label: l10n.progressChallengeProgress,
                ),
                AppSpacing.vGapLg,
                _buildStatsRow(provider),
                AppSpacing.vGapXl,
                _buildCalendarCard(provider),
                AppSpacing.vGapXl,
                _SectionHeader(title: l10n.progressWeeklyPerformance),
                AppSpacing.vGapSm,
                _buildWeeklyChart(provider),
                AppSpacing.vGapXl,
                _SectionHeader(title: l10n.progressRecentLogs),
                AppSpacing.vGapSm,
                _buildDaysList(provider),
              ],
            ),
          );
        },
      ),
    );
  }

  /// `grid grid-cols-3 gap-3` — completed, remaining, and the streak tile,
  /// which the comp singles out with a warm border and flame watermark.
  Widget _buildStatsRow(ChallengeProvider provider) {
    final l10n = AppLocalizations.of(context)!;
    final completed = provider.totalQualifyingDays;
    final remaining = AppConstants.qualifyingDaysGoal - completed;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _StatTile(
              label: l10n.progressStatCompleted,
              value: context.localizeNumber(completed),
            ),
          ),
          AppSpacing.hGapSm,
          Expanded(
            child: _StatTile(
              label: l10n.progressStatRemaining,
              value: context.localizeNumber(remaining < 0 ? 0 : remaining),
            ),
          ),
          AppSpacing.hGapSm,
          Expanded(
            child: _StatTile(
              label: l10n.progressStatStreak,
              value: context.localizeNumber(provider.currentStreak),
              isStreak: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarCard(ChallengeProvider provider) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final qualifyingDays = provider.dayLogs
        .where((log) => log.isQualifying)
        .map((log) => DateTime(log.date.year, log.date.month, log.date.day))
        .toSet();
    final nonQualifyingDays = provider.dayLogs
        .where((log) => !log.isQualifying)
        .map((log) => DateTime(log.date.year, log.date.month, log.date.day))
        .toSet();
    final firstDay = provider.challengeStartDate ?? DateTime.now();
    final lastDay =
        firstDay.add(const Duration(days: AppConstants.challengeDays));
    final effectiveFocusedDay =
        _focusedDay.isBefore(firstDay) ? firstDay : _focusedDay;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: TableCalendar(
          locale: Localizations.localeOf(context).toString(),
          firstDay: firstDay,
          lastDay: lastDay,
          focusedDay: effectiveFocusedDay,
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
            _showDayDetails(provider, selectedDay);
          },
          onFormatChanged: (format) =>
              setState(() => _calendarFormat = format),
          onPageChanged: (focusedDay) =>
              setState(() => _focusedDay = focusedDay),
          calendarBuilders: CalendarBuilders(
            // Comp marks logged days with a 6px dot under the numeral rather
            // than an icon: mint for qualifying, ochre for logged-but-not.
            markerBuilder: (context, day, events) {
              final normalized = DateTime(day.year, day.month, day.day);
              final isQualifying = qualifyingDays.contains(normalized);
              final isLogged = nonQualifyingDays.contains(normalized);
              if (!isQualifying && !isLogged) return null;
              return Semantics(
                label: isQualifying
                    ? AppLocalizations.of(context)!.a11yQualifyingDay
                    : AppLocalizations.of(context)!.a11yNonQualifyingDay,
                child: Container(
                  margin: const EdgeInsets.only(top: 30),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isQualifying
                        ? scheme.secondary
                        : context.appColors.warning,
                  ),
                ),
              );
            },
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: theme.textTheme.labelSmall!
                .copyWith(color: scheme.onSurfaceVariant),
            weekendStyle: theme.textTheme.labelSmall!
                .copyWith(color: scheme.onSurfaceVariant),
          ),
          calendarStyle: CalendarStyle(
            outsideDaysVisible: false,
            defaultTextStyle: theme.textTheme.bodySmall!,
            weekendTextStyle: theme.textTheme.bodySmall!,
            todayDecoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: scheme.primary, width: 2),
            ),
            todayTextStyle: theme.textTheme.bodySmall!
                .copyWith(color: scheme.primary, fontWeight: FontWeight.bold),
            selectedDecoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scheme.primary,
            ),
            selectedTextStyle:
                theme.textTheme.bodySmall!.copyWith(color: scheme.onPrimary),
          ),
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: theme.textTheme.titleSmall!,
            leftChevronIcon: Icon(Icons.chevron_left, color: scheme.primary),
            rightChevronIcon: Icon(Icons.chevron_right, color: scheme.primary),
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyChart(ChallengeProvider provider) {
    final theme = Theme.of(context);
    final weekProgress = provider.weeklyProgress;
    const weeklyTarget =
        AppConstants.qualifyingDaysGoal ~/ AppConstants.challengeWeeks;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: weeklyTarget.toDouble(),
              barTouchData: BarTouchData(enabled: true),
              gridData: FlGridData(

                drawVerticalLine: false,
                getDrawingHorizontalLine: (_) => FlLine(
                  color: theme.colorScheme.outlineVariant,
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) => Text(
                      AppLocalizations.of(context)!
                          .progressWeekAxisLabel(value.toInt()),
                      style: theme.textTheme.labelSmall,
                    ),
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (value, meta) => Text(
                      context.localizeNumber(value.toInt()),
                      style: theme.textTheme.labelSmall,
                    ),
                  ),
                ),
                rightTitles: const AxisTitles(),
                topTitles: const AxisTitles(),
              ),
              borderData: FlBorderData(show: false),
              barGroups: List.generate(AppConstants.challengeWeeks, (index) {
                final week = index + 1;
                final progress = weekProgress[week]?.toDouble() ?? 0;
                return BarChartGroupData(
                  x: week,
                  barRods: [
                    BarChartRodData(
                      toY: progress,
                      // One mint series, per the comp's charting rule.
                      color: theme.colorScheme.secondary,
                      width: 28,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(6),
                      ),
                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        toY: weeklyTarget.toDouble(),
                        color: theme.colorScheme.outlineVariant
                            .withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDaysList(ChallengeProvider provider) {
    final l10n = AppLocalizations.of(context)!;
    final sortedLogs = List<DayLog>.from(provider.dayLogs)
      ..sort((a, b) => b.date.compareTo(a.date));

    if (sortedLogs.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          child: EmptyView(
            icon: Icons.event_note_outlined,
            title: l10n.progressNoDaysLogged,
          ),
        ),
      );
    }

    final visible = sortedLogs.take(5).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < visible.length; i++) ...[
          if (i > 0) AppSpacing.vGapSm,
          _LogRow(
            log: visible[i],
            onTap: () => _showDayDetails(provider, visible[i].date),
          ),
        ],
      ],
    );
  }

  void _showDayDetails(ChallengeProvider provider, DateTime day) {
    final log = provider.dayLogs.firstWhere(
      (log) => isSameDay(log.date, day),
      orElse: () => DayLog(
        date: day,
        prayedFajrOnTime: false,
        minutesWorked: 0,
        workDescription: '',
        isQualifying: false,
        loggedAt: day,
        workType: WorkType.learning,
      ),
    );

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => DayDetailSheet(log: log),
    );
  }
}

/// 192px completion ring: mint arc with a rounded cap on a neutral track, the
/// percentage centred at `text-5xl` with a muted `%`.
class _ProgressRing extends StatelessWidget {
  final double percent;
  final String label;

  const _ProgressRing({required this.percent, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final whole = (percent * 100).round();

    return Column(
      children: [
        SizedBox(
          width: 192,
          height: 192,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox.expand(
                child: CircularProgressIndicator(
                  value: percent,
                  strokeWidth: 12,
                  strokeCap: StrokeCap.round,
                  backgroundColor: scheme.outlineVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(scheme.secondary),
                ),
              ),
              Text.rich(
                TextSpan(
                  text: context.localizeNumber(whole),
                  children: [
                    TextSpan(
                      text: '%',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                style: theme.textTheme.displayMedium?.copyWith(
                  color: scheme.onSurface,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
        AppSpacing.vGapMd,
        Text(label, style: theme.textTheme.titleMedium),
      ],
    );
  }
}

/// Section heading: `text-lg` semibold, sitting on the canvas above its card.
class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: AppSpacing.xs),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final bool isStreak;

  const _StatTile({
    required this.label,
    required this.value,
    this.isStreak = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = context.appColors;

    final valueText = Text(
      value,
      style: theme.textTheme.headlineSmall?.copyWith(
        color: isStreak ? null : theme.colorScheme.onSurface,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );

    return Card(
      // The streak tile carries a warm border, per the comp.
      shape: isStreak
          ? RoundedRectangleBorder(
              borderRadius: AppRadius.brLg,
              side: BorderSide(
                color: appColors.warning.withValues(alpha: 0.35),
              ),
            )
          : null,
      child: Stack(
        children: [
          if (isStreak)
            PositionedDirectional(
              top: -8,
              end: -8,
              child: Icon(
                Icons.local_fire_department,
                size: 44,
                color: appColors.warning.withValues(alpha: 0.20),
              ),
            ),
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      letterSpacing: 0.8,
                    ),
                  ),
                  AppSpacing.vGapXs,
                  if (isStreak)
                    ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (bounds) => LinearGradient(
                        colors: appColors.streakGradient,
                        begin: AlignmentDirectional.topStart,
                        end: AlignmentDirectional.bottomEnd,
                      ).createShader(
                        bounds,
                        textDirection: Directionality.of(context),
                      ),
                      child: DefaultTextStyle.merge(
                        style: const TextStyle(color: Colors.white),
                        child: valueText,
                      ),
                    )
                  else
                    valueText,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Recent-log row: date and relative day, a status pill, focus minutes, and the
/// note quoted behind a mint rule.
class _LogRow extends StatelessWidget {
  final DayLog log;
  final VoidCallback onTap;

  const _LogRow({required this.log, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final appColors = context.appColors;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final prayed = log.prayedFajrOnTime;
    final accent = prayed ? appColors.success : appColors.warning;
    final isToday = isSameDay(log.date, DateTime.now());

    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    DateFormat.MMMd(locale).format(log.date),
                    style: theme.textTheme.titleSmall,
                  ),
                  if (isToday) ...[
                    AppSpacing.hGapSm,
                    Text(
                      l10n.prayerCardToday,
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                  const Spacer(),
                  _StatusPill(
                    label: prayed
                        ? l10n.progressLogFajrPrayed
                        : l10n.progressLogFajrMissed,
                    color: accent,
                    icon: prayed ? Icons.check_circle : Icons.cancel,
                  ),
                ],
              ),
              AppSpacing.vGapSm,
              Row(
                children: [
                  Icon(Icons.schedule,
                      size: 16, color: scheme.onSurfaceVariant),
                  AppSpacing.hGapXs,
                  Text(
                    l10n.todayStatusMinutesWorked(log.minutesWorked),
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                  if (log.isQualifying) ...[
                    AppSpacing.hGapSm,
                    Icon(Icons.star, size: 16, color: appColors.gold),
                  ],
                ],
              ),
              if (log.workDescription.isNotEmpty) ...[
                AppSpacing.vGapSm,
                Container(
                  padding: const EdgeInsetsDirectional.only(
                    start: AppSpacing.sm + 4,
                    top: AppSpacing.xs,
                    bottom: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    border: BorderDirectional(
                      start: BorderSide(
                        color: scheme.secondary.withValues(alpha: 0.35),
                        width: 2,
                      ),
                    ),
                  ),
                  child: Text(
                    log.workDescription,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _StatusPill({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.brFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          AppSpacing.hGapXs,
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
