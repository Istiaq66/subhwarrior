# Fajr Home-Screen Widget Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship an Android home-screen widget showing the next Fajr time, a countdown, and a fill progress bar (matching the in-app `PrayerTimeCard`), refreshing itself via a background task even when the app isn't open, with a placeholder state for a never-opened install.

**Architecture:** `home_widget` bridges Dart → native `RemoteViews`; `flutter_background_fetch` (`forceAlarmManager: true`) drives refresh — one 30-min periodic base task plus a self-rescheduling exact task fired right at each Fajr boundary. A single Dart service (`FajrWidgetService`) owns the entire refresh: live-fetches today/tomorrow prayer times (no BuildContext/provider needed — reads `SharedPreferences` directly, same pattern as `NotificationService`), computes countdown/progress via the already-pure static methods on `PrayerTimeProvider`, pushes to the widget, and reschedules the next boundary task.

**Tech Stack:** Flutter/Dart, Kotlin (native Android widget provider), `home_widget`, `flutter_background_fetch`, existing `provider`/Firestore/SharedPreferences stack.

## Global Constraints

- Definition of done per Dart-touching task: `dart format` clean, `flutter analyze` zero issues, existing `flutter test` suite green (75 tests as of this plan) — copied from `IMPROVEMENT_PLAN.md`.
- **No new automated tests** for this feature (standing owner decision) — the native Kotlin/XML layer can't be exercised by `flutter test` anyway; verification for that layer is a manual device run (final task).
- Android only — no iOS WidgetKit work (spec: `docs/superpowers/specs/2026-07-24-fajr-home-widget-design.md`).
- This is a personal project with no employer/organization affiliation — no external branding in any string, XML, or comment (standing user correction).
- Package `com.subhwarrior.app` — new Kotlin files go in `android/app/src/main/kotlin/com/subhwarrior/app/` (note: `MainActivity.kt` physically lives under a stale `.../com/example/subhwarrior/` folder from the original template rename, but its `package` declaration is `com.subhwarrior.app` — Kotlin's source of truth is the `package` line, not the folder path; new files use the correct conventional folder).

---

### Task 1: Add `home_widget` and `flutter_background_fetch` dependencies

**Files:**
- Modify: `pubspec.yaml`

- [ ] **Step 1: Add the packages**

Run: `cd "D:/Programming/subhwarrior" && flutter pub add home_widget flutter_background_fetch`
Expected: both added to `pubspec.yaml` under `dependencies`, `pubspec.lock` updated, command exits 0.

- [ ] **Step 2: Verify the project still builds**

Run: `flutter analyze`
Expected: "No issues found!" (adding a dependency shouldn't break anything on its own).

- [ ] **Step 3: Commit**

```bash
cd "D:/Programming/subhwarrior"
git add pubspec.yaml pubspec.lock
git commit -m "chore: add home_widget and flutter_background_fetch dependencies"
```

---

### Task 2: `FajrWidgetService` — the Dart-side refresh logic

**Files:**
- Create: `lib/features/prayer_times/data/fajr_widget_service.dart`

**Interfaces:**
- Consumes: `ChallengeLocalDataSource` (`lib/features/challenge/data/challenge_local_data_source.dart`) for `userLatitude`/`userLongitude`/`hasLocation`; `PrayerTimesLocalDataSource`/`PrayerTimesRepositoryImpl.fromPrefs` (`lib/features/prayer_times/data/`) for settings + live fetch; `PrayerTimeProvider.durationUntilNextFajr`/`.fajrCycleProgress` (`lib/features/prayer_times/presentation/prayer_times_controller.dart`, both already static/pure); `AppLocalizations`/`lookupAppLocalizations` (`lib/core/l10n/app_localizations.dart`); `LocaleProvider.prefsKey` (`lib/providers/locale_provider.dart`).
- Produces: `FajrWidgetService.refresh()` (`Future<void>`, no params) — called from Task 3 (provider wiring) and Task 7 (background-fetch callbacks). Also produces the widget-data `SharedPreferences` keys `fajr_widget_title`/`fajr_widget_time`/`fajr_widget_countdown`/`fajr_widget_progress` (strings) that Task 6's native code reads, and the `home_widget` provider identifier `'FajrWidgetProvider'` that must match Task 5's Kotlin class name exactly.

- [ ] **Step 1: Write the service**

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_background_fetch/flutter_background_fetch.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../providers/locale_provider.dart';
import '../../challenge/data/challenge_local_data_source.dart';
import '../presentation/prayer_times_controller.dart';
import 'prayer_times_local_data_source.dart';
import 'prayer_times_repository.dart';

/// Refreshes the Android Fajr home-screen widget. Self-contained — no
/// BuildContext or provider instance needed, so it's safe to call from a
/// headless background isolate (`flutter_background_fetch`) as well as
/// from the running app.
///
/// Every call does a **live** prayer-times fetch (not a stale-cache read):
/// otherwise the widget would silently drift day-to-day if the app goes
/// unopened for a while (see the design doc's "Accepted tradeoff"). On
/// success it also reschedules the next Fajr-boundary background task,
/// so the refresh chain keeps going without the app running.
class FajrWidgetService {
  static const _androidProviderName = 'FajrWidgetProvider';
  static const _boundaryTaskId = 'com.subhwarrior.app.fajr_widget_boundary';

  static Future<void> refresh() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final challengeData = ChallengeLocalDataSource(prefs, uid: uid).load();

    // Never configured (onboarding not completed) — nothing to show yet.
    // Leave any previously-saved widget data untouched; the native side
    // treats "nothing ever saved" as the placeholder case.
    if (!challengeData.hasLocation) return;

    final settings = PrayerTimesLocalDataSource(prefs).load();
    final repository = PrayerTimesRepositoryImpl.fromPrefs(prefs);

    final today = DateTime.now();
    final tomorrow = today.add(const Duration(days: 1));

    try {
      final todayTimes = await repository.fetchByCoordinates(
        today,
        challengeData.userLatitude,
        challengeData.userLongitude,
        settings,
      );
      final tomorrowTimes = await repository.fetchByCoordinates(
        tomorrow,
        challengeData.userLatitude,
        challengeData.userLongitude,
        settings,
      );

      final todayFajr = _onDay(today, todayTimes.fajr);
      final tomorrowFajr = _onDay(tomorrow, tomorrowTimes.fajr);
      if (todayFajr == null) return;

      final now = DateTime.now();
      final remaining = PrayerTimeProvider.durationUntilNextFajr(
        todayFajrTime: todayFajr,
        tomorrowFajrTime: tomorrowFajr,
        now: now,
      );
      final progress = PrayerTimeProvider.fajrCycleProgress(
            todayFajrTime: todayFajr,
            tomorrowFajrTime: tomorrowFajr,
            now: now,
          ) ??
          0.0;

      final l10n = await _loadL10n();
      final clockPattern = settings.use24HourFormat ? 'HH:mm' : 'hh:mm a';
      final countdownText = remaining == null
          ? l10n.prayerCardCountdownUnknown
          : l10n.prayerCardCountdownValue(
              remaining.inHours, remaining.inMinutes % 60);

      await HomeWidget.saveWidgetData<String>(
          'fajr_widget_title', l10n.prayerCardTitle);
      await HomeWidget.saveWidgetData<String>('fajr_widget_time',
          DateFormat(clockPattern).format(todayFajr));
      await HomeWidget.saveWidgetData<String>(
          'fajr_widget_countdown', countdownText);
      await HomeWidget.saveWidgetData<String>(
          'fajr_widget_progress', (progress * 100).round().toString());
      await HomeWidget.updateWidget(androidName: _androidProviderName);

      final nextFajr = now.isBefore(todayFajr) ? todayFajr : tomorrowFajr;
      if (nextFajr != null) {
        await _scheduleNextBoundary(nextFajr);
      }
    } catch (_) {
      // Offline or API error — leave previously-saved widget data as-is,
      // same offline-tolerant contract as PrayerTimeProvider._runFetch.
    }
  }

  static Future<void> _scheduleNextBoundary(DateTime nextFajr) async {
    final delayMs = nextFajr.difference(DateTime.now()).inMilliseconds;
    if (delayMs <= 0) return;
    await BackgroundFetch.scheduleTask(TaskConfig(
      taskId: _boundaryTaskId,
      delay: delayMs,
      periodic: false,
      forceAlarmManager: true,
      enableHeadless: true,
    ));
  }

  /// Same lookup NotificationService._loadL10n uses: honours the user's
  /// in-app language choice, falling back to the device locale (or English
  /// when unsupported). Duplicated rather than shared because that method
  /// is private to notification_service.dart — small enough to not be
  /// worth a shared-utility extraction.
  static Future<AppLocalizations> _loadL10n() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(LocaleProvider.prefsKey);
    var locale =
        stored != null ? Locale(stored) : PlatformDispatcher.instance.locale;
    if (!AppLocalizations.delegate.isSupported(locale)) {
      locale = const Locale('en');
    }
    return lookupAppLocalizations(locale);
  }

  /// Builds a [DateTime] on [day]'s calendar date from an "HH:mm" string.
  /// Same parsing PrayerTimeProvider._onDay uses.
  static DateTime? _onDay(DateTime day, String timeStr) {
    try {
      final parts = timeStr.split(':');
      return DateTime(day.year, day.month, day.day, int.parse(parts[0]),
          int.parse(parts[1]));
    } catch (e) {
      return null;
    }
  }
}
```

- [ ] **Step 2: Verify**

Run: `cd "D:/Programming/subhwarrior" && dart format lib/features/prayer_times/data/fajr_widget_service.dart && flutter analyze`
Expected: "No issues found!" — if `HomeWidget.updateWidget`'s parameter name doesn't match the installed `home_widget` version (APIs have shifted slightly across versions), analyze will report an unknown named parameter. Fix by checking the installed version's actual signature: `flutter pub deps | grep home_widget` for the version, then open `.dart_tool/../pub-cache/hosted/pub.dev/home_widget-<version>/lib/home_widget.dart` and match the parameter name exactly (`name`, `androidName`, or `qualifiedAndroidName` depending on version).

Run: `flutter test`
Expected: all existing tests still pass (this file isn't called from anywhere yet).

- [ ] **Step 3: Commit**

```bash
cd "D:/Programming/subhwarrior"
git add lib/features/prayer_times/data/fajr_widget_service.dart
git commit -m "feat(prayer-widget): add FajrWidgetService live-refresh logic"
```

---

### Task 3: Wire the in-app fetch to refresh the widget immediately

**Files:**
- Modify: `lib/features/prayer_times/presentation/prayer_times_controller.dart` (`_runFetch`, around line 149-162 as of this plan)

**Interfaces:**
- Consumes: `FajrWidgetService.refresh()` (Task 2).

- [ ] **Step 1: Call the refresh after a successful fetch**

Find `_runFetch`:

```dart
  Future<void> _runFetch(Future<void> Function() body) async {
    _isLoading = true;
    _error = '';
    _notifyDeferred();

    try {
      await body();
    } catch (e) {
      _error = 'Failed to fetch prayer times: $e';
    } finally {
      _isLoading = false;
      _notifyDeferred();
    }
  }
