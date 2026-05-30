# Subh Warrior — Engineering Improvement Plan & Execution Prompt

> **How to use this file.** This is both a senior-engineer audit and an executable prompt.
> Feed it to a coding agent (or follow it yourself) one phase at a time, top to bottom.
> Each task has a stable ID (`A1`, `B3`, …). Do not start a later phase until the
> current phase compiles, `flutter analyze` is clean, and tests pass.

---

## 0. Project Snapshot

- **App:** Subh Warrior — 28-day morning-routine challenge (Fajr on time + 60 min deep work, weekdays only, logged before 8 AM).
- **Stack:** Flutter 3.35, Dart 3, `provider` state, `shared_preferences` local store, `cloud_firestore` for leaderboard, Aladhan REST API for prayer times, `flutter_local_notifications`.
- **Size:** ~5,300 LOC in `lib/`. 3 providers, 7 screens, 2 widgets, 2 helpers.
- **Targets:** Android (primary), iOS, web scaffolding present.

### Top-level verdict
The app works but is a **single-layer Provider app**: business logic, persistence
(SharedPreferences *and* Firestore), model classes, and UI styling all live in the
same files. There is **no design system, no auth, no localization, no real tests**,
and several **correctness bugs**. The plan below moves it to a layered, testable,
themed, modern Flutter app without a risky big-bang rewrite.

---

## 1. Guiding Principles (apply to every change)

1. **Layer the code.** `presentation` (widgets) → `application` (state/controllers) →
   `domain` (entities + use-cases) → `data` (repositories + data sources). No widget
   talks to Firestore/SharedPreferences/HTTP directly.
2. **No magic literals.** Every `16`, `28`, `8`, `60`, color, and string becomes a
   named constant, theme token, or localized string.
3. **One source of truth.** State lives in the provider/controller, never duplicated
   into screen-local `setState` fields.
4. **Fail loud in dev, gracefully in prod.** Every async path has loading / error /
   empty states. No silent `catch (e) {}`.
5. **Material 3, tokenized.** Colors, spacing, radius, typography come from
   `Theme.of(context)` / `ThemeExtension`, never hardcoded.
6. **Test what you fix.** Every bug fix below ships with a regression test.

---

## PHASE A — Correctness Bugs (do first, highest ROI)

These are real defects found in the current code. Fix with a regression test each.

| ID     | File:Line                                                     | Bug                                                                                                                                                                                                                   | Fix                                                                                                                                                                |
|--------|---------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **A1** | `screens/splash_screen.dart:15-17`                            | `Timer`/`Future.delayed` navigates after 2s with no `mounted` check and no cancel on dispose → "Navigator in disposed context" crash / memory leak.                                                                   | Store the `Timer`, cancel in `dispose()`, guard `if (!mounted) return;` before `pushReplacementNamed`.                                                             |
| **A2** | `screens/onboarding_screen.dart:~500`, `screens/home.dart:40` | Coordinate "is set" check uses `lat == 0 && lon == 0`. Latitude/longitude `0.0` is a **valid** location (Gulf of Guinea / equator).                                                                                   | Track location-set state with a nullable `LatLng?` or an explicit `bool hasLocation`, not a zero sentinel.                                                         |
| **A3** | `screens/leader_board_screen.dart:16,194`                     | `_selectedPeriod` (week/month/all-time) chips change UI but **never filter the Firestore query** — the `orderBy` was removed and never replaced. Period filter is cosmetic.                                           | Either implement real time-window queries (store per-period aggregates) or remove the chips until backed. Don't ship dead controls.                                |
| **A4** | `helpers/notification_service.dart:123,159`                   | `scheduleFajrReminder` doesn't validate `minutesBefore > 0`; logging reminder uses same-day `isBefore(now)` → off-by-one (schedules tomorrow if called minutes before target).                                        | Clamp `minutesBefore`, compute next occurrence with explicit date rollover, add unit tests for both.                                                               |
| **A5** | `providers/challenge_provider.dart:100-108`                   | Logging window logic: `now.hour >= 8` rejects 08:00 but the rule is "before 8 AM"; also weekend rule and "already logged" all return bare `false` so UI can't tell *why* it failed.                                   | Return a typed result (enum/sealed `LogResult`) so UI shows the correct reason. Centralize the `< 8 AM` / weekday rule in one place.                               |
| **A6** | `providers/challenge_provider.dart:180-215`                   | `checkUsernameExists` + `updateUserSettings` is a **race / not unique**: two users can claim the same name; Firestore doc is keyed by `userName` so a rename orphans the old doc and can overwrite a stranger's data. | Move to Firebase Auth UID as the doc key (see **D1**). Treat username as a display field with a `usernames/{name}` uniqueness collection written in a transaction. |
| **A7** | `screens/progress_screen.dart:348`                            | Tapping a day with empty `workDescription` early-returns → tap feels broken (no sheet, no feedback).                                                                                                                  | Always open the sheet; render "No details logged" empty state.                                                                                                     |
| **A8** | `screens/settings_screen.dart:281-302`                        | Settings keep **dual state**: local `setState` fields *and* provider values; `Consumer` reassigns locals every rebuild → toggles fight each other.                                                                    | Drive switches directly from the provider; delete the shadow local fields.                                                                                         |
| **A9** | `test/widget_test.dart`                                       | Default counter test references `Icons.add` and a `'0'`/`'1'` counter that don't exist → test suite is red/meaningless.                                                                                               | Delete and replace with real tests (Phase F).                                                                                                                      |

