import 'package:flutter/material.dart';

import 'package:subh_warrior/core/constants/app_constants.dart';
import 'package:subh_warrior/features/challenge/domain/day_log.dart';
import 'package:subh_warrior/screens/logday_screen.dart';

/// Dashboard card summarizing today's log state: qualifying/logged/pending/
/// closed, with either the day's details, a "Log Today" CTA, or a closed notice.
class TodayStatusCard extends StatelessWidget {
  final DayLog? todayLog;
  final bool canLog;

  const TodayStatusCard({
    super.key,
    required this.todayLog,
    required this.canLog,
  });

  @override
  Widget build(BuildContext context) {
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
                _statusChip(context),
              ],
            ),
            const SizedBox(height: 12),
            ..._buildBody(context),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(BuildContext context) {
    final String label;
    final Color color;
    if (todayLog != null) {
      label = todayLog!.isQualifying ? 'Qualifying ✓' : 'Logged';
      color = todayLog!.isQualifying ? Colors.green : Colors.orange;
    } else {
      label = canLog ? 'Pending' : 'Time\'s Up';
      color = canLog ? Colors.blue : Colors.red;
    }
    return Chip(label: Text(label), backgroundColor: color);
  }

  List<Widget> _buildBody(BuildContext context) {
    final log = todayLog;
    if (log != null) {
      return [
        _StatusRow(
          icon: Icons.mosque,
          label: 'Fajr Prayer',
          value: log.prayedFajrOnTime ? 'On Time' : 'Missed',
        ),
        _StatusRow(
          icon: Icons.work,
          label: 'Work Time',
          value: '${log.minutesWorked} minutes',
        ),
        if (log.workDescription.isNotEmpty)
          _StatusRow(
            icon: Icons.description,
            label: 'Work',
            value: log.workDescription,
          ),
      ];
    }

    if (canLog) {
      return [
        Center(
          child: ElevatedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LogDayScreen()),
            ),
            icon: const Icon(Icons.add_circle),
            label: const Text('Log Today'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
          ),
        ),
      ];
    }

    return [
      Text(
        'Logging window closed (after ${AppConstants.logCutoffHour} AM)',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
      ),
    ];
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
}
