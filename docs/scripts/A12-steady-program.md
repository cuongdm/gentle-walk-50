# A12 — Chương trình vững chân: tự kiểm tra 2 tuần · bản nháp 1 (CHỜ CHỦ APP DUYỆT)
_08/10/2026 · Theo [kế hoạch steady-program](../plans/2026-10-08-steady-program.md) Task 4.7, 5.1 · Luật câu chữ: [steady-claims.md](../design/steady-claims.md) · Dùng lại `a5.n.1–3` ("One." "Two." "Three.") và `a5.half` ("Halfway there.") từ [A-min-support.md](A-min-support.md) · Chữ thoại tiếng Anh Mỹ, ghi chú tiếng Việt_

## 1. Quy tắc
- Giọng như A1/A11: nữ 58–65, trầm ấm, khoảng 130 từ/phút, không gọi tên, bản dễ trước. Mỗi câu ≤ 16 từ.
- Không nói "test" theo nghĩa y khoa, không "fall", không "risk", không so với người khác hay theo tuổi. Tự kiểm tra là "your 2-week check".
- Được phép chống tay: câu chuẩn bị nói cả hai cách, cách nào cũng được (chỉ so cùng cách).

## 2. Âm thanh 30 giây (`SessionTimeline.selfCheck`, tổng 40 s)
| Giây | Âm | Câu |
|---|---|---|
| 0 | `a12.check.setup` | chuẩn bị |
| 5 · 6 · 7 | `a5.n.3` · `a5.n.2` · `a5.n.1` | đếm ngược (dùng lại) |
| 8 | chuông pha + `a12.check.go` | bắt đầu 30 giây |
| 23 | chuông pha + `a5.half` | giữa chừng (dùng lại) |
| 38 | chuông kết + `a12.check.stop` | dừng, nhập số |
Chưa thu kịp thì chuông vẫn kêu và màn hình hiện chữ (đồng hồ, "Go", "Stop"): luồng chạy được không cần giọng.

## 3. Câu mới (cần thu EN + VI)
| ID | Câu thoại | Ghi chú |
|---|---|---|
| a12.check.setup | Sit near the front of your chair, feet flat. Ready? | mở đầu, trước đếm ngược |
| a12.check.go | Go. Stand up all the way, then sit back down. At your own pace. | giây 0 của 30 giây |
| a12.check.stop | And stop. Rest a moment, then enter how many times you stood up. | giây 30, sau chuông kết |

## 4. Câu đề xuất, chưa nối vào buổi tập (không build, không thu ở 1.0)
Các câu sau chỉ là đề xuất cho bản sau; bản 1.0 nói những điều này bằng chữ trên màn hình (Hôm nay, Hoàn thành, Kế hoạch). Không có cột ID nên `build_content.py` bỏ qua.
- Bắt đầu chương trình: "This is your 12-week plan. A little steadier each week, at your own pace."
- Sang chặng 2 / 3 / 4: "Stage two: building strength. Same moves, a little more." · "Stage three: a gentle challenge. Go up only when it feels right." · "Stage four: your routine. Keep what feels good."
- Lên số lần: "You did all of these twice in a row. Next time, a few more."
- Hết 12 tuần: "Twelve weeks. Look how far you've come, at your own pace."

## 5. Bản Việt
`docs/i18n/vi/voice-a12.json` (3 câu mục 3), theo [glossary-vi.md](../i18n/glossary-vi.md): "Tự kiểm tra 2 tuần", không dùng "bài kiểm tra".
