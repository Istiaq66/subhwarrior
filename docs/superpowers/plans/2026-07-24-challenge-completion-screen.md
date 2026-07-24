# Challenge Completion Screen Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Show a distinct completion recap (final streak/qualifying-days/week, share option, restart CTA) when a 28-day challenge auto-closes, instead of the generic "start your challenge" screen.

**Architecture:** Add one persisted local-only flag (`hasUnseenCompletion`) to the existing `ChallengeData`/`ChallengeLocalDataSource`/`ChallengeProvider` stack, set it when `_closeIfExpired()` fires and clear it in `startChallenge()`. A new stateless `ChallengeCompletionView` widget renders the recap; `home_screen.dart` branches to it ahead of the existing `InactiveChallengeView`.

**Tech Stack:** Flutter/Dart, `provider` state management, `flutter_localizations`/ARB (`flutter gen-l10n`), `shared_preferences`.

## Global Constraints

- Definition of done per task: `dart format` clean, `flutter analyze` zero issues, existing `flutter test` suite green (55+ tests) — copied verbatim from `IMPROVEMENT_PLAN.md`.
- **No new tests are being written** for this feature (owner decision, reaffirmed 2026-07-24) — tasks below substitute a manual verification step (`flutter analyze` + full `flutter test` run) for the usual TDD red/green steps.
- This is a personal project with no affiliation to any employer/organization — no external branding, promo text, or attribution goes in app strings, docs, or commit messages (user correction, 2026-07-24).
- Spec: `docs/superpowers/specs/2026-07-24-challenge-completion-screen-design.md`.

---

### Task 1: Add `hasUnseenCompletion` to `ChallengeData` + local persistence

**Files:**
- Modify: `lib/features/challenge/data/challenge_data.dart`
- Modify: `lib/features/challenge/data/challenge_local_data_source.dart`

**Interfaces:**
- Produces: `ChallengeData.hasUnseenCompletion` (`bool`, default `false`), read/written by `ChallengeLocalDataSource.load()`/`save()`.

- [ ] **Step 1: Add the field to `ChallengeData`**

In `lib/features/challenge/data/challenge_data.dart`, add the field next to `isChallengeActive` and thread it through the constructor:

```dart
class ChallengeData {
  DateTime? challengeStartDate;
  bool isChallengeActive;
  bool hasUnseenCompletion;
  int currentStreak;
  int totalQualifyingDays;
  int currentWeek;

  String userName;
  String userLocation;
  double userLatitude;
  double userLongitude;
  bool hasLocation;

  bool notificationsEnabled;
  bool fajrReminder;
  bool loggingReminder;
  int fajrReminderMinutes;

  List<DayLog> dayLogs;

  ChallengeData({
    this.challengeStartDate,
    this.isChallengeActive = false,
    this.hasUnseenCompletion = false,
    this.currentStreak = 0,
    this.totalQualifyingDays = 0,
    this.currentWeek = 1,
    this.userName = '',
    this.userLocation = '',
    this.userLatitude = 0.0,
    this.userLongitude = 0.0,
    this.hasLocation = false,
    this.notificationsEnabled = true,
    this.fajrReminder = true,
    this.loggingReminder = true,
    this.fajrReminderMinutes = AppConstants.defaultFajrReminderMinutes,
    List<DayLog>? dayLogs,
  }) : dayLogs = dayLogs ?? [];
}
```

- [ ] **Step 2: Persist it in `ChallengeLocalDataSource`**

In `lib/features/challenge/data/challenge_local_data_source.dart`, add a prefs key next to `_kActive`:

```dart
  static const _kActive = 'isChallengeActive';
  static const _kHasUnseenCompletion = 'hasUnseenCompletion';
```

Add it to `_allKeys` (so the existing uid-namespace migration picks it up automatically) right after `_kActive`:

```dart
  static const List<String> _allKeys = [
    _kStartDate,
    _kActive,
    _kHasUnseenCompletion,
    _kStreak,
```

In `load()`, read it next to `isChallengeActive`:

```dart
    data.isChallengeActive = prefs.getBool(_key(_kActive)) ?? false;
    data.hasUnseenCompletion =
        prefs.getBool(_key(_kHasUnseenCompletion)) ?? false;
```

In `save()`, write it next to `isChallengeActive`:

