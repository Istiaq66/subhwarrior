import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:subh_warrior/core/constants/app_constants.dart';
import 'package:subh_warrior/core/l10n/app_localizations.dart';
import 'package:subh_warrior/core/theme/app_colors.dart';
import 'package:subh_warrior/features/challenge/domain/day_log.dart';

/// Bottom-sheet content showing the details of a single logged day. Renders a
/// "No details logged" empty state for days with no description (A7).
class DayDetailSheet extends StatelessWidget {
  final DayLog log;

  const DayDetailSheet({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                log.isQualifying ? Icons.check_circle : Icons.warning,
                color: log.isQualifying
                    ? context.appColors.success
                    : context.appColors.warning,
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
                      log.isQualifying
                          ? l10n.dayDetailQualifying
                          : l10n.dayDetailNonQualifying,
                      style: TextStyle(
                        color: log.isQualifying
                            ? context.appColors.success
                            : context.appColors.warning,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _DetailRow(
            icon: Icons.mosque,
            label: l10n.todayStatusFajrPrayer,
            value: log.prayedFajrOnTime
                ? l10n.todayStatusFajrOnTime
                : l10n.todayStatusFajrMissed,
            success: log.prayedFajrOnTime,
          ),
          _DetailRow(
            icon: Icons.timer,
            label: l10n.dayDetailWorkDuration,
            value: l10n.todayStatusMinutesWorked(log.minutesWorked),
            success: log.minutesWorked >= AppConstants.minDeepWorkMinutes,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.dayDetailWorkDescription,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Text(
            log.workDescription.isNotEmpty
                ? log.workDescription
                : l10n.dayDetailNoDetails,
          ),
          if (log.reflection != null && log.reflection!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              l10n.dayDetailReflection,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Text(log.reflection!),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool success;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.success,
  });

  @override
  Widget build(BuildContext context) {
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
              color: success ? context.appColors.success : null,
            ),
          ),
        ],
      ),
    );
  }
}
