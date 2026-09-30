# Review UI/UX toàn app — 30/09/2026

**Phạm vi:** chỉ lăng kính 2 (UI/UX), toàn app, en-US. Commit `44bf590`.
**Bằng chứng:** 195 ảnh (`-ScreenshotMode`): 83 trạng thái iPhone 17 sáng; 28 màn chính ở mỗi chế độ: tối, cỡ chữ AX5, iPhone SE, iPad Pro 13.
**Các lăng kính khác:** bỏ qua theo yêu cầu (code, ngôn ngữ, pháp lý, riêng tư, hiệu năng đã review 29/09).

**Phán quyết:** Pass with notes — 0 Critical · 6 Important · 6 Minor (U12 thêm trong lúc sửa).

## Important

| ID | Màn | Lỗi | Khi nào | Sửa đề xuất |
|---|---|---|---|---|
| U1 | Break, Rest, This hurts, Cancel guide, Before you head out, Two quick things, Postcard, Try something else, player ghế/giãn cơ | iPad: nội dung trải hết 1000+ pt; nút Break/This hurts dài cả màn, tranh Break bị cắt đầu | iPad dọc/ngang | Khung đọc chung tối đa 700 pt, căn giữa (như Today, Journey, Onboarding đã làm) |
| U2 | Break, Rest, Onboarding plan, Goal, Preview, This hurts, player ghế/giãn cơ | Cỡ chữ AX5: chữ bị cắt "Take your ti…", "00:…", "Seate…"; Onboarding plan tràn ngang (mất mép trái); hàng icon + chữ + radio vỡ từng chữ ("Mov/e", "Sw/ap"); chip "Somewhere els" tràn mép; tên động tác bị thu nhỏ còn cỡ caption | Cỡ chữ lớn | Bỏ `lineLimit(1)` ở tiêu đề/nút; hàng chọn và hàng động tác xếp dọc ở cỡ AX; chip dùng bố cục xuống dòng; dải tuần ở Plan cuộn ngang hoặc ẩn nhãn |
| U3 | Player ghế + giãn cơ (dọc) | Phụ đề nền đen bị cắt dưới hàng Back · ⏸ · Skip; mẹo động tác và Easier/Harder nằm trong vùng cuộn nhỏ | iPhone 17 và SE | Làm cùng kiểu màn đi bộ mới: phụ đề chữ thường, bỏ khối đen, vùng giữa gọn lại |
| U4 | Complete (mọi biến thể) | HLV giơ tay chiếm ~35 % màn trên cùng; "How did that feel?" và Done bị đẩy xuống dưới nếp gấp; Level up có hai hình (lá + HLV) chồng ý | Mọi máy | HLV nhỏ lại, đặt cạnh lời khen; bỏ hình trùng ở Level up; cảm nhận + Done thấy ngay không cần cuộn |
| U5 | Onboarding "No surprises…", "Sore knees…" | Nút Continue nằm ngay dưới chữ, nửa dưới trống; các bước onboarding khác ghim nút ở đáy | Mọi máy | Dùng `pinnedActions` như các bước khác |
| U6 | Complete, Countdown, Preview chair, Progress (cây), thẻ All sessions | Chế độ tối: khối giấy kem sáng quanh tranh HLV/cây chói trên nền tối | Dark mode | Màu `artPaper` bản tối dịu hơn (giữ tranh, giảm độ sáng khối nền) |

## Minor

