# Review D — Progress, Complete, Journey, Program (+ VI)

## Progress
- [Important] se-xxl/progress-day-xxl.png — day-sheet title breaks mid-word ("Wedn / esday, / Octob / er 7") because "Close" (fixedSize) sits beside the title in an HStack at accessibility sizes — Design/Components/ScreenHeader.swift:50-53 (ClosableHeader) — at `typeSize.isAccessibilitySize` stack title above Close (VStack / AnyLayout), or ViewThatFits.
- [Minor] ip11-light/progress-lower.png, se-light/progress-lower.png, promax-dark/progress-lower-dark.png, ip11-light/progress-checks.png — 2-week-checks chart x-axis labels "Week 0 / Week 3" are the Swift Charts default (~11 pt, light grey), well under the 17 pt body rule and low contrast — Features/Progress/ProgressScreen.swift:218-227 — add `.chartXAxis { AxisMarks { AxisValueLabel().font(...caption role...).foregroundStyle(Palette.textMuted) } }` or draw labels under bars like YourResultsCard.
- OK: "Hands on the chair" in progress-lower (ip11/SE/dark) now shows Fingertips lit (all three steps filled, 5·2·1 dots = 8 moves). Scrolled Progress states (progress-empty, progress-lower, progress-lower-free) keep an opaque band under the status bar — no text under it.

## Complete
- [Important] promax-dark/complete-dark.png, complete-first-walk-dark, complete-check-invite-dark, complete-level-up-dark, complete-outdoor-dark, complete-reps-up-dark, complete-stopped-dark, complete-stretch-dark — tree art in the "6 of 14 active days to Sapling" wash is almost invisible in dark (multiply blend on a dark fill turns it black); the row reads as text with a stray dark speck — Features/Workout/Complete/CompleteJourneyCards.swift:199 (`.blendMode(.multiply)`) — drop multiply in dark (`scheme == .dark ? .normal : .multiply`) or use a dark-variant asset.
- [Minor] ip11-light/complete*.png, se-light/complete*.png — same row in light: the sapling art is tiny and sits at the bottom-left corner of its 58 pt frame (art has big transparent margins), so it looks misaligned against the centred text — CompleteJourneyCards.swift:197-204 — crop the tree assets or scale/align `.bottom`-anchored art to centre.
- [Minor] ip11-light/complete-check-invite.png, se-light/complete-check-invite.png, promax-dark/complete-check-invite-dark.png — wrong state data: shows "+0.2 mi on your journey" yet "Next postcard: Central Park Zoo · 0.1 mi to go" while the tilted card already shows Central Park Zoo as reached (Zoo is mile 0) — Debug/WorkoutCaptureScenes.swift:207-208 — use `unlockedStops: [ny.stops[0]], nextStop: ny.stops[1], milesToNext: 0.75` like complete-first-walk (capture fixture only).
- OK: Done pinned and visible on every SE default-text Complete state; XXL states stack and scroll without clipping.

## Journey / Journeys / Locked stop / Where next
- [Important] ip11-light/locked-stop.png, se-light/locked-stop.png, promax-dark/locked-stop-dark.png, se-xxl/locked-stop-xxl.png — wrong state for the name: shows the normal "Next stop Laurel Falls · 1.0 mi to go · Start today's session" card, no LockedStopCard (free leg ends at Laurel Falls, mile 2.4; fixture puts her at 1.4) — Debug/AppCaptureScene.swift:197 — set `miles: 2.4` (at the free-leg limit) so `isLockedAhead` is true.
- [Important] ip11-light/where-next.png, se-light/where-next.png, promax-dark/where-next-dark.png — the finished NYC card is dimmed by `.disabled`, so the "Done" pill and title fall to very low contrast (near invisible in dark) — Features/Journey/JourneyListView.swift:75 — keep the card non-interactive with `.allowsHitTesting(false)` + `.accessibilityAddTraits`, or dim only the image (`.opacity` on ArtImage) and keep the Done label at full contrast.
- [Minor] se-light/journey.png, se-light/locked-stop.png — on SE default text the Next-stop card's "Start today's session" button sits under the tab bar (below the fold) — Features/Journey/JourneyView.swift:23-30 — shorten the map height on compact heights (e.g. ViewThatFits / smaller JourneyMap) so the next-stop button is reachable without scrolling, if the button counts as this screen's main action.

## Program
- OK: program, program-finished (SE buttons pinned and visible; XXL scrolls), dark variants — no defects.

