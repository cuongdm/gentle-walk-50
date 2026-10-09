# Cài RevenueCat cho Good Footing: các bước của chủ app
_09/10/2026. Quyết định của chủ app: dùng SDK RevenueCat trong app, tài khoản RevenueCat **riêng** cho app này. Giá: năm 49,99 USD (dùng thử 14 ngày), tháng 9,99, trả một lần 99,99._

Chia việc: phần A và B là việc **bạn** làm trên web (khoá và tài khoản là của bạn). Phần C là việc tôi làm sau khi bạn báo xong. Không dán khoá bí mật vào chat.

## A. App Store Connect
_Đã làm 09/10/2026 bằng Claude in Chrome: bước 0 (App ID `com.kmd.goodfooting`, có HealthKit) và bước 1 (app "Good Footing: Gentle Workouts", iOS, English (U.S.), SKU `goodfooting`, Apple ID `6820763820`). Còn bước 2 trở đi._

0. **Đăng ký Bundle ID trước** (lỗi "The key is not valid or is not compatible with the Bundle ID" trong RevenueCat là do thiếu bước này): developer.apple.com → Certificates, Identifiers & Profiles → Identifiers → + → App IDs → App. Bundle ID **Explicit** `com.kmd.goodfooting`, bật capability **HealthKit** (và In-App Purchase nếu có). Bundle ID này đã được đổi trong dự án ngày 09/10/2026.
1. **App mới:** Apps → + → New App, chọn Bundle ID vừa đăng ký `com.kmd.goodfooting`. Tên: "Good Footing: Gentle Workouts" (còn chờ luật sư nhãn hiệu xem; đổi được sau).
2. **Nhóm đăng ký:** Monetization → Subscriptions → tạo nhóm "Good Footing Pro".
3. **3 sản phẩm** (mã phải đúng từng ký tự):

| Mã sản phẩm | Loại | Thời hạn | Giá (Mỹ) | Ghi chú |
|---|---|---|---|---|
| `com.kmd.goodfooting.pro.yearly` | Auto-renewable | 1 năm | 49,99 USD | **Introductory Offer**: Free, 2 tuần, người mới, mọi quốc gia |
| `com.kmd.goodfooting.pro.monthly` | Auto-renewable | 1 tháng | 9,99 USD | không dùng thử |
| `com.kmd.goodfooting.pro.lifetime` | **Non-Consumable** (In-App Purchase) | — | 99,99 USD | |

   Mỗi sản phẩm cần tên hiển thị và mô tả tiếng Anh, và ảnh chụp màn paywall để duyệt (lấy từ bản chụp `paywall-eligible`).
4. **Khoá (tải về một lần, giữ file `.p8`):**
   - **Bắt buộc:** Users and Access → Integrations → **In-App Purchase** → tạo khoá. Ghi lại Key ID và **Issuer ID** (hiện ở đầu trang). RevenueCat dùng khoá này để xác nhận giao dịch của SDK mới; thiếu thì mua xong vẫn không được ghi nhận. Một khoá dùng được cho mọi app cùng tài khoản App Store Connect, nên bạn có thể dùng lại khoá đã tạo cho MeowBreathe.
   - **Tuỳ chọn:** Integrations → **App Store Connect API** → Team Keys, quyền **App Manager**. Chỉ giúp RevenueCat tự nhập sản phẩm từ App Store Connect và đọc doanh thu. Hai khoá này khác loại, **không thay cho nhau được**. Nếu đầu trang In-App Purchase không hiện Issuer ID, tạo khoá App Store Connect API (tên và quyền nào cũng được) để lấy Issuer ID.

## B. RevenueCat (tài khoản mới)
1. Tạo project **Good Footing**.
2. Project settings → Apps → + New → **App Store**. Bundle ID `com.kmd.goodfooting` (nếu app "Good Footing - Cuong (App Store)" đã tạo với Bundle ID khác thì sửa Bundle ID trong cài đặt app, hoặc xoá và tạo lại; làm sau khi App Store Connect đã có app, rồi bấm **Check credentials** lại). Tải lên khoá In-App Purchase (.p8, Key ID, Issuer ID). Khoá App Store Connect API (.p8, Key ID, Issuer ID, Vendor number) tải thêm nếu bạn đã có, không bắt buộc.
3. Project settings → **API keys** → + New secret API key → **V2**, quyền đọc và ghi cấu hình project (apps, products, entitlements, offerings, packages). Lưu vào file trên máy bạn, **không dán vào chat**:
   ```bash
   mkdir -p ~/.config/revenuecat && printf '%s' 'DÁN_KHOÁ_sk_Ở_ĐÂY' > ~/.config/revenuecat/good-footing.key && chmod 600 ~/.config/revenuecat/good-footing.key
   ```
