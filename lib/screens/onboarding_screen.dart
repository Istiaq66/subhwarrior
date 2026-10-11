import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:subh_warrior/core/constants/app_constants.dart';
import 'package:subh_warrior/core/l10n/app_localizations.dart';
import 'package:subh_warrior/core/theme/app_colors.dart';
import 'package:subh_warrior/core/theme/app_snack_bars.dart';
import 'package:subh_warrior/core/theme/app_spacing.dart';
import 'package:subh_warrior/features/challenge/presentation/challenge_controller.dart';
import 'package:subh_warrior/features/location/domain/city.dart';
import 'package:subh_warrior/features/location/presentation/location_selector.dart';
import 'package:subh_warrior/features/prayer_times/presentation/prayer_times_controller.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();

  int _currentPage = 0;
  City? _city;

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
    if (_currentPage == 2 && _city == null) {
      return const NeverScrollableScrollPhysics();
    }
    return const BouncingScrollPhysics();
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
              borderRadius: AppRadius.brMd,
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
              borderRadius: AppRadius.brSm,
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
          LocationSelector(
            label: _city?.label ?? '',
            onSelected: (city) => setState(() => _city = city),
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
              borderRadius: AppRadius.brMd,
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
                if (_city != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on, size: 16),
                      const SizedBox(width: 4),
                      Text(_city!.label),
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
              onPressed: () {
                if (_currentPage == 2 && _city == null) {
                  context.showSnack(
                    l10n.onboardingSetLocationPrompt,
                    kind: AppSnackKind.warning,
                  );
                  return;
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

  /// Comp rule card: cream surface, `p-4`, a 40dp filled primary badge with a
  /// white numeral, then the title and description.
  ///
  /// This previously coloured itself with `colorScheme.surface`, which is the
  /// parchment canvas — the card was invisible against the page. It now uses
  /// the shared [Card] so it picks up the cream fill, hairline border and
  /// radius every other card has.
  Widget _buildRuleCard(
      String number, String title, String description, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: AppRadius.brMd,
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimary,
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

  Future<void> _completeOnboarding() async {
    try {
      final challengeProvider = context.read<ChallengeProvider>();
      final prayerProvider = context.read<PrayerTimeProvider>();

      final city = _city!;
      // Seed the method and Asr school from the user's country before the
      // first fetch, so the first times they see are their local ones.
      await prayerProvider.applyCountryDefaults(city.countryCode, seed: true);
      try {
        await prayerProvider.fetchPrayerTimes(city.latitude, city.longitude);
      } catch (_) {}

      await challengeProvider.updateUserSettings(
        name: _nameController.text,
        location: city.label,
        latitude: city.latitude,
        longitude: city.longitude,
      );
    } catch (e) {
      if (mounted) {
        context.showSnack(
          e.toString().replaceAll('Exception: ', ''),
          kind: AppSnackKind.error,
          duration: const Duration(seconds: 3),
        );
      }
    }
  }
}