```dart
    await prefs.setBool(_key(_kActive), data.isChallengeActive);
    await prefs.setBool(
        _key(_kHasUnseenCompletion), data.hasUnseenCompletion);
```

- [ ] **Step 3: Verify**

Run: `cd "D:/Programming/subhwarrior" && dart format lib/features/challenge/data/challenge_data.dart lib/features/challenge/data/challenge_local_data_source.dart && flutter analyze`
Expected: "Formatted N files" + "No issues found!"

Run: `flutter test test/features/challenge/`
Expected: all existing tests still pass (nothing references the new field yet, so this is a pure regression check).

- [ ] **Step 4: Commit**

```bash
cd "D:/Programming/subhwarrior"
git add lib/features/challenge/data/challenge_data.dart lib/features/challenge/data/challenge_local_data_source.dart
git commit -m "feat(challenge): persist hasUnseenCompletion flag"
```

---

### Task 2: Wire the flag + `challengeGoalMet` into `ChallengeProvider`

**Files:**
- Modify: `lib/features/challenge/presentation/challenge_controller.dart:79` (getters block), `:116-133` (`startChallenge`/`endChallenge`), `:326-341` (`_closeIfExpired`)

**Interfaces:**
- Consumes: `ChallengeData.hasUnseenCompletion` (Task 1).
- Produces: `ChallengeProvider.hasUnseenCompletion` (`bool` getter), `ChallengeProvider.challengeGoalMet` (`bool` getter) — both used by `home_screen.dart` and `ChallengeCompletionView` in Task 4.

- [ ] **Step 1: Add the two getters**

Next to the existing `bool get isChallengeActive => _data.isChallengeActive;` (line 79), add:

```dart
  bool get isChallengeActive => _data.isChallengeActive;
  bool get hasUnseenCompletion => _data.hasUnseenCompletion;
```

Next to `overallProgress`/`daysRemaining` (around line 94-97), add:

```dart
  double get overallProgress =>
      _data.totalQualifyingDays / AppConstants.qualifyingDaysGoal;

  /// Whether the just-finished (or in-progress) run hit the qualifying-days
  /// goal. Must be read from `_data` before `startChallenge()` resets
  /// `totalQualifyingDays` — the completion screen reads it first.
  bool get challengeGoalMet =>
      _data.totalQualifyingDays >= AppConstants.qualifyingDaysGoal;

  int get daysRemaining =>
      math.max(0, AppConstants.challengeDays - _getDaysSinceStart());
```

- [ ] **Step 2: Set the flag when the challenge auto-closes**

In `_closeIfExpired()`, set `hasUnseenCompletion = true` alongside `isChallengeActive = false`:

```dart
  void _closeIfExpired() {
    if (_data.isChallengeActive &&
        _data.challengeStartDate != null &&
        _getDaysSinceStart() >= AppConstants.challengeDays) {
      _data.isChallengeActive = false;
      _data.hasUnseenCompletion = true;
      unawaited(_repository.save(_data));
    }
  }
```

- [ ] **Step 3: Clear the flag when a new challenge starts**

In `startChallenge()`, reset it alongside the other fields it already resets:

```dart
  Future<void> startChallenge() async {
    _data.challengeStartDate = AppDateUtils.dateOnly(DateTime.now());
    _data.isChallengeActive = true;
    _data.hasUnseenCompletion = false;
    _data.dayLogs = [];
    _data.currentStreak = 0;
    _data.totalQualifyingDays = 0;
    _data.currentWeek = 1;

    await _repository.save(_data);
    _analytics?.logEvent(AnalyticsEvents.challengeStarted);
    notifyListeners();
  }
```

- [ ] **Step 4: Verify**

Run: `cd "D:/Programming/subhwarrior" && dart format lib/features/challenge/presentation/challenge_controller.dart && flutter analyze`
Expected: "No issues found!"