```

Replace with (adds a fire-and-forget widget refresh only on success — errors already fall into the existing `catch`, and re-fetching there would just duplicate the same failed network call):

```dart
  Future<void> _runFetch(Future<void> Function() body) async {
    _isLoading = true;
    _error = '';
    _notifyDeferred();

    try {
      await body();
      unawaited(FajrWidgetService.refresh());
    } catch (e) {
      _error = 'Failed to fetch prayer times: $e';
    } finally {
      _isLoading = false;
      _notifyDeferred();
    }
  }
```

Add the two needed imports at the top of the file:

```dart
import 'dart:async';

import '../data/fajr_widget_service.dart';
```

(the file already imports `package:flutter/material.dart`, `package:intl/intl.dart`, `package:shared_preferences/shared_preferences.dart`, and its own repository/domain files — add the two above alongside them.)

- [ ] **Step 2: Verify**

Run: `cd "D:/Programming/subhwarrior" && dart format lib/features/prayer_times/presentation/prayer_times_controller.dart && flutter analyze`
Expected: "No issues found!"

Run: `flutter test`
Expected: all existing tests pass — `_runFetch` is exercised by `test/features/prayer_times/prayer_times_test.dart`'s provider tests; `FajrWidgetService.refresh()` will no-op there (`FirebaseAuth.instance` / `HomeWidget` calls aren't mocked, but since those tests don't set up a signed-in Firebase user or real location data, `hasLocation` will be false and the service returns immediately without touching any platform channel — if this assumption is wrong and a test fails with a MissingPluginException or similar, wrap the `unawaited(FajrWidgetService.refresh())` call so any exception it throws is caught and swallowed rather than propagating, since it's a best-effort side effect that must never break the actual fetch).

- [ ] **Step 3: Commit**

```bash
cd "D:/Programming/subhwarrior"
git add lib/features/prayer_times/presentation/prayer_times_controller.dart
git commit -m "feat(prayer-widget): refresh the home widget after every successful fetch"
```

---

### Task 4: Android widget layout + placeholder string + brand color

**Files:**
- Create: `android/app/src/main/res/layout/fajr_widget.xml`
- Create: `android/app/src/main/res/xml/fajr_widget_info.xml`
- Create: `android/app/src/main/res/values/strings.xml`
- Modify: `android/app/src/main/res/values/colors.xml`

**Interfaces:**
- Produces: view IDs `fajr_widget_root`, `fajr_widget_content`, `fajr_widget_placeholder`, `fajr_widget_title`, `fajr_widget_time`, `fajr_widget_countdown`, `fajr_widget_progress_bar` — all consumed by Task 5's Kotlin provider. `@layout/fajr_widget` and `@xml/fajr_widget_info` consumed by Task 6's manifest entry.

- [ ] **Step 1: Add the widget's brand color**

`android/app/src/main/res/values/colors.xml` currently has one color. Add the app's primary brand color (matches `AppPalette.primary` = `Color(0xFF3F72AF)` in `lib/core/theme/app_colors.dart`) for the widget background:

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <!-- Window background shown behind the Flutter UI (e.g. while the system
         Credential Manager / Google sign-in sheet is up). Matches the app's
         light surface so it doesn't flash black. -->
    <color name="window_background">#FAFBFC</color>

    <!-- Matches AppPalette.primary (lib/core/theme/app_colors.dart) — the
         Fajr home-screen widget's background. -->
    <color name="fajr_widget_background">#3F72AF</color>
</resources>
```

