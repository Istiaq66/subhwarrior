import 'package:flutter/material.dart';

/// Time-of-day greeting plus the user's name at the top of the dashboard.
class GreetingHeader extends StatelessWidget {
  final String userName;

  const GreetingHeader({super.key, required this.userName});

  String _greetingFor(int hour) {
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _greetingFor(DateTime.now().hour),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        Text(
          userName.isNotEmpty ? userName : 'Warrior',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}
