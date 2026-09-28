import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:subh_warrior/core/constants/app_constants.dart';
import 'package:subh_warrior/core/l10n/app_localizations.dart';
import 'package:subh_warrior/core/l10n/l10n_utils.dart';
import 'package:subh_warrior/core/theme/app_snack_bars.dart';
import 'package:subh_warrior/core/theme/app_spacing.dart';
import 'package:subh_warrior/features/auth/data/auth_service.dart';
import 'package:subh_warrior/features/challenge/presentation/challenge_controller.dart';
import 'package:subh_warrior/features/prayer_times/data/fajr_call_service.dart';
import 'package:subh_warrior/features/prayer_times/presentation/prayer_times_controller.dart';
import 'package:subh_warrior/helpers/location_access.dart';
import 'package:subh_warrior/helpers/notification_permission.dart';
import 'package:subh_warrior/helpers/notification_service.dart';
import 'package:subh_warrior/providers/locale_provider.dart';
import 'package:subh_warrior/providers/theme_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with WidgetsBindingObserver {
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();

  bool _isLoadingLocation = false;
  bool _nameIsEmpty = false;
  Timer? _profileSaveTimer;
  Timer? _notificationSaveTimer;
  Future<void>? _notificationSaveInFlight;
  ChallengeProvider? _challengeProvider;
  PrayerTimeProvider? _prayerTimeProvider;

  /// Long enough to cover normal typing, short enough that leaving the
  /// screen straight after typing still lands the write.
  static const _profileSaveDebounce = Duration(milliseconds: 600);

  /// Rescheduling notifications is a string of platform-channel calls that run
  /// on Android's main thread. Flipping three switches in a row used to queue
  /// three full cycles and hang the UI, so taps are coalesced into one.
  static const _notificationSaveDebounce = Duration(milliseconds: 400);
  bool _notificationsEnabled = true;
  bool _fajrReminder = true;
  bool _fajrCall = false;

  bool _notificationsAllowed = true;

  /// Whether the OS lets the call take over the screen (Android 14+ gates
  /// this separately). Without it the call is a notification, not an alarm.
  bool _fullScreenAllowed = true;
  bool _loggingReminder = true;
  int _fajrReminderMinutes = 15;
  String _appVersion = '';
  bool _isAccountBusy = false;

  // App languages shown as endonyms — kept untranslated on purpose so users
  // can always find their own language.
  static const Map<String, String> _languageNames = {
    'en': 'English',
    'ar': 'العربية',
    'bn': 'বাংলা',
    'ur': 'اردو',
  };

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
    WidgetsBinding.instance.addObserver(this);
    _loadCurrentSettings();
    _loadAppVersion();
    _loadCallPermissions();
  }

  /// Both gates are granted on system settings pages the user leaves the app
  /// for, so they are re-read whenever the app comes back.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _loadCallPermissions();
  }

  Future<void> _loadCallPermissions() async {
    final allowed = await hasNotificationPermission();
    final fullScreen = await FajrCallService.canShowFullScreen();
    if (!mounted) return;
    setState(() {
      _notificationsAllowed = allowed;
      _fullScreenAllowed = fullScreen;
    });
  }

  Future<void> _loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() {
      _appVersion = '${info.version}+${info.buildNumber}';
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Kept so [dispose] can flush a debounced edit — the provider outlives
    // this screen, `context` does not.
    _challengeProvider = context.read<ChallengeProvider>();
    _prayerTimeProvider = context.read<PrayerTimeProvider>();
  }

  void _loadCurrentSettings() {
    final challengeProvider = context.read<ChallengeProvider>();

    // Load user info
    _nameController.text = challengeProvider.userName;
    _locationController.text = challengeProvider.userLocation;

    // Load notification settings from provider
    _notificationsEnabled = challengeProvider.notificationsEnabled;
    _fajrReminder = challengeProvider.fajrReminder;
    _fajrCall = challengeProvider.fajrCall;
    _loggingReminder = challengeProvider.loggingReminder;
    _fajrReminderMinutes = challengeProvider.fajrReminderMinutes;
  }

  @override
  void dispose() {
    // Leaving mid-edit must not lose the edit: the debounce is dropped, but
    // whatever it was about to write is written now, straight to the provider.
    WidgetsBinding.instance.removeObserver(this);
    final hadPendingEdit = _profileSaveTimer?.isActive ?? false;
    _profileSaveTimer?.cancel();
    // A queued notification save still has to land: it is written straight to
    // the provider, which outlives this screen.
    if (_notificationSaveTimer?.isActive ?? false) {
      _notificationSaveTimer!.cancel();
      unawaited(_writeNotificationSettings(_challengeProvider));
    }
    if (hadPendingEdit) {
      unawaited(_writeProfile(
        _challengeProvider,
        name: _nameController.text.trim(),
        location: _locationController.text.trim(),
      ));
    }
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
      ),
      // Comp layout: uppercase muted section labels sitting on the canvas
      // above each card, rather than an icon+title header inside every card.
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SettingsSection(
              label: AppLocalizations.of(context)!.settingsProfileTitle,
              child: _buildProfileSection(),
            ),
            _SettingsSection(
              label: AppLocalizations.of(context)!.settingsLocationTitle,
              child: _buildLocationSection(),
            ),
            _SettingsSection(
              label: AppLocalizations.of(context)!.settingsPrayerSettingsTitle,
              child: _buildPrayerSettingsSection(),
            ),
            _SettingsSection(
              label: AppLocalizations.of(context)!.settingsNotificationsTitle,
              child: _buildNotificationSection(),
            ),
            _SettingsSection(
              label: AppLocalizations.of(context)!.settingsAppearanceTitle,
              child: _buildAppearanceSection(),
            ),
            _SettingsSection(
              label: AppLocalizations.of(context)!.settingsChallengeTitle,
              child: _buildChallengeSection(),
            ),
            _SettingsSection(
              label: AppLocalizations.of(context)!.settingsAboutTitle,
              child: _buildAboutSection(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              textInputAction: TextInputAction.done,
              onChanged: (_) => _persistProfileSoon(),
              onEditingComplete: _persistProfile,
              onTapOutside: (_) => _persistProfile(),
              decoration: InputDecoration(
                labelText: l10n.settingsNameLabel,
                hintText: l10n.settingsNameHint,
                prefixIcon: const Icon(Icons.badge),
                errorText: _nameIsEmpty ? l10n.settingsEnterNamePrompt : null,
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
                        context.localizeNumber(provider.totalQualifyingDays)),
                    _buildStatRow(l10n.settingsStatCurrentStreak,
                        context.localizeNumber(provider.currentStreak)),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _locationController,
              textInputAction: TextInputAction.done,
              onChanged: (_) => _persistProfileSoon(),
              onEditingComplete: _persistProfile,
              onTapOutside: (_) => _persistProfile(),
              decoration: InputDecoration(
                labelText: l10n.onboardingLocationFieldLabel,
                hintText: l10n.onboardingLocationFieldHint,
                prefixIcon: const Icon(Icons.map),
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
                          context.localizeNumber(provider.userLatitude,
                              fractionDigits: 4),
                          context.localizeNumber(provider.userLongitude,
                              fractionDigits: 4)),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer<PrayerTimeProvider>(
              builder: (context, provider, _) {
                return DropdownButtonFormField<int>(
                  initialValue: provider.calculationMethod,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: l10n.settingsCalculationMethodLabel,
                  ),
                  items: _calculationMethods.entries.map((entry) {
                    return DropdownMenuItem(
                      value: entry.key,
                      child: Text(
                        entry.value,
                        style: Theme.of(context).textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
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
                          borderRadius: AppRadius.brSm,
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: Text(l10n.settingsEnableNotifications),
              subtitle: Text(l10n.settingsEnableNotificationsSubtitle),
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
                _persistNotificationSettingsSoon();
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
                  _persistNotificationSettingsSoon();
                },
              ),
              if (_fajrReminder) _buildFajrReminderPicker(l10n),
              SwitchListTile(
                title: Text(l10n.settingsFajrCallTitle),
                subtitle: Text(_fajrCallSubtitle(l10n)),
                value: _fajrCall,
                onChanged: (value) async {
                  if (value && !await _ensureCallCanRing()) return;
                  setState(() {
                    _fajrCall = value;
                  });
                  _persistNotificationSettingsSoon();
                  if (value) await _promptForFullScreenAccess();
                },
              ),
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
                  _persistNotificationSettingsSoon();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Presets cover the common lead times; anything else goes through the
  // custom sheet so the value is still a plain minute count.
  static const List<int> _fajrReminderPresets = [5, 10, 15];

  Widget _buildFajrReminderPicker(AppLocalizations l10n) {
    final isCustom = !_fajrReminderPresets.contains(_fajrReminderMinutes);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.settingsRemindMeBeforeFajr,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              for (final minutes in _fajrReminderPresets)
                ChoiceChip(
                  label: Text(l10n.commonMinutesShort(minutes)),
                  selected: !isCustom && _fajrReminderMinutes == minutes,
                  onSelected: (selected) {
                    if (!selected) return;
                    setState(() {
                      _fajrReminderMinutes = minutes;
                    });
                    _persistNotificationSettingsSoon();
                  },
                ),
              ChoiceChip(
                label: Text(
                  isCustom
                      ? l10n.commonMinutesShort(_fajrReminderMinutes)
                      : l10n.settingsCustomMinutes,
                ),
                selected: isCustom,
                onSelected: (_) => _openCustomFajrReminderSheet(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openCustomFajrReminderSheet() async {
    final minutes = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _CustomReminderSheet(
        initialMinutes: _fajrReminderMinutes,
      ),
    );
    if (minutes == null || !mounted) return;
    setState(() {
      _fajrReminderMinutes = minutes;
    });
    _persistNotificationSettingsSoon();
  }

  Widget _buildAppearanceSection() {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            const SizedBox(height: 8),
            Consumer<LocaleProvider>(
              builder: (context, localeProvider, _) {
                final code = localeProvider.locale?.languageCode;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.language),
                  title: Text(l10n.settingsLanguageLabel),
                  subtitle: Text(code == null
                      ? l10n.settingsLanguageSystem
                      : _languageNames[code] ?? code),
                  trailing: Icon(Directionality.of(context) == TextDirection.rtl
                      ? Icons.chevron_left
                      : Icons.chevron_right),
                  onTap: () => _showLanguageDialog(localeProvider),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(LocaleProvider localeProvider) {
    final l10n = AppLocalizations.of(context)!;
    final current = localeProvider.locale?.languageCode ?? '';

    Future<void> select(Locale? locale) async {
      Navigator.pop(context);
      await localeProvider.setLocale(locale);
      // Re-issue pending notifications so their text follows the new language.
      await _rescheduleNotifications();
    }

    showDialog<void>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n.settingsLanguageLabel),
        children: [
          RadioGroup<String>(
            groupValue: current,
            onChanged: (value) =>
                select(value == null || value.isEmpty ? null : Locale(value)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<String>(
                  value: '',
                  title: Text(l10n.settingsLanguageSystem),
                ),
                ..._languageNames.entries.map(
                  (entry) => RadioListTile<String>(
                    value: entry.key,
                    title: Text(entry.value),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _rescheduleNotifications() async {
    final challengeProvider = context.read<ChallengeProvider>();
    final prayerProvider = context.read<PrayerTimeProvider>();
    await NotificationService.updateNotifications(
      notificationsEnabled: challengeProvider.notificationsEnabled,
      fajrReminder: challengeProvider.fajrReminder,
      fajrCall: challengeProvider.fajrCall,
      loggingReminder: challengeProvider.loggingReminder,
      fajrReminderMinutes: challengeProvider.fajrReminderMinutes,
      todayFajrTime: prayerProvider.todayFajrTime,
      isChallengeActive: challengeProvider.isChallengeActive,
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
                        ? DateFormat.yMMMd()
                            .format(provider.challengeStartDate!)
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
        context.showSnack(
          e.toString().replaceAll('Exception: ', ''),
          kind: AppSnackKind.error,
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
      context.showSnack(
        l10n.settingsNoEmailApp(_feedbackEmail),
        kind: AppSnackKind.warning,
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
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      final access = await requestLocationAccess();
      if (!mounted) return;
      if (access != LocationAccess.granted) {
        showLocationAccessSnack(context, access);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );

      // Reverse geocoding is best-effort: the coordinates alone already drive
      // prayer times, so a failed or empty lookup falls back to showing them.
      var location = l10n.locationSetCoords(
        position.latitude.toStringAsFixed(2),
        position.longitude.toStringAsFixed(2),
      );
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          final locality = place.locality?.isNotEmpty ?? false
              ? place.locality!
              : (place.administrativeArea?.isNotEmpty ?? false
                  ? place.administrativeArea!
                  : l10n.locationUnknownLocality);
          final country = place.country ?? '';
          location = country.isEmpty ? locality : '$locality, $country';
        }
      } catch (_) {
        // Keep the coordinate fallback.
      }

      if (!mounted) return;
      setState(() {
        _locationController.text = location;
      });

      await context.read<ChallengeProvider>().updateUserSettings(
            name: _nameController.text,
            location: location,
            latitude: position.latitude,
            longitude: position.longitude,
          );

      if (!mounted) return;
      await _refreshPrayerTimes();
    } catch (_) {
      // Platform channel, timeout or GPS failure — the user gets one plain
      // sentence instead of the raw exception.
      if (!mounted) return;
      showLocationSnack(
        context,
        l10n.locationDetectFailed,
        kind: AppSnackKind.error,
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

  /// Says what is missing, so an enabled switch never implies a working alarm.
  String _fajrCallSubtitle(AppLocalizations l10n) {
    if (!_fajrCall) return l10n.settingsFajrCallSubtitle;
    if (!_notificationsAllowed) return l10n.settingsFajrCallNeedsNotifications;
    if (!_fullScreenAllowed) return l10n.settingsFajrCallNeedsFullScreen;
    return l10n.settingsFajrCallSubtitle;
  }

  /// Nudges the user towards the full-screen-notification page.
  ///
  /// Unlike the notification permission there is no dialog for this one — it
  /// is a system settings page — so the call stays armed and the subtitle
  /// keeps saying what is missing until it is granted.
  Future<void> _promptForFullScreenAccess() async {
    if (await FajrCallService.canShowFullScreen()) return;
    if (!mounted) return;

    final l10n = AppLocalizations.of(context)!;
    context.showSnack(
      l10n.settingsFajrCallNeedsFullScreen,
      kind: AppSnackKind.warning,
      action: SnackBarAction(
        label: l10n.locationOpenSettingsAction,
        onPressed: FajrCallService.requestFullScreenAccess,
      ),
    );
  }

  Future<bool> _ensureCallCanRing() async {
    if (await hasNotificationPermission()) {
      if (mounted) setState(() => _notificationsAllowed = true);
      return true;
    }

    if (!mounted) return false;
    final granted = await getNotificationPermission(context);
    if (!mounted) return false;
    setState(() => _notificationsAllowed = granted);
    if (granted) return true;

    context.showSnack(
      AppLocalizations.of(context)!.settingsFajrCallNeedsNotifications,
      kind: AppSnackKind.warning,
      action: SnackBarAction(
        label: AppLocalizations.of(context)!.locationOpenSettingsAction,
        onPressed: openNotificationSettings,
      ),
    );
    return false;
  }

  void _persistNotificationSettingsSoon() {
    _notificationSaveTimer?.cancel();
    _notificationSaveTimer = Timer(
      _notificationSaveDebounce,
      () => unawaited(_persistNotificationSettings()),
    );
  }

  Future<void> _persistNotificationSettings() async {
    // One cycle at a time: a save started while another is mid-flight waits
    // for it, so the platform side never has two rescheduling runs queued.
    final inFlight = _notificationSaveInFlight;
    if (inFlight != null) await inFlight;

    final save = _writeNotificationSettings(_challengeProvider);
    _notificationSaveInFlight = save;
    final error = await save;
    if (identical(_notificationSaveInFlight, save)) {
      _notificationSaveInFlight = null;
    }

    if (error == null || !mounted) return;
    context.showSnack(error, kind: AppSnackKind.error);
  }

  /// Writes the notification settings and reschedules against them, returning
  /// a message when it fails.
  Future<String?> _writeNotificationSettings(
    ChallengeProvider? challengeProvider,
  ) async {
    if (challengeProvider == null) return null;

    try {
      await challengeProvider.updateNotificationSettings(
        notificationsEnabled: _notificationsEnabled,
        fajrReminder: _fajrReminder,
        fajrCall: _fajrCall,
        loggingReminder: _loggingReminder,
        fajrReminderMinutes: _fajrReminderMinutes,
      );

      await NotificationService.updateNotifications(
        notificationsEnabled: _notificationsEnabled,
        fajrReminder: _fajrReminder,
        fajrCall: _fajrCall,
        loggingReminder: _loggingReminder,
        fajrReminderMinutes: _fajrReminderMinutes,
        todayFajrTime: _prayerTimeProvider?.todayFajrTime,
        isChallengeActive: challengeProvider.isChallengeActive,
      );
      return null;
    } catch (e) {
      return e.toString().replaceAll('Exception: ', '');
    }
  }

  /// Persists the name and location fields once typing has settled.
  ///
  /// Debounced rather than written per keystroke: each save is a preferences
  /// write plus a provider notify, and a half-typed name is not worth either.
  void _persistProfileSoon() {
    _profileSaveTimer?.cancel();
    _profileSaveTimer = Timer(_profileSaveDebounce, _persistProfile);
  }

  Future<void> _persistProfile() async {
    _profileSaveTimer?.cancel();

    final name = _nameController.text.trim();
    // An empty name is refused rather than saved over a good one; the field
    // says why instead of a snackbar the user has to dismiss.
    if (mounted) setState(() => _nameIsEmpty = name.isEmpty);
    if (name.isEmpty) return;

    final error = await _writeProfile(
      _challengeProvider,
      name: name,
      location: _locationController.text.trim(),
    );
    if (error == null || !mounted) return;
    context.showSnack(
      _profileErrorMessage(AppLocalizations.of(context)!, error),
      kind: AppSnackKind.error,
    );
  }

  /// Writes the profile through [provider], returning the failure when it
  /// fails so the caller can localize it.
  ///
  /// Takes the provider rather than reading it from `context` so [dispose] can
  /// call it on the way out.
  static Future<Object?> _writeProfile(
    ChallengeProvider? provider, {
    required String name,
    required String location,
  }) async {
    if (provider == null || name.isEmpty) return null;
    try {
      await provider.updateUserSettings(
        name: name,
        location: location,
        latitude: provider.userLatitude,
        longitude: provider.userLongitude,
      );
      return null;
    } catch (e) {
      return e;
    }
  }

  /// Turns a profile-write failure into something the user can act on.
  String _profileErrorMessage(AppLocalizations l10n, Object error) {
    if (error is UsernameTakenException) return l10n.authUsernameTaken;
    if (error is ProfileSaveFailedException) return l10n.profileSaveFailed;
    return error.toString().replaceAll('Exception: ', '');
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

/// Settings group: an uppercase muted label on the canvas, then the card of
/// rows it describes — the comp's grouping pattern.
class _SettingsSection extends StatelessWidget {
  final String label;
  final Widget child;

  const _SettingsSection({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(
              start: AppSpacing.xs,
              bottom: AppSpacing.sm,
            ),
            child: Text(
              label.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

/// Bottom sheet for a Fajr reminder lead time outside the presets. Returns the
/// chosen minute count via [Navigator.pop], or null when dismissed.
class _CustomReminderSheet extends StatefulWidget {
  final int initialMinutes;

  const _CustomReminderSheet({required this.initialMinutes});

  @override
  State<_CustomReminderSheet> createState() => _CustomReminderSheetState();
}

class _CustomReminderSheetState extends State<_CustomReminderSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.initialMinutes}');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.pop(context, int.parse(_controller.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Padding(
      // Lift the sheet above the keyboard so the field and actions stay visible.
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.settingsCustomReminderTitle,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _controller,
                autofocus: true,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
                decoration: InputDecoration(
                  labelText: l10n.settingsCustomReminderFieldLabel,
                  helperText: l10n.settingsCustomReminderHelper,
                ),
                validator: (value) {
                  final minutes = int.tryParse((value ?? '').trim());
                  if (minutes == null ||
                      minutes < AppConstants.minFajrReminderMinutes ||
                      minutes > AppConstants.maxFajrReminderMinutes) {
                    return l10n.settingsCustomReminderInvalid;
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.settingsCancel),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  FilledButton(
                    onPressed: _submit,
                    child: Text(l10n.settingsCustomReminderSave),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