- [ ] **Step 2: Add the placeholder string**

This is a new file (no `values/strings.xml` exists yet). This one string is the sole exception to keeping all widget text Dart-sourced (per the design doc): it has to render before Dart has ever run, on a fresh install where the widget was added before the app was ever opened.

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="fajr_widget_placeholder">Open Subh Warrior to see prayer times</string>
</resources>
```

- [ ] **Step 3: Write the widget layout**

```xml
<?xml version="1.0" encoding="utf-8"?>
<FrameLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:id="@+id/fajr_widget_root"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:background="@color/fajr_widget_background"
    android:padding="12dp">

    <LinearLayout
        android:id="@+id/fajr_widget_content"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:orientation="vertical"
        android:visibility="gone">

        <TextView
            android:id="@+id/fajr_widget_title"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:textColor="@android:color/white"
            android:textSize="12sp" />

        <TextView
            android:id="@+id/fajr_widget_time"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:textColor="@android:color/white"
            android:textSize="20sp"
            android:textStyle="bold" />

        <TextView
            android:id="@+id/fajr_widget_countdown"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:textColor="@android:color/white"
            android:textSize="14sp" />

        <ProgressBar
            android:id="@+id/fajr_widget_progress_bar"
            style="?android:attr/progressBarStyleHorizontal"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginTop="6dp"
            android:max="100"
            android:progress="0" />
    </LinearLayout>

    <TextView
        android:id="@+id/fajr_widget_placeholder"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:textColor="@android:color/white"
        android:textSize="13sp"
        android:text="@string/fajr_widget_placeholder"
        android:visibility="visible" />
