# Bàn giao: lõi logic và nội dung milestone 3–4 (cloud)
_08/10/2026 · Nhánh `cloud/core-content-m3m4` (từ `main` c9769c6) · Kế hoạch: [docs/plans/2026-10-08-ui-onboarding-personalization.md](../plans/2026-10-08-ui-onboarding-personalization.md) · Phiên Mac đọc bằng `git fetch origin cloud/core-content-m3m4`._

## Trạng thái (cập nhật mỗi commit)
| Task | Trạng thái | API lõi mới | Test |
|---|---|---|---|
| 4.7 P13 nghỉ dài → hạ một bậc | DONE | `RepLadder.stepDownAll(_:)`, `SupportLadder.stepDownAll(_:)` | `RepLadderTests.stepDownNeverBelowZero`, `SupportLadderTests.longBreakStepsEveryLevelDown` (13/13 xanh) |
| 4.8 P9 tự kiểm tra → thang số lần | DONE | `SelfCheckTrend` (.up/.flat/.down), `SelfCheckComparison.trend(history:now:calendar:)`, `RepLadder.today(…, trend:)`, `SupportLadder.update(…, holdRaises:)` | `trendComparesTheSameWayByTwoOrMore`, `selfCheckTrendMovesTheCap`, `checkDownHoldsTheHandsLevel` (19/19 xanh) |
| 4.5 P3 nhớ chỗ đau theo bài | DONE | `ExerciseRules` (easier, setAside, setAsideIDs, merging), `PainRules.exerciseRules(reports:now:restored:)`, `PainRules.suggestedLimit(for:)`, `SessionBuilder.build(…, exerciseRules:)` | `PainRulesTests` +4 (oneReportMakesItEasier, twoReportsSetItAside, restoredStaysAllowed, areaSuggestsALimit), `SessionBuilderTests.setAsideMovesAreReplacedAndHurtMovesStartEasier` (37/37 xanh) |
| 3.9 Kho câu HLV xoay vòng | DONE | `VoiceRotation.pools` (a2.warm.2–8, a6 trừ .6/.9, a7.break, a3.open, a9.back), `VoiceRotation.rotates(family:number:)` | `CoachLinePoolTests` 5 test; toàn core 206/41 xanh (SessionSyncTests xanh) |
| 3.10 Chủ đề tuần | DONE | `WeekTheme` (12 case, `forWeek(_:)`, `of(_:)`, `week`, `stage`, `title`, `newThisWeek: News?` = .programStarts/.stageStarts/.lastWeek) | `WeekThemeTests` 4 test xanh |
| 4.9 P6 check-in tuần | DONE | `WeeklyEffort`, `BetterChip` (7 chip, `title`), `WeeklyNote` (Codable), `WeekEffects` (.none), `WeeklyCheckIn.reviewedWeek/isDue/current/effects/lastWeekChip/adding`, `WeeklyCheckIn.kept` = 24; `RepLadder.update(…, holdRaises:)` | `WeeklyCheckInTests` 7 test, `RepLadderTests.holdRaisesKeepsTheStep` xanh |
| 4.11 P10 giờ nhắc và độ dài | DONE | `SessionTiming`, `LengthSignal` (.shorter/.longer), `HabitSignals.suggestedReminderMinutes(starts:reminderMinutes:calendar:)`, `HabitSignals.lengthSignal(_:)` | `HabitSignalsTests` 4 test xanh |
| 4.12 P11 ngày đã đi nhiều | DONE (chỉ logic) | `BusyDay.usualSteps(dailySteps:now:calendar:)`, `BusyDay.isBusy(stepsToday:dailySteps:now:reminderMinutes:calendar:)` | `BusyDayTests` 3 test xanh |
| 4.18 Thông báo tổng kết tuần | DONE | không API mới (planner đã chỉ gửi số ngày; test khoá lại) | `NotificationPlannerTests.weeklyRecapNeverNamesHealth`, `stillAtMostOneADay` (21/21 xanh) |
| 4.13 P7 kịch bản A13 | DONE (chưa thu giọng) | `CoachHistory.checkLine/weekLine/daysLine/walkLine`, `CoachHistory.allLineIDs` (41) | `CoachHistoryTests` 3 test (coachHistoryLinesExist 41 EN+VI); toàn core 230/46 xanh |

Ranh giới: nhánh này chỉ sửa `iOS/Packages/GentleWalkCore`, `tools/content`, `tools/lint`, `docs/scripts`, `docs/i18n`, `docs/handoff` (và dòng Evidence trong kế hoạch). Không đụng `iOS/App`, `iOS/GentleWalkTests`, `Localizable.xcstrings`, `project.yml`, `Plan/Adaptation.swift`, WalkLevel, TodayModel.

