# Chương trình vững chân (Steady program) — kế hoạch 08/10/2026

**Goal:** trước khi phát hành 1.0, Good Footing có một lời hứa duy nhất ("vững chân hơn, đứng dậy khỏi ghế dễ hơn") được giữ bằng kế hoạch 12 tuần, tự kiểm tra 2 tuần một lần và biểu đồ so với chính mình; đi bộ, động tác với ghế, giãn cơ, hành trình giữ nguyên.
**Architecture:** logic mới nằm trong `GentleWalkCore` (lịch chương trình, thang số lần, lịch tự kiểm tra, so sánh kết quả, thông báo), test trước, chạy được bằng `swift test` cả trên Linux. App thêm SchemaV2 (trạng thái chương trình, kết quả tự kiểm tra) với migration nhẹ từ V1, một luồng tự kiểm tra (`fullScreenCover(item:)`), màn Kế hoạch (push từ Hôm nay), thẻ mới trên Hôm nay, biểu đồ mới trên Tiến bộ. Quyền Pro vẫn lấy từ `Transaction.currentEntitlements`; chương trình và tự kiểm tra miễn phí, thang số lần là Pro.
**Tech stack:** Swift 6 · SwiftUI · SwiftData · Swift Charts · AVFoundation (một `AVMutableComposition` + một `AVPlayer`) · UserNotifications · StoreKit 2
**Deployment target:** iOS 18.0 (iPhone + iPad) · Xcode 27 / SDK 27 — không dùng API mới hơn iOS 18
**Locales:** en-US, vi (cả hai đã có trong app) · RTL: không
**Inputs read:** app-context.md (07/10/2026), CLAUDE.md, reports/Chọn ngách cho Good Footing.md, research_notes/Chọn ngách cho Good Footing/feasibility_risk_codefit.md, docs/reviews/2026-10-06-chuyen-gia-ra-soat-bai-tap-58-75.md, bản vẽ https://claude.ai/artifact/WvZruzhCiPhASwSLYEhtER (màn mới + sơ đồ luồng), code: `WeeklyPlanner`, `SupportLadder`, `ChairSessionPlanner`, `SessionBuilder`, `NotificationPlanner`, `SchemaV1`, `MigrationPlan`, `SupportLadderStore`, `DataEraser`, `ProgressScreen` (`SitToStandChart`), `TodayModel`, `CaptureHook`
**Checkpoint 1 (08/10/2026, chủ app chốt):** làm **trước 1.0** · kế hoạch 12 tuần + tự kiểm tra + biểu đồ **miễn phí**; tăng số lần và bậc vịn theo khả năng là **Pro** · lần tự kiểm tra đầu (tuần 0) **sau buổi tập đầu tiên**, mời ở màn Hoàn thành, bỏ qua được · thanh thẻ giữ Hôm nay · Hành trình · Tiến bộ · Tôi (cách A, 08/10).
**Ngoài phạm vi:** viết lại bộ tự đếm ngồi–đứng (8.8, sau 1.0; bản 1.0 người dùng tự đếm) · đọc Walking Steadiness từ Apple Health · thử thách 15 ngày / sự kiện trong app · tai chi · AI chat.

## Sub-skill đã dùng khi lập kế hoạch
| Bước | Skill theo manh-skill-plan | Đã dùng |
|---|---|---|
| 1 Kiến trúc | `swiftui-specialist`, `swiftui-whats-new-27` | bản xuất Xcode 27 (superagents-lab/xcode27-skills): `structure.md` (mỗi phần màn hình một `struct: View`), `dataflow.md` (input hẹp, `@Observable` có thuộc tính `Equatable`, cache giá trị dẫn xuất), `localization.md` (interpolation, `LocalizedStringResource`, format style) |
| 2 Tuân thủ | `app-store-review-agent` | `references/compliance-by-design.md` + cruisediary/apple-app-review-skills (request-timing, push-notification, privacy-manifest) |
| 2 Paywall | `paywall-upgrade-cro` / `paywalls` | không đổi paywall; chỉ thêm một dòng giá trị Pro (thang số lần) — xem Task 3.12 |
| 2 Thói quen | `game-design` | dự phòng `references/architecture-decisions.md` §Behaviour: chương trình có điểm kết thúc, không có chuỗi có thể mất, so với chính mình |
| 3 Task test trước | `test-driven-development` | obra/superpowers `skills/test-driven-development` + `references/test-plan.md` |

## Lệnh dùng chung
| Tên | Lệnh | Kết quả mong đợi |
|---|---|---|
| `CORE <Suite>` | `swift test --package-path Packages/GentleWalkCore --filter <Suite>` (trong `iOS/`) | RED: `error: cannot find '<Type>' in scope` hoặc `Expectation failed:` · GREEN: `Test run with N tests in M suites passed` |
| `APP <Suite>` | `xcodebuild test -project GentleWalk.xcodeproj -scheme GentleWalk -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:GentleWalkTests/<Suite>` | `** TEST SUCCEEDED **` |
| `BUILD` | `xcodegen generate && xcodebuild build -project GentleWalk.xcodeproj -scheme GentleWalk -destination 'platform=iOS Simulator,name=iPhone 17'` | `** BUILD SUCCEEDED **`, 0 error |
| `SHOT <state>` | `xcrun simctl launch --terminate-running-process booted com.kmd.gentlewalk -ScreenshotMode <state> && xcrun simctl io booted screenshot /tmp/gf-<state>.png` | file PNG + inspect: nhãn, vùng chạm ≥ 56 pt |
| `L10N` | `python3 tools/i18n/apply_catalog.py vi --check && python3 iOS/scripts/xcstrings_coverage.py iOS/App/Localizable.xcstrings en,vi && python3 tools/lint/copy_lint.py` | `0 missing; 0 problems` · `missing: 0 needs_review/new: 0` (en, vi) · `0 findings` |
| `PY <file>` | `python3 -m unittest <file>` | `OK` |

Ghi chú môi trường: `CORE`, `L10N`, `PY` chạy được trên cloud (Linux, Docker `swift:6.2`); `APP`, `BUILD`, `SHOT` cần Mac của chủ app.

