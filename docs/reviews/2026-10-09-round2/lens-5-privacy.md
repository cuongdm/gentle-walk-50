# Round 2 · Lens 5 — Privacy & security

_09/10/2026 · read-only review. IDs are numbered across the whole round-2 report._

## Verdict
**Pass with notes** — 0 Critical, 0 Important, 2 Minor (M34–M35). No secret in the repo or its history; the manifest matches what RevenueCat does. The repo being **public** is the main exposure: a list of what to consider making private is at the end (nothing was deleted).

## What was run / read
- Secret scan of the working tree and the full history: `git grep` for `appl_…`, `sk_…`, private-key headers, `AKIA…`, `ghp_…`, `xox…-`, API-key assignments; `git log --all -p -S "appl_"`; `git log --all -- iOS/Config/Local.xcconfig`.
- `iOS/App/PrivacyInfo.xcprivacy`; RevenueCat 5.94.0's own manifest (`purchases-ios-spm/Sources/PrivacyInfo.xcprivacy` in the Mac's DerivedData, `plutil -p`); `Info.plist`; `GentleWalk.entitlements`; `iOS/Config/Shared.xcconfig`, `Local.xcconfig.example`; `.gitignore`.
- Code: `RevenueCatBackend.swift`, `StoreService.swift`, `PaywallLegalFooter.swift` (in-app privacy text), `StoreNotice.swift`, `DataEraser.swift`, `ModelContainerFactory.swift`, `LocationService.swift`, `AppModel+Personalisation.swift`; every `Logger`/`print` call outside `App/Debug`.

## Findings

### Minor
M34 [Privacy] [Minor] iOS/App/Features/Paywall/PaywallLegalFooter.swift:114-116 (+ `appstore/metadata-json/en.json` "Your answers and workouts stay on your iPhone") — the in-app privacy text says her answers, workouts and pain reports "are stored only on this phone", but the SwiftData store (Persistence/ModelContainerFactory.swift:8-17, default location, not excluded from backup) and UserDefaults are part of her own iCloud/computer device backup · not "collection" for the App Privacy label (the developer cannot read it) and keeping it in backups is right (phone migration), but the sentence is absolute on the screen that is supposed to be exact · fix: "…are kept on this phone (and in your own iPhone backup, if you use one). The app never uploads them." — EN + VI + `site/privacy.html`.

M35 [Privacy] [Minor · likely] iOS/App/Features/Root/StoreNotice.swift:29 — after "Delete all my data" the notice says "Everything is deleted from this phone.", but RevenueCat's anonymous app user ID and cached purchase record stay (the SDK's own UserDefaults, not in `AppDefaultsKeys` — on purpose, so Pro survives), and RevenueCat keeps the purchase history on its servers · fix: "Your data is deleted from this phone. Your plan stays with your Apple Account."; add one line to the privacy text on how to ask for the purchase record to be deleted (support email). (Erase also leaves delivered notifications on screen — M8 in lens 1.)

## Checked and OK
- **No secrets:** only the placeholder `appl_XXXX…` (Local.xcconfig.example:7) and a test literal (StoreServiceTests.swift:373); `iOS/Config/Local.xcconfig` is git-ignored and was never committed; ASC API keys only as environment-variable placeholders in `tools/appstore/*`; no `.p8`, no tokens.
- **RevenueCat key handling:** only from `Local.xcconfig` → `$(REVENUECAT_PUBLIC_KEY)` in Info.plist; Release accepts only public `appl_` keys (RevenueCatBackend.swift:12-21), never a secret `sk_` key; missing key → free plan, no crash, release gate red.
- **Manifest:** `NSPrivacyTracking` false, no tracking domains, Purchase History (not linked, not tracking, App Functionality + Analytics), UserDefaults CA92.1. RevenueCat's manifest declares Purchase History (App Functionality) + UserDefaults CA92.1 — covered by the app's own declaration. No other third-party SDK.
- **SDK configuration:** anonymous ID, no `logIn`; `automaticDeviceIdentifierCollectionEnabled(false)`; `logLevel .error` in Release (`.info` only in Debug). The IDFV-in-header question is already an owner decision (docs/todo.md, checklist §3).
- **Logs:** only plan IDs and error codes are `.public` (StoreService.swift:105-120); cue logs carry content IDs; no personal or health data logged.
- **Health data stays on the device:** busy-day answer cached in memory only (AppModel+Personalisation.swift:14-17,167-179); `cloudKitDatabase: .none`; nothing health-related in RevenueCat calls; in-app privacy text EN = VI and says so, incl. RevenueCat.
- **Location:** When-In-Use only, background updates on during an outdoor walk and off after (LocationService.swift:74,83); purpose string concrete.
- **Transport:** no ATS exceptions in Info.plist.
- **Erase:** every UserDefaults key the app writes is in `AppDefaultsKeys.all` except the two language keys (M9, lens 1), incl. the new `programPauses` and `stageRecapSeen`; all 9 SchemaV2 models deleted.

## Public repo — what to consider making private (nothing deleted; owner decides)
1. **Business strategy and numbers:** `docs/research/2026-10-03-kiem-tien-dinh-vi-doi-thu.md`, `2026-10-03-quang-cao-nam-dau.md`, `2026-10-08-kha-nang-chi-tra-va-kiem-tien.md`, `2026-10-04-tom-tat-thi-truong.md`, `reports/`, `research_notes/`, `docs/todo.md` (loss limits, ad budget, price tests), `app-context.md` decisions log.
2. **Third-party data:** `docs/research/data/2026-10-03-niche-apps.csv` + `2026-10-03-review-analysis.txt` (competitor revenue estimates / review analysis — check the data source's terms), `docs/research/competitors/{chillfit,lazyfit}/` (776 KB of competitor screenshots), `docs/research/competitors-ui-reference.md`.
3. **The whole product content:** `assets/voice/cache-bella-v4` + `cache-vi-bella-v4` (1,362 coach lines), `assets/voice/cache` (72 ElevenLabs **Free-plan** lines — that plan is non-commercial with attribution, so publishing them is a licence question), `assets/video` (AI clips + 1080 masters), `assets/music/test` (Lyria), `iOS/App/Resources/Media` (bundled voice/video/music), `docs/scripts` (every script and generation prompt). Anyone can copy the app's content today.
4. **Personal details:** owner's legal name (`docs/release/1.0/asc-listing-fields.md:74`), personal e-mail (`iOS/App/Features/Paywall/PaywallModel.swift:181` `LegalLinks.supportEmail`, handoff files), another app's name (`docs/release/1.0/revenuecat-setup.md:22`), commit e-mail addresses in the git history.
5. **Operational:** `docs/release/1.0/revenuecat-setup.md`, `purchase-troubleshooting.md`, `tools/appstore/*` (safe: keys come from the environment).
- Note for Việc 1 (site pages): GitHub Pages from a **private** repo needs a paid GitHub plan. If this repo goes private, publish `site/` from a small separate public repo (or another host / the custom domain).

## Needs the owner
- Decide repo visibility (list above) before more assets or research are pushed.
- Confirm `cuongdm@live.com` as the public support address (it is compiled into the app as `LegalLinks.supportEmail`).
- Confirm the privacy wording for M34/M35 (also used on `site/privacy.html`).