## Kiểm tra đã chạy (cloud, Docker `swift:6.2-noble`)
- Toàn bộ core: `swift test --package-path iOS/Packages/GentleWalkCore` → `Test run with 230 tests in 46 suites passed` (từ 194/40 trên `main`: +36 test, +6 suite).
- Nội dung: `python3 tools/content/build_content.py --check` → `stale: none` (`voice-lines.json` 661 câu). `python3 tools/lint/copy_lint.py` → `0 findings`, và 0 findings cho mọi chữ mới trong `docs/i18n/vi/ui-extra-10.json`.
- App (`xcodebuild`) **chưa chạy** vì cloud không có Xcode. Không file Swift nào của app bị sửa; chỉ có API mới thêm tham số có giá trị mặc định nên lời gọi cũ vẫn biên dịch.

## File ngoài core bị chạm (cần biết khi merge)
- `iOS/App/Resources/Content/voice-lines.json` và `content.vi.json`: **chỉ là đầu ra sinh từ** `build_content.py` (A13) và bản Việt 41 câu A13 (chỉ thêm `text`, không xoá ghi âm nào). Không có Swift, không có `Localizable.xcstrings`. Nếu Mac cũng sửa 2 file này thì chạy lại `build_content.py` sau khi merge thay vì gộp tay.
- `docs/scripts/A2-walk.md` (ghi chú kho xoay), `A13-coach-history.md` (mới), `docs/i18n/vi/ui-extra-10.json` (mới), `voice-a13.json` (mới), `glossary-vi.md`, dòng **Evidence** trong kế hoạch.

## API mới theo task và việc Mac phải nối
| Task | API lõi | Mac nối vào app |
|---|---|---|
| 4.7 | `RepLadder.stepDownAll(_:)`, `SupportLadder.stepDownAll(_:)` | `AppModel+Program.pickUpProgram`: hạ cả hai thang rồi lưu; test `AppFlowTests.pickUpLowersLadders()` |
| 4.8 | `SelfCheckTrend`, `SelfCheckComparison.trend(history:now:calendar:)`, `RepLadder.today(…, trend:)`, `SupportLadder.update(…, holdRaises:)` | `prepareAndPlay`: tính trend từ `selfCheckResults()`, truyền vào `RepLadderStore.today`; `onBalanceResult`: `holdRaises: trend == .down`; TodayModel: down → check-in gợi `.okay` |
| 4.5 | `ExerciseRules` (+`merging`), `PainRules.exerciseRules(reports:now:restored:)`, `PainRules.suggestedLimit(for:)`, `SessionBuilder.build(…, exerciseRules:)` | `WorkoutRequest.exerciseRules` → `plan(content:)`; store "restored" (UserDefaults, `AppDefaultsKeys`); thẻ Today `.setAside`, Me "Moves set aside / Bring it back", gợi ý chip trên ThisHurts |
| 3.9 | `VoiceRotation.pools`, `rotates(family:number:)` | không cần (SessionBuilder đã xoay); `a6`/`a7.break` chỉ phát khi có chỗ dùng (4.1) |
| 3.10 | `WeekTheme` (`forWeek`, `of`, `title`, `newThisWeek`) | `localizedTitle` (literal cho String Catalog), kicker "Week %lld · %@", thẻ "New this week" chỉ khi `newThisWeek != nil` |
| 4.9 | `WeeklyNote`, `WeeklyEffort`, `BetterChip`, `WeekEffects`, `WeeklyCheckIn.reviewedWeek/isDue/current/effects/lastWeekChip/adding`, `RepLadder.update(…, holdRaises:)` | `WeeklyNoteStore`, `WeeklyCheckInView` + `AppCover.weeklyCheckIn` (mở ở `sceneBecameActive` khi `isDue`), áp `WeekEffects`, dòng Thứ hai, dòng thời gian Progress, `DataEraser` |
| 4.11 | `SessionTiming`, `LengthSignal`, `HabitSignals.suggestedReminderMinutes`, `HabitSignals.lengthSignal` | map `WorkoutRecord` → `SessionTiming` (cần planned seconds), thẻ `.moveReminder(to:)`, `.shorter`/`.longer` |
| 4.12 | `BusyDay.usualSteps`, `BusyDay.isBusy` | `HealthService` đọc bước (đã có quyền) → `TodayInput.busyDay`, dòng gợi giãn cơ |
| 4.18 | không (test khoá lại) | không |
| 4.13 | `CoachHistory.*` (41 id) | 4.14 thu Vibi; 4.15 nối vào `SessionBuilder` và `SessionTimeline.selfCheck(previousCount:)` |

Chữ giao diện gợi ý (EN key → VI) cho mọi thẻ/dòng mới: `docs/i18n/vi/ui-extra-10.json`. Khoá phải trùng đúng chữ Mac viết trong code; khác thì sửa file VI, không sửa code.
