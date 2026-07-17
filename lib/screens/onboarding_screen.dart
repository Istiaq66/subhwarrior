import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:subh_warrior/core/constants/app_constants.dart';
import 'package:subh_warrior/core/l10n/app_localizations.dart';
import 'package:subh_warrior/core/theme/app_colors.dart';
import 'package:subh_warrior/features/challenge/presentation/challenge_controller.dart';
import 'package:subh_warrior/features/prayer_times/presentation/prayer_times_controller.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  int _currentPage = 0;
  bool _isLoadingLocation = false;
  double _latitude = 0.0;
  double _longitude = 0.0;
  bool _hasCoordinates = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final existing = context.read<ChallengeProvider>().userName.trim();
      if (existing.isNotEmpty && _nameController.text.trim().isEmpty) {
        setState(() => _nameController.text = existing);
      }
    });
  }

  ScrollPhysics get _pageScrollPhysics {
    // Page 2 is the location page; block swiping past it until a location is set.
    if (_currentPage == 2 && _locationController.text.isEmpty) {
      return const NeverScrollableScrollPhysics();
    }
    return const BouncingScrollPhysics();
  }

  Future<void> _getCoordinatesFromText() async {
    final text = _locationController.text.trim();
    if (text.isEmpty) return;

    try {
      final locations = await locationFromAddress(text);
      if (!mounted) return;
      if (locations.isNotEmpty) {
        final loc = locations.first;
        setState(() {
          _latitude = loc.latitude;
          _longitude = loc.longitude;
          _hasCoordinates = true;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(AppLocalizations.of(context)!.onboardingLocationNotFound),
            backgroundColor: context.appColors.warning,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!
              .onboardingErrorFindingLocation(e.toString())),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                physics: _pageScrollPhysics,
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildWelcomePage(),
                  _buildRulesPage(),
                  _buildLocationPage(),
                  _buildReadyPage(),
                ],
              ),
            ),
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomePage() {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.wb_sunny,
            size: 120,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 32),
          Text(
            l10n.onboardingWelcomeTitle,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.onboardingWelcomeSubtitle,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildFeatureRow(
                    Icons.mosque, l10n.onboardingFeatureFajrTracking),
                const SizedBox(height: 8),
                _buildFeatureRow(
                    Icons.timer, l10n.onboardingFeatureProductiveWork),
                const SizedBox(height: 8),
                _buildFeatureRow(Icons.calendar_month,
                    l10n.onboardingFeatureChallengeDuration),
                const SizedBox(height: 8),
                _buildFeatureRow(
                    Icons.emoji_events, l10n.onboardingFeatureAchieveDays),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRulesPage() {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.rule,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            l10n.onboardingRulesTitle,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),
          _buildRuleCard(
            '1',
            l10n.onboardingRuleWakeUpTitle,
            l10n.onboardingRuleWakeUpDesc,
            Icons.alarm,
          ),
          _buildRuleCard(
            '2',
            l10n.onboardingRulePrayTitle,
            l10n.onboardingRulePrayDesc,
            Icons.mosque,
          ),
          _buildRuleCard(
            '3',
            l10n.onboardingRuleWorkTitle,
            l10n.onboardingRuleWorkDesc,
            Icons.work,
          ),
          _buildRuleCard(
            '4',
            l10n.onboardingRuleLogTitle,
            l10n.onboardingRuleLogDesc(context
                .watch<PrayerTimeProvider>()
                .formatClock(AppConstants.logCutoffHour)),
            Icons.check_circle,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.appColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: context.appColors.warning),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.onboardingRulesGoal,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationPage() {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.location_on,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            l10n.onboardingLocationTitle,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.onboardingLocationSubtitle,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _locationController,
            onChanged: (_) {
              // Editing the text invalidates any previously resolved coords.
              if (_hasCoordinates) setState(() => _hasCoordinates = false);
            },
            decoration: InputDecoration(
              labelText: l10n.onboardingLocationFieldLabel,
              hintText: l10n.onboardingLocationFieldHint,
              prefixIcon: const Icon(Icons.map),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 16),
          Text(l10n.commonOr),
          const SizedBox(height: 16),
          OutlinedButton.icon(
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
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadyPage() {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.rocket_launch,
              size: 64,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            l10n.onboardingReadyTitle,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.inactiveChallengeTitle,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  l10n.onboardingWelcomeUser(_nameController.text.isNotEmpty
                      ? _nameController.text
                      : l10n.homeGreetingFallbackName),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                if (_locationController.text.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on, size: 16),
                      const SizedBox(width: 4),
                      Text(_locationController.text),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 48),
          FilledButton.icon(
            onPressed: _completeOnboarding,
            icon: const Icon(Icons.check),
            label: Text(l10n.onboardingStartJourneyButton),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentPage > 0)
            TextButton(
              onPressed: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: Text(l10n.onboardingBackButton),
            )
          else
            const SizedBox(width: 80),
          Row(
            children: List.generate(4, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == index
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
              );
            }),
          ),
          if (_currentPage < 3)
            TextButton(
              onPressed: () async {
                if (_currentPage == 2) {
                  final locationText = _locationController.text.trim();

                  if (locationText.isEmpty && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.onboardingSetLocationPrompt),
                        backgroundColor: context.appColors.warning,
                      ),
                    );
                    return;
                  }

                  // If user typed manually and didn't use current location
                  if (!_hasCoordinates) {
                    await _getCoordinatesFromText();

                    // Still failed to get coordinates
                    if (!_hasCoordinates && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.onboardingCoordinatesNotFound),
                          backgroundColor: Theme.of(context).colorScheme.error,
                        ),
                      );
                      return;
                    }
                  }
                }
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: Text(l10n.onboardingNextButton),
            )
          else
            const SizedBox(width: 80),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Text(text),
      ],
    );
  }

  Widget _buildRuleCard(
      String number, String title, String description, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Icon(icon, color: Theme.of(context).colorScheme.primary),
        ],
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // Check if location services are enabled
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!
                .onboardingLocationServicesDisabled),
            backgroundColor: context.appColors.warning,
          ),
        );
        setState(() {
          _isLoadingLocation = false;
        });
        return;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!
                  .onboardingLocationPermissionDenied),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
          setState(() {
            _isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!
                .onboardingLocationPermissionDeniedForever),
            backgroundColor: Theme.of(context).colorScheme.error,
            action: SnackBarAction(
              label: AppLocalizations.of(context)!.onboardingSettingsAction,
              onPressed: () {
                Geolocator.openAppSettings();
              },
            ),
          ),
        );
        setState(() {
          _isLoadingLocation = false;
        });
        return;
      }

      // If we have permission, get the position
      final position = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );

      _latitude = position.latitude;
      _longitude = position.longitude;
      _hasCoordinates = true;

      // Reverse geocoding to get city name
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (!mounted) return;

        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          final location =
              '${place.locality ?? place.administrativeArea ?? AppLocalizations.of(context)!.onboardingUnknownLocality}, ${place.country ?? ''}';

          setState(() {
            _locationController.text = location;
          });
        } else {
          setState(() {
            _locationController.text =
                AppLocalizations.of(context)!.onboardingLocationSetCoords(
              position.latitude.toStringAsFixed(2),
              position.longitude.toStringAsFixed(2),
            );
          });
        }
      } catch (e) {
        // If geocoding fails, just show coordinates
        if (!mounted) return;
        setState(() {
          _locationController.text =
              AppLocalizations.of(context)!.onboardingLocationSetCoords(
            position.latitude.toStringAsFixed(2),
            position.longitude.toStringAsFixed(2),
          );
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!
              .onboardingErrorGettingLocation(e.toString())),
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

  Future<void> _completeOnboarding() async {
    try {
      final challengeProvider = context.read<ChallengeProvider>();
      final prayerProvider = context.read<PrayerTimeProvider>();

      if (_hasCoordinates) {
        try {
          await prayerProvider.fetchPrayerTimes(_latitude, _longitude);
        } catch (_) {}
      }

      await challengeProvider.updateUserSettings(
        name: _nameController.text,
        location: _locationController.text,
        latitude: _latitude,
        longitude: _longitude,
      );
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
}
