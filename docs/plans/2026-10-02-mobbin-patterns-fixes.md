# Kế hoạch sửa theo review Mobbin — 02/10/2026

Nguồn: `docs/reviews/2026-10-02-mobbin-patterns.md` (M1–M16, S1–S4). Người thực hiện: phiên Opus. Reviewer không sửa code.

**Trạng thái 02/10/2026: T1–T15 DONE (T1 và T3 làm khác kế hoạch, xem nhật ký trong review); T16 DONE: test xanh, chụp lại chỉ các màn đã sửa. S1–S4 chờ chủ app.**

## Lệnh dùng chung

```bash
# Build cho simulator (iPhone 17 Pro Max, id cố định)
cd iOS && xcodebuild build -project GentleWalk.xcodeproj -scheme GentleWalk -destination 'id=558F034D-7FF9-42AF-9612-50FFA68E6B91' -derivedDataPath /tmp/gw-dd -quiet
# Test app
cd iOS && xcodebuild test -project GentleWalk.xcodeproj -scheme GentleWalk -destination 'id=558F034D-7FF9-42AF-9612-50FFA68E6B91' -derivedDataPath /tmp/gw-dd
# Test Core
cd iOS/Packages/GentleWalkCore && swift test
# Chụp (sau khi build): iOS/scripts/capture_states.sh <out> 558F034D-7FF9-42AF-9612-50FFA68E6B91 <state…>  (hậu tố @dark, @xxl — @xxl chỉ đúng sau T10)
# Copy lint
python3 tools/lint/copy_lint.py            # → 0 findings
# String Catalog + tiếng Việt (CLAUDE.md: mọi chuỗi mới phải có bản dịch trước khi DONE)
cd iOS && xcodebuild build -project GentleWalk.xcodeproj -scheme GentleWalk -destination 'id=558F034D-7FF9-42AF-9612-50FFA68E6B91' -derivedDataPath /tmp/gw-dd SWIFT_EMIT_LOC_STRINGS=YES -quiet && cd ..
python3 tools/i18n/extract_sources.py /tmp/gw-dd
python3 tools/i18n/apply_catalog.py vi --check        # liệt kê khoá thiếu → dịch vào docs/i18n/vi/ui-extra*.json
python3 tools/i18n/apply_catalog.py vi
```

Quy ước chung cho mọi task UI: token `Palette` / `.typeRole` / `Metrics`; không API mới hơn iOS 18; chữ mới qua `String(localized:)` hoặc `LocalizedStringResource`; ảnh chụp lại vào `/tmp/gw-mobbin-fix/`; xem bằng mắt (chữ tự nhiên, ngắt dòng, sáng/tối).

---

## Milestone A — Sửa lỗi thấy ngay trong buổi tập và màn kết (Important)

### T1 · M5 · TDD — "Next:" trên stretch player bỏ qua bên còn lại
- **Test:** Create `iOS/GentleWalkTests/StretchPlayerModelTests.swift` (Swift Testing, `@Suite(.serialized)` nếu dùng store): dựng `WorkoutSessionModel` cho buổi stretch có tư thế hai bên (fixture như `WorkoutCaptureScenes` state `stretch-switch-side`); assert `model.stretchModel.followingName == "other side"`-string khi phase kế cùng `exerciseID`, và bằng tên tư thế kế khi khác id, `nil`/"Last stretch" ở tư thế cuối.
- **Modify** `iOS/App/Features/Workout/Stretch/StretchPlayerModel.swift:55-60`: `followingName` → tìm phase đầu tiên sau `progress.index` có `exerciseID != current`; nếu phase kế ngay sau có cùng id → trả `String(localized: "other side")`. `MoveProgressHeader` (`MoveGuidance.swift:14`) vẫn in "Next: …".
- **Verify:** test mới pass; chụp `stretch-player stretch-switch-side` → dòng dưới thanh là "Next: other side" (ảnh 1) / "Next: <tư thế kế>" (ảnh 2).
- **DONE:** test xanh, 2 ảnh đúng, chuỗi "other side" có bản vi.

