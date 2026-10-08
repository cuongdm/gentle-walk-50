# A13 — Câu HLV theo lịch sử của bà ấy (P7) · bản nháp 1 (CHỜ CHỦ APP NGHE THỬ)
_08/10/2026 · Kế hoạch [UI/cá nhân hoá](../plans/2026-10-08-ui-onboarding-personalization.md) task 4.13 (kịch bản), 4.14 (thu Vibi, credit đã duyệt), 4.15 (nối vào buổi) · Nghiên cứu: [ca-nhan-hoa.md](../research/2026-10-08-ca-nhan-hoa.md) P7 · Luật câu chữ: [steady-claims.md](../design/steady-claims.md) · Chữ thoại tiếng Anh Mỹ, ghi chú tiếng Việt_

## 1. Quy tắc
- D12: **thu nguyên câu có số** (không ghép số rời) cho tự nhiên; số viết bằng chữ để giọng đọc đúng ("twelve", không "12").
- Mỗi buổi tối đa **1** câu lịch sử, ở chỗ nhịp chậm (mở đầu hoặc cuối buổi). Không gọi tên, không ngày tháng, không so với người khác, không "test/score/risk/fall".
- Chỉ so với chính bà ấy: "Last check" là lần tự kiểm tra trước **cùng cách làm** (có/không chống tay); số ngoài 3…20 thì bỏ câu (im lặng tốt hơn câu sai).
- API lõi chọn câu: `CoachHistory.checkLine(previousCount:)`, `weekLine(week:)`, `daysLine(activeDays:)`, `walkLine(walkNumber:)` (`iOS/Packages/GentleWalkCore/Sources/GentleWalkCore/Session/CoachHistory.swift`).