Run: `flutter test test/features/challenge/`
Expected: all existing tests pass (existing `_closeIfExpired`/`startChallenge` behavior is unchanged from their perspective — this only adds a field they don't assert on).

- [ ] **Step 5: Commit**

```bash
cd "D:/Programming/subhwarrior"
git add lib/features/challenge/presentation/challenge_controller.dart
git commit -m "feat(challenge): expose hasUnseenCompletion and challengeGoalMet"
```

---

### Task 3: Add l10n keys (en/ar/bn/ur) and regenerate

**Files:**
- Modify: `lib/core/l10n/app_en.arb`, `lib/core/l10n/app_ar.arb`, `lib/core/l10n/app_bn.arb`, `lib/core/l10n/app_ur.arb`

**Interfaces:**
- Produces: `AppLocalizations.challengeCompleteTitleGoalMet`, `.challengeCompleteTitleFallShort`, `.challengeCompleteBody(int qualifyingDays, int goal, int streak, int week)`, `.challengeCompleteRestartButton` — all consumed by `ChallengeCompletionView` in Task 4.

- [ ] **Step 1: Add the English (template) keys**

In `lib/core/l10n/app_en.arb`, add these four keys right after `"inactiveChallengeStartButton": "Start Challenge",` (line 37):

```json
  "inactiveChallengeStartButton": "Start Challenge",
  "challengeCompleteTitleGoalMet": "Challenge complete — well done!",
  "challengeCompleteTitleFallShort": "Challenge complete — you built real momentum",
  "challengeCompleteBody": "You logged {qualifyingDays} of {goal} qualifying days, with a best streak of {streak} and reached week {week}.",
  "@challengeCompleteBody": {
    "description": "Stats recap shown on the challenge completion screen",
    "placeholders": {
      "qualifyingDays": { "type": "int", "format": "decimalPattern" },
      "goal": { "type": "int", "format": "decimalPattern" },
      "streak": { "type": "int", "format": "decimalPattern" },
      "week": { "type": "int", "format": "decimalPattern" }
    }
  },
  "challengeCompleteRestartButton": "Start New Challenge",
```

- [ ] **Step 2: Add the Arabic translations**

In `lib/core/l10n/app_ar.arb`, add right after the existing `"inactiveChallengeStartButton": "ابدأ التحدي",` line:

```json
  "inactiveChallengeStartButton": "ابدأ التحدي",
  "challengeCompleteTitleGoalMet": "اكتمل التحدي — أحسنت!",
  "challengeCompleteTitleFallShort": "اكتمل التحدي — لقد حققت زخمًا حقيقيًا",
  "challengeCompleteBody": "سجّلت {qualifyingDays} من أصل {goal} أيام مؤهلة، بأفضل سلسلة متتالية {streak} ووصلت إلى الأسبوع {week}.",
  "challengeCompleteRestartButton": "ابدأ تحديًا جديدًا",
```

- [ ] **Step 3: Add the Bengali translations**

In `lib/core/l10n/app_bn.arb`, find the equivalent `"inactiveChallengeStartButton"` line and add right after it:

```json
  "challengeCompleteTitleGoalMet": "চ্যালেঞ্জ সম্পন্ন — চমৎকার করেছেন!",
  "challengeCompleteTitleFallShort": "চ্যালেঞ্জ সম্পন্ন — আপনি ভালো অগ্রগতি অর্জন করেছেন",
  "challengeCompleteBody": "আপনি {goal} টির মধ্যে {qualifyingDays} টি যোগ্য দিন লগ করেছেন, সেরা স্ট্রিক {streak} এবং সপ্তাহ {week} পর্যন্ত পৌঁছেছেন।",
  "challengeCompleteRestartButton": "নতুন চ্যালেঞ্জ শুরু করুন",
```

- [ ] **Step 4: Add the Urdu translations**

In `lib/core/l10n/app_ur.arb`, find the equivalent `"inactiveChallengeStartButton"` line and add right after it:

```json
  "challengeCompleteTitleGoalMet": "چیلنج مکمل — شاندار کارکردگی!",
  "challengeCompleteTitleFallShort": "چیلنج مکمل — آپ نے اچھی پیش رفت کی",
  "challengeCompleteBody": "آپ نے {goal} میں سے {qualifyingDays} اہل دن لاگ کیے، بہترین اسٹریک {streak} کے ساتھ اور ہفتہ {week} تک پہنچے۔",
  "challengeCompleteRestartButton": "نیا چیلنج شروع کریں",
```

- [ ] **Step 5: Regenerate and verify**

Run: `cd "D:/Programming/subhwarrior" && flutter gen-l10n`
Expected: completes with no errors (a "translation not 100% complete" info message is fine — matches existing ar/bn/ur state).

Run: `dart format lib/core/l10n/*.arb 2>/dev/null; flutter analyze`
Expected: "No issues found!" (ARB files aren't Dart, `dart format` will just skip them — the real check is that `app_localizations*.dart` compiles).

Run: `flutter test`
Expected: all existing tests pass (no test references these new keys yet).

- [ ] **Step 6: Commit**

```bash
cd "D:/Programming/subhwarrior"
git add lib/core/l10n/
git commit -m "feat(l10n): add challenge-completion screen strings (en/ar/bn/ur)"
```

---

### Task 4: `ChallengeCompletionView` widget

**Files:**
- Create: `lib/features/home/presentation/widgets/challenge_completion_view.dart`

**Interfaces:**
- Consumes: `AppLocalizations` keys from Task 3; `AppConstants.qualifyingDaysGoal` (`lib/core/constants/app_constants.dart`); `AppSpacing`/`AppRadius` (`lib/core/theme/app_spacing.dart`); `LocalizedNumberX.localizeNumber` (`lib/core/l10n/l10n_utils.dart`).
- Produces: `ChallengeCompletionView` widget, constructor `({required bool goalMet, required int finalStreak, required int totalQualifyingDays, required int currentWeek, required VoidCallback onShare, required VoidCallback onRestart})` — consumed by `home_screen.dart` in Task 5.

- [ ] **Step 1: Write the widget**

```dart
import 'package:flutter/material.dart';

import 'package:subh_warrior/core/constants/app_constants.dart';
import 'package:subh_warrior/core/l10n/app_localizations.dart';
import 'package:subh_warrior/core/l10n/l10n_utils.dart';
import 'package:subh_warrior/core/theme/app_spacing.dart';

/// Shown once, in place of [InactiveChallengeView], right after a challenge's
/// 28-day window auto-closes — recaps the final stats and offers to restart.
/// Stays on screen (re-shown on every app open) until the user taps restart;
/// there is no separate dismiss action (see the completion-screen design doc).
class ChallengeCompletionView extends StatelessWidget {
  final bool goalMet;
  final int finalStreak;
  final int totalQualifyingDays;
  final int currentWeek;
  final VoidCallback onShare;
  final VoidCallback onRestart;

  const ChallengeCompletionView({
    super.key,
    required this.goalMet,
    required this.finalStreak,
    required this.totalQualifyingDays,
    required this.currentWeek,
    required this.onShare,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              goalMet ? Icons.emoji_events : Icons.trending_up,
              size: 100,
              color: goalMet ? scheme.primary : scheme.secondary,
            ),
            AppSpacing.vGapLg,
            Text(
              goalMet
                  ? l10n.challengeCompleteTitleGoalMet
                  : l10n.challengeCompleteTitleFallShort,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            AppSpacing.vGapMd,
            Text(
              l10n.challengeCompleteBody(
                totalQualifyingDays,
                AppConstants.qualifyingDaysGoal,
                finalStreak,
                currentWeek,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.vGapXl,
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onShare,
                icon: const Icon(Icons.share),
                label: Text(l10n.shareCardButton),
              ),
            ),
            AppSpacing.vGapMd,
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onRestart,
                icon: const Icon(Icons.play_arrow),
                label: Text(l10n.challengeCompleteRestartButton),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl, vertical: AppSpacing.md),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

Note: `totalQualifyingDays`/`finalStreak`/`currentWeek` are plain `int` here (not passed through `context.localizeNumber`) because they flow through the ARB `{qualifyingDays}`/`{goal}`/`{streak}`/`{week}` placeholders, which `gen-l10n`'s `decimalPattern` format already localizes — same pattern as `shareCardWeekLabel`/`inactiveChallengeBody` elsewhere in the codebase.

- [ ] **Step 2: Verify**

Run: `cd "D:/Programming/subhwarrior" && dart format lib/features/home/presentation/widgets/challenge_completion_view.dart && flutter analyze`
Expected: "No issues found!" (the widget isn't referenced anywhere yet, so analyze just checks it compiles standalone — an unused-file warning is not a thing in Dart, so this is safe).

- [ ] **Step 3: Commit**

```bash
cd "D:/Programming/subhwarrior"
git add lib/features/home/presentation/widgets/challenge_completion_view.dart
git commit -m "feat(home): add ChallengeCompletionView widget"
```

---

### Task 5: Wire `ChallengeCompletionView` into `home_screen.dart`

**Files:**
- Modify: `lib/features/home/presentation/home_screen.dart:15-20` (imports), `:126-134` (`_buildDashboard` branch)

**Interfaces:**
- Consumes: `ChallengeProvider.hasUnseenCompletion`, `.challengeGoalMet`, `.currentStreak`, `.totalQualifyingDays`, `.currentWeek`, `.startChallenge()` (Task 2); `ChallengeCompletionView` (Task 4); `showShareSheet` (already imported, `lib/features/share/presentation/share_sheet.dart`).

- [ ] **Step 1: Import the new widget**

In `lib/features/home/presentation/home_screen.dart`, add the import alongside the other `widgets/` imports (line 16):

```dart
import 'widgets/challenge_completion_view.dart';
import 'widgets/greeting_header.dart';
import 'widgets/inactive_challenge_view.dart';
```

- [ ] **Step 2: Branch to it ahead of `InactiveChallengeView`**

In `_buildDashboard()`, replace:

```dart
          if (!provider.isChallengeActive) {
            return InactiveChallengeView(
              onStart: () => _startChallenge(provider),
            );
          }
```

with:

```dart
          if (!provider.isChallengeActive) {
            if (provider.hasUnseenCompletion) {
              return ChallengeCompletionView(
                goalMet: provider.challengeGoalMet,
                finalStreak: provider.currentStreak,
                totalQualifyingDays: provider.totalQualifyingDays,
                currentWeek: provider.currentWeek,
                onShare: () => showShareSheet(
                  context,
                  currentStreak: provider.currentStreak,
                  totalQualifyingDays: provider.totalQualifyingDays,
                  currentWeek: provider.currentWeek,
                ),
                onRestart: () => _startChallenge(provider),
              );
            }
            return InactiveChallengeView(
              onStart: () => _startChallenge(provider),
            );
          }
```

- [ ] **Step 3: Verify statically**

Run: `cd "D:/Programming/subhwarrior" && dart format lib/features/home/presentation/home_screen.dart && flutter analyze`
Expected: "No issues found!"

Run: `flutter test`
Expected: all existing tests pass (75 tests as of the last full run — `test/widget_test.dart` and friends don't exercise this branch, so no existing assertions change).

- [ ] **Step 4: Manual run — verify the full flow**

Run: `cd "D:/Programming/subhwarrior" && flutter run -d <device-id>` (pick any connected device/emulator from `flutter devices`).

In the running app:
1. Complete or fast-forward a challenge so `isChallengeActive` flips to `false` with `hasUnseenCompletion = true`. The fastest way: temporarily set a breakpoint or use `flutter`'s dev tools to inspect `SharedPreferences`, **or** simpler — start a challenge, then in `_closeIfExpired()` temporarily change `AppConstants.challengeDays` to `0` in a local uncommitted edit, restart the app, confirm the completion screen appears, then revert that temporary edit (do not commit it).
2. Confirm the recap shows the right streak/qualifying-days/week numbers.
3. Tap "Share" — confirm the existing share sheet opens with the streak card.
4. Close the share sheet, tap "Start New Challenge" — confirm it starts a fresh challenge (dashboard shows day-1 state) and that reopening the app no longer shows the completion screen.

Expected: all four checks pass. This substitutes for automated widget tests per the no-new-tests decision.

- [ ] **Step 5: Commit**

```bash
cd "D:/Programming/subhwarrior"
git add lib/features/home/presentation/home_screen.dart
git commit -m "feat(home): show completion recap instead of the generic start screen"
```

---

## Self-review notes

- **Spec coverage:** data model (Task 1-2), widget (Task 4), home_screen wiring (Task 5), l10n (Task 3), no-dismiss/restart-only behavior (Task 4 docstring + Task 5 wiring), share reuse (Task 5 `onShare`) — all present. Out-of-scope items (notifications, archive, constant changes) are correctly untouched by any task.
- **Type consistency:** `ChallengeProvider.challengeGoalMet` (bool), `.hasUnseenCompletion` (bool) match their use in Task 5; `ChallengeCompletionView`'s constructor param names (`goalMet`, `finalStreak`, `totalQualifyingDays`, `currentWeek`, `onShare`, `onRestart`) match exactly between Task 4's definition and Task 5's call site.
- **No placeholders:** every step has literal code/commands; the manual-run step (Task 5 Step 4) gives a concrete temporary-edit technique rather than "test it somehow".
