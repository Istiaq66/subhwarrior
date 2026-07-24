# Fajr Home-Screen Widget (Design)

**Date:** 2026-07-24
**Status:** Approved by owner (brainstorming session)

## Context

The in-app `PrayerTimeCard` (`lib/widgets/prayer_time_card.dart`) shows the next
Fajr time, a live HH:MM:SS countdown, and a Fajr-to-Fajr fill progress bar
(both added this session; math lives in `PrayerTimeProvider.durationUntilNextFajr`
and `PrayerTimeProvider.fajrCycleProgress`, `lib/features/prayer_times/presentation/prayer_times_controller.dart`).
Owner wants the same information available as an Android home-screen widget.

Owner asked to follow the sibling project **Sadiq**'s
(`D:/Office/sadiq`) precedent, which already ships three home-screen widgets.
Sadiq's architecture (confirmed by reading its source):
- `home_widget` Flutter package bridges Dart ↔ native `RemoteViews`.
- Three Kotlin classes extend `es.antonborri.home_widget.HomeWidgetProvider`,
  each reading `SharedPreferences` (`widgetData`) and populating a
  `RemoteViews` in `onUpdate`.
- The widget XML configs declare no `android:updatePeriodMillis` — refresh is
  entirely driven from the Dart side via `flutter_background_fetch`
  (`forceAlarmManager: true`), which schedules one exact `AlarmManager` task
  per prayer boundary (9 times/day) plus a daily base fetch. Each fired task
  recomputes data, calls `HomeWidget.saveWidgetData`, then
  `HomeWidget.updateWidget` per provider.
- Tap opens `MainActivity` via `HomeWidgetLaunchIntent.getActivity`.

**Key difference from Sadiq**: Sadiq refreshes at 9 boundaries/day, so an
exact-alarm-only refresh keeps things naturally fresh every few hours. This
widget cares about exactly **one** boundary (Fajr) — exact-alarm-only would
leave the countdown text stale for up to ~24h between updates. This design
adds a periodic base refresh on top of the one exact-Fajr alarm to cover that
gap.

## Scope

- **Platform**: Android only (matches the app's Android-first/Bangladesh-first
  launch strategy, `docs/superpowers/specs/2026-07-18-growth-plan-design.md`).
  No iOS WidgetKit work.
- **Content**: Fajr label + time (e.g. "Fajr 4:52 AM"), countdown text (e.g.
  "in 3h 12m"), and a native `ProgressBar` mirroring the in-app fill (0% at
  last Fajr → 100% at next Fajr).
- **Placeholder**: if the app has never fetched prayer times (fresh install,
  widget added to the home screen before the app was ever opened), the widget
  shows a fallback string instead of blank/crashing views.
- **Tap**: opens the app (`MainActivity`), same as Sadiq.

## Data contract (SharedPreferences, via `home_widget`)

`home_widget`'s `HomeWidget.saveWidgetData` writes into the same
`SharedPreferences` file the native side reads via `HomeWidgetPlugin` glue
(`group.<applicationId>` / default file depending on package version) — four
string keys:

| Key | Value | Written by |
|---|---|---|
| `fajr_widget_title` | Already-localized label, e.g. "Fajr" or its ar/bn/ur translation | Dart |
| `fajr_widget_time` | Already-localized formatted Fajr time, e.g. "4:52 AM" | Dart |
| `fajr_widget_countdown` | Already-localized countdown text, e.g. "in 3h 12m" | Dart |
| `fajr_widget_progress` | Progress fraction as a string int 0–100 (RemoteViews `ProgressBar.setProgress` takes an int) | Dart |

All four are written together, atomically, by one function
(`_updateFajrWidget` in a new file — see Files below). If any of the four are
absent (`null`) when the native side reads them, the widget renders the
placeholder state instead of partially-populated views.

**Localization stays Dart-side**: reuses the existing headless-l10n pattern
already proven in `notification_service.dart` (`_loadL10n`, using
`lookupAppLocalizations(locale)` — no `BuildContext` needed). No new Android
`strings.xml` translations; the native layout only ever displays whatever
string Dart last saved.

## Files

**New Dart:**
- `lib/features/prayer_times/data/fajr_widget_service.dart` — `FajrWidgetService.refresh()`:
  a **self-contained live refresh**, not a reuse of in-memory provider state
  (a headless background task has none). Every call:
  1. Reads the signed-in user's cached location (`userLatitude`/`userLongitude`/
     `hasLocation`) via `ChallengeLocalDataSource` and prayer-calc settings via
     `PrayerTimesLocalDataSource` — both already `SharedPreferences`-backed,
     so no `BuildContext`/provider instance is needed.
  2. If `hasLocation` is false (never configured — covers the "app never
     opened" placeholder case), leaves any previously-saved widget data
     untouched and returns early; the native side's placeholder logic (see
     below) handles the "nothing ever saved" case.
  3. Otherwise does a **live fetch** via `PrayerTimesRepositoryImpl` (today +
     tomorrow, same as `PrayerTimeProvider.fetchPrayerTimes`) — this is a real
     network call, not a stale-cache read, so the widget doesn't silently
     drift day over day if the app goes unopened for a while.
  4. On fetch success: computes countdown text (headless l10n) + progress
     fraction via the existing pure `PrayerTimeProvider.durationUntilNextFajr`/
     `fajrCycleProgress` static methods, saves all four widget-data keys, and
     calls `HomeWidget.updateWidget`.
  5. On fetch failure (offline, API error): leaves previously-saved widget
     data as-is (stale-but-real beats blanking it) and returns — same
     offline-tolerant contract as `PrayerTimeProvider._runFetch`.
  - Called from: `PrayerTimeProvider._runFetch` (after a successful in-app
    fetch, so the widget updates immediately while the app is open) and from
    the new background-fetch headless task (below) — both call the exact
    same function, no separate "cached" vs "live" code path to keep in sync.

