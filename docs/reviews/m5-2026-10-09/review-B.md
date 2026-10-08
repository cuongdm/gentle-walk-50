# Review nhóm B (Today, All sessions, Me, sheets) — m5

## Me → Delete confirm
- [Critical] se-xxl/me-delete-confirm-xxl.png — at XXL every line is cut to one line with "…": the 3 explanation sentences ("This removes…", "Workouts alr…", "Your subscri…") and both buttons ("Delete ev…", "Keep my…"). She cannot read what gets deleted or which button is which — iOS/App/Features/Me/MeSections.swift:483-497 (VStack + 2 Spacers, no ScrollView) — wrap in ScrollView at accessibility sizes (keep Spacers only when !isAccessibilitySize), add `.fixedSize(horizontal: false, vertical: true)` to the texts.

## Today
- [Important] se-light/today-done.png (also ip11-light/today-done.png) — on the green "Done for today" card, "Today's session is still here if you'd like it" and "See all sessions" are dark ink on mid green (about 3:1, under 4.5:1); on SE the first link also wraps to 2 lines with a big gap above "See all sessions" — TodayView.swift:358-370 + Design/Components/TextLinkButtonStyle.swift:15 (the style forces `Palette.text`, so `.foregroundStyle(Palette.onStrongFill)` is ignored) — give TextLinkButtonStyle a colour parameter (default `Palette.text`) and pass `onStrongFill` on the done card; add the pair to `Palette.textPairs`.
- [Important] se-light/today.png, today-free.png, today-dark.png, today-trial-ended.png, today-welcome-back.png, today-last-week.png — Start sits at ≈68–82 % of SE height (today ≈68 %, trial-ended ≈82 % with "Pick a different session" under the tab bar); plan goal "Start in the upper part / ≤55 %" still not met (same concern as task 1.8) — TodayView.swift:20-46 (2-line greeting + check-in row + "We'll set today's session to match.") — owner decision already pending; options: 1-line greeting on compact height, drop the helper line under the check-in, or trial-ended note as one caption line.
- [Important] ip11-light/today-fewer-reminders.png, promax-dark/today-fewer-reminders-dark.png — wrong state: byte-identical to `today` (no "Want fewer reminders?" card anywhere); fixture never satisfies `offersFewerReminders` (5 consecutive days before 8:30) — Debug/AppCaptureScene.swift:177-260 (no `.todayFewerReminders` seed) — seed 5 consecutive mornings before the reminder time (or set the card directly) and recapture.
- [Minor] ip11-light/today-moved-up.png, promax-dark/today-moved-up-dark.png — "Your walks are now In place. Seated is one tap away." — level title capitalised mid-sentence reads oddly — TodayCards.swift:32 — use a lowercase/sentence form ("Your walks are now in place, standing.") or quote the level name.
- [Minor] se-light/today-trial-ended.png, ip11-light/today-trial-ended.png — title wraps as "Free walk of the day ·" / "14 min", leaving the "·" dangling at line end — TodayModel.swift (title "Free walk of the day · \(minutes) min") — put minutes on the detail line or use a non-breaking space before "·".
- [Minor] ip11-light/today-set-aside.png, se-light/me.png ("How to cancel") — underlined text links sit ~8 pt (Me: ~17 pt) right of the text above them, visibly misaligned — TextLinkButtonStyle.swift:8 (`horizontalPadding` 8) / TodayCards.swift:46, MeSections.swift:115 — use `horizontalPadding: 0` for left-aligned links.
- [Minor] se-light/today-dark.png, ip11-light/today-dark.png — state named "today-dark" renders light (identical to other light shots); dark is only right on promax — RootView.swift:93 (only "-xxl" is pinned) — pin `.preferredColorScheme(.dark)` for "-dark" states or drop the state from light runs.
- [Minor] se-light (today, fewer-reminders, move-reminder, moved-up identical; today-dark, goal-line, pain-card, program, set-aside, trial-ending identical) and se-xxl (9 states identical to today-xxl) — the state's own card is below the fold, so these SE/XXL shots verify nothing about the card — capture script — also capture each state scrolled to its special card (initialAnchor like Progress).

## Swap sheet / Watch on TV / Sound (ClosableHeader)
- [Important] se-xxl/today-swap-xxl.png, se-xxl/watch-on-tv-xxl.png — at XXL the title breaks inside words ("somet/hing", "support/s") because "Close" is fixed-size beside it and the title gets ~45 % width — Design/Components/ScreenHeader.swift:50-53 — at accessibility sizes stack Close above the title (ViewThatFits / VStack), as SettingsCard does.
- [Important] se-light/watch-on-tv.png (+ ip11, promax) — step 1 "Swipe down from the top-right corner of your phone." is wrong on iPhone SE / home-button phones (Control Center opens by swiping up from the bottom) — Features/Workout/Shared/MoveGuidance.swift:121 — branch on device (safe-area bottom inset == 0 → "Swipe up from the bottom edge of your screen.") or word it for both.