## Decisions (một dòng mỗi quyết định)
- **Chương trình là lớp trên lịch tuần, không thay lịch tuần:** chọn `ProgramCalendar` tính tuần 1–12 và chặng 1–4 từ ngày bắt đầu, `WeeklyPlanner` giữ nguyên nhịp ngày, thay vì viết lịch mới — vì lịch tuần đã test kỹ (Steady set, ngày nghỉ, free/Pro) và chặng chỉ đổi mục tiêu số lần, không đổi loại buổi.
- **Lên bậc theo khả năng, không theo lịch:** chặng là nhãn tiến độ; số lần và bậc vịn chỉ tăng khi làm đủ (Otago, WFG ≥ 12 tuần, tăng dần) — tránh ép người yếu theo tuần.
- **Thang số lần là mở rộng của `SupportLadder`:** chọn `RepLadder` cùng hình dạng (lên sau 2 buổi làm đủ không bấm Bị đau/Nghỉ, xuống khi bấm) và cùng chỗ lưu UserDefaults như `SupportLadderStore`, thay vì đưa vào SwiftData — vì vài giá trị nhỏ, đã có tiền lệ, "Xoá dữ liệu" đã quét UserDefaults.
- **Dữ liệu chương trình và tự kiểm tra trong SwiftData SchemaV2:** chọn hai `@Model` mới (`ProgramState`, `SelfCheckRecord`) + `MigrationStage.lightweight(V1→V2)` làm **trước khi phát hành** (chưa có dữ liệu thật để hỏng), thay vì UserDefaults — vì cần lịch sử, truy vấn theo ngày, và sau này có thể đổi cấu trúc bằng migration. `cloudKitDatabase: .none` giữ nguyên.
- **Tự kiểm tra do người dùng tự đếm:** app chỉ dẫn giọng, bấm giờ 30 giây, nhận số nhập tay (0–40) và cách làm (có/không chống tay); không dùng bộ tự đếm (8.8 chưa đủ chính xác cho người đứng dậy chậm).
- **Chỉ so với chính mình, cùng cách làm:** không lưu, không hiện bảng chuẩn theo tuổi, không nhãn "nguy cơ ngã"; chênh lệch chỉ tính giữa các lần cùng cách (có tay / không tay) — tránh ngôn ngữ sàng lọc lâm sàng (1.4.1, ranh giới FDA wellness).
- **Biểu đồ Tiến bộ:** thay `SitToStandChart` ("nhiều lần nhất trong một buổi") bằng biểu đồ kết quả tự kiểm tra — vì số lần trong buổi phụ thuộc bài được giao nên không so được; số trong buổi vẫn nằm ở lịch sử buổi tập.
- **Âm thanh tự kiểm tra:** một `AVMutableComposition` ngắn (câu dặn, đếm ngược, "Bắt đầu", 30 giây có chuông giữa chừng, "Dừng") phát bằng một `AVPlayer`, dùng lại `SessionAudioComposer` — đúng luật âm thanh của dự án; không âm im lặng.
- **Điều hướng (cách A):** màn Kế hoạch push từ thẻ trên Hôm nay bằng `navigationDestination(for: ProgramRoute.self)`; luồng tự kiểm tra là `fullScreenCover(item: SelfCheckRequest)`; thanh thẻ không đổi.
- **Miễn phí / Pro:** miễn phí: khung 12 tuần, màn Kế hoạch, tự kiểm tra, biểu đồ; Pro: `RepLadder` (số lần tăng theo khả năng), thang vịn (đã là Pro), 3 cường độ — paywall không đổi bố cục, chỉ thêm một dòng lợi ích.
- **Thông báo:** thêm loại `selfCheck` vào `NotificationPlanner`, vẫn tối đa 1 thông báo/ngày, không ghi tình trạng sức khoẻ trên màn khoá, tôn trọng cài đặt nhắc.
- **Analytics/backend:** không (giữ nguyên).
- **Android:** sau (không đổi).

## Compliance tasks (milestone 1 — bắt buộc)
| Quy tắc | # | Task | File | Bằng chứng |
|---|---|---|---|---|
| Không tuyên bố y khoa, không hứa phòng ngã | 1.4.1 | 1.1, 1.2 | `tools/lint/copy_lint.py`, `docs/design/steady-claims.md` | lint 0 findings; test lint bắt được cụm cấm |
| Đo lường sức khoẻ phải minh bạch | 1.4.1 | 1.3 | màn tự kiểm tra (Task 3.6) + `steady-claims.md` | ảnh chụp có dòng "Đây không phải bài kiểm tra y tế", không bảng chuẩn |
| An toàn người dùng khi tự kiểm tra | 1.4.1 | 3.6 | `SelfCheckIntroView.swift` | ảnh chụp có 4 lời dặn an toàn và nút "Để hôm khác" |
| Quyền xin đúng lúc | 5.1.1 | n/a | — | không thêm quyền mới (không dùng cảm biến, không đọc Health mới) |
| Thông báo không spam, có tắt được | 4.5.4 | 1.9, 3.13 | `NotificationPlanner.swift`, `NotificationSection.swift` | test: ≤ 1 thông báo/ngày; công tắc "Self-check reminders" trong Tôi |
| Privacy manifest | 5.1.1 | 1.4 | `PrivacyInfo.xcprivacy` | không thêm required-reason API mới (UserDefaults CA92.1 đã có) — trích manifest |
| App Privacy labels | 5.1.1 | 5.4 | `site/privacy.html` | câu "kết quả tự kiểm tra chỉ nằm trên điện thoại này"; nhãn ASC vẫn "Data Not Collected" |
| Paywall trio | 3.1.1/3.1.2 | n/a | — | paywall chỉ thêm một dòng lợi ích (3.12); Restore, Terms, Privacy, giá giữ nguyên — ảnh chụp đối chiếu |
| Khác biệt thấy ngay khi mở | 4.3 | 3.10 | Welcome | ảnh chụp: lời hứa 12 tuần + bản ngồi + giọng dẫn |

## Milestones
| # | Tên | Task | Bằng chứng cuối |
|---|---|---|---|
| 1 | Tuân thủ và luật câu chữ | 1.1–1.4 | lint xanh, file claims, manifest không đổi |
| 2 | Logic chương trình (core, TDD) | 2.1–2.12 (+2.7a) | `swift test` xanh toàn bộ (cloud + Mac) |
| 3 | Dữ liệu SchemaV2 | 3.1–3.4 | migration V1→V2 giữ nguyên số dòng; Xoá dữ liệu xoá cả bảng mới |
| 4 | Giao diện | 4.1–4.15 | ảnh chụp mọi trạng thái mới (danh sách cuối file), sáng/tối, cỡ chữ lớn, iPad |
| 5 | Nội dung, giọng, ngôn ngữ | 5.1–5.6 | `L10N` xanh; `ReleaseContentTests` xanh; QC giọng |
| 6 | Release skeleton | 6.1–6.4 | tài liệu release, privacy, app-context cập nhật |

## Tasks

### Milestone 1 — Tuân thủ và luật câu chữ

### Task 1.1 — Cụm từ cấm về ngã và y khoa trong lint (1.4.1) [TDD]
**Files:** Modify `tools/lint/copy_lint.py` · Test `tools/lint/test_copy_lint.py`
**Steps:**
1. Thêm test `test_flags_fall_prevention_claims`: các câu "prevents falls", "fall prevention", "reduce your fall risk", "lower fall risk", "builds bone", "relieves knee pain" bị bắt; câu nhắc đi khám "Had a fall recently, or fainted…? Check with your doctor first." **không** bị bắt (đã có trong app).
2. Chạy → expected: `FAIL: test_flags_fall_prevention_claims`
3. Thêm các mẫu vào danh sách cấm (chỉ cụm từ, không cấm chữ "fall" đơn lẻ).
4. Chạy lại cả lint trên repo.
**Command:** `PY tools/lint/test_copy_lint.py` → expected: `OK`; `python3 tools/lint/copy_lint.py` → `0 findings`
**Evidence:** DONE 08/10 — RED `FAIL: test_flags_fall_prevention_claims` → GREEN `Ran 7 tests … OK`; `copy_lint.py` → `0 findings`
**Commit point:** `test(lint): ban fall-prevention and treatment claims`

### Task 1.2 — Bảng câu được nói / không được nói (1.4.1) [DATA]
**Files:** Create `docs/design/steady-claims.md`
**Steps:**
1. Hai cột "Được nói" (steadier, stronger legs, get up from a chair more easily, at your own pace, compared only with yourself) / "Không nói" (prevent falls, fall risk, reduce falls, build bone, treat/relieve pain, below normal for your age), mỗi dòng ghi nguồn trong `reports/Chọn ngách cho Good Footing.md` hoặc `research_notes/…/feasibility_risk_codefit.md`.
2. Ghi rõ: chưa có luật sư duyệt; đưa luật sư nhãn hiệu xem cùng tên app.
**Command:** `grep -c "|" docs/design/steady-claims.md` → expected: ≥ 12 dòng bảng
**Evidence:** DONE 08/10 — `docs/design/steady-claims.md`: 10 dòng bảng + câu cố định; nguồn: báo cáo mục 7, feasibility notes
**Commit point:** `docs(design): steady program claims list`

