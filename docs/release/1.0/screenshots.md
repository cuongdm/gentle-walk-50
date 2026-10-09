# Good Footing 1.0 — màn chụp cho store (task 9.5)
_29/09/2026. Mọi màn chụp bằng hook `-ScreenshotMode <state>` (dữ liệu mẫu Margaret, `App/Debug/Fixtures/en-US.json`). Lệnh:_

```bash
iOS/scripts/capture_states.sh docs/release/1.0/shots "iPhone 17 Pro Max" walk-player chair-player paywall-eligible today journey complete stretch-player progress
```

## Bộ ảnh store đã làm (09/10/2026)
Ảnh có khung và chữ: `appstore/output/iPhone/en` (7 ảnh) và `appstore/output/iPad/en` (6 ảnh), chữ ở `appstore/captions.txt`, cách làm lại ở `appstore/README.md`. iPhone: onboarding-welcome, today-goal-line, walk-player, chair-player, program, progress-results, journey. iPad bỏ Welcome (một cột hẹp trên trang trống), dùng Today làm ảnh đầu.

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

### Bổ sung 08/10/2026: font A1, chiều sâu mềm, icon Phosphor, onboarding mới, cá nhân hoá
Mọi ảnh trên phải **chụp lại** sau commit e15a38b, 2b9ecd2 và 016196a. Lý do:
- Đổi chữ: New York cho tiêu đề, SF Pro cho chữ, Rounded chỉ cho số.
- Nút chính xanh 64 pt có chiều sâu mềm; thẻ giấy.
- Icon Phosphor trên chip màu nước.
- Lời chào và mục tiêu nhắc lại trên Hôm nay.
- Ảnh cũ trong `docs/release/1.0/shots` (nếu còn) không dùng được.

Lựa chọn thay thế cho ảnh 2 và 4 (cùng thông điệp, mạnh hơn nhờ cá nhân hoá):

| Thay | Trạng thái | Nói gì | Ghi chú |
|---|---|---|---|
| 2 | `today-goal-line` | Buổi hôm nay gắn với mục tiêu của cô ấy | "For steadier feet" dưới thẻ bài (P4) |
| 4 | `progress-results` | "Your results": 4 tuần, chỉ so với chính mình | 5 tuần buổi tập, 3 lần tự kiểm tra. Có dòng "not medical advice" |

Ảnh phụ nếu cần ảnh thứ 6: `onboarding-plan` ("Your plan" với thẻ Day 1 và "Hear your coach").

Không dùng các màn sau làm ảnh store, vì chúng chỉ hiện khi có tín hiệu riêng:
- `weekly-checkin`
- `today-move-reminder`
- `today-set-aside`
- `me-set-aside`

Lệnh chụp lại (sáng; thêm `CAPTURE_LANG=vi CAPTURE_LOCALE=vi_VN` cho bản Việt nội bộ):
```bash
iOS/scripts/capture_states.sh docs/release/1.0/shots "iPhone 17 Pro Max" onboarding-welcome today-program today-goal-line chair-player progress-checks progress-results journey onboarding-plan
iOS/scripts/capture_states.sh docs/release/1.0/shots-ipad "iPad Pro 13-inch (M5)" onboarding-welcome today-program chair-player progress-checks journey
```
Tên máy iPad lấy theo `xcrun simctl list devices` trên Mac.

### Ảnh cho người duyệt (không đăng store; đính kèm khi App Review hỏi, hoặc dùng để tự kiểm trước khi nộp)

| Trạng thái | Chứng minh điều gì | Guideline |
|---|---|---|
| `paywall-eligible` | Paywall gọn: chỉ gói năm, có dòng thời gian dùng thử. Giá bị trừ là giá to nhất; ngay dưới nút có điều khoản tự gia hạn; có Maybe later, Restore · Terms · Privacy | 3.1.1, 3.1.2 |
| `paywall-monthly` | "See other plans" mở đủ 3 gói tại chỗ, bộ ba vẫn trong màn | 3.1.2 |
| `paywall-not-eligible` | Không đủ điều kiện dùng thử thì không nói "free" | 3.1.2(a) |
| `paywall-lifetime-while-subscribed` | Cảnh báo trước khi mua trả một lần khi còn gói tự gia hạn | 3.1.2 |
| `permissions-reminder`, `permissions-health` | Mỗi màn một quyền, sau buổi đầu; nút gọi tên tính năng, không ghi "Allow" | 5.1.1 |
| `outdoor-measure-choice`, `outdoor-location-prompt` | Hỏi cách đo trước; màn mồi vị trí chỉ có một nút | 5.1.1(iv) |
| `selfcheck-intro`, `progress-checks` | "This is not a medical test.", chỉ so với chính mình, không bảng chuẩn | 1.4.1 |

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