## 2. Câu (41)
| ID | Câu thoại | Ghi chú |
|---|---|---|
| a13.check.n.3 | Last check, you stood up three times. Let's see today. | mở tự kiểm tra từ lần 2, trước `a12.check.setup` |
| a13.check.n.4 | Last check, you stood up four times. Let's see today. | mở tự kiểm tra từ lần 2, trước `a12.check.setup` |
| a13.check.n.5 | Last check, you stood up five times. Let's see today. | mở tự kiểm tra từ lần 2, trước `a12.check.setup` |
| a13.check.n.6 | Last check, you stood up six times. Let's see today. | mở tự kiểm tra từ lần 2, trước `a12.check.setup` |
| a13.check.n.7 | Last check, you stood up seven times. Let's see today. | mở tự kiểm tra từ lần 2, trước `a12.check.setup` |
| a13.check.n.8 | Last check, you stood up eight times. Let's see today. | mở tự kiểm tra từ lần 2, trước `a12.check.setup` |
| a13.check.n.9 | Last check, you stood up nine times. Let's see today. | mở tự kiểm tra từ lần 2, trước `a12.check.setup` |
| a13.check.n.10 | Last check, you stood up ten times. Let's see today. | mở tự kiểm tra từ lần 2, trước `a12.check.setup` |
| a13.check.n.11 | Last check, you stood up eleven times. Let's see today. | mở tự kiểm tra từ lần 2, trước `a12.check.setup` |
| a13.check.n.12 | Last check, you stood up twelve times. Let's see today. | mở tự kiểm tra từ lần 2, trước `a12.check.setup` |
| a13.check.n.13 | Last check, you stood up thirteen times. Let's see today. | mở tự kiểm tra từ lần 2, trước `a12.check.setup` |
| a13.check.n.14 | Last check, you stood up fourteen times. Let's see today. | mở tự kiểm tra từ lần 2, trước `a12.check.setup` |
| a13.check.n.15 | Last check, you stood up fifteen times. Let's see today. | mở tự kiểm tra từ lần 2, trước `a12.check.setup` |
| a13.check.n.16 | Last check, you stood up sixteen times. Let's see today. | mở tự kiểm tra từ lần 2, trước `a12.check.setup` |
| a13.check.n.17 | Last check, you stood up seventeen times. Let's see today. | mở tự kiểm tra từ lần 2, trước `a12.check.setup` |
| a13.check.n.18 | Last check, you stood up eighteen times. Let's see today. | mở tự kiểm tra từ lần 2, trước `a12.check.setup` |
| a13.check.n.19 | Last check, you stood up nineteen times. Let's see today. | mở tự kiểm tra từ lần 2, trước `a12.check.setup` |
| a13.check.n.20 | Last check, you stood up twenty times. Let's see today. | mở tự kiểm tra từ lần 2, trước `a12.check.setup` |
| a13.week.1 | Week one of twelve. At your own pace. | mở buổi đầu tiên của tuần chương trình |
| a13.week.2 | Week two of twelve. At your own pace. | mở buổi đầu tiên của tuần chương trình |
| a13.week.3 | Week three of twelve. At your own pace. | mở buổi đầu tiên của tuần chương trình |
| a13.week.4 | Week four of twelve. At your own pace. | mở buổi đầu tiên của tuần chương trình |
| a13.week.5 | Week five of twelve. At your own pace. | mở buổi đầu tiên của tuần chương trình |
| a13.week.6 | Week six of twelve. At your own pace. | mở buổi đầu tiên của tuần chương trình |
| a13.week.7 | Week seven of twelve. At your own pace. | mở buổi đầu tiên của tuần chương trình |
| a13.week.8 | Week eight of twelve. At your own pace. | mở buổi đầu tiên của tuần chương trình |
| a13.week.9 | Week nine of twelve. At your own pace. | mở buổi đầu tiên của tuần chương trình |
| a13.week.10 | Week ten of twelve. At your own pace. | mở buổi đầu tiên của tuần chương trình |
| a13.week.11 | Week eleven of twelve. At your own pace. | mở buổi đầu tiên của tuần chương trình |
| a13.week.12 | Week twelve of twelve. At your own pace. | mở buổi đầu tiên của tuần chương trình |
| a13.days.1 | That's your first active day this week. | cuối buổi (Complete), đếm ngày vận động trong tuần |
| a13.days.2 | That's two active days this week. | cuối buổi (Complete), đếm ngày vận động trong tuần |
| a13.days.3 | That's three active days this week. | cuối buổi (Complete), đếm ngày vận động trong tuần |
| a13.days.4 | That's four active days this week. | cuối buổi (Complete), đếm ngày vận động trong tuần |
| a13.days.5 | That's five active days this week. | cuối buổi (Complete), đếm ngày vận động trong tuần |
| a13.days.6 | That's six active days this week. | cuối buổi (Complete), đếm ngày vận động trong tuần |
| a13.days.7 | That's seven active days this week. | cuối buổi (Complete), đếm ngày vận động trong tuần |
| a13.walk.2 | Second walk this week. Nice and steady. | cuối buổi đi bộ, thay `a13.days.*` khi là buổi đi bộ |
| a13.walk.3 | Third walk this week. Nice and steady. | cuối buổi đi bộ, thay `a13.days.*` khi là buổi đi bộ |
| a13.walk.4 | Fourth walk this week. Nice and steady. | cuối buổi đi bộ, thay `a13.days.*` khi là buổi đi bộ |
| a13.walk.5 | Fifth walk this week. Nice and steady. | cuối buổi đi bộ, thay `a13.days.*` khi là buổi đi bộ |

## 3. Bản Việt
`docs/i18n/vi/voice-a13.json` (41 câu, theo [glossary-vi.md](../i18n/glossary-vi.md): "ngày vận động", "Đều đặn", "theo nhịp của bạn"; số viết bằng chữ).

## 4. Thu giọng (task 4.14, phiên Mac)
`render_lines_vibi.py --voice bella-v4 --all` → `build_manifest.py` → `qc_lines.py`; VI `--voice bella-v4-vi` → `build_content_overlay.py vi --cache assets/voice/cache-vi-bella-v4` (luôn kèm `--cache`). Nghe thử N = 3, 12; week 1; days 3 (EN + VI).