### T2 · M3 · UI — "How did that feel?" ngay sau 3 ô số trên Complete
- **Modify** `iOS/App/Features/Workout/Complete/CompleteView.swift:31-75`: chuyển khối `if content.variant != .stoppedForPain { FeelingQuestion … }` lên ngay sau `CompleteStats` (trước `TreeMilestoneLine`). Giữ các điều kiện khác.
- **Verify:** chụp `complete complete-first-walk complete-stretch complete-outdoor complete@dark complete-xxl` (xxl sau T10) → câu hỏi + 3 pill thấy ngay dưới ô số, Done vẫn ghim; bưu thiếp ở dưới.
- **DONE:** 6 ảnh đúng; `SessionStageFlowTests`/`AppFlowTests` vẫn pass.

### T3 · M4 · UI — Level-up không hiện "0 of 14"
- **Modify** `CompleteView.swift:36`: `if content.reachedLevel == nil { TreeMilestoneLine(...).cardStyle() } else { NextLevelLine(level: content.reachedLevel!) }`.
- **Create** `struct NextLevelLine: View` trong `iOS/App/Features/Progress/TreeMilestone.swift` (dưới `TreeMilestoneLine`): đọc `TreeLevel.milestone(activeDays:)` để lấy `next` và `total`; text `"Next: \(next.title), \(total) active days from here."`; sau Tree (next == nil): `"Next ring in \(total) active days."`; `.typeRole(.body)`, `.cardStyle()`, không thanh.
- **Test:** thêm vào `iOS/GentleWalkTests/SessionCompletionServiceTests.swift` hoặc test view-model gần nhất: `TreeMilestoneLine.text` không đổi; thêm `NextLevelLine.text(for:)` static → "Next: Sapling, 14 active days from here.".
- **Verify:** chụp `complete-level-up` → không còn "0 of 14", có dòng Next.
- **DONE:** ảnh đúng, test pass, chuỗi mới có bản vi.

### T4 · M9 · UI — Số đếm "Starting in" to như đồng hồ
- **Modify** `iOS/App/Features/Workout/Chair/ChairPlayerView.swift:308-312`: thay `Text("Starting in \(remaining)")` bằng `VStack(spacing: 2) { Text("Starting in").typeRole(.caption).foregroundStyle(Palette.textMuted); Text(verbatim: "\(remaining)").typeRole(.stat).foregroundStyle(Palette.text).contentTransition(.numericText()) }`, giữ `accessibilityLabel("Starting in \(remaining) seconds")` trên VStack (`accessibilityElement(children: .combine)`).
- **Verify:** chụp `chair-stand-behind` → số 40 pt đậm, màu chữ chính; `scrollsWhenCrowded` không cuộn ở cỡ mặc định.
- **DONE:** ảnh đúng; `ChairPlayer`/`SessionStageFlowTests` pass.

### T5 · M2 · UI — Nút trên clip có viền và bóng
- **Modify** `iOS/App/Features/Workout/Shared/InterfaceOrientation.swift:41-57` (`VideoCornerButton.body`): sau `.background(Palette.surface.opacity(0.92), in: .circle)` thêm `.overlay { Circle().strokeBorder(Palette.textMuted.opacity(0.35), lineWidth: 1) }` và `.shadow(color: .black.opacity(0.12), radius: 4, y: 1)`.
- **Modify** `iOS/App/Features/Outdoor/OutdoorLiveMap.swift:60-74` (nút Recenter): thêm cùng `.shadow` như `TrackingBadge` (dòng 113).
- **Verify:** chụp `walk-player chair-player stretch-player walk-fullscreen outdoor-player walk-player@dark` → vòng tròn nổi trên tường trắng và trên nền tối; `DesignTokenTests` không đổi (không có cặp chữ-nền mới).
- **DONE:** 6 ảnh đúng.

