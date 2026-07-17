import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:subh_warrior/core/constants/app_constants.dart';
import 'package:subh_warrior/core/l10n/app_localizations.dart';
import 'package:subh_warrior/core/theme/app_colors.dart';
import 'package:subh_warrior/features/challenge/domain/day_log.dart';
import 'package:subh_warrior/features/challenge/domain/work_type.dart';
import 'package:subh_warrior/features/challenge/presentation/challenge_controller.dart';
import 'package:subh_warrior/features/challenge/presentation/widgets/day_detail_sheet.dart';
import 'package:table_calendar/table_calendar.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.homeNavProgress),
        centerTitle: true,
      ),
      body: Consumer<ChallengeProvider>(
        builder: (context, provider, _) {
          if (!provider.isChallengeActive) {
            return Center(
              child: Text(AppLocalizations.of(context)!.progressNoChallenge),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildProgressSummary(provider),
                _buildCalendarView(provider),
                _buildWeeklyChart(provider),
                _buildDaysList(provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressSummary(ChallengeProvider provider) {
    final l10n = AppLocalizations.of(context)!;
    final percentage = (provider.overallProgress * 100).toInt();
    final daysCompleted = provider.totalQualifyingDays;
    final daysRemaining = AppConstants.qualifyingDaysGoal - daysCompleted;

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            l10n.quickStatsPercent(percentage),
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.progressChallengeProgress,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatColumn(l10n.progressStatCompleted, '$daysCompleted',
                  Theme.of(context).colorScheme.onPrimary),
              _buildStatColumn(l10n.progressStatRemaining, '$daysRemaining',
                  Theme.of(context).colorScheme.onPrimary),
              _buildStatColumn(
                  l10n.progressStatStreak,
                  '${provider.currentStreak}',
                  Theme.of(context).colorScheme.onPrimary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarView(ChallengeProvider provider) {
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
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TableCalendar(
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
          onFormatChanged: (format) {
            setState(() {
              _calendarFormat = format;
            });
          },
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, day, events) {
              final normalizedDay = DateTime(day.year, day.month, day.day);

              if (qualifyingDays.contains(normalizedDay)) {
                return Container(
                  margin: const EdgeInsets.only(top: 6),
                  child: Icon(
                    Icons.check_circle,
                    color: context.appColors.success,
                    size: 16,
                  ),
                );
              } else if (nonQualifyingDays.contains(normalizedDay)) {
                return Container(
                  margin: const EdgeInsets.only(top: 6),
                  child: Icon(
                    Icons.circle,
                    color: context.appColors.warning,
                    size: 16,
                  ),
                );
              }
              return null;
            },
          ),
          calendarStyle: CalendarStyle(
            outsideDaysVisible: false,
            weekendTextStyle: TextStyle(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyChart(ChallengeProvider provider) {
    final weekProgress = provider.weeklyProgress;
    const weeklyTarget =
        AppConstants.qualifyingDaysGoal ~/ AppConstants.challengeWeeks;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.progressWeeklyPerformance,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: weeklyTarget.toDouble(),
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(AppLocalizations.of(context)!
                              .progressWeekAxisLabel(value.toInt()));
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          return Text(value.toInt().toString());
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(),
                    topTitles: const AxisTitles(),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups:
                      List.generate(AppConstants.challengeWeeks, (index) {
                    final week = index + 1;
                    final progress = weekProgress[week]?.toDouble() ?? 0;

                    return BarChartGroupData(
                      x: week,
                      barRods: [
                        BarChartRodData(
                          toY: progress,
                          color: progress >= weeklyTarget
                              ? context.appColors.success
                              : Theme.of(context).colorScheme.primary,
                          width: 30,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaysList(ChallengeProvider provider) {
    final l10n = AppLocalizations.of(context)!;
    final sortedLogs = List<DayLog>.from(provider.dayLogs)
      ..sort((a, b) => b.date.compareTo(a.date));

    if (sortedLogs.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32.0),
        child: Text(l10n.progressNoDaysLogged),
      );
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              l10n.progressRecentLogs,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sortedLogs.length.clamp(0, 5),
            itemBuilder: (context, index) {
              final log = sortedLogs[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: log.isQualifying
                      ? context.appColors.success
                      : context.appColors.warning,
                  child: Icon(
                    log.isQualifying ? Icons.check : Icons.close,
                    color: log.isQualifying
                        ? context.appColors.onSuccess
                        : context.appColors.onWarning,
                  ),
                ),
                title: Text(DateFormat('EEEE, MMM d').format(log.date)),
                subtitle: Text(
                  l10n.progressLogSubtitle(
                    log.prayedFajrOnTime
                        ? l10n.progressLogFajrPrayed
                        : l10n.progressLogFajrMissed,
                    log.minutesWorked,
                  ),
                ),
                trailing: log.isQualifying
                    ? Icon(Icons.star, color: context.appColors.gold)
                    : null,
                onTap: () => _showDayDetails(provider, log.date),
              );
            },
          ),
        ],
      ),
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DayDetailSheet(log: log),
    );
  }
}
