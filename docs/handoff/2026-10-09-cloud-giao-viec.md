# Giao việc cho cloud — 09/10/2026 (chủ app: "giao all")

Hai việc cloud làm song song, mỗi việc một nhánh riêng. Cả hai **chỉ cần đọc/viết file**, không cần Xcode.
Gốc: `origin/mac/integration` (= main của máy Mac lúc giao việc). Phiên Mac gộp kết quả sau khi chủ app xem.

Luật chung cho cả hai việc (theo `CLAUDE.md` gốc):
- Đọc `app-context.md` và `CLAUDE.md` của dự án trước. Chữ cho chủ app bằng tiếng Việt; code, comment, commit bằng tiếng Anh.
- Commit bằng danh tính repo đã dùng (`Cuong`), **không** `Co-Authored-By`, không "Generated with…", không danh tính AI.
- Chỉ push nhánh của mình (`cloud/site-pages` hoặc `cloud/review-round2`). Không push `main` / `mac/integration`, không tag, không release, không bật cài đặt GitHub (Pages, secrets…).
- Không dán khoá, token, mã bí mật vào file hay commit.
- Cấm câu y khoa: không "prevent falls", "fall risk", "build bone", "relieve pain"; hứa duy nhất "steadier on your feet / easier getting up from a chair" (`docs/design/steady-claims.md`). Chạy `python3 tools/lint/copy_lint.py` nếu việc đụng chữ hiển thị.
- Việc cuối: một báo cáo ngắn (Vietnamese, ≤ 15 dòng, "unresolved questions" ở cuối) ghi trong file `docs/handoff/` của việc đó.

---
## Việc 1 — Trang Privacy + Support (nhánh `cloud/site-pages`)

Đang chặn việc nộp App Store: ASC bắt buộc Privacy Policy URL và Support URL (không nhận `mailto:`). Xem `docs/release/1.0/asc-listing-fields.md` mục B1–B3.

Làm:
1. `site/privacy.html`: điền `Last updated` = "October 9, 2026" (bỏ `[date of publication]`). Đối chiếu từng đoạn với app thật: `iOS/App/PrivacyInfo.xcprivacy` (hoặc đường dẫn thật của nó), các `NS…UsageDescription` trong `iOS/project.yml`, mục privacy của `docs/release/1.0/checklist.md`, và code RevenueCat (`iOS/App/Services/Store/RevenueCatBackend.swift`): trang phải đúng sự thật, không nói "Data Not Collected" / "we don't collect your data" (mua hàng đi tới RevenueCat dưới ID ngẫu nhiên). Sửa chỗ sai/thiếu, ghi lại trong báo cáo.
2. Tạo `site/support.html` cùng kiểu dáng với `privacy.html` (cùng CSS, sáng/tối, chữ ≥ 19px): email hỗ trợ `cuongdm@live.com` (chủ app còn phải xác nhận đây là email công khai, ghi trong báo cáo), cách huỷ gói (Settings → tên bạn → Subscriptions), Restore (tìm đúng đường đi trong app bằng cách grep chuỗi "Restore" trong `iOS/App/Localizable.xcstrings`), xoá dữ liệu (Me → Delete all my data), vài câu hỏi thường gặp ngắn (Apple Health, nhắc giờ, không có tài khoản), và dòng "Good Footing is for general fitness. It isn't medical advice."
3. Tạo `site/index.html` rất ngắn (tên app, khẩu hiệu "Steadier on your feet, at your own pace.", link tới Privacy và Support). Không giá, không số tự bịa, không tên nền tảng khác.
4. Tạo `.github/workflows/pages.yml` đăng thư mục `site/` bằng GitHub Pages (actions/configure-pages, upload-pages-artifact, deploy-pages; kích hoạt `workflow_dispatch` và push vào `main` có đổi `site/**`). **Chỉ tạo file**, không bật Pages (chủ app / phiên Mac bật sau khi xác nhận).
5. Cập nhật `docs/release/1.0/asc-listing-fields.md` B1/B3: trạng thái mới, và URL dự kiến (mặc định `https://cuongdm.github.io/gentle-walk-50/privacy.html` và `/support.html`; nhắc rằng tên repo là tên cũ, muốn tên mới cần tên miền riêng — chủ app quyết). **Không** thay `{{PRIVACY_URL}}` trong `appstore/metadata-json/en.json` và không sửa `_config.json` (làm sau khi URL chạy thật).
6. Kiểm: mở HTML bằng `python3 -m http.server` + đọc lại, hoặc kiểm cú pháp; không có link chết; không có JS ngoài.