</FrameLayout>
```

- [ ] **Step 4: Write the appwidget-provider config**

No `android:updatePeriodMillis` (matches the design — refresh is entirely driven by Task 2/7's background-fetch scheduling, not the OS's own periodic timer):

```xml
<?xml version="1.0" encoding="utf-8"?>
<appwidget-provider xmlns:android="http://schemas.android.com/apk/res/android"
    android:minWidth="250dp"
    android:minHeight="60dp"
    android:updatePeriodMillis="0"
    android:initialLayout="@layout/fajr_widget"
    android:resizeMode="horizontal|vertical"
    android:widgetCategory="home_screen" />
```

- [ ] **Step 5: Commit**

These are resource-only files with no Dart/Kotlin to compile yet — nothing to `flutter analyze` here. Commit as-is; Task 5 wires the Kotlin provider that references these IDs, and a build-level check happens there.

```bash
cd "D:/Programming/subhwarrior"
git add android/app/src/main/res/layout/fajr_widget.xml android/app/src/main/res/xml/fajr_widget_info.xml android/app/src/main/res/values/strings.xml android/app/src/main/res/values/colors.xml
git commit -m "feat(prayer-widget): add Fajr widget layout, config, and placeholder string"
```

---

### Task 5: Native `FajrWidgetProvider.kt`

**Files:**
- Create: `android/app/src/main/kotlin/com/subhwarrior/app/FajrWidgetProvider.kt`

**Interfaces:**
- Consumes: view IDs from Task 4's `fajr_widget.xml`; `MainActivity` (`android/app/src/main/kotlin/com/example/subhwarrior/MainActivity.kt`, package `com.subhwarrior.app`); `HomeWidgetProvider`/`HomeWidgetLaunchIntent` from the `home_widget` plugin (Task 1).
- Produces: class `FajrWidgetProvider` — its name must match exactly the string `'FajrWidgetProvider'` already hardcoded in Task 2's `FajrWidgetService._androidProviderName`, and Task 6's manifest `<receiver android:name=".FajrWidgetProvider">`.

- [ ] **Step 1: Write the provider**

```kotlin
package com.subhwarrior.app

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

