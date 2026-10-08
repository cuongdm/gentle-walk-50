# Good Footing 1.0 — checklist release (task 9.4)
_Khung 29/09/2026. Người chịu trách nhiệm: **Chủ app** (App Store Connect, tài khoản, pháp lý) · **Claude** (code, kiểm tra tự động). Đánh dấu khi xong, ghi ngày._

## 1. In-App Purchases (App Store Connect → Monetization)
- [ ] **Chủ app** — Tạo nhóm subscription "Good Footing Pro" (một nhóm, 3.1.2(b)).
- [ ] **Chủ app** — `com.kmd.goodfooting.pro.yearly`: 1 năm, level 1, intro offer **Free trial 2 weeks**, giá **49,99 USD** (chốt 09/10/2026; file `.storekit` đã theo giá này).
- [ ] **Chủ app** — `com.kmd.goodfooting.pro.monthly`: 1 tháng, level 1 (đổi qua lại với yearly là crossgrade), giá **9,99 USD**.
- [ ] **Chủ app** — `com.kmd.goodfooting.pro.lifetime`: non-consumable, giá **99,99 USD**.
- [ ] **Chủ app** — RevenueCat (từ 09/10/2026): làm theo `docs/release/1.0/revenuecat-setup.md` (khoá In-App Purchase tải lên RevenueCat, entitlement `pro`, offering `default`), rồi đặt public SDK key vào `iOS/Config/Local.xcconfig`: `REVENUECAT_PUBLIC_KEY = appl_…` (mẫu ở `Local.xcconfig.example`). Thiếu khoá: app chạy ở bản miễn phí, paywall báo "Plans aren't available right now", cổng phát hành đỏ.
- [ ] **Chủ app** — Tên hiển thị, mô tả, ảnh review cho từng IAP; gắn cả 3 IAP vào bản build nộp.
- [ ] **Claude** — `StoreServiceTests` (lớp mua giả, không mạng), `StoreConfigTests` (file `App/GentleWalk.storekit`: 3 sản phẩm, giá, trial 2 tuần) và core `CustomerRulesTests` xanh.
- [ ] **Chủ app** — Mua thử trên iPhone thật bằng tài khoản Sandbox (năm có trial, tháng, trả một lần, Restore); xem giao dịch hiện trong RevenueCat (bật View Sandbox Data).

## 2. Age rating (câu trả lời, App Store Connect tự tính bậc — verify)
| Câu hỏi | Trả lời |
|---|---|
| Bạo lực (hoạt hình, thực tế) | None |
| Nội dung tình dục, khoả thân | None |
| Ngôn ngữ thô tục | None |
| Cờ bạc, cá cược | None |
| Rượu, thuốc lá, chất kích thích | None |
| Nội dung người dùng tạo, chat, mạng xã hội | None / No |
| Thông tin y tế hoặc điều trị | None (app ghi rõ "It isn't medical advice") |
| Chủ đề sức khoẻ, tập luyện | Yes |
| Truy cập web không giới hạn | No |
- [ ] **Chủ app** — Điền và xác nhận bậc tuổi ASC tính ra.

## 3. App Privacy (nhãn quyền riêng tư)
Từ 09/10/2026 app có SDK RevenueCat nên **không còn chọn "Data Not Collected"**. Theo hướng dẫn của RevenueCat (revenuecat.com/docs → Apple App Privacy, đọc 09/10/2026):

| Loại dữ liệu (ASC) | Khai? | Gắn với danh tính | Dùng để theo dõi | Mục đích |
|---|---|---|---|---|
| Purchases → **Purchase History** | **Có** (RevenueCat ghi "Required") | **Không**: app dùng mã ẩn danh của RevenueCat, không đăng nhập, không email | **Không** | **App Functionality** (xác nhận giao dịch, quyền Pro) + **Analytics** (bảng số liệu RevenueCat) |
| Identifiers → User ID | Không (RevenueCat: chỉ khi dùng mã người dùng riêng; app chỉ dùng mã ẩn danh) | — | — | — |
| Identifiers → Device ID | Không theo RevenueCat (chỉ khi tích hợp dùng IDFA; app không dùng, đã tắt thu định danh tự động) — **xem lưu ý dưới** | — | — | — |
| Diagnostics | Không (RevenueCat: "does not collect device diagnostic information") | — | — | — |
| Usage Data, Location, Contact Info, Health & Fitness | Không (không SDK analytics; RevenueCat chỉ lấy locale và tiền tệ; dữ liệu sức khoẻ không rời máy) | — | — | — |