## Me screens at XXL
- [Important] se-xxl/me-notifications-xxl.png, se-xxl/me-acknowledgements-xxl.png — titles and labels break mid-word: "Notification/s", "Acknowled/gements", "Phosph/or Icons", "Walk remin/der" — ScreenHeader.swift:10-13 (screenTitle at accessibility3), AcknowledgementsView.swift:13-16 (chip beside title), NotificationSection.swift:16-18 (label beside On/Off toggle) — cap screen title with `.dynamicTypeSize(...DynamicTypeSize.accessibility1)` or `.minimumScaleFactor(0.7)`+`lineLimit`, hide the chip at accessibility sizes (like IconCardRow), stack toggle under its label at accessibility sizes.
- [Important] se-xxl/me-set-aside-xxl.png — whole screen loses its side margin: title and card start at x≈6 pt instead of 20 pt, card almost touches the right edge (content wider than screen) — Features/Me/SetAsideSection.swift:30-32 (`.fixedSize()` pill "Bring it back") — drop `.fixedSize()` in the stacked branch / allow the pill to wrap.

## Cancel guide
- [Important] se-xxl/cancel-guide-xxl.png — hand illustration overflows its 64 pt box and covers the end of "Tap the button below" — Design/Components/IllustrationPlaceholder.swift:10,17,21 (`@ScaledMetric` 56 pt symbol in fixed 64 pt height) — clamp symbol size to `height * 0.7` (or don't scale) and `.clipped()`.

## All sessions
- [Important] se-light/all-sessions.png, ip11-light/all-sessions.png, promax-dark/all-sessions-dark.png, se-xxl/all-sessions-xxl.png — "Your favourites" is British spelling in an en-US app (also VoiceOver "Add … to favourites") — Features/Sessions/AllSessionsView.swift:20, SessionCard.swift:80 (+ Localizable.xcstrings) — "Your favorites" / "favorites".

## Weekly check-in
- [Important] se-light/weekly-checkin.png, ip11-light/weekly-checkin.png, promax-dark/weekly-checkin-dark.png, se-xxl/weekly-checkin-xxl.png — title "This week felt…" and subtitle "About last week." contradict each other — Features/WeeklyCheckIn/WeeklyCheckInView.swift:18 — "Last week felt…" + "A quick look back. You can skip this."

Không thấy lỗi tràn/che/tương phản khác trên promax-dark (Today, Me, sheets) và ip11-light ngoài các mục trên.

Checked 132 images

## Fix log (agent B, branch local/m5-fix-b, commit cdd8f15)
- [Critical] Delete confirm XXL → FIXED: MeSections.swift DeleteDataConfirmation = ViewThatFits(vertical) { spaced layout ; ScrollView } — full text + both buttons readable (re-shot promax XXL + dark normal).
- Done card link contrast → FIXED: TextLinkButtonStyle gets `color` (default text); done card links use onStrongFill (pair "label on secondary" already in Palette.textPairs, 5:1). Still-open link aligned with card text (padding 0).
- today-fewer-reminders capture → FIXED: AppCaptureScene seeds 5 consecutive 8:15 walks (days 1–5 ago); card "Want fewer reminders?" now shows.
- Watch on TV step 1 → FIXED: "Open Control Center: swipe down from the top-right corner. On a phone with a Home button, swipe up from the bottom edge." (VI updated).
- Me set aside XXL margins → FIXED: SetAsideSection `.fixedSize()` only in the side-by-side branch; stacked pill may wrap.
- Cancel guide illustration XXL → FIXED: IllustrationPlaceholder symbol capped at 60 % of panel height + clipped.
- Me XXL mid-word breaks (non-ScreenHeader parts) → FIXED: OnOffToggleStyle stacks label / word+switch at accessibility sizes (one VoiceOver switch via accessibilityRepresentation); "How often" pills stack at accessibility sizes; Acknowledgements chip hidden at accessibility sizes. Screen titles (ScreenHeader) + ClosableHeader title breaks → left to gf-fix-d.
- favourites → favorites (UI + VoiceOver labels); also "Grey dots" → "Gray dots" (TodayCards). Code identifiers unchanged.
- Minor fixed: moved-up line → "New walking level: In place. Seated is still one tap away."; trial-ended title glued with NBSP ("Free walk of the / day · 14 min", no dangling dot); "Moves set aside", "How to cancel", "Cancel it" links padding 0 (aligned).
- Not done: Today Start on SE 68–82 % (owner decision pending, unchanged); today-dark pinning (fixed on main by players agent in RootView); weekly check-in wording (gf-fix-d); SE scrolled-to-card captures (capture-script work, not done).
- Checks: VI 1069/1069, apply --check 0 problems, copy_lint 0, core swift test 279 ✔, app xcodebuild test 285 ✔, ReleaseContentTests ✔. Re-shots (promax only): scratchpad/fixb/shots, shots2. SE-size re-check of set-aside/delete/trial-ended still needed (no SE sim used).
