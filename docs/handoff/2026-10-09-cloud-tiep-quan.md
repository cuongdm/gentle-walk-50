# Bàn giao cho phiên cloud — 09/10/2026 sáng (phiên Mac hết token)

Chủ app yêu cầu chuyển hết việc còn lại sang phiên cloud. Phiên Mac dừng ở đây.

## Trạng thái git
- `origin/mac/integration` = main local (d74ec2e + commit bàn giao này). Đã gộp đủ: đợt 0–4, App Review recheck (I-1, M-1, M-2, 54 câu VI, 2 câu VI thu lại), banner dùng thử báo trước 4 ngày, sửa ảnh nhóm B/C/D, đi ngoài trời không còn câu ghế (`OutdoorWalk`).
- Test trên Pro Max (iOS 27): core 282/282, app 287/287, release gate 2/2, VI 1068/1068, copy_lint 0.
- `origin/mac/m5-fix-a-wip` (9dc3e38, gốc 13ebbc5): sửa dở nhóm A (onboarding, paywall, quyền, ready-first-walk, đếm ngược, thanh trên màn đi bộ ở XXL). **Đã build được**; test app 287 chạy, chỉ hỏng các test StoreKit (StoreServiceTests, StoreConfigTests) — chạy trên máy ảo SE tạm, các test này cũng hỏng ở máy iPhone 11 tạm mà vẫn qua trên Pro Max ⇒ lỗi môi trường máy ảo mới, không phải code. Chưa xem lại ảnh sau sửa, chưa gộp vào main. Có `Localizable.xcstrings`/`ui.json` thay đổi → khi gộp phải tạo lại (build cờ `SWIFT_EMIT_LOC_STRINGS=YES` → extract → apply_catalog vi).

## Báo cáo xem ảnh (đợt 5)
`docs/reviews/m5-2026-10-09/review-{A,B,C,D}.md` — mỗi file có danh sách lỗi và "Fix log". B, C, D đã sửa xong; A đang dở (nhánh WIP trên).

## Việc cloud làm tiếp (theo thứ tự)
1. **Nhóm A:** đọc `review-A.md` + diff `mac/m5-fix-a-wip`; hoàn thiện phần còn thiếu theo review (2 Critical: thẻ "Have ready" XXL `WorkoutReadyView.swift`; thanh trên màn đi bộ XXL `WalkPlayerView.swift`; Important: "None of these" dưới mép SE ở anything-else, hàng giờ reminder-offer bị footer che trên SE, ghi chú gói năm bị cắt ở paywall-not-eligible XXL, trạng thái chụp `countdown` và `onboarding-goal` dark sai). Gộp vào `mac/integration`.
2. **Câu mở đầu đi ngoài trời (chủ app duyệt 09/10: "Thêm và thu giọng"):** EN "Pick a flat, familiar route, and walk at a pace where you can still talk." Thêm vào nguồn câu trong `docs/scripts/` (họ câu outdoor/opening), bản Việt tự nhiên cùng giọng các câu VI khác, `tools/content/build_content.py`; `OutdoorWalk` (GentleWalkCore) mở mọi bài ngoài trời bằng câu này, test core trước (`swift test` chạy được không cần Xcode). **Thu giọng** cần khoá Vibi trên Mac: nếu cloud không có thì để lệnh sẵn cho phiên Mac: `python3 tools/voice/render_lines_vibi.py --voice bella-v4 <id>`, `--voice bella-v4-vi <id>`, rồi `build_manifest.py --cache assets/voice/cache-bella-v4`, `tools/i18n/build_content_overlay.py vi --cache assets/voice/cache-vi-bella-v4`. Release gate sẽ đỏ tới khi thu xong — ghi rõ trong handoff.
3. **Viết `docs/handoff/2026-10-09-sang-mai.md`** (tiếng Việt cho chủ app): đã xong gì, còn lỗi gì, cần quyết gì trước release. Các mục chờ chủ app quyết đã có trong `docs/todo.md` (Start ở 60% màn SE, VI paywall, chair chip SE, Your results 4/8 tuần, set-aside 3 ngày, "Easier than I expected" +2 phút, 6 câu VI a8.* bị đánh dấu…) + Minor bỏ qua trong các Fix log (chấm xanh dark mode, tranh một tay dưới nhãn "Two hands", số bài giãn preview ≠ player, thẻ tranh màu be ở dark…).
4. Commit danh tính Cuong, không ghi AI; chỉ push `mac/integration` (không push main, không tag, không submit).

## Việc chỉ phiên Mac làm được (cần Xcode / máy ảo / khoá Vibi)
- Build + toàn bộ test sau khi cloud gộp nhóm A; tạo lại chuỗi (extract chỉ ngay sau build có cờ, không sau `xcodebuild test`).
- Thu giọng câu outdoor (nếu cloud chưa thu).
- Chụp lại các màn đã sửa trên SE/iPhone 11/Pro Max và **ảnh store** theo `docs/release/1.0/screenshots.md`.
- Xoá 3 máy ảo tạm: `GF M5 SE3` (A28757BC…), `GF M5 SE3 b` (30DEAC1E…), `GF M5 iPhone11` (E7FC15A8…); xoá worktree `../gf-fix-a`.
