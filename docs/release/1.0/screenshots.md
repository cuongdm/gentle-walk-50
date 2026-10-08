# Good Footing 1.0 — màn chụp cho store (task 9.5)
_29/09/2026. Mọi màn chụp bằng hook `-ScreenshotMode <state>` (dữ liệu mẫu Margaret, `App/Debug/Fixtures/en-US.json`). Lệnh:_

```bash
iOS/scripts/capture_states.sh docs/release/1.0/shots "iPhone 17 Pro Max" walk-player chair-player paywall-eligible today journey complete stretch-player progress
```

## Thứ tự mới theo chương trình vững chân (08/10/2026, kế hoạch steady-program Task 6.1) — dùng bảng này
```bash
iOS/scripts/capture_states.sh docs/release/1.0/shots "iPhone 17 Pro Max" onboarding-welcome today-program chair-player progress-checks journey
```
| # | Trạng thái (`-ScreenshotMode`) | Nói gì | Ghi chú |
|---|---|---|---|
| 1 | `onboarding-welcome` | Kế hoạch 12 tuần cho đôi chân khoẻ hơn, đứng vững hơn | Lời hứa một vấn đề. Tranh: một người ngồi, một người đứng cạnh ghế (todo yes2next) |
| 2 | `today-program` | Tuần 3/12 trên Hôm nay, buổi tập theo cảm giác | Thẻ "Week 3 of 12 · Plan ›" ngay dưới lời chào |
| 3 | `chair-player` | Bản ngồi, có nhãn mức vịn và số lần | Pro: nhãn "One hand on the chair" / "2 × 8" |
| 4 | `progress-checks` | Tự kiểm tra 2 tuần, chỉ so với chính mình | Số mẫu 7 → 8 → 9; không bảng chuẩn, không chữ "fall" |
| 5 | `journey` | Hành trình địa danh theo phút tập | Giữ từ bản cũ |
Ảnh thêm nếu cần: `program` (4 chặng), `selfcheck-intro` (an toàn + "This is not a medical test."), `paywall-eligible` (minh bạch tiền).
Chữ quảng cáo trên ảnh không được hứa phòng ngã, xương hay giảm đau (docs/design/steady-claims.md; lint `tools/lint/copy_lint.py`).

## Thứ tự cũ (29/09/2026, giữ để đối chiếu) (iPhone 6.9" và iPad 13")
| # | Trạng thái | Nói gì | Ghi chú |
|---|---|---|---|
| 1 | `walk-player` | Giọng dẫn, không cần nhìn màn hình | Trụ 1. Phụ đề hiện, nút Break/This hurts thấy rõ |
| 2 | `chair-player` | Mọi động tác có bản ngồi | Trụ 2. Clip thật, bộ đếm to |
| 3 | `paywall-eligible` | Minh bạch tiền: ngày trừ tiền ghi rõ | Trụ 3. Giá lấy từ App Store Connect khi chụp bản thật |
| 4 | `today` | Kế hoạch hôm nay theo cảm giác khớp | |
| 5 | `journey` | Hành trình địa danh New York | Tranh vẽ tay thay placeholder trước khi chụp |
| 6 | `complete` | Bưu thiếp, so với chính mình | |
| 7 | `stretch-player` | Giãn cơ nhẹ, giữ theo cường độ | Cần clip giãn cơ V7 |
| 8 | `progress` | Cây lớn dần, lịch không ô đỏ | |

- Không cảnh ngoài trời trong 3 ảnh đầu (spec: ngoài trời không phải định vị của app).
- iPad 13": dùng máy ảo iPad ngang cho `walk-player` (bố cục nửa màn); các màn còn lại dọc.
- Khung, chữ quảng cáo và mockup: skill `appstore-mockup` sau khi có tranh và giọng thật.

## Đã chạy thử (29/09/2026, iPhone 17, bản DEBUG)
Tất cả 80 trạng thái trong plan chụp được bằng `iOS/scripts/capture_states.sh` (ảnh lưu ngoài repo, không commit).