## Vietnamese (ip11-vi)
- [Important] ip11-vi/weekly-checkin.png — title "Tuần này bạn thấy…" then subtitle "Về tuần trước." contradicts itself (this week vs last week); EN source has the same clash ("This week felt…" / "About last week.") — Features/WeeklyCheckIn/WeeklyCheckInView.swift:18, keys `This week felt…`, `About last week. You can skip this.` — e.g. EN "Last week felt…" / VI "Tuần qua bạn thấy…", subtitle "Bạn có thể bỏ qua."
- [Minor] ip11-vi/paywall-eligible.png — "20 thg 10 · App nhắc bạn": English loanword "App" — key `We remind you` — "Ứng dụng nhắc bạn" / "Chúng tôi nhắc bạn".
- [Minor] ip11-vi/onboarding-anything-else.png — "Còn điều gì app nên biết không?" ("app") — key `Anything else we should know?` — "Còn điều gì mình nên biết không?" (matches the coach's "mình" voice).
- [Minor] ip11-vi/onboarding-anything-else.png — chip "Không nhảy" reads as a refusal ("I don't jump"/"don't skip") — key `No jumping` — "Không bật nhảy" / "Tránh động tác nhảy".
- [Minor] ip11-vi/paywall-lifetime*.png, paywall-monthly.png — "Ít gói hơn" (fewer plans) is literal and odd as a collapse link — key `Fewer plans` — "Thu gọn".
- [Minor] ip11-vi/permissions-health.png — "Tiến bộ hiện số bước cả ngày của bạn…" — tab name used as subject without marking it reads like the noun "progress" — key `Progress shows your all-day steps. Your journey moves either way.` — "Mục Tiến bộ sẽ hiện số bước cả ngày của bạn. Hành trình vẫn tiến, dù có kết nối hay không."
- [Minor] ip11-vi/today.png, today-free.png, today-trial-*.png — "Chúng tôi sẽ chỉnh…" while the coach speaks as "mình" elsewhere (onboarding bubbles) — key `We'll set today's session to match.` — "Mình sẽ chỉnh buổi tập hôm nay cho phù hợp."
- OK: no truncation or untranslated English seen in VI shots; Complete, Progress, Me, self-check intro, onboarding and paywall read naturally otherwise; paywall trio, prices and renewal terms present.

Checked 133 images

## Fix log (09/10/2026, branch local/m5-fix-d)
- [Important] Day-sheet title mid-word break — ScreenHeader.swift `ClosableHeader`: at accessibility sizes Close gets its own row (trailing) above the title, title full width, capped at AX2 so "Thursday," fits one line on SE; VoiceOver still reads title first. Re-shot se-xxl + ip11 progress-day@xxl: "Thursday, / October 8" wraps by words.
- [Important] Complete tree art invisible in dark — CompleteJourneyCards.swift `TreeBadge`: dark mode puts the art on an artPaper tile (multiply inside a compositing group); light keeps multiply on the wash. [Minor] same fix crops the art to the plant (`Art.treeContentRect`, measured from the PNGs) so seed/sprout fill the 58 pt square, centred. Re-shot complete, complete-dark, complete-level-up-dark.
- [Important] locked-stop wrong state — AppCaptureScene.swift: 2.4 mi + Laurel Falls opened → LockedStopCard "Next stop: Clingmans Dome · Pro" (ip11 light/dark, SE, SE xxl).
- [Important] where-next Done card greyed — JourneyListView.swift: done card is no longer a Button (no `.disabled`), combined a11y element; "Done" text in Palette.text (checked pair), tick in secondary. Light + dark readable.
- [Important] Weekly check-in clash — "Last week felt…" / "You can skip this." (EN); VI "Tuần qua bạn thấy…" / "Bạn có thể bỏ qua." (ui-extra-17.json; old keys removed from ui-extra-10/12).
- [Important→fixed] SE Journey button under tab bar — JourneyView.swift: on short viewports (< 680 pt: SE, mini) map 190 pt, spacing 12, next-stop card above the progress card; SE "Start today's session" now fully above the tab bar. iPhone 11+ unchanged. Note: SE locked-stop "See Pro plans" still needs a scroll (two-line route title + long Pro line).
- [Minor] Check-invite fixture — WorkoutCaptureScenes.swift: Zoo reached, next Bethesda Fountain 0.75 mi.
- [Minor] 2-week chart x-axis — ProgressScreen.swift `.chartXAxis` labels at caption role in textMuted.
- [Minor] VI: "Ứng dụng nhắc bạn" (We remind you + We'll remind you), "Ứng dụng luôn báo ngày…" (same paywall), "Còn điều gì mình nên biết không?", "Không bật nhảy", "Thu gọn", "Mục Tiến bộ sẽ hiện số bước cả ngày của bạn. Hành trình vẫn tiến, dù có kết nối hay không.", "Mình sẽ chỉnh buổi tập hôm nay cho phù hợp." Re-shot ip11 VI: all read as intended.
- Checks: extract 1013 keys, apply_catalog vi 1069/1069, --check 0 problems, coverage en,vi 0 missing, copy_lint 0 findings.
- Tests: core `swift test` 279/279 green; ReleaseContentTests (TEST_RUNNER_RELEASE_CHECK=1) green; full app `xcodebuild test` 285 tests, all green except 2 StoreServiceTests (`trialDaysComeFromTheIntroOffer`, `oneWeekOfferReadsSevenDays`: `store.isEligibleForTrial` false) — same 2 fail on the base commit 3c06a9d without these changes (pre-existing, StoreKitTest intro-offer eligibility on the iOS 27 sim), not touched here.