### Task 1.3 — Văn bản minh bạch của tự kiểm tra (1.4.1) [DATA]
**Files:** Modify `docs/design/steady-claims.md` · Modify `docs/scripts/D-min-texts.md`
**Steps:**
1. Viết 3 câu cố định: "This is not a medical test." · "You compare only with yourself." · "Stop if anything hurts or you feel dizzy." (EN) kèm bản VI theo `docs/i18n/glossary-vi.md`.
2. Ghi vào D-min-texts mục Self-check để Task 4.6 dùng nguyên văn.
**Command:** `python3 tools/lint/copy_lint.py` → expected: `0 findings`
**Evidence:** DONE 08/10 — 3 câu EN/VI trong `steady-claims.md` và `D-min-texts.md` §D10; lint `0 findings`
**Commit point:** `docs(copy): self-check transparency lines`

### Task 1.4 — Privacy manifest không đổi (5.1.1) [DATA]
**Files:** Read `iOS/App/PrivacyInfo.xcprivacy`
**Steps:**
1. Xác nhận các API mới (SwiftData, UserDefaults cho `RepLadderStore`, AVFoundation) không thêm required-reason mới ngoài `CA92.1` đã có.
2. Ghi một dòng bằng chứng (trích manifest) vào kế hoạch.
**Command:** `grep -n "CA92.1" iOS/App/PrivacyInfo.xcprivacy` → expected: 1 dòng
**Evidence:** DONE 08/10 — `PrivacyInfo.xcprivacy:18` `CA92.1` (UserDefaults) đã có; không API required-reason mới, file không đổi
**Commit point:** — (không đổi file)

### Milestone 2 — Logic chương trình (GentleWalkCore, TDD)

### Task 2.1 — Tuần và chặng của chương trình [TDD]
**Files:** Create `Packages/GentleWalkCore/Sources/GentleWalkCore/Program/ProgramCalendar.swift` · Test `Packages/GentleWalkCore/Tests/GentleWalkCoreTests/ProgramCalendarTests.swift`
**Steps:**
1. `@Test func weekAndStageFromStartDate()`: bắt đầu thứ Tư 08/10/2026; ngày 08/10 → tuần 1 chặng 1; 29/10 → tuần 4 chặng 2; 24/12 → tuần 12 chặng 4; 31/12 → `.finished`.
2. Chạy → expected: `error: cannot find 'ProgramCalendar' in scope`
3. Implement `public enum ProgramStage: Int, CaseIterable { case base = 1, build, challenge, routine }` và `public enum ProgramCalendar { static func position(start: Date, on: Date, pausedDays: Int, calendar: Calendar) -> ProgramPosition }` với `ProgramPosition { case week(Int, ProgramStage), finished }`; chặng = tuần 1–3, 4–6, 7–9, 10–12.
4. Chạy → GREEN.
**Command:** `CORE ProgramCalendarTests` → expected: `Test weekAndStageFromStartDate() passed`
**Evidence:** DONE 08/10 — RED `cannot find type 'ProgramRound' in scope` → GREEN `Test weekAndStageFromStartDate() passed`
**Commit point:** `feat(core): program calendar with four stages`

### Task 2.2 — Múi giờ và giờ mùa hè [TDD]
**Files:** Test `ProgramCalendarTests.swift` · Modify `ProgramCalendar.swift`
**Steps:**
1. `@Test(arguments:)` với `America/New_York` qua 02/11/2026 (hết giờ mùa hè) và `America/Los_Angeles`; bắt đầu 23:30 vẫn tính cùng ngày lịch.
2. Chạy → expected RED nếu tính theo giây; sửa thành `calendar.dateComponents([.day], from: startOfDay, to: startOfDay)`.
**Command:** `CORE ProgramCalendarTests` → expected: `passed`
**Evidence:** DONE 08/10 — RED `Expectation failed … .week(2…) == .week(1…)` (NY, LA, bắt đầu 23:30) → GREEN sau khi đếm ngày lịch
**Commit point:** `test(core): program weeks across DST`

### Task 2.3 — Nghỉ dài thì tiếp tục, không phạt [TDD]
**Files:** Test `ProgramCalendarTests.swift` · Modify `ProgramCalendar.swift`
**Steps:**
1. `@Test func longGapOffersPickUp()`: không có buổi tập ≥ 14 ngày → `ProgramCalendar.resumeOffer(lastWorkout:now:)` trả về `.pickUp(atWeek: w)` với w = tuần của buổi cuối; < 14 ngày → `nil`.
2. RED → implement `resumeOffer` và `pausedDays` cộng thêm khi người dùng chọn "Tiếp tục từ tuần w".
**Command:** `CORE ProgramCalendarTests` → expected: `Test longGapOffersPickUp() passed`
**Evidence:** DONE 08/10 — RED `no member 'resumeOffer'` → GREEN `longGapOffersPickUp() passed`; dừng tuần 8 rồi quay lại sau 12 tuần vẫn được mời tuần 8 (sửa kỳ vọng test, hợp ý "không bao giờ mất")
**STOP AND ASK:** nghỉ bao lâu thì hỏi "tiếp tục từ tuần đó"? (mặc định: 14 ngày; không tự lùi lịch, không bao giờ nói "mất")
**Commit point:** `feat(core): pick up the program after a long break`

### Task 2.4 — Kết thúc và làm lại chương trình [TDD]
**Files:** Test `ProgramCalendarTests.swift` · Modify `ProgramCalendar.swift`
**Steps:**
1. `@Test func restartKeepsHistory()`: sau `.finished`, `restart(on:)` trả về ngày bắt đầu mới, `round` tăng 1; lịch sử tự kiểm tra không bị đụng (kiểu thuần, không xoá gì).
2. RED → implement `ProgramRound { start: Date; round: Int; pausedDays: Int }`.
**Command:** `CORE ProgramCalendarTests` → expected: `passed`
**Evidence:** DONE 08/10 — GREEN `restartKeepsCountingRounds() passed` (round 2, pausedDays 0)
**Commit point:** `feat(core): program rounds`

### Task 2.5 — Thang số lần theo khả năng (Pro) [TDD]
_Sửa 08/10/2026 (chủ app chốt "dựng sẵn các bậc khi build"): câu đếm của HLV được dựng sẵn theo số lần, nên mỗi bậc là một đoạn nội dung riêng (Task 2.7a); bài Nhón gót là bài tính giờ nên không vào thang._
**Files:** Create `Packages/GentleWalkCore/Sources/GentleWalkCore/Plan/RepLadder.swift` · Test `…/RepLadderTests.swift`
**Steps:**
1. `@Test func raisesAfterTwoFullSessions()`: Ngồi xuống đứng lên 1×6 → 1×8 → 1×10 → 2×8 → 2×10 (trần), lên sau 2 buổi làm đủ không bấm Bị đau/Nghỉ; bậc đã làm trong buổi được ghi nhận (`done`).
2. `@Test func dropsOneStepOnTrouble()`: bấm Bị đau hoặc Nghỉ trong bài đó → xuống một bậc so với bậc đã làm, đếm lại từ 0.
3. RED → implement `RepStep(sets:reps:)`, `RepProgress(step:fullSessions:pendingChange:)`, `RepLadder.steps(for:)`, `RepLadder.update(_:done:steady:troubled:)`.
**Command:** `CORE RepLadderTests` → expected: `passed`
**Evidence:** DONE 08/10 — RED `cannot find 'RepStep' in scope` → GREEN 4 test `RepLadderTests` (lên sau 2 buổi, xuống khi Bị đau/Nghỉ, bỏ qua bài ngoài thang)
**STOP AND ASK (đã chốt 08/10):** Ngồi xuống đứng lên 6 → 8 → 10 → 2×8 → 2×10; Khuỵu gối nhẹ và Nâng chân sang ngang 8 → 10 → 12 → 2×10; nghỉ 60 giây giữa hiệp.
**Commit point:** `feat(core): rep ladder for leg-strength moves`

