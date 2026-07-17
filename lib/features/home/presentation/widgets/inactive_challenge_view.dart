import 'package:flutter/material.dart';

import 'package:subh_warrior/core/constants/app_constants.dart';

/// Shown on the dashboard when no challenge is active — a call to action to
/// start the challenge.
class InactiveChallengeView extends StatelessWidget {
  final VoidCallback onStart;

  const InactiveChallengeView({super.key, required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wb_sunny,
              size: 100,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Ready to become a Subh Warrior?',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Start your ${AppConstants.challengeDays}-day challenge to build a '
              'powerful morning routine with Fajr prayer and productive work.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: onStart,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Challenge'),
              style: FilledButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