### T6 · M1 · UI — Câu check-in rõ và có lời giải thích
- **Modify** `iOS/App/Features/Today/TodayView.swift:152`: `Text("How do your joints feel today?").typeRole(.body).foregroundStyle(Palette.text)`; sau `ViewThatFits` thêm `Text("We'll set today's session to match.").typeRole(.caption).foregroundStyle(Palette.textMuted)`.
- **Verify:** chụp `today today-free today@dark today-xxl` → câu hỏi 19 pt màu chính, dòng giải thích dưới pill; thẻ vẫn vừa màn (Start thấy không cuộn ở iPhone 17 Pro Max cỡ mặc định).
- **DONE:** 4 ảnh đúng; `TodayModelTests` pass; chuỗi "We'll set today's session to match." có bản vi (có thể còn trong `docs/i18n/vi/` từ D6 — kiểm `apply_catalog.py vi --check`).

## Milestone B — Onboarding và quyền (Important)

### T7 · M6 · UI — Thanh tiến độ mảnh trên onboarding
- **Modify** `iOS/App/Features/Onboarding/OnboardingFlow.swift:46-53`: thêm `var progress: Double { Double(step.rawValue) / Double(OnboardingStep.plan.rawValue) }` (goal = 1/8 ≠ 0; plan = 1).
- **Modify** `iOS/App/Features/Onboarding/OnboardingView.swift:65-83` (`OnboardingProgressHeader`): thêm tham số `progress: Double`; dưới `HStack` vẽ `ProgressView(value: progress).tint(Palette.secondary).frame(height: 4).accessibilityHidden(true)` (nhãn Part đã đọc tiến độ). Gọi tại dòng 23 với `flow.progress`. Hiện cả ở `.plan` (nhãn nil, thanh đầy).
- **Test:** `iOS/GentleWalkTests/OnboardingFlowTests.swift`: `progressNeverStartsAtZero` → `.goal` > 0, `.plan` == 1, tăng đơn điệu.
- **Verify:** chụp `onboarding-goal onboarding-name onboarding-body onboarding-plan` → thanh 4 pt dưới hàng Back, dài dần.
- **DONE:** test pass, 4 ảnh đúng.

### T8 · M7 · TDD + UI — Đáp án thoát ở Goal, dòng "vì sao hỏi" ở Name/Activity/Chair
- **Modify** `iOS/Packages/GentleWalkCore/Sources/GentleWalkCore/Onboarding/OnboardingProfile.swift:4`: thêm `case notSure` cuối `Goal`. Kiểm `OnboardingProfile.make` và `whyKeys` không rẽ nhánh theo goal (review 01/10 §4: goals không dùng) — nếu có `switch` exhaustive, thêm nhánh.
- **Test Core:** `swift test` (có thể cần cập nhật test đếm `Goal.allCases`).
- **Modify** `iOS/App/Features/Onboarding/OnboardingCopy.swift:7-37`: `.notSure` → title "Not sure yet, just to feel better", symbol `"sparkles"`, tint `Palette.sky`.
- **Modify** `iOS/App/Features/Onboarding/QuestionViews.swift`: dòng 69 `ScreenHeader(title: "What should we call you?", subtitle: "The coach never says it; we use it to say hello.")`; dòng 104 subtitle `"So we start you at a comfortable level."`; dòng 121 subtitle `"It helps us pick your first chair moves."`.
- **Verify:** chụp `onboarding-goal onboarding-name onboarding-strength` → 7 thẻ Goal vừa màn (nếu tràn: Continue đã ở cuối cuộn, chấp nhận), phụ đề hiện; `python3 tools/lint/copy_lint.py` → 0 findings; `OnboardingFlowTests` pass.
- **DONE:** Core + App test pass, 3 ảnh đúng, 4 chuỗi mới có bản vi.

