import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:subh_warrior/providers/challenge_provider.dart';
import 'package:subh_warrior/providers/prayer_time_provider.dart';
import 'package:intl/intl.dart';

class LogDayScreen extends StatefulWidget {
  const LogDayScreen({Key? key}) : super(key: key);

  @override
  State<LogDayScreen> createState() => _LogDayScreenState();
}

class _LogDayScreenState extends State<LogDayScreen> {
  final _formKey = GlobalKey<FormState>();
  final _workDescriptionController = TextEditingController();
  final _reflectionController = TextEditingController();

  bool _prayedFajrOnTime = false;
  bool _prayedAtMasjid = false;
  int _minutesWorked = 0;
  WorkType _selectedWorkType = WorkType.deepWork;
  bool _isSubmitting = false;

  // Track if user is awake and alert
  bool _wokeUpForFajr = false;
  bool _stayedAwakeAfter = false;

  @override
  void dispose() {
    _workDescriptionController.dispose();
    _reflectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prayerProvider = context.watch<PrayerTimeProvider>();
    final currentTime = DateTime.now();
    final canSubmit = currentTime.hour < 8;
    final isWeekend = currentTime.weekday == DateTime.saturday ||
        currentTime.weekday == DateTime.sunday;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Today'),
        elevation: 0,
      ),
      body: !canSubmit
          ? _buildTimeExpired()
          : isWeekend
          ? _buildWeekendMessage()
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTimeWarning(currentTime),
              const SizedBox(height: 20),
              _buildPrayerTimeInfo(prayerProvider),
              const SizedBox(height: 20),
              _buildWakeUpSection(),
              const SizedBox(height: 24),
              _buildFajrPrayerSection(),
              const SizedBox(height: 24),
              _buildWorkSection(),
              const SizedBox(height: 24),
              _buildReflectionSection(),
              const SizedBox(height: 32),
              _buildQualificationStatus(),
              const SizedBox(height: 24),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeekendMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.weekend,
              size: 80,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(height: 16),
            Text(
              'Weekend Day',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Weekend days do not count toward the Subh Warrior Challenge.\n\n'
                  'You need 4 qualifying weekdays per week.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeExpired() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.access_time,
              size: 80,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Time\'s Up!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Daily logs must be submitted before 8:00 AM.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeWarning(DateTime currentTime) {
    final timeUntil8AM = DateTime(
      currentTime.year,
      currentTime.month,
      currentTime.day,
      8, 0,
    ).difference(currentTime);

    if (timeUntil8AM.isNegative) return const SizedBox();

    final hours = timeUntil8AM.inHours;
    final minutes = timeUntil8AM.inMinutes % 60;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.timer,
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Time remaining to log: ${hours}h ${minutes}m',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerTimeInfo(PrayerTimeProvider provider) {
    final fajrTime = provider.todayFajrTime;
    final isWithinWindow = provider.isWithinFajrTime();

    return Card(
      color: isWithinWindow
          ? Theme.of(context).colorScheme.primaryContainer
          : null,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Today\'s Fajr',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (isWithinWindow)
                  const Chip(
                    label: Text('Prayer Time Now'),
                    backgroundColor: Colors.green,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              fajrTime != null
                  ? DateFormat('hh:mm a').format(fajrTime)
                  : 'Loading...',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            if (provider.todayPrayerTimes != null) ...[
              const SizedBox(height: 4),
              Text(
                'Sunrise: ${provider.todayPrayerTimes!.sunrise}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWakeUpSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Wake-Up Requirements',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              title: const Text('Woke up at/before Fajr time'),
              subtitle: const Text('Not just temporary wake-up'),
              value: _wokeUpForFajr,
              onChanged: (value) {
                setState(() {
                  _wokeUpForFajr = value ?? false;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Stayed awake and alert'),
              subtitle: const Text('Remained conscious after prayer'),
              value: _stayedAwakeAfter,
              onChanged: (value) {
                setState(() {
                  _stayedAwakeAfter = value ?? false;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFajrPrayerSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fajr Prayer',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Prayed Fajr on time'),
              subtitle: const Text('Within the prayer window'),
              value: _prayedFajrOnTime,
              onChanged: (value) {
                setState(() {
                  _prayedFajrOnTime = value;
                });
              },
              activeColor: Theme.of(context).colorScheme.primary,
            ),
            if (_prayedFajrOnTime) ...[
              const Divider(),
              SwitchListTile(
                title: const Text('Prayed at Masjid'),
                subtitle: const Text('Highly recommended (not required)'),
                value: _prayedAtMasjid,
                onChanged: (value) {
                  setState(() {
                    _prayedAtMasjid = value;
                  });
                },
                activeColor: Colors.green,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWorkSection() {
    final isQualifyingWork = _selectedWorkType != WorkType.passiveConsumption &&
        _selectedWorkType != WorkType.routineAdmin &&
        _selectedWorkType != WorkType.socialMedia;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Productive Work',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),

            // Work Type Selection
            Text(
              'Type of Work',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<WorkType>(
              value: _selectedWorkType,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                fillColor: isQualifyingWork
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                filled: true,
              ),
              items: const [
                DropdownMenuItem(
                  value: WorkType.deepWork,
                  child: Text('Deep Work'),
                ),
                DropdownMenuItem(
                  value: WorkType.strategicPlanning,
                  child: Text('Strategic Planning'),
                ),
                DropdownMenuItem(
                  value: WorkType.learning,
                  child: Text('Learning/Skill Development'),
                ),
                DropdownMenuItem(
                  value: WorkType.creativeProjects,
                  child: Text('Creative Projects'),
                ),
                DropdownMenuItem(
                  value: WorkType.importantCommunication,
                  child: Text('Important Communication'),
                ),
                DropdownMenuItem(
                  value: WorkType.passiveConsumption,
                  child: Text('❌ Passive Content Consumption'),
                ),
                DropdownMenuItem(
                  value: WorkType.routineAdmin,
                  child: Text('❌ Routine Administrative Tasks'),
                ),
                DropdownMenuItem(
                  value: WorkType.socialMedia,
                  child: Text('❌ Social Media'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedWorkType = value!;
                });
              },
            ),

            if (!isQualifyingWork) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.red, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This type of work does not qualify',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),
            Text(
              'Minutes of focused work: $_minutesWorked',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Slider(
              value: _minutesWorked.toDouble(),
              min: 0,
              max: 180,
              divisions: 36,
              label: '$_minutesWorked min',
              onChanged: (value) {
                setState(() {
                  _minutesWorked = value.round();
                });
              },
            ),
            if (_minutesWorked < 60)
              Text(
                'Minimum 60 minutes required for qualification',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 12,
                ),
              ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _workDescriptionController,
              decoration: const InputDecoration(
                labelText: 'Describe your work',
                hintText: 'What specific tasks did you complete?',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please describe your work';
                }
                if (value.length < 10) {
                  return 'Please provide more detail';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReflectionSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reflection (Optional)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _reflectionController,
              decoration: const InputDecoration(
                hintText: 'How did the early morning work feel?\nWhat did you accomplish?\nAny insights or breakthroughs?',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQualificationStatus() {
    final isQualifyingWork = _selectedWorkType != WorkType.passiveConsumption &&
        _selectedWorkType != WorkType.routineAdmin &&
        _selectedWorkType != WorkType.socialMedia;

    final isQualifying = _wokeUpForFajr &&
        _stayedAwakeAfter &&
        _prayedFajrOnTime &&
        _minutesWorked >= 60 &&
        isQualifyingWork;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isQualifying
            ? Colors.green.withOpacity(0.1)
            : Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isQualifying
              ? Colors.green
              : Theme.of(context).colorScheme.error,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isQualifying ? Icons.check_circle : Icons.warning,
                color: isQualifying
                    ? Colors.green
                    : Theme.of(context).colorScheme.error,
                size: 32,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  isQualifying ? 'Qualifying Day!' : 'Not Qualifying Yet',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildRequirement('Awake at/before Fajr', _wokeUpForFajr),
          _buildRequirement('Stayed awake and alert', _stayedAwakeAfter),
          _buildRequirement('Prayed Fajr on time', _prayedFajrOnTime),
          _buildRequirement('60+ minutes of work', _minutesWorked >= 60),
          _buildRequirement('Qualifying work type', isQualifyingWork),
          if (_prayedAtMasjid) ...[
            const SizedBox(height: 8),
            Row(
              children: const [
                Icon(Icons.star, color: Colors.amber, size: 16),
                SizedBox(width: 8),
                Text('Bonus: Prayed at Masjid! 🌟'),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRequirement(String label, bool met) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            met ? Icons.check : Icons.close,
            color: met ? Colors.green : Colors.red,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              decoration: met ? null : TextDecoration.lineThrough,
              color: met ? null : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: _isSubmitting ? null : _handleSubmit,
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: _isSubmitting
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text('Submit Log'),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    // Additional validation
    if (!_wokeUpForFajr || !_stayedAwakeAfter) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be awake and alert for Fajr'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final provider = context.read<ChallengeProvider>();

    final success = await provider.logDay(
      prayedFajrOnTime: _prayedFajrOnTime,
      prayedAtMasjid: _prayedAtMasjid,
      minutesWorked: _minutesWorked,
      workDescription: _workDescriptionController.text,
      workType: _selectedWorkType,
      reflection: _reflectionController.text.isNotEmpty
          ? _reflectionController.text
          : null,
    );

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (success) {
      final isQualifyingWork = _selectedWorkType != WorkType.passiveConsumption &&
          _selectedWorkType != WorkType.routineAdmin &&
          _selectedWorkType != WorkType.socialMedia;

      final isQualifying = _wokeUpForFajr &&
          _stayedAwakeAfter &&
          _prayedFajrOnTime &&
          _minutesWorked >= 60 &&
          isQualifyingWork;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          icon: Icon(
            isQualifying
                ? (_prayedAtMasjid ? Icons.stars : Icons.celebration)
                : Icons.check_circle,
            size: 48,
            color: isQualifying ? Colors.green : Colors.orange,
          ),
          title: Text(
            isQualifying
                ? (_prayedAtMasjid ? 'Exceptional!' : 'Excellent!')
                : 'Day Logged',
          ),
          content: Text(
            isQualifying
                ? (_prayedAtMasjid
                ? 'Outstanding! You prayed at the masjid AND completed your morning work. True Subh Warrior spirit! 🌟'
                : 'You\'ve earned a qualifying day! Keep up the great work!')
                : 'Day logged successfully. Review the requirements and try again tomorrow!',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to log day. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}