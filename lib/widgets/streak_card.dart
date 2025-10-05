import 'package:flutter/material.dart';

class StreakCard extends StatelessWidget {
  final int currentStreak;
  final int totalDays;

  const StreakCard({
    super.key,
    required this.currentStreak,
    required this.totalDays,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: currentStreak > 0
              ? LinearGradient(
            colors: [
              Colors.orange.shade400,
              Colors.deepOrange.shade400,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStreakSection(context),
              Container(
                height: 60,
                width: 1,
                color: currentStreak > 0
                    ? Colors.white.withOpacity(0.3)
                    : Theme.of(context).dividerColor,
              ),
              _buildTotalDaysSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStreakSection(BuildContext context) {
    final bool hasStreak = currentStreak > 0;
    final streakEmoji = _getStreakEmoji(currentStreak);

    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                hasStreak ? Icons.local_fire_department : Icons.whatshot,
                color: hasStreak
                    ? Colors.white
                    : Theme.of(context).colorScheme.primary,
                size: 32,
              ),
              const SizedBox(width: 8),
              Text(
                streakEmoji,
                style: const TextStyle(fontSize: 24),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$currentStreak',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: hasStreak
                  ? Colors.white
                  : Theme.of(context).textTheme.headlineLarge?.color,
            ),
          ),
          Text(
            currentStreak == 1 ? 'Day Streak' : 'Days Streak',
            style: TextStyle(
              fontSize: 14,
              color: hasStreak
                  ? Colors.white.withOpacity(0.9)
                  : Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          if (currentStreak >= 7) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getStreakMessage(currentStreak),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTotalDaysSection(BuildContext context) {
    final progress = (totalDays / 16).clamp(0.0, 1.0);
    final bool isOnTrack = totalDays >= 4; // Assuming week 1

    return Expanded(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 6,
                  backgroundColor: currentStreak > 0
                      ? Colors.white.withOpacity(0.3)
                      : Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    currentStreak > 0
                        ? Colors.white
                        : (isOnTrack ? Colors.green : Theme.of(context).colorScheme.primary),
                  ),
                ),
              ),
              Column(
                children: [
                  Text(
                    '$totalDays',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: currentStreak > 0
                          ? Colors.white
                          : Theme.of(context).textTheme.headlineMedium?.color,
                    ),
                  ),
                  Text(
                    '/16',
                    style: TextStyle(
                      fontSize: 12,
                      color: currentStreak > 0
                          ? Colors.white.withOpacity(0.8)
                          : Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Qualifying Days',
            style: TextStyle(
              fontSize: 14,
              color: currentStreak > 0
                  ? Colors.white.withOpacity(0.9)
                  : Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          if (totalDays >= 8) ...[
            const SizedBox(height: 4),
            Icon(
              Icons.emoji_events,
              color: currentStreak > 0 ? Colors.white : Colors.amber,
              size: 20,
            ),
          ],
        ],
      ),
    );
  }

  String _getStreakEmoji(int streak) {
    if (streak == 0) return '💤';
    if (streak < 3) return '✨';
    if (streak < 7) return '🔥';
    if (streak < 14) return '⚡';
    if (streak < 21) return '🚀';
    return '👑';
  }

  String _getStreakMessage(int streak) {
    if (streak >= 21) return 'LEGENDARY!';
    if (streak >= 14) return 'UNSTOPPABLE!';
    if (streak >= 7) return 'ON FIRE!';
    return 'KEEP GOING!';
  }
}