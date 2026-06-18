import 'package:flutter/material.dart';

/// Daily-rotating motivational quote card. The quote is chosen by day-of-month
/// so it is stable within a day.
class MotivationalQuoteCard extends StatelessWidget {
  const MotivationalQuoteCard({super.key});

  static const List<String> _quotes = [
    '"O Allah, bless my Ummah in its early mornings." - Prophet Muhammad ﷺ (Abu Dawud, Tirmidhi)',
    '"The two Rak\'ah before Fajr are better than this world and all that it contains." - Prophet Muhammad ﷺ (Muslim)',
    '"Whoever prays the dawn prayer in congregation, it is as if he prayed the whole night." - Prophet Muhammad ﷺ (Muslim)',
    '"And [recite] the Qur\'an at dawn. Indeed, the recitation of dawn is ever witnessed." - Qur\'an 17:78',
    '"Indeed, the night prayer is most effective for the heart and most upright in speech." - Qur\'an 73:6',
    '"Take advantage of five before five: your youth before your old age, your health before your sickness, your wealth before your poverty, your free time before your busyness, and your life before your death." - Prophet Muhammad ﷺ (Al-Hakim)',
    '"The most beloved deeds to Allah are those done consistently, even if small." - Prophet Muhammad ﷺ (Bukhari & Muslim)',
    '"And when the prayer has ended, disperse in the land and seek the bounty of Allah." - Qur\'an 62:10',
    '"There are two blessings which many people lose: good health and free time." - Prophet Muhammad ﷺ (Bukhari)',
    '"Whoever rises in the morning safe in his home, healthy in body, with food for the day, it is as if the whole world were given to him." - Prophet Muhammad ﷺ (Tirmidhi)',
  ];

  @override
  Widget build(BuildContext context) {
    // Rotate daily through the whole list (day-of-year, not day-of-month, so
    // every quote is shown and the cycle doesn't reset each month).
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year)).inDays;
    final quote = _quotes[dayOfYear % _quotes.length];

    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(
              Icons.format_quote,
              size: 32,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            const SizedBox(height: 8),
            Text(
              quote,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