/// Populates the Fajr home-screen widget from the `home_widget`-managed
/// SharedPreferences that FajrWidgetService (Dart side) writes to. Shows a
/// placeholder instead of blank/crashing views when nothing has been saved
/// yet (fresh install, widget added before the app was ever opened).
class FajrWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.fajr_widget)

            val title = widgetData.getString("fajr_widget_title", null)
            val time = widgetData.getString("fajr_widget_time", null)
            val countdown = widgetData.getString("fajr_widget_countdown", null)
            val progress = widgetData.getString("fajr_widget_progress", null)

            if (title == null || time == null || countdown == null || progress == null) {
                views.setViewVisibility(R.id.fajr_widget_content, View.GONE)
                views.setViewVisibility(R.id.fajr_widget_placeholder, View.VISIBLE)
            } else {
                views.setViewVisibility(R.id.fajr_widget_content, View.VISIBLE)
                views.setViewVisibility(R.id.fajr_widget_placeholder, View.GONE)
                views.setTextViewText(R.id.fajr_widget_title, title)
                views.setTextViewText(R.id.fajr_widget_time, time)
                views.setTextViewText(R.id.fajr_widget_countdown, countdown)
                views.setProgressBar(
                    R.id.fajr_widget_progress_bar,
                    100,
                    progress.toIntOrNull() ?: 0,
                    false
                )
            }

            val pendingIntent =
                HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
            views.setOnClickPendingIntent(R.id.fajr_widget_root, pendingIntent)

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
```

- [ ] **Step 2: Verify it compiles as part of a full Android build**

Run: `cd "D:/Programming/subhwarrior" && flutter build apk --debug`
Expected: `BUILD SUCCESSFUL`. This is the first point Kotlin actually compiles against the `home_widget` plugin's classes (`es.antonborri.home_widget.HomeWidgetProvider`/`HomeWidgetLaunchIntent`) — if the import path is wrong for the installed version, this is where it surfaces. Fix by checking the plugin's actual package: `find "$(flutter pub cache list 2>/dev/null | grep -o '.*home_widget[^ ]*' | head -1)" 2>/dev/null` or simply open the installed package's Android source under the pub cache (`%LOCALAPPDATA%\Pub\Cache\hosted\pub.dev\home_widget-<version>\android\src\main\kotlin\`) and match the actual package/class names.

- [ ] **Step 3: Commit**

```bash
cd "D:/Programming/subhwarrior"
git add android/app/src/main/kotlin/com/subhwarrior/app/FajrWidgetProvider.kt
git commit -m "feat(prayer-widget): add native FajrWidgetProvider"
```

---

### Task 6: Register the widget receiver in the manifest

**Files:**
- Modify: `android/app/src/main/AndroidManifest.xml`

**Interfaces:**
- Consumes: `FajrWidgetProvider` (Task 5), `@xml/fajr_widget_info` (Task 4).

- [ ] **Step 1: Add the receiver**

Add right after the existing `flutter_local_notifications` receivers (before the closing `</application>` tag, currently right before the `flutterEmbedding` meta-data):

```xml
        <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED"/>
                <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
                <action android:name="android.intent.action.QUICKBOOT_POWERON" />
                <action android:name="com.htc.intent.action.QUICKBOOT_POWERON"/>
            </intent-filter>
        </receiver>

        <receiver android:name=".FajrWidgetProvider" android:exported="true">
            <intent-filter>
                <action android:name="android.appwidget.action.APPWIDGET_UPDATE" />
            </intent-filter>
            <meta-data
                android:name="android.appwidget.provider"
                android:resource="@xml/fajr_widget_info" />
        </receiver>

        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
```

(`flutter_background_fetch`'s own receiver/service entries are merged automatically by its Gradle plugin per its documented setup — no manual manifest entry needed for it; Task 8's build verifies this.)

- [ ] **Step 2: Verify**

Run: `cd "D:/Programming/subhwarrior" && flutter build apk --debug`
Expected: `BUILD SUCCESSFUL`, and the merged manifest (`build/app/intermediates/merged_manifest/debug/AndroidManifest.xml` or similar path depending on AGP version) contains the `FajrWidgetProvider` receiver.

- [ ] **Step 3: Commit**

```bash
cd "D:/Programming/subhwarrior"
git add android/app/src/main/AndroidManifest.xml
git commit -m "feat(prayer-widget): register FajrWidgetProvider receiver"
```

---

### Task 7: Configure `flutter_background_fetch` in `main.dart`

**Files:**
- Modify: `lib/main.dart`

**Interfaces:**
- Consumes: `FajrWidgetService.refresh()` (Task 2).

- [ ] **Step 1: Add imports**

Add alongside the existing imports at the top of `lib/main.dart`:

```dart
import 'dart:async';

import 'package:flutter_background_fetch/flutter_background_fetch.dart';
import 'package:subh_warrior/features/prayer_times/data/fajr_widget_service.dart';
```

- [ ] **Step 2: Configure background fetch in `main()`**

Find:

```dart
  await ChallengeLocalDataSource.migrateLegacyIfNeeded(prefs, uid);

  runApp(SubhWarriorApp(
```

Replace with:

```dart
  await ChallengeLocalDataSource.migrateLegacyIfNeeded(prefs, uid);

  await _configureFajrWidgetBackgroundFetch();

  runApp(SubhWarriorApp(
```

- [ ] **Step 3: Add the configuration function and headless task**

Add after the `main()` function (before `class SubhWarriorApp`):

```dart
/// Keeps the Android Fajr home-screen widget refreshed even when the app
/// isn't running: a 30-minute periodic base task (Android's practical floor
/// for background work) covers the in-between countdown ticking, and
/// FajrWidgetService self-reschedules an exact one-shot task right at each
/// Fajr boundary so the progress bar/countdown flip lands on time instead
/// of waiting for the next periodic tick.
Future<void> _configureFajrWidgetBackgroundFetch() async {
  await BackgroundFetch.configure(
    BackgroundFetchConfig(
      minimumFetchInterval: 30,
      forceAlarmManager: true,
      stopOnTerminate: false,
      enableHeadless: true,
      startOnBoot: true,
      requiredNetworkType: NetworkType.ANY,
    ),
    (String taskId) async {
      await FajrWidgetService.refresh();
      BackgroundFetch.finish(taskId);
    },
    (String taskId) async {
      // Timeout — OS is reclaiming background time; finish immediately.
      BackgroundFetch.finish(taskId);
    },
  );
  BackgroundFetch.registerHeadlessTask(_fajrWidgetBackgroundFetchHeadlessTask);

  // Kick off the first refresh immediately rather than waiting up to 30 min.
  unawaited(FajrWidgetService.refresh());
}

/// Entry point for background-fetch events firing while the app process is
/// dead. Must be a top-level (or static) function annotated `vm:entry-point`
/// so the Android-side plugin can find it via reflection after a fresh Dart
/// VM spin-up.
@pragma('vm:entry-point')
void _fajrWidgetBackgroundFetchHeadlessTask(HeadlessTask task) async {
  if (task.timeout) {
    BackgroundFetch.finish(task.taskId);
    return;
  }
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FajrWidgetService.refresh();
  BackgroundFetch.finish(task.taskId);
}
```

- [ ] **Step 4: Verify**

Run: `cd "D:/Programming/subhwarrior" && dart format lib/main.dart && flutter analyze`
Expected: "No issues found!"

Run: `flutter build apk --debug`
Expected: `BUILD SUCCESSFUL`.

Run: `flutter test`
Expected: all existing tests pass (`main.dart`'s `main()` isn't under test).

- [ ] **Step 5: Commit**

```bash
cd "D:/Programming/subhwarrior"
git add lib/main.dart
git commit -m "feat(prayer-widget): configure flutter_background_fetch for widget refresh"
```

---

### Task 8: Manual device verification

**Files:** none (verification only, per the design doc's accepted testing gap for the native layer).

- [ ] **Step 1: Run the app on a device/emulator with Google Play services**

Run: `cd "D:/Programming/subhwarrior" && flutter run` (pick a device from `flutter devices` if more than one is attached). Complete onboarding (grant location) if not already done on this device/emulator.

- [ ] **Step 2: Add the widget to the home screen**

Long-press the home screen → Widgets → find "Subh Warrior" → drag the Fajr widget onto the home screen.

Expected: within a few seconds (the app is running, so `FajrWidgetService.refresh()` already fired once from `main()`), it shows the real Fajr time, countdown, and a progress bar matching the in-app card's fill level — not the placeholder.

- [ ] **Step 3: Verify the placeholder state**

On a second device/profile (or after `flutter clean` + uninstall + reinstall, add the widget to the home screen **before** ever opening the app): confirm it shows "Open Subh Warrior to see prayer times" instead of blank or crashing views.

- [ ] **Step 4: Verify tap-to-open**

Tap the widget. Expected: the app launches to `MainActivity` (the running dashboard, or auth/onboarding if that device hasn't completed setup).

- [ ] **Step 5: Verify background refresh without the app running**

Force-stop the app (Android Settings → Apps → Subh Warrior → Force stop). Wait past the next Fajr boundary time (or, faster: temporarily edit a local test build's `AppConstants`/mock the clock forward — or simply wait for the real next Fajr if testing overnight). Expected: the widget's progress bar resets to 0% and the countdown flips to counting toward the *following* Fajr, without having reopened the app — confirming the background task fired via `AlarmManager` while the process was dead.

- [ ] **Step 6: No commit for this task** — it's verification only. If any step fails, return to the relevant earlier task, fix, and re-run its own verify step before re-attempting this task.

## Self-review notes

- **Spec coverage:** platform scope (Android-only, Task 4-6), content (title/time/countdown/progress, Task 2 + 4 + 5), placeholder (Task 4 string + Task 5 null-check branch), refresh cadence (30-min periodic + exact Fajr-boundary reschedule, Task 7 + Task 2's `_scheduleNextBoundary`), tap behavior (Task 5's `HomeWidgetLaunchIntent`), localization staying Dart-side (Task 2's `_loadL10n`, only the one native placeholder string is the documented exception) — all present.
- **Type consistency:** `FajrWidgetService.refresh()` (no params, `Future<void>`) called identically from Task 3 (`prayer_times_controller.dart`) and Task 7 (`main.dart`'s configure callback + headless task) — same signature, same import path (`lib/features/prayer_times/data/fajr_widget_service.dart`). The Kotlin class name `FajrWidgetProvider` is used verbatim in three places (Task 2's `_androidProviderName` string, Task 5's class declaration, Task 6's manifest `android:name=".FajrWidgetProvider"`) — kept identical throughout.
- **No placeholders:** every step has literal, complete code. Steps that depend on an installed package version's exact API surface (Task 2 Step 2, Task 5 Step 2) give a concrete command to resolve the ambiguity rather than saying "adjust as needed" — this is the honest reality of a plan written before `flutter pub add` has pinned the exact resolved version, not a vague placeholder.
