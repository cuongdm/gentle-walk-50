# Bàn giao: nội dung chống nhàm chán milestone 3 (cloud)
_08/10/2026 · Nhánh `cloud/m3-content` (từ `origin/cloud/core-content-m3m4` 0053af0) · Yêu cầu từ phiên Mac · Nguồn: `docs/design/research-2026-10-08/icon-va-chong-nham-chan.md` §4–§5, kế hoạch [UI/cá nhân hoá](../plans/2026-10-08-ui-onboarding-personalization.md) task 3.6, 3.9–3.11 và mục "Bổ sung"._

## Trạng thái (cập nhật mỗi commit)
| Việc | Trạng thái | Id / API mới | Test | Mac phải nối |
|---|---|---|---|---|
| 1. Lời khen màn Hoàn thành (6 ngữ cảnh) | DONE | `CheerContext` (.firstSession, .ordinary, .cameBack, .personalBest, .weekDone, .stageDone), `Cheer`, `CompleteCheer.context(isFirstSession:daysSinceLastSession:personalBest:weekDone:stageDone:)`, `CompleteCheer.pick(_:sessionIndex:lastID:)`, `CompleteCheer.pool(_:)`; id `cheer.<context>.<n>` (21 câu) | `CompleteCheerTests` 4 test xanh | `CompleteContent`: tính context (stoppedForPain giữ màn riêng), `pick(sessionIndex: activeDays, lastID:)` với `lastID` lưu UserDefaults (`AppDefaultsKeys`); `title`/`line` qua String Catalog (khoá = chuỗi EN, literal); VI: `docs/i18n/vi/ui-extra-11.json` |
| 2. Lời chào theo giờ và mùa | DONE | `DayPart` (.morning < 12h, .afternoon 12–17h, .evening), `Season` (theo tháng, không nói thời tiết), `Greeting` (`text`, `withName` có một `%@`), `Greetings.dayPart/season/pool/pick(now:calendar:)`; id `greeting.<part>.<1–6 \| season>` (18 + 12 câu) | `GreetingsTests` 5 test xanh (7 ngày liền không lặp; mọi câu có bản Việt; không trùng bản dịch giữa các file VI) | `TodayModel.greeting`: `Greetings.pick(now:calendar:)` → `withName` (có tên) hoặc `text`, qua String Catalog (khoá = chuỗi EN, gồm "Good morning, %@" đã có); VI: `ui-extra-11.json` |
| 3. Chữ "New this week" cho 12 tuần | DONE | `WeekTheme.line` (12 câu, một câu "để ý gì tuần này"; tên tuần `WeekTheme.title` từ nhánh trước); chữ thẻ: "New this week", "This week", "This week · %@", câu tin của tuần 1/4/7/10/12 đã có trong `ui-extra-10.json` | `WeekThemeTests.everyWeekHasALineInBothLanguages` (5 test xanh) | Today/Program: thẻ "New this week" (chỉ khi `newThisWeek != nil`, câu tin) hoặc "This week · <title>" + `line`; mọi chữ qua String Catalog; VI: `ui-extra-10.json` (tên) + `ui-extra-11.json` (câu) |
| 4. Câu HLV cho 4 hành trình Pro | DONE (chưa thu) | 20 id mới: `a8.smoky.2–6`, `a8.camino.2–6`, `a8.ne.2–6`, `a8.pch.2–6` (kịch bản `docs/scripts/A8-journeys.md`, VI `docs/i18n/vi/voice-a8b.json`); `JourneyCoach.route(of:)`, `JourneyCoach.lineID(journeyID:stopIndex:content:)` | `JourneyCoachTests` (mọi điểm dừng của 5 tuyến có câu EN + VI); toàn core 241/49 xanh | Thu 20 câu qua Vibi EN + VI (rồi overlay VI **kèm `--cache`**); phát câu khi mở bưu thiếp mới (Complete/Journey) bằng `SpokenCue` hoặc thêm vào timeline; hiện chưa có chỗ nào phát `a8.*` (kể cả New York) |
| 5. Everyday wins nhãn ngắn | DONE | id giữ nguyên `win.1`–`win.8`; nhãn mới (≤ 6 chữ, ≤ 32 ký tự): Up from the sofa, no hands · Groceries in one trip · Walked the whole store · Stairs without stopping · On the floor with the grandkids · Top shelf, no stool · To the mailbox and back · Stood through a whole show (VI trong `content.vi.json`/`docs/i18n/vi/content.json`) | `EverydayWinsContentTests` xanh | không cần nối (app đọc `wins.json` + `content.vi.json`); xem lại ảnh Progress nửa dưới |