Báo cáo vào `docs/handoff/2026-10-09-cloud-site-ket-qua.md`.

---
## Việc 2 — Review toàn app vòng 2, chỉ ghi phát hiện (nhánh `cloud/review-round2`)

Yêu cầu gốc của chủ app: "review kỹ toàn bộ app, tổng quan, thiết kế… căn kẽ chi tiết, tiết kiệm khoảng trống, hạn chế scroll quá dài." Vòng 1 là `docs/reviews/m5-2026-10-09/review-{A..D}.md`; vòng 2 xem lại sau các thay đổi từ đó: SDK RevenueCat (`iOS/App/Services/Store/`), sửa lỗi mua (`PaywallModel`, `PaywallNotice`, `StoreService`), nối Kế hoạch ↔ Hành trình (`StageRecaps` trong `GentleWalkCore`, các thẻ trên Today/Program/Journey), thẻ kết quả theo số lượng (`iOS/App/Features/Progress/ResultTileGrid.swift`, `YourResultsCard.swift`, `TreeArtTile.swift`), icon mới.

Làm theo `manh-skill-review` (sáu lăng kính), **chỉ đọc, KHÔNG sửa mã nguồn, KHÔNG sửa chuỗi, KHÔNG sửa test**:
1. Code đúng/sai: logic mua (entitlement `pro`, các nhánh lỗi), `StageRecaps` (biên ngày, múi giờ, người dùng miễn phí không thấy tên điểm dừng ngoài chặng miễn phí, `Delete all my data` xoá cả dấu "Pick up at week N"), SwiftData/UserDefaults, `@Observable` narrow input, identity `ForEach`.
2. Giao diện/UX từ **đọc code SwiftUI** (cloud không chạy được Xcode): khoảng trống thừa, chiều dài cuộn (màn nào chồng nhiều thẻ), mục tiêu chạm ≥ 56 pt, chữ ≥ 17 pt, Dynamic Type (`ViewThatFits`, ô xếp dọc ở cỡ chữ lớn), token màu/khoảng cách (`Palette`, `Metrics`, `.typeRole`), tương phản (`Palette.textPairs`), tối/sáng, iPad. Có ảnh trong repo (`appstore/output/`, `docs/**/screenshots*`) thì xem thêm.
3. Ngôn ngữ: `python3 iOS/scripts/xcstrings_coverage.py`, `python3 tools/i18n/apply_catalog.py --check` (nếu chạy được); đọc các chuỗi mới EN/VI xem tự nhiên, nối chuỗi, số nhiều.
4. Pháp lý/App Store: `docs/release/1.0/checklist.md`, App Review 3.1.2 (3 điều: Restore, Terms+Privacy, giá thật nổi nhất; thử miễn phí/tự gia hạn rõ ràng; "Maybe later"), 1.4.1 (y khoa), 5.1.1 (quyền, xoá dữ liệu), 5.6.1 (hộp đánh giá), nhãn quyền riêng tư vs RevenueCat.
5. Riêng tư/bảo mật: `PrivacyInfo.xcprivacy`, khoá RevenueCat chỉ lấy từ `Local.xcconfig`, không khoá trong repo, UserDefaults cho dữ liệu nhạy cảm, repo đang **public**: liệt kê tài liệu/chi tiết nên cân nhắc không công khai (không xoá gì).
6. Hiệu năng/build: vùng gây vẽ lại (`@Observable` lớn), việc nặng trên main thread, `init` có việc nặng, thẻ ảnh nặng.

Mỗi phát hiện: `[Lens] [Critical|Important|Minor] file:dòng — chuyện gì sai, khi nào, vì sao, cách sửa` và mức chắc chắn ("likely" khi chưa chắc). Không có file:dòng thì không phải phát hiện. Không "nit" văn phong. Cuối mỗi lăng kính: phán quyết Pass / Pass with notes / Fail. Cuối báo cáo: danh sách "cần chủ app tự kiểm tra" (App Store Connect, máy thật), thứ tự sửa đề xuất, và mục "điều tốt" ngắn.

Ghi vào `docs/reviews/2026-10-09-round2/` (một file mỗi lăng kính `lens-1-code.md` … `lens-6-perf.md` + `SUMMARY.md` tiếng Việt, ≤ 1 trang, danh sách Critical đầu tiên). Nếu có `swift` chạy được: `cd iOS/Packages/GentleWalkCore && swift test`, ghi kết quả; không chạy được thì ghi "không chạy".