4. Mở trang của app App Store trong RevenueCat, sao chép **public SDK key** (bắt đầu bằng `appl_`). Khoá này không bí mật; nhắn cho tôi hoặc đặt vào `iOS/Config/Local.xcconfig` đúng tên biến mà nhánh `local/revenuecat` ghi trong báo cáo.
5. Nhắn tôi "xong A và B".

## Tình trạng ngày 09/10/2026 (đã làm bằng Claude in Chrome, không cần khoá bí mật)
- RevenueCat (project `e94f818d`, app App Store `app61771b806c`, bundle ID `com.kmd.goodfooting`): đã tạo 3 sản phẩm theo đúng mã, quyền `pro` gắn 3 sản phẩm, gói `default` có `$rc_monthly`, `$rc_annual`, `$rc_lifetime` gắn vào 3 sản phẩm App Store. Quyền cũ "Cuong Pro" và các sản phẩm Test Store không bị đụng.
- Khoá SDK công khai (`appl_…`) đã đặt vào `iOS/Config/Local.xcconfig` (file không commit), test kiểm tra khoá của cổng phát hành xanh.
- **Khoá đã hợp lệ (09/10/2026, sau khi chủ app tải lại khoá gốc):** cả khoá In-App Purchase `49K6TC2584` và khoá App Store Connect API đều báo "Valid credentials" trong RevenueCat.
- **Sản phẩm trên App Store Connect (09/10/2026, tạo bằng Product editor của RevenueCat từ file CSV, rồi bổ sung bằng Chrome và skill `appstore-connect-sync`):**
  - Nhóm "Good Footing Pro" (có tên hiển thị en-US); yearly cấp 1, monthly cấp 2.
  - Yearly 49,99 USD, dùng thử 2 tuần (lịch bắt đầu 09/10/2026); monthly 9,99; lifetime (non-consumable) 99,99 USD.
  - Mỗi sản phẩm có tên + mô tả en-US ("Every walk, chair move and stretch.") và ảnh duyệt paywall chụp từ bản build hiện tại (đúng giá) kèm ghi chú duyệt.
  - Thông báo máy chủ App Store → RevenueCat đã đặt (RevenueCat báo "configured correctly").
- **Việc còn lại của chủ app:** (1) ~~Availability của 3 sản phẩm chỉ 1/175 nước~~ — **đã mở 175/175 ngày 09/10/2026** bằng `tools/appstore/asc-open-territories.py` (đăng ký năm và tháng có giá cho đủ 175 nước theo bảng giá tương đương của Apple; mua một lần có mặt ở 175 nước). Lưu ý: ô "all countries" trên web chỉ bật availability, **không** tạo giá, nên storefront ngoài Mỹ báo "This item is not available"; chạy lại script (mặc định chỉ đọc, thêm `--apply` để ghi) nếu thêm sản phẩm mới. Availability của **app** vẫn là chỉ Mỹ (mục 5 của `asc-listing-fields.md`). (2) Bấm "Add for Review" cho nhóm đăng ký cùng bản app 1.0 (đăng ký đầu tiên phải nộp cùng một phiên bản app). (3) Thử mua bằng tài khoản Sandbox. Gặp "This item is not available.": xem `purchase-troubleshooting.md`.

## C. Phần tôi làm sau đó
1. Đọc khoá từ file (không in ra), gọi RevenueCat REST API v2 để tạo: quyền `pro`; 3 sản phẩm; gói mặc định `default` với `$rc_annual`, `$rc_monthly`, `$rc_lifetime`; gắn sản phẩm vào quyền `pro`.
2. Kiểm tra lại bằng cách đọc ngược cấu hình, rồi báo bạn.
3. Bạn thử mua trên iPhone thật bằng tài khoản Sandbox (App Store Connect → Users and Access → Sandbox) trước khi nộp.

## Lưu ý
- Giá và dùng thử đặt ở App Store Connect, không đặt ở RevenueCat.
- Nhãn quyền riêng tư của app đổi vì có RevenueCat: xem mục privacy trong `docs/release/1.0/checklist.md` do nhánh tích hợp cập nhật.
- Chưa có khoá thật thì app vẫn chạy: cửa hàng báo "không khả dụng", người dùng ở bản miễn phí.