### T9 · M8 · UI — Nút chính ghim đáy trên "Two quick things"
- **Modify** `iOS/App/Features/Permissions/PermissionsView.swift:52-61`: `.pinnedActions(true)` theo trạng thái: `!model.remindersAllowed` → `Button("Allow reminders"){ Task { await model.allowReminders() } }.buttonStyle(.primaryAction)` + `Button("Not now", action: onDone).buttonStyle(.textLink)`; `remindersAllowed && !healthConnected` → `Button("Connect Apple Health")…primaryAction` + `Button("Done", action: onDone).buttonStyle(.textLink)`; cả hai → `Button("Done")…primaryAction`.
- **Modify** `PermissionCard` (dòng 93-102): khi `!isGranted` **không** vẽ nút trong thẻ nữa (nút đã ở vùng ghim); khi granted giữ nhãn xanh. Thêm tham số `showsButton: Bool` mặc định `false`.
- **Test:** `iOS/GentleWalkTests/AppFlowTests.swift` hoặc test `PermissionsModel`: không đổi logic; chỉ kiểm build. Nếu có `PermissionsModel` test về `allowReminders` → chạy lại.
- **Verify:** chụp `permissions permissions-granted` → ghim đáy là "Allow reminders" (xanh đậm) + "Not now" link; granted → "Done".
- **DONE:** 2 ảnh đúng, test pass; chuỗi đã có sẵn (không chuỗi mới).

## Milestone C — Công cụ chụp (Important)

### T10 · M10 · UI — Hook không ghi đè cỡ chữ của simulator
- **Modify** `iOS/App/RootView.swift:84`: thay `.dynamicTypeSize(state.rawValue.hasSuffix("-xxl") ? .accessibility3 : .large)` bằng modifier có điều kiện: chỉ `if state.rawValue.hasSuffix("-xxl") { scene.dynamicTypeSize(.accessibility3) } else { scene }`.
- **Modify** `iOS/scripts/capture_states.sh` dòng 3-4 (comment): ghi rõ `@xxl` dùng `content_size accessibility-extra-extra-extra-large` của simulator và cần hook này.
- **Test:** `iOS/GentleWalkTests/CaptureHookTests.swift`: thêm `plainStatesDoNotPinTextSize` (kiểm hàm tách suffix/`pinsAccessibilitySize(for:)` nếu tách ra hàm thuần; nếu không, mô tả trong comment và kiểm bằng ảnh).
- **Verify:** chụp `onboarding-plan@xxl today@xxl` → chữ cỡ AX, so với `today-xxl.png` phải giống nhau.
- **DONE:** 2 ảnh ở cỡ lớn; các task trên dùng `@xxl` từ đây.

## Milestone D — Hoàn thiện (Minor)

### T11 · M11 · UI — Paywall: "Start my free trial", mốc nhắc là ngày lịch
- **Modify** `iOS/App/Features/Paywall/PaywallModel.swift:66`: `showsTrial ? "Start my free trial" : "Continue"`; thêm `var reminderDateText: String { trial.reminderDate.formatted(.dateTime.month(.abbreviated).day()) }`.
- **Modify** `iOS/App/Features/Paywall/PaywallView.swift:32,77-80`: `TrialTimelineView(billingDate:reminderDate:price:)`; mốc 2 dùng `TimelineStepText(symbol: "bell.fill", title: reminderDate, detail: String(localized: "We'll remind you"))`.
- **Test:** `StoreServiceTests`/`PaywallModel` test có sẵn: thêm `reminderDateIsTwoDaysBeforeBilling`.
- **Verify:** chụp `paywall-eligible paywall-eligible@dark` → "Oct 14  We'll remind you", nút "Start my free trial"; `paywall-monthly paywall-lifetime` nút vẫn "Continue". Trio Restore · Terms · Privacy + Maybe later không đổi.
- **DONE:** 4 ảnh đúng, test pass, chuỗi nút có bản vi.

