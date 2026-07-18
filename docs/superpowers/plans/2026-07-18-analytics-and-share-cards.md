# Analytics + Streak Share Cards Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Instrument the app with the launch analytics events and add shareable streak cards (image → WhatsApp/Facebook share sheet), per `docs/superpowers/specs/2026-07-18-growth-plan-design.md` weeks 1–4.

**Architecture:** An `AnalyticsService` abstraction (Firebase impl + in-memory fake) injected via `provider`, with events fired from `ChallengeProvider` (domain events) and screens (UI events). Share cards are a visible widget wrapped in `RepaintBoundary`, rendered inside a bottom sheet, captured to PNG and handed to `share_plus`.

**Tech Stack:** Flutter 3.35 / Dart 3, `provider`, `firebase_analytics`, `share_plus` (existing), `path_provider`, gen-l10n ARB localization (en/ar/bn/ur), `flutter_test` + `mocktail`.

## Global Constraints

- `flutter analyze` zero issues; `dart format` clean; `flutter test` green after every task (project lints are strict: `flutter_lints ^6.0.0`).
- Every user-facing string goes through ARB localization in all 4 files (`app_en.arb`, `app_ar.arb`, `app_bn.arb`, `app_ur.arb`); after ARB edits run `flutter gen-l10n`. Template metadata (`@key`) only in `app_en.arb`. Int placeholders use `"format": "decimalPattern"`.
- Every number shown in UI uses localized digits: values through ARB placeholders get it automatically; values interpolated in Dart use `context.localizeNumber(...)` from `lib/core/l10n/l10n_utils.dart`.
- No hardcoded colors/spacing: use `Theme.of(context).colorScheme`, `context.appColors` (`lib/core/theme/app_colors.dart`), `AppSpacing`/`AppRadius` (`lib/core/theme/app_spacing.dart`).
- Layouts must be RTL-safe: `AlignmentDirectional`, no `EdgeInsets.only(left:/right:)`.
- Analytics event names are snake_case and MUST match the spec exactly: `challenge_started`, `day_logged`, `streak_milestone`, `share_card_sent`, `invite_sent`, `invite_accepted`, `friend_added`, `notification_opened`. (Only the first four plus `notification_opened` and `share_card_sent` are wired in this plan; the rest belong to later plans but the constants file reserves them.)
- Commit messages: Conventional Commits, ending with `Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>`.

---

### Task 1: AnalyticsService abstraction + fake

**Files:**
- Create: `lib/core/analytics/analytics_service.dart`
- Create: `lib/core/analytics/firebase_analytics_service.dart`
- Test: `test/core/analytics_service_test.dart`

**Interfaces:**
- Consumes: nothing (leaf module).
- Produces:
  - `abstract class AnalyticsService { Future<void> logEvent(String name, [Map<String, Object>? parameters]); }`
  - `class AnalyticsEvents` — static const String event names (see code).
  - `class FakeAnalyticsService implements AnalyticsService` — exposes `List<LoggedEvent> events` (record type `({String name, Map<String, Object>? parameters})`).
  - `class FirebaseAnalyticsService implements AnalyticsService`.
  - `AnalyticsService? AnalyticsService.maybeInstance` — static, settable once at startup, for context-free call sites (notification tap callback).

- [ ] **Step 1: Add dependencies**

```powershell
flutter pub add firebase_analytics path_provider
```

Expected: `Changed N dependencies!` (firebase_core already present, so no majors move).

- [ ] **Step 2: Write the failing test**

