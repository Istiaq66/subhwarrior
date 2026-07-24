# Challenge Completion Screen (Design)

**Date:** 2026-07-24
**Status:** Approved by owner (brainstorming session)

## Context

`ChallengeProvider._closeIfExpired()` (added same day, `lib/features/challenge/presentation/challenge_controller.dart`)
auto-flips `isChallengeActive` to `false` once the 28-day window
(`AppConstants.challengeDays`) elapses, fixing a bug where `daysRemaining` went
negative and the challenge never closed.

Today, `home_screen.dart`'s `_buildDashboard` shows the same
`InactiveChallengeView` (generic "start your challenge" CTA) for both a
brand-new user and someone who just finished 28 days — no stats recap, no
acknowledgment of the result. This spec adds a distinct completion screen
shown once, right after auto-close.

## Data model

`ChallengeData` (`lib/features/challenge/data/challenge_data.dart`) gains one
field:

```dart
bool hasUnseenCompletion = false;
```

Local-only (persisted via `ChallengeLocalDataSource`/`saveLocal`, like
`notificationsEnabled` — not synced to the Firestore leaderboard doc; it's
per-device UI state, not a leaderboard-relevant fact).

`ChallengeProvider` changes:
- `_closeIfExpired()` also sets `_data.hasUnseenCompletion = true` when it
  flips `isChallengeActive` to `false`.
- `startChallenge()` resets `hasUnseenCompletion = false` (the only way off
  the completion screen — see below).
- New getters:
  - `bool get hasUnseenCompletion => _data.hasUnseenCompletion;`
  - `bool get challengeGoalMet => _data.totalQualifyingDays >= AppConstants.qualifyingDaysGoal;`
    Read *before* `startChallenge()` resets `totalQualifyingDays`, so it must
    be read from the still-populated `_data` on the completion screen.

## Widget

New `ChallengeCompletionView` in
`lib/features/home/presentation/widgets/challenge_completion_view.dart`,
sibling to `InactiveChallengeView`. Stateless, takes the final stats + a
`VoidCallback onRestart` + the share-sheet trigger (mirrors
`InactiveChallengeView`'s existing `onStart` pattern).

`home_screen.dart`'s `_buildDashboard` Consumer branches:

```dart
if (!provider.isChallengeActive) {
  if (provider.hasUnseenCompletion) {
    return ChallengeCompletionView(
      goalMet: provider.challengeGoalMet,
      finalStreak: provider.currentStreak,
      totalQualifyingDays: provider.totalQualifyingDays,
      currentWeek: provider.currentWeek,
      onShare: () => showShareSheet(context, ...),
      onRestart: () => _startChallenge(provider),
    );
  }
  return InactiveChallengeView(onStart: () => _startChallenge(provider));
}
```

Layout (reuses `AppSpacing`/theme tokens, no new design-system components):
- Icon + headline: trophy/celebratory icon + copy when `goalMet`; a softer
  "you built momentum" icon + copy when not — same layout otherwise.
- Stats recap: final streak, `totalQualifyingDays` / `qualifyingDaysGoal`,
  week reached (`currentWeek`).
- Share button (both outcomes) → calls the existing `showShareSheet` /
  `StreakShareCard` flow unchanged.
- Single "Start New Challenge" button → `provider.startChallenge()`.

No dismiss/"later" option — restart is the only exit, so the screen
re-appears on every app open until the user restarts (matches "persist until
acted on").

## l10n

New ARB keys (en/ar/bn/ur, `lib/core/l10n/`):

| Key | Purpose |
|---|---|
| `challengeCompleteTitleGoalMet` | Headline when `totalQualifyingDays >= 16` |
| `challengeCompleteTitleFallShort` | Headline when goal missed |
| `challengeCompleteBody` | Stats recap template, placeholders `{qualifyingDays}`, `{goal}`, `{streak}`, `{week}` |
| `challengeCompleteRestartButton` | "Start New Challenge" button label |

Reuses existing `shareCardButton` / `shareCardSheetTitle` for the share flow —
no new share-sheet strings needed. Machine-drafted ar/bn/ur translations fall
under the existing pending native-speaker review item in
`IMPROVEMENT_PLAN.md`.

## Testing

Per owner decision (2026-07-18, reaffirmed 2026-07-24), no new widget/unit
tests are being written for this feature. Verify via `flutter analyze` +
existing `flutter test` suite staying green, plus a manual run.

## Out of scope

- No push/local notification announcing challenge completion.
- No historical archive of past challenge runs (only the most recent
  completed run's stats are shown, via the not-yet-reset `ChallengeData`
  fields).
- No change to the 28-day / 16-day constants themselves.