---

## PHASE B — Architecture & Structure

Goal: feature-first layering, models out of provider files, repositories behind
interfaces. Do this incrementally — one feature folder at a time, app stays green.

**B1. Target folder structure**
```
lib/
├── main.dart
├── app/
│   ├── app.dart                 # MaterialApp, router, theme wiring
│   └── di.dart                  # provider/get_it wiring
├── core/
│   ├── constants/               # AppConstants (28, 16, 60min, 8AM, goals)
│   ├── theme/                   # AppColors, AppTheme, AppSpacing, AppTypography, ThemeExtensions
│   ├── l10n/                    # generated localizations
│   ├── result.dart              # Result<T>/sealed error types
│   └── utils/                   # date helpers (single _isSameDay, week calc)
├── features/
│   ├── challenge/
│   │   ├── data/   (challenge_repository, firestore_ds, prefs_ds)
│   │   ├── domain/ (day_log.dart, sleep_preparation.dart, work_type.dart, use cases)
│   │   └── presentation/ (challenge_controller, screens, widgets)
│   ├── prayer_times/
│   ├── onboarding/
│   ├── leaderboard/
│   └── settings/
└── shared/widgets/              # reusable cards, buttons, states
```

**B2.** Extract all model classes (`DayLog`, `SleepPreparation`, `WorkType`,
`PrayerTimes`) out of provider files into `domain/`. Generate `toJson/fromJson`
with `json_serializable` (already a dependency but **unused** — manual serialization
today). Add `freezed` for immutability + `copyWith` + equality.

**B3.** Introduce a **repository layer**:
- `ChallengeRepository` interface → `ChallengeRepositoryImpl(localDs, remoteDs)`.
- `PrayerTimesRepository` wrapping the Aladhan HTTP client.
- Providers become thin controllers that call repositories; they hold no
  `http`, `Firestore`, or `SharedPreferences` instances directly.

**B4.** Centralize date/week math. Today `_isSameDay`, week-number, and date
normalization are duplicated across `challenge_provider`, `progress_screen`,
`home`. One `DateUtils` in `core/utils`.

**B5.** Split god-widgets. `home.dart` `_buildDashboard` (7 sub-builders),
`logday_screen._handleSubmit` (91 lines), and the progress modal sheet (65 lines)
each become their own widgets/methods with single responsibilities.

**B6. (Decision) State management.** Two acceptable paths — pick one and be consistent:
- **Pragmatic:** keep `provider` but enforce the controller/repository split above.
- **Modern (recommended):** migrate to **Riverpod 2** (`flutter_riverpod` +
  `riverpod_generator`) for compile-safe DI, `AsyncValue` loading/error/data states,
  and easy testing. Do it feature-by-feature behind the new structure.
