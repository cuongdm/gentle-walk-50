# UI không tràn, font, onboarding mới, icon và cá nhân hoá — kế hoạch 08/10/2026

**Goal:** trước 1.0, mọi màn của Good Footing vừa iPhone SE 3 ở cỡ chữ mặc định (hành động chính và lựa chọn an toàn không bao giờ dưới mép), chữ thường sang SF Pro với caption 16 pt và nút 64 pt, onboarding 9 màn + 1 (Welcome · 7 câu hỏi · Plan · Paywall) trên một khung chung có câu HLV đáp tại chỗ và "Hear your coach · 10 seconds", vòng "How did that feel?" lên và xuống cấp đúng, và mọi câu trả lời của bà ấy (mục tiêu, trở ngại, mức vận động, Easier/Harder, chỗ đau theo bài, tự kiểm tra, lịch sử) thật sự đổi buổi tập và lời HLV (P1–P13). Mọi màn có icon + chữ và không nhàm chán (milestone 3, theo tài liệu icon đang viết).
**Architecture:** logic mới đặt trong `GentleWalkCore` (adaptation theo cấp hiện tại, hồ sơ onboarding, luật đau theo bài, trí nhớ Easier, check-in tuần, câu HLV theo lịch sử), test trước bằng `swift test`. App: một `OnboardingStepScaffold` dùng cho mọi bước; `WalkLevelStore`, `ExerciseMemoryStore`, `WeeklyNoteStore`, `PreviewChoiceStore` là UserDefaults kiểu `SupportLadderStore` (không SchemaV3); hai màn quyền riêng qua `AppCover.permissions(PermissionAsk)`; màn vị trí: chọn cách đo trước, rồi một nút "Continue" mở hộp thoại iOS; "Hear your coach" là một `AVMutableComposition` (2 câu A1 có sẵn) phát bằng một `AVPlayer`, không âm im lặng. Giao diện chụp bằng hook `-ScreenshotMode` duy nhất, trên iPhone SE 3 · iPhone 11 · iPhone 17 Pro Max, sáng/tối/XXL và bản Việt.
**Tech stack:** Swift 6 · SwiftUI · SwiftData (SchemaV2 giữ nguyên) · AVFoundation · UserNotifications · StoreKit 2 · Swift Testing · XcodeGen · Python 3 tools (content, i18n, voice qua Vibi).
**Deployment target:** iOS 18.0 (iPhone + iPad) · Xcode 27 / SDK 27 — không API mới hơn iOS 18 (`containerRelativeFrame` là iOS 17, dùng được).
**Locales:** en-US, vi · RTL: không · Chữ mới: `docs/i18n/vi/ui-extra-9.json`.
**Inputs read:** CLAUDE.md (3 cấp), app-context.md (08/10), docs/plans/2026-10-08-steady-program.md (mẫu), docs/design/research-2026-10-08/{tong-hop, ui-ux-va-onboarding, font-va-hinh-anh}.md + mockups (3 bảng ghép SE đã xem), docs/research/2026-10-08-ca-nhan-hoa.md, /Users/cuong/CascadeProjects/MeowBreath/docs/reviews/2026-10-07-onboarding-app-review.md, docs/todo.md, docs/i18n/README.md; code: `Typography.swift`, `Tokens.swift`, `ButtonStyles.swift`, `OnboardingFlow/View/Copy/Motion/QuestionViews/BodyLimitChips/PlanReadyView/WelcomeView.swift`, `OnboardingProfile.swift` (core), `Adaptation.swift`, `TodayModel.swift`, `TodayCards.swift`, `TodayView.swift`, `AppModel*.swift`, `AppCover.swift`, `CoverView.swift`, `PaywallView/Model.swift`, `PermissionsView/Model.swift`, `OutdoorPrepView.swift`, `SelfCheckViews.swift`, `SelfCheckAudioPlayer.swift`, `VoiceSource.swift`, `SessionBuilder.swift`, `ChairSessionPlanner.swift`, `PainRules.swift`, `RepLadder.swift`, `SessionCompletionService.swift`, `WorkoutRequest.swift`, `WorkoutPreviewModel/View.swift`, `CompleteView/Content.swift`, `SoundControls.swift`, `AllSessionsView.swift`, `SessionTile.swift`, `PhonePlacementView.swift`, `ProgressScreen.swift`, `MeSections.swift`, `SchemaV2.swift`, `DataEraser.swift`, `CaptureHook.swift`, `AppCaptureScene.swift`, `CaptureHookTests.swift`, `OnboardingFlowTests.swift`, `AdaptationTests.swift`, `DesignTokenTests.swift`, `ReleaseContentTests.swift`, `voice-lines.json` (620 câu; `a9.*` đã có file), `sessions.json` (`ses.firstWalk` mở bằng `a1.01`, `a1.02`, `a1.03`), `en-US.json` fixture, `capture_states.sh`, `project.yml`.
**Checkpoint (08/10/2026, chủ app chốt, "làm hết, dứt điểm"):** font A1 · onboarding theo đề xuất chuyên gia nhưng **giữ** "How active are you now?" (ACSM pre-participation) và dùng nó thật · paywall ở lại onboarding + "Hear your coach" trên thẻ Day 1 · làm cả 5 đợt (0 lỗi, 1 không tràn + font, 2 onboarding, 3 icon/chống nhàm chán, 4 cá nhân hoá P1–P13, 5 kiểm chứng) · credit Vibi cho P7 đã duyệt · màn vị trí: chọn cách đo trước, mồi quyền một nút.
**Ngoài phạm vi:** font đóng gói (B1/B2) · SchemaV3 · đo lường từ người dùng thật (không backend) · bộ tự đếm ngồi–đứng · tai chi · iPad làm lại bố cục (chỉ chụp kiểm tra `readableWidth`).

## Sub-skill đã dùng khi lập kế hoạch
| Bước | Skill | Đã dùng |
|---|---|---|
| Kiến trúc | `swiftui-specialist` (structure, dataflow), `swiftui-whats-new-27` | một `struct: View` mỗi phần; `@Observable` input hẹp; không tính trong `body`; `@State` macro SDK 27 |
| Tuân thủ | `app-store-review-agent`; MeowBreath review 07/10 (HIG Pre-alert screens, 5.1.1(iv), 4.5.4) | bảng Compliance dưới |
| Mẫu UI | `mobbin-ux-patterns` (A3 Ro/Ada quiz; smart defaults; goal gradient; reciprocity) | khung onboarding, "nghe HLV trước paywall" |
| Test trước | `test-driven-development` | mọi task [TDD] có bước RED → GREEN |

## Lệnh dùng chung
| Tên | Lệnh | Kết quả mong đợi |
|---|---|---|
| `CORE <Suite>` | `cd iOS && swift test --package-path Packages/GentleWalkCore --filter <Suite>` | RED: `error: cannot find '<Type>' in scope` / `Expectation failed:` · GREEN: `Test run with N tests in M suites passed` |
| `APP <Suite>` | `cd iOS && xcodebuild test -project GentleWalk.xcodeproj -scheme GentleWalk -destination 'id=558F034D-7FF9-42AF-9612-50FFA68E6B91' -only-testing:GentleWalkTests/<Suite>` | `** TEST SUCCEEDED **` |
| `BUILD` | `cd iOS && xcodegen generate && xcodebuild build -project GentleWalk.xcodeproj -scheme GentleWalk -destination 'id=558F034D-7FF9-42AF-9612-50FFA68E6B91' -derivedDataPath /tmp/gw-dd SWIFT_EMIT_LOC_STRINGS=YES` | `** BUILD SUCCEEDED **`, 0 error (bản build này cũng là nguồn trích chuỗi) |
| `SHOT <device> <state>[@dark|@xxl] …` | `lockf -k /tmp/gentlewalk-sim.lock iOS/scripts/capture_states.sh docs/design/shots-2026-10/<device-tag> <device-udid> <state>…` | file PNG + inspect bằng mắt: không "…", không cuộn ngang, nút chính trong màn, vùng chạm ≥ 56 pt |
| `SHOT-VI` | như `SHOT`, thêm `-AppleLanguages "(vi)" -AppleLocale vi_VN` (sửa `capture_states.sh` nhận biến `LANG_ARGS`, task 5.6) | PNG bản Việt |
| `SIM-SE` / `SIM-11` | `lockf -k /tmp/gentlewalk-sim.lock xcrun simctl create "GF SE3 tmp" "iPhone SE (3rd generation)"` · `… create "GF 11 tmp" "iPhone 11"` → dùng xong: `xcrun simctl shutdown <udid> && xcrun simctl delete <udid>` | tối đa 2 máy ảo chạy: Pro Max `558F034D…` + **một** máy tạm; xong SE mới tạo 11 |
| `EXTRACT` | ngay sau `BUILD` (chưa chạy `xcodebuild test` ở giữa): `python3 tools/i18n/extract_sources.py /tmp/gw-dd` | `ui.json <N> khoá` |
| `L10N` | `python3 tools/i18n/apply_catalog.py vi && python3 tools/i18n/apply_catalog.py vi --check && python3 iOS/scripts/xcstrings_coverage.py iOS/App/Localizable.xcstrings en,vi && python3 tools/i18n/scan_literals.py && python3 tools/lint/copy_lint.py` | `0 missing; 0 problems` · coverage `missing: 0 needs_review/new: 0` (en, vi) · không chuỗi lạ · `0 findings` |
| `PY <file>` | `python3 -m unittest <file>` | `OK` |
| `RELEASE` | `cd iOS && RELEASE_CHECK=1 xcodebuild test … -only-testing:GentleWalkTests/ReleaseContentTests` | `** TEST SUCCEEDED **` |

Mọi lệnh simulator (create/boot/launch/screenshot/delete) bọc trong `lockf -k /tmp/gentlewalk-sim.lock`. Thư mục ảnh: `docs/design/shots-2026-10/{se3,i11,promax}/` (git-ignore nếu > 50 MB; giữ bảng ghép nhỏ trong `docs/design/research-2026-10-08/after/`).