### T12 · M13 · UI — Ẩn thanh tiến độ khi "walking home"
- **Modify** `iOS/App/Features/Workout/Walk/WalkPlayerView.swift:329-342` (`NextUpRow`): `let progress: Double?`; vẽ `PhaseProgressBar` chỉ khi non-nil. Dòng 114 và 173: truyền `model.isWalkingHome ? nil : model.phaseProgress`.
- **Verify:** chụp `walk-home walk-player` → walk-home không có thanh; walk-player vẫn có.
- **DONE:** 2 ảnh đúng, `WalkPlayerModelTests` pass.

### T13 · M14 · UI — Dòng số + chữ dưới tiêu đề tháng (Progress)
- **Modify** `iOS/App/Features/Progress/ProgressScreen.swift:93-118` (`MonthCalendar`): tính `activeThisMonth = activeDates.filter { calendar.isDate($0, equalTo: now, toGranularity: .month) }.count`; dưới tiêu đề: `activeThisMonth > 0 ? "\(Plural.activeDays(activeThisMonth)) so far this month" : "Your first active day this month will show here."` `.typeRole(.body)`.
- **Test:** `iOS/GentleWalkTests/SessionHistoryTests.swift` hoặc test snapshot Progress: tách hàm thuần `MonthCalendar.summary(activeDates:now:calendar:) -> String` và test 0 / 3 ngày.
- **Verify:** chụp `progress progress-free progress@dark` → dòng mới dưới "October 2026".
- **DONE:** 3 ảnh đúng, test pass, 2 chuỗi có bản vi.

### T14 · M15 · UI — Thẻ ngày nghỉ có tranh và gợi ý nhẹ
- **Modify** `iOS/App/Features/Today/TodayView.swift:198-249` (`TodaySessionCard`): khi `session.kind == .rest` và không phải cỡ AX: thay `Image(systemName:)` bằng `ArtImage(art: .walkerRest, height: 96).frame(width: 84)`; sau detail thêm `Button("A short stretch if you like", action: onPickAnother ?? {}).buttonStyle(.smallTextLink)` (TodayView dòng 30 đã truyền `onSeeAllSessions` khi không có swap).
- **Create** state chụp: `iOS/App/Debug/CaptureHook.swift` thêm `case todayRest = "today-rest"` và seed ngày nghỉ (`restedToday` hoặc hôm nay là Thứ bảy) trong `AppCaptureScene`.
- **Verify:** chụp `today-rest` → tranh + link; `TodayModelTests` pass.
- **DONE:** ảnh đúng, chuỗi mới có bản vi, `CaptureHookTests` cập nhật danh sách state.

### T15 · M16 · DATA — Tranh cây một tông ở chế độ tối
- **Modify** `iOS/App/Design/Components/ArtImage.swift`: với tên `Art.treeName(level:)` dùng `.blendMode(.multiply)` trên nền `Palette.artPaper` (hoặc xuất lại 4 PNG cây nền trong suốt từ `assets/art/` bằng `tools/art/build_art.py` nếu nền là lớp riêng).
- **Verify:** chụp `progress@dark complete-level-up@dark` → ô cây một tông.
- **DONE:** 2 ảnh đúng; `ArtCatalogTests` pass.

### T16 · Kết — Kiểm toàn bộ
- Chạy: Core `swift test`; App `xcodebuild test …`; `python3 tools/lint/copy_lint.py` → 0 findings; `python3 tools/i18n/apply_catalog.py vi --check` → 0 khoá thiếu; `LocalizationTests.screenWordsAreTranslated` pass.
- Chụp lại bộ 92 state (`capture_states.sh` theo 6 nhóm như review) vào `/tmp/gw-mobbin-fix/`, xem bằng mắt các màn đã sửa ở sáng, tối, `@xxl`.
- Ghi "Nhật ký sửa" vào cuối `docs/reviews/2026-10-02-mobbin-patterns.md` (bảng ID → đã sửa) và thêm dòng vào `app-context.md` Decisions log nếu chủ app chốt S1–S4.
- **DONE:** mọi lệnh xanh; đề xuất điểm commit với message sẵn (không commit nếu chủ app chưa yêu cầu).

