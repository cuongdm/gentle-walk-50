# Cài RevenueCat cho Good Footing: các bước của chủ app
_09/10/2026. Quyết định của chủ app: dùng SDK RevenueCat trong app, tài khoản RevenueCat **riêng** cho app này. Giá: năm 49,99 USD (dùng thử 14 ngày), tháng 9,99, trả một lần 99,99._

Chia việc: phần A và B là việc **bạn** làm trên web (khoá và tài khoản là của bạn). Phần C là việc tôi làm sau khi bạn báo xong. Không dán khoá bí mật vào chat.

## A. App Store Connect
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

## C. Phần tôi làm sau đó
1. Đọc khoá từ file (không in ra), gọi RevenueCat REST API v2 để tạo: quyền `pro`; 3 sản phẩm; gói mặc định `default` với `$rc_annual`, `$rc_monthly`, `$rc_lifetime`; gắn sản phẩm vào quyền `pro`.
2. Kiểm tra lại bằng cách đọc ngược cấu hình, rồi báo bạn.
3. Bạn thử mua trên iPhone thật bằng tài khoản Sandbox (App Store Connect → Users and Access → Sandbox) trước khi nộp.

## Lưu ý
- Giá và dùng thử đặt ở App Store Connect, không đặt ở RevenueCat.
- Nhãn quyền riêng tư của app đổi vì có RevenueCat: xem mục privacy trong `docs/release/1.0/checklist.md` do nhánh tích hợp cập nhật.
- Chưa có khoá thật thì app vẫn chạy: cửa hàng báo "không khả dụng", người dùng ở bản miễn phí.
