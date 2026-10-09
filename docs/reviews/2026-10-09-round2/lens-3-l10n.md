# Round 2 · Lens 3 — Localization (en-US source, vi)

_09/10/2026 · read-only review. IDs are numbered across the whole round-2 report._

## Verdict
**Pass with notes** — 0 Critical, 0 Important, 7 Minor (M27–M33). Every key added since round 1 has a correct Vietnamese value, placeholders match, nothing visible is missing from the catalog. One small regression (monthly price format).

## What was run / read
- `python3 iOS/scripts/xcstrings_coverage.py iOS/App/Localizable.xcstrings en,vi` → en missing 0, needs_review 0; vi missing 0, needs_review 0. Same for `InfoPlist.xcstrings` → 0 / 0.
- `python3 tools/i18n/apply_catalog.py vi --check` → "vi: 1089 of 1089 UI keys translated; 0 missing; 0 problems".
- `python3 tools/lint/copy_lint.py` → 0 findings.
- `python3 tools/i18n/scan_literals.py` (read-only without `--json`): 58 candidates, all non-UI.
- A literal-to-catalog check over the changed Swift files (every `Text`/`Button`/`String(localized:)` literal has a key with a `vi` value); a Foundation script formatting distance, duration, list, currency and date in en_US, vi_VN, vi_US.
- Read: new `docs/i18n/vi/ui-extra-18/20/21/22.json` (30 keys), `docs/i18n/glossary-vi.md`, Paywall/*, Store/*, StageRecapText/Views, ProgramView, ProgramFinishedView, Today/*, Progress tiles, Journey/*, StoreNotice, Plural, DistanceText, AppLanguage; `appstore/metadata-json/en.json`, `GentleWalk.storekit`, `site/privacy.html`.
- Limits: no simulator; no Vietnamese capture of the stage-recap screens exists.

## Findings

### Minor
M27 [L10n] [Minor · likely] iOS/App/Features/Paywall/PaywallModel.swift:160,171-173 — **regression**: the yearly card's "$4.17 a month" is now formatted with the device locale (`Locale.autoupdatingCurrent`), while the billed price beside it is the store's `localizedPriceString` (RevenueCatBackend.swift:97) · app language/region ≠ storefront, e.g. Vietnamese on a US storefront: "$49.99" next to "4.17 $ mỗi tháng" (vi_US) or "4,17 US$" (vi_VN) · before RevenueCat both used the product's own format style · fix: carry the store's price locale/formatter in `StoreOffer` (RevenueCat `StoreProduct.priceFormatter`) and format the monthly figure with it.
    Evidence: `(49.99/12).formatted(.currency(code:"USD").locale(…))` → "$4.17" en_US, "4,17 US$" vi_VN, "4.17 $" vi_US.

M28 [L10n] [Minor] iOS/App/Features/Program/StageRecapText.swift:75 (same pattern: iOS/App/Features/Journey/JourneyRouteList.swift:42,142, iOS/App/Features/Workout/Complete/CompleteContent.swift:44) — "Next stop: X · 0.0 mi to go" when 0 < miles < 0.05 (guard is `miles > 0`, text has one decimal); remainders this small are common (fractional active minutes, real outdoor distance) · fix: one shared rule for the three places (`>= 0.05`, or round up to 0.1).

M29 [L10n] [Minor] iOS/App/Features/Today/TodayModel.swift:469,471 — "1 rest days are part of the plan" / "0 rest days …" when a Pro user saves 1 or 0 rest days (MeSections.swift:211-215 allows it); keys `%lld of %lld active days so far · %lld rest days are part of the plan` and `%@ this week · %lld rest days…` have no inflection/plural variation · fix: `^[\(n) rest day](inflect: true)` and drop the clause at 0 (Vietnamese is fine).

M30 [L10n] [Minor] iOS/App/Features/Journey/JourneyListView.swift:51 — `String(localized: "The first leg, to \(end.name), is free.") + " " + kept` joins two localized sentences with `+` and a fixed space · breaks the project rule "interpolation, never `+`" and languages without spaces between sentences · fix: one key with two placeholders, or two `Text` lines.

M31 [L10n] [Minor] iOS/App/Features/Root/StoreNotice.swift:25, iOS/App/Features/Permissions/SystemPermission.swift:29, iOS/App/Features/Me/MeSections.swift:279,292,435, iOS/App/Features/Outdoor/OutdoorPrepView.swift:151 — six keys say "iPhone" ("Your plan is back on this iPhone.", "Reminders are off on this iPhone.", "Location is off for %@ on this iPhone.", "Auto follows your iPhone…", "Reduce motion follows your iPhone setting…", "Next, iPhone asks about location") while the app ships for iPad too ("Made for iPhone and iPad" in the store text) · fix: "on this device"/"this iPad" by idiom, or neutral wording ("Your plan is back."), EN + VI.

M32 [L10n] [Minor] key `So far` (EN, iOS/App/Features/Program/StageRecapViews.swift:93) · vi "Đến giờ" (docs/i18n/vi/ui-extra-21.json:10) — as a bare heading over stage-only numbers, EN "So far" can be read as the whole plan (Today's headline shows whole-plan totals), and VI "Đến giờ" first reads as "it's time (to…)" ("đến giờ tập") · fix: EN "This stage so far", VI "Tính đến nay" / "Giai đoạn này đến nay".

M33 [L10n] [Minor · likely] iOS/App/Features/Program/StageRecapText.swift:56-58 — EN "Your 2-week check: 8" gives a bare number, while VI adds the unit ("Tự kiểm tra 2 tuần: 8 lần"); it appears on the Today stage card and on every stage of Program, away from the self-check explanation ("8 what?") · fix: EN `Your 2-week check: ^[\(n) sit-to-stand](inflect: true)`; VI unchanged (glossary: sit-to-stand = lần ngồi–đứng).
    Evidence: SCR/link/shots3/program-recaps.png, today-stage-recap.png.

(The Restore error text — every failure says "check your connection" — is listed once, as M2 in lens 1.)

## Checked and OK
- New keys (ui-extra-18/20/21/22, 30 keys): all have Vietnamese, placeholders match, glossary terms used ("giai đoạn", "hành trình", "điểm dừng", "Tự kiểm tra 2 tuần", "ngày vận động", "lộ trình" as in 6 existing keys), no fall/bone/pain words.
- Plurals: `^[%lld stop](inflect: true)` and the active-days inflection (Design/Plural.swift:31-33); other new `%lld` keys are stage numbers or bare counts that need no plural; Vietnamese has none.
- Formatting: durations `.units(.abbreviated)` ("1 hr, 44 min" / "1 giờ, 44 phút"); lists `.list(type: .and)`; distance through `Measurement` in the unit chosen in Me (mi/km), decimal comma only with a Vietnamese region; dates via `.dateTime` styles.
- 0/1/2 edges in the recaps: miles < 0.05 hidden; whole-route "0.0 mi" fallback unreachable (ProgramFinishedView.swift:43 guard); check gain only when up; up to 3 stops named, more counted; `fromTo` needs 2 distinct stops.
- Mechanics: stop names from localized content (StageRecaps.swift:104); stage titles `LocalizedStringResource`; recap text built in `body`; language changes on relaunch (AppLanguage.swift:56-62), so per-launch caching is fine; `.uppercased()` only on the brand name.
- PaywallNotice: 5 lines EN/VI, calm and accurate per reason; "tap Restore" matches the button ("Khôi phục").
- In-app privacy text EN = VI, incl. the RevenueCat sentence; "Tôi → Xoá toàn bộ dữ liệu của tôi" matches the real labels; consistent with `site/privacy.html`.
- Store text: "Good Footing Pro", trial length never typed (read from the store), renewal/cancel wording matches `CancelNote`, Pro wording matches the app.

## Needs the owner / a real device
- Vietnamese captures (SE) of today-stage-recap, program-recaps, program-finished-route, journey-with-stages (long VI lines such as "Giờ bạn đang ở giai đoạn 2 · Khoẻ dần…" unseen).
- Purchase product display names exist only in English (`.storekit` en_US, ASC sync config): Apple's purchase sheet shows "Good Footing Pro Yearly/Lifetime" in English to Vietnamese users — add Vietnamese names in App Store Connect if Vietnamese users will buy (app availability is US-only for now).
- Rename readiness: 4 Vietnamese values type "Good Footing" where the English key has none (new: the RevenueCat line, docs/i18n/vi/ui-extra-20.json:3-5); docs/design/doi-ten-app-checklist.md:28,208 still says 3.
- Are 0 or 1 rest days allowed for Pro by design (decides M29: plural only, or a rule too)?