- Add **`go_router`** for declarative routing + deep links (proguard already
  *pretends* GoRouter exists — see **G3**). Replace the manual `routes:` map and
  `Navigator.pushReplacementNamed`.

---

## PHASE C — Design System & UI Modernization

Current UI hardcodes `Colors.green/orange/blue/red`, `Colors.white`,
`Colors.grey[300]`, raw `SizedBox(height: 16/20/24/32)`, and mixes the deprecated
`withOpacity` with `withValues`. Theme is a single `isDarkMode` bool that ignores
the system setting.

**C1. Color & theme tokens.** Build `AppColors` + a Material 3 `ColorScheme`
seeded from the Islamic green (`0xFF1B5E20`), with semantic roles
(`success`, `warning`, `onTrack`, `streakGradientStart/End`) exposed via a
`ThemeExtension<AppColorsX>`. Replace **every** hardcoded color reference.

**C2. Spacing & radius scale.** `AppSpacing(xs:4, sm:8, md:16, lg:24, xl:32)` and
`AppRadius`. Replace ad-hoc `SizedBox`/`EdgeInsets`/`BorderRadius.circular(n)`.

**C3. Typography.** Define a `TextTheme` (consider `google_fonts`); stop scattering
`TextStyle(fontSize: 24, fontWeight: bold)`. Support text scaling (accessibility).

**C4. Theme mode.** `ThemeProvider` should expose `ThemeMode.system/light/dark`
(3-way), default to `system`, persist the choice. Wire `theme` + `darkTheme` +
`themeMode` on `MaterialApp`.

**C5. Standardize APIs.** Replace all `withOpacity` with `withValues(alpha:)`
(Flutter 3.27+) project-wide; remove the mix.

**C6. State widgets.** Reusable `LoadingView`, `ErrorView(onRetry)`, `EmptyView`
in `shared/widgets`. Use them in prayer card, leaderboard, progress, onboarding
location fetch — all currently miss one or more states.

**C7. Polish.**
- Splash: real logo + subtle animation (or use `flutter_native_splash`), not bare text.
- Onboarding: progress dots, page transitions, deduplicate the two identical
  `TextField`s into one styled component.
- Home: skeleton loaders for prayer times; quote rotation via a localized list.
- Add haptics + micro-animations (`AnimatedSwitcher`, implicit animations) for
  streak/log success.

---

## PHASE D — Security & Data Integrity

