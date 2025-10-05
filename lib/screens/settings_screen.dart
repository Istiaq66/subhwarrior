import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:subh_warrior/providers/challenge_provider.dart';
import 'package:subh_warrior/providers/prayer_time_provider.dart';
import 'package:subh_warrior/providers/theme_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();

  bool _isLoadingLocation = false;
  bool _notificationsEnabled = true;
  bool _fajrReminder = true;
  bool _loggingReminder = true;
  int _fajrReminderMinutes = 15;
  bool _useHanafiMethod = false; // Add this to track Hanafi method

  // Prayer calculation methods
  final Map<int, String> _calculationMethods = {
    1: 'University of Islamic Sciences, Karachi',
    2: 'Islamic Society of North America (ISNA)',
    3: 'Muslim World League (MWL)',
    4: 'Umm Al-Qura University, Makkah',
    5: 'Egyptian General Authority',
    15: 'Moonsighting Committee',
  };

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  void _loadCurrentSettings() {
    final challengeProvider = context.read<ChallengeProvider>();
    _nameController.text = challengeProvider.userName;
    _locationController.text = challengeProvider.userLocation;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSettings,
            tooltip: 'Save Settings',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileSection(),
            _buildLocationSection(),
            _buildPrayerSettingsSection(),
            _buildNotificationSection(),
            _buildAppearanceSection(),
            _buildChallengeSection(),
            _buildAboutSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Profile',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Your Name',
                hintText: 'Enter your name',
                prefixIcon: const Icon(Icons.badge),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Consumer<ChallengeProvider>(
              builder: (context, provider, _) {
                if (!provider.isChallengeActive) {
                  return const SizedBox();
                }

                return Column(
                  children: [
                    _buildStatRow('Total Days', '${provider.totalQualifyingDays}'),
                    _buildStatRow('Current Streak', '${provider.currentStreak}'),
                    _buildStatRow('Challenge Week', '${provider.currentWeek}/4'),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Location',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: 'City/Location',
                hintText: 'e.g., New York, USA',
                prefixIcon: const Icon(Icons.map),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isLoadingLocation ? null : _getCurrentLocation,
                icon: _isLoadingLocation
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.my_location),
                label: Text(_isLoadingLocation
                    ? 'Getting Location...'
                    : 'Use Current Location'),
              ),
            ),
            Consumer<ChallengeProvider>(
              builder: (context, provider, _) {
                if (provider.userLatitude != 0 && provider.userLongitude != 0) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Coordinates: ${provider.userLatitude.toStringAsFixed(4)}, ${provider.userLongitude.toStringAsFixed(4)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerSettingsSection() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.mosque,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Prayer Settings',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Consumer<PrayerTimeProvider>(
              builder: (context, provider, _) {
                return DropdownButtonFormField<int>(
                  value: provider.calculationMethod,
                  decoration: InputDecoration(
                    labelText: 'Calculation Method',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: _calculationMethods.entries.map((entry) {
                    return DropdownMenuItem(
                      value: entry.key,
                      child: Text(
                        entry.value,
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      provider.updateCalculationMethod(value);
                      _refreshPrayerTimes();
                    }
                  },
                );
              },
            ),
            const SizedBox(height: 12),
            Consumer<PrayerTimeProvider>(
              builder: (context, provider, _) {
                _useHanafiMethod = provider.useHanafiMethod;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Juristic Method'),
                  subtitle: Text(_useHanafiMethod
                      ? 'Hanafi (Later Asr time)'
                      : 'Standard (Shafi, Maliki, Hanbali)'),
                  trailing: Switch(
                    value: _useHanafiMethod,
                    onChanged: (value) {
                      setState(() {
                        _useHanafiMethod = value;
                      });
                      provider.updateJuristicMethod(value);
                      _refreshPrayerTimes();
                    },
                  ),
                );
              },
            ),
            if (_useHanafiMethod)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Hanafi method calculates Asr time when shadow is twice the object length',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSection() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.notifications,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Notifications',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Enable Notifications'),
              subtitle: const Text('Get reminders and updates'),
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
            if (_notificationsEnabled) ...[
              const Divider(),
              SwitchListTile(
                title: const Text('Fajr Prayer Reminder'),
                subtitle: Text('Notify $_fajrReminderMinutes min before Fajr'),
                value: _fajrReminder,
                onChanged: (value) {
                  setState(() {
                    _fajrReminder = value;
                  });
                },
              ),
              if (_fajrReminder) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Text('Remind me'),
                      const SizedBox(width: 8),
                      DropdownButton<int>(
                        value: _fajrReminderMinutes,
                        items: [5, 10, 15, 20, 30].map((minutes) {
                          return DropdownMenuItem(
                            value: minutes,
                            child: Text('$minutes min'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _fajrReminderMinutes = value!;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      const Text('before Fajr'),
                    ],
                  ),
                ),
              ],
              const Divider(),
              SwitchListTile(
                title: const Text('Daily Logging Reminder'),
                subtitle: const Text('Remind at 7:30 AM to log day'),
                value: _loggingReminder,
                onChanged: (value) {
                  setState(() {
                    _loggingReminder = value;
                  });
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAppearanceSection() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.palette,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Appearance',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, _) {
                return SwitchListTile(
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Easier on eyes for Fajr time'),
                  value: themeProvider.isDarkMode,
                  onChanged: (value) {
                    themeProvider.toggleTheme();
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengeSection() {
    return Consumer<ChallengeProvider>(
      builder: (context, provider, _) {
        if (!provider.isChallengeActive) {
          return const SizedBox();
        }

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.flag,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Challenge',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Challenge Started'),
                  subtitle: Text(
                    provider.challengeStartDate != null
                        ? '${provider.challengeStartDate!.day}/${provider.challengeStartDate!.month}/${provider.challengeStartDate!.year}'
                        : 'Not started',
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    _showEndChallengeDialog(provider);
                  },
                  icon: const Icon(Icons.stop, color: Colors.red),
                  label: const Text(
                    'End Challenge',
                    style: TextStyle(color: Colors.red),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAboutSection() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'About',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.apps),
              title: const Text('App Version'),
              subtitle: const Text('1.0.0'),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.book),
              title: const Text('Guidelines'),
              onTap: _showGuidelinesDialog,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.feedback),
              title: const Text('Send Feedback'),
              onTap: () {
                // Open feedback form or email
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.share),
              title: const Text('Share App'),
              onTap: () {
                // Share app link
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Reverse geocoding to get city name
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final location = '${place.locality}, ${place.country}';

        setState(() {
          _locationController.text = location;
        });

        // Update provider with coordinates
        final provider = context.read<ChallengeProvider>();
        await provider.updateUserSettings(
          name: _nameController.text,
          location: location,
          latitude: position.latitude,
          longitude: position.longitude,
        );

        // Update prayer times
        await _refreshPrayerTimes();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error getting location: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _refreshPrayerTimes() async {
    final challengeProvider = context.read<ChallengeProvider>();
    final prayerProvider = context.read<PrayerTimeProvider>();

    if (challengeProvider.userLatitude != 0 && challengeProvider.userLongitude != 0) {
      await prayerProvider.fetchPrayerTimes(
        challengeProvider.userLatitude,
        challengeProvider.userLongitude,
      );
    }
  }

  Future<void> _saveSettings() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your name'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final provider = context.read<ChallengeProvider>();

    // Parse location to get coordinates if needed
    double lat = provider.userLatitude;
    double lon = provider.userLongitude;

    await provider.updateUserSettings(
      name: _nameController.text,
      location: _locationController.text,
      latitude: lat,
      longitude: lon,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings saved successfully'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }

  void _showEndChallengeDialog(ChallengeProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Challenge?'),
        content: const Text(
          'Are you sure you want to end the challenge? '
              'Your progress will be saved but the challenge will be marked as incomplete.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await provider.endChallenge();
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text(
              'End Challenge',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showGuidelinesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Challenge Guidelines'),
        content: const SingleChildScrollView(
          child: Text(
            '🌅 SUBH WARRIOR CHALLENGE\n\n'
                '✓ Wake up at or before Fajr time\n'
                '✓ Stay awake and alert\n'
                '✓ Pray Fajr within the prayer window\n'
                '✓ Complete 60+ minutes of productive work\n'
                '✓ Log before 8 AM daily\n'
                '✓ Complete 16+ days over 4 weeks\n'
                '✓ Minimum 4 qualifying days per week\n\n'
                'QUALIFYING WORK:\n'
                '• Deep work tasks\n'
                '• Strategic planning\n'
                '• Learning/skill development\n'
                '• Creative projects\n'
                '• Important communication\n\n'
                'NON-QUALIFYING:\n'
                '• Passive content consumption\n'
                '• Routine administrative tasks\n'
                '• Social media\n\n'
                'Note: Weekends do not count as qualifying days.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }
}