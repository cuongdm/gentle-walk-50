# Review C — players, previews, self-check, safety (read-only)

Paths below are relative to `iOS/App/`. Line numbers are approximate: they point to the block responsible.

## Break (S14)
- [Critical] se-light/break-outdoor.png (also ip11-light/break-outdoor.png) — on SE at default text size, "I'm ready to continue", "Walk home gently" and "Finish here for today" are all below the fold. On iPhone 11, "Finish here for today" is off-screen and "Walk home gently" touches the bottom edge. The art (180 pt), the header, the timer and UrgentSignsNote fill the screen first — Features/Workout/Safety/BreakView.swift:13-42 — Pin the action buttons with `.pinnedActions` (as OutdoorPrepView does) and let only the info stack scroll. Shrink the art to about 120 pt on compact heights.

## Chair player / stand-behind / rest
- [Critical] se-light/chair-stand-behind.png — "Ready" only peeks at the bottom, and "Wait" and "Skip this move" are off-screen at default text size. The 220 pt art plus the screenTitle and the countdown overflow, and `.scrollsWhenCrowded` takes the buttons with it — Features/Workout/Chair/ChairPlayerView.swift:303-345 — Pin Ready/Wait/Skip at the bottom. Scale the art down on compact height (for example `ViewThatFits` with heights of 220 and 120).
- [Important] se-light/chair-player.png, chair-player-dark.png, chair-player-reduce-motion.png, chair-counted.png, chair-timed.png — the ScrollView between the clip and the caption gets almost no height. Easier/Harder/Tips and the "Tap +1" hint are hidden, chair-timed shows the option buttons cut in half, and the title breaks as "Sit-to-/stand" — ChairPlayerView.swift:68-103 — Cap the clip height on compact screens (for example `.frame(maxHeight: 160)`) or move the options row out of the ScrollView.
- [Minor] se-light/chair-rest.png — "Skip rest" is pushed under the safety bar and cannot be seen — ChairPlayerView.swift:254-269 — Shrink the next-up clip on compact heights, or put Skip rest above the card.
- [Minor] chair-counted*.png (all devices) — the caption says "Two." while the counter shows 4 of 8, so the screen contradicts itself. This comes from the capture setup: it ticks to +40 s, then calls addRep ×4 — Debug/WorkoutCaptureScenes.swift:146-150 — Tick to a cue that matches the count, or skip addRep.

## Steady set / Balance
- [Important] se-light/steady-set.png, se-light/balance-back-walk.png — the "Two hands on the chair" support pill is cut off, and Easier/Tips are hidden. Balance shows a tiny painted still, and its expand button floats outside the image — ChairPlayerView.swift:68-100 (LadderLabels inside a ScrollView with almost no height) — Same fix as the chair player, and keep LadderLabels outside the ScrollView.
- [Minor] promax-dark/steady-set-dark.png, ip11-light/steady-set.png, balance-back-walk*.png — the clip or still shows one hand on the chair (or a counter), while the pill says "Two hands on the chair". A user would follow the picture — content/Art choice for bl.tandem / bl.back-walk — Use a two-hand variant, or word the pill to match.

## Stretch player
- [Minor] se-light/stretch-player.png, stretch-switch-side.png, stretch-cooldown.png — Easier/Tips are cut in half at the bottom of the ScrollView. The breathing pill covers the whole lower half of the clip, and an empty gap sits above the caption — Features/Workout/Stretch/StretchPlayerView.swift:58-74 — Cap the clip height on compact screens. Use a smaller BreathingGuide (dot 28) when height is compact.
- [Minor] ip11-light/stretch-cooldown.png — the version note is clipped mid-line (a little ... cut off) — StretchPlayerView.swift:64-74 / MoveTips — Give the note `.fixedSize(horizontal:false, vertical:true)`, or let the ScrollView take more height.
- [Minor] promax-dark/stretch-cooldown-dark.png — the note "Keep the knee a little bent, lean only a little" repeats "a little" — content tip/versionNote for st.hamstring — Use "Keep the knee soft and lean only slightly".