### Task 2.6 — Trần theo cường độ và giới hạn cơ thể [TDD]
**Files:** Test `RepLadderTests.swift` · Modify `RepLadder.swift`
**Steps:**
1. `@Test func achyDayCapsReps()`: bậc hôm nay = max(bậc đã đạt, bậc mặc định của cường độ), không quá mặc định + 1 bậc; ngày Hơi nhức Ngồi xuống đứng lên tối đa 8. `@Test func unsteadyKeepsTheDefault()`: chip unsteady/dizzy → không lên quá trần của ngày Hơi nhức.
2. RED → implement `RepLadder.today(_:progress:intensity:limits:) -> RepStep`.
**Command:** `CORE RepLadderTests` → expected: `passed`
**Evidence:** DONE 08/10 — RED `cannot infer contextual base … 'gentle'` → GREEN `achyDayCapsReps()`, `unsteadyKeepsTheDefault()` (6 test)
**Commit point:** `feat(core): cap reps by intensity and limits`

### Task 2.7a — Dựng sẵn các bậc số lần trong nội dung [TDD]
**Files:** Modify `tools/content/sessions_chair.py` (`rep_move` nhận `reps`/`sets`; hàm `rep_variants(voice)` tạo template `ses.reps.<exerciseID>.<sets>x<reps>`), `iOS/App/Resources/Content/sessions.json` (sinh lại) · Test `Packages/GentleWalkCore/Tests/GentleWalkCoreTests/SessionCatalogTests.swift` (`@Test func everyRepStepHasAVariant()`)
**Steps:**
1. Test: mỗi `RepLadder.steps(for:)` của 3 bài có template `ses.reps.…` trong nội dung, segment đúng `reps`/`sets`.
2. RED → sinh nội dung bằng câu đếm đã thu (`a5.n.1–15`, `a4.v1.rest`, `a4.v1.set2`); không thu giọng mới.
3. `python3 tools/content/build_content.py` rồi `--check`.
**Command:** `CORE SessionCatalogTests` + `SessionSyncTests` → expected: `passed`; `build_content.py --check` → exit 0
**Evidence:** DONE 08/10 — RED `MissingTemplate(id: "ses.reps.mv.sit-to-stand.1x6")` → `build_content.py` (sessions.json 47 → 60, chỉ thêm) → GREEN `everyRepStepHasAVariant()`; `--check` exit 0; `SessionSyncTests` 325 plans, lệch xấu nhất không đổi (en 2,32 s, vi 2,91 s)
**Commit point:** `feat(content): pre-built rep steps for leg moves`

### Task 2.7 — Buổi tập dùng số lần đã đạt (Pro), mặc định cho free [TDD]
**Files:** Modify `Packages/GentleWalkCore/Sources/GentleWalkCore/Plan/ChairSessionPlanner.swift`, `SessionBuilder.swift` (`repProgress`, `entitlement` trong `SessionBuilder.Context`) · Test `SessionBuilderTests.swift`
**Steps:**
1. `@Test func proChairDayUsesEarnedReps()` và `@Test func freeChairDayUsesIntensityDefaults()`.
2. RED → Pro: segment của bài trong thang thay bằng segment của template `ses.reps.…` theo `RepLadder.today`; free giữ nguyên.
**Command:** `CORE SessionBuilderTests` → expected: `passed` (test cũ vẫn xanh)
**Evidence:** DONE 08/10 — RED `extra argument 'reps' in call` → GREEN `proChairDayUsesEarnedReps()`, `freeChairDayUsesIntensityDefaults()`; 27 test SessionBuilder xanh
**Commit point:** `feat(core): sessions use earned reps for Pro`

### Task 2.8 — Lịch tự kiểm tra [TDD]
**Files:** Create `Packages/GentleWalkCore/Sources/GentleWalkCore/Progress/SelfCheck.swift` · Test `…/SelfCheckScheduleTests.swift`
**Steps:**
1. `@Test func firstCheckAfterFirstWorkout()`: chưa có buổi tập → không có lịch; sau buổi đầu → `.invite` (tuần 0); bỏ qua → nhắc lại trên Hôm nay sau 2 ngày.
2. `@Test func everyTwoWeeksWithWindow()`: kết quả ngày D → lần sau D+14, cửa sổ D+12…D+17; quá hạn > 3 ngày → `.overdue` (không có chữ "trễ" trên giao diện, chỉ "khi nào bạn sẵn sàng").
3. RED → implement `public enum SelfCheckSchedule { static func status(firstWorkout: Date?, results: [Date], dismissedAt: Date?, now: Date, calendar: Calendar) -> SelfCheckStatus }` với `.none, .invite, .dueIn(days:), .due, .overdue`.
**Command:** `CORE SelfCheckScheduleTests` → expected: `Test run with 2 tests … passed`
**Evidence:** DONE 08/10 — RED `cannot find type 'SelfCheckStatus'` → GREEN `firstCheckAfterFirstWorkout()`, `everyTwoWeeksWithWindow()`
**Commit point:** `feat(core): self-check schedule`

### Task 2.9 — So sánh chỉ với chính mình, cùng cách làm [TDD]
**Files:** Modify `SelfCheck.swift` · Test `…/SelfCheckComparisonTests.swift`
**Steps:**
1. `@Test func deltaOnlyAgainstSameMethod()`: lần đầu → `nil`; 7 (có tay) rồi 9 (có tay) → +2; 9 (không tay) sau 7 (có tay) → `nil` + cờ `newMethodBaseline`.
2. `@Test func rejectsOutOfRange()`: số < 0 hoặc > 40 không lưu.
3. RED → implement `public struct SelfCheckResult: Codable, Equatable { date: Date; count: Int; usedHands: Bool }` và `SelfCheckComparison.delta(latest:history:)`.
**Command:** `CORE SelfCheckComparisonTests` → expected: `passed`
**Evidence:** DONE 08/10 — GREEN `deltaOnlyAgainstSameMethod()`, `rejectsOutOfRange()` (so lần đầu và lần trước, cùng cách)
**Commit point:** `feat(core): compare self-checks with yourself only`

### Task 2.10 — Không có bảng chuẩn, không nhãn nguy cơ [TDD]
**Files:** Test `SelfCheckComparisonTests.swift`
**Steps:**
1. `@Test func noNormsOrRiskLabels()`: kiểu `SelfCheckComparison` không có thuộc tính tuổi/chuẩn/nguy cơ (test bằng `Mirror` liệt kê thuộc tính), và chuỗi khoá nội dung không chứa "risk", "normal", "below average".
**Command:** `CORE SelfCheckComparisonTests` → expected: `Test noNormsOrRiskLabels() passed`
**Evidence:** DONE 08/10 — GREEN `noNormsOrRiskLabels()`
**Commit point:** `test(core): guard against norms and risk labels`

### Task 2.11 — Thông báo ngày tự kiểm tra [TDD]
**Files:** Modify `Packages/GentleWalkCore/Sources/GentleWalkCore/Notifications/NotificationPlanner.swift` (thêm `NotificationKind.selfCheck`, `NotificationSettings.selfCheckReminders`, `PlannerInput.selfCheckDue`) · Test `NotificationPlannerTests.swift`
**Steps:**
1. `@Test func selfCheckReminderOnDueDay()`; `@Test func selfCheckNeverDoublesUp()` (cùng ngày với nhắc tập → chỉ một, theo `priority`); `@Test func selfCheckRespectsSetting()`.
2. RED: `error: type 'NotificationKind' has no member 'selfCheck'`
3. Implement; `priority` đặt sau `trialEnd`, trước `reminder`.
**Command:** `CORE NotificationPlannerTests` → expected: toàn bộ `passed`
**Evidence:** DONE 08/10 — RED `no member 'selfCheck'` → GREEN 4 test mới (đúng ngày, không trùng, tắt được, cài đặt cũ vẫn đọc được); 19 test thông báo xanh
**Commit point:** `feat(core): self-check reminder`