Ranh giới như nhánh trước: chỉ `iOS/Packages/GentleWalkCore`, `tools/content`, `tools/lint`, `docs/scripts`, `docs/i18n`, `docs/handoff` (cộng đầu ra sinh tự động của `build_content.py` trong `iOS/App/Resources/Content/*.json` khi kịch bản đổi). Không Swift của app, không `GentleWalkTests`, không `Localizable.xcstrings`, không `project.yml`.

Ghi chú: test core đọc `docs/i18n/vi/ui*.json` (`TestSupport.vietnameseUI()`) để bắt câu thiếu bản Việt, nên Docker phải mount cả repo (`-v <repo>:/repo -w /repo/iOS`).

## Kiểm tra đã chạy (cloud, Docker `swift:6.2-noble`, mount cả repo)
- Toàn bộ core: `Test run with 242 tests in 50 suites passed` (nhánh gốc 230/46: +12 test, +4 suite).
- Nội dung: `build_content.py --check` → `stale: none` (`voice-lines.json` 681 câu, `wins.json` 8). `copy_lint.py` → `0 findings`, cả chữ mới trong `docs/i18n/vi/ui-extra-11.json`.
- App chưa build (cloud không có Xcode). Không sửa Swift của app.

## File ngoài core bị chạm
- Đầu ra sinh tự động của `build_content.py`: `iOS/App/Resources/Content/voice-lines.json` (+20 câu a8), `wins.json` (nhãn ngắn).
- `iOS/App/Resources/Content/content.vi.json`: +20 câu a8 (chỉ `text`) và 8 nhãn wins. **Nhánh này tách từ `cloud/core-content-m3m4` nên chưa có file ghi âm A13 mà Mac đã merge ở `main` local.** Khi merge: lấy bản `content.vi.json` của `main` rồi chạy `python3 tools/i18n/build_content_overlay.py vi --cache assets/voice/cache-vi-bella-v4` (overlay đọc `docs/i18n/vi/voice-*.json` và `content.json`, nên giữ được cả A13 lẫn a8 mới), không gộp tay.
- `docs/scripts/D-min-texts.md` §D9 (nhãn ngắn, câu cũ ghi lại), `docs/scripts/A8-journeys.md` (mới), `tools/content/voice_lines.py` (đọc A8-journeys), `docs/i18n/vi/ui-extra-11.json` (mới), `voice-a8b.json` (mới), `docs/i18n/vi/content.json` (wins).

## Ghi chú
- Mock `ProgressMore.dc.html` không có trên `origin` (chỉ có ở máy Mac), nên nhãn wins ngắn viết theo yêu cầu "một dòng trên SE"; nếu mock có câu khác thì sửa §D9 rồi chạy `build_content.py`.
- Câu `a8.*` (kể cả New York) hiện chưa phát ở đâu trong app: cần Mac nối khi mở bưu thiếp mới.

- Mac 08/10 (đã nối): câu `a8.*` phát trên màn Hoàn thành khi buổi tập mở bưu thiếp mới (điểm xa nhất mở trong buổi, `JourneyCoach.arrivalLineID`; không phát khi dừng vì đau; `SpokenCue` trong `WorkoutView`). Quãng hành trình chỉ được cộng lúc lưu buổi, nên "tới điểm dừng" = lúc Hoàn thành. `CompleteCheer`, `Greetings`, `WeekTheme.line` đã dùng trong app. Tiến bộ → "Hands on the chair" hiện mức đã đạt (`SupportLadder.earned`), không giới hạn theo ngày Okay; buổi hôm nay vẫn theo `SupportLadder.plan`.