## Walk player (indoor)
- [Important] se-light/walk-player.png, walk-player-dark.png, walk-end.png — the clip is missing on SE, and an empty gap of about 100 pt is left above the QUICKER pill. WalkScene hides the picture below 80 pt but keeps the frame — Features/Workout/Walk/WalkPlayerView.swift:219-244 (and sceneHeight) — Collapse the frame to 0 when the picture is hidden (`.frame(height: hidden ? 0 : …)`), or show the clip at 80 pt.
- [Minor] se-light/walk-fullscreen.png — in the landscape panel the caption is clipped mid-line ("…out to the sides." cut) — Features/Workout/Shared/FullScreenVideoView.swift:95-117 — Allow 3 lines with minHeight, or make the caption area scroll.
- [Minor] ip11-light/walk-player-dark.png, se-light/walk-player-dark.png, chair-player-dark.png (all non-dark folders), promax-dark/*-player-dark-dark.png — the `*-player-dark` states render in light mode on the light devices, so they are identical to `*-player`. The state name promises dark — Debug/CaptureHook.swift:42,49 (no colour-scheme override) — Apply `.preferredColorScheme(.dark)` for these states, or drop them.

## Outdoor player / prep
- [Important] all outdoor-player*.png (se, ip11, promax) — while walking outdoors the caption reads "Keep your foot low as it slides out. Your hips stay still on the seat.", a seated cue. The outdoor request keeps level `.seated`, so the seated walk template and its lines are used — Features/Workout/Preview/WorkoutPreviewModel.swift:64 (level kept when place == .outdoors), WorkoutRequest.swift:94 — Force a standing/outdoor level when place == .outdoors, as is done for `.pad`. The capture also passes `.seated` (WorkoutCaptureScenes.swift:68).
- [Important] se-light/outdoor-player.png, outdoor-player-finding.png — the live map has a fixed height of 360 pt, which pushes the progress bar, "Next:" and the caption out of view on SE — WalkPlayerView.swift:166 (`liveMap(height: 360)`) — Use a smaller map height on compact screens (for example min(360, 40% of height)), or let it shrink like WalkScene.
- [Minor] se-light/outdoor-player-no-gps.png — the painting is hidden but its space stays, leaving a large empty gap under the top bar — WalkPlayerView.swift:219-244 — Same fix as the walk-player gap.
- [Minor] promax-dark/outdoor-player-dark.png, outdoor-player-finding-dark.png — the green "Tracking your walk" dot is nearly invisible on the dark pill — Features/Outdoor/OutdoorLiveMap.swift:97-112 — Use a lighter green, or add a light ring in dark mode.

## Session previews
- [Minor] preview-stretch*.png (all) — the hold times read "Neck turn 49 sec" and "Chin tuck 66 sec". These odd numbers look like bugs; preview rows with hold == 0 show the raw segment seconds — Features/Workout/Preview/WorkoutPreviewModel.swift:155-158 — Round to the nearest 5 or 10 s, or show reps or "about 1 min".
- [Minor] preview-stretch*.png vs stretch-player*.png — the preview lists 5 stretches, but the player says "Stretch 5 of 7" while on the 4th listed stretch — WorkoutPreviewModel.swift:151-156 (dedupes by id) vs StretchPlayerModel position — Count the same way in both.
- [Minor] preview-outdoor*.png, preview-walking-pad*.png — the row reads "Easy and brisk rounds", while indoors and in every player the phase is "QUICKER" / "Next: quicker" — WorkoutPreviewModel.swift:125-128 — Use one word everywhere ("quicker").
- [Minor] preview-stretch*.png — the subtitle "Seated, with a chair to hold on to." reads oddly for a seated stretch — WorkoutPreviewModel.swift:100 — Use "Seated in a sturdy chair."

## Self-check
- [Important] se-xxl/selfcheck-timer-xxl.png — the 0:13 clock runs under the status bar, and the required disclaimer is truncated to "This is not a me…" (steady-claims needs the full line) — Features/SelfCheck/SelfCheckViews.swift:121-133 and SelfCheckDisclaimer :34-44 — Keep the safe-area top padding, add `.scrollsWhenCrowded` to the upper part, and give the disclaimer `.fixedSize(horizontal:false, vertical:true)`.
- [Important] se-xxl/selfcheck-count-xxl.png — the title is squeezed beside the icon chip, one word per line, over about 7 lines — SelfCheckViews.swift:192-195 — At accessibility sizes, stack the icon above the title (or hide the chip).

## Not saved
- [Important] se-xxl/not-saved-xxl.png — the title is truncated to "No proble…" and the body to "Nothing was saved. Come…", with no scrolling — Features/Workout/WorkoutView.swift:149-166 — Add `.scrollsWhenCrowded()` with Close pinned, and shrink or hide the art at accessibility sizes.

## XXL (largest accessibility text) — players
- [Critical] se-xxl/chair-player*.png, chair-counted, chair-timed, steady-set, balance-back-walk, stretch-*, chair-fullscreen, walk-fullscreen — the safety controls overflow. The "This hurts" label spills outside the red fill and off the screen bottom, the hand icon sits on top of "Skip", and "Break" is clipped. BarButton is `fixedSize` vertically while the parent squeezes its height. The walk player is fine because its ScrollView gives way — Features/Workout/Shared/WorkoutSafetyBar.swift:18-31, 60-73 (accessibility Grid only when voice/music shows) + ChairPlayerView.swift:56-109 / StretchPlayerView.swift:46-84 / FullScreenVideoView.swift — Give the safety bar and control row `.layoutPriority(1)` so the middle ScrollView shrinks first. At accessibility sizes, stack Break above This hurts.
- [Important] se-xxl chair/stretch/steady/balance players — the End button shows only "✕ …" and the header reads "Move…", "Stret…", "Cool-…". On walk and outdoor players "End" wraps one letter per line ("E/n/d") and the status line takes 5 lines — Features/Workout/Shared/EndSessionButton.swift:12-21, WalkPlayerView.swift:192-213, ChairPlayerView.swift:57-64 — At accessibility sizes, use an icon-only End (keeping its accessibility label) and move the status/position text to its own row with `.fixedSize`.
- [Important] se-xxl/walk-player*.png, walk-home, outdoor-player* — the scroll viewport is only about 100 pt, so the phase pill is cut and the clock is never visible without scrolling — WalkPlayerView.swift:136-144 — Keep the clock and phase outside the ScrollView in the fallback (or above the top-bar text), and shrink the top bar as above.
- [Important] se-xxl chair/stretch/balance players — the caption bubble or plain caption is cut to one line ("Step back s…", "Now with m…", "Ten more sec…") even though lineLimit is nil at accessibility sizes — Features/Workout/Shared/CaptionBar.swift:32-38, 53-60 — Add `.fixedSize(horizontal:false, vertical:true)`, or move the caption into the ScrollView at accessibility sizes.
- [Minor] se-xxl/walk-transition-xxl.png — "QUICKE / R" breaks mid-word. In se-xxl/walk-home-xxl.png the status breaks as "Walkin / g home" — Features/Workout/Shared/PhaseTransitionCard.swift:12-16; WalkPlayerView.swift:207-210 — Use `.lineLimit(1).minimumScaleFactor(0.5)` on the transition label, and wrap the status by words (put it on its own row).
- [Minor] se-xxl/stretch-player-xxl.png, stretch-switch-side-xxl.png — the breathing pill covers the whole clip and is truncated to "Bre…" — StretchPlayerView.swift:111-124 — Show the dot only (the label goes into accessibility) at accessibility sizes.
- [Minor] se-xxl chair/stretch players — the expand button is larger than the shrunken clip, and "Next: …" and the move title are cut mid-line inside the ScrollView — ChairPlayerView.swift:65-69, Shared/MoveGuidance.swift — Cap the VideoCornerButton size, and let Next wrap to 2 lines.
- [Minor] se-xxl/chair-fullscreen-xxl.png, walk-fullscreen-xxl.png — the clock is cut ("0:24" shows only its top half), "Next: Single-leg stand" is cut mid-line, and the minimise and TV icons overflow their circles — FullScreenVideoView.swift:95-117 — Put the panel text in a ScrollView above pinned controls, and cap the icon size.

## Dark mode
- [Minor] promax-dark/not-saved-dark.png, chair-stand-behind-dark.png, balance-back-walk-dark.png, preview-indoor/stretch-dark (level tiles) — the painted cut-out art sits on a light beige card, which looks like a glaring block on the dark background — Design/Components/ArtImage.swift (card fill) — Use a darker card fill in dark mode for cut-out art.
- [Minor] promax-dark/chair-counted-dark.png — the "Counted for you" dot is dark green on near-black and barely visible — ChairPlayerView.swift:161-178 — Use a lighter green token in dark mode.
- [Minor] promax-dark/walk-transition-dark.png — the white status bar sits on the mustard full-screen fill with low contrast — PhaseTransitionCard.swift:9-20 — Add `.preferredColorScheme(.light)` / a dark status bar style while the card shows.

## Safety (This hurts)
- [Minor] se-light/this-hurts.png — the emergency note ("Chest pain… call emergency services") runs off the bottom on SE at default text size and needs scrolling — Features/Workout/Safety/ThisHurtsView.swift — Move the urgent note above the text-link options, or tighten the spacing.

Checked 152 images

## Fix log (09/10/2026)

Verified on iPhone SE (second sim, default + XXL) in `scratchpad/m5/fixC/r1..r3`; core `swift test`, full `xcodebuild test`, release gate, copy_lint 0, xcstrings en/vi 0 missing. No new strings.

- [Critical] Break outdoors below the fold — FIXED. BreakView: buttons pinned at the bottom (own bar with the sky wash), painting 180 → 120, info scrolls; inline at accessibility sizes.
- [Critical] Stand behind chair off-screen — FIXED. Ready/Wait/Skip pinned; painting 220 → 120 → 84 before the words scroll; inline at accessibility sizes.
- [Important] Chair player options hidden on SE — FIXED. Shared `MovePlayerPortrait` (chair + stretch): clip capped at 112 pt below 700 pt height, tighter spacing, Pause 64 pt on SE. Easier/Harder/Tips now visible on chair-player/timed/counted; steady-set shows them peeking (scrolls).
- [Minor] Rest: Skip rest hidden — FIXED. Skip rest fixed above the safety row; next clip shrinks to 110 pt first.
- [Minor] chair-counted caption vs counter — FIXED (capture adds 2 reps, matching "Two.").
- [Important] Steady set pill cut / options hidden — FIXED (same layout; pill visible, options scroll).
- [Minor] Steady/balance picture shows one hand vs "Two hands" pill — SKIPPED (art/content choice).
- [Minor] Stretch: options cut, breathing pill covers clip — FIXED (clip cap; dot-only 28 pt guide on a small clip, label kept for VoiceOver).
- [Minor] Stretch version note clipped — FIXED (`fixedSize` vertical on the note).
- [Minor] "a little … a little" hamstring note — SKIPPED (content wording, needs EN+VI content pass).
- [Important] Walk player empty gap on SE — FIXED. Picture needs ≥ 80 pt or the layout without it is used (ViewThatFits), so no gap.
- [Minor] Walk full-screen caption clipped — FIXED in landscape (caption fixed-size inside the scroll panel).
- [Minor] `*-player-dark` captured light — FIXED. CaptureRouter applies `.preferredColorScheme(.dark)` to "-dark" states.
- [Important] Outdoor walk plays seated cue — FIXED, test first (`SessionPresetRequestTests.outdoorWalkIsNeverCoachedSeated`). `WorkoutRequest.coachedLevel`: outdoors always `.inPlace`; preview request outdoors uses `.inPlace`. FOLLOW-UP: in-place template still has chair lines ("Stand near your chair", calf stretch "hold your chair", ankle "side of your seat") and the outdoor preview lists "Cool-down and stretches" — needs an outdoor template/lines.
- [Important] Live map 360 pt pushes clock off SE — FIXED. Map tries 360/260/180, then 150 with stat-size clock and tight spacing; distance shows under the clock whenever the map is not shown.
- [Minor] Outdoor no-GPS gap — FIXED (same as walk gap).
- [Minor] Tracking dot invisible in dark — SKIPPED (needs a new light-green token in both appearances).
- [Minor] Preview "49 sec"/"66 sec" — FIXED (rounded to 5 s: 50/65 sec).
- [Minor] Preview count vs "Stretch 5 of 7" — SKIPPED (counting rule needs a product decision: dedupe vs repeats).
- [Minor] "Easy and brisk rounds" — FIXED (always "Easy and quicker rounds"; old key now unused in catalog).
- [Minor] Stretch subtitle wording — SKIPPED (copy change + VI; left for copy pass).
- [Important] Self-check timer under status bar / disclaimer cut — FIXED. Clock + disclaimer scroll when crowded, Stop early / This hurts fixed; disclaimer lines `fixedSize`.
- [Important] Self-check count title one word per line — FIXED (chip above the title at accessibility sizes).
- [Important] Not saved truncated — FIXED (scrollsWhenCrowded, Close pinned, art hidden at accessibility sizes).
- [Critical] XXL "This hurts" spills / hand over Skip — FIXED. Safety bar and control row `fixedSize` vertical + `layoutPriority(1)`, words capped at `PlayerChrome.typeLimit` (.accessibility2), buttons equal height.
- [Important] XXL End "✕ …" / "E/n/d", headers cut — FIXED. End is icon-only at accessibility sizes (label "End session"); position/move bar move into the scroll area; walk status line moves into the scroll area.
- [Important] XXL walk: clock never visible — FIXED. Crowded layout keeps phase + clock (capped .accessibility1) above the scroll, status/Next/caption scroll.
- [Important] XXL caption cut to one line — FIXED (caption `fixedSize` vertical at accessibility sizes; inside the scroll area on chair/stretch).
- [Minor] "QUICKE/R" — FIXED (one line, scales down). "Walkin/g home" — FIXED (status on its own row in the scroll).
- [Minor] XXL breathing pill "Bre…" — FIXED (dot only on small clip).
- [Minor] XXL expand/minimise/TV icons overflow — FIXED (VideoCornerButton capped at .xxLarge); "Next:" wraps (`fixedSize`).
- [Minor] XXL full-screen clock cut — FIXED (landscape panel: counter first, move bar after the caption at accessibility sizes; controls fixed).
- [Minor] Cut-out art on beige card in dark — SKIPPED (art card design, outside players).
- [Minor] "Counted for you" dot dark — SKIPPED (same token question as tracking dot).
- [Minor] Transition card status bar contrast — SKIPPED (preferredColorScheme would flip the whole screen).
- [Minor] This hurts urgent note below fold on SE — SKIPPED (not re-checked this pass; layout change in ThisHurtsView left for a later pass).

### Follow-up: outdoor walk lines (09/10/2026)
- Pre-existing: before `436e634` an outdoor walk played her indoor level's template (`ses.walk.seated.*` → seated cues, `ses.walk.inplace.*` → chair lines); no outdoor template or outdoor lines ever existed.
- Chair-dependent in `ses.walk.inplace.*`: set-up `a2.setup.inplace.1/.3/.shoes`; move lines `a2.move.*` (heel-dig/knee-lift/side-step dizzy/shift easy/heel-back harder "chair", march easy "floor") plus intros, demos `a4.demo.*`, `a2.now.*`, "Next up" lines; `a1.19` heel taps; rotated `a2.brisk.inplace.2` "Stay close to your chair"; stretches `st.calf` (hold chair), `st.ankle` (side of seat), `st.thigh` (sit on chair) with `a2.cool.stretch.*`.
- FIXED with recorded lines only (EN + VI m4a exist): `GentleWalkCore/Plan/OutdoorWalk.swift` keeps the in-place walk's timing/phases, drops those lines and chair stretches, swaps `a2.brisk.inplace.2` → `.4`, keeps arm swing, heel-to-toe, pace/talk-test/safety lines, the slow cool-down walk and the standing chest stretch with the breaths and "That's your walk for today". Applied in `WorkoutRequest.plan` when outdoors. Tests first: `OutdoorWalkTests` (all intensities, long walks, every body limit, 4 rotations: no chair/seat/floor/demo text, close line kept) + app `outdoorPreviewListsWhatPlays`.
- Preview outdoors now lists "Cool-down walk" + "Cool-down stretch" (existing strings) instead of "Cool-down and stretches".
- No new recordings needed. Side effect: easy parts outdoors are quieter (move coaching removed). Optional owner decision for later, NOT recorded: an outdoor set-up line, e.g. "Pick a flat, familiar route, and walk at a pace where you can still talk."