- [ ] **Chủ app** — Điền nhãn như bảng trên trong App Store Connect → App Privacy; verify lại với trang RevenueCat và hướng dẫn của Apple lúc nộp.
- [ ] **Chủ app (cần quyết)** — SDK RevenueCat gửi IDFV (mã Apple cấp cho các app cùng nhà phát triển) trong header `X-Apple-Device-Identifier` của mọi yêu cầu, và máy chủ thấy địa chỉ IP. RevenueCat không yêu cầu khai Device ID cho trường hợp này; nếu muốn thận trọng, khai thêm **Identifiers → Device ID**, không gắn danh tính, không theo dõi, App Functionality.
- [ ] **Chủ app** — HealthKit, vị trí, chuyển động vẫn chỉ xử lý trên máy; không có gì liên quan sức khoẻ gửi tới RevenueCat.
- [ ] **Chủ app** — Privacy Policy URL (task 9.1): đăng `site/privacy.html` (mặc định GitHub Pages), điền `[date]` và `[support email]` trước khi đăng.
- [ ] **Claude** — `PrivacyInfo.xcprivacy`: tracking false, không domain, UserDefaults CA92.1 (task 1.10); từ 09/10/2026 khai Purchase History (không gắn danh tính, không theo dõi, App Functionality + Analytics), test `StoreConfigTests.privacyManifestDeclaresPurchaseHistoryOnly`. SDK RevenueCat 5.94.0 kèm manifest riêng (Purchase History, App Functionality; UserDefaults CA92.1).
- [ ] **Claude** — Chữ Privacy trong app (Me, paywall) và `site/privacy.html` nói rõ RevenueCat: lịch sử mua với mã ngẫu nhiên, chi tiết kỹ thuật, không gì về sức khoẻ; bản Việt đủ.

## 4. Điều khoản
- [ ] **Chủ app** — Terms of Use: đang dùng EULA chuẩn của Apple (link trên paywall và Me). Nếu dùng Terms riêng: thêm `site/terms.html` và đổi `LegalLinks.termsOfUse`.
- [ ] **Chủ app** — Điền EULA link vào mô tả app hoặc trường License Agreement trong ASC.

## 5. Review notes (dán vào App Review Information)
> Good Footing needs no account and works offline. To see the paywall, finish the short onboarding (about 2 minutes) or tap any "Pro" item.
> Background audio: the app plays continuous spoken guidance, bells and optional music during a workout so the user can follow with the screen locked. It never plays silent audio.
> Background location: used only during an outdoor walk the user starts after choosing "Use my location", to measure distance and draw the route. It is switched off when the walk ends. Indoor sessions never use location.
> HealthKit: step count is read for the Progress screen and, on days the user has already walked much more than their own usual, to suggest a gentle stretch instead; nothing from Apple Health is stored by the app. Workouts are written after each session. Permission is asked after the first workout, not at launch.
> Paywall: the first view shows the yearly plan with its trial timeline; "See other plans" opens the monthly plan and the one-time purchase on the same screen. Restore, Terms of Use (Apple standard EULA), Privacy Policy, the billed price and the renewal terms are visible in both views, and "Maybe later" closes it.
> Personalisation stays on the device: the plan adapts to the user's own answers (onboarding goal and body limits, "How did that feel?", an optional weekly check-in, "This hurts"), with no account, server or analytics.
> How it differs from a timer app (4.3(b)): voice-led interval walks at three levels, seated chair moves with looping demonstration clips, stretches held per intensity, landmark journeys unlocked by active minutes, a weekly plan that adapts to feedback and pain reports.
> The 2-week check is a self-counted 30-second chair stand, compared only with the user's own earlier results. It is general fitness, not a medical test, and shows no norms or risk levels. Results stay on the device.
> Every permission is optional. Each screen before a system dialog has one button that opens the dialog; "Don't Allow" there leaves the app fully usable, and reminders, Apple Health and location can be turned on later in Me. Reminders and Apple Health are asked one per screen after the first workout; location only after the user picks "Map and distance" for an outdoor walk.
> The coach preview on "Your plan" plays two bundled lines of the first session ("Hear your coach · 10 seconds"); it is the real recording, voice only, and stops when the screen closes.
- [ ] **Chủ app** — Dán review notes; thêm số điện thoại/email liên hệ.

## 6. Build và kiểm tra cuối
- [ ] **Claude** — `CORE`, `APP` xanh; build Release sạch; lint 0; catalog en đủ (task 9.7).
- [ ] **Claude** — `TEST_RUNNER_RELEASE_CHECK=1 … ReleaseContentTests` xanh (chỉ xanh khi đủ asset thật — task 9.2).
- [ ] **Chủ app** — Kiểm trên iPhone thật theo `docs/owner-todo-after-mvp.md` mục 1.
- [ ] **Chủ app** — App icon thật (icon tạm dùng SF Symbol, **không được** dùng trong icon nộp store).
- [ ] **Chủ app** — Tên app trên store: Name "Good Footing: Gentle Workouts", Subtitle "Chair Yoga, Walks & Stretches" (chốt 07/10/2026; trước khi đặt: luật sư nhãn hiệu, giữ tên trên App Store Connect).
- [ ] **Chủ app** — Ảnh chụp store theo `docs/release/1.0/screenshots.md`.
- [ ] **Chủ app** — Archive, upload, TestFlight nội bộ, rồi Submit (chủ app tự bấm).