Create `test/core/analytics_service_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:subh_warrior/core/analytics/analytics_service.dart';

void main() {
  tearDown(() => AnalyticsService.maybeInstance = null);

  group('FakeAnalyticsService', () {
    test('records events with parameters in order', () async {
      final fake = FakeAnalyticsService();

      await fake.logEvent(AnalyticsEvents.challengeStarted);
      await fake.logEvent(AnalyticsEvents.dayLogged, {'qualifying': 'true'});

      expect(fake.events, hasLength(2));
      expect(fake.events[0].name, 'challenge_started');
      expect(fake.events[0].parameters, isNull);
      expect(fake.events[1].name, 'day_logged');
      expect(fake.events[1].parameters, {'qualifying': 'true'});
    });
  });

  group('AnalyticsEvents', () {
    test('names match the growth-plan spec exactly', () {
      expect(AnalyticsEvents.challengeStarted, 'challenge_started');
      expect(AnalyticsEvents.dayLogged, 'day_logged');
      expect(AnalyticsEvents.streakMilestone, 'streak_milestone');
      expect(AnalyticsEvents.shareCardSent, 'share_card_sent');
      expect(AnalyticsEvents.inviteSent, 'invite_sent');
      expect(AnalyticsEvents.inviteAccepted, 'invite_accepted');
      expect(AnalyticsEvents.friendAdded, 'friend_added');
      expect(AnalyticsEvents.notificationOpened, 'notification_opened');
    });
  });

  group('AnalyticsService.maybeInstance', () {
    test('is null until set, then returns the set instance', () {
      expect(AnalyticsService.maybeInstance, isNull);
      final fake = FakeAnalyticsService();
      AnalyticsService.maybeInstance = fake;
      expect(AnalyticsService.maybeInstance, same(fake));
    });
  });
}
```

- [ ] **Step 3: Run test to verify it fails**

Run: `flutter test test/core/analytics_service_test.dart`
Expected: FAIL — `Error: Couldn't resolve the package 'subh_warrior/core/analytics/analytics_service.dart'` (file missing).

- [ ] **Step 4: Write minimal implementation**

Create `lib/core/analytics/analytics_service.dart`:

```dart
/// One logged analytics event (used by [FakeAnalyticsService] assertions).
typedef LoggedEvent = ({String name, Map<String, Object>? parameters});

/// Event-name constants from the growth-plan spec. Names are wire format —
/// never rename without a data-migration decision.
abstract final class AnalyticsEvents {
  AnalyticsEvents._();

  static const challengeStarted = 'challenge_started';
  static const dayLogged = 'day_logged';
  static const streakMilestone = 'streak_milestone';
  static const shareCardSent = 'share_card_sent';
  static const inviteSent = 'invite_sent';
  static const inviteAccepted = 'invite_accepted';
  static const friendAdded = 'friend_added';
  static const notificationOpened = 'notification_opened';
}

/// Analytics abstraction so widgets/controllers never import Firebase
/// directly and tests can assert on events via [FakeAnalyticsService].
abstract class AnalyticsService {
  Future<void> logEvent(String name, [Map<String, Object>? parameters]);

  /// Set once at startup; lets context-free call sites (e.g. the
  /// notification-tap callback) log events. Null in tests unless set.
  static AnalyticsService? maybeInstance;
}

/// In-memory implementation for tests.
class FakeAnalyticsService implements AnalyticsService {
  final List<LoggedEvent> events = [];

  @override
  Future<void> logEvent(String name, [Map<String, Object>? parameters]) async {
    events.add((name: name, parameters: parameters));
  }
}
```

Create `lib/core/analytics/firebase_analytics_service.dart`:

```dart
import 'package:firebase_analytics/firebase_analytics.dart';

import 'analytics_service.dart';

/// Production implementation backed by Firebase Analytics.
class FirebaseAnalyticsService implements AnalyticsService {
  FirebaseAnalyticsService([FirebaseAnalytics? analytics])
      : _analytics = analytics ?? FirebaseAnalytics.instance;

  final FirebaseAnalytics _analytics;

  @override
  Future<void> logEvent(String name, [Map<String, Object>? parameters]) =>
      _analytics.logEvent(name: name, parameters: parameters);
}
```

- [ ] **Step 5: Run test to verify it passes**

Run: `flutter test test/core/analytics_service_test.dart`
Expected: PASS (3 tests).

- [ ] **Step 6: Gate + commit**

```powershell
dart format .; flutter analyze --no-pub; flutter test
git add pubspec.yaml pubspec.lock lib/core/analytics test/core/analytics_service_test.dart
git commit -m @'
feat(analytics): add AnalyticsService abstraction with Firebase impl and fake

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>
'@
```

---

### Task 2: Domain events from ChallengeProvider (challenge_started, day_logged, streak_milestone)

**Files:**
- Modify: `lib/features/challenge/presentation/challenge_controller.dart` (constructor ~line 21-30, `startChallenge()` ~line 105, `logDay()` ~line 125)
- Modify: `lib/main.dart` (ChallengeProvider construction inside the auth `StreamBuilder`, ~line 72-75; register `Provider<AnalyticsService>` in the `MultiProvider` list)
- Test: `test/features/challenge/challenge_analytics_test.dart`

**Interfaces:**
- Consumes: `AnalyticsService`, `AnalyticsEvents`, `FakeAnalyticsService` from Task 1; existing `ChallengeProvider(this._repository)` constructor and `ChallengeProvider.fromPrefs(prefs, uid: uid)` factory; existing `Future<LogResult> logDay({...})` and `Future<void> startChallenge()`.
- Produces: `ChallengeProvider` constructor gains optional named param `AnalyticsService? analytics` (both the main constructor and `fromPrefs` factory pass it through). Behavior: `startChallenge()` logs `challenge_started`; successful `logDay()` logs `day_logged` with `{'qualifying': 'true'|'false'}`; when `currentStreak` lands exactly on 7, 14, or 21 after a successful log, also logs `streak_milestone` with `{'streak': <int>}`. Failed `logDay` (any non-success `LogResult`) logs nothing.

- [ ] **Step 1: Write the failing test**

Create `test/features/challenge/challenge_analytics_test.dart`. Reuse the existing fake-repository pattern from `test/features/challenge/challenge_controller_test.dart` (open it and copy its fake `ChallengeRepository` + provider construction verbatim — it already fakes `load()`/`save()`; the test below assumes a helper `makeProvider({FakeAnalyticsService? analytics})` built from that pattern with an active challenge started on a weekday). Test bodies:

```dart
test('startChallenge logs challenge_started', () async {
  final analytics = FakeAnalyticsService();
  final provider = makeProvider(analytics: analytics);

  await provider.startChallenge();

  expect(analytics.events.map((e) => e.name), contains('challenge_started'));
});

test('successful logDay logs day_logged with qualifying flag', () async {
  final analytics = FakeAnalyticsService();
  final provider = makeProvider(analytics: analytics);
  await provider.startChallenge();

  final result = await provider.logDay(
    prayedFajrOnTime: true,
    prayedAtMasjid: false,
    minutesWorked: 90,
    workDescription: 'Deep work session',
    workType: WorkType.deepWork,
  );

  expect(result, LogResult.success);
  final event =
      analytics.events.singleWhere((e) => e.name == 'day_logged');
  expect(event.parameters, {'qualifying': 'true'});
});

test('no analytics events on rejected logDay', () async {
  final analytics = FakeAnalyticsService();
  final provider = makeProvider(analytics: analytics);
  // No startChallenge -> logDay must fail.

  await provider.logDay(
    prayedFajrOnTime: true,
    prayedAtMasjid: false,
    minutesWorked: 90,
    workDescription: 'Deep work session',
    workType: WorkType.deepWork,
  );

  expect(analytics.events.where((e) => e.name == 'day_logged'), isEmpty);
});
```

Note: a `streak_milestone` unit test requires 7 qualifying weekday logs across dates, which the current `logDay` (always "today") can't produce; assert milestone logic instead via the private helper being extracted as a pure function — see Step 4's `streakMilestoneFor`. Add:

```dart
test('streakMilestoneFor fires only on exact 7/14/21', () {
  expect(ChallengeProvider.streakMilestoneFor(6), isNull);
  expect(ChallengeProvider.streakMilestoneFor(7), 7);
  expect(ChallengeProvider.streakMilestoneFor(8), isNull);
  expect(ChallengeProvider.streakMilestoneFor(14), 14);
  expect(ChallengeProvider.streakMilestoneFor(21), 21);
  expect(ChallengeProvider.streakMilestoneFor(28), isNull);
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/challenge/challenge_analytics_test.dart`
Expected: FAIL — `No named parameter with the name 'analytics'` / `streakMilestoneFor` undefined.

- [ ] **Step 3: Implement**

In `challenge_controller.dart`:

```dart
// imports:
import '../../../core/analytics/analytics_service.dart';

// fields (next to _repository):
final AnalyticsService? _analytics;

// constructor becomes:
ChallengeProvider(this._repository, {AnalyticsService? analytics})
    : _analytics = analytics {
  // ...existing body unchanged
}

// fromPrefs factory: add `AnalyticsService? analytics` named param and
// pass `analytics: analytics` through.

/// 7/14/21 milestone hit, or null. Pure so it's unit-testable.
static int? streakMilestoneFor(int streak) =>
    const [7, 14, 21].contains(streak) ? streak : null;
```

In `startChallenge()`, after the existing state mutation + save, before `notifyListeners()`:

```dart
_analytics?.logEvent(AnalyticsEvents.challengeStarted);
```

In `logDay(...)`, at the point where the method returns `LogResult.success` (after `_updateStreak()` and save):

```dart
_analytics?.logEvent(AnalyticsEvents.dayLogged,
    {'qualifying': '$isQualifying'});
final milestone = streakMilestoneFor(_data.currentStreak);
if (milestone != null) {
  _analytics?.logEvent(
      AnalyticsEvents.streakMilestone, {'streak': milestone});
}
```

(`isQualifying` is the local qualifying flag already computed in `logDay` — match the actual local variable name when editing.)

In `main.dart`:

```dart
// import:
import 'package:subh_warrior/core/analytics/analytics_service.dart';
import 'package:subh_warrior/core/analytics/firebase_analytics_service.dart';

// in main(), after Firebase.initializeApp:
final analytics = FirebaseAnalyticsService();
AnalyticsService.maybeInstance = analytics;
// pass into SubhWarriorApp (new constructor field `analytics`).

// in MultiProvider providers list:
Provider<AnalyticsService>.value(value: analytics),

// ChallengeProvider construction becomes:
create: (_) => ChallengeProvider.fromPrefs(prefs, uid: uid, analytics: analytics),
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/features/challenge`
Expected: PASS (existing controller tests + 4 new).

- [ ] **Step 5: Gate + commit**

```powershell
dart format .; flutter analyze --no-pub; flutter test
git add lib/features/challenge/presentation/challenge_controller.dart lib/main.dart test/features/challenge/challenge_analytics_test.dart
git commit -m @'
feat(analytics): log challenge_started, day_logged, streak_milestone

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>
'@
```

---

### Task 3: notification_opened event

**Files:**
- Modify: `lib/helpers/notification_service.dart` (`initBackground()`, ~line 16-34)
- Test: `test/helpers/notification_analytics_test.dart`

**Interfaces:**
- Consumes: `AnalyticsService.maybeInstance`, `AnalyticsEvents.notificationOpened` (Task 1).
- Produces: `static void handleNotificationTap(String? payload)` on `NotificationService` — public + pure-ish so it's testable; wired as the plugin's `onDidReceiveNotificationResponse`.

- [ ] **Step 1: Write the failing test**

Create `test/helpers/notification_analytics_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:subh_warrior/core/analytics/analytics_service.dart';
import 'package:subh_warrior/helpers/notification_service.dart';

void main() {
  tearDown(() => AnalyticsService.maybeInstance = null);

  test('handleNotificationTap logs notification_opened with payload', () {
    final fake = FakeAnalyticsService();
    AnalyticsService.maybeInstance = fake;

    NotificationService.handleNotificationTap('fajr_reminder');

    final event = fake.events.single;
    expect(event.name, 'notification_opened');
    expect(event.parameters, {'payload': 'fajr_reminder'});
  });

  test('handleNotificationTap is safe with no analytics and null payload',
      () {
    expect(() => NotificationService.handleNotificationTap(null),
        returnsNormally);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/helpers/notification_analytics_test.dart`
Expected: FAIL — `handleNotificationTap` undefined.

- [ ] **Step 3: Implement**

In `notification_service.dart`:

```dart
// import:
import 'package:subh_warrior/core/analytics/analytics_service.dart';

// new static method on NotificationService:
/// Logs the notification_opened analytics event. Public for tests; wired
/// as the local-notifications tap callback in [initBackground].
static void handleNotificationTap(String? payload) {
  AnalyticsService.maybeInstance?.logEvent(
    AnalyticsEvents.notificationOpened,
    {'payload': payload ?? 'unknown'},
  );
}
```

In `initBackground()`, change the initialize call:

```dart
await flutterLocalNotificationsPlugin.initialize(
  initializationSettings,
  onDidReceiveNotificationResponse: (response) =>
      handleNotificationTap(response.payload),
);
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/helpers`
Expected: PASS (existing reminder-math tests + 2 new).

- [ ] **Step 5: Gate + commit**

```powershell
dart format .; flutter analyze --no-pub; flutter test
git add lib/helpers/notification_service.dart test/helpers/notification_analytics_test.dart
git commit -m @'
feat(analytics): log notification_opened on notification tap

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>
'@
```

---

### Task 4: Share-card localization strings

**Files:**
- Modify: `lib/core/l10n/app_en.arb`, `app_ar.arb`, `app_bn.arb`, `app_ur.arb`

**Interfaces:**
- Produces l10n getters used by Tasks 5–6: `shareCardTitle`, `shareCardStreakLabel`, `shareCardQualifyingLabel`, `shareCardWeekLabel(int week)`, `shareCardFooter`, `shareCardButton`, `shareCardSheetTitle`.

- [ ] **Step 1: Add keys to `app_en.arb`** (before `"a11yOpenSettings"`; metadata blocks only here):

```json
"shareCardTitle": "Subh Warrior",
"shareCardStreakLabel": "day streak",
"shareCardQualifyingLabel": "qualifying days",
"shareCardWeekLabel": "Week {week} of 4",
"@shareCardWeekLabel": {
  "description": "Challenge week shown on the shareable streak card",
  "placeholders": {
    "week": { "type": "int", "format": "decimalPattern" }
  }
},
"shareCardFooter": "Join me on the 28-day Fajr challenge!",
"shareCardButton": "Share",
"shareCardSheetTitle": "Share your progress",
```

- [ ] **Step 2: Add translations**

`app_ar.arb`:

```json
"shareCardTitle": "محارب الصبح",
"shareCardStreakLabel": "يومًا متتاليًا",
"shareCardQualifyingLabel": "أيام مؤهّلة",
"shareCardWeekLabel": "الأسبوع {week} من 4",
"shareCardFooter": "انضم إليّ في تحدي الفجر لمدة 28 يومًا!",
"shareCardButton": "مشاركة",
"shareCardSheetTitle": "شارك تقدمك",
```

`app_bn.arb`:

```json
"shareCardTitle": "সুবহ ওয়ারিয়র",
"shareCardStreakLabel": "দিনের স্ট্রিক",
"shareCardQualifyingLabel": "যোগ্য দিন",
"shareCardWeekLabel": "৪ সপ্তাহের মধ্যে {week}তম সপ্তাহ",
"shareCardFooter": "২৮ দিনের ফজর চ্যালেঞ্জে আমার সাথে যোগ দিন!",
"shareCardButton": "শেয়ার করুন",
"shareCardSheetTitle": "আপনার অগ্রগতি শেয়ার করুন",
```

`app_ur.arb`:

```json
"shareCardTitle": "صبح واریئر",
"shareCardStreakLabel": "دن کی اسٹریک",
"shareCardQualifyingLabel": "اہل دن",
"shareCardWeekLabel": "4 میں سے ہفتہ {week}",
"shareCardFooter": "28 دن کے فجر چیلنج میں میرے ساتھ شامل ہوں!",
"shareCardButton": "شیئر کریں",
"shareCardSheetTitle": "اپنی پیشرفت شیئر کریں",
```

- [ ] **Step 3: Regenerate + gate**

Run: `flutter gen-l10n` then `flutter analyze --no-pub`
Expected: no issues (getters unused until Task 5 — analyzer doesn't flag unused public l10n getters).

- [ ] **Step 4: Commit**

```powershell
git add lib/core/l10n
git commit -m @'
feat(l10n): add share-card strings in en/ar/bn/ur

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>
'@
```

---

### Task 5: StreakShareCard widget + share bottom sheet

**Files:**
- Create: `lib/features/share/presentation/streak_share_card.dart`
- Create: `lib/features/share/presentation/share_sheet.dart`
- Create: `lib/features/share/data/share_card_service.dart`
- Test: `test/features/share/streak_share_card_test.dart`

**Interfaces:**
- Consumes: l10n getters from Task 4; `context.localizeNumber` from `lib/core/l10n/l10n_utils.dart`; `context.appColors.streakGradient`; `AnalyticsService`/`AnalyticsEvents` from Task 1.
- Produces:
  - `class StreakShareCard extends StatelessWidget { const StreakShareCard({required this.currentStreak, required this.totalQualifyingDays, required this.currentWeek}); }` — pure visual, fixed 320×400 logical size, safe to wrap in `RepaintBoundary`.
  - `class ShareCardService { Future<void> shareBoundary(GlobalKey boundaryKey, {required String text}) }` — captures the `RepaintBoundary` under `boundaryKey` at `pixelRatio: 3.0`, writes `streak_card.png` to the temp dir (`path_provider`), calls `Share.shareXFiles([XFile(path)], text: text)`.
  - `Future<void> showShareSheet(BuildContext context, {required int currentStreak, required int totalQualifyingDays, required int currentWeek})` (in `share_sheet.dart`) — modal bottom sheet with card preview + share button; logs `share_card_sent` with `{'streak': currentStreak}` after a successful share.

- [ ] **Step 1: Write the failing widget test**

Create `test/features/share/streak_share_card_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subh_warrior/core/l10n/app_localizations.dart';
import 'package:subh_warrior/core/theme/app_theme.dart';
import 'package:subh_warrior/features/share/presentation/streak_share_card.dart';

Widget _wrap(Widget child, {Locale locale = const Locale('en')}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: AppTheme.light(),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  testWidgets('renders streak, qualifying days and week', (tester) async {
    await tester.pumpWidget(_wrap(const StreakShareCard(
      currentStreak: 7,
      totalQualifyingDays: 5,
      currentWeek: 2,
    )));

    expect(find.text('7'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(find.text('Week 2 of 4'), findsOneWidget);
    expect(find.text('Subh Warrior'), findsOneWidget);
  });

  testWidgets('localizes digits in Bengali', (tester) async {
    await tester.pumpWidget(_wrap(
      const StreakShareCard(
        currentStreak: 7,
        totalQualifyingDays: 5,
        currentWeek: 2,
      ),
      locale: const Locale('bn'),
    ));

    expect(find.text('৭'), findsOneWidget); // Bengali 7
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/share/streak_share_card_test.dart`
Expected: FAIL — package import unresolved.

- [ ] **Step 3: Implement the card**

Create `lib/features/share/presentation/streak_share_card.dart`:

```dart
import 'package:flutter/material.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/l10n/l10n_utils.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

/// Fixed-size, self-contained visual for the shareable streak image.
/// No interactivity — designed to be wrapped in a [RepaintBoundary].
class StreakShareCard extends StatelessWidget {
  const StreakShareCard({
    super.key,
    required this.currentStreak,
    required this.totalQualifyingDays,
    required this.currentWeek,
  });

  final int currentStreak;
  final int totalQualifyingDays;
  final int currentWeek;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    return Container(
      width: 320,
      height: 400,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: context.appColors.streakGradient,
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
        ),
        borderRadius: AppRadius.brLg,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.mosque, color: onPrimary, size: 28),
              AppSpacing.hGapSm,
              Text(
                l10n.shareCardTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          Column(
            children: [
              Icon(Icons.local_fire_department, color: onPrimary, size: 48),
              Text(
                context.localizeNumber(currentStreak),
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                l10n.shareCardStreakLabel,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: onPrimary),
              ),
            ],
          ),
          Column(
            children: [
              Text(
                context.localizeNumber(totalQualifyingDays),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                l10n.shareCardQualifyingLabel,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: onPrimary),
              ),
              AppSpacing.vGapSm,
              Text(
                l10n.shareCardWeekLabel(currentWeek),
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: onPrimary),
              ),
            ],
          ),
          Text(
            l10n.shareCardFooter,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: onPrimary),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/share/streak_share_card_test.dart`
Expected: PASS (2 tests).

- [ ] **Step 5: Implement capture service + sheet**

Create `lib/features/share/data/share_card_service.dart`:

```dart
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Captures a [RepaintBoundary] to a PNG and opens the system share sheet.
class ShareCardService {
  Future<void> shareBoundary(GlobalKey boundaryKey,
      {required String text}) async {
    final boundary = boundaryKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (boundary == null) return;

    final image = await boundary.toImage(pixelRatio: 3.0);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    if (bytes == null) return;

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/streak_card.png');
    await file.writeAsBytes(bytes.buffer.asUint8List());

    await Share.shareXFiles([XFile(file.path)], text: text);
  }
}
```

Create `lib/features/share/presentation/share_sheet.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/analytics/analytics_service.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_spacing.dart';
import '../data/share_card_service.dart';
import 'streak_share_card.dart';

/// Bottom sheet with a live preview of the streak card and a share button.
Future<void> showShareSheet(
  BuildContext context, {
  required int currentStreak,
  required int totalQualifyingDays,
  required int currentWeek,
}) {
  final boundaryKey = GlobalKey();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
    ),
    builder: (sheetContext) {
      final l10n = AppLocalizations.of(sheetContext)!;
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.shareCardSheetTitle,
              style: Theme.of(sheetContext).textTheme.titleMedium,
            ),
            AppSpacing.vGapMd,
            RepaintBoundary(
              key: boundaryKey,
              child: StreakShareCard(
                currentStreak: currentStreak,
                totalQualifyingDays: totalQualifyingDays,
                currentWeek: currentWeek,
              ),
            ),
            AppSpacing.vGapMd,
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.share),
                label: Text(l10n.shareCardButton),
                onPressed: () async {
                  final analytics = sheetContext.read<AnalyticsService>();
                  await ShareCardService().shareBoundary(
                    boundaryKey,
                    text: l10n.shareCardFooter,
                  );
                  await analytics.logEvent(AnalyticsEvents.shareCardSent,
                      {'streak': currentStreak});
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}
```

Note: `Provider<AnalyticsService>` (non-nullable) is registered in `main.dart` by Task 2 — always register and read the non-nullable type. Tests that pump the sheet standalone must wrap it in `Provider<AnalyticsService>.value(value: FakeAnalyticsService())`.

- [ ] **Step 6: Gate + commit**

```powershell
dart format .; flutter analyze --no-pub; flutter test
git add lib/features/share test/features/share pubspec.yaml pubspec.lock
git commit -m @'
feat(share): add streak share card, capture service, and share sheet

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>
'@
```

---

### Task 6: Share hooks — success dialog + streak card

**Files:**
- Modify: `lib/screens/logday_screen.dart` (`_showSuccessDialog`, ~line 686-720: add a "Share" action to the `AlertDialog` when `isQualifying`)
- Modify: `lib/widgets/streak_card.dart` (add a share `IconButton` in the streak section when `currentStreak > 0`)
- Modify: `lib/core/l10n/app_en.arb` + ar/bn/ur (one key: `a11yShareStreak`, screen-reader label for the icon button; en value `"Share your streak"`, ar `"شارك سلسلتك"`, bn `"আপনার স্ট্রিক শেয়ার করুন"`, ur `"اپنی اسٹریک شیئر کریں"`)
- Test: `test/features/share/share_hooks_test.dart`

**Interfaces:**
- Consumes: `showShareSheet(...)` from Task 5; `ChallengeProvider.currentStreak/.totalQualifyingDays/.currentWeek` (existing getters); `StreakCard(currentStreak:, totalDays:)` existing constructor.
- Produces: no new API — UI affordances only. `StreakCard` gains optional `VoidCallback? onShare` (null hides the button) so the widget stays provider-free.

- [ ] **Step 1: Write the failing widget test**

Create `test/features/share/share_hooks_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subh_warrior/core/l10n/app_localizations.dart';
import 'package:subh_warrior/core/theme/app_theme.dart';
import 'package:subh_warrior/widgets/streak_card.dart';

Widget _wrap(Widget child) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.light(),
      home: Scaffold(body: child),
    );

void main() {
  testWidgets('streak card shows share button when onShare given',
      (tester) async {
    var tapped = false;
    await tester.pumpWidget(_wrap(StreakCard(
      currentStreak: 3,
      totalDays: 2,
      onShare: () => tapped = true,
    )));

    final shareButton = find.byIcon(Icons.share);
    expect(shareButton, findsOneWidget);
    await tester.tap(shareButton);
    expect(tapped, isTrue);
  });

  testWidgets('streak card hides share button when onShare null',
      (tester) async {
    await tester.pumpWidget(_wrap(const StreakCard(
      currentStreak: 3,
      totalDays: 2,
    )));

    expect(find.byIcon(Icons.share), findsNothing);
  });

  testWidgets('streak card hides share button at zero streak',
      (tester) async {
    await tester.pumpWidget(_wrap(StreakCard(
      currentStreak: 0,
      totalDays: 0,
      onShare: () {},
    )));

    expect(find.byIcon(Icons.share), findsNothing);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/share/share_hooks_test.dart`
Expected: FAIL — `No named parameter with the name 'onShare'`.

- [ ] **Step 3: Implement**

`streak_card.dart` — add the field and button:

```dart
// constructor:
const StreakCard({
  super.key,
  required this.currentStreak,
  required this.totalDays,
  this.onShare,
});

final VoidCallback? onShare;
```

In `_buildStreakSection`, inside the top `Row` after the emoji `Text`, add:

```dart
if (onShare != null && currentStreak > 0) ...[
  const SizedBox(width: 4),
  IconButton(
    icon: const Icon(Icons.share, size: 20),
    color: Theme.of(context).colorScheme.onPrimary,
    tooltip: AppLocalizations.of(context)!.a11yShareStreak,
    onPressed: onShare,
  ),
],
```

Caller (find the `StreakCard(` construction — `Grep "StreakCard(" lib/features/home`) passes:

```dart
onShare: () => showShareSheet(
  context,
  currentStreak: provider.currentStreak,
  totalQualifyingDays: provider.totalQualifyingDays,
  currentWeek: provider.currentWeek,
),
```

`logday_screen.dart` `_showSuccessDialog` — add as the FIRST entry in `actions:` (before the existing continue button), only when qualifying:

```dart
if (isQualifying)
  TextButton.icon(
    icon: const Icon(Icons.share, size: 18),
    label: Text(l10n.shareCardButton),
    onPressed: () {
      final provider = context.read<ChallengeProvider>();
      showShareSheet(
        context,
        currentStreak: provider.currentStreak,
        totalQualifyingDays: provider.totalQualifyingDays,
        currentWeek: provider.currentWeek,
      );
    },
  ),
```

(Use the *screen's* `context`, not the dialog builder's — the dialog stays open behind the sheet; existing Continue button behavior unchanged.)

Add the `a11yShareStreak` ARB key to all 4 files + `flutter gen-l10n`.

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test`
Expected: full suite PASS.

- [ ] **Step 5: Gate + commit**

```powershell
dart format .; flutter analyze --no-pub; flutter test
git add lib/widgets/streak_card.dart lib/screens/logday_screen.dart lib/features lib/core/l10n test/features/share
git commit -m @'
feat(share): hook share sheet into success dialog and streak card

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>
'@
```

---

### Task 7: End-to-end verification

**Files:** none (verification only).

- [ ] **Step 1: Full gate**

Run: `dart format --set-exit-if-changed .; flutter analyze --no-pub; flutter test`
Expected: all clean/green.

- [ ] **Step 2: Manual smoke on device/emulator**

Run: `flutter run`
Verify: log a qualifying day → success dialog shows Share → sheet previews card → share opens system sheet; streak card share icon works; switch language to বাংলা → card digits/labels localize; DebugView in Firebase console shows `day_logged` (enable with `adb shell setprop debug.firebase.analytics.app com.subhwarrior.app`).

- [ ] **Step 3: Update memory/status**

Mark analytics + share cards done in `IMPROVEMENT_PLAN` follow-on tracking (memory file `improvement-plan-status.md` equivalent for growth plan).