### Task 2.12 — Toàn bộ core xanh [TDD]
**Files:** —
**Steps:** chạy toàn bộ test core; trên cloud dùng Docker `swift:6.2` (cách đã dùng 07/10).
**Command:** `swift test --package-path Packages/GentleWalkCore` → expected: `Test run with N tests in M suites passed` (N ≥ 145 + test mới)
**Evidence:** DONE 08/10 — Docker `swift:6.2-noble`: `Test run with 187 tests in 39 suites passed` (mốc đầu 164)
**Commit point:** —

### Milestone 3 — Dữ liệu SchemaV2

### Task 3.1 — SchemaV2 với hai model mới [DATA]
**Files:** Create `iOS/App/Persistence/SchemaV2.swift` · Modify `iOS/App/Persistence/MigrationPlan.swift`, `ModelContainerFactory.swift` · Test `iOS/GentleWalkTests/PersistenceTests.swift`
**Steps:**
1. `@Test func v2HasProgramAndSelfCheck()`: container in-memory với `SchemaV2` lưu được `ProgramState(start:round:pausedDays:finishedAt:)` và `SelfCheckRecord(id:date:count:usedHands:week:)`.
2. RED: `error: cannot find 'SchemaV2' in scope`
3. `SchemaV2` gồm mọi model V1 (copy nguyên) + 2 model mới; `GentleWalkMigrationPlan.schemas = [SchemaV1.self, SchemaV2.self]`, `stages = [.lightweight(fromVersion: SchemaV1.self, toVersion: SchemaV2.self)]`; không xoá `SchemaV1`.
**Command:** `APP PersistenceTests` → expected: `** TEST SUCCEEDED **`
**Evidence:** VIẾT XONG, CHƯA BUILD (cloud 08/10): `SchemaV2.swift`, `MigrationPlan.swift`, test `v2HasProgramAndSelfCheck` — chạy `APP PersistenceTests` trên Mac
**Commit point:** `feat(data): schema v2 for program and self-checks`

### Task 3.2 — Migration V1 → V2 giữ nguyên dữ liệu [DATA]
**Files:** Test `PersistenceTests.swift` · Create `iOS/GentleWalkTests/Fixtures/store-v1/` (store tạo bằng test)
**Steps:**
1. `@Test func migratesV1StoreKeepingRows()`: tạo store V1 ở URL tạm, ghi 1 `UserProfile`, 5 `WorkoutRecord`, 1 `JourneyState`; mở lại bằng plan V2; đếm: 1 / 5 / 1, `ProgramState` = 0.
2. RED trước khi có stage → GREEN sau Task 3.1.
**Command:** `APP PersistenceTests` → expected: `** TEST SUCCEEDED **` + số dòng trước/sau trong log test
**Evidence:** VIẾT XONG, CHƯA BUILD: test `migratesV1StoreKeepingRows` (store V1 ở URL tạm, mở lại bằng plan V2) — chạy `APP PersistenceTests`
**Commit point:** `test(data): v1 to v2 migration keeps rows`

### Task 3.3 — Lưu thang số lần [DATA]
**Files:** Create `iOS/App/Services/Data/RepLadderStore.swift` (theo `SupportLadderStore`) · Modify `iOS/App/Services/Data/DataEraser.swift` (thêm khoá) · Test `iOS/GentleWalkTests/RepLadderStoreTests.swift` (`@Suite(.serialized)`)
**Steps:**
1. `@Test func roundTripsProgress()`, `@Test func eraseClearsRepLadder()`.
2. RED → implement `@MainActor struct RepLadderStore { init(defaults:); func load() -> [String: RepProgress]; func save(_:) }`, khoá vào `AppDefaultsKeys`.
**Command:** `APP RepLadderStoreTests` → expected: `** TEST SUCCEEDED **`
**Evidence:** VIẾT XONG, CHƯA BUILD: `RepLadderStore.swift` (+ `today(intensity:limits:isPro:)`), `RepLadderStoreTests.swift` — chạy `APP RepLadderStoreTests`
**Commit point:** `feat(data): rep ladder store`

### Task 3.4 — "Xoá dữ liệu" xoá cả chương trình và tự kiểm tra [DATA]
**Files:** Modify `DataEraser.swift` · Test `DataEraserTests.swift`
**Steps:**
1. `@Test func eraseRemovesProgramAndChecks()`: sau xoá, `ProgramState` = 0, `SelfCheckRecord` = 0.
2. RED → thêm hai model vào danh sách xoá.
**Command:** `APP DataEraserTests` → expected: `** TEST SUCCEEDED **`
**Evidence:** VIẾT XONG, CHƯA BUILD: `DataEraser` xoá `ProgramState`, `SelfCheckRecord`, khoá `repLadder`, `selfCheckDismissedAt` — chạy `APP DataEraserTests`
**Commit point:** `fix(data): erase program and self-check data`

### Milestone 4 — Giao diện

### Task 4.1 — Dữ liệu mẫu cho ảnh chụp [DATA]
**Files:** Modify `iOS/App/Debug/Fixtures/en-US.json`, `iOS/App/Debug/CaptureHook.swift` (thêm trạng thái: `today-program`, `today-check-due`, `program`, `selfcheck-intro`, `selfcheck-timer`, `selfcheck-count`, `progress-checks`, `complete-check-invite`, `complete-level-up`, `program-finished`) · Test `CaptureHookTests.swift`
**Steps:**
1. Margaret bắt đầu 17/09/2026 (tuần 3 chặng 1 vào 08/10), 2 lần tự kiểm tra (7 rồi 8, có chống tay), `mv.sit-to-stand` ở bậc 2×6.
2. Test: mỗi trạng thái mới có trong `CaptureState.allCases` và seed được.
**Command:** `APP CaptureHookTests` → expected: `** TEST SUCCEEDED **`
**Evidence:** VIẾT XONG, CHƯA BUILD: 10 trạng thái (`complete-reps-up` thay `complete-level-up` vì tên cũ đã có), fixture `programStartDaysAgo` + `selfChecks`, test `steadyProgramStatesParse`, số trạng thái 99 → 109 — chạy `APP CaptureHookTests`
**Commit point:** `chore(debug): capture states for steady program`

### Task 4.2 — Today: dữ liệu thẻ chương trình và thẻ tự kiểm tra [TDD]
**Files:** Modify `iOS/App/Features/Today/TodayModel.swift` · Test `TodayModelTests.swift`
**Steps:**
1. `@Test func programStripShowsWeekAndStage()` ("Week 3 of 12", "Stage 1 · Steady base"); `@Test func checkCardFollowsSchedule()` (`.dueIn(5)` → "Your 2-week check is in 5 days"; `.none` → không có thẻ).
2. RED → thêm `programStrip: ProgramStripState?`, `checkCard: SelfCheckStatus?` (kiểu `Equatable`, tính khi tải, không tính trong `body`).
**Command:** `APP TodayModelTests` → expected: `** TEST SUCCEEDED **`
**Evidence:** VIẾT XONG, CHƯA BUILD: `ProgramStripState`, `checkCard`, `checkTitle`; test `programStripShowsWeekAndStage`, `longBreakOffersToPickUp`, `checkCardFollowsSchedule` — chạy `APP TodayModelTests`
**Commit point:** `feat(today): program strip and self-check card state`

