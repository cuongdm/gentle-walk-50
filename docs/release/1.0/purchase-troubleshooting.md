# Mua thử báo "This item is not available." — kiểm tra phía máy chủ
_09/10/2026, sau báo cáo của chủ app (TestFlight 1.0 (2), iPhone thật, giao diện tiếng Việt)._

## Trong app đã thấy gì
- Màn phía sau hộp thoại là bước **"Tiếp theo, Apple sẽ yêu cầu bạn xác nhận"** (khiên, "Tiếp tục", "Quay lại"). Đây là bước *trước* khi mua: app đang chờ Apple trả kết quả, **chưa** đi tiếp sang màn quyền hay buổi tập.
- Câu "This item is not available." **không có trong chữ của app**: đó là hộp thoại của Apple. RevenueCat chỉ chuyển lỗi của App Store sang mã của nó (sản phẩm không bán được → mã `5`, `productNotAvailableForPurchaseError`).
- Bản cũ sau đó còn hiện thêm "Không kết nối được App Store / kiểm tra kết nối" — sai nguyên nhân. Nhánh `local/purchase-unavailable` sửa: paywall giữ nguyên, hiện câu "Gói này chưa bán ở quốc gia App Store của bạn, hoặc lúc này chưa mua được…", đọc lại các gói một lần; không còn gói nào thì hiện "Hiện chưa tải được các gói". Chỉ rời paywall khi quyền `pro` thật sự bật.

## Checklist (theo thứ tự nên kiểm)
| # | Nguyên nhân có thể | Cách kiểm | Ghi chú |
|---|---|---|---|
| 1 | **Quốc gia App Store của tài khoản đang mua ≠ nơi bán sản phẩm** (khả năng cao nhất) | iPhone: Cài đặt → [tên bạn] → Phương tiện & Mục mua → Xem tài khoản → Quốc gia/Vùng. Dấu hiệu nhanh: giá trên paywall là giá cửa hàng trả về theo storefront ("$49.99" = Mỹ; "đ" = Việt Nam). | `revenuecat-setup.md` ghi 3 sản phẩm chỉ bán ở **Mỹ (1/175)**. Bản TestFlight mua bằng tài khoản Apple đang đăng nhập trên máy (không bị trừ tiền); tài khoản Việt Nam thì gói Mỹ có thể không mua được. Cách xử lý: tạm thêm Việt Nam (hoặc mọi nước) vào Availability của 3 sản phẩm, **hoặc** thử bằng tài khoản Sandbox quốc gia Mỹ trên bản chạy từ Xcode (mục 4). |
| 2 | Thoả thuận **Paid Applications** chưa hiệu lực, thiếu ngân hàng hoặc thuế | App Store Connect → Business (Agreements, Tax, and Banking): Paid Apps phải **Active**, ngân hàng và biểu thuế không còn mục chờ. | Repo không ghi trạng thái này. Thiếu thoả thuận thường làm gói không tải được; lần này paywall đã hiện giá nên ít khả năng hơn, nhưng vẫn kiểm. |
| 3 | **Trạng thái sản phẩm** chưa đủ | Monetization → Subscriptions (nhóm "Good Footing Pro") và In-App Purchases: từng sản phẩm phải **Ready to Submit**, không "Missing Metadata" / "Developer Action Needed"; có giá cho storefront đang thử; nhóm có tên hiển thị; yearly có intro offer 2 tuần với lịch hợp lệ. | "Prepare for Submission" là trạng thái của **phiên bản app**, không phải của sản phẩm — xem cột Status của từng sản phẩm. Lifetime là Non-Consumable, nằm ở In-App Purchases, không trong nhóm đăng ký. |
| 4 | **Tài khoản Sandbox** chưa đúng | Users and Access → Sandbox → Test Accounts: quốc gia/vùng **United States** (vì chỉ bán ở Mỹ). Trên iPhone đăng nhập ở mục Tài khoản Sandbox (Cài đặt → App Store, hoặc Cài đặt → Nhà phát triển tuỳ bản iOS). | Tài khoản Sandbox dùng cho bản cài từ Xcode; bản TestFlight dùng tài khoản thật (mục 1). Đổi quốc gia: tạo tài khoản Sandbox mới hoặc sửa ở trang Test Accounts. |
| 5 | **RevenueCat** chưa khớp | Dashboard → Product catalog: 3 sản phẩm đúng mã `com.kmd.goodfooting.pro.*`, gắn vào entitlement `pro`; offering `default` là **Current**, có `$rc_annual`, `$rc_monthly`, `$rc_lifetime`. App App Store đúng bundle `com.kmd.goodfooting`, khoá In-App Purchase "Valid credentials". Customers → lần mua thử (mã ẩn danh `$RCAnonymousID…`). | Repo ghi các mục này đã làm 09/10/2026. RevenueCat không tạo ra hộp thoại này; nếu entitlement thiếu sản phẩm thì Apple vẫn mua được nhưng app không bật Pro (app nay giữ paywall và nhắc "chạm Khôi phục"). |
| 6 | **Chưa lan truyền** sau khi sửa | Sau khi đổi Availability, giá hoặc trạng thái: chờ vài giờ, xoá app, cài lại bản TestFlight, thử lại. | Apple không hứa thời gian cụ thể. |
| 7 | Gói đăng ký đầu tiên chưa "Add for Review" | Repo ghi việc này còn chờ (nộp cùng bản 1.0). | Cần cho bản phát hành; thường không chặn mua thử Sandbox/TestFlight. Làm khi nộp. |

## Đọc mã lỗi trong nhật ký
Mac → Console → chọn iPhone → lọc `subsystem:com.kmd.goodfooting category:store`, rồi bấm mua. Dòng dạng `Purchase of com.kmd.goodfooting.pro.yearly failed: RevenueCat 5 PRODUCT_NOT_AVAILABLE_FOR_PURCHASE, root …`:
- `5` — App Store không bán gói này cho tài khoản/lúc này → mục 1, 3, 6.
- `2` — lỗi App Store chung (`storeProblemError`) → thử lại sau, rồi mục 2, 3.
- `10` / `35` — mạng.
- Dòng "finished but the pro entitlement is not active" → mục 5.
Nhật ký chỉ ghi mã lỗi và mã sản phẩm, không có thông tin người dùng.
