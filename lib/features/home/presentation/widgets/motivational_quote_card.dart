import 'package:flutter/material.dart';

/// Daily-rotating motivational quote card. The quote is chosen by day-of-month
/// so it is stable within a day.
class MotivationalQuoteCard extends StatelessWidget {
  const MotivationalQuoteCard({super.key});

  static const List<String> _quotes = [
    '"The early morning has gold in its mouth." - Benjamin Franklin',
    '"Lose an hour in the morning, and you will spend all day looking for it." - Richard Whately',
    '"Success comes to those who have the willpower to win over their snooze buttons." - Unknown',
    '"The sun has not caught me in bed in fifty years." - Thomas Jefferson',
    '"Every morning we are born again. What we do today is what matters most." - Buddha',
  ];

  @override
  Widget build(BuildContext context) {
    final quote = _quotes[DateTime.now().day % _quotes.length];

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
