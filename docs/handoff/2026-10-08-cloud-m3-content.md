# Bàn giao: nội dung chống nhàm chán milestone 3 (cloud)
_08/10/2026 · Nhánh `cloud/m3-content` (từ `origin/cloud/core-content-m3m4` 0053af0) · Yêu cầu từ phiên Mac · Nguồn: `docs/design/research-2026-10-08/icon-va-chong-nham-chan.md` §4–§5, kế hoạch [UI/cá nhân hoá](../plans/2026-10-08-ui-onboarding-personalization.md) task 3.6, 3.9–3.11 và mục "Bổ sung"._

## Trạng thái (cập nhật mỗi commit)
| Việc | Trạng thái | Id / API mới | Test | Mac phải nối |
|---|---|---|---|---|
| 1. Lời khen màn Hoàn thành (6 ngữ cảnh) | DONE | `CheerContext` (.firstSession, .ordinary, .cameBack, .personalBest, .weekDone, .stageDone), `Cheer`, `CompleteCheer.context(isFirstSession:daysSinceLastSession:personalBest:weekDone:stageDone:)`, `CompleteCheer.pick(_:sessionIndex:lastID:)`, `CompleteCheer.pool(_:)`; id `cheer.<context>.<n>` (21 câu) | `CompleteCheerTests` 4 test xanh | `CompleteContent`: tính context (stoppedForPain giữ màn riêng), `pick(sessionIndex: activeDays, lastID:)` với `lastID` lưu UserDefaults (`AppDefaultsKeys`); `title`/`line` qua String Catalog (khoá = chuỗi EN, literal); VI: `docs/i18n/vi/ui-extra-11.json` |
| 2. Lời chào theo giờ và mùa | DONE | `DayPart` (.morning < 12h, .afternoon 12–17h, .evening), `Season` (theo tháng, không nói thời tiết), `Greeting` (`text`, `withName` có một `%@`), `Greetings.dayPart/season/pool/pick(now:calendar:)`; id `greeting.<part>.<1–6 \| season>` (18 + 12 câu) | `GreetingsTests` 5 test xanh (7 ngày liền không lặp; mọi câu có bản Việt; không trùng bản dịch giữa các file VI) | `TodayModel.greeting`: `Greetings.pick(now:calendar:)` → `withName` (có tên) hoặc `text`, qua String Catalog (khoá = chuỗi EN, gồm "Good morning, %@" đã có); VI: `ui-extra-11.json` |
| 3. Chữ "New this week" cho 12 tuần | NOT STARTED | | | |
| 4. Câu HLV cho 4 hành trình Pro | NOT STARTED | | | |
| 5. Everyday wins nhãn ngắn | NOT STARTED | | | |

Ranh giới như nhánh trước: chỉ `iOS/Packages/GentleWalkCore`, `tools/content`, `tools/lint`, `docs/scripts`, `docs/i18n`, `docs/handoff` (cộng đầu ra sinh tự động của `build_content.py` trong `iOS/App/Resources/Content/*.json` khi kịch bản đổi). Không Swift của app, không `GentleWalkTests`, không `Localizable.xcstrings`, không `project.yml`.

Ghi chú: test core đọc `docs/i18n/vi/ui*.json` (`TestSupport.vietnameseUI()`) để bắt câu thiếu bản Việt, nên Docker phải mount cả repo (`-v <repo>:/repo -w /repo/iOS`).
