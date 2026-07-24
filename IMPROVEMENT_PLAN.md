# Subh Warrior — Engineering Improvement Plan (Remaining Items)

> All completed phases have been removed from this file — see git history for the
> original audit (Phases A–D, C1–C7, E1–E3, F1–F2, G1–G7 are done). What's below
> is the outstanding work only. Definition of done per item:
> `dart format` clean · `flutter analyze` zero issues · `flutter test` green.

## Outstanding

### Human / console tasks (not code)

- **Translation review.** Machine-drafted ar/bn/ur ARB translations (300+ keys
  each in `lib/core/l10n/`) need a native-speaker pass before marketing those
  locales. Known nit: `shareCardWeekLabel` in Arabic mixes Arabic-Indic `{week}`
  digits with a literal Western "4".

### Optional architecture (take only if pain appears)

- **B6 — Riverpod 2 + go_router migration.** Current `provider` +
  controller/repository split works; migrate feature-by-feature only if state
  management or routing becomes a bottleneck.

## Growth work

Launch/growth roadmap lives separately:
- Spec: `docs/superpowers/specs/2026-07-18-growth-plan-design.md`
- Plan 1 (analytics + share cards): `docs/superpowers/plans/2026-07-18-analytics-and-share-cards.md` — implemented on `feature/analytics-share-cards`
- Plans 2–3 (invite links, friends leaderboard): not yet written
