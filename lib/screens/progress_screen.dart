import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:subh_warrior/providers/challenge_provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

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
        title: const Text('Progress'),
        centerTitle: true,
      ),
      body: Consumer<ChallengeProvider>(
        builder: (context, provider, _) {
          if (!provider.isChallengeActive) {
            return const Center(
              child: Text('Start a challenge to track your progress'),
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
    final percentage = (provider.overallProgress * 100).toInt();
    final daysCompleted = provider.totalQualifyingDays;
    final daysRemaining = 16 - daysCompleted;

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
            '$percentage%',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Challenge Progress',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatColumn('Completed', '$daysCompleted', Colors.white),
              _buildStatColumn('Remaining', '$daysRemaining', Colors.white),
              _buildStatColumn('Streak', '${provider.currentStreak}', Colors.white),
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
            color: color.withOpacity(0.9),
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
    final lastDay = firstDay.add(const Duration(days: 28));
    final effectiveFocusedDay = _focusedDay.isBefore(firstDay) ? firstDay : _focusedDay;
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
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 16,
                  ),
                );
              } else if (nonQualifyingDays.contains(normalizedDay)) {
                return Container(
                  margin: const EdgeInsets.only(top: 6),
                  child: const Icon(
                    Icons.circle,
                    color: Colors.orange,
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

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Performance',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 4,
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text('W${value.toInt()}');
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
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(4, (index) {
                    final week = index + 1;
                    final progress = weekProgress[week]?.toDouble() ?? 0;

                    return BarChartGroupData(
                      x: week,
                      barRods: [
                        BarChartRodData(
                          toY: progress,
                          color: progress >= 4
                              ? Colors.green
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
    final sortedLogs = List<DayLog>.from(provider.dayLogs)
      ..sort((a, b) => b.date.compareTo(a.date));

    if (sortedLogs.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Text('No days logged yet'),
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
              'Recent Logs',
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
                      ? Colors.green
                      : Colors.orange,
                  child: Icon(
                    log.isQualifying
                        ? Icons.check
                        : Icons.close,
                    color: Colors.white,
                  ),
                ),
                title: Text(DateFormat('EEEE, MMM d').format(log.date)),
                subtitle: Text(
                  '${log.prayedFajrOnTime ? "✓ Fajr" : "✗ Fajr"} • '
                      '${log.minutesWorked} min work',
                ),
                trailing: log.isQualifying
                    ? const Icon(Icons.star, color: Colors.amber)
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

    if (log.workDescription.isEmpty) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  log.isQualifying ? Icons.check_circle : Icons.warning,
                  color: log.isQualifying ? Colors.green : Colors.orange,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('EEEE, MMMM d').format(log.date),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        log.isQualifying ? 'Qualifying Day' : 'Non-Qualifying Day',
                        style: TextStyle(
                          color: log.isQualifying ? Colors.green : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildDetailRow(
              Icons.mosque,
              'Fajr Prayer',
              log.prayedFajrOnTime ? 'On Time' : 'Missed',
              log.prayedFajrOnTime,
            ),
            _buildDetailRow(
              Icons.timer,
              'Work Duration',
              '${log.minutesWorked} minutes',
              log.minutesWorked >= 60,
            ),
            const SizedBox(height: 16),
            Text(
              'Work Description',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Text(log.workDescription),
            if (log.reflection != null && log.reflection!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Reflection',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Text(log.reflection!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, bool success) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Text(label),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: success ? Colors.green : null,
            ),
          ),
        ],
      ),
    );
  }
}