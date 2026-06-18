import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:subh_warrior/core/constants/app_constants.dart';
import 'package:subh_warrior/core/theme/app_colors.dart';
import 'package:subh_warrior/helpers/notification_service.dart';
import 'package:subh_warrior/features/auth/data/auth_service.dart';
import 'package:subh_warrior/features/challenge/presentation/challenge_controller.dart';
import 'package:subh_warrior/features/prayer_times/presentation/prayer_times_controller.dart';
import 'package:subh_warrior/providers/theme_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

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
  String _appVersion = '';
  bool _isAccountBusy = false;

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
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() {
      _appVersion = '${info.version}+${info.buildNumber}';
    });
  }

  void _loadCurrentSettings() {
    final challengeProvider = context.read<ChallengeProvider>();

    // Load user info
    _nameController.text = challengeProvider.userName;
    _locationController.text = challengeProvider.userLocation;

    // Load notification settings from provider
    _notificationsEnabled = challengeProvider.notificationsEnabled;
    _fajrReminder = challengeProvider.fajrReminder;
    _loggingReminder = challengeProvider.loggingReminder;
    _fajrReminderMinutes = challengeProvider.fajrReminderMinutes;
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
                    _buildStatRow(
                        'Total Days', '${provider.totalQualifyingDays}'),
                    _buildStatRow(
                        'Current Streak', '${provider.currentStreak}'),
                    _buildStatRow(
                        'Challenge Week', '${provider.currentWeek}/4'),
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
                // Drive directly from the provider — single source of truth.
                final useHanafi = provider.useHanafiMethod;
                return Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Juristic Method'),
                      subtitle: Text(useHanafi
                          ? 'Hanafi (Later Asr time)'
                          : 'Standard (Shafi, Maliki, Hanbali)'),
                      trailing: Switch(
                        value: useHanafi,
                        onChanged: (value) {
                          provider.updateJuristicMethod(value);
                          _refreshPrayerTimes();
                        },
                      ),
                    ),
                    if (useHanafi)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primaryContainer
                              .withValues(alpha: 0.3),
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
                );
              },
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
                subtitle: Text('Remind at '
                    '${context.watch<PrayerTimeProvider>().formatClock(AppConstants.logReminderHour, AppConstants.logReminderMinute)}'
                    ' to log day'),
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
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Theme'),
                    const SizedBox(height: 8),
                    SegmentedButton<ThemeMode>(
                      segments: const [
                        ButtonSegment(
                          value: ThemeMode.system,
                          label: Text('System'),
                          icon: Icon(Icons.brightness_auto),
                        ),
                        ButtonSegment(
                          value: ThemeMode.light,
                          label: Text('Light'),
                          icon: Icon(Icons.light_mode),
                        ),
                        ButtonSegment(
                          value: ThemeMode.dark,
                          label: Text('Dark'),
                          icon: Icon(Icons.dark_mode),
                        ),
                      ],
                      selected: {themeProvider.themeMode},
                      onSelectionChanged: (selection) {
                        themeProvider.setThemeMode(selection.first);
                      },
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            Consumer<PrayerTimeProvider>(
              builder: (context, prayerProvider, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Time Format'),
                    const SizedBox(height: 8),
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(
                          value: false,
                          label: Text('12-hour'),
                          icon: Icon(Icons.schedule),
                        ),
                        ButtonSegment(
                          value: true,
                          label: Text('24-hour'),
                          icon: Icon(Icons.access_time),
                        ),
                      ],
                      selected: {prayerProvider.use24HourFormat},
                      onSelectionChanged: (selection) {
                        prayerProvider.updateTimeFormat(selection.first);
                      },
                    ),
                  ],
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
                  icon: Icon(Icons.stop,
                      color: Theme.of(context).colorScheme.error),
                  label: Text(
                    'End Challenge',
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Theme.of(context).colorScheme.error),
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
              subtitle: Text(_appVersion.isEmpty ? '…' : _appVersion),
            ),
            _buildAccountTile(),
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
              onTap: _sendFeedback,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.share),
              title: const Text('Share App'),
              onTap: _shareApp,
            ),
          ],
        ),
      ),
    );
  }

  /// Account status + Google upgrade. Anonymous users (the default) can link a
  /// Google account; signed-in users can sign out (IMPROVEMENT_PLAN D1).
  Widget _buildAccountTile() {
    final auth = context.read<AuthService>();
    return StreamBuilder(
      stream: auth.authStateChanges(),
      builder: (context, _) {
        final isAnon = auth.isAnonymous;
        final configured = AuthService.googleServerClientId.isNotEmpty;
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(isAnon ? Icons.person_outline : Icons.verified_user),
          title: Text(isAnon ? 'Guest account' : 'Signed in'),
          subtitle: Text(isAnon
              ? (configured
                  ? 'Tap to back up your progress with Google'
                  : 'Progress is saved on this device')
              : (auth.currentUser?.email ?? 'Synced')),
          trailing: _isAccountBusy
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : null,
          onTap: _isAccountBusy
              ? null
              : (isAnon
                  ? (configured ? _linkGoogle : null)
                  : _signOutAccount),
        );
      },
    );
  }

  Future<void> _linkGoogle() async {
    setState(() => _isAccountBusy = true);
    try {
      await context.read<AuthService>().signInWithGoogle();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signed in with Google.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isAccountBusy = false);
    }
  }

  Future<void> _signOutAccount() async {
    setState(() => _isAccountBusy = true);
    try {
      await context.read<AuthService>().signOut();
    } finally {
      if (mounted) setState(() => _isAccountBusy = false);
    }
  }

  /// Where "Send Feedback" mails are delivered.
  static const String _feedbackEmail = 'ahmedboby66@gmail.com';

  /// Opens the device email composer pre-filled to the support address, with the
  /// app version in the body so reports carry useful context.
  Future<void> _sendFeedback() async {
    final info = await PackageInfo.fromPlatform();
    final uri = Uri(
      scheme: 'mailto',
      path: _feedbackEmail,
      query: _encodeQuery({
        'subject': 'Subh Warrior Feedback',
        'body': '\n\n\n---\nApp version: ${info.version} (${info.buildNumber})',
      }),
    );
    if (!mounted) return;
    final launched =
        await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No email app found. Reach us at $_feedbackEmail'),
          backgroundColor: context.appColors.warning,
        ),
      );
    }
  }

  String _encodeQuery(Map<String, String> params) => params.entries
      .map((e) =>
          '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
      .join('&');

  /// Opens the system share sheet with an invite message. No store link yet
  /// (unpublished) — add the Play/App Store URL here once live.
  Future<void> _shareApp() async {
    const message =
        'Build powerful mornings with Subh Warrior — wake for Fajr, stay '
        'productive, and finish the 28-day challenge. 🌅';
    await Share.share(message, subject: 'Subh Warrior');
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
          backgroundColor: Theme.of(context).colorScheme.error,
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

    if (challengeProvider.userLatitude != 0 &&
        challengeProvider.userLongitude != 0) {
      await prayerProvider.fetchPrayerTimes(
        challengeProvider.userLatitude,
        challengeProvider.userLongitude,
      );
    }
  }

  Future<void> _saveSettings() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter your name'),
          backgroundColor: context.appColors.warning,
        ),
      );
      return;
    }

    final challengeProvider = context.read<ChallengeProvider>();
    final prayerProvider = context.read<PrayerTimeProvider>();

    try {
      // Save user profile
      await challengeProvider.updateUserSettings(
        name: _nameController.text,
        location: _locationController.text,
        latitude: challengeProvider.userLatitude,
        longitude: challengeProvider.userLongitude,
      );

      // Save notification settings
      await challengeProvider.updateNotificationSettings(
        notificationsEnabled: _notificationsEnabled,
        fajrReminder: _fajrReminder,
        loggingReminder: _loggingReminder,
        fajrReminderMinutes: _fajrReminderMinutes,
      );

      // Update notifications
      await NotificationService.updateNotifications(
        notificationsEnabled: _notificationsEnabled,
        fajrReminder: _fajrReminder,
        loggingReminder: _loggingReminder,
        fajrReminderMinutes: _fajrReminderMinutes,
        todayFajrTime: prayerProvider.todayFajrTime,
        isChallengeActive: challengeProvider.isChallengeActive,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Settings saved successfully'),
            backgroundColor: context.appColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
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
            child: Text(
              'End Challenge',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
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
        content: SingleChildScrollView(
          child: Text(
            '🌅 SUBH WARRIOR CHALLENGE\n\n'
            '✓ Wake up at or before Fajr time\n'
            '✓ Stay awake and alert\n'
            '✓ Pray Fajr within the prayer window\n'
            '✓ Complete 60+ minutes of productive work\n'
            '✓ Log before ${context.read<PrayerTimeProvider>().formatClock(AppConstants.logCutoffHour)} daily\n'
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
