# Good Footing 1.0 — checklist release (task 9.4)
_Khung 29/09/2026. Người chịu trách nhiệm: **Chủ app** (App Store Connect, tài khoản, pháp lý) · **Claude** (code, kiểm tra tự động). Đánh dấu khi xong, ghi ngày._

## 1. In-App Purchases (App Store Connect → Monetization)
- [ ] **Chủ app** — Tạo nhóm subscription "Good Footing Pro" (một nhóm, 3.1.2(b)).
- [ ] **Chủ app** — `com.kmd.gentlewalk.pro.yearly`: 1 năm, level 1, intro offer **Free trial 2 weeks**; giá thật (file .storekit đang là giá test).
- [ ] **Chủ app** — `com.kmd.gentlewalk.pro.monthly`: 1 tháng, level 1 (đổi qua lại với yearly là crossgrade).
- [ ] **Chủ app** — `com.kmd.gentlewalk.pro.lifetime`: non-consumable.
- [ ] **Chủ app** — Tên hiển thị, mô tả, ảnh review cho từng IAP; gắn cả 3 IAP vào bản build nộp.
- [ ] **Claude** — `StoreServiceTests` xanh với file `App/GentleWalk.storekit` (9 test, 29/09/2026).

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
- [ ] **Chủ app** — Chọn **Data Not Collected**: app không gửi dữ liệu nào ra khỏi máy (không server, không analytics, không SDK bên thứ ba). HealthKit, vị trí, chuyển động chỉ xử lý trên máy — verify cách trả lời với hướng dẫn hiện hành của Apple.
- [ ] **Chủ app** — Privacy Policy URL (task 9.1): đăng `site/privacy.html` (mặc định GitHub Pages), điền `[date]` và `[support email]` trước khi đăng.
- [ ] **Claude** — `PrivacyInfo.xcprivacy`: tracking false, không domain, UserDefaults CA92.1 (task 1.10).

## 4. Điều khoản
- [ ] **Chủ app** — Terms of Use: đang dùng EULA chuẩn của Apple (link trên paywall và Me). Nếu dùng Terms riêng: thêm `site/terms.html` và đổi `LegalLinks.termsOfUse`.
- [ ] **Chủ app** — Điền EULA link vào mô tả app hoặc trường License Agreement trong ASC.

## 5. Review notes (dán vào App Review Information)
> Good Footing needs no account and works offline. To see the paywall, finish the short onboarding (about 2 minutes) or tap any "Pro" item.
> Background audio: the app plays continuous spoken guidance, bells and optional music during a workout so the user can follow with the screen locked. It never plays silent audio.
> Background location: used only during an outdoor walk the user starts after choosing "Use my location", to measure distance and draw the route. It is switched off when the walk ends. Indoor sessions never use location.
> HealthKit: step count is read for the Progress screen; workouts are written after each session. Permission is asked after the first workout, not at launch.
> How it differs from a timer app (4.3(b)): voice-led interval walks at three levels, seated chair moves with looping demonstration clips, stretches held per intensity, landmark journeys unlocked by active minutes, a weekly plan that adapts to feedback and pain reports.
> The 2-week check is a self-counted 30-second chair stand, compared only with the user's own earlier results. It is general fitness, not a medical test, and shows no norms or risk levels. Results stay on the device.
- [ ] **Chủ app** — Dán review notes; thêm số điện thoại/email liên hệ.

## 6. Build và kiểm tra cuối
- [ ] **Claude** — `CORE`, `APP` xanh; build Release sạch; lint 0; catalog en đủ (task 9.7).
- [ ] **Claude** — `TEST_RUNNER_RELEASE_CHECK=1 … ReleaseContentTests` xanh (chỉ xanh khi đủ asset thật — task 9.2).
- [ ] **Chủ app** — Kiểm trên iPhone thật theo `docs/owner-todo-after-mvp.md` mục 1.
- [ ] **Chủ app** — App icon thật (icon tạm dùng SF Symbol, **không được** dùng trong icon nộp store).
- [ ] **Chủ app** — Tên app trên store: Name "Good Footing: Gentle Workouts", Subtitle "Chair Yoga, Walks & Stretches" (chốt 07/10/2026; trước khi đặt: luật sư nhãn hiệu, giữ tên trên App Store Connect).
- [ ] **Chủ app** — Ảnh chụp store theo `docs/release/1.0/screenshots.md`.
- [ ] **Chủ app** — Archive, upload, TestFlight nội bộ, rồi Submit (chủ app tự bấm).