**D1. Authentication.** Add **Firebase Auth** (Anonymous at minimum, ideally
Google/Apple sign-in). Key all Firestore docs by `uid`, not username. This closes
**A6** (anyone can overwrite anyone's challenge by guessing a username).

**D2. Firestore security rules.** There are none committed. Add `firestore.rules`:
users may write only their own `uid` doc; leaderboard reads are public but
write-validated (no client-set rank/score tampering beyond own logs). Add to
`firebase.json` and CI.

**D3. HTTPS.** `prayer_time_provider.dart` calls `http://api.aladhan.com`.
Switch to `https://`. Cleartext is a privacy/integrity risk and may be blocked by
default network-security config.

**D4. Username uniqueness transaction.** Implement reservation via a
`usernames/{lowercased}` doc inside a Firestore transaction; trim + lowercase for
comparison (today comparison is case-sensitive, untrimmed — `onboarding:36`,
`leaderboard:418`).

**D5. Input validation.** Validate/limit username (length, charset, profanity?),
work description length, reflection length before persisting/uploading.

**D6. Secrets/config.** `google-services.json` is committed (acceptable for
client config but) — confirm no API keys with broad scope; restrict the Firebase
API key in the Google Cloud console to the app's SHA-256 + package.

---

## PHASE E — Localization & Accessibility

**E1. i18n.** This is an Islamic app likely serving Arabic/Bengali/Urdu/English
audiences, yet **every string is hardcoded English**. Add `flutter_localizations`
+ `intl` ARB files, extract all user-facing text. Already depend on `intl`.

**E2. RTL.** Ensure layouts work in RTL (use `EdgeInsetsDirectional`,
`Directionality`-aware widgets). Test with Arabic.

**E3. Accessibility.** Add `Semantics`/labels to icon buttons, checkboxes, switches,
form fields, and the success dialog (currently emoji-only). Verify contrast ratios
of the new color tokens. Respect `MediaQuery.textScaler`.

---

## PHASE F — Testing

Current state: only the **broken default counter test** exists; CI never runs tests.

**F1. Unit tests** for pure logic (highest value):
- Streak calculation (`_updateStreak`), week-number, qualifying-day rules.
- `LogResult` reasons (before/after 8 AM, weekend, already-logged).
- Notification scheduling time math (**A4**).
- `PrayerTimes.fromJson` cleaning (`"05:30 (+06)"` → `05:30`).
**F2. Repository tests** with fake data sources (mocktail).
**F3. Widget tests** for each screen's loading/error/empty/data states.
**F4. Golden tests** for the new design-system components (light + dark + RTL).
**F5. Integration test** of the core flow (use the `flutter-add-integration-test`
skill): onboarding → log day → see streak.
Target: meaningful coverage on `domain`/`data`; smoke coverage on screens.

---

## PHASE G — CI/CD, Native Config, Tooling

**G1. CI pipeline** (`.github/workflows/ci.yml`) — currently only builds APK. Add,
in order, failing fast:
```yaml
- run: flutter pub get
- run: dart format --set-exit-if-changed .
- run: flutter analyze
- run: flutter test --coverage
- run: flutter build apk --release   # existing
```
Fix the comment/version mismatch (says "Java 17", installs 21). Cache pub + Gradle.

**G2. Release signing.** `android/app/build.gradle.kts:48` signs **release with the
debug keystore**. Create a real keystore, load credentials from
`key.properties`/CI secrets, never commit them.

**G3. ProGuard cleanup.** `proguard-rules.pro` keeps classes for GoRouter,
`showcaseview`, gson, and `com.subhwarrior.app.{models,data,repositories,services}`
packages that **don't exist**. Either adopt those libs (G/B) or delete the dead
keep-rules so R8 can actually shrink.

**G4. AndroidManifest.**
- Add `<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>`
  (Android 13+) — the app requests it via `permission_handler` but never declares it.
- Add `SCHEDULE_EXACT_ALARM` / `USE_EXACT_ALARM` for scheduled Fajr reminders.
- Fix `android:label="subhwarrior"` → `"Subh Warrior"`.

**G5. Lints.** Adopt a stricter ruleset (`flutter_lints` is minimal; consider
`very_good_analysis`). Turn on `prefer_const`, `require_trailing_commas`, etc.
Upgrade `flutter_lints` (currently `^3.0.1`, behind the SDK).

**G6. README.** The "Project Structure" section lists files that **don't exist**
(`home_screen.dart`, `log_day_screen.dart`, `sleep_preparation_screen.dart`,
`progress_card.dart`, `utils/`). Rewrite to match reality (and the new Phase-B layout).

**G7. App version.** `settings_screen.dart:557` hardcodes `"1.0.0"`. Read from
`package_info_plus` instead.

---

## Suggested Sequencing

1. **Phase A** (bugs) + delete broken test — ship fast, low risk.
2. **Phase G1/G4/G2** (CI gate + manifest + signing) — make the pipeline trustworthy.
3. **Phase C1–C5** (design tokens) — unblock all UI work.
4. **Phase B** (architecture) feature-by-feature, starting with `challenge`.
5. **Phase D** (auth + rules) — needs backend coordination.
6. **Phase E, F** woven in as each feature is refactored.

## Definition of Done (per phase)
`dart format` clean · `flutter analyze` zero issues · `flutter test` green ·
no hardcoded colors/strings/magic numbers introduced · loading+error+empty states
present on every async surface · changed logic covered by a test.

---

### Quick-win checklist (first PR)
- [ ] A1 splash leak/crash
- [ ] A2 equator coordinate bug
- [ ] A9 delete counter test
- [ ] D3 http → https
- [ ] G4 POST_NOTIFICATIONS + app label
- [ ] G1 add analyze + test to CI