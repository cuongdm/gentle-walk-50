# Review A — onboarding, paywall, permissions, ready, countdown (88 images)

## Welcome
(no defects: SE default shows "Let's begin" + "Restore purchase" above the fold; XXL scrolls without clipping; dark OK)

## Onboarding — garden progress (all question steps)
[Minor] promax-dark/onboarding-activity-dark.png, onboarding-barriers-dark.png, onboarding-strength-dark.png (all -dark steps) — current plot's plant is deep green (Palette.primary) on a dim ochre halo, almost invisible in dark, so "where am I" is lost while past plants read fine — iOS/App/Features/Onboarding/GardenProgress.swift:29-32 — in dark use a lighter ink for the current plant (e.g. Palette.secondary/text colour) and raise the halo opacity.

## Onboarding — Goal (step 1)
[Important] promax-dark/onboarding-goal-dark.png — wrong state: shows Step 5 "Standing up without your hands is…", not Step 1 "What matters most?"; dark goal screen never captured — capture run / iOS/App/Debug/CaptureHook.swift onboarding-goal state — re-capture onboarding-goal on promax-dark.
[Minor] se-light/onboarding-goal.png, ip11-light/onboarding-goal.png — option "Move with less pain" reads as a pain-relief promise; docs/design/steady-claims.md bans "relieve pain" — iOS/App/Features/Onboarding/OnboardingCopy.swift:10 — owner check; e.g. "Move more comfortably".

## Onboarding — Barriers (step 2) / Strength (step 5) — highlighter
[Minor] se-light/onboarding-barriers.png, ip11-light/onboarding-barriers.png, promax-dark/onboarding-barriers-dark.png, */onboarding-strength*.png — ochre highlighter sits on the lower half of the words and runs past the last letter ("My joints hurt▁", "Hard, but I can▁"), reads like an offset underline/strike rather than a marker — iOS/App/Design/Components/AppIconChip.swift:101-105 — smaller offset (~0.45h) and no overhang past the text end.

## Onboarding — Name (step 3), Sore spots (step 6), Activity
(no defects: SE default fits with Continue + Skip visible; XXL scrolls cleanly; dark OK)

## Onboarding — Anything else (step 7)
[Important] se-light/onboarding-anything-else.png — "None of these" (the safe choice) is cut in half under the pinned doctor note + Continue footer on SE default text; plan goal says safe choice never below the fold — iOS/App/Features/Onboarding/OnboardingStepScaffold.swift:~180-200 (pinned footer with doctor note) + BodyLimitChips.swift — on compact height move the doctor note into the scroll content (or a 1-line version), so "None of these" sits above the footer.

## Onboarding — Your plan / plan-coach
(no defects in se-light / ip11 / promax-dark; Stop vs "Hear your coach" states correct)
[Minor] se-xxl/onboarding-plan-xxl.png = se-xxl/onboarding-plan-coach-xxl.png (byte-identical) — the audio row is below the fold at XXL, so the coach-playing state is not verified at XXL — capture script — scroll to the Day 1 card for the -coach XXL shot.

## Paywall
[Important] se-xxl/paywall-not-eligible-xxl.png — Yearly card note truncated "$3.33 a…" at XXL (the plan-note Text truncates instead of wrapping) — iOS/App/Features/Paywall/PaywallView.swift:215-216 — add `.fixedSize(horizontal: false, vertical: true)` to the note Text (as done for the renewing warning at 218-220).
[Minor] se-xxl/paywall-eligible-xxl.png, se-xxl/paywall-not-eligible-xxl.png — "GOOD FOOTING PRO" wraps to 2 lines and the Close (×) circle overlaps the end of "PRO" — PaywallView.swift:84-110 (Close is an overlay on the label row, label has no trailing inset) — give the label HStack `.padding(.trailing, Metrics.minTouchTarget)`.
[Minor] se-light/paywall-lifetime-while-subscribed.png — "Fewer plans" link half hidden under the pinned footer's top edge; on SE the "Cancel anytime in Settings…" note is below the fold in every paywall state (se-light/paywall-eligible.png, paywall-lifetime.png, paywall-monthly.png) — PaywallView.swift:30-60 — tighter plan-card vertical padding on compact height, or put CancelNote into the pinned footer next to the renewal line.
[Minor] ip11-light/paywall-monthly.png, ip11-light/paywall-lifetime*.png, promax-dark/paywall-*-dark.png (all-plans list) — cards mix two layouts: Monthly shows the price right-aligned on the row, Yearly and One payment stack the price under the name (ViewThatFits picks per card); prices don't line up down the list — PaywallView.swift:236-251 — use the stacked layout for all cards whenever any card needs it (e.g. decide once in the list, pass a flag).
[Minor] se-xxl/paywall-lifetime-xxl.png = paywall-monthly-xxl.png = paywall-lifetime-while-subscribed-xxl.png (byte-identical top of scroll) — selected card and renewing warning are off-screen, so these XXL states are not verified — capture script — scroll to the selected card for XXL shots.