| ID | Màn | Lỗi | Sửa đề xuất |
|---|---|---|---|
| U7 | Walk player trên SE | Video bị ẩn nhưng còn khoảng trống ~130 pt giữa phụ đề và nút | Hạ chiều cao tối thiểu của video để vừa SE, hoặc dồn khoảng trống |
| U8 | Me | Mỗi thẻ có dòng link riêng "Edit" / "Change" / "How to cancel" làm thẻ cao | Cả hàng bấm được, mũi tên › bên phải, bỏ dòng link |
| U9 | Preview, Try something else | Dòng "Close" đứng riêng một hàng trên cùng | Đưa vào thanh trên cùng cạnh tiêu đề (tiết kiệm ~40 pt) |
| U10 | Code | Cỡ chữ cố định không co giãn: `TodayView.swift:225` (36), `ChairPlayerView.swift:92` (26), `CompleteView.swift:184` (64), `PaywallView.swift:94,119` (18), `JourneyMapView.swift:111` (9) | `@ScaledMetric` hoặc `.typeRole` |
| U11 | Outdoor player | Khoảng trống lớn giữa "Next" và nút (không có video) | Tranh ngoài trời lớn hơn thay cho khoảng trống |
| U12 | Today · Extras | Chủ app hỏi "phần này có ý nghĩa gì?": không có dòng giải thích, biểu tượng mờ, khác All sessions | Dòng giải thích + thẻ có tranh và nhãn Video như All sessions |

## Đã tốt
- Today, Journey mới, All sessions, Paywall, Walk player mới: bố cục gọn, đúng thứ bậc, sáng/tối ổn.
- SE: không màn nào mất nút an toàn; Walk/ghế ẩn hình trước, giữ nút.
- Paywall giữ đủ Restore · Terms · Privacy ở mọi biến thể.

## Cần tự kiểm
- Xoay ngang bằng nút phóng to trên máy thật (iPhone 11).
- iPad chia đôi màn hình (Split View) — chưa chụp.

## Fix log (30/09 — chủ app: "Sửa tất cả")
- U1 — `readableColumn()` (700 pt, `Metrics.readableWidth`): Break, Rest, Stand behind, This hurts, Cancel guide, Outdoor prep, Permissions, Swap, Phone placement, Postcard, Where next, player ghế + giãn cơ.
- U2 — `scrollsWhenCrowded()` cho Break / Rest / Stand behind (Rest: Break · This hurts cố định ngoài vùng cuộn); đồng hồ co thay vì "…"; Next up xếp dọc; `SelectableCard` + danh sách Preview ẩn biểu tượng ở cỡ AX, Swap xuống dưới tên; `FlowLayout` không cho chip tràn mép; dải tuần Plan xuống dòng ở cỡ AX. Ảnh AX5: không còn chữ bị cắt ở các màn đã kiểm.
- U3 — player ghế + giãn cơ: phụ đề chữ thường, luôn ngay trên hàng Back · ⏸ · Skip.
- U4 — Complete: `CompleteHero` (HLV 132 pt cạnh lời khen; lên cấp = huy hiệu + "You reached Sprout" thay HLV); bưu thiếp 150 pt. "How did that feel?" thấy ngay không cần cuộn trên iPhone 17.
- U5 — Onboarding: Continue ghim đáy ở Part 1/2/3 và Understanding.
- U6 — `artPaper` có bản tối (#D6CEC1).
- U7/U11 — `WalkScene` co giãn vào chỗ trống và tự ẩn dưới 80 pt: SE giờ có video/tranh; tranh ngoài trời lớn hơn.
- U8 — Me: link Edit / Change / How to cancel lên dòng tiêu đề thẻ (xuống dòng khi chữ lớn).
- U9 — `ClosableHeader`: Close cùng dòng tiêu đề ở Preview và Try something else.
- U10 — cỡ chữ cố định → `typeRole` (tên động tác, biểu tượng thẻ Today, biểu tượng Paywall có giới hạn trong vòng 40 pt).
- U12 — Extras dựng từ `SessionCatalog` (cùng tên, tranh, nhãn Video với All sessions) + dòng giải thích; `SessionVideo` dùng chung.
- Kiểm: 125 tests / 32 suites pass (1 known issue iOS 27); copy lint 0; ảnh iPhone 17 sáng/tối/AX5, SE, iPad.
- Còn lại: player ghế ở AX5 vẫn chật (mẹo động tác cuộn trong vùng nhỏ) — chấp nhận, giữ nút an toàn cố định.
