import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:subh_warrior/core/theme/app_colors.dart';
import 'package:subh_warrior/features/prayer_times/presentation/prayer_times_controller.dart';
import 'package:subh_warrior/shared/widgets/error_view.dart';
import 'package:subh_warrior/shared/widgets/loading_view.dart';

class PrayerTimeCard extends StatelessWidget {
  const PrayerTimeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PrayerTimeProvider>(
      builder: (context, prayerProvider, _) {
        if (prayerProvider.isLoading) {
          return const Card(
            child: SizedBox(height: 120, child: LoadingView()),
          );
        }

        if (prayerProvider.error.isNotEmpty) {
          return Card(
            child: SizedBox(
              height: 160,
              child: ErrorView(
                message: 'Unable to load prayer times',
                onRetry: () =>
                    prayerProvider.fetchPrayerTimesForCurrentLocation(),
              ),
            ),
          );
        }

        final fajrTime = prayerProvider.todayFajrTime;
        final tomorrowFajr = prayerProvider.tomorrowFajrTime;
        final isWithinWindow = prayerProvider.isWithinFajrTime();
        final timeUntilFajr = prayerProvider.getTimeUntilFajr();

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
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
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
                            'Fajr Prayer',
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
                                'NOW',
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
                        'Today',
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
                        'Tomorrow',
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
                      _buildTimeColumn(
                        context,
                        'Next Fajr In',
                        timeUntilFajr,
                        isCountdown: true,
                      ),
                    ],
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
                              'Sunrise',
                              prayerProvider.formatTimeString(
                                  prayerProvider.todayPrayerTimes!.sunrise),
                            ),
                          ),
                          Expanded(
                            child: _buildSmallTimeInfo(
                              context,
                              'Dhuhr',
                              prayerProvider.formatTimeString(
                                  prayerProvider.todayPrayerTimes!.dhuhr),
                            ),
                          ),
                          Expanded(
                            child: _buildSmallTimeInfo(
                              context,
                              'Asr',
                              prayerProvider.formatTimeString(
                                  prayerProvider.todayPrayerTimes!.asr),
                            ),
                          ),
                          Expanded(
                            child: _buildSmallTimeInfo(
                              context,
                              'Maghrib',
                              prayerProvider.formatTimeString(
                                  prayerProvider.todayPrayerTimes!.maghrib),
                            ),
                          ),
                          Expanded(
                            child: _buildSmallTimeInfo(
                              context,
                              'Isha',
                              prayerProvider.formatTimeString(
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
    bool isCountdown = false,
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
            fontSize: isCountdown ? 18 : 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSmallTimeInfo(BuildContext context, String label, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
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
                  .withValues(alpha: 0.7),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              time,
              maxLines: 1,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
