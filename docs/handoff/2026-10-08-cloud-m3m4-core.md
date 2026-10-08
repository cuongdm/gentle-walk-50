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
| 4.13 P7 kịch bản A13 | IN PROGRESS | | |

Ranh giới: nhánh này chỉ sửa `iOS/Packages/GentleWalkCore`, `tools/content`, `tools/lint`, `docs/scripts`, `docs/i18n`, `docs/handoff` (và dòng Evidence trong kế hoạch). Không đụng `iOS/App`, `iOS/GentleWalkTests`, `Localizable.xcstrings`, `project.yml`, `Plan/Adaptation.swift`, WalkLevel, TodayModel.