---

## STOP-AND-ASK — không lên lịch, chờ chủ app

### S1 · M12 — Ô thứ ba trên bản đồ ngoài trời
Lựa chọn: (a) bỏ, còn distance · time; (b) "steps" từ `PedometerService` (`WorkoutSessionModel` đã có `outdoorDistance`; cần thêm `stepCount` provider); (c) giữ "min per mile". Đề xuất (b). Nếu (b): `OutdoorLiveMap.swift:119-145` `LiveStatsStrip(miles:seconds:steps:)`; nếu không có pedometer thì ẩn ô 3.

### S2 · **VƯỢT LUẬT DỰ ÁN** — Nhãn "Lowest monthly cost" trên gói Yearly
- Luật bị bẻ: Tone & copy "không hype"; bố cục paywall chốt D4 (30/09).
- Hợp nhóm: nhãn một chữ giúp quyết nhanh (uxpeak A/B 2 "Cheaper"); là sự thật số học, không bịa số, không gạch giá.
- Rủi ro: giọng bán hàng; nhãn phải tính từ `Product` (không cứng). **App Review:** không ảnh hưởng — Restore/Terms/Privacy, giá tính thật nổi nhất, không countdown, không giá gạch đều giữ.
- Nếu OK: `PaywallModel.badge(for:)` → `PlanOptionCard(badge:)` capsule `Palette.sky`/`onLightFill`, `.caption` semibold.

### S3 · **VƯỢT LUẬT DỰ ÁN** — "4 of 5 active days so far this week" trên dải tuần Today
- Luật bị bẻ: app-context "ngày hoạt động, không streak"; `weekLine` hiện chỉ đếm xuôi.
- Hợp nhóm: mục tiêu mềm kiểu Ten Percent Happier "10 of 14 days" không bao giờ "mất"; mẫu số = ngày không nghỉ trong kế hoạch.
- Rủi ro: tuần ốm thấy "1 of 5" vẫn là áp lực. Giảm: chỉ hiện khi ≥1 ngày tập, chữ "so far", không màu cảnh báo. **App Review:** không.
- Nếu OK: `TodayModel.weekLine` (`TodayModel.swift:284-287`) + test `weekAndJourneyLines`.

### S4 · **VƯỢT LUẬT DỰ ÁN** — "Try a 2-minute seated walk first" trên Welcome
- Luật bị bẻ: luồng onboarding 10 màn → paywall → buổi đầu (quyết định 27/09, 01/10).
- Hợp nhóm: A4 Tempo/Breathwrk; nhóm "video đi quá nhanh" tin app sau khi *nghe* 2 phút giọng dẫn; seated march an toàn khi chưa biết giới hạn cơ thể.
- Rủi ro: thêm nhánh luồng (player trước profile), phải quyết có ghi `WorkoutRecord` không; kéo dài đường tới paywall. **App Review:** không.
- Nếu OK: `WelcomeView.swift:22-25` nút phụ → `AppCover.workout(request: WorkoutRequest.trialWalk)` (2 phút, `.seated`, `.gentle`, không lưu), Complete rút gọn → quay lại `.goal`.

## Câu hỏi chưa giải quyết
1. S1: chọn (a)/(b)/(c)?
2. S2–S4: duyệt từng mục; mặc định không làm.
3. T8: `Goal.notSure` có cần dòng trong "Why this will work for you" không? Đề xuất không.
4. T10 xong có chụp lại 6 màn U2 (30/09) ở `@xxl` để xác nhận không? Đề xuất có, ghi vào T16.
