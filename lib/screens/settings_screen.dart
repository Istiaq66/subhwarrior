import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:subh_warrior/core/constants/app_constants.dart';
import 'package:subh_warrior/core/l10n/app_localizations.dart';
import 'package:subh_warrior/core/theme/app_colors.dart';
import 'package:subh_warrior/features/auth/data/auth_service.dart';
import 'package:subh_warrior/features/challenge/presentation/challenge_controller.dart';
import 'package:subh_warrior/features/prayer_times/presentation/prayer_times_controller.dart';
import 'package:subh_warrior/helpers/notification_service.dart';
import 'package:subh_warrior/providers/theme_provider.dart';
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
        title: Text(AppLocalizations.of(context)!.settingsTitle),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSettings,
            tooltip: AppLocalizations.of(context)!.settingsSaveTooltip,
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
    final l10n = AppLocalizations.of(context)!;
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
                  l10n.settingsProfileTitle,
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
                labelText: l10n.settingsNameLabel,
                hintText: l10n.settingsNameHint,
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
                    _buildStatRow(l10n.settingsStatTotalDays,
                        '${provider.totalQualifyingDays}'),
                    _buildStatRow(l10n.settingsStatCurrentStreak,
                        '${provider.currentStreak}'),
                    _buildStatRow(
                        l10n.settingsStatChallengeWeek,
                        l10n.settingsChallengeWeekRatio(
                            provider.currentWeek, 4)),
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
    final l10n = AppLocalizations.of(context)!;
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
                  l10n.settingsLocationTitle,
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
                labelText: l10n.onboardingLocationFieldLabel,
                hintText: l10n.onboardingLocationFieldHint,
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
                    ? l10n.onboardingGettingLocation
                    : l10n.onboardingUseCurrentLocation),
              ),
            ),
            Consumer<ChallengeProvider>(
              builder: (context, provider, _) {
                if (provider.userLatitude != 0 && provider.userLongitude != 0) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      l10n.settingsCoordinates(
                          provider.userLatitude.toStringAsFixed(4),
                          provider.userLongitude.toStringAsFixed(4)),
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
    final l10n = AppLocalizations.of(context)!;
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
                  l10n.settingsPrayerSettingsTitle,
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
                    labelText: l10n.settingsCalculationMethodLabel,
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
                      title: Text(l10n.settingsJuristicMethodTitle),
                      subtitle: Text(useHanafi
                          ? l10n.settingsJuristicHanafi
                          : l10n.settingsJuristicStandard),
                      trailing: Semantics(
                        label: l10n.settingsJuristicMethodTitle,
                        child: Switch(
                          value: useHanafi,
                          onChanged: (value) {
                            provider.updateJuristicMethod(value);
                            _refreshPrayerTimes();
                          },
                        ),
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
                                l10n.settingsHanafiInfo,
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
    final l10n = AppLocalizations.of(context)!;
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
                  l10n.settingsNotificationsTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: Text(l10n.settingsEnableNotifications),
              subtitle: Text(l10n.settingsEnableNotificationsSubtitle),
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
                title: Text(l10n.settingsFajrReminderTitle),
                subtitle: Text(
                    l10n.settingsFajrReminderSubtitle(_fajrReminderMinutes)),
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
                      Text(l10n.settingsRemindMe),
                      const SizedBox(width: 8),
                      DropdownButton<int>(
                        value: _fajrReminderMinutes,
                        items: [5, 10, 15, 20, 30].map((minutes) {
                          return DropdownMenuItem(
                            value: minutes,
                            child: Text(l10n.commonMinutesShort(minutes)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _fajrReminderMinutes = value!;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      Text(l10n.settingsBeforeFajr),
                    ],
                  ),
                ),
              ],
              const Divider(),
              SwitchListTile(
                title: Text(l10n.settingsLoggingReminderTitle),
                subtitle: Text(l10n.settingsLoggingReminderSubtitle(context
                    .watch<PrayerTimeProvider>()
                    .formatClock(AppConstants.logReminderHour,
                        AppConstants.logReminderMinute))),
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
    final l10n = AppLocalizations.of(context)!;
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
                  l10n.settingsAppearanceTitle,
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
                    Text(l10n.settingsThemeLabel),
                    const SizedBox(height: 8),
                    SegmentedButton<ThemeMode>(
                      segments: [
                        ButtonSegment(
                          value: ThemeMode.system,
                          label: Text(l10n.settingsThemeSystem),
                          icon: const Icon(Icons.brightness_auto),
                        ),
                        ButtonSegment(
                          value: ThemeMode.light,
                          label: Text(l10n.settingsThemeLight),
                          icon: const Icon(Icons.light_mode),
                        ),
                        ButtonSegment(
                          value: ThemeMode.dark,
                          label: Text(l10n.settingsThemeDark),
                          icon: const Icon(Icons.dark_mode),
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
                    Text(l10n.settingsTimeFormatLabel),
                    const SizedBox(height: 8),
                    SegmentedButton<bool>(
                      segments: [
                        ButtonSegment(
                          value: false,
                          label: Text(l10n.settingsTimeFormat12),
                          icon: const Icon(Icons.schedule),
                        ),
                        ButtonSegment(
                          value: true,
                          label: Text(l10n.settingsTimeFormat24),
                          icon: const Icon(Icons.access_time),
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

        final l10n = AppLocalizations.of(context)!;
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
                      l10n.settingsChallengeTitle,
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
                  title: Text(l10n.settingsChallengeStarted),
                  subtitle: Text(
                    provider.challengeStartDate != null
                        ? '${provider.challengeStartDate!.day}/${provider.challengeStartDate!.month}/${provider.challengeStartDate!.year}'
                        : l10n.settingsChallengeNotStarted,
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
                    l10n.settingsEndChallenge,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                  style: OutlinedButton.styleFrom(
                    side:
                        BorderSide(color: Theme.of(context).colorScheme.error),
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
    final l10n = AppLocalizations.of(context)!;
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
                  l10n.settingsAboutTitle,
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
              title: Text(l10n.settingsAppVersion),
              subtitle: Text(_appVersion.isEmpty ? '…' : _appVersion),
            ),
            _buildAccountTile(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.book),
              title: Text(l10n.settingsGuidelines),
              onTap: _showGuidelinesDialog,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.feedback),
              title: Text(l10n.settingsSendFeedback),
              onTap: _sendFeedback,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.share),
              title: Text(l10n.settingsShareApp),
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
        final l10n = AppLocalizations.of(context)!;
        final isAnon = auth.isAnonymous;
        final configured = AuthService.googleServerClientId.isNotEmpty;
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(isAnon ? Icons.person_outline : Icons.verified_user),
          title:
              Text(isAnon ? l10n.settingsGuestAccount : l10n.settingsSignedIn),
          subtitle: Text(isAnon
              ? (configured
                  ? l10n.settingsLinkGooglePrompt
                  : l10n.settingsProgressSavedLocally)
              : (auth.currentUser?.email ?? l10n.settingsSynced)),
          trailing: _isAccountBusy
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : null,
          onTap: _isAccountBusy
              ? null
              : (isAnon ? (configured ? _linkGoogle : null) : _signOutAccount),
        );
      },
    );
  }

  Future<void> _linkGoogle() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isAccountBusy = true);
    try {
      await context.read<AuthService>().signInWithGoogle();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.settingsSignedInWithGoogle)),
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
    final l10n = AppLocalizations.of(context)!;
    final info = await PackageInfo.fromPlatform();
    final uri = Uri(
      scheme: 'mailto',
      path: _feedbackEmail,
      query: _encodeQuery({
        'subject': l10n.settingsFeedbackSubject,
        'body':
            '\n\n\n---\n${l10n.settingsFeedbackAppVersion(info.version, info.buildNumber)}',
      }),
    );
    if (!mounted) return;
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.settingsNoEmailApp(_feedbackEmail)),
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
    final l10n = AppLocalizations.of(context)!;
    await Share.share(l10n.settingsShareMessage, subject: l10n.splashTitle);
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
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );

      // Reverse geocoding to get city name
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (!mounted) return;

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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!
              .onboardingErrorGettingLocation('$e')),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
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
    final l10n = AppLocalizations.of(context)!;
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.settingsEnterNamePrompt),
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
            content: Text(l10n.settingsSavedSuccess),
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
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.settingsEndChallengeDialogTitle),
        content: Text(l10n.settingsEndChallengeDialogContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.settingsCancel),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              await provider.endChallenge();
              navigator.pop();
              navigator.pop();
            },
            child: Text(
              l10n.settingsEndChallenge,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showGuidelinesDialog() {
    final l10n = AppLocalizations.of(context)!;
    final cutoffTime = context
        .read<PrayerTimeProvider>()
        .formatClock(AppConstants.logCutoffHour);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.settingsGuidelinesDialogTitle),
        content: SingleChildScrollView(
          child: Text(l10n.settingsGuidelinesContent(cutoffTime)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.settingsGotIt),
          ),
        ],
      ),
    );
  }
}
