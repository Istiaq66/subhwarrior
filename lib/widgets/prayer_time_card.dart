import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:subh_warrior/providers/prayer_time_provider.dart';
import 'package:intl/intl.dart';

class PrayerTimeCard extends StatelessWidget {
  const PrayerTimeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PrayerTimeProvider>(
      builder: (context, prayerProvider, _) {
        if (prayerProvider.isLoading) {
          return Card(
            child: SizedBox(
              height: 120,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        if (prayerProvider.error.isNotEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(height: 8),
                  Text(
                    'Unable to load prayer times',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: () async {
                      await prayerProvider.fetchPrayerTimesForCurrentLocation();
                    },
                    child: const Text('Retry'),
                  ),
                ],
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
                    ? [Colors.green.shade400, Colors.green.shade600]
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
                            color: Colors.white,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Fajr Prayer',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
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
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: const [
                              Icon(
                                Icons.circle,
                                color: Colors.white,
                                size: 8,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'NOW',
                                style: TextStyle(
                                  color: Colors.white,
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
                        fajrTime != null
                            ? DateFormat('hh:mm a').format(fajrTime)
                            : '--:--',
                        isHighlighted: isWithinWindow,
                      ),
                      Container(
                        height: 40,
                        width: 1,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      _buildTimeColumn(
                        context,
                        'Tomorrow',
                        tomorrowFajr != null
                            ? DateFormat('hh:mm a').format(tomorrowFajr)
                            : '--:--',
                      ),
                      Container(
                        height: 40,
                        width: 1,
                        color: Colors.white.withValues(alpha: 0.3),
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
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildSmallTimeInfo(
                            'Sunrise',
                            prayerProvider.todayPrayerTimes!.sunrise,
                          ),
                          _buildSmallTimeInfo(
                            'Dhuhr',
                            prayerProvider.todayPrayerTimes!.dhuhr,
                          ),
                          _buildSmallTimeInfo(
                            'Asr',
                            prayerProvider.todayPrayerTimes!.asr,
                          ),
                          _buildSmallTimeInfo(
                            'Maghrib',
                            prayerProvider.todayPrayerTimes!.maghrib,
                          ),
                          _buildSmallTimeInfo(
                            'Isha',
                            prayerProvider.todayPrayerTimes!.isha,
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
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: TextStyle(
            color: Colors.white,
            fontSize: isCountdown ? 18 : 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSmallTimeInfo(String label, String time) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          time,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}