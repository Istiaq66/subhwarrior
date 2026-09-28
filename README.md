# Subh Warrior

A Flutter app for a **28-day morning-routine challenge**: pray Fajr on time and
complete 60+ minutes of deep work, on weekdays, logged before 8 AM. Tracks
streaks, visualizes progress, ranks warriors on a leaderboard, and sends Fajr /
logging reminders.

---

## Features

- **Fajr prayer tracking** with prayer times from the Aladhan API (calculation
  method + Hanafi/Standard juristic method configurable).
- **Daily logging** — Fajr status, work duration, work type, reflection. A day
  qualifies when Fajr was on time, work ≥ 60 min, and the work type is
  productive. Logging window closes at 8 AM; weekends don't count.
- **Streaks & progress** — current streak, qualifying days toward the 16-day
  goal, weekly breakdown, calendar view, and charts.
- **Leaderboard** — global and location-based rankings via Cloud Firestore.
- **Notifications** — Fajr reminder (configurable minutes before) and a 7:30 AM
  logging reminder, via `flutter_local_notifications`.
- **Theming** — Material 3, light/dark.

---

## Tech Stack

- **Flutter** 3.35 / Dart 3
- **State management:** `provider`
- **Local storage:** `shared_preferences`
- **Backend:** Firebase Core + Cloud Firestore (leaderboard)
- **Prayer times:** Aladhan REST API (`http`)
- **Location:** `geolocator`, `geocoding`
- **Notifications:** `flutter_local_notifications`, `flutter_timezone`
- **UI:** `fl_chart`, `percent_indicator`, `table_calendar`, `font_awesome_flutter`

---

## Project Structure

```
subh_warrior/
├── lib/
│   ├── main.dart                     # App entry, MultiProvider, theme, routes
│   ├── firebase_options.dart
│   ├── providers/
│   │   ├── challenge_provider.dart   # Challenge state, day logs, persistence
│   │   ├── prayer_time_provider.dart # Aladhan API + prayer-time logic
│   │   └── theme_provider.dart
│   ├── screens/
│   │   ├── splash_screen.dart
│   │   ├── onboarding_screen.dart
│   │   ├── home.dart                 # Dashboard + bottom-nav host
│   │   ├── logday_screen.dart
│   │   ├── progress_screen.dart
│   │   ├── leader_board_screen.dart
│   │   └── settings_screen.dart
│   ├── widgets/
│   │   ├── prayer_time_card.dart
│   │   └── streak_card.dart
│   └── helpers/
│       ├── notification_service.dart
│       └── notification_permission.dart
├── test/
├── android/ · ios/ · web/
├── IMPROVEMENT_PLAN.md               # Engineering audit + phased roadmap
├── pubspec.yaml
└── README.md
```

> A layered, feature-first refactor of this structure is planned — see
> [`IMPROVEMENT_PLAN.md`](IMPROVEMENT_PLAN.md) (Phase B).

---

## Getting Started

```bash
flutter pub get
flutter run
```

Firebase is already configured via `lib/firebase_options.dart` and
`android/app/google-services.json`.

### Release builds (signing)

Release signing reads `android/key.properties` (gitignored). Copy the template
and fill in your keystore details:

```bash
cp android/key.properties.example android/key.properties
```

If `key.properties` is absent the release build falls back to debug signing so
local builds still work. In CI the file is generated from repository secrets
(`ANDROID_KEYSTORE_BASE64`, `ANDROID_STORE_PASSWORD`, `ANDROID_KEY_PASSWORD`,
`ANDROID_KEY_ALIAS`).

---

## Quality Gate

CI (`.github/workflows/ci.yml`) runs on every push/PR:

```bash
dart format --set-exit-if-changed .
flutter analyze --no-fatal-infos
flutter test --coverage
```

A signed release APK is built and published on pushes to `master`.

---

## Startup Performance

Boot is instrumented by `StartupTrace` (`lib/core/perf/startup_trace.dart`). Every
launch records milestones — `prefs_loaded`, `first_frame`, `firebase_ready`,
`auth_ready`, `prayer_times_settled`, `boot_complete` — as milliseconds since
`main`.

Where the numbers show up:

- **Console** (debug and profile builds): `[startup] first_frame: 118ms` lines.
- **DevTools / `--trace-startup`**: one `app_startup` timeline slice with each
  milestone as an instant event.
- **Analytics**: a single `app_startup` event per launch carrying every
  milestone plus `total_ms`, so regressions surface from real devices.
- **Firebase Performance**: the same milestones as metrics on an `app_startup`
  custom trace, alongside the SDK's automatic app-start and screen-rendering
  traces. Collection is enabled explicitly at boot, debug builds included.
  The `firebase-perf` Gradle
  plugin is deliberately not applied — it instruments Android HTTP clients by
  bytecode rewriting, which never sees Dart's network calls.

To measure a cold start on a device:

```bash
flutter run --profile --trace-startup -d <device>
# writes build/start_up_info.json
```

`timeToFirstFrameMicros` is when the splash appears; `timeToFirstFrameRasterizedMicros`
is when it is actually on screen. A large gap between the two means startup work is
competing with the first frame — keep plugin registration and other platform-channel
work behind `SchedulerBinding.instance.endOfFrame`.

---

## Version

- **Current:** 1.0.0+1 (shown in-app from `package_info_plus`, not hardcoded)
- **Flutter SDK:** >= 3.0.0