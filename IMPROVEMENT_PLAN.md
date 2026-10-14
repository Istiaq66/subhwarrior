# Subh Warrior — Engineering Improvement Plan (Remaining Items)

> Completed work is removed from this file — see git history for earlier audits.
> Definition of done per code item:
> `dart format` clean · `flutter analyze` zero issues · `flutter test` green.

## Outstanding

### H1 — Tighten R8 keep rules (next release, not the first one)

Play Console's *DEX code optimization* check (Medium) reports obfuscation at
36% with no optimization or shrinking score. Cause: `android/app/proguard-rules.pro`
keeps whole libraries, so R8 cannot remove, rename or optimize them
(`build/app/outputs/mapping/release/seeds.txt` is ~10 MB):

```
-keep class io.flutter.** { *; }
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-keep class com.google.android.play.core.** { *; }
```

Firebase, Play services and the Flutter embedding ship their own consumer
rules, so these blanket keeps should be unnecessary.

Steps, on a branch:
1. Remove the four blanket `-keep` lines. Keep `-dontwarn com.google.android.play.core.**`
   and the targeted rules (flutter_local_notifications, `NotificationCompat`,
   flutter_callkit_incoming, annotations, `SourceFile,LineNumberTable`).
2. `flutter build appbundle --release` and compare the AAB size with 66.6 MB
   (1.3.1+7).
3. Install the **release** build and exercise every reflection-heavy path,
   since missing keep rules only fail at runtime:
   - Google sign-in and email sign-in, sign-out, account deletion
   - Firestore save/restore (log a day, reinstall, sign in again)
   - Fajr reminder, logging reminder, and the Fajr call screen
   - Home-screen widget refresh and the background-fetch headless task
   - A Crashlytics test crash, then confirm it is deobfuscated in the console
4. Add back narrow rules only for what actually breaks; merge when all pass.

Done when Play's DEX optimization check is no longer flagged and the release
build passes the checklist above.

### Human / console tasks (not code)

- **Play App Signing SHA-1.** After the first upload, add the *app signing key*
  SHA-1 (Play Console → App integrity) to Firebase and replace
  `android/app/google-services.json`. Until then Google sign-in fails in
  Play-installed builds.
- **CI deploy access.** Create the Google Play service account, grant it release
  access in Play Console, and add the `PLAY_SERVICE_ACCOUNT_JSON` repo secret
  (see `.github/workflows/ci.yml`). Set the `PLAY_RELEASE_STATUS` variable to
  `draft` only while the app has never been published.
- **Release keystore password.** It is still weak; change it with
  `keytool -storepasswd` (same key, same SHA-1) and update
  `ANDROID_STORE_PASSWORD` and `android/key.properties`.
- **Branding verification.** Search Console ownership file is live
  (`hosting/google4cbedca6d5408d3d.html`); re-run *Verify branding* in Google
  Auth Platform 24 h after verifying.
- **Store listing translations.** Add ar / bn-BD / ur to the Play store listing
  so the localized release notes in `distribution/whatsnew/` are accepted.
- **Terms of service — governing law.** `hosting/terms.html` says "the country
  where IS TECH is established"; name the country.
- **Translation review.** Machine-drafted ar/bn/ur strings in `lib/core/l10n/`,
  `distribution/whatsnew/` and the Arabic plurals need a native-speaker pass.
  Known nit: `shareCardWeekLabel` in Arabic mixes Arabic-Indic `{week}` digits
  with a literal Western "4".

### Small follow-ups

- **Recapture store screenshot 6** (share card) and the home screenshot: the
  current images predate the "1 qualifying day" plural fix and the duplicate
  check mark removal.
- **Verify the leaderboard Friends tab** works end to end before mentioning it
  in the store description.

### Optional architecture (take only if pain appears)

- **B6 — Riverpod 2 + go_router migration.** Current `provider` +
  controller/repository split works; migrate feature-by-feature only if state
  management or routing becomes a bottleneck.