**New Android (Kotlin), package `com.subhwarrior.app`:**
- `android/app/src/main/kotlin/com/subhwarrior/app/FajrWidgetProvider.kt` —
  extends `es.antonborri.home_widget.HomeWidgetProvider`. In `onUpdate`, reads
  the four keys from `widgetData`; if any are null, binds the placeholder
  string + hides/zeroes the progress bar; otherwise binds title/time/countdown
  text and `progressBar.progress = fajr_widget_progress.toInt()`. Sets
  `setOnClickPendingIntent` on the root view via
  `HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)`.

**New Android resources:**
- `android/app/src/main/res/layout/fajr_widget.xml` — `RemoteViews`-compatible
  layout: `TextView` title, `TextView` time, `TextView` countdown,
  `ProgressBar` (horizontal style, RemoteViews-supported natively — no custom
  canvas/drawable needed), all wrapped for the placeholder text to substitute
  cleanly (single `TextView` swapped in when data is absent, matching Sadiq's
  simplicity — no separate placeholder layout file).
- `android/app/src/main/res/xml/fajr_widget_info.xml` — `appwidget-provider`
  config: no `android:updatePeriodMillis` (0 — matches Sadiq; refresh is
  alarm/fetch-driven, not OS-periodic), `android:initialLayout` pointing at
  `fajr_widget.xml`, `android:resizeMode="horizontal|vertical"`,
  `minWidth`/`minHeight` sized for a standard 4x1 widget cell.

**Modified:**
- `pubspec.yaml` — add `home_widget: ^0.7.0` and `flutter_background_fetch: ^1.3.4`
  (pinned to whatever's current-stable at implementation time; exact versions
  resolved via `flutter pub add` during the plan, not hardcoded here).
- `android/app/src/main/AndroidManifest.xml` — register
  `<receiver android:name=".FajrWidgetProvider" ...>` with
  `<meta-data android:name="android.appwidget.provider" android:resource="@xml/fajr_widget_info" />`
  and the `APPWIDGET_UPDATE` intent-filter; `flutter_background_fetch`'s own
  manifest merge handles its receiver/service (no manual entry needed per its
  docs, verified during implementation).
- `lib/main.dart` — initialize `flutter_background_fetch`
  (`BackgroundFetch.configure` with a periodic base config, e.g. 30-minute
  interval — Android's practical floor — `forceAlarmManager: true`,
  `startOnBoot: true`, `enableHeadless: true`) plus register the headless
  task callback (`BackgroundFetch.registerHeadlessTask`) that calls
  `FajrWidgetService.refresh()`. Also schedules one additional exact
  `BackgroundFetch.scheduleTask` for the next Fajr boundary itself (via the
  already-fetched `todayFajrTime`/`tomorrowFajrTime`), re-scheduled every time
  a fresh fetch completes — this is the piece that guarantees the progress
  bar/countdown flip lands exactly on time instead of waiting for the next
  30-minute tick.
- `lib/features/prayer_times/presentation/prayer_times_controller.dart` —
  `_runFetch` calls `FajrWidgetService.refresh()` after a successful fetch (in
  addition to the background-task-triggered refreshes) so the widget updates
  immediately when the app is open and fetches succeed.

## Accepted tradeoff

`FajrWidgetService.refresh()` doing a live network fetch every ~30 minutes
(instead of reusing a cached value) means the widget stays accurate even if
the app goes unopened for days, at the cost of a background network call
every 30 minutes while the device has connectivity — same battery/data class
as Sadiq's existing background-fetch usage, not a new category of cost for
a phone that already runs this app.

## Out of scope

- iOS widget (WidgetKit) — explicitly deferred, Android-first strategy.
- Any prayer other than Fajr on the widget face — matches the in-app card's
  Fajr-only countdown/progress feature this extends.
- Widget configuration UI (size variants, multiple widget instances with
  different settings) — one fixed layout/size, matching the scope of what
  was asked for.
- Automated tests for the native Kotlin/XML layer — Flutter's test suite
  can't exercise `AppWidgetProvider`/`RemoteViews` directly; verification is
  manual (add the widget to a home screen, observe placeholder → real data
  transition, observe the Fajr-boundary reset, force-stop the app and confirm
  the widget still refreshes via the background task).

## Testing

Per the standing no-new-automated-tests decision this session:
`FajrWidgetService.refresh()`'s pure countdown/progress math is already
covered by the existing `durationUntilNextFajr`/`fajrCycleProgress` logic (no
new Dart logic to test beyond wiring). The native layer is verified manually
only (see Out of scope above) — `flutter analyze` + full `flutter test` still
gate every Dart-side commit, but this feature's real correctness bar is a
device/emulator run.
