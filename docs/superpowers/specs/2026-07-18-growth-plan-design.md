# Subh Warrior — Launch & Growth Plan (Design)

**Date:** 2026-07-18
**Status:** Approved by owner (brainstorming session)
**Strategy:** "A pure" — build the viral core before launch, no beta program, launch when done.

## Context

Subh Warrior (28-day Fajr + deep-work challenge app, Flutter/Firebase) is feature-complete
per `IMPROVEMENT_PLAN.md` but unpublished. Owner decisions:

- **Stage:** not published; target public launch in ~12 weeks (2–3 months).
- **Audience:** Bangladesh first (Bengali flagship locale; English secondary; ar/ur shipped, not marketed). Android-first — BD is ~97% Android.
- **Monetization:** freemium/ads *eventually*; nothing at launch. Keep client architecture paywall-ready, decide from data later.
- **Growth bet:** product virality (share cards, invites, friends leaderboard) over cross-promo or content marketing.

## Goal & success criteria

Ship on Google Play within 12 weeks with the viral loop built in. At launch + 8 weeks:

| Metric | Target |
|--------|--------|
| Installs | 5,000 |
| New users via invite/share attribution | ≥ 25% |
| D7 retention | ≥ 20% |
| Active users in a friends group | ≥ 30% |

## Product workstream — the viral core

Dependency-ordered:

### 1. Streak share cards (weeks 3–4)
- Branded image (streak count, qualifying days, current week) rendered via `RepaintBoundary` → system share sheet (`share_plus`, already a dependency).
- Channels that matter in BD: WhatsApp, Facebook. Localized digits already implemented.
- Hooks: qualifying-day success dialog; streak milestones 7/14/21.
- Analytics: `share_card_sent`.

### 2. Challenge invite links (weeks 5–7)
- Firebase Dynamic Links is deprecated → Android App Links + static landing page (`subhwarrior.web.app`) carrying `?ref=<uid>`.
- On first sign-in after install via link, store referral attribution in Firestore (powers the invite metric).
- Analytics: `invite_sent`, `invite_accepted`.

### 3. Friends leaderboard (weeks 8–10)
- Replaces the existing "Friends — coming soon" tab.
- Mutual add via invite link or username search.
- New Firestore collection `friendships/{uidPair}` + security rules.
- UI reuses the existing leaderboard row widget, filtered to friends + self.
- Analytics: `friend_added`.

### 4. Group challenges (stretch — only if ahead by week 8, else v1.1)
- Named group, shared 28-day window, group progress screen.

### Monetization prep (no visible change)
- No paywall at launch. Keep entitlement checks out of local client state (no baked-in "premium" flags).
- Analytics coverage (below) makes future paywall placement data-driven.

## Launch readiness workstream

### Analytics (week 1, before features)
Add `firebase_analytics`. Core events: `challenge_started`, `day_logged` (qualifying y/n),
`streak_milestone`, `share_card_sent`, `invite_sent`, `invite_accepted`, `friend_added`,
`notification_opened`.

### Store listing / ASO (Bangladesh-focused)
- Play listing localized in Bengali *and* English (per-locale listings).
- Keyword targets: "ফজর", "fajr alarm", "fajr challenge", "morning routine", "salah tracker".
- Screenshots: Bengali UI, dark + light, streak share card front and center; feature graphic shows the 28-day arc.
- Category: Lifestyle. Pre-registration page live ~3 weeks before launch.

### Compliance / hard blockers
- Privacy policy page (location, auth, analytics collected) — hosted on the landing site.
- Play Data Safety form matching actual collection.
- `SCHEDULE_EXACT_ALARM` justification text for Play review; notification permission flow already handled.
- **Firestore rules deploy** (pending from IMPROVEMENT_PLAN Phase D) + rules for the new `friendships` collection — must precede any public install.
- CI release build wired to the Play internal track (fastlane or gradle-play-publisher); release signing already in place.

### Landing page
Single static page on Firebase Hosting (free tier): value prop in bn/en, Play link,
`assetlinks.json` for App Links, invite-link handling, privacy policy.

## Timeline (12 weeks)

| Weeks | Work |
|-------|------|
| 1–2 | Analytics events, landing page + privacy policy, Firestore rules deploy, Play console setup |
| 3–4 | Streak share cards + share hooks |
| 5–7 | Invite links + referral attribution |
| 8–10 | Friends leaderboard (model, rules, UI) |
| 11 | Hardening: internal testing track, polish pass, final store assets |
| 12 | Public launch + pre-registration release |

## Post-launch loop (weeks 13+)

- Weekly funnel review: install → `challenge_started` → D7 → share/invite rates. Iterate on the weakest step, not on new features.
- v1.1 candidates, ranked by data: group challenges, Ramadan mode (largest seasonal spike for Fajr apps), home-screen widget, iOS release.
- Monetization decision gate at ~20k MAU: ads vs premium (cosmetics/insights), decided from analytics.

## Out of scope

- Beta/community program (explicitly declined — "A pure").
- GTAF cross-promo and content marketing as planned channels.
- iOS at launch.
- Any monetization implementation.
