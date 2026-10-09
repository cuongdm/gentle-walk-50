# Round 2 · Lens 4 — Legal / App Store

_09/10/2026 · read-only review. IDs are numbered across the whole round-2 report. Guideline numbers as of this date — verify against the current App Review Guidelines before submitting._

## Verdict
**Fail (pending owner)** — 1 Important (I20 · likely): the paywall never says what Pro includes. Everything else checked in this lens passes. Related money-transparency defects that are code bugs are in lens 1 (I1 trial reminder can vanish, I2 "You'll be billed" after the trial is cancelled).

## What was run / read
- `docs/release/1.0/checklist.md` (all sections), `docs/release/1.0/asc-listing-fields.md`, `docs/reviews/2026-10-08-app-review-recheck.md` (I-1, I-2, M-1, M-2 — all re-checked below), `appstore/metadata-json/en.json`, `appstore/captions.txt`, `docs/design/steady-claims.md`.
- Code: Paywall/*, CoverView (PaywallContainer, BeforeAppleSheetView, PlansUnavailableView), Me → SubscriptionSection, CancelGuideView, Permissions/PermissionStepView, OutdoorPrepView, ReviewPromptModifier, `Info.plist`, `GentleWalk.entitlements`, `PrivacyInfo.xcprivacy`.
- `python3 tools/lint/copy_lint.py` → 0 findings. `sips` on the app icon.
- Capture: SCR/s2-paywall-eligible.png (Pro Max, Mac session 09/10).

## Findings

### Important
I20 [Legal] [Important · likely] iOS/App/Features/Paywall/PaywallView.swift:36-60 (+ iOS/App/Features/Paywall/PaywallModel.swift:89-107) — the paywall never describes what the subscription gives · it shows "GOOD FOOTING PRO", the goal title, the trial timeline, the plan cards and (all plans) "Every plan unlocks the same things." — no list of what is unlocked; it opens from locked content (`PaywallTrigger.lockedContent`), Me → "See Pro plans" (MeSections.swift:112), the end of New York and onboarding, and only onboarding has a screen before it — "Your plan" (Onboarding/PlanReadyView.swift) does not say which parts are Pro either · 3.1.2(c): "Before asking a customer to subscribe, you should clearly describe what the user will get for the price." Also the title "Your 12 weeks to feel steadier…" names the 12-week program, which is **free** (app-context Price model, 08/10), so she may believe "Maybe later" loses her plan · fix: one short block in the empty band between the plan cards and the pinned footer (~200 pt empty on Pro Max), e.g. "Pro adds: every session and move · all five journeys · more reps and less hand on the chair as you get steadier · your own rest days · your full history" (2–3 lines, body/caption, EN + VI; wording through steady-claims and copy_lint); keep the title or make it "Your 12 weeks, with everything in Pro".
    Evidence: SCR/s2-paywall-eligible.png (no benefit text anywhere); `grep -rn "Pro adds\|What Pro" iOS/App/Features` → none.

## Checked and OK
- **3.1.1 / 3.1.2 trio and terms:** Restore · Terms (Apple standard EULA) · Privacy in the pinned footer on every plan view, inline at accessibility sizes; billed price is the bold card title, "$4.17 a month" a caption; trial length read from the store's intro offer (review I-1 fixed); "Free for 14 days, then $49.99 a year. Renews until you cancel, at least 24 hours before renewal." under the button; "Maybe later" + Close 56 pt; no countdown, no struck-through price; "You won't be charged today" only for a trial; lifetime-while-subscribed warning on the card and the cancel guide right after purchase; Restore also in Welcome and Me → Help.
- **5.1.1 permissions:** one button before each system dialog, no "Not now" (PermissionStepView.swift:17,109-111 — I-2 fixed); Close hidden at the location step (OutdoorPrepView.swift:45 — M-2 fixed); purpose strings concrete and match use, incl. the busy-day use of steps (Info.plist `NSHealthShareUsageDescription` — M-1 fixed); asked at the moment of need, never at launch.
- **5.1.1(v) / data deletion:** no accounts; "Delete all my data" in Me with a clear confirmation.
- **5.6.1:** review prompt only through `ReviewPromptPolicy` after Complete (ReviewPromptModifier.swift; WorkoutView.swift:106), never from a button.
- **2.5.4 / 2.5.1:** `UIBackgroundModes` audio + location only; no silent audio (SessionAudioComposer); location background updates switched off after the walk; entitlements HealthKit only, `healthkit.access` empty (no clinical records).
- **1.4.1 / health claims:** copy_lint 0; new recap/results copy only counts up, no fall/bone/pain words; self-check keeps "This is not a medical test." and "You compare only with yourself."; store captions keep to "up from a chair, more easily" / "steadier feet".
- **Store text vs app (2.3.1):** en.json renewal terms, Settings path, trial wording ("length shown in the app"), EULA link and "isn't medical advice" match the app; free-plan description matches Me's free line.
- **App icon:** 1024×1024 RGB without alpha (sips) — no "icon has alpha" rejection.
- **Export compliance:** `ITSAppUsesNonExemptEncryption = false` in Info.plist.

## Needs the owner (App Store Connect)
- Attach the subscription group and the 3 IAPs to the 1.0 build ("Add for Review"): if the reviewer's sandbox cannot load them, the app shows "Plans aren't available right now" and review stops under 2.1 (this is the most common first-submission IAP rejection).
- Privacy Policy URL (`{{PRIVACY_URL}}` still a placeholder in `appstore/metadata-json/en.json`; Việc 1 of the cloud hand-off).
- App Privacy label as in checklist §3 (Purchase History, not linked, not tracking; the IDFV/Device ID question is already an owner decision in docs/todo.md).
- Age rating answers (checklist §2); review notes + contact phone/email (checklist §5).
- Sandbox purchase on a real iPhone: yearly with trial, monthly, lifetime while subscribed, Restore after reinstall, cancel → back to free; a US sandbox account (app availability US-only, products 175 countries).