### Task 4.3 — Today: hai thẻ mới [UI]
**Files:** Modify `iOS/App/Features/Today/TodayCards.swift` (thêm `struct ProgramStripCard: View`, `struct SelfCheckCard: View`), `TodayView.swift`
**Steps:**
1. Đặt thẻ chương trình dưới dòng lời chào, thẻ tự kiểm tra dưới thẻ buổi tập, thẻ hành trình giữ nguyên (theo bản vẽ màn 2).
2. `BUILD` → 3. `SHOT today-program`, `SHOT today-check-due` → 4. inspect.
**Command:** `BUILD`; `SHOT today-program` → expected: ảnh có "Week 3 of 12", "Plan ›", thẻ buổi tập với Achy/Okay/Great, thẻ hành trình; vùng chạm ≥ 56 pt
**Evidence:** VIẾT XONG, CHƯA BUILD: `ProgramStripCard`, `SelfCheckCard` — cần `SHOT today-program`, `SHOT today-check-due`
**Commit point:** `feat(today): program strip and self-check cards`

### Task 4.4 — Màn Kế hoạch 12 tuần [UI]
**Files:** Create `iOS/App/Features/Program/ProgramView.swift` (`ProgramStageList`, `SelfCheckDots` là `struct` riêng) · Modify `iOS/App/Features/Root/MainTabView.swift` (`navigationDestination(for: ProgramRoute.self)` trong stack của Hôm nay)
**Steps:**
1. 4 chặng (tên, tuần, mô tả), chặng hiện tại viền xanh, 7 mốc tự kiểm tra, dòng "general fitness, not medical advice".
2. `BUILD` → `SHOT program` → inspect.
**Command:** `SHOT program` → expected: ảnh khớp màn 3 của bản vẽ; nhãn "Back", "Your 12-week plan"
**Evidence:** VIẾT XONG, CHƯA BUILD: `Features/Program/ProgramView.swift`; dùng `TodayRoute.program` (không tạo kiểu `ProgramRoute` riêng, cùng stack Hôm nay) — cần `SHOT program`
**Commit point:** `feat(program): 12-week plan screen`

### Task 4.5 — Mô hình luồng tự kiểm tra [TDD]
**Files:** Create `iOS/App/Features/SelfCheck/SelfCheckFlowModel.swift` · Test `iOS/GentleWalkTests/SelfCheckFlowModelTests.swift`
**Steps:**
1. `@Test func flowIntroTimerCountSave()`: intro → timer (30 s, đồng hồ tiêm vào) → count (mặc định = lần trước cùng cách, hoặc 8) → save tạo 1 `SelfCheckRecord`; `@Test func notTodayDismisses()`; `@Test func countStaysInRange()`.
2. RED → implement `@Observable @MainActor final class SelfCheckFlowModel { var step: Step; var count: Int; var usedHands: Bool; func save(in: ModelContext) }`.
**Command:** `APP SelfCheckFlowModelTests` → expected: `** TEST SUCCEEDED **`
**Evidence:** VIẾT XONG, CHƯA BUILD: `SelfCheckFlowModel.swift`, 6 test trong `SelfCheckFlowModelTests.swift` — chạy `APP SelfCheckFlowModelTests`
**Commit point:** `feat(selfcheck): flow model`

### Task 4.6 — Màn chuẩn bị (an toàn) [UI]
**Files:** Create `iOS/App/Features/SelfCheck/SelfCheckIntroView.swift` · Modify `iOS/App/Features/Root/AppCover.swift` (case `.selfCheck`)
**Steps:**
1. 4 lời dặn an toàn, 3 bước, "I'm ready", "Not today", dòng "This is not a medical test." (nguyên văn Task 1.3).
2. `SHOT selfcheck-intro` → inspect.
**Command:** `SHOT selfcheck-intro` → expected: ảnh khớp màn 5 bản vẽ; nhãn đủ 4 lời dặn
**Evidence:** VIẾT XONG, CHƯA BUILD: `SelfCheckIntroView` (trong `SelfCheckViews.swift`), `AppCover.selfCheck` — cần `SHOT selfcheck-intro`
**Commit point:** `feat(selfcheck): safety intro`

### Task 4.7 — Âm thanh 30 giây [TDD]
**Files:** Modify `iOS/App/Services/Audio/SessionAudioComposer.swift` (hàm `selfCheckTimeline()`) · Test `SessionAudioComposerTests.swift`
**Steps:**
1. `@Test func selfCheckCompositionIs30sWithCues()`: composition có câu dặn, đếm ngược 3-2-1, "Go" ở 0 s, chuông ở 15 s, "Stop" ở 30 s; tổng ≤ 40 s; một track giọng, một track chuông.
2. RED → implement bằng `SessionTimeline` có sẵn.
**Command:** `APP SessionAudioComposerTests` → expected: `** TEST SUCCEEDED **`
**Evidence:** Core XANH (cloud 08/10, Docker swift 6.2): `SessionTimeline.selfCheck` + `SelfCheckTimelineTests` (3 test). App VIẾT XONG, CHƯA BUILD: `SelfCheckAudioPlayer.swift`, test `selfCheckCompositionIs30sWithCues` — chạy `APP SessionAudioComposerTests`. Chưa thu giọng thì chuông + chữ (tự động)
**STOP AND ASK:** bản 1.0 dùng câu HLV thu sẵn hay chỉ chuông + chữ trên màn? (mặc định: câu HLV; nếu chưa thu kịp thì chuông + chữ, cờ trong `ReleaseContentTests`)
**Commit point:** `feat(audio): self-check timeline`

### Task 4.8 — Màn bấm giờ [UI]
**Files:** Create `iOS/App/Features/SelfCheck/SelfCheckTimerView.swift`
**Steps:**
1. Đồng hồ lớn 0:30 → 0:00 (`Text(timerInterval:)` hoặc giá trị từ model), nút "Stop early", "This hurts" luôn hiện; Reduce Motion: không hiệu ứng.
2. `SHOT selfcheck-timer` → inspect.
**Command:** `SHOT selfcheck-timer` → expected: ảnh có đồng hồ, "Stop early", "This hurts"
**Evidence:** VIẾT XONG, CHƯA BUILD: `SelfCheckTimerView` — cần `SHOT selfcheck-timer` (đồng hồ chạy thật, bắt đầu lùi 20 s)
**Commit point:** `feat(selfcheck): timer screen`

### Task 4.9 — Màn nhập số [UI]
**Files:** Create `iOS/App/Features/SelfCheck/SelfCheckCountView.swift`
**Steps:**
1. Nút − / + 72 pt, số lớn có `accessibilityValue`, hai lựa chọn "Yes, with my hands" / "No" (`accessibilityAddTraits(.isSelected)`), "Last time: 8", "Save", "Do the 30 seconds again".
2. `SHOT selfcheck-count` → inspect (VoiceOver đọc được số và lựa chọn).
**Command:** `SHOT selfcheck-count` → expected: ảnh khớp màn 6 bản vẽ; vùng chạm ≥ 56 pt
**Evidence:** VIẾT XONG, CHƯA BUILD: `SelfCheckCountView` (+ `CountStepper` 72 pt, adjustable) — cần `SHOT selfcheck-count`
**Commit point:** `feat(selfcheck): count entry`

### Task 4.10 — Tiến bộ: biểu đồ tự kiểm tra thay biểu đồ cũ [UI]
**Files:** Modify `iOS/App/Features/Progress/ProgressScreen.swift` (thay `SitToStandChart` bằng `struct SelfCheckChart: View`), `iOS/App/Features/Root/Snapshots.swift` (`ProgressSnapshot.selfChecks`)
**Steps:**
1. Cột theo từng lần kiểm tra (Week 0, 2, 4…), dòng "+2 since your first check" chỉ khi cùng cách; trống: "Your first check comes after your first session."; `accessibilityLabel` liệt kê các lần.
2. Thêm `struct SupportLevelsCard: View` (bậc vịn từng bài thăng bằng) — Pro thấy bậc, free thấy "Two hands" + một dòng Pro.
3. `SHOT progress-checks`.
**Command:** `SHOT progress-checks` → expected: ảnh khớp màn 7 bản vẽ (số mẫu 7, 8, 9)
**Evidence:** VIẾT XONG, CHƯA BUILD: `SelfCheckChart`, `SupportLevelsCard`; `ProgressSnapshot.sitToStand` → `selfChecks` — cần `SHOT progress-checks`
**Commit point:** `feat(progress): self-check chart and support levels`