## Permissions — Health / Health granted
(no defects in se-light / ip11 / promax-dark)
[Minor] se-xxl/permissions-health-xxl.png = se-xxl/permissions-health-granted-xxl.png (byte-identical) — the state difference is below the fold at XXL, so "granted" is not verified at XXL — capture script — scroll to the button/status for the granted XXL shot.

## Permissions — Reminder (1 of 2)
[Minor] se-light/permissions-reminder.png — chosen two-line row "After my morning / coffee": the highlighter becomes one block under line 2 only, line 1 has none — AppIconChip.swift:94-110 (HighlighterStroke on multi-line Text) — highlight per line (AttributedString background) or drop the stroke when the label wraps.
[Minor] se-light/permissions-reminder.png — the "Reminder at" label is dropped on SE (row shows only − 8:30 AM +), ip11/promax show it — reminder-time row ViewThatFits fallback (Features/Permissions) — keep the label on its own line above the stepper.

## Reminder offer (after first walk)
[Important] se-light/reminder-offer.png — time stepper row (− 8:30 AM +) is cut in half by the pinned "Remind me" footer, so on SE she can't see/adjust the time she agrees to without scrolling; "Reminder at" label also dropped — reminder offer view + shared reminder-time row — on compact height shrink/drop the kitchen painting so choices + time row sit above the footer.
[Minor] se-light/reminder-offer.png — same two-line highlighter block on "After my morning / coffee" — AppIconChip.swift:94-110.

## Phone placement
[Minor] promax-dark/phone-placement-dark.png — check mark on the chosen tile is dark green on dark green (low contrast) while other dark screens use the ochre check; light art tiles show grainy/white speckle edges against the dark card — iOS/App/Features/Workout/PhonePlacementView.swift (tile + ChosenCheck) — use the dark-mode ochre ChosenCheck like paywall/onboarding; clean art alpha.

## Ready (first walk)
[Critical] se-xxl/ready-first-walk-xxl.png — "Have ready" card collapses at XXL: tiles become ~2 pt slivers, labels show as single cut letters stacked down the card, icons invisible; card unreadable — iOS/App/Features/Workout/Shared/WorkoutReadyView.swift:98-105 (LazyVGrid with 2 flexible columns) + 156-169 (ReadyTile HStack at accessibility sizes) — at isAccessibilitySize use a plain VStack, one tile per row (as ThenStrip already does).
[Minor] promax-dark/ready-first-walk-dark.png — tile icons are Palette.secondary on secondary.opacity(0.14), nearly vanish in dark — WorkoutReadyView.swift:158-162 — stronger circle fill / lighter icon tint in dark.

## Countdown
[Important] se-light/countdown.png, se-xxl/countdown-xxl.png, ip11-light/countdown.png, promax-dark/countdown-dark.png — wrong state: all four show the walk player (Warm-up, Pause/Break/This hurts), not the "Get ready" 3-2-1 screen; the 3 s count ran out before the shot, so the countdown screen was never reviewed — iOS/App/Debug/WorkoutCaptureScenes.swift:110-115 + Features/Workout/Shared/WorkoutCountdownView.swift:36 (.task { await run() }) — under -ScreenshotMode countdown hold the count (skip run()), then re-capture.
[Critical] se-xxl/countdown-xxl.png (walk player at XXL) — top bar breaks: "End" capsule wraps one letter per line, "Warm-up · 5:09 left in total" wraps to 5 lines with the speaker icon over "5:09", and the WARM-UP pill is cut by the controls row below — iOS/App/Features/Workout/Walk/WalkPlayerView.swift:197-212 (WalkTopBar HStack) + Shared/EndSessionButton.swift:11-21 — at accessibility sizes stack the bar (End + sound row, status row below), `.fixedSize()` on End; let the phase area scroll/shrink instead of overlapping.
[Minor] se-light/countdown.png — status "Warm-up · 5:09 left in / total" orphans "total" on line 2 at default text on SE — WalkPlayerView.swift:205-208 — shorter compact copy ("5:09 left") or give the status more width.

Checked 88 images
