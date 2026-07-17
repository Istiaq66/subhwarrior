import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:subh_warrior/core/constants/app_constants.dart';
import 'package:subh_warrior/core/l10n/app_localizations.dart';
import 'package:subh_warrior/core/theme/app_colors.dart';
import 'package:subh_warrior/features/challenge/domain/log_result.dart';
import 'package:subh_warrior/features/challenge/domain/work_type.dart';
import 'package:subh_warrior/features/challenge/presentation/challenge_controller.dart';
import 'package:subh_warrior/features/prayer_times/presentation/prayer_times_controller.dart';

class LogDayScreen extends StatefulWidget {
  const LogDayScreen({super.key});

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

  /// Whether the selected work type counts toward a qualifying day.
  bool get _isQualifyingWork => _selectedWorkType.isQualifying;

  /// Whether the current form state would produce a qualifying day. Single
  /// source of truth — used by the live status card and the submit handler.
  bool get _isQualifyingDay =>
      _wokeUpForFajr &&
      _stayedAwakeAfter &&
      _prayedFajrOnTime &&
      _minutesWorked >= AppConstants.minDeepWorkMinutes &&
      _isQualifyingWork;

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
    final canSubmit = currentTime.hour < AppConstants.logCutoffHour;
    final isWeekend = currentTime.weekday == DateTime.saturday ||
        currentTime.weekday == DateTime.sunday;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.todayStatusLogTodayButton),
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
    final l10n = AppLocalizations.of(context)!;
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
              l10n.logDayWeekendTitle,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.logDayWeekendBody,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.logDayGoBack),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeExpired() {
    final l10n = AppLocalizations.of(context)!;
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
              l10n.logDayTimeUpTitle,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.logDayTimeUpBody(context
                  .watch<PrayerTimeProvider>()
                  .formatClock(AppConstants.logCutoffHour)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.logDayGoBack),
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
      8,
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
              AppLocalizations.of(context)!.logDayTimeRemaining(hours, minutes),
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
    final l10n = AppLocalizations.of(context)!;
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
                  l10n.logDayTodaysFajr,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (isWithinWindow)
                  Chip(
                    label: Text(l10n.logDayPrayerTimeNow),
                    backgroundColor: context.appColors.success,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              fajrTime != null
                  ? provider.formatTime(fajrTime)
                  : l10n.logDayLoading,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            if (provider.todayPrayerTimes != null) ...[
              const SizedBox(height: 4),
              Text(
                l10n.logDaySunrise(provider
                    .formatTimeString(provider.todayPrayerTimes!.sunrise)),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWakeUpSection() {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.logDayWakeUpTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              title: Text(l10n.logDayWokeUpTitle),
              subtitle: Text(l10n.logDayWokeUpSubtitle),
              value: _wokeUpForFajr,
              onChanged: (value) {
                setState(() {
                  _wokeUpForFajr = value ?? false;
                });
              },
            ),
            CheckboxListTile(
              title: Text(l10n.logDayStayedAwake),
              subtitle: Text(l10n.logDayStayedAwakeSubtitle),
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
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.todayStatusFajrPrayer,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: Text(l10n.logDayPrayedFajrOnTime),
              subtitle: Text(l10n.logDayWithinWindow),
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
                title: Text(l10n.logDayPrayedAtMasjid),
                subtitle: Text(l10n.logDayMasjidSubtitle),
                value: _prayedAtMasjid,
                onChanged: (value) {
                  setState(() {
                    _prayedAtMasjid = value;
                  });
                },
                activeColor: context.appColors.success,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWorkSection() {
    final l10n = AppLocalizations.of(context)!;
    final isQualifyingWork = _isQualifyingWork;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.logDayProductiveWork,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),

            // Work Type Selection
            Text(
              l10n.logDayTypeOfWork,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<WorkType>(
              value: _selectedWorkType,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                fillColor: isQualifyingWork
                    ? context.appColors.success.withValues(alpha: 0.1)
                    : Theme.of(context)
                        .colorScheme
                        .error
                        .withValues(alpha: 0.1),
                filled: true,
              ),
              items: WorkType.values
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(_workTypeLabel(l10n, type)),
                      ))
                  .toList(),
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
                  color: Theme.of(context)
                      .colorScheme
                      .error
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning,
                        color: Theme.of(context).colorScheme.error, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.logDayWorkNotQualify,
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
              l10n.logDayMinutesFocused(_minutesWorked),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Semantics(
              label: l10n.a11yMinutesWorkedSlider,
              child: Slider(
                value: _minutesWorked.toDouble(),
                max: 180,
                divisions: 36,
                label: l10n.commonMinutesShort(_minutesWorked),
                onChanged: (value) {
                  setState(() {
                    _minutesWorked = value.round();
                  });
                },
              ),
            ),
            if (_minutesWorked < AppConstants.minDeepWorkMinutes)
              Text(
                l10n.logDayMinimumMinutes(AppConstants.minDeepWorkMinutes),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 12,
                ),
              ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _workDescriptionController,
              decoration: InputDecoration(
                labelText: l10n.logDayDescribeWorkLabel,
                hintText: l10n.logDayDescribeWorkHint,
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.logDayDescribeWorkError;
                }
                if (value.length < 10) {
                  return l10n.logDayMoreDetailError;
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Maps a [WorkType] to its localized display label (kept at the widget
  /// layer so the domain enum stays l10n-free).
  String _workTypeLabel(AppLocalizations l10n, WorkType type) {
    switch (type) {
      case WorkType.deepWork:
        return l10n.logDayWorkTypeDeepWork;
      case WorkType.strategicPlanning:
        return l10n.logDayWorkTypeStrategicPlanning;
      case WorkType.learning:
        return l10n.logDayWorkTypeLearning;
      case WorkType.creativeProjects:
        return l10n.logDayWorkTypeCreativeProjects;
      case WorkType.importantCommunication:
        return l10n.logDayWorkTypeImportantCommunication;
      case WorkType.passiveConsumption:
        return l10n.logDayWorkTypePassiveConsumption;
      case WorkType.routineAdmin:
        return l10n.logDayWorkTypeRoutineAdmin;
      case WorkType.socialMedia:
        return l10n.logDayWorkTypeSocialMedia;
    }
  }

  Widget _buildReflectionSection() {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.logDayReflectionTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _reflectionController,
              decoration: InputDecoration(
                hintText: l10n.logDayReflectionHint,
                border: const OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQualificationStatus() {
    final l10n = AppLocalizations.of(context)!;
    final isQualifyingWork = _isQualifyingWork;
    final isQualifying = _isQualifyingDay;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isQualifying
            ? context.appColors.success.withValues(alpha: 0.1)
            : Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isQualifying
              ? context.appColors.success
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
                    ? context.appColors.success
                    : Theme.of(context).colorScheme.error,
                size: 32,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  isQualifying
                      ? l10n.logDayQualifyingDay
                      : l10n.logDayNotQualifyingYet,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildRequirement(context, l10n.logDayReqAwake, _wokeUpForFajr),
          _buildRequirement(context, l10n.logDayStayedAwake, _stayedAwakeAfter),
          _buildRequirement(
              context, l10n.logDayPrayedFajrOnTime, _prayedFajrOnTime),
          _buildRequirement(
              context,
              l10n.logDayReqMinutesWork(AppConstants.minDeepWorkMinutes),
              _minutesWorked >= AppConstants.minDeepWorkMinutes),
          _buildRequirement(
              context, l10n.logDayReqQualifyingWorkType, isQualifyingWork),
          if (_prayedAtMasjid) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.star, color: context.appColors.gold, size: 16),
                const SizedBox(width: 8),
                Text(l10n.logDayBonusMasjid),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRequirement(BuildContext context, String label, bool met) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            met ? Icons.check : Icons.close,
            semanticLabel: met
                ? AppLocalizations.of(context)!.a11yRequirementMet
                : AppLocalizations.of(context)!.a11yRequirementNotMet,
            color: met
                ? context.appColors.success
                : Theme.of(context).colorScheme.error,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              decoration: met ? null : TextDecoration.lineThrough,
              color:
                  met ? null : Theme.of(context).colorScheme.onSurfaceVariant,
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
            ? CircularProgressIndicator(
                color: Theme.of(context).colorScheme.onPrimary)
            : Text(AppLocalizations.of(context)!.logDaySubmitButton),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    // Additional validation
    if (!_wokeUpForFajr || !_stayedAwakeAfter) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.logDayMustBeAwake),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final provider = context.read<ChallengeProvider>();

    final result = await provider.logDay(
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

    if (result == LogResult.success) {
      _showSuccessDialog(isQualifying: _isQualifyingDay);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_logFailureMessage(result, context)),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  /// Confirmation dialog shown after a successful log. Tone scales with whether
  /// the day qualified and whether the user prayed at the masjid. Pops both the
  /// dialog and the log screen on "Continue".
  void _showSuccessDialog({required bool isQualifying}) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: Icon(
          isQualifying
              ? (_prayedAtMasjid ? Icons.stars : Icons.celebration)
              : Icons.check_circle,
          size: 48,
          color: isQualifying
              ? context.appColors.success
              : context.appColors.warning,
        ),
        title: Text(
          isQualifying
              ? (_prayedAtMasjid
                  ? l10n.logDayExceptional
                  : l10n.logDayExcellent)
              : l10n.logDayDayLogged,
        ),
        content: Text(
          isQualifying
              ? (_prayedAtMasjid
                  ? l10n.logDayMasjidSuccessContent
                  : l10n.logDayQualifyingSuccessContent)
              : l10n.logDayLoggedContent,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text(l10n.logDayContinue),
          ),
        ],
      ),
    );
  }

  String _logFailureMessage(LogResult result, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (result) {
      case LogResult.afterCutoff:
        return l10n.logDayAfterCutoff(context
            .read<PrayerTimeProvider>()
            .formatClock(AppConstants.logCutoffHour));
      case LogResult.weekend:
        return l10n.logDayWeekendError;
      case LogResult.alreadyLogged:
        return l10n.logDayAlreadyLogged;
      case LogResult.invalidInput:
        return l10n.logDayNotesTooLong;
      case LogResult.success:
        return '';
    }
  }
}