### Task 4.11 — Màn đang tập: nhãn bậc vịn và số lần [UI]
**Files:** Modify `iOS/App/Features/Workout/Shared/MoveGuidance.swift`, `iOS/App/Features/Workout/Chair/ChairPlayerView.swift`
**Steps:**
1. Nhãn trên nền `sky` "One hand on the chair" cho bài trong `SupportLadder.exercises`; dòng "2 × 8" cho bài trong `RepLadder.exercises`; thêm cặp chữ-trên-nền vào `Palette.textPairs` nếu mới.
2. `SHOT chair-player` và `SHOT chair-player-dark` → inspect; `APP DesignTokenTests`.
**Command:** `APP DesignTokenTests` → expected: `** TEST SUCCEEDED **`; ảnh có nhãn bậc vịn
**Evidence:** VIẾT XONG, CHƯA BUILD: `LadderLabels` (chữ `onLightFill` trên `sky`, cặp đã có trong `Palette.textPairs`), `ChairPlayerModel.supportLabel/repsLabel`; `WorkoutRequest.reps` → `SessionBuilder.build(reps:)` — cần `SHOT chair-player`, `APP DesignTokenTests`
**Commit point:** `feat(player): show support level and reps`

### Task 4.12 — Màn Hoàn thành: mời tự kiểm tra tuần 0, báo lên bậc [UI]
**Files:** Modify `iOS/App/Features/Workout/Complete/CompleteContent.swift`, `CompleteView.swift`
**Steps:**
1. Sau buổi đầu: thẻ "Want to see where you start? 30 seconds." với "Let's do it" / "Later" (không chặn luồng xin quyền Health/thông báo — thẻ nằm sau bước xin quyền).
2. Khi `RepLadder`/`SupportLadder` có `pendingChange == .up` hoặc sang chặng mới: một dòng gợi ý, không ép.
3. `SHOT complete-check-invite`, `SHOT complete-level-up`.
**Command:** ảnh có đúng thẻ mời và dòng lên bậc
**Evidence:** VIẾT XONG, CHƯA BUILD: `SelfCheckInviteCard`, `LevelUpLine`, `LevelUpText`; mời sau màn xin quyền (`afterOneTimeScreens`) — cần `SHOT complete-check-invite`, `SHOT complete-reps-up`
**Commit point:** `feat(complete): week-0 check invite and level-up line`

### Task 4.13 — Welcome và màn Kế hoạch sẵn sàng nói lời hứa mới [UI]
**Files:** Modify `iOS/App/Features/Onboarding/WelcomeView.swift` (dòng đầu "A 12-week plan for stronger legs and better balance"), `PlanReadyView.swift`
**Steps:**
1. Giữ 3 dòng: kế hoạch 12 tuần · bản ngồi · giọng dẫn; PlanReady nhắc "Week 1 starts with your first session".
2. `SHOT onboarding-welcome`, `SHOT onboarding-plan`.
**Command:** ảnh khớp màn 1 bản vẽ
**Evidence:** VIẾT XONG, CHƯA BUILD: Welcome dòng đầu là lời hứa 12 tuần; `ProgramPromiseCard` trên PlanReady — cần `SHOT onboarding-welcome`, `SHOT onboarding-plan`
**Commit point:** `feat(onboarding): steady program promise`

### Task 4.14 — Hết 12 tuần và tạm dừng / làm lại trong Tôi [UI]
**Files:** Create `iOS/App/Features/Program/ProgramFinishedView.swift` · Modify `iOS/App/Features/Me/MeSections.swift` (mục "Your plan": tuần hiện tại, "Start again")
**Steps:**
1. Màn kết thúc: so lần kiểm tra cuối với tuần 0 (cùng cách), hai nút "Start a new 12 weeks" / "Keep my routine".
2. `SHOT program-finished`; ảnh Tôi có mục kế hoạch.
**Command:** ảnh có hai nút và con số so với tuần 0
**Evidence:** VIẾT XONG, CHƯA BUILD: `ProgramFinishedView.swift`, `AppCover.programFinished`, `ProgramSection` trong Tôi — cần `SHOT program-finished`, `SHOT me`
**Commit point:** `feat(program): finish and restart`

### Task 4.15 — Thông báo: công tắc và lên lịch [UI]
**Files:** Modify `iOS/App/Features/Me/NotificationSection.swift`, `iOS/App/Services/Notifications/NotificationScheduler.swift` · Test `NotificationSchedulerTests.swift`
**Steps:**
1. Công tắc "Self-check reminders" (mặc định bật); scheduler truyền `selfCheckDue` vào `PlannerInput`; nội dung không nhắc sức khoẻ ("Your 2-week check is ready when you are.").
2. `APP NotificationSchedulerTests`.
**Command:** `APP NotificationSchedulerTests` → expected: `** TEST SUCCEEDED **`
**Evidence:** VIẾT XONG, CHƯA BUILD: công tắc "Self-check reminders"; `plannerInput()` truyền `selfCheckDue`; core có `SelfCheckSchedule.dueDate` (XANH trên cloud); test `selfCheckReminderOnItsDay` — chạy `APP NotificationSchedulerTests`
**Commit point:** `feat(notifications): self-check reminder toggle`

### Milestone 5 — Nội dung, giọng, ngôn ngữ

### Task 5.1 — Kịch bản câu HLV mới [DATA]
**Files:** Create `docs/scripts/A12-steady-program.md`
**Steps:**
1. Câu (EN): giới thiệu chương trình (2), sang chặng (4), tự kiểm tra: dặn an toàn, 3-2-1, Go, giữa chừng, Stop, cảm ơn (7), lên số lần (3), kết thúc 12 tuần (2) ≈ 18 câu; theo luật giọng (không gọi tên, bản dễ trước, không chữ "fall").
2. Bản VI theo glossary.
**Command:** `python3 tools/lint/copy_lint.py` → expected: `0 findings`
**Evidence:** Bản nháp xong: `docs/scripts/A12-steady-program.md` (3 câu mới + dùng lại `a5.n.1–3`, `a5.half`); câu chương trình/chặng/lên số lần để ở mục "đề xuất" (bản 1.0 nói bằng chữ). CHỜ CHỦ APP DUYỆT
**STOP AND ASK:** chủ app duyệt kịch bản trước khi thu (mặc định: duyệt trong 1 lượt đọc)
**Commit point:** `docs(scripts): A12 steady program lines`

### Task 5.2 — Nội dung và kiểm tra nội dung [TDD]
**Files:** Modify `tools/content/build_content.py`, `iOS/App/Resources/Content/voice-lines.json`, `Packages/GentleWalkCore/Sources/GentleWalkCore/Content/ContentValidator.swift` · Test `ContentValidatorTests.swift`
**Steps:**
1. `@Test func steadyProgramLinesExist()`: mọi id câu dùng trong `ProgramStage`, tự kiểm tra, `RepLadder` có trong `voice-lines.json` (en) và `content.vi.json`.
2. RED → build content từ A12.
**Command:** `CORE ContentValidatorTests` → expected: `passed`
**Evidence:** XANH trên cloud: `voice_lines.py` đọc A12, `build_content.py --check` stale: none, test core `steadyProgramLinesExist` (EN + VI)
**Commit point:** `feat(content): steady program voice lines`