## Decisions (một dòng mỗi quyết định)
- **Cấp đi bộ hiện tại lưu ở UserDefaults (`WalkLevelStore`: level, changedAt, pendingCard), cột `startLevel` giữ nghĩa "cấp khởi đầu":** chọn thay vì cột `currentLevel` ở SchemaV3 — vì một giá trị nhỏ, có tiền lệ (`SupportLadderStore`), "Delete all my data" đã quét `AppDefaultsKeys`, không đụng migration trước 1.0; Me vẫn hiện "Started seated · In place since 20 Oct".
- **Adaptation tính trên cấp hiện tại và chỉ đếm buổi sau lần đổi gần nhất:** sửa `Adaptation` nhận `LevelState(level:changedAt:)`; quyết định đổi cấp xảy ra lúc ghi "How did that feel?" (`SessionCompletionService.recordFeeling`), không trong `reload()` — để Today, Preview và Me cùng thấy một cấp và thẻ `.movedUp`/`.movedDown` hiện đúng một lần (tới buổi kế hoặc 7 ngày).
- **Font A1:** `TypeRole.design` = `.serif` cho `screenTitle`, `.rounded` cho `phaseLabel/timer/transition/stat/wallClock`, `.default` cho `cardTitle/body/button/caption`; caption 16 pt neo `.callout`; `lineSpacing(2)` cho body và screenTitle; timer weight medium; `Metrics.buttonHeight` 64; `secondary` sáng `#54722F` (trắng trên nền ≈ 5,5:1), `accent` sáng `#8F4323` cho chữ nhỏ tab; `readableWidth` 620.
- **Khung onboarding chung (`OnboardingStepScaffold`):** header (Back có chữ · "Step n of 7" · đường đi) → tiêu đề ≤ 8 chữ ≤ 2 dòng → **ô HLV cố định 2 dòng** (gợi ý ≤ 15 chữ, sau khi chọn thành mặt HLV + câu đáp ≤ 14 chữ, không đẩy nội dung) → vùng chọn ≤ 7 lựa chọn → Continue **ghim** (trừ cỡ trợ năng: cuộn, nút ở cuối). Ngân sách chữ được test (`OnboardingCopyBudgetTests`).
- **Thứ tự bước:** `welcome, goal, barriers, name, activity, chair, soreSpots, anythingElse, plan, paywall` (7 câu hỏi). Bỏ `.understanding` (câu thấu hiểu thành câu HLV đáp ở barriers và 2 dòng "why" trên Plan); `.body` tách `soreSpots` (Knees · Hips · Lower back · Shoulders · Joint replacement · None) và `anythingElse` (Can't get down on the floor · Standing long is hard · I get dizzy easily · I feel unsteady on my feet · No jumping · None) với câu bác sĩ ngay trên Continue trong vùng ghim.
- **Goal chọn 1:** `OnboardingFlow.maxGoals = 1`, cột `goals: [String]` giữ nguyên (một phần tử); `OnboardingProfile.primaryGoal` dùng lại ở Plan (phụ đề), paywall (tiêu đề phụ + dòng lợi ích đầu), Today (dòng dưới thẻ buổi), Complete (1 dòng), Progress (thẻ "Your goal"), Me (đổi được).
- **"How active are you now?" giữ và dùng:** `startLevel` như cũ (active ∧ chair Easy ∧ đứng được → In place); thêm `OnboardingProfile.startIntensity` (`mostlySit` → `.gentle`, còn lại `.steady`) làm check-in mặc định 10 buổi đầu và `startsShorter` (`mostlySit` → đi bộ ngắn hơn 2 phút trong 2 tuần đầu, thẻ "A shorter start, as you asked"). Đọc từ cột `activityLevel` đã có, không thêm cột.
- **"Hear your coach · 10 seconds":** `CoachPreviewPlayer` ghép `a1.01` + `a1.02` (6,1 + 4,7 s, đã thu EN và VI) bằng `SessionAudioComposer.compose` (voice only, không nhạc, không chuông) → một `AVPlayer`; `AudioSessionConfigurator.apply(.guided)` lúc bấm, `deactivate()` khi xong/rời màn; không bật background audio ở onboarding; nút đổi thành "Stop" khi đang phát; bản Việt qua `VoiceSource` theo `AppLanguage`.
- **Paywall:** giữ bố cục và bộ ba tuân thủ; `PaywallModel` nhận `goal` và `barriers` để xếp 3 dòng lợi ích (dòng đầu theo goal; `charged` đưa dòng thời gian lên ngay dưới tiêu đề; `bored` đưa hành trình lên); SE: tiêu đề 2 dòng, hàng gói 52–56 pt, timeline 1 dòng/mốc, "Or keep the free plan…" dưới gói, cả 3 gói trong tầm mắt.
- **Quyền:** hai màn, mỗi màn một quyền, cùng khung; nút chính không dùng chữ "Allow": "Set my reminder" (đặt giờ + mở hộp thoại) và "Connect Apple Health"; "Not now" giữ (luật dự án) + Review Notes; luồng Complete → Reminder → Health → Today.
- **Vị trí ngoài trời:** màn 2 của Outdoor prep thành **chọn cách đo** ("Map and distance" / "Steps only", hai thẻ chọn + Continue); chọn Map → màn mồi **một nút** "Continue" → hộp thoại iOS; Don't Allow → tự rơi về Steps, không hỏi lại; đổi ở Me → Outdoor.
- **Trí nhớ cá nhân hoá ở UserDefaults, Codable, qua `DataEraser`:** `ExerciseMemoryStore` (Easier theo bài, bài tạm bỏ, bài bật lại), `WeeklyNoteStore` (câu trả lời tuần, ≤ 24 bản ghi gần nhất), `PreviewChoiceStore` (cấp và swap ở Preview) — không SchemaV3 trước 1.0.
- **Câu HLV mới chỉ cho P7:** kịch bản `A13` thu nguyên câu có số (không ghép số rời) qua Vibi EN (`bella-v4`) và VI (`bella-v4-vi`); P1 dùng 7 câu `a9.*` đã có; mỗi buổi tối đa 1 câu "lịch sử", đặt ở mở đầu.
- **Icon:** mọi lựa chọn, hàng cài đặt, thẻ Today/Complete/Progress có SF Symbol + chữ, một nghĩa một symbol, qua `IconMap` (enum trung tâm) và test không trùng nghĩa — chi tiết theo `icon-va-chong-nham-chan.md` (milestone 3).
- **Không tuyên bố y khoa, không hứa phòng ngã, chỉ so với chính mình:** mọi chuỗi mới qua `copy_lint.py` (đã có cụm cấm từ 08/10) và `docs/design/steady-claims.md`.
- **Analytics/backend:** không. **Android:** sau.

## Quyết định mặc định đã chọn (chủ app có thể đổi)
| # | Câu hỏi mở (nguồn) | Mặc định đã chọn | Lý do ngắn |
|---|---|---|---|
| D1 | Lưu cấp hiện tại: đổi nghĩa `startLevel` hay cột mới (cá nhân hoá Q1) | UserDefaults `WalkLevelStore`, `startLevel` giữ nghĩa cũ | luật "ưu tiên UserDefaults/cột có sẵn"; không migration |
| D2 | "Lose some weight" giữ trong 7 mục tiêu? (UI Q2) | Giữ, đổi câu đáp thành "Short daily walks add up, at your pace." (không số, không hứa) | app không cân; bỏ thì người chọn nó không thấy mình |
| D3 | Câu nào cho "Hear your coach", có bản Việt? (UI Q3) | `a1.01` + `a1.02`; có bản Việt (đã thu) | 10,8 s, đúng câu bà ấy sẽ nghe ở buổi đầu |
| D4 | Câu bác sĩ ở đâu (UI Q4) | Chỉ ở màn "Anything else", trong vùng ghim trên Continue (16 pt) | một chỗ, không bị cuộn mất |
| D5 | "Not now" ở 2 màn quyền (UI Q5, MeowBreath #9) | Giữ "Not now"; nút chính "Set my reminder" / "Connect Apple Health"; Review Notes | thông báo/Health không trong phạm vi HIG pre-alert; vị trí thì đổi sang một nút (D6) |
| D6 | Màn vị trí (UI 6.1) | Chọn cách đo trước; màn mồi một nút "Continue"; Don't Allow = Steps | ca từ chối 5.1.1(iv) 03/2026 là màn vị trí |
| D7 | iPhone SE 3 là máy mục tiêu? (UI Q6) | Có: mọi màn không phải danh sách vừa SE ở cỡ mặc định | iOS 18 còn hỗ trợ SE 2/3; khách 58–75 hay dùng máy cũ |
| D8 | Nhãn nút quyền (HIG "Allow") | "Set my reminder" | đặt tên theo tính năng, không theo quyền (như "Turn on calls" ở MeowBreath) |
| D9 | P3: tạm bỏ bài sau 2 hay 3 báo đau (Q2) | 1 báo đau/14 ngày → bản dễ; **2**/28 ngày → tạm bỏ 4 tuần, có công tắc "Bring it back" ở Me | có đường quay lại nên ngưỡng thấp an toàn hơn |
| D10 | P5-Harder cho Pro (Q3) | Giữ luật 2 buổi (Otago); Harder + làm đủ → trần hôm sau `base + 2` thay `base + 1`, không lên bậc sớm | không vi phạm "2 × 10 mới tăng" |
| D11 | P6 hỏi tuần khi nào (Q4) | Lần mở app đầu tiên từ Chủ nhật tới hết Thứ ba, 2 câu, bỏ qua được; không thông báo riêng | người nghỉ T7–CN mở lại Thứ hai |
| D12 | P7 thu nguyên câu hay ghép số (Q5) | Thu nguyên câu: "Last check, you stood up N times…" N = 3…20; "Week N of twelve." N = 1…12; "That's N active days this week." N = 1…7; "Second/Third/Fourth/Fifth walk this week…" | nghe tự nhiên; chủ app đã duyệt credit |
| D13 | Hỏi lại goal sau 12 tuần (Q6) | Màn Program finished thêm một dòng "Still the same goal? Change it in Me." (link) — không màn mới | nhẹ, không chặn |
| D14 | P8 là thẻ đầu Progress hay màn riêng (Q7) | Thẻ "Your results" ở đầu Progress (4 ô + biểu đồ 8 tuần); Program có link "See how far you've come" trỏ tab Progress | ít màn hơn |
| D15 | Đo từ người dùng thật (Q8) | Không; chỉ bộ đếm DEBUG ở Me → Your plan (tỉ lệ trả lời feeling, số lần đổi cấp, báo đau lặp) | luật không backend |
| D16 | Check-in mặc định sau "Too hard" ×2 | Achy được chọn sẵn + dòng "After last time, we'll keep it gentle. Change it if you like."; bà ấy đổi được một chạm | không ép, nhưng lời hứa "adjust after every session" thành thật |
| D17 | Dark mode cho số lớn (font Q4) | timer/stat weight medium ở cả hai chế độ (một giá trị, không rẽ nhánh) | tránh loá; nhìn ảnh tối ở 5.5 rồi chỉnh nếu cần |
| D18 | Số trạng thái chụp | thêm 17, bỏ 5 (xem danh sách cuối), `CaptureHookTests.coversEveryPlannedState` = **121** (109 − 5 + 17) | cập nhật khi thêm/bỏ |
| D19 | Nhân vật phụ / đàn ông (font Q5) | Không làm trong kế hoạch này (asset); ghi todo | ngoài phạm vi code |
| D20 | Máy ảo tạm | Tạo "GF SE3 tmp" rồi xoá, mới tạo "GF 11 tmp"; không đụng máy ảo của dự án khác ("MB iPhone SE") | luật ≤ 2 máy ảo chạy |

## Compliance tasks (bắt buộc, có bằng chứng)
| Quy tắc | # | Task | File | Bằng chứng |
|---|---|---|---|---|
| Màn mồi quyền: một nút, không "Allow", không ép (HIG Pre-alert; 5.1.1(iv)) | 5.1.1 | 1.6, 1.17 | `PermissionStepView.swift`, `OutdoorPrepView.swift` | ảnh: vị trí một nút "Continue"; Reminder/Health "Not now" + ghi chú Review Notes (5.9) |
| Quyền hỏi đúng lúc, không lúc mở app | 5.1.1 | 1.6 | `AppModel+Flows.workoutClosed` | test `AppFlowTests.permissionsComeAfterFirstSession` vẫn xanh |
| Thông báo không bắt buộc, tắt được, ≤ 1/ngày, không ghi sức khoẻ trên màn khoá | 4.5.4 | 4.9, 4.18 | `NotificationPlanner.swift`, phrase bank | test `weeklyRecapNeverNamesHealth`; câu tuần chỉ số ngày |
| Paywall trio + giá thu nổi bật + điều khoản + Maybe later, cả trên SE | 3.1.1/3.1.2 | 1.5, 2.12 | `PaywallView.swift`, `PaywallLegalFooter.swift` | ảnh SE sáng/tối: Restore · Terms · Privacy, 3 gói, điều khoản, Maybe later trong màn |
| Không tuyên bố y khoa, không hứa phòng ngã (1.4.1) | 1.4.1 | 2.3, 4.3, 4.9, 4.13 | `tools/lint/copy_lint.py`, `steady-claims.md` | `copy_lint` 0 findings; test ngân sách chữ không chứa cụm cấm |
| "Hear your coach" là nội dung thật, không demo giả, không audio nền | 2.3.1 / 2.5.4 | 2.11 | `CoachPreviewPlayer.swift` | test: composition từ 2 file bundled, ≤ 12 s; không `UIBackgroundModes` mới |
| Dữ liệu cá nhân hoá chỉ trên máy; "Delete all my data" xoá hết | 5.1.1 | 0.2, 4.4, 4.5, 4.9 | `DataEraser.swift` (`AppDefaultsKeys`) | test `DataEraserTests.eraseClearsPersonalisationStores` |
| Privacy manifest không đổi (UserDefaults CA92.1 đã có) | 5.1.1 | 5.8 | `PrivacyInfo.xcprivacy` | `grep -c CA92.1` = 1; không API required-reason mới |
| Tương phản ≥ 4,5:1 mọi cặp, sáng và tối | HIG | 1.2 | `Tokens.swift`, Assets | `DesignTokenTests` xanh, cặp chữ nhỏ ≥ 5,0 |
| Review prompt chỉ qua `ReviewPromptPolicy` | 5.6.1 | n/a | — | không đổi |

## Milestones
| # | Tên | Task | Bằng chứng cuối |
|---|---|---|---|
| 0 | Sửa lỗi "How did that feel?" | 0.1–0.6 | core + app test xanh; ảnh `today-moved-up`; cấp hạ được sau "Too hard" ×3 ở cấp mới |
| 1 | Không tràn, font, màu, cỡ | 1.1–1.18 | mọi màn trong bảng audit vừa SE 3 (trừ danh sách được cuộn); `DesignTokenTests` xanh; bảng ghép trước/sau |
| 2 | Onboarding mới | 2.1–2.18 | 10 màn trên khung chung, SE không cuộn, VI chụp, "Hear your coach" phát thật, paywall theo goal |
| 3 | Icon + chống nhàm chán | 3.1–3.11 | theo `icon-va-chong-nham-chan.md` §7; `IconMapTests` xanh; ảnh trước/sau |
| 4 | Cá nhân hoá P1–P13 | 4.1–4.18 | core test xanh; giọng A13 thu EN+VI; mọi tín hiệu trong bảng 1.1 của báo cáo có "Dùng lại" ≠ Không |
| 5 | Kiểm chứng + tài liệu | 5.1–5.10 | `swift test`, `xcodebuild test`, `RELEASE`, `L10N` xanh; bộ ảnh 3 máy × sáng/tối/XXL + VI; danh sách màn được cuộn; app-context, todo, spec cập nhật |

**Thứ tự và tránh đụng file (một agent một vùng):** 0 → 1 → 2 → 3 → 4 → 5, tuần tự. Trong milestone 1, các task 1.4–1.17 sửa file khác nhau nên có thể chia 2 agent (A: 1.4, 1.5, 1.6, 1.7, 1.17 — onboarding/paywall/quyền/self-check; B: 1.8–1.16 — Today/Complete/player/Progress/Me), nhưng `Localizable.xcstrings` chỉ một agent chạm (gom ở 1.18). Milestone 2 chạm `Onboarding/*`, `Paywall/*`, `AppCaptureScene.swift`, `CaptureHook.swift` — không chạy song song với 1. Milestone 4 chạm `TodayModel.swift`, `SessionBuilder.swift`, `ProgressScreen.swift`, `MeSections.swift` — sau 3. `CaptureHookTests.coversEveryPlannedState` chỉ đổi số trong task 0.5, 1.6, 2.14, 4.16 (mỗi lần ghi số mới vào Evidence).

## Tasks

### Milestone 0 — Sửa lỗi "How did that feel?"

### Task 0.1 — Adaptation theo cấp hiện tại, chỉ đếm buổi sau lần đổi [TDD]
**Files:** Modify `iOS/Packages/GentleWalkCore/Sources/GentleWalkCore/Plan/Adaptation.swift` · Test `iOS/Packages/GentleWalkCore/Tests/GentleWalkCoreTests/AdaptationTests.swift`
**Steps:**
1. Test `tooHardAtTheNewLevelStepsBackDown()`: `LevelState(level: .inPlace, changedAt: d0)`; lịch sử 3 `.tooEasy` ở seated (trước d0) + 3 `.tooHard` ở inPlace (sau d0) → `.seated`, card `.movedDown(to: .seated)`. Test `answersBeforeTheChangeDoNotCount()`: 3 `.tooEasy` ở seated trước d0, state seated đổi lúc d0 (vừa hạ) → không lên lại. Test `firstChangeHasNoDate()`: `changedAt == nil` đếm cả lịch sử (hành vi cũ).
2. `CORE AdaptationTests` → RED `cannot find 'LevelState' in scope`.
3. Thêm `public var date: Date?` vào `SessionFeedback` (init mặc định nil); `public struct LevelState: Equatable, Sendable { level, changedAt: Date? }`; `Adaptation.next(state:history:)` lọc `history` theo `$0.level == state.level && (state.changedAt == nil || $0.date == nil || $0.date! > changedAt)`; giữ `next(level:history:)` gọi qua `LevelState(level:changedAt:nil)` để test cũ xanh.
**Command:** `CORE AdaptationTests` → expected: `Test run with 11 tests … passed`
**Evidence:** DONE — baseline trước khi sửa: core 191 tests/40 suites, app 198/44 xanh. RED: `cannot find 'LevelState' in scope` + `extra argument 'date'`. GREEN: `CORE AdaptationTests` → `Test run with 11 tests in 1 suite passed` (3 test mới: tooHardAtTheNewLevelStepsBackDown, answersBeforeTheChangeDoNotCount, firstChangeHasNoDate). `LevelState` là kiểu cấp cao nhất trong core (không lồng trong `Adaptation`).
**Commit point:** `fix(core): adaptation follows the current level`

### Task 0.2 — WalkLevelStore (cấp hiện tại, ngày đổi, thẻ chờ) [DATA]
**Files:** Create `iOS/App/Services/Data/WalkLevelStore.swift` · Modify `iOS/App/Services/Data/DataEraser.swift` (`AppDefaultsKeys`) · Test `iOS/GentleWalkTests/WalkLevelStoreTests.swift` (`@Suite(.serialized)`), `DataEraserTests.swift`
**Steps:**
1. Test `roundTripsLevelAndCard()`, `fallsBackToStartLevelWhenEmpty()`, `DataEraserTests.eraseClearsWalkLevel()`.
2. RED → `@MainActor struct WalkLevelStore { static let defaultsKey = "walkLevel"; init(defaults:); func state(startLevel:) -> Adaptation.LevelState; func set(level:changedAt:card:); var pendingCard: AdaptationCard?; func clearCard() }` (Codable JSON, một khoá).
**Command:** `APP WalkLevelStoreTests` + `APP DataEraserTests` → expected: `** TEST SUCCEEDED **`
**Evidence:** DONE — RED: `cannot find 'WalkLevelStore' in scope`. GREEN: `APP WalkLevelStoreTests` + `APP DataEraserTests` → `Test run with 5 tests in 2 suites passed`, `** TEST SUCCEEDED **`. `AdaptationCard` thêm `Codable` (core) để lưu thẻ chờ; khoá `walkLevel` trong `AppDefaultsKeys`.
**Commit point:** `feat(data): walk level store`

### Task 0.3 — Đổi cấp lúc ghi "How did that feel?" [TDD]
**Files:** Modify `iOS/App/Services/Session/SessionCompletionService.swift` (`recordFeeling` nhận `WalkLevelStore`; ghi `date` vào `SessionFeedback`), `iOS/App/Features/Root/AppModel.swift` (`completion` truyền store) · Test `iOS/GentleWalkTests/SessionCompletionServiceTests.swift`
**Steps:**
1. Test `threeTooHardAtInPlaceMovesDownAndKeepsACard()`: store ở inPlace; 3 record inPlace + feeling tooHard → store.level == .seated, `pendingCard == .movedDown(.seated)`; `threeTooEasyAtSeatedMovesUp()` → `.movedUp(.inPlace)`; `justRightChangesNothing()`.
2. RED → sau khi lưu feeling: dựng `history` từ mọi `WorkoutRecord` (date, level, feeling, breakCount) → `Adaptation.next(state:history:)`; nếu `result.level != state.level` → `store.set(level:changedAt: record.date, card: result.card)`.
**Command:** `APP SessionCompletionServiceTests` → expected: `** TEST SUCCEEDED **`
**Evidence:** DONE — RED: `extra argument 'levels' in call`. GREEN: `APP SessionCompletionServiceTests` → `Test run with 12 tests in 1 suite passed`, `** TEST SUCCEEDED **` (mới: threeTooHardAtInPlaceMovesDownAndKeepsACard, threeTooEasyAtSeatedMovesUp — kèm lên rồi hạ lại sau 3 Too hard ở cấp mới, justRightChangesNothing). Store truyền qua init `levels:` (AppModel.walkLevels), `recordFeeling` giữ chữ ký.
**Commit point:** `fix(session): level changes when the feeling is recorded`

### Task 0.4 — Today dùng cấp hiện tại, thẻ `.movedUp` [TDD]
**Files:** Modify `iOS/App/Features/Today/TodayModel.swift` (`TodayInput.level` = cấp hiện tại; `TodayInput.levelCard: AdaptationCard?`; `TodaySpecialCard.movedUp(to:)`; `specialCard` ưu tiên: pain → shorter → movedDown → movedUp → connectHealth → fewerReminders), `AppModel.swift` (`reload()` đọc `WalkLevelStore`; thẻ hết hạn 7 ngày sau `changedAt` hoặc sau buổi kế → `clearCard()` trong `workoutClosed`) · Test `TodayModelTests.swift`
**Steps:**
1. Test `movedUpCardShowsAfterAChange()` (`levelCard: .movedUp(.inPlace)` → `specialCard == .movedUp(to: .inPlace)`, `request?.level == .inPlace`), `levelDropsBackAfterTooHardAtTheNewLevel()` (input level seated sau khi store hạ → `request?.level == .seated`), cập nhật `oneSpecialCardAtATimeInPriorityOrder`.
2. RED → implement. `Adaptation.next` trong `TodayModel.init` chỉ còn tính `minutesDelta`/`.shorter` (2 Break), không đổi cấp (đã đổi ở 0.3).
**Command:** `APP TodayModelTests` → expected: `** TEST SUCCEEDED **`
**Evidence:** DONE — RED: `type 'TodaySpecialCard?' has no member 'movedUp'`. GREEN: `APP TodayModelTests` → `Test run with 19 tests in 1 suite passed` (mới: movedUpCardShowsAfterAChange, levelDropsBackAfterTooHardAtTheNewLevel; oneSpecialCardAtATimeInPriorityOrder cập nhật: movedDown trước movedUp). TodayModel bỏ `Adaptation.next`, chỉ còn `minutesDelta` từ Break buổi cuối. Thẻ hết hạn: `AppModel.currentLevel` (trong `reload()`, chạy cả ở `workoutClosed`) xoá thẻ khi đã có buổi sau `changedAt` hoặc ≥ 7 ngày — không xoá ngay trong `workoutClosed` vì thẻ được đặt ở Complete của chính buổi đó.
**Commit point:** `feat(today): moved-up card and current level`

### Task 0.5 — Thẻ "You're ready for a little more" và trạng thái chụp [UI]
**Files:** Modify `iOS/App/Features/Today/TodayCards.swift` (`SpecialCard` case `.movedUp`: "You're ready for a little more: In place today. Seated is one tap away." + nút "Keep it seated" → `onKeepSeated` ghi store về seated), `TodayView.swift`/`MainTabView.swift` (action), `iOS/App/Debug/CaptureHook.swift` (+`today-moved-up`), `AppCaptureScene.swift` (seed: store inPlace + card), `CaptureHookTests.swift` (count 109 → 110)
**Steps:** 1. Thêm case, copy, action. 2. `BUILD` → `SHOT promax today-moved-up today-moved-up@dark today-moved-up@xxl`.
**Command:** `APP CaptureHookTests` → `** TEST SUCCEEDED **`; ảnh có thẻ và nút "Keep it seated" ≥ 56 pt
**Evidence:** DONE_WITH_CONCERNS — `APP CaptureHookTests` → `Test run with 5 tests in 1 suite passed` (count 109 → **110**, `today-moved-up`). Ảnh `docs/design/research-2026-10-08/after-m1/promax/today-moved-up{,-dark,-xxl}.png`: thẻ "You're ready for a little more" + nút viên "Keep it seated" (PillButtonStyle, 56 pt) → `AppModel.keepEasierLevel()` (đặt lại cấp dễ hơn, `changedAt = now` nên câu Too easy cũ không đẩy lên lại). Concern: câu thân đổi từ "In place today." thành "Your walks are now In place. Seated is one tap away." vì hôm Chair moves/Stretch câu cũ sai nghĩa.
**Commit point:** `feat(today): moved-up card`

### Task 0.6 — Preview và Me cùng một cấp [UI]
**Files:** Modify `iOS/App/Features/Root/AppModel+Flows.swift` (`preview` dùng `today.request.level` — đã là cấp hiện tại), `iOS/App/Features/Me/MeSections.swift` (`BodySection` hoặc mục "Your plan": dòng "Walking level: In place since Oct 20 · Started seated"; DEBUG: bộ đếm D15) · Test `OnboardingFlowTests`/`AppFlowTests` không đổi
**Steps:** 1. Dòng Me đọc `WalkLevelStore` + `profile.startLevel`. 2. `SHOT promax me` → inspect.
**Command:** `BUILD` → `** BUILD SUCCEEDED **`; ảnh `me` có dòng cấp
**Evidence:** DONE — Preview đã dùng `request.level` (= cấp hiện tại từ TodayModel). Me → Your body: `WalkingLevelLine` "Walking level: In place since Oct 2" + caption "Started at Seated" (chưa đổi: chỉ "Walking level: Seated"). DEBUG (D15): `PersonalisationCountersCard` (feeling đã trả lời/tổng, số lần đổi cấp — `WalkLevelStore.changeCount`, vùng đau lặp 14 ngày), ẩn khi chạy `-ScreenshotMode`. `BUILD` → `** BUILD SUCCEEDED **`; ảnh `after-m1/promax/me.png` có dòng cấp. Hết milestone 0: core `194 tests in 40 suites passed` (191 → 194), app `** TEST SUCCEEDED **` `206 tests in 45 suites` (198/44 → 206/45).
**Commit point:** `feat(me): current walking level line`

### Milestone 1 — Không tràn, font, màu, cỡ

### Task 1.1 — Font A1: SF Pro cho chữ, Rounded cho số, caption 16 [TDD]
**Files:** Modify `iOS/App/Design/Typography.swift` · Test Create `iOS/GentleWalkTests/TypographyTests.swift`
**Steps:**
1. Test `textRolesUseSFPro()` (`cardTitle/body/button/caption`.design == `.default`), `numberRolesUseRounded()` (`phaseLabel/timer/transition/stat/wallClock` == `.rounded`), `titleIsSerif()`, `captionIsSixteen()` (`size == 16`, `anchor == .callout`), `timerIsMedium()`.
2. RED → sửa `design`, `size`, `anchor`, `weight`; `TypeRoleModifier` thêm `.lineSpacing(2)` cho `.body` và `.screenTitle`.
**Command:** `APP TypographyTests` → expected: `** TEST SUCCEEDED **`
**Evidence:** DONE — RED: `value of type 'TypeRole' has no member 'lineSpacing'`. GREEN: `APP TypographyTests` + `DesignTokenTests` → `Test run with 8 tests in 2 suites passed` (6 test Typography: textRolesUseSFPro, numberRolesUseRounded, titleIsSerif, captionIsSixteen — mọi vai ≥ 16, timerIsMedium — cả wallClock, bodyAndTitleHaveLineSpacing). `stat` giữ bold (đã đậm hơn medium). Ghi chú: `ShareCardRenderer` (ảnh chia sẻ) còn Rounded cho chữ — ngoài phạm vi.
**Commit point:** `feat(design): SF Pro for text, rounded for numbers, caption 16`

### Task 1.2 — Nút 64 pt, `secondary` và `accent` đậm hơn, cặp chữ-nền có lề [TDD]
**Files:** Modify `iOS/App/Design/Tokens.swift` (`buttonHeight` 64, `readableWidth` 620, `TextPair.minimum` mặc định 4.5, `smallText` 5.0), `iOS/App/Assets.xcassets/Colors/secondary.colorset/Contents.json` (sáng `#54722F`, tối giữ `#557537`), `accent.colorset` (sáng `#8F4323`), `iOS/App/Features/Root/MainTabView.swift` (nhãn tab 15 pt) · Test `DesignTokenTests.swift`
**Steps:**
1. Test `smallTextPairsReachFive()`: "label on secondary", "selected tab on bg" ≥ 5.0 sáng và tối; `buttonHeightIsSixtyFour()`.
2. RED (4,6 và 4,8) → đổi màu; chạy lại cả `textPairsReachFourPointFive`.
3. `SHOT promax tokens tokens@dark` → nhìn bằng mắt.
**Command:** `APP DesignTokenTests` → expected: `** TEST SUCCEEDED **`
**Evidence:** DONE_WITH_CONCERNS — RED: `selected tab on bg … 4.80`, `label on secondary … 4.59` (< 5.0). GREEN: `APP DesignTokenTests` + `TypographyTests` → `Test run with 10 tests in 2 suites passed` (smallTextPairsReachFive sáng+tối, buttonHeightIsSixtyFour: 64 / rowHeight 64 / readableWidth 620). Màu: `secondary` sáng #54722F (5,49:1), tối giữ #557537 (5,27:1); `accent` sáng #8F4323 (6,25:1). **Phát hiện + sửa lỗi test cũ:** `ContrastRatio` đọc màu động không `resolvedColor(with:)` nên phép thử "dark" thật ra đo bản sáng — đã sửa, mọi cặp tối nay được đo thật và vẫn ≥ 4,5. Thêm theo hướng Claude Design (điều phối viên 08/10): `.primaryAction` gradient `primaryTop` #43684C/#52795A → `primary` → `primaryBottom` #253D2A/#3F6346, viền sáng 1 pt trên (trắng 22 %), bóng xanh (y 8, r 9 ≈ blur 18, 26 %), disabled phẳng; `cardStyle()` → `CardPaper` gradient `surfaceTop` #FFFEFA/#2E2923 → `surfaceBottom` #FBF5EA/#27221C + 2 lớp bóng nhẹ (`Palette.shadow`); 4 cặp chữ mới trên giấy + 2 cặp nút gradient trong `textPairs`. Nhãn tab 15 pt semibold qua `UITabBarAppearance` (UITabBarItem.appearance bị thanh tab Liquid Glass bỏ qua; appearance giữ nền kính — ảnh xác nhận). Ảnh: `after-m1/promax/tokens{,-dark}.png`, `today{,-dark}.png`. Concern: nhãn tab chọn nằm trên kính, không trên `bg` — cặp 'selected tab on bg' là xấp xỉ.
**Commit point:** `feat(design): 64 pt buttons and darker fills under white text`

### Task 1.3 — Rà mọi `frame(minHeight: 60)` và `Metrics.minTouchTarget` sau khi đổi token [UI]
**Files:** Modify các view có số cứng 60/72 (`grep -rn "minHeight: 60\|height: 60" iOS/App`): `SelectableCard.swift` (72 → `Metrics.rowHeight` = 64), `PillButtonStyle`, `ContinueButton`
**Steps:** 1. Thêm `Metrics.rowHeight = 64`; thay số cứng. 2. `BUILD`; `SHOT promax onboarding-goal today paywall-eligible`.
**Command:** `grep -rn "minHeight: 60" iOS/App | wc -l` → expected: `0`
**Evidence:** DONE — `grep -rn "minHeight: 60" iOS/App | wc -l` → `0`. `Metrics.rowHeight = 64` (thêm ở 1.2) thay 72/64 cứng ở `SelectableCard`, `PictureChoiceCard`, `DailyMomentPicker`, ô tên onboarding; `CaptionBar` 60 là dải chữ (không phải vùng chạm) → hằng `bandMinHeight`; `PillButtonStyle` đã dùng `minTouchTarget` 56; không có `ContinueButton`. `JourneyRouteList` 72 để task 1.15. `BUILD` → `** BUILD SUCCEEDED **`; ảnh `after-m1/promax/onboarding-goal.png`, `today-dark.png`, `paywall-eligible.png`.
**Commit point:** `refactor(design): row height token`

### Task 1.4 — Welcome vừa SE [UI]
**Files:** Modify `iOS/App/Features/Onboarding/WelcomeView.swift` (`WelcomeHero` cao `containerRelativeFrame(.vertical) { h, _ in min(260, h * 0.32) }`; 3 dòng ≤ 7 chữ; nút ghim không cần vì vừa)
**Steps:** 1. Sửa. 2. `SIM-SE` → `SHOT se3 onboarding-welcome onboarding-welcome@dark onboarding-welcome@xxl`; `SHOT i11 …` (sau khi xoá SE, tạo 11); `SHOT promax …`.
**Command:** ảnh SE: "Let's begin" và "Restore purchase" trong màn, tranh ≥ 200 pt; XXL: cuộn được, không cắt chữ
**Evidence:** DONE — `WelcomeHero` cao `containerRelativeFrame(.vertical) { min(260, h × 0.32) }` (SE ≈ 207 pt, ảnh/clip qua `ArtImage.flexible`), khoảng cách 18 → 12, dòng 12 → 8; dòng 1 đổi "A 12-week plan for stronger legs and better balance" → "A 12-week plan for stronger legs" (≤ 7 chữ, bỏ "better balance" — rủi ro 1.4.1 ở mục 6.2 báo cáo UI). Ảnh SE `after-m1/se3/onboarding-welcome.png`: tranh 207 pt, "Let's begin" và "Restore purchase" trong màn; `-dark` sạch; `-xxl` cuộn, không cắt chữ. i11/promax: xem bảng 1.18.
**Commit point:** `fix(onboarding): welcome fits the smallest iPhone`

### Task 1.5 — Paywall vừa SE, 3 gói trong tầm mắt [UI]
**Files:** Modify `iOS/App/Features/Paywall/PaywallView.swift` (`PlanOptionCard` padding dọc 8 → hàng 52–56 pt; `TrialTimelineView` 1 dòng/mốc, `cardStyle(padding: 10)`; "Cancel anytime…" gộp vào disclosure dưới nút; `FreePlanNote` 1 dòng dưới gói; `IncludedList` 3 dòng caption-size 16 pt), `PaywallLegalFooter.swift` (footer gọn: nút + điều khoản 2 dòng + hàng link)
**Steps:** 1. Sửa bố cục theo mockup `paywall-se.png`. 2. `SHOT se3 paywall-eligible paywall-eligible@dark paywall-eligible@xxl paywall-monthly paywall-lifetime paywall-not-eligible paywall-lifetime-while-subscribed` + i11 + promax.
**Command:** ảnh SE sáng: tiêu đề, 3 dòng ✓, timeline, 3 gói, nút, điều khoản, Maybe later · Restore · Terms · Privacy đều trong màn, không "…"
**Evidence:** DONE_WITH_CONCERNS — ảnh SE `after-m1/se3/paywall-eligible{,-dark}.png`: tiêu đề 2 dòng, 3 dòng ✓ (caption 16), dòng thời gian 1 dòng/mốc ("Oct 22  Billed $39.99"), 3 gói (hàng 52–56 pt; "Lowest monthly cost" thành tab trên mép thẻ năm, không thêm hàng), nút, điều khoản 2 dòng ("Free for 14 days, then $39.99 a year from Oct 22. Renews until you cancel.", ngày không ngắt dòng), "Maybe later · Restore · Terms · Privacy" một hàng 56 pt — đều trong màn, không "…". `paywall-monthly/-lifetime/-not-eligible`: 3 gói + điều khoản đúng gói trong màn; `-lifetime-while-subscribed`: cảnh báo gia hạn làm thẻ cao, "Or keep the free plan" phải cuộn (trạng thái hiếm, 3 gói vẫn thấy). **Sửa thêm:** `-xxl` trước đó tràn ngang (giá `fixedSize` + hàng link `fixedSize`) → thẻ gói xếp dọc ở cỡ trợ năng, hàng link `ViewThatFits` dọc. Concern (chủ app duyệt câu): câu 24 giờ chuyển xuống `CancelNote` dưới gói ("Cancel anytime in Settings, at least 24 hours before renewal. Deleting the app doesn't cancel.") để điều khoản dưới nút vừa 2 dòng; "Includes 14 days free" → "14 days free"; "Yours to keep, no renewals" → "No renewals"; free plan: "Or keep the free plan: a walk each weekday." Ghi chú 08/10 (điều phối viên): paywall sẽ dựng lại ở 2.12 (Yearly + "See other plans") — 1.5 dừng ở mức không tràn, không làm thêm.
**Commit point:** `fix(paywall): three plans in view on iPhone SE`

### Task 1.6 — Tách Permissions thành 2 màn một quyền [UI]
**Files:** Create `iOS/App/Features/Permissions/PermissionStepView.swift` (`enum PermissionAsk { reminders, health }`; một màn: tiêu đề ≤ 8 chữ, 1 dòng lý do, nội dung (Reminder: `DailyMomentPicker` 2×2 + stepper; Health: tranh `momentFriends` 110 pt + callout "Turn On All"), nút chính ghim "Set my reminder" / "Connect Apple Health", link "Not now"; sau khi cấp: dòng xanh "Reminders on" + nút "Continue") · Modify `PermissionsView.swift` (xoá), `PermissionsModel.swift` (giữ), `AppCover.swift` (`.permissions(PermissionAsk)`), `CoverView.swift`, `AppModel+Flows.swift` (`workoutClosed` → `.permissions(.reminders)`; `permissionStepDone(.reminders)` → `.permissions(.health)`; `.health` → `oneTimeScreenClosed()`), `CaptureHook.swift` (bỏ `permissions`, `permissions-granted`; thêm `permissions-reminder`, `permissions-health`, `permissions-health-granted`), `AppCaptureScene.swift`, `CaptureHookTests.swift` (110 → 111) · Test `AppFlowTests.swift` (`permissionsComeAfterFirstSession` → hai bước)
**Steps:** 1. Test luồng: sau buổi đầu cover là `.permissions(.reminders)`, "Not now" → `.permissions(.health)`, "Not now" → nil và `pendingAfterCover` chạy. 2. RED → implement. 3. `SHOT se3/i11/promax permissions-reminder permissions-health permissions-health-granted` (+@dark, @xxl).
**Command:** `APP AppFlowTests` + `APP CaptureHookTests` → `** TEST SUCCEEDED **`; ảnh SE: lưới giờ + stepper + nút + Not now trong màn
**Evidence:** DONE — RED: `pattern with associated values does not match enum case 'permissions'` + `no member 'permissionStepDone'`. GREEN: `APP AppFlowTests` + `APP CaptureHookTests` → `Test run with 11 tests in 2 suites passed` (mới: `permissionsComeAfterFirstSession`: sau buổi đầu `.permissions(.reminders)` → `permissionStepDone(.reminders)` → `.permissions(.health)` → nil + `pendingAfterCover` chạy; lần sau không hiện). Count 110 → **111** (bỏ `permissions`, `permissions-granted`; thêm `permissions-reminder`, `permissions-health`, `permissions-health-granted`). `PermissionsView.swift` xoá (`git rm`), `PermissionStepView.swift` mới; cover giữ một id "permissions" nên bước 2 thay tại chỗ; "Don't Allow" trong hộp thoại iOS → sang bước kế (không hỏi lại); bước Health có "Back". Ảnh SE `after-m1/se3/permissions-{reminder,health,health-granted,reminder-dark,health-xxl}.png`: lưới giờ 2×2 + stepper + "Set my reminder" + "Not now" trong màn; Health: tranh 110 pt + callout "Turn On All" + nút + Not now trong màn; XXL cuộn, nút ở cuối.
**Commit point:** `feat(permissions): one permission per screen`

### Task 1.7 — Self-check intro vừa SE [UI]
**Files:** Modify `iOS/App/Features/SelfCheck/SelfCheckViews.swift` (`SelfCheckIntroView`: bỏ tranh 150 → 96 pt bên tiêu đề; "How it works" 3 bước lên trên; "Before you start" 4 gạch ≤ 8 chữ: "Sturdy chair, no wheels, back to a wall" · "Sit near the front, feet flat" · "Hands crossed or pushing, either is fine" · "Stop if it hurts or you feel dizzy"; disclaimer 1 dòng)
**Steps:** 1. Sửa. 2. `SHOT se3 selfcheck-intro selfcheck-intro@dark selfcheck-intro@xxl` + i11 + promax.
**Command:** ảnh SE: cả "How it works" và 4 gạch trên nút ghim "I'm ready"
**Evidence:** DONE — `SelfCheckIntroView`: tiêu đề 1 dòng, câu hỏi + tranh 84 pt bên cạnh (thay tranh 150 pt), một thẻ: "How it works" 3 bước ("1. Stand up fully, then sit down." · "2. Keep going for 30 seconds." · "3. Count each time you stand.") rồi "Before you start" 4 gạch 1 dòng ("Sturdy chair, no wheels, by a wall" · "Sit near the front, feet flat" · "Cross arms or push up, both fine" · "Stop if it hurts or you feel dizzy" — 2 câu rút gọn hơn plan để mỗi gạch 1 dòng trên SE), disclaimer 2 dòng giữ nguyên. Ảnh SE `after-m1/se3/selfcheck-intro{,-dark,-xxl}.png`: cả 3 bước + 4 gạch + disclaimer trên nút ghim "I'm ready"; XXL cuộn, tranh ẩn.
**Commit point:** `fix(selfcheck): intro fits without scrolling`

### Task 1.8 — Today: Start lên nửa trên màn; check đến hạn chỉ 1 nút chính [UI]
**Files:** Modify `iOS/App/Features/Today/TodayView.swift`, `TodayCards.swift` (`TodayHero` + `ProgramStripCard` gộp thành `TodayHeadline`: lời chào + một dòng "13 active days · Week 3 of 12 · Plan ›" (ring 24 pt); khi `checkCard == .due/.overdue`: `SelfCheckCard` đứng **trên** thẻ buổi và thẻ buổi hạ nút Start thành `.secondaryAction` — hoặc ngược lại khi chưa tới hạn)
**Steps:** 1. Sửa. 2. `SHOT se3 today today-program today-check-due today-done today-new today-rest today@dark today-xxl` + i11 + promax; đo y của Start ≤ 55 % chiều cao màn trên SE (từ ảnh, bằng mắt + thước).
**Command:** ảnh SE `today`: Start trong nửa trên; `today-check-due`: đúng một nút xanh
**Evidence:** DONE_WITH_CONCERNS — `TodayHero` + `ProgramStripCard` → `TodayHeadline`: lời chào + một dòng (vòng 24 pt) "13 active days · Week 3 of 12 · Plan ›" (`ViewThatFits`: SE chỉ còn mũi tên, VoiceOver vẫn đọc "…, Plan"; cỡ trợ năng xuống dòng), "Pick up at week N" giữ; `ProgramStripCard` xoá (không còn dùng; dòng "Stage 1 · Steady base" chỉ còn ở màn Program). Check `.due/.overdue`: `SelfCheckCard(isMain:)` lên trên thẻ buổi với nút xanh duy nhất, Start của thẻ buổi → `.secondaryAction`. Ảnh SE `after-m1/se3/today{,-program,-check-due,-done,-new,-rest,-dark,-xxl}.png`: `today-check-due` đúng một nút xanh. Đo SE `today`: mép trên Start ≈ y 397/667 pt (60 %), tâm ≈ 64 % (trước: ≈ 600 pt, dưới thanh tab) — **chưa đạt ≤ 55 %**: phần còn lại là câu chào 2 dòng + check-in (câu hỏi, 3 viên 56 pt, dòng "We'll set today's session to match." do review M1 khôi phục). Muốn đạt 55 % phải bỏ/chuyển dòng đó — chủ app quyết.
**Commit point:** `fix(today): start in the upper half, one main button`

### Task 1.9 — Complete buổi đầu: thẻ mời ngay sau "How did that feel?" [UI]
**Files:** Modify `iOS/App/Features/Workout/Complete/CompleteView.swift` (thứ tự: hero → 3 số → feeling → `SelfCheckInviteCard` → caption gộp "🌱 1 of 7 active days to Sprout · Every walk moves your journey" (`TreeMilestoneLine` + `JourneyProgressBar` thành `CompleteFootnote`) → postcard…; Done ghim)
**Steps:** 1. Sửa. 2. `SHOT se3 complete-first-walk complete-check-invite complete complete-xxl complete-first-walk@dark` + i11 + promax.
**Command:** ảnh SE `complete-first-walk`: "Let's do it" và "Later" trên nút Done
**Evidence:** DONE — thứ tự mới: hero → 3 số → "How did that feel?" → `SelfCheckInviteCard` (nút "Let's do it" viên xanh + "Later" cùng hàng, `ViewThatFits` xếp dọc khi chữ lớn) → `CompleteFootnote` (một thẻ caption 16: lá + "6 of 14 active days to Sapling", bản đồ + dòng hành trình + thanh + "Every minute you move…"; thay `TreeMilestoneLine`-thẻ + `JourneyProgressBar`, cái sau xoá vì không còn dùng) → postcard…; Done ghim; khoảng cách 20 → 12, ô số 80 → 70 pt. Không dùng emoji (luật copy ASCII). Ảnh SE `after-m1/se3/complete-first-walk{,-dark}.png`, `complete-check-invite.png`: "Let's do it" và "Later" nằm trên nút Done; `complete.png`: thẻ ghi chú + postcard bắt đầu trên Done; `complete-xxl.png` cuộn, Done cuối danh sách.
**Commit point:** `fix(complete): self-check invite in view on the first walk`

### Task 1.10 — Sound sheet: − / + thay slider [UI]
**Files:** Modify `iOS/App/Features/Workout/Shared/SoundControls.swift` (`LevelStepper`: 5 nấc, nút − / + 56 pt, nhãn "3 of 5", `accessibilityAdjustableAction`; `AudioLevels` map nấc ↔ 0…1 giữ khoá cũ) · Test `AudioLevelsTests.swift` (`stepsMapToLevels()`)
**Steps:** 1. Test map 5 nấc ↔ giá trị, nấc 1 của giọng = `voiceFloor`. 2. RED → implement. 3. `SHOT promax sound-sheet sound-sheet@dark`.
**Command:** `APP AudioLevelsTests` → `** TEST SUCCEEDED **`; ảnh không còn slider
**Evidence:** DONE — RED: `instance member 'voice' cannot be used on type 'AudioLevels'`. GREEN: `APP AudioLevelsTests` → `Test run with 5 tests in 1 suite passed` (`stepsMapToLevels`: 5 nấc, nấc 1 giọng = `voiceFloor` 0,4, nấc 5 = 1, nhạc 0,2…1, giá trị cũ của slider làm tròn về nấc gần nhất, mặc định nhạc 0,8 = nấc 4; khoá UserDefaults giữ nguyên). `LevelStepper`: nút − / + 56 pt (dùng lại `StepButton` của `DailyMomentPicker`, nay mờ khi hết nấc), nhãn "3 of 5", `accessibilityAdjustableAction`. Áp dụng cả Me → During a session (cùng `SoundControls`). Ảnh `after-m1/promax/sound-sheet{,-dark}.png`, `se3/sound-sheet.png`: không còn slider.
**Commit point:** `feat(sound): stepper instead of sliders`

### Task 1.11 — All sessions: lưới 2 cột, phút 17 pt [UI]
**Files:** Modify `iOS/App/Features/Sessions/AllSessionsView.swift` (`SessionSection`: `LazyVGrid` 2 cột `GridItem(.flexible())`, thẻ cao bằng nhau; cỡ trợ năng 1 cột như cũ), `SessionTile.swift` (bỏ `width` cố định; detail `.typeRole(.body)`)
**Steps:** 1. Sửa. 2. `SHOT se3 all-sessions all-sessions-free all-sessions@xxl` + promax.
**Command:** ảnh: không cuộn ngang, thẻ thứ ba không bị cắt
**Evidence:** DONE — `SessionSection`: `Grid` 2 cột (cặp mục mỗi `GridRow`, thẻ cùng hàng cao bằng nhau qua `maxHeight: .infinity`; dùng `Grid` thay `LazyVGrid` vì LazyVGrid không cân chiều cao ô), 1 cột thẻ ở cỡ trợ năng như cũ; `SessionTile` bỏ `width` cố định, phút `.typeRole(.body)` (19 pt), bỏ `lineLimit(2)` (không cắt "…" bản Việt). Ảnh SE `after-m1/se3/all-sessions{,-free,-xxl}.png`: không cuộn ngang, không thẻ bị cắt nửa.
**Commit point:** `fix(sessions): two-column grid`

### Task 1.12 — Preview: bỏ tranh khi danh sách dài; Swap là nút 56 pt [UI]
**Files:** Modify `iOS/App/Features/Workout/Preview/WorkoutPreviewView.swift` (`showsHero` thêm điều kiện `model.rows.count <= 4`; `SegmentList` nút Swap `PillButtonStyle` minHeight 56)
**Steps:** 1. Sửa. 2. `SHOT se3 preview-indoor preview-chair preview-stretch preview-steady preview-walking-pad` + promax.
**Command:** ảnh SE `preview-chair`: 6 động tác và Start đều trong màn hoặc danh sách cuộn với Start ghim (được phép cuộn: danh sách)
**Evidence:** DONE — `showsHero` thêm `model.rows.count <= 4`; Swap → `PillButtonStyle` (56 pt) thay link chữ nhỏ. Ảnh SE `after-m1/se3/preview-{indoor,chair,stretch,steady,walking-pad}.png`: `preview-chair` không còn tranh 140 pt, 5/6 động tác thấy, danh sách cuộn dưới "Start now" ghim (danh sách — được phép cuộn); các preview đi bộ cuộn vì 2 hàng chọn tranh + danh sách, Start ghim.
**Commit point:** `fix(preview): room for the list`

### Task 1.13 — Phone placement, Outdoor prep, Reminder offer vừa SE [UI]
**Files:** Modify `iOS/App/Features/Workout/PhonePlacementView.swift` (`PlacementCard` tranh 110 pt, thẻ ≤ 100 pt), `iOS/App/Features/Outdoor/OutdoorPrepView.swift` (`BeforeYouGo` tranh 110, 4 hàng 56 pt, mẹo nắng 2 dòng), `iOS/App/Features/Root/CoverView.swift` (`ReminderOfferCover` tranh 110, lưới 2×2)
**Steps:** 1. Sửa. 2. `SHOT se3 phone-placement outdoor-prep reminder-offer` (+@xxl) + promax.
**Command:** ảnh SE: nút chính và thẻ/lựa chọn thứ ba trong màn
**Evidence:** DONE — `PlacementCard` tranh 110 × 80 pt (thẻ ≈ 100–110 pt), khoảng 14 → 12; `BeforeYouGo` tranh 110, 4 hàng tick 56 pt trong một thẻ (`CheckRow`), mẹo nắng 2 dòng ("On hot days, walk early or late. Stop if you feel dizzy."), Continue ghim (trước nằm cuối trang); `ReminderOfferCover` tranh 96, bỏ câu hỏi lặp ("What's a good moment…" — tiêu đề phụ đã nói), lưới 2×2, khoảng 16 → 10. **Sửa thêm (XXL):** hàng giờ của `DailyMomentPicker` tràn ngang ở cỡ trợ năng (làm lệch lề cả màn Reminder offer và Permissions) → ở cỡ trợ năng tách 3 hàng (chữ / giờ / − +); Reminder offer không ghim nút ở cỡ trợ năng. Ảnh SE `after-m1/se3/{phone-placement,outdoor-prep,reminder-offer}{,-xxl}.png`: nút chính và lựa chọn thứ ba / hàng tick thứ tư / − + trong màn.
**Commit point:** `fix(flows): placement, outdoor prep and reminder offer fit iPhone SE`

### Task 1.14 — Player: hướng dẫn 17 pt, đồng hồ "0:24", câu HLV 22 pt [UI]
**Files:** Modify `iOS/App/Features/Workout/Chair/ChairPlayerView.swift` ("Tap +1 each time you stand" → `.typeRole(.body)`, màu `Palette.text`; câu HLV đang nói trong bong bóng `.cardTitle`), `iOS/App/Features/Workout/Walk/WalkPlayerView.swift` (`Duration` format `.time(pattern: .minuteSecond)` không zero-pad phút; "left in this part" 16 pt caption), `MoveGuidance.swift`
**Steps:** 1. Sửa. 2. `SHOT se3 walk-player chair-player chair-counted steady-set walk-player@dark chair-player-dark` + promax.
**Command:** ảnh: "0:24", không chữ 15 pt dùng làm hướng dẫn
**Evidence:** DONE_WITH_CONCERNS — `WalkPlayerModel.clock` → `.minuteSecond` không đệm phút ("0:24", cả đồng hồ ghế); `WalkPlayerModelTests` sửa kỳ vọng "00:25"/"01:26" → "0:25"/"1:26" → `Test run with 4 tests in 1 suite passed`. "Tap +1 each time you stand" → `.typeRole(.body)` màu `Palette.text`, đặt cả bề ngang dưới tên động tác (trước bị cắt dở trong cột hẹp); câu HLV đang nói: `CaptionBar(style: .bubble)` 22 pt (`.cardTitle`) trong bong bóng giấy; "left in this part" là caption 16 (từ 1.1). **Sửa thêm:** bộ đếm "4 of 8" trên SE bị "4 o…" (đồng hồ và tên chia đôi bề ngang) → `layoutPriority(1)` cho đồng hồ/bộ đếm. Ảnh SE `after-m1/se3/{walk-player,chair-player,chair-counted,steady-set,walk-player-dark,chair-player-dark}.png`: "0:24", không chữ 15 pt làm hướng dẫn, không "…". Concern: SE ghế — vùng cuộn giữa video và bong bóng thấp, chip "Two hands on the chair" ở `steady-set` bị mép cuộn cắt nửa (cuộn được); tên "Sit-to-stand" xuống dòng có gạch nối (như trước).
**Commit point:** `fix(player): readable instructions and clock`

### Task 1.15 — Progress: số lịch ≥ 17 pt, ô ngày ≥ 44 pt, biểu tượng nghỉ 16 pt; Journey huy hiệu ≥ 24 pt [UI]
**Files:** Modify `iOS/App/Features/Progress/ProgressScreen.swift` (`MonthCalendar` ngày `.typeRole(.body)`, `minHeight: 44`, moon 16 pt + `accessibilityLabel("Rest")`), `iOS/App/Features/Journey/JourneyRouteList.swift` (✓ 24 pt, thumbnail 80 pt)
**Steps:** 1. Sửa. 2. `SHOT se3 progress progress-checks journey` + promax; lịch 7 cột vẫn vừa 335 pt.
**Command:** ảnh: lịch không tràn ngang trên SE
**Evidence:** DONE — `MonthCalendar`: số ngày `.typeRole(.body)` (19 pt), ô `minHeight: 44` (ô trống cũng 44), trăng ngày nghỉ 16 pt nằm dưới số (trước 8 pt đè lên ô), VoiceOver giữ "Rest day". `JourneyRouteList`: điểm đã tới = huy hiệu ✓ 24 pt, thumbnail 80 × 64, hàng ≥ 80 pt. Ảnh SE `after-m1/se3/{progress,progress-checks,journey}.png`: lịch 7 cột vừa 335 pt, không tràn ngang. (Danh sách điểm dừng của Journey nằm dưới mép — màn danh sách, cuộn.)
**Commit point:** `fix(progress): larger calendar days`

### Task 1.16 — Program: dòng "not medical advice" dưới tiêu đề; Program finished 2 gạch [UI]
**Files:** Modify `iOS/App/Features/Program/ProgramView.swift`, `ProgramFinishedView.swift` ("What next?" → 2 gạch ≤ 8 chữ + dòng D13 "Still the same goal? Change it in Me.")
**Steps:** 1. Sửa. 2. `SHOT se3 program program-finished` (+@xxl) + promax.
**Command:** ảnh SE `program-finished`: 2 nút trong màn
**Evidence:** DONE_WITH_CONCERNS — `ProgramView`: dòng "Good Footing is for general fitness. It isn't medical advice." lên ngay dưới tiêu đề. `ProgramFinishedView`: tranh 72 × 96 bên tiêu đề (thay 170 pt trên đầu), "What next?" + 2 gạch ≤ 6 chữ ("Start again at week 1" · "Or keep your plan as it is", khớp 2 nút), disclaimer vào trong thẻ số liệu, dòng D13 "Still the same goal? Change it in Me." là link → đóng cover, mở tab Me. Ảnh SE `after-m1/se3/program{,-finished}{,-xxl}.png`: 2 nút ghim + link + disclaimer trong màn. Concern: Me chưa có mục đổi mục tiêu (đến ở milestone 2/4) — link tạm chỉ mở tab Me; câu "Your 2-week checks go on either way" bỏ khỏi đoạn What next.
**Commit point:** `fix(program): medical line first, shorter finish`

### Task 1.17 — Vị trí: chọn cách đo trước, màn mồi một nút [UI]
**Files:** Modify `iOS/App/Features/Outdoor/OutdoorPrepView.swift` (màn 2 `MeasureChoiceView`: "How should we measure your walk?" · 2 thẻ chọn "Map and distance" (chú thích "Uses your location while you walk") / "Steps only" · Continue; chọn Map → màn 3 `LocationPromptView`: tranh `mapPark` 110, tiêu đề "Next, iPhone asks about location", 1 dòng "Only while you walk. It stays on this phone.", **một** nút "Continue" → `onRequestLocation()`; kết quả Don't Allow → `onDone(false)`), `CoverView.swift`, `AppModel+Flows.outdoorPrepDone` (ghi `outdoorLocationChoice`), `MeSections.swift` (`OutdoorSection` đổi cách đo), `CaptureHook.swift` (`outdoor-location-ask` → `outdoor-measure-choice` + `outdoor-location-prompt`; 111 → 112), `AppCaptureScene.swift`, `CaptureHookTests.swift` · Test `OutdoorServicesTests.swift` (`dontAllowFallsBackToSteps()`)
**Steps:** 1. Test: `onRequestLocation` trả không được phép → `useLocation == false` và không hỏi lại lần sau. 2. RED → implement. 3. `SHOT se3/promax outdoor-measure-choice outdoor-location-prompt` (+@dark).
**Command:** `APP OutdoorServicesTests` + `APP CaptureHookTests` → `** TEST SUCCEEDED **`; ảnh `outdoor-location-prompt`: đúng một nút, không "Allow"
**Evidence:** DONE — RED: `cannot find 'OutdoorLocationChoice' in scope`. GREEN: `APP OutdoorPrepFlowTests` (trong `OutdoorServicesTests.swift`) + `APP CaptureHookTests` → `Test run with 8 tests in 2 suites passed` (`dontAllowFallsBackToSteps`: Map → màn mồi → "Don't Allow" → `useLocation == false`, lưu "steps", lần sau không hỏi; `stepsOnlyNeverOpensThePrompt`; `allowUsesTheMap`). Mới: `OutdoorPrepFlow.swift` (`OutdoorPrepFlow` @Observable + `OutdoorLocationChoice` thay chuỗi khoá rải rác); `OutdoorPrepView`: 3 bước, Continue ghim, `MeasureChoiceView` ("Map and distance" · "Uses your location while you walk" / "Steps only" · "No location needed" + "You can change this in Me."), `LocationPromptView` (tranh `mapPark` 110, "Next, iPhone asks about location", "Only while you walk. It stays on this phone.", **một** nút Continue → `requestPermissionAndWait()` trả Bool); `OutdoorLocationAskView` xoá. Me → Outdoor walks: "Map and distance" / "Uses your location while you walk. Off: steps only.". Count 111 → **112** (`outdoor-location-ask` → `outdoor-measure-choice`, `outdoor-location-prompt`). Ảnh SE `after-m1/se3/outdoor-{measure-choice,location-prompt}{,-dark}.png`: đúng một nút, không chữ "Allow".
**Commit point:** `feat(outdoor): measure choice first, single-button location prompt`

### Task 1.18 — Chuỗi mới EN + VI của milestone 1, bảng đo "cần cuộn" trước/sau [DATA]
**Files:** Modify `iOS/App/Localizable.xcstrings`, `docs/i18n/source/ui.json`, Create `docs/i18n/vi/ui-extra-9.json` · Create `docs/design/research-2026-10-08/after/m1-can-cuon.md` (bảng 50 màn × SE/11/Max: cuộn ✓/✗ sau sửa, chỉ danh sách được ✓)
**Steps:** 1. `BUILD` → `EXTRACT` → dịch khoá mới vào `ui-extra-9.json` (glossary) → `L10N`. 2. Chụp lại 50 trạng thái cũ trên SE (`SIM-SE`), ghi bảng.
**Command:** `L10N` → `0 missing; 0 problems`, coverage 0, `0 findings`; bảng: màn không phải danh sách = ✗ trên SE
**Evidence:** DONE — `BUILD` (SWIFT_EMIT_LOC_STRINGS) → `EXTRACT`: `ui.json 805` khoá (`removed 32 keys no longer in code`); 47 khoá mới dịch vào `docs/i18n/vi/ui-extra-9.json` (theo glossary; sau khi xem ảnh VI trên SE rút gọn 6 câu, và 2 câu cũ ở `ui-2.json`: "Full access, no charge" → "Dùng đủ, không mất phí", "We'll remind you" → "App nhắc bạn" để dòng thời gian paywall 1 dòng/mốc). `L10N`: `vi: 820 of 820 UI keys translated; 0 missing; 0 problems` · coverage `en/vi missing: 0 needs_review/new: 0` · `scan_literals` 42 ứng viên đều không phải chữ hiển thị (tên cặp màu `textPairs`, mô tả, `A−/A+`…) · `copy_lint` `0 findings`. Bảng `docs/design/research-2026-10-08/after/m1-can-cuon.md`: 52 trạng thái × SE/11/Max chụp thật; cuộn sau M1: SE 21 (trước 31/50), iPhone 11 20 (trước 21/50), Pro Max 16; màn không phải danh sách còn ✓ trên SE: chỉ onboarding-goal/barriers/body/plan (làm lại ở M2). Ảnh VI SE: `after-m1/se3-vi/` (8 màn). Cuối M1: core `194 tests in 40 suites passed`; app `** TEST SUCCEEDED **` `225 tests in 48 suites` (gồm AppIconTests của agent M3: xanh); `BUILD SUCCEEDED`.
**Commit point:** `feat(l10n): milestone 1 strings; docs: scroll audit after fixes`

### Milestone 2 — Onboarding mới

### Task 2.1 — Hồ sơ onboarding: 1 mục tiêu, mức vận động dùng thật [TDD]
**Files:** Modify `iOS/Packages/GentleWalkCore/Sources/GentleWalkCore/Onboarding/OnboardingProfile.swift` · Test `OnboardingProfileTests.swift`
**Steps:**
1. Test `primaryGoalIsTheOnlyGoal()`; `mostlySitStartsGentleAndShorter()` (`startIntensity == .gentle`, `startsShorter == true`); `activeEasyChairStandingStartsInPlace()` (giữ); `whyLinesFollowBarriersThenPocket()` (giữ, ≤ 2 dòng); `paywallOrderFollowsBarriers()` (`paywallEmphasis: [PaywallEmphasis]` — `charged` → `.timelineFirst`, `bored` → `.journeysFirst`).
2. RED → thêm `primaryGoal: Goal`, `startIntensity: Intensity`, `startsShorter: Bool`, `paywallEmphasis`; `maxWhyLines = 2`; `understandingKey` giữ (dùng cho câu đáp barriers).
**Command:** `CORE OnboardingProfileTests` → expected: `passed`
**Evidence:**
**Commit point:** `feat(core): onboarding profile with one goal and activity use`

### Task 2.2 — Thứ tự bước mới, goal chọn 1, hai màn cơ thể [TDD]
**Files:** Modify `iOS/App/Features/Onboarding/OnboardingFlow.swift` (`OnboardingStep`: `welcome, goal, barriers, name, activity, chair, soreSpots, anythingElse, plan, paywall`; `maxGoals = 1`; `stepLabel` "Step n of 7"; `noneChosen` riêng cho từng màn cơ thể: `noSoreSpots`, `noOtherLimits`; `missingAnswerHint` cho goal/activity/chair), `BodyLimitChips.swift` (`soreSpots = [knees, hips, lowerBack, shoulders, jointReplacement]`, `everyday = [noFloor, standingIsHard, dizzy, unsteady, noJumping]`) · Test `OnboardingFlowTests.swift`
**Steps:**
1. Sửa test: `screensComeInTheSpecOrder` (10 bước), `goalIsSingle()` (chọn 2 → cái sau thay cái trước, không `showsGoalLimit`), `noneOfTheseOnEachBodyScreen()`, `stepLabelCountsSeven()` (goal = 1, anythingElse = 7, plan = nil), `progressNeverStartsAtZero` (danh sách bước mới), `finishSavesSingleGoalAndActivity()`.
2. RED → implement; xoá `UnderstandingView`, `ActivityLevelView` cũ (thay bằng view trên khung mới ở 2.8).
**Command:** `APP OnboardingFlowTests` → expected: `** TEST SUCCEEDED **`
**Evidence:**
**Commit point:** `feat(onboarding): new step order, one goal, two body screens`

### Task 2.3 — Câu chữ mới và ngân sách chữ [TDD]
**Files:** Modify `iOS/App/Features/Onboarding/OnboardingCopy.swift` (tiêu đề: "What matters most to you?" · "What got in the way before?" · "What should we call you?" · "How active are you now?" · "Standing up without your hands is…" · "Any sore spots?" · "Anything else we should know?"; nhãn ô ≤ 4 chữ: Less pain · Steadier feet · Up from chairs · More energy · Keep up with grandkids · Lose some weight · Not sure yet, just start; barriers: My joints hurt · Videos go too fast · No time for me · I got bored · Surprise charges · Didn't know where to start; activity: I mostly sit · Short walks sometimes · I walk most days · I exercise regularly; câu đáp ≤ 14 chữ mỗi lựa chọn (goal 7, barrier 6 lấy từ `understanding` rút gọn, activity 4, sore 5 + None, else 5 + None, name); gợi ý ≤ 15 chữ) · Test Create `iOS/GentleWalkTests/OnboardingCopyBudgetTests.swift`
**Steps:**
1. Test `titlesAtMostEightWords()`, `hintsAtMostFifteen()`, `repliesAtMostFourteen()`, `optionLabelsAtMostFourWords()` (trừ `notSure` ≤ 5), `noBannedWords()` (đọc danh sách cấm từ `tools/lint/copy_lint.py` bằng regex đơn giản trong test).
2. RED → viết copy; `python3 tools/lint/copy_lint.py` → 0.
**Command:** `APP OnboardingCopyBudgetTests` → `** TEST SUCCEEDED **`; `copy_lint` → `0 findings`
**Evidence:**
**Commit point:** `feat(onboarding): copy within word budgets`

### Task 2.4 — Khung chung `OnboardingStepScaffold` + ô HLV cố định [UI]
**Files:** Create `iOS/App/Features/Onboarding/OnboardingStepScaffold.swift` (`struct OnboardingStepScaffold<Content: View>: View { title, hint, reply: LocalizedStringResource?, content, continueTitle, isContinueDimmed, onContinue, footer: (() -> AnyView)? }`; `CoachSlot`: khung cao cố định = 2 dòng body (`ScaledMetric` 56), hiện gợi ý (textMuted) hoặc `CoachFace` + câu đáp, chuyển bằng `.transition(.opacity)` ≤ 0,4 s, `.accessibilityElement(children: .combine)`; nội dung dưới không dịch chuyển) · Modify `OnboardingView.swift` (mọi bước ≠ welcome dùng scaffold; Continue ghim khi `!typeSize.isAccessibilitySize`; `OnboardingProgressHeader` nhận "Step n of 7"), `OnboardingMotion.swift` (`CoachNote` giữ cho Plan; `WalkingPathProgress.partStarts` → 7 mốc)
**Steps:** 1. Dựng. 2. `BUILD` → `SHOT se3 onboarding-goal onboarding-goal@xxl`; chạm chọn trên Pro Max và quan sát: ô HLV đổi chữ, lưới không nhảy.
**Command:** `BUILD` → `** BUILD SUCCEEDED **`; ảnh SE: tiêu đề, ô HLV, 7 ô, Continue ghim trong 647 pt
**Evidence:**
**Commit point:** `feat(onboarding): shared step scaffold with a fixed coach slot`

### Task 2.5 — Goal: lưới 2 cột, icon mỗi ô, ô cuối trải hàng [UI]
**Files:** Create `iOS/App/Design/Components/ChoiceGrid.swift` (`ChoiceTile`: icon chip + nhãn + vòng/tick, 64–72 pt, viền chọn 3 pt; `ChoiceGrid` 2 cột `LazyVGrid`, phần tử lẻ cuối `gridCellColumns(2)`; 1 cột ở cỡ trợ năng) · Modify `QuestionViews.swift` (`GoalView` dùng scaffold + `ChoiceGrid`; icon từ `IconMap.goal(_:)` — tạm dùng `OnboardingCopy.symbol`, milestone 3 chốt) 
**Steps:** 1. Dựng. 2. `SHOT se3/i11/promax onboarding-goal (+@dark, @xxl)`.
**Command:** ảnh SE: 7 ô + Continue, không cuộn; XXL: 1 cột, cuộn, Continue cuối
**Evidence:**
**Commit point:** `feat(onboarding): goal grid`

### Task 2.6 — Barriers: lưới 2 cột, chọn nhiều, đáp theo lựa chọn đầu [UI]
**Files:** Modify `QuestionViews.swift` (`BarriersView` scaffold + `ChoiceGrid`; gợi ý "Pick any that fit. No judgment."; reply `OnboardingCopy.note(first)`)
**Steps:** 1. Dựng. 2. `SHOT se3/i11/promax onboarding-barriers (+@dark, @xxl)`.
**Command:** ảnh SE: 6 ô, gợi ý, Continue trong màn
**Evidence:**
**Commit point:** `feat(onboarding): barriers grid`

### Task 2.7 — Name: ô nhập, gợi ý dưới ô, Skip 48 pt [UI]
**Files:** Modify `QuestionViews.swift` (`NameView` scaffold: hint "Only to say hello. It stays on this phone." trong `CoachSlot`, reply "Nice to meet you, \(name)."; footer Skip `.textLink` 48 pt dưới Continue ghim; bàn phím mở sẵn giữ)
**Steps:** 1. Dựng. 2. `SHOT se3/promax onboarding-name` (bàn phím ẩn trong capture: `UIApplication.resignFirstResponder` trong scene khi `-ScreenshotMode`).
**Command:** ảnh: Continue + Skip trong màn, không chữ bị cắt
**Evidence:**
**Commit point:** `feat(onboarding): name step on the scaffold`

### Task 2.8 — Activity (gọn) và Chair trên khung [UI]
**Files:** Modify `QuestionViews.swift` (`ActivityLevelView`: 4 hàng `SelectableCard` 64 pt, hint "So the first week fits you.", reply theo đáp án (vd. mostlySit: "A gentle, shorter start. Build up at your pace."); `ChairStrengthView`: 3 hàng, hint "This picks your first chair moves.", reply tick không chữ)
**Steps:** 1. Dựng. 2. `SHOT se3/i11/promax onboarding-activity onboarding-strength (+@dark, @xxl)`.
**Command:** ảnh SE: 4 hàng + Continue trong màn
**Evidence:**
**Commit point:** `feat(onboarding): activity and chair steps`

### Task 2.9 — Sore spots và Anything else, câu bác sĩ trong vùng ghim [UI]
**Files:** Modify `QuestionViews.swift` (`SoreSpotsView`: 5 chip + None lưới 2 cột 56 pt, hint "Tap all that apply.", reply "Got it. We'll go easy on your knees." theo chip cuối; `AnythingElseView`: 5 chip + None, reply theo chip (unsteady: "Thanks. Balance moves will keep both hands on the chair.")), `OnboardingView.swift` (`pinnedActions` của `.anythingElse` gồm `DoctorNote` 16 pt + Continue), `BodyLimitChips.swift` (hai hàm `soreSpotGrid`/`everydayGrid`; Me → Edit vẫn hiện cả hai nhóm), `OnboardingMotion.swift` (`BodyGlowFigure` chỉ ở Sore spots, 60 pt, ẩn trên SE nếu thiếu chỗ: `ViewThatFits`)
**Steps:** 1. Dựng. 2. `SHOT se3/i11/promax onboarding-sore-spots onboarding-anything-else (+@dark, @xxl)`.
**Command:** ảnh SE `onboarding-anything-else`: "I feel unsteady on my feet", "None of these", câu bác sĩ, Continue đều trong màn
**Evidence:**
**Commit point:** `feat(onboarding): two body screens with the doctor note pinned`

### Task 2.10 — Plan: 2 thẻ + 2 dòng why + thẻ Day 1 [UI]
**Files:** Modify `PlanReadyView.swift` (tiêu đề "Your plan, Margaret"; phụ đề theo goal "For steadier feet. Built from your answers." (`OnboardingCopy.planSubtitle(goal)`); `PlanCard`: "5–10 min a day, 12 weeks" · "Starts Seated · Sat & Sun are rest days" · tuần 7 ô · dòng giới hạn gộp "Easy on knees · No floor moves · Both hands on the chair"; `DayOneCard`: "Day 1 · Your first walk · 5 min" · "Seated · march in your chair" · nút Hear your coach (2.11); `WhyThisWorks` 2 dòng ✓ không thẻ; bỏ `ProgramPromiseCard` (gộp vào PlanCard), bỏ `FirstJourneyMini` (hành trình nói ở Today)), `OnboardingView.swift` (Continue "See my options" ghim)
**Steps:** 1. Dựng theo `plan-se.png`. 2. `SHOT se3/i11/promax onboarding-plan (+@dark, @xxl)`.
**Command:** ảnh SE: cả hai thẻ, 2 dòng ✓ và "See my options" trong màn, ≤ 70 chữ
**Evidence:**
**Commit point:** `feat(onboarding): compact plan screen`

### Task 2.11 — "Hear your coach · 10 seconds" phát câu thật [TDD]
**Files:** Create `iOS/App/Features/Onboarding/CoachPreviewPlayer.swift` (`@Observable @MainActor final class CoachPreviewPlayer { state: idle/loading/playing; func toggle(); func stop() }`: resolve `a1.01`, `a1.02` qua `VoiceSource`; `SessionTimeline` 2 cue (0 s, 6,3 s) → `SessionAudioComposer.compose(voiceURL:bellURL:nil…)` (thêm tham số `bellURL: URL?` cho phép không chuông) → `AVPlayer`; `AudioSessionConfigurator.apply(.guided)` khi phát, `deactivate()` khi hết/`stop()`; `onDisappear` → `stop()`) · Modify `PlanReadyView.swift` (nút 56 pt "Hear your coach · 10 seconds" ↔ "Stop" ↔ "Play again"; `accessibilityLabel`), `SessionAudioComposer.swift` · Test Create `iOS/GentleWalkTests/CoachPreviewPlayerTests.swift`
**Steps:**
1. Test `compositionIsTwoBundledLinesUnderTwelveSeconds()` (duration 10–12 s, 1 track giọng, 0 track chuông/nhạc), `stopDeactivatesTheAudioSession()` (spy configurator), `vietnameseResolvesViLines()` (VoiceSource language vi → file `a1.01.vi.m4a`).
2. RED → implement. 3. Trên Pro Max: bấm nghe, nghe được 2 câu; khoá màn → âm dừng (không background audio).
**Command:** `APP CoachPreviewPlayerTests` → `** TEST SUCCEEDED **`; `grep -c "UIBackgroundModes" iOS/project.yml` không đổi
**Evidence:**
**Commit point:** `feat(onboarding): hear your coach preview`

### Task 2.12 — Paywall nói lại mục tiêu, thứ tự theo trở ngại [TDD]
**Files:** Modify `PaywallModel.swift` (`init(... goal: Goal?, emphasis: [PaywallEmphasis])`; `benefits: [LocalizedStringResource]` 3 dòng: dòng đầu theo goal (steadier → "Balance sessions for steadier feet"; chairs → "Leg moves that grow with you"; lessPain → "Seated versions of every move"; energy/grandkids → "Walks that build up at your pace"; loseWeight → "Daily walks, chair moves and stretches"; notSure → mặc định); `layout: .timelineFirst/.default`), `PaywallView.swift` (`IncludedList(benefits:)`; `charged` → timeline ngay dưới tiêu đề), `CoverView.PaywallContainer` (truyền từ `app.profile`), `Snapshots.swift` (`ProfileSnapshot.goal`, `.barriers`), `AppCaptureScene.swift` · Test `PaywallModelTests.swift`
**Steps:** 1. Test `firstBenefitFollowsTheGoal()`, `chargedPutsTheTimelineFirst()`, `benefitsNeverPromiseHealth()` (không "prevent", "fall", "pain relief"). 2. RED → implement. 3. `SHOT se3/promax paywall-eligible` (fixture goal steadier, barriers joints+charged).
**Command:** `APP PaywallModelTests` → `** TEST SUCCEEDED **`; ảnh: dòng đầu "Balance sessions for steadier feet", timeline trên gói
**Evidence:**
**Commit point:** `feat(paywall): benefits echo her goal and barriers`

### Task 2.13 — Lưu hồ sơ và Me sửa được mục tiêu, cơ thể hai nhóm [DATA]
**Files:** Modify `OnboardingFlow.finish` (goals 1 phần tử, `activityLevel`, limits = sore ∪ else), `MeSections.swift` (`BodySection` sheet: hai nhóm chip; mục "Your goal" với 7 lựa chọn, `updateProfile { $0.goals = [goal.rawValue] }`), `Snapshots.swift` · Test `OnboardingFlowTests.finishSavesSingleGoalAndActivity` (2.2), `AppFlowTests.changingTheGoalUpdatesTheSnapshot()`
**Command:** `APP OnboardingFlowTests` + `APP AppFlowTests` → `** TEST SUCCEEDED **`
**Evidence:**
**Commit point:** `feat(me): change goal and body limits`

### Task 2.14 — Trạng thái chụp và fixture onboarding mới [DATA]
**Files:** Modify `CaptureHook.swift` (bỏ `onboarding-understanding-joints`, `onboarding-understanding-charged`; thêm `onboarding-activity`, `onboarding-sore-spots`, `onboarding-anything-else`, `onboarding-plan-coach` (trạng thái "đang phát", nút "Stop")), `AppCaptureScene.swift` (seed answers: goal steadier, barriers joints+charged, name Margaret, activity shortWalks, chair hard, limits knees+noFloor+unsteady cho ảnh), `Fixtures/en-US.json` (`goals: ["steadier"]`), `CaptureHookTests.swift` (112 − 2 + 4 = **114**; `onboardingStatesParse`)
**Command:** `APP CaptureHookTests` → `** TEST SUCCEEDED **`
**Evidence:**
**Commit point:** `chore(debug): capture states for the new onboarding`

### Task 2.15 — Bộ ảnh onboarding 3 máy + bản Việt [UI]
**Files:** `docs/design/research-2026-10-08/after/onboarding-{se3,i11,promax}.png` (bảng ghép bằng `tools/art` hoặc `montage`), `after/onboarding-vi-se3.png`
**Steps:** `SIM-SE` → `SHOT se3 onboarding-welcome onboarding-goal onboarding-barriers onboarding-name onboarding-activity onboarding-strength onboarding-sore-spots onboarding-anything-else onboarding-plan onboarding-plan-coach paywall-eligible` ×(sáng, @dark, @xxl) → `SHOT-VI se3` cùng danh sách → xoá SE → `SIM-11` → lặp → xoá → Pro Max lặp. Xem từng ảnh: không "…", không cuộn ngang, Continue trong màn (trừ @xxl), bản Việt không vỡ dòng xấu (tiêu đề ≤ 2 dòng, ô lưới ≤ 2 dòng).
**Command:** `ls docs/design/shots-2026-10/se3 | grep -c onboarding` → expected: ≥ 33
**Evidence:**
**Commit point:** `docs(design): onboarding screenshots after redesign`

### Task 2.16 — Chuyển động và trợ năng của khung [UI]
**Files:** Modify `OnboardingStepScaffold.swift`, `OnboardingMotion.swift` (reply hiện ≤ 0,4 s; Reduce Motion chỉ fade; `WalkingPathProgress` chạy một lần; VoiceOver: `CoachSlot` `accessibilityAddTraits(.updatesFrequently)` tắt, đọc reply một lần qua `AccessibilityNotification.Announcement`)
**Steps:** 1. Sửa. 2. Trên Pro Max: bật Reduce Motion (`xcrun simctl … accessibility`? không có → bật trong Settings của máy ảo) chụp `onboarding-goal`; bật VoiceOver thủ công một lần, ghi nhận đọc đúng.
**Command:** ảnh Reduce Motion giống bố cục thường; ghi chú kiểm VoiceOver vào Evidence
**Evidence:**
**Commit point:** `feat(onboarding): motion and VoiceOver on the scaffold`

### Task 2.17 — Chuỗi EN + VI của onboarding [DATA]
**Files:** Modify `iOS/App/Localizable.xcstrings`, `docs/i18n/source/ui.json`, `docs/i18n/vi/ui-extra-9.json`, `docs/i18n/glossary-vi.md` (Step n of 7 → "Bước n/7"; Sore spots → "Chỗ đau nhức"; Hear your coach → "Nghe HLV · 10 giây")
**Steps:** `BUILD` → `EXTRACT` → dịch → `L10N`; chuỗi cũ không dùng (understanding, "Pick up to 2") để stale theo luật i18n.
**Command:** `L10N` → `0 missing; 0 problems`, coverage 0, `0 findings`
**Evidence:**
**Commit point:** `feat(l10n): onboarding strings en and vi`

### Task 2.18 — Tài liệu onboarding: spec, Review Notes, app-context [DATA]
**Files:** Modify `docs/design/gentle-walk-screen-spec.html` (S02–S07 theo bước mới; S04 bỏ; S06 hai màn; S16 hai màn; S10b ba màn), `docs/release/1.0/checklist.md` (Review Notes: "Every permission is optional; 'Not now' or 'Don't Allow' leaves the app fully usable. The coach preview on 'Your plan' plays two bundled lines of the first session."), `app-context.md` (decisions log, mục Engineering hooks: trạng thái mới)
**Command:** `grep -c "Step n of 7\|Sore spots\|Anything else" docs/design/gentle-walk-screen-spec.html` → ≥ 3; `copy_lint` 0
**Evidence:**
**Commit point:** `docs: onboarding redesign in spec and review notes`

### Milestone 3 — Icon + chống nhàm chán (placeholder, chi tiết theo `docs/design/research-2026-10-08/icon-va-chong-nham-chan.md`)

_Tài liệu chưa có lúc lập kế hoạch (08/10). Task 3.1 đọc nó và viết lại 3.2–3.11 với file:line, icon map và cơ chế chống nhàm chán xếp hạng ở §7 của tài liệu. Luật chung: SF Symbols, weight medium, ≥ 24 pt, luôn kèm chữ, một nghĩa một symbol, màu từ `Palette`, nền icon là vệt màu nước (`IconChip`), không emoji trong UI._

### Task 3.1 — Đọc `icon-va-chong-nham-chan.md` và chi tiết hoá milestone này [DATA]
**Files:** Read `docs/design/research-2026-10-08/icon-va-chong-nham-chan.md`, `icon-mockups.html` và ảnh trong `icon-mockups/` (đã có lúc 08/10, tài liệu .md chưa có) · Modify kế hoạch này (thay các task 3.2–3.11 bằng task cụ thể theo §7, mỗi task có file:line, icon, test, ảnh)
**Steps:** 1. Đọc §icon rules, icon map, cơ chế chống nhàm chán, §7 task list. 2. Viết lại 3.2–3.11 (giữ số, thêm 3.x nếu cần), ghi "Chi tiết hoá 3.1 ngày …" vào Evidence.
**Command:** `grep -c "### Task 3\." docs/plans/2026-10-08-ui-onboarding-personalization.md` → ≥ 11
**Evidence:**
**Commit point:** `docs(plan): icon and anti-boredom milestone detailed`

### Task 3.2 — `IconMap` trung tâm và test một nghĩa một symbol [TDD]
**Files:** Create `iOS/App/Design/IconMap.swift` (`enum IconMap`: `goal(Goal)`, `barrier(Barrier)`, `activity(ActivityAnswer)`, `chair(ChairAnswer)`, `limit(BodyLimit)`, `moment(DailyMoment)`, `setting(SettingRow)`, `card(TodayCardKind)`, `stat(StatKind)`…; mỗi symbol kèm `meaning: String`) · Test Create `IconMapTests.swift` (`eachSymbolHasOneMeaning()`: không symbol nào gắn 2 nghĩa; `everySymbolExists()`: `UIImage(systemName:) != nil`)
**Command:** `APP IconMapTests` → `** TEST SUCCEEDED **`
**Evidence:**
**Commit point:** `feat(design): icon map`

### Task 3.3 — Icon cho lựa chọn onboarding (kiểm lại 2.5–2.9 theo icon map) [UI]
**Files:** Modify `OnboardingCopy.symbol`, `QuestionViews.swift`, `ChoiceGrid.swift` (icon từ `IconMap`) · ảnh onboarding lại trên Pro Max
**Evidence:**
**Commit point:** `feat(onboarding): icons from the icon map`

### Task 3.4 — Icon hàng cài đặt Me [UI]
**Files:** Modify `MeSections.swift` (`SettingsCard` nhận `symbol`; mỗi hàng Gói · Your plan · Your body · Week · Reminders · Sound · Display · Language & units · Apple Health · Outdoor · Help có icon) · `SHOT promax me me-notifications`
**Evidence:**
**Commit point:** `feat(me): icons on settings rows`

### Task 3.5 — Icon thẻ Today (buổi, check-in, hành trình, tuần, extras, thẻ đặc biệt) [UI]
**Files:** Modify `TodayCards.swift` · ảnh `today*`
**Evidence:**
**Commit point:** `feat(today): icons on cards`

### Task 3.6 — Complete và ăn mừng: icon 3 số, biến thể lời khen, lá rơi theo mùa/chặng [UI]
**Files:** Modify `CompleteView.swift`, `CompleteContent.swift` (kho lời khen theo biến thể, xoay theo `activeDays`, không lặp 7 ngày) · Test `CompleteContentTests` (xoay không lặp)
**Evidence:**
**Commit point:** `feat(complete): icons and varied cheers`

### Task 3.7 — Progress: icon cho ô kết quả, lịch, Everyday wins [UI]
**Files:** Modify `ProgressScreen.swift`
**Evidence:**
**Commit point:** `feat(progress): icons`

### Task 3.8 — Permissions / Outdoor / Self-check: icon + chữ cho mọi bước [UI]
**Files:** Modify `PermissionStepView.swift`, `OutdoorPrepView.swift`, `SelfCheckViews.swift`
**Evidence:**
**Commit point:** `feat(flows): icons on permission, outdoor and self-check screens`

### Task 3.9 — Kho câu HLV đa dạng (coach line pools) [TDD]
**Files:** Modify `VoiceRotation.swift`, nội dung `docs/scripts/*` (biến thể câu mở/đóng đã thu: xoay theo `rotationIndex`, không lặp trong 5 buổi) · Test `VoiceRotationTests` (chi tiết theo tài liệu §chống nhàm chán)
**Evidence:**
**Commit point:** `feat(content): rotating coach line pools`

### Task 3.10 — Chủ đề buổi tập (session themes) theo tuần/chặng [TDD]
**Files:** theo tài liệu (vd. tên buổi theo địa danh hành trình, nhạc theo chặng) — `SessionCatalog.swift`, `TodayModel.swift`
**Evidence:**
**Commit point:** `feat(sessions): weekly themes`

### Task 3.11 — Lời chào và tranh thay đổi (greetings/art variants) [UI]
**Files:** `TodayModel.greeting` (kho câu theo giờ/ngày/tuần, không lặp 7 ngày), `TodayHero` tranh theo mùa/chặng (`Art` có sẵn), Welcome back · Test `TodayModelTests.greetingRotates()`
**Evidence:**
**Commit point:** `feat(today): varied greetings and art`

### Milestone 4 — Cá nhân hoá P1–P13

### Task 4.1 — P1: HLV nói check-in và trạng thái ngày [TDD]
**Files:** Modify `iOS/Packages/GentleWalkCore/Sources/GentleWalkCore/Plan/SessionBuilder.swift` (`build(... opening: OpeningContext)`; `OpeningContext { intensity, restart: Bool, shortened: Bool, levelChange: AdaptationCard? }` → segment `intro` 4–6 s trước block đầu với **một** câu: `a9.back.1/2` (xoay) nếu restart, else `a9.levelup/leveldown` nếu đổi cấp, else `a9.shorter` nếu rút ngắn, else `a9.gentle/steady/strong` theo intensity; không áp cho First Walk, extras, outdoor), `iOS/App/Features/Workout/WorkoutRequest.swift` (`opening`), `TodayModel.request` · Test `SessionBuilderTests.swift`
**Steps:** 1. Test `openingLineFollowsTheDay()` (4 trường hợp, ưu tiên restart > level > shorter > intensity), `firstWalkHasNoOpening()`, `SessionSyncTests` vẫn xanh (câu có file). 2. RED → implement.
**Command:** `CORE SessionBuilderTests` + `CORE SessionSyncTests` → `passed`
**Evidence:**
**Commit point:** `feat(core): coach opens with the day's state`

### Task 4.2 — P2 mở rộng: "Too hard" ×2 → Achy mặc định và ngắn hơn; "Too easy" ×2 → gợi Strong; Pro lên bậc nhanh hơn một bậc trần [TDD]
**Files:** Modify `Adaptation.swift` (`AdaptationResult.suggestedCheckIn: CheckIn?`, `minutesDelta −2` sau 2 tooHard liền ở cấp hiện tại; 2 tooEasy ở inPlace → `.great`), `TodayModel.swift` (check-in chọn sẵn `suggestedCheckIn` + dòng D16; `startIntensity`/`startsShorter` từ `ProfileSnapshot.activity` cho 10 buổi đầu / 2 tuần đầu), `RepLadder.swift` (`today(... bonusCap: Int)` — P5-Harder dùng), `Snapshots.swift` · Test `AdaptationTests`, `TodayModelTests` (`twoTooHardPreselectsAchy()`, `mostlySitStartsGentleAndShorter()`)
**Command:** `CORE AdaptationTests` + `APP TodayModelTests` → xanh
**Evidence:**
**Commit point:** `feat(adaptation): gentler default after two hard sessions`

### Task 4.3 — P4: nhắc lại mục tiêu trên Today, Complete, Progress, Everyday wins [TDD]
**Files:** Create `iOS/App/Features/Shared/GoalText.swift` (`GoalText.todayLine(goal, day)` chỉ khi buổi khớp: chairs ∧ sit-to-stand → "For getting up from chairs"; steadier ∧ steady set → "For steadier feet"; energy/grandkids ∧ walk → "For more energy, one walk at a time"; lessPain → "Gentle on your joints"; loseWeight → "Minutes moved add up"; `completeLine(goal)`, `progressTitle(goal)`) · Modify `TodayCards.swift` (dòng caption dưới tiêu đề thẻ buổi), `CompleteContent.swift` (`comparison` fallback = goal line), `ProgressScreen.swift` (thẻ "Your goal" ghim đầu, 1–2 số đo khớp goal từ `ProgressSnapshot`), `AppModel.allWins` (xếp theo goal) · Test `TodayModelTests.goalLineOnlyWhenTheSessionFits()`, `CompleteContentTests` (tạo nếu chưa có), `copy_lint`
**Command:** `APP TodayModelTests` → xanh; `copy_lint` → `0 findings`
**Evidence:**
**Commit point:** `feat(personalisation): her goal echoed across the app`

### Task 4.4 — P5: nhớ Easier / Harder [TDD]
**Files:** Create `iOS/Packages/GentleWalkCore/Sources/GentleWalkCore/Plan/ExerciseMemory.swift` (`ExerciseMemory { easierTaps: [id: [Date]], setAside: [id: Date], restored: Set<id>] }`; `defaultsEasier(now:) -> Set<id>` (2 lần/14 ngày); `harderBonus(now:) -> Set<id>`), Create `iOS/App/Services/Data/ExerciseMemoryStore.swift` (UserDefaults, khoá vào `AppDefaultsKeys`) · Modify `ChairPlayerModel.swift` (`chooseEasier` ghi; `chooseHarder` Pro ghi; free: nút Harder hiện 1 lần "With Pro, more reps when you're ready"), `SessionBuilder.swift` (`easierExerciseIDs ∪ memory.defaultsEasier`), `MoveGuidance.swift` (nhãn "Easier version, as you chose" + nút "Try the usual one"), `AppModel+Flows.prepareAndPlay` (`repLadder.today(bonusCap:)` khi Harder hôm trước + làm đủ, D10) · Test `ExerciseMemoryTests.swift` (core), `DataEraserTests`
**Command:** `CORE ExerciseMemoryTests` → `passed`; `APP DataEraserTests` → xanh
**Evidence:**
**Commit point:** `feat(personalisation): remember easier and harder`

### Task 4.5 — P3: nhớ chỗ đau theo bài, tạm bỏ có đường quay lại [TDD]
**Files:** Modify `PainRules.swift` (`exerciseRules(reports:now:) -> ExerciseRules { easier: Set<id>, setAside: Set<id> }`: 1 báo/14 ngày → easier; 2/28 ngày → setAside 28 ngày; bỏ qua id trong `memory.restored`), `SessionBuilder.swift` (`allowed` trừ setAside; `ChairSessionPlanner` tự thế bài ngồi — cơ chế có sẵn), `TodayModel.swift` (`TodaySpecialCard.setAside(exerciseName)`: "We've set Mini-squat aside for now. Bring it back in Me."), `TodayCards.swift`, `MeSections.swift` (mục "Moves set aside" với công tắc "Bring it back"), `ThisHurtsView.swift` (sau chọn vùng: gợi "Add 'Easy on knees' to your plan?" → `updateProfile`) · Test `PainRulesTests.swift` (`oneReportMakesItEasier`, `twoReportsSetItAside`, `restoredStaysAllowed`), `TodayModelTests`
**Command:** `CORE PainRulesTests` + `CORE SessionBuilderTests` → `passed`; `APP TodayModelTests` → xanh
**Evidence:**
**Commit point:** `feat(personalisation): moves that hurt go easier, then aside`

### Task 4.6 — P12: nhớ lựa chọn ở Preview [TDD]
**Files:** Create `iOS/App/Services/Data/PreviewChoiceStore.swift` (cấp chọn → `WalkLevelStore.set(level:…, card: nil)` khi khác cấp hiện tại; swaps: `[original: (replacement, date)]`) · Modify `WorkoutPreviewModel.swift` (`request` ghi store), `ChairSessionPlanner.moves` (bài bị đổi đi lùi trong vòng xoay 14 ngày, bài đổi vào ưu tiên — qua `Context.swapMemory`) · Test `WorkoutPreviewModelTests` (tạo), `SessionBuilderTests.swappedMoveComesBackLater()`
**Command:** `CORE SessionBuilderTests` → `passed`; `APP WorkoutPreviewModelTests` → xanh
**Evidence:**
**Commit point:** `feat(personalisation): preview choices remembered`

### Task 4.7 — P13: nghỉ dài → hạ một bậc thang (Pro) [TDD]
**Files:** Modify `SupportLadder.swift`, `RepLadder.swift` (`stepDownAll(_:)`), `AppModel+Program.pickUpProgram` (gọi khi bấm "Pick up at week N"; HLV nói `a11.ladder.down` ở buổi kế qua `pendingChange = .down`) · Test `SupportLadderTests`, `RepLadderTests` (`stepDownNeverBelowZero`), `AppFlowTests.pickUpLowersLadders()`
**Command:** `CORE RepLadderTests` + `CORE SupportLadderTests` → `passed`
**Evidence:**
**Commit point:** `feat(ladders): one step down after a long break`

### Task 4.8 — P9: tự kiểm tra quay lại kế hoạch (Pro) [TDD]
**Files:** Modify `SelfCheck.swift` (`SelfCheckComparison.trend(history:) -> .up/.down/.flat` chỉ cùng cách, chênh ≥ 2), `RepLadder.today(... trend:)` (up → trần `base + 2` trong 14 ngày; down → trần `base`, không lên bậc vịn), `AppModel+Flows.prepareAndPlay`, `TodayModel` (down → `suggestedCheckIn = .okay`) · Test `SelfCheckComparisonTests`, `RepLadderTests`
**Command:** `CORE SelfCheckComparisonTests` + `CORE RepLadderTests` → `passed`
**Evidence:**
**Commit point:** `feat(selfcheck): results feed the rep ladder`

### Task 4.9 — P6: check-in tuần đổi tuần sau [TDD]
**Files:** Create `iOS/Packages/GentleWalkCore/Sources/GentleWalkCore/Progress/WeeklyCheckIn.swift` (`WeeklyNote { weekStart, effort: .easier/.right/.harder, better: BetterChip? }`; `WeeklyCheckIn.isDue(now:notes:calendar:)` D11; `effects(note) -> WeekEffects { minutesDelta, defaultCheckIn, laddersFrozen }`), Create `iOS/App/Services/Data/WeeklyNoteStore.swift`, Create `iOS/App/Features/WeeklyCheckIn/WeeklyCheckInView.swift` (sheet 2 câu: "This week felt…" 3 ô · "One thing that felt a bit better?" 7 chip; "Skip"), `AppCover.weeklyCheckIn` · Modify `TodayModel` (thứ Hai: dòng "Last week you said stairs felt a bit better. Let's keep the leg work going."; `WeekEffects` áp vào request/check-in), `ProgressScreen.swift` (dòng thời gian ghi chú tuần, nguyên văn chip), `MainTabView`/`AppModel.sceneBecameActive` (mở sheet khi đến hạn, 1 lần/tuần), `DataEraser` · Test `WeeklyCheckInTests.swift` (core), `TodayModelTests.lastWeekLineOnMonday()`, `copy_lint`
**Command:** `CORE WeeklyCheckInTests` → `passed`; `APP TodayModelTests` → xanh; `copy_lint` → 0
**Evidence:**
**Commit point:** `feat(personalisation): weekly check-in shapes next week`

### Task 4.10 — P8: thẻ "Your results" đầu Progress [UI]
**Files:** Modify `ProgressScreen.swift` (`YourResultsCard`: 4 ô Chair count (có/không tay, "+2 since your first check") · Hands on the chair (Pro; free: "Two hands" + 1 dòng Pro) · Longest walk without a break · Minutes this week vs your usual (trung vị 4 tuần); biểu đồ 8 tuần phút/tuần + số ngày/tuần (Swift Charts); Pro: reps hiện tại vs tuần 1 cho 3 bài), `Snapshots.swift` (`ProgressSnapshot.weeklyMinutes: [WeekPoint]`, `usualMinutes`, `repSteps`), `ProgramView.swift` (link "See how far you've come" → tab Progress) · Test `MonthSummaryTests`/`JourneySnapshotTests` mở rộng: `usualMinutesIsTheMedianOfFourWeeks()`
**Steps:** 1. Test snapshot. 2. Dựng. 3. `SHOT se3/promax progress progress-free progress-checks (+@dark, @xxl)`; thêm trạng thái `progress-results` (fixture 8 tuần).
**Command:** `APP MonthSummaryTests` → xanh; ảnh: 4 ô, không "score", không "normal"
**Evidence:**
**Commit point:** `feat(progress): your results card`

### Task 4.11 — P10: giờ nhắc và độ dài theo hành vi thật [TDD]
**Files:** Modify `NotificationPlanner.swift` hoặc Create `Progress/HabitSignals.swift` (core: `suggestedReminderMinutes(sessions:[(start, end)], reminderMinutes:)` — 5 buổi gần nhất lệch > 45 phút → đề xuất; `lengthSignal(records:)` — 2/3 buổi gần nhất kết thúc sớm 60–85 % không vì đau → `.shorter`; hay làm Extra ngay sau → `.longer`), `TodayModel` (`TodaySpecialCard.moveReminder(to:)` "Move your reminder to 9:15?" Yes/No → `updateProfile`; `.shorter` dùng cơ chế có sẵn; `.longer` → gợi Long walk) · Test `HabitSignalsTests.swift` (core), `TodayModelTests`
**Command:** `CORE HabitSignalsTests` → `passed`
**Evidence:**
**Commit point:** `feat(personalisation): reminder time and length from real habits`

### Task 4.12 — P11: bước Apple Health → "đã đi nhiều hôm nay" [TDD]
**Files:** Modify `HealthService.swift` (`stepsToday(now:)`, `medianDailySteps(weeks: 4)` — chỉ khi đã có quyền), `AppModel.reload` (tính async, cache `TodayInput.busyDay: Bool` = hôm nay > 1,5 × trung vị, trước giờ nhắc), `TodayModel` (dòng "You've been on your feet a lot today. A gentle stretch fits." + swap mặc định stretch; không đổi lịch, không bỏ nhắc) · Test `HealthServiceTests.busyDayNeedsOneAndAHalfTimesTheMedian()`, `TodayModelTests`
**Command:** `APP HealthServiceTests` → xanh
**Evidence:**
**Commit point:** `feat(personalisation): busy day from Apple Health steps`

### Task 4.13 — P7: kịch bản A13 câu HLV theo lịch sử (EN + VI) [DATA]
**Files:** Create `docs/scripts/A13-coach-history.md` (bảng ID · câu · ghi chú: `a13.check.n.3`…`a13.check.n.20` "Last check, you stood up N times. Let's see today." · `a13.week.1`…`a13.week.12` "Week N of twelve. At your own pace." · `a13.days.1`…`a13.days.7` "That's N active days this week." · `a13.walk.2`…`a13.walk.5` "Second/Third/Fourth/Fifth walk this week. Nice and steady." — 41 câu, ≤ 16 từ, không tên, không "fall/risk/test"), Create `docs/i18n/vi/voice-a13.json` (41 câu VI theo glossary) · Modify `tools/content/voice_lines.py` (đọc A13), `tools/content/build_content.py`, `iOS/App/Resources/Content/voice-lines.json`, `ContentValidator.swift` · Test `ContentValidatorTests.coachHistoryLinesExist()` (41 id EN + VI)
**Steps:** 1. Viết kịch bản; `copy_lint` 0. 2. Test RED → build content → GREEN; `build_content.py --check` exit 0.
**Command:** `CORE ContentValidatorTests` → `passed`; `python3 tools/content/build_content.py --check` → exit 0
**Evidence:**
**Commit point:** `feat(content): A13 coach history lines`

### Task 4.14 — P7: thu giọng A13 qua Vibi, EN rồi VI, QC [DATA]
**Files:** `assets/voice/cache-bella-v4/`, `assets/voice/cache-vi-bella-v4/`, `iOS/App/Resources/Media/Voice/a13.*.m4a` (+ `.vi.m4a`), `voice-lines.json`, `content.vi.json`
**Steps:**
1. `python3 tools/voice/render_lines_vibi.py --voice bella-v4 --all --dry-run` → đếm 41 câu, ≈ 2.000 credit; `--balance` ghi số dư.
2. `python3 tools/voice/render_lines_vibi.py --voice bella-v4 --all --workers 6` → `python3 tools/voice/build_manifest.py --cache assets/voice/cache-bella-v4` → `python3 tools/voice/qc_lines.py` → sửa câu bị cờ "render again" (xoá cặp mp3/json, chạy lại; 2 lần sai thì đổi cách viết).
3. VI: `render_lines_vibi.py --voice bella-v4-vi --all --workers 6` → `python3 tools/i18n/build_content_overlay.py vi --cache assets/voice/cache-vi-bella-v4` → `qc_lines.py vi`.
4. Nghe thử 4 câu mẫu (N = 3, 12; week 1; days 3) EN + VI, ghi đường dẫn vào Evidence.
**Command:** `build_manifest.py` → `matched 661/661`; `build_content_overlay.py vi` → `661/661`; `RELEASE` → `** TEST SUCCEEDED **`
**Evidence:**
**STOP AND ASK (đã chốt 08/10):** credit Vibi — chủ app đã duyệt trước.
**Commit point:** `feat(voice): A13 recordings en and vi`

### Task 4.15 — P7: nối câu lịch sử vào buổi và tự kiểm tra [TDD]
**Files:** Modify `SessionBuilder.swift` (`OpeningContext.history: HistoryLine?` — một câu/buổi, đặt sau câu trạng thái P1 hoặc thay nó khi là buổi đầu tuần: `a13.week.N` ngày đầu tuần chương trình; Complete: `a13.days.N` hoặc `a13.walk.N` nói ở block cuối qua segment outro 3 s), `SelfCheckTimeline.swift` (`selfCheck(previousCount:)` → `a13.check.n.N` trước `a12.check.setup` từ lần 2), `SelfCheckAudioPlayer.swift`, `TodayModel.request` (tính `history`) · Test `SessionBuilderTests.oneHistoryLinePerSession()`, `SelfCheckTimelineTests.secondCheckRecallsTheLast()`, `SessionSyncTests` xanh
**Command:** `CORE SessionBuilderTests` + `CORE SelfCheckTimelineTests` → `passed`
**Evidence:**
**Commit point:** `feat(core): the coach remembers her history`

### Task 4.16 — Trạng thái chụp cho milestone 4 [DATA]
**Files:** Modify `CaptureHook.swift` (+`today-goal-line`, `today-set-aside`, `today-move-reminder`, `today-last-week`, `weekly-checkin`, `progress-results`, `me-set-aside`; 114 + 7 = **121**), `AppCaptureScene.swift`, `CaptureHookTests.swift` · `SHOT se3/promax` các trạng thái mới (+@dark, @xxl)
**Command:** `APP CaptureHookTests` → `** TEST SUCCEEDED **`; ảnh không "…", nút trong màn
**Evidence:**
**Commit point:** `chore(debug): capture states for personalisation`

### Task 4.17 — Chuỗi EN + VI của milestone 3 và 4 [DATA]
**Files:** `Localizable.xcstrings`, `docs/i18n/source/ui.json`, `docs/i18n/vi/ui-extra-9.json`, `docs/i18n/vi/content.json` (câu thông báo tuần mới nếu có), `glossary-vi.md`
**Steps:** `BUILD` → `EXTRACT` → dịch → `L10N`.
**Command:** `L10N` → `0 missing; 0 problems`, coverage 0, `0 findings`
**Evidence:**
**Commit point:** `feat(l10n): personalisation strings en and vi`

### Task 4.18 — Thông báo: tổng kết tuần không ghi sức khoẻ, không trùng, ≤ 1/ngày [TDD]
**Files:** Modify `NotificationPlanner.swift` (recap tuần chỉ số ngày/phút; không chèn chip P6), `NotificationScheduler.swift` · Test `NotificationPlannerTests.weeklyRecapNeverNamesHealth()`, `stillAtMostOneADay()` (với weekly check-in không tạo thông báo)
**Command:** `CORE NotificationPlannerTests` → `passed`
**Evidence:**
**Commit point:** `test(notifications): recap stays private`

### Milestone 5 — Kiểm chứng + tài liệu

### Task 5.1 — Toàn bộ core xanh [TDD]
**Command:** `cd iOS && swift test --package-path Packages/GentleWalkCore` → expected: `Test run with N tests … passed` (N ≥ 191 + test mới, ghi số)
**Evidence:**

### Task 5.2 — Toàn bộ app test xanh [TDD]
**Command:** `cd iOS && xcodebuild test -project GentleWalk.xcodeproj -scheme GentleWalk -destination 'id=558F034D-7FF9-42AF-9612-50FFA68E6B91'` → `** TEST SUCCEEDED **` (ghi số test/suite, so với 198/44)
**Evidence:**

### Task 5.3 — Cổng nội dung phát hành [TDD]
**Command:** `RELEASE` → `** TEST SUCCEEDED **` (mọi câu A13 có file EN + VI; `everyLanguageHasItsRecordings(vi)` xanh)
**Evidence:**

### Task 5.4 — i18n và lint cuối [DATA]
**Command:** `BUILD` → `EXTRACT` → `L10N` → `0 missing; 0 problems`, coverage 0 (en, vi), `scan_literals` sạch, `copy_lint` 0; `PY tools/lint/test_copy_lint.py` → `OK`; `PY tools/voice/test_build_manifest.py` → `OK`
**Evidence:**

### Task 5.5 — Bộ ảnh đầy đủ 3 máy × sáng/tối/XXL [UI]
**Files:** `docs/design/shots-2026-10/{se3,i11,promax}/`; bảng ghép `docs/design/research-2026-10-08/after/sheet-*.png`
**Steps:** `SIM-SE` → `SHOT se3 <121 trạng thái> ×(sáng, @dark, @xxl)` → xoá → `SIM-11` → lặp → xoá → Pro Max lặp (`capture_states.sh` đã nhận danh sách từ `CaptureState.allCases` xuất bằng `-ScreenshotMode list`? — không thêm hook mới: dùng danh sách tĩnh trong `iOS/scripts/capture_all.txt`). Xem từng ảnh theo 4 tiêu chí: nút chính trong màn (trừ @xxl), không "…", không cuộn ngang, chữ ≥ 16 pt.
**Command:** `find docs/design/shots-2026-10 -name "*.png" | wc -l` → expected: ≥ 3 × 3 × 121 = 1089 (trừ trạng thái chỉ iPad)
**Evidence:**

### Task 5.6 — Bản Việt: onboarding, paywall, Today, Complete, Progress [UI]
**Files:** Modify `iOS/scripts/capture_states.sh` (biến `LANG_ARGS`) · `docs/design/shots-2026-10/vi-se3/`
**Steps:** `SHOT-VI se3` cho 10 màn onboarding + 5 paywall + 8 today + complete-first-walk + progress-results; xem: tiêu đề ≤ 2 dòng, ô lưới ≤ 2 dòng, nút ghim trong màn, dấu tiếng Việt không chạm dòng trên (lineSpacing 2).
**Command:** `ls docs/design/shots-2026-10/vi-se3 | wc -l` → ≥ 25; ghi màn nào phải sửa chữ VI vào Evidence
**Evidence:**

### Task 5.7 — Danh sách "cần cuộn" đo được [DATA]
**Files:** Modify `docs/design/research-2026-10-08/after/m1-can-cuon.md` (bảng cuối: mọi trạng thái × SE/11/Max, cuộn ✓ chỉ ở: today*, journey, journeys, progress*, program, me*, all-sessions*, preview-* (danh sách > 4), session history, cancel-guide; mọi màn khác ✗ ở cỡ mặc định)
**Command:** `grep -c "✓" after/m1-can-cuon.md` ≤ số màn danh sách × 3; mọi dòng onboarding/paywall/quyền/self-check/complete-first-walk = ✗ trên SE
**Evidence:**

### Task 5.8 — Rà lại rủi ro App Review [DATA]
**Files:** Create `docs/reviews/2026-10-xx-ui-onboarding-app-review.md` (bảng: màn quyền 2 nút (D5) · vị trí 1 nút · paywall SE · "Hear your coach" · 1.4.1 chuỗi mới (grep "prevent\|fall risk\|improve balance\|relieve") · PrivacyInfo không đổi · UIBackgroundModes không đổi · thông báo ≤ 1/ngày · dữ liệu trên máy; Review Notes cập nhật)
**Command:** `grep -c "CA92.1" iOS/App/PrivacyInfo.xcprivacy` → 1; `git diff --stat iOS/project.yml` không đụng `UIBackgroundModes`; `copy_lint` 0
**Evidence:**

### Task 5.9 — Tài liệu: app-context, todo, spec, design guidelines [DATA]
**Files:** Modify `app-context.md` (decisions log dòng dưới; Engineering hooks: 121 trạng thái; Tone: "goal echoed"), `docs/todo.md` (gạch việc xong; thêm: nhân vật phụ D19, test người dùng câu bản Việt, iPad lượt ảnh), `docs/design/gentle-walk-screen-spec.html` (Design tokens: font A1, caption 16, nút 64, secondary/accent mới; S17 Today dòng gộp; S19 Your results), `docs/design-guidelines.md` nếu có (`ls docs/*.md`), `docs/codebase-summary.md` (store mới, scaffold, IconMap)
**Command:** `grep -n "2026-10-08-ui-onboarding-personalization" app-context.md docs/todo.md` → ≥ 2 dòng
**Evidence:**

### Task 5.10 — Điểm commit gợi ý (không commit khi chưa được bảo) [DATA]
**Steps:** gom các commit point theo milestone; đề xuất chủ app: `git add -A && git commit -m "UI fits iPhone SE, SF Pro text, new onboarding, icons, personalisation P1–P13"` (tác giả Cuong, không dòng AI).
**Evidence:**

## Trạng thái chụp (thêm vào danh sách của kế hoạch MVP)
Bỏ: `onboarding-understanding-joints`, `onboarding-understanding-charged`, `permissions`, `permissions-granted`, `outdoor-location-ask` (5).
Thêm: `today-moved-up` · `permissions-reminder` · `permissions-health` · `permissions-health-granted` · `outdoor-measure-choice` · `outdoor-location-prompt` · `onboarding-activity` · `onboarding-sore-spots` · `onboarding-anything-else` · `onboarding-plan-coach` · `today-goal-line` · `today-set-aside` · `today-move-reminder` · `today-last-week` · `weekly-checkin` · `progress-results` · `me-set-aside` (17) → 109 − 5 + 17 = **121**. Mỗi trạng thái chụp SE 3 · iPhone 11 · Pro Max × sáng · tối · XXL; bản Việt cho onboarding/paywall/Today/Complete/Progress.

## Rủi ro đã biết
- Đổi `secondary`/`accent` làm chip "Okay"/"Easier" và tab đậm hơn — xem lại ảnh tối; nếu xấu, chỉ đậm bản sáng.
- Khung ghim Continue + nút 64 pt trên SE: màn 7 ô (goal) sát mép; nếu tràn 1–2 pt, ô 64 → 60 pt riêng màn goal (ghi quyết định).
- `WalkLevelStore` ngoài SwiftData: người dùng xoá app giữ iCloud? Không (không iCloud) — nhất quán với ladders.
- A13 41 câu × 2: Vibi có thể đọc số lệch ("twelve" vs "12") → QC từng câu; câu sai 2 lần thì viết số bằng chữ trong kịch bản.
- Tài liệu icon chưa có: milestone 3 chỉ là khung; không bắt đầu 3.2+ trước khi 3.1 chi tiết hoá.
- Thời gian chụp: 121 × 9 ảnh × 3 máy ≈ 1.100 ảnh, mỗi ảnh ~10 s → ~3 giờ máy; chạy nền, xem theo bảng ghép.

## Approval checklist (tick để làm — không tick thì không code)
_Chủ app duyệt 08/10/2026 (làm hết, dứt điểm)._
- [x] Milestone 0 — Sửa lỗi "How did that feel?" (0.1–0.6)
- [x] Milestone 1 — Không tràn, font, màu, cỡ (1.1–1.18)
- [x] Milestone 2 — Onboarding mới (2.1–2.18)
- [x] Milestone 3 — Icon + chống nhàm chán (3.1–3.11, chi tiết hoá ở 3.1)
- [x] Milestone 4 — Cá nhân hoá P1–P13 (4.1–4.18)
- [x] Milestone 5 — Kiểm chứng + tài liệu (5.1–5.10)
- [x] Quyết định mặc định D1–D20 (bảng trên) áp dụng cho tới khi chủ app đổi
- [x] Credit Vibi cho A13 (4.14) đã duyệt trước

## Decisions-log line (thêm vào app-context.md sau khi duyệt)
- 08/10/2026 — Kế hoạch "UI không tràn, font A1, onboarding mới, icon, cá nhân hoá" duyệt: docs/plans/2026-10-08-ui-onboarding-personalization.md (81 task / 6 milestone; chủ app chốt: giữ "How active are you now?" và dùng thật; goal chọn 1; bỏ màn "You're not alone"; cơ thể 2 màn; paywall ở onboarding + "Hear your coach"; quyền 2 màn, vị trí chọn cách đo rồi 1 nút; cấp hiện tại ở UserDefaults; không SchemaV3) — by manh-skill-plan

## Bổ sung 08/10/2026: hướng hình ảnh từ Claude Design (chủ app duyệt)
Bản thiết kế: Claude Design "Good Footing — less-AI redesign" (https://claude.ai/artifact/Qgwo7Z66MkWDTAgKjoDtBP), nguồn lưu ở `docs/design/research-2026-10-08/claude-design/*.dc.html`. Milestone 2 (onboarding) và milestone 3 (icon + chống nhàm chán) làm theo các điểm sau, thay cho mockup cũ ở chỗ khác nhau:
- **Thanh tiến độ onboarding = luống cây 7 ô** (hạt → mầm → lá → nụ → hoa; ô đã qua là cây có màu, ô hiện tại có quầng ochre và lớn hơn, ô chưa tới là ụ đất có viền). Ảnh: `claude-design/progress-metaphors.png`. Nối với cây ở Progress. **Thanh tiến độ trong buổi tập = dấu chân.** Không dùng đường lượn có dấu tick.
- **Danh sách lựa chọn dạng trang sổ tay**: một tấm giấy, các dòng ngăn bằng nét đứt, icon cùng hàng bên trái trong vệt màu nước loang (radial), chữ 19 pt; dòng đang chọn tô kiểu bút dạ quang ochre dưới chữ + dấu tick vẽ tay ở cuối; không vòng tròn rỗng.
- **Chỗ đau: icon cơ thể vẽ riêng** (hình người tối giản, tô vùng đầu gối / hông / lưng dưới / vai bằng sienna; khớp thay thế = chấm viền), thẻ 2 cột cao 62 pt; "None of these" viền đứt, không icon.
- **Chiều sâu nhẹ, không 3D**: nút chính gradient xanh lá mạ (#5A8052 → #4A7044 → #3E6138; chủ app thấy xanh rêu đậm quá nặng) + vệt sáng mép trên + bóng xanh mềm; thẻ giấy gradient #FFFEFA → #FBF5EA + bóng nhiều lớp nhẹ; nền màn có ánh sáng ấm từ trên; lựa chọn đang chọn có lớp loang + bóng nhẹ.
- **Icon nét mềm** (stroke tròn đầu, hơi không đều) trên vệt màu nước, thay cảm giác "cứng" của SF Symbols; nguồn bộ icon chốt theo `icon-sources/nguon-icon.md` khi có.
- Today: thẻ buổi tập có dải tranh ở đầu và mép răng cưa như vé; hành trình như bưu thiếp nghiêng có tem. Complete: số liệu 3 cột ngăn bằng nét đứt (số dùng SF Pro Rounded), bưu thiếp tiếp theo, dòng cây sắp lớn. Me: hàng cài đặt có icon trái, giá trị và mũi tên phải, thẻ Pro gradient.
- **Trạng thái điều khiển phải rõ (chủ app 08/10, bảng `claude-design/States.dc.html`)**, áp cho mọi nút trong app, không chỉ dựa vào màu:
  - Lựa chọn đã chọn: nền tô đậm hơn + viền 3 pt + chữ đậm + dấu ✓ trong vòng tròn đặc; chưa chọn: nền giấy, viền mảnh, không dấu. VoiceOver đọc "Selected".
  - Công tắc: luôn có chữ "On"/"Off" cạnh nút gạt (và dấu ✓ trên núm khi bật).
  - Nhấn xuống: nút lún (scale 0.97, tối hơn, bóng chìm vào trong) + rung nhẹ `.sensoryFeedback(.selection)`.
  - Chưa bấm được: không chỉ làm mờ; nút viền đứt và ghi lý do ("Pick one to continue").
  - Đang xử lý: vòng quay + chữ ("Saving…"), nút không nhận chạm hai lần.
  - Nút giữ (chỉ khi thật cần): chữ "Hold to …" → vòng chạy đầy + "Keep holding…" → ✓ + "Done" + rung; VoiceOver/Switch Control một chạm là xong.
  - Hàng mở màn khác: giá trị + mũi tên ›; link: gạch chân, không phải chữ xám trơn.
  - Test: mỗi kiểu nút có một trạng thái chụp trong gallery `-ScreenshotMode tokens` (sáng/tối/XXL).
- **Nguồn icon (chủ app chốt 08/10, `icon-sources/nguon-icon.md`)**: Phosphor **Bold** (MIT) cho mọi icon nội dung, Phosphor **Fill** cùng tên cho trạng thái đã chọn; SF Symbols chỉ còn cho điều khiển hệ thống (›, ✓, ✕, +). Thay quy tắc "SF Symbols only" trong `icon-va-chong-nham-chan.md` §2 (giữ mọi quy tắc khác: luôn kèm chữ, một nghĩa một icon, chip vệt màu nước, ẩn với VoiceOver). Vẽ riêng 10–12 icon cơ thể trên lưới và độ dày nét của Phosphor (đầu gối, hông, lưng dưới, vai, khớp thay thế, khó xuống sàn, đứng lâu khó, chóng mặt, đứng không vững, không nhảy; thêm giãn cơ, cháu nhỏ nếu thiếu), theo hình mẫu `claude-design/SoreSpots.dc.html`. Triển khai theo `nguon-icon.md` §4: `tools/art/build_icons.py` lấy SVG Phosphor (ghim phiên bản) vào `iOS/App/Assets.xcassets/Icons/`, sinh `enum AppIcon`, file giấy phép `Phosphor-MIT.txt` trong bundle và một dòng Acknowledgements ở Me → Help; màu nét icon theo bảng tương phản §4 (không dùng sky/sun làm màu nét), thêm vào `Palette.textPairs` để `DesignTokenTests` kiểm.
- **Paywall gọn (chủ app 08/10: màn cũ "chi chít")**, làm ở task 2.12, theo `claude-design/Paywall.dc.html` và `PaywallPlans.dc.html`: tiêu đề nhắc mục tiêu chính ("Your 12 weeks to feel steadier, free for 14 days"), bỏ 3 dòng ✓ lợi ích (đã có ở màn Kế hoạch ngay trước); dòng thời gian 3 mốc không khung, nối bằng đường chấm dọc; chỉ hiện gói Yearly đã chọn sẵn (giá năm là số to nhất, giá/tháng chữ nhỏ), link "See other plans" mở Monthly và One payment tại chỗ (nút chính đổi theo gói: "Subscribe for $7.99 a month"…); bỏ nhãn "Lowest monthly cost"; giữ điều khoản tự gia hạn dưới nút, Maybe later, Restore, Terms, Privacy. Kiểm lại App Review 3.1.2 (giá gói đang chọn rõ, điều khoản dùng thử đúng gói) và chụp `paywall-eligible`, `paywall-monthly`, `paywall-lifetime` trên SE.
- **Progress nửa dưới hết "toàn chữ" (chủ app 08/10: "nhìn rất ngán")**, làm ở task 3.7 (+4.10), theo `claude-design/ProgressMore.dc.html`: ô trống Recent sessions / 2-week checks = tranh nhỏ trong vệt màu nước + một câu + một nút hành động (không chữ xám trơn); **Hands on the chair** = biểu đồ 3 bậc (Two hands → One hand → Fingertips) với chấm cho từng bài trên bậc của nó, icon bàn tay mỗi bậc, một câu tóm tắt, link "Each move" mở danh sách (không còn 8 dòng "Two hands" giống nhau); **Everyday wins** = lưới 2 cột thẻ có icon Phosphor (sofa, túi đồ, cửa hàng, cầu thang, cháu, kệ, hộp thư, vé), chạm để đánh dấu theo chuẩn trạng thái (tô đặc + viền 3 pt + ✓), dòng "2 of 8 so far"; nhãn rút gọn theo mockup (cập nhật `wins.json` + bản Việt); **All-day steps** = icon dấu chân trong vệt màu nước + một câu + nút viền. Chụp `progress`, `progress-free`, `progress-no-health` sáng/tối/XXL trên SE.
