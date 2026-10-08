# RevenueCat làm lớp mua hàng — kế hoạch 09/10/2026

**Plan (15 dòng):**
1. Chủ app chốt 09/10/2026: dùng SDK RevenueCat (`purchases-ios-spm`, SPM) thay StoreKit 2 trực tiếp; đảo quyết định cũ "StoreKit 2 direct, no RevenueCat". Tài khoản RevenueCat riêng, khoá công khai chưa có.
2. Giá: năm **49,99** (dùng thử **14 ngày**, giữ), tháng **9,99**, trả một lần **99,99** USD. Mã sản phẩm giữ nguyên. Phía RevenueCat (coordinator làm): entitlement `pro`, offering `default`, gói `$rc_annual` · `$rc_monthly` · `$rc_lifetime`.
3. Kiến trúc: `StoreService` (app, `@Observable`) giữ API cũ cho màn hình; bên dưới là seam `PurchaseBackend`. App dùng `RevenueCatBackend` (chỉ file này `import RevenueCat`); test dùng `FakePurchaseBackend` (không mạng).
4. Luật thuần (Foundation, `GentleWalkCore/Store/CustomerRules.swift`, `swift test`): `CustomerSnapshot` (phần cần của `CustomerInfo`) → `Entitlement` (free/trial/subscribed/lifetime), gói đang tự gia hạn + ngày, điều kiện dùng thử. Bỏ `TransactionSnapshot` và luật đọc giao dịch StoreKit cũ.
5. Quyền Pro = entitlement `pro` đang hoạt động (cập nhật qua `customerInfoStream` thay `Transaction.updates`); hết hạn/hoàn tiền → free; lifetime thắng; trial = `periodType == .trial`, ngày tính tiền = `expirationDate`.
6. Gói và giá: đọc offering hiện tại (gói năm/tháng/trọn đời); offering lỗi thì đọc thẳng 3 mã sản phẩm. Giá hiện = `localizedPriceString`; "$x a month" = giá năm thật / 12 (49,99 → $4.17). Số ngày dùng thử = intro offer miễn phí của gói năm (I-1, không viết cứng).
7. Không có khoá (`RevenueCatPublicKey` rỗng) hoặc đang chạy test: không cấu hình SDK, `StoreService` báo "không có cửa hàng" → bản miễn phí, paywall hiện trạng thái nhẹ nhàng + "Try again", không crash.
8. Khoá lấy từ build config: `REVENUECAT_PUBLIC_KEY` trong `iOS/Config/Local.xcconfig` (git-ignore) → Info.plist `RevenueCatPublicKey`; `Local.xcconfig.example` ghi chỗ điền. Cổng phát hành (`ReleaseContentTests`) đỏ khi thiếu khoá.
9. Người dùng ẩn danh (không gọi `logIn`), `Purchases.logLevel` = `.error` ở Release; tắt thu định danh thiết bị tự động (không dùng mạng quảng cáo).
10. Tuân thủ: paywall giữ bộ ba, giá bị trừ to nhất, "Maybe later", không đếm ngược; cảnh báo mua trả một lần khi còn gói tự gia hạn (3.1.2) giữ nguyên.
11. Quyền riêng tư: `PrivacyInfo.xcprivacy` khai Purchase History (không gắn danh tính, không theo dõi); chữ Privacy trong app + `site/privacy.html` + checklist nhãn ASC viết lại đúng sự thật (không còn "Data Not Collected"); EN + VI.
12. Tài liệu: CLAUDE.md (Entitlement truth), app-context (Price model + decisions log 09/10), todo, `docs/release/1.0/revenuecat-setup.md` chỉ khi chưa có.
13. Thứ tự: core test đỏ → xanh; app test (fake) đỏ → xanh; build; trích khoá + dịch VI; lint; test đầy đủ; cổng phát hành; chụp 5 trạng thái paywall/Today trên Pro Max.
14. Không làm: RevenueCatUI/paywall dựng sẵn, đăng nhập, web purchase, thử giá 39,99/49,99 (offering của RevenueCat làm được sau, app đã đọc offering).
15. Commit trên `local/revenuecat` bằng tên Cuong, không push, không merge.

## Decisions (một dòng mỗi quyết định)
- **Giữ `StoreService` làm mặt tiền, thêm seam `PurchaseBackend`:** màn hình và `AppModel` không đổi cách đọc; chỉ một file biết RevenueCat — dễ thay lại, test không cần mạng.
- **Luật quyền trong core:** `CustomerRules` thuần Foundation để `swift test` chạy được cả trên Linux; app chỉ chép trường từ `CustomerInfo`.
- **Hết hạn theo đồng hồ:** entitlement đang "active" nhưng `expirationDate` đã qua (cache cũ, mất mạng) vẫn tính là free — giống luật cũ "expired never count".
- **Gói đang gia hạn từ `subscriptionsByProductIdentifier`:** cảnh báo "lifetime khi còn gói" cần biết gói năm/tháng vẫn tự gia hạn dù entitlement đã chuyển sang lifetime.
- **Điều kiện dùng thử:** có intro offer miễn phí trên gói năm VÀ RevenueCat báo `eligible` (khi `unknown`: chưa từng mua gói nào trong lịch sử khách).
- **Offering trước, mã sản phẩm sau:** dùng được thử giá của RevenueCat (nghiên cứu §7.2 bước 5) mà không sửa app; vẫn chạy khi offering chưa cấu hình.

## Tasks
| # | Việc | File | Kết quả mong đợi |
|---|---|---|---|
| 1 | Test đỏ `CustomerRulesTests` (free, trial, subscribed, lifetime, hết hạn, hoàn tiền, gói gia hạn, điều kiện dùng thử) | `Packages/GentleWalkCore/Tests/.../CustomerRulesTests.swift` | `cannot find 'CustomerSnapshot'` |
| 2 | `CustomerRules` + bỏ luật giao dịch cũ | `GentleWalkCore/Store/CustomerRules.swift`, `EntitlementRules.swift` | core xanh |
| 3 | Gói SPM RevenueCat, khoá trong xcconfig → Info.plist | `iOS/project.yml`, `Config/*.xcconfig*` | `xcodegen generate`, resolve 5.94.0 |
| 4 | Test đỏ `StoreServiceTests` với `FakePurchaseBackend` | `GentleWalkTests/StoreServiceTests.swift` | không biên dịch được |
| 5 | `PurchaseBackend`, `StoreOffer`, `StoreService` mới, `RevenueCatBackend` | `App/Services/Store/*` | app test xanh |
| 6 | Paywall: options từ `StoreOffer`, "$4.17 a month", trạng thái không có cửa hàng + "Try again" | `Features/Paywall/*`, `Root/CoverView.swift` | `PaywallModelTests` xanh |
| 7 | Giá 49,99 / 9,99 / 99,99: `.storekit`, ảnh chụp, test, tài liệu | `GentleWalk.storekit`, `Debug/CaptureServices.swift`, `StoreConfigTests` | `StoreConfigTests` xanh |
| 8 | Quyền riêng tư (manifest, chữ trong app, site, checklist) + VI | `PrivacyInfo.xcprivacy`, `PaywallLegalFooter.swift`, `site/privacy.html`, `docs/i18n/vi/ui-extra-20.json` | copy_lint 0, catalog đủ en/vi |
| 9 | Tài liệu, luật | `CLAUDE.md`, `app-context.md`, `docs/todo.md`, `docs/release/1.0/*` | — |
| 10 | Build, trích khoá, test đầy đủ, cổng phát hành, ảnh | — | `** TEST SUCCEEDED **`, ảnh đúng giá |