### Task 5.3 — Thu giọng EN và VI [DATA]
**Files:** `assets/voice/` (A12), `docs/i18n/vi/voice-extra.json`
**Steps:**
1. Thu EN và VI qua Vibi (quyết định 06/10: giọng tiếng Anh qua Vibi trước); chạy QC `tools/voice/qc_lines.py`.
**Command:** `python3 tools/voice/qc_lines.py` → expected: 0 lỗi
**Evidence:** CHỜ CHỦ APP: thu 3 câu `a12.check.*` EN + VI (Vibi), rồi `build_content_overlay.py vi --cache …`
**STOP AND ASK:** chi phí credit Vibi cho khoảng 18 câu × 2 ngôn ngữ (mặc định: dùng hạn mức hiện có)
**Commit point:** `feat(voice): A12 recordings`

### Task 5.4 — Chữ giao diện EN + VI [DATA]
**Files:** Modify `iOS/App/Localizable.xcstrings`, `docs/i18n/source/ui.json`, `docs/i18n/vi/ui-extra-8.json` (mới), `docs/i18n/glossary-vi.md` (Kế hoạch 12 tuần, Chặng, Tự kiểm tra 2 tuần, Nền vững / Thêm sức / Thử thách nhẹ / Thói quen của bạn)
**Steps:**
1. Trên Mac: build với `SWIFT_EMIT_LOC_STRINGS=YES`, `tools/i18n/extract_sources.py`, thêm bản Việt, `apply_catalog.py vi`.
**Command:** `L10N` → expected: `0 missing; 0 problems`, coverage 0 cho en và vi, `0 findings`
**Evidence:** Bản Việt sẵn: `docs/i18n/vi/ui-extra-8.json` (101 câu, khoá đã có dạng %lld/%@), glossary đã thêm mục. CẦN MAC: build trích khoá, `extract_sources.py`, `apply_catalog.py vi`, rồi `L10N`
**Commit point:** `feat(l10n): steady program strings en and vi`

### Task 5.5 — Thông báo EN + VI [DATA]
**Files:** Modify `iOS/App/Resources/Content/notifications.json`, `content.vi.json`
**Steps:** thêm 3–4 câu `selfCheck` không lặp trong 14 ngày; `ContentValidator` kiểm.
**Command:** `CORE ContentValidatorTests` → expected: `passed`
**Evidence:** XANH trên cloud: `nt.check.1–4` trong D8, `notifications.json` 30 câu, bản Việt trong `docs/i18n/vi/content.json` + `content.vi.json`; `copy_lint` 0 findings
**Commit point:** `feat(content): self-check notification phrases`

### Task 5.6 — Kiểm tra nội dung phát hành [TDD]
**Files:** Modify `iOS/GentleWalkTests/ReleaseContentTests.swift`
**Steps:** thêm kiểm tra: mọi câu A12 có file âm thanh EN và VI.
**Command:** `APP ReleaseContentTests` → expected: `** TEST SUCCEEDED **` (sau Task 5.3)
**Evidence:** Không cần sửa test: `ReleaseContentTests` đã kiểm mọi câu trong `voice-lines.json` có file (gồm A12) — đỏ cho tới khi thu xong 5.3
**Commit point:** `test(release): A12 audio present`

### Milestone 6 — Release skeleton

### Task 6.1 — Bộ ảnh store và mô tả [DATA]
**Files:** Modify `docs/release/1.0/screenshots.md`, `docs/release/1.0/asset-checklist.md`
**Steps:** thứ tự ảnh: (1) Welcome lời hứa, (2) Hôm nay có thẻ Tuần x/12, (3) đang tập bản ngồi + bậc vịn, (4) biểu đồ tự kiểm tra, (5) hành trình; ảnh 1 có cảnh một người ngồi một người đứng (todo yes2next). Trạng thái chụp dùng tên ở Task 4.1.
**Command:** `grep -c "SHOT\|ScreenshotMode" docs/release/1.0/screenshots.md` → expected: ≥ 5
**Evidence:** XONG: bảng thứ tự mới trong `docs/release/1.0/screenshots.md`
**Commit point:** `docs(release): screenshots for steady program`

### Task 6.2 — Ghi chú cho người duyệt [DATA]
**Files:** Modify `docs/release/1.0/checklist.md`
**Steps:** thêm câu: "The 2-week check is a self-counted 30-second chair stand, compared only with the user's own earlier results. It is general fitness, not a medical test, and shows no norms or risk levels."
**Command:** `python3 tools/lint/copy_lint.py` → expected: `0 findings`
**Evidence:** XONG: câu review notes trong `docs/release/1.0/checklist.md` §5
**Commit point:** `docs(release): review notes for self-check`

### Task 6.3 — Trang privacy [DATA]
**Files:** Modify `site/privacy.html`
**Steps:** thêm "Your 2-week check results stay on this phone." vào mục dữ liệu.
**Command:** `grep -n "2-week check" site/privacy.html` → expected: 1 dòng
**Evidence:** XONG: `site/privacy.html` dòng 24
**Commit point:** `docs(site): self-check data stays on device`

### Task 6.4 — app-context và todo [DATA]
**Files:** Modify `app-context.md` (Positioning: lời hứa một vấn đề; Price model: chương trình + tự kiểm tra miễn phí, thang số lần Pro; decisions log), `docs/todo.md`
**Command:** `grep -n "Steady program\|chương trình vững chân" app-context.md` → expected: ≥ 2 dòng
**Evidence:** XONG: app-context (Positioning, Price model, decisions log) và `docs/todo.md`
**Commit point:** `docs: record steady program decision`

## Trạng thái chụp mới (thêm vào danh sách chụp của kế hoạch MVP)
`today-program` · `today-check-due` · `program` · `selfcheck-intro` · `selfcheck-timer` · `selfcheck-count` · `progress-checks` · `complete-check-invite` · `complete-level-up` · `program-finished` — mỗi trạng thái chụp sáng, tối, cỡ chữ XXL, iPad; tiếng Việt khi chủ app yêu cầu.

## Rủi ro đã biết
- Chưa có bằng chứng người dùng trả tiền cho "thăng bằng" (11 khen / 5 chê, n < 30) → test thông điệp quảng cáo song song; nếu "cứng người" thắng rõ, chỉ đổi chữ quảng cáo và store, kế hoạch này vẫn dùng được.
- Người dùng tự đếm có thể sai hoặc làm khác cách → chỉ so cùng cách, cho làm lại, không bảng chuẩn.
- Thêm khoảng 18 câu thoại × 2 ngôn ngữ → chi phí giọng; có phương án chuông + chữ (Task 4.7).
- Migration SchemaV2 phải xong trước khi phát hành; nếu trễ, phát hành V1 rồi migration trên dữ liệu thật (rủi ro cao hơn).

## Approval checklist (tick để làm — không tick thì không code)
_Chủ app duyệt toàn bộ 08/10/2026._
- [x] Milestone 1 — Tuân thủ và luật câu chữ (1.1–1.4)
- [x] Milestone 2 — Logic chương trình (2.1–2.12)
- [x] Milestone 3 — Dữ liệu SchemaV2 (3.1–3.4)
- [x] Milestone 4 — Giao diện (4.1–4.15)
- [x] Milestone 5 — Nội dung, giọng, ngôn ngữ (5.1–5.6)
- [x] Milestone 6 — Release skeleton (6.1–6.4)
- [x] Mặc định của các câu STOP AND ASK: nghỉ 14 ngày (2.3) · bậc 6 → 8 → 10 → 2×8 → 2×10 (2.5) · câu HLV cho 30 giây (4.7) · duyệt kịch bản A12 (5.1) · credit Vibi (5.3)

## Decisions-log line (thêm vào app-context.md sau khi duyệt)
- 08/10/2026 — Kế hoạch "Chương trình vững chân" duyệt: docs/plans/2026-10-08-steady-program.md (45 task / 6 milestone; làm trước 1.0; kế hoạch + tự kiểm tra miễn phí, thang số lần Pro; tuần 0 sau buổi đầu; thanh thẻ giữ nguyên) — by manh-skill-plan
