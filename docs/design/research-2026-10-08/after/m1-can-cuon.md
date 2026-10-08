# Bảng "cần cuộn" trước / sau milestone 1 — 08/10/2026

_Task 1.18 của docs/plans/2026-10-08-ui-onboarding-personalization.md. "Trước": báo cáo `ui-ux-va-onboarding.md` §1 (iPhone 11 chụp thật, SE tính). "Sau": chụp thật bằng `-ScreenshotMode`, cỡ chữ mặc định, sáng, bản build cuối M1, trên **iPhone SE 3** (375×667, máy tạm iOS 27), **iPhone 11** (414×896, máy tạm) và **iPhone 17 Pro Max**. Ảnh: `docs/design/research-2026-10-08/after-m1/{se3,i11,promax}/<state>.png`; bản Việt (8 màn) `after-m1/se3-vi/`._

Ký hiệu: ✓ phải cuộn (nội dung dưới mép) · ✗ vừa màn · ≈ hành động chính và mọi lựa chọn trong màn, chỉ phần phụ dưới mép (hoặc vùng cuộn giữa của player). Danh sách/feed được phép ✓ (cột "Loại").

| # | Trạng thái | Loại | Trước 11 / SE | Sau SE | Sau 11 | Sau Pro Max | Ghi chú |
|---|---|---|---|---|---|---|---|
| 1 | onboarding-welcome | màn | ✗ / ✓ | ✗ | ✗ | ✗ | SE: tranh 207 pt, "Let's begin" + Restore trong màn |
| 2 | onboarding-goal | màn | ✓ / ✓ | ✓ | ✓ | ✗ | **Còn lại cho M2 (2.4–2.5)**: Continue dưới mép trên SE/11 |
| 3 | onboarding-barriers | màn | ✓ / ✓ | ✓ | ✓ | ✗ | **M2 (2.6)**: Continue dưới mép trên SE/11 |
| 4 | onboarding-understanding-joints | màn | ✗ / ≈ | ✗ | ✗ | ✗ | Continue ghim; màn bị bỏ ở M2 |
| 5 | onboarding-name | màn | ✗ / ✗ | ✗ | ✗ | ✗ | bàn phím che, Return = Continue |
| 6 | onboarding-strength | màn | ✗ / ✗ | ✗ | ✗ | ✗ |  |
| 7 | onboarding-body | màn | ✓ / ✓ | ✓ | ✓ | ≈ | **M2 (2.9–2.10)**: chip cuối dưới thanh ghim (tách 2 màn) |
| 8 | onboarding-plan | màn | ✓ / ✓ | ✓ | ✓ | ✓ | "See my options" ghim; **M2 (2.11)** gọn lại |
| 9 | paywall-eligible | màn | ✓ / ✓ | ≈ | ✗ | ✗ | SE: 3 gói + nút + điều khoản + Maybe later · Restore · Terms · Privacy trong màn; chỉ 2 dòng free/cancel dưới thanh ghim (dựng lại ở 2.12) |
| 10 | permissions-reminder | màn | ✓ / ✓ | ✗ | ✗ | ✗ | thay `permissions` (task 1.6) |
| 11 | permissions-health | màn | ✓ / ✓ | ✗ | ✗ | ✗ | thay `permissions` (task 1.6) |
| 12 | phone-placement | màn | ✗ / ✓ | ✗ | ✗ | ✗ | 3 thẻ + Continue |
| 13 | ready-first-walk | màn | ✗ / ≈ | ✗ | ✗ | ✗ | khoảng cách gọn lại sau nút 64 pt |
| 14 | preview-chair | danh sách | ✓ / ✓ | ✓ | ✗ | ✗ | danh sách; Start ghim; tranh bỏ khi > 4 phần |
| 15 | preview-indoor | danh sách | ✓ / ✓ | ✓ | ✓ | ✓ | danh sách; Start ghim |
| 16 | preview-steady | danh sách | ✓ / ✓ | ✓ | ✓ | ✓ | danh sách; Start ghim |
| 17 | countdown | màn | ✗ / ≈ | ✗ | ✗ | ✗ |  |
| 18 | walk-player | màn | ✗ / ≈ | ✗ | ✗ | ✗ | "0:24" |
| 19 | chair-player | màn | ✗ / ≈ | ≈ | ✗ | ✗ | SE: hàng Easier/Harder/Tips trong vùng cuộn giữa |
| 20 | chair-counted | màn | ✗ / ≈ | ≈ | ✗ | ✗ | như trên |
| 21 | stretch-player | màn | ✗ / ≈ | ≈ | ✗ | ✗ | như trên |
| 22 | steady-set | màn | ✗ / ≈ | ≈ | ✗ | ✗ | SE: chip "Two hands on the chair" nửa dưới mép vùng cuộn giữa |
| 23 | balance-back-walk | màn | ✗ / ≈ | ≈ | ✗ | ✗ | SE: hàng lựa chọn trong vùng cuộn giữa |
| 24 | break | màn | ✗ / ✗ | ✗ | ✗ | ✗ |  |
| 25 | this-hurts | màn | ✗ / ✗ | ✗ | ✗ | ✗ | khoảng 20 → 12 để ghi chú cấp cứu trong màn |
| 26 | complete-first-walk | màn | ✓ / ✓ | ≈ | ≈ | ≈ | Let's do it + Later trên Done ghim; ghi chú/Share dưới |
| 27 | complete-check-invite | màn | ✓ / ✓ | ≈ | ≈ | ≈ | như trên |
| 28 | complete | danh sách | ✓ / ✓ | ✓ | ✓ | ≈ | postcard dưới; Done ghim (chấp nhận) |
| 29 | today | danh sách | ✓ / ✓ | ✓ | ✓ | ✓ | feed; Start SE ≈ 60 % chiều cao (mục tiêu 55 %) |
| 30 | today-program | danh sách | ✓ / ✓ | ✓ | ✓ | ✓ | feed |
| 31 | today-check-due | danh sách | ✓ / ✓ | ✓ | ✓ | ✓ | feed; một nút xanh |
| 32 | today-done | danh sách | ✓ / ✓ | ✓ | ✓ | ✓ | feed |
| 33 | today-new | danh sách | ✓ / ✓ | ✓ | ✓ | ✓ | feed |
| 34 | today-rest | danh sách | ✓ / ✓ | ✓ | ✓ | ✓ | feed |
| 35 | today-swap | màn | ✗ / ✗ | ✗ | ✗ | ✗ |  |
| 36 | journey | danh sách | ✓ / ✓ | ✓ | ✓ | ✓ | danh sách điểm dừng |
| 37 | journeys | danh sách | ✓ / ✓ | ✓ | ✓ | ✓ | danh sách |
| 38 | progress | danh sách | ✓ / ✓ | ✓ | ✓ | ✓ | feed; lịch vừa 7 cột |
| 39 | progress-checks | danh sách | ✓ / ✓ | ✓ | ✓ | ✓ | feed |
| 40 | program | danh sách | ✓ / ✓ | ✓ | ✓ | ✓ | danh sách 4 giai đoạn |
| 41 | program-finished | màn | ✗ / ✓ | ✗ | ✗ | ✗ | 2 nút + link + disclaimer |
| 42 | selfcheck-intro | màn | ✓ / ✓ | ✗ | ✗ | ✗ | 3 bước + 4 gạch trên "I'm ready" |
| 43 | selfcheck-timer | màn | ✗ / ✗ | ✗ | ✗ | ✗ |  |
| 44 | selfcheck-count | màn | ✗ / ✗ | ✗ | ✗ | ✗ |  |
| 45 | me | danh sách | ✓ / ✓ | ✓ | ✓ | ✓ | danh sách cài đặt |
| 46 | me-notifications | màn | ✗ / ✗ | ✗ | ✗ | ✗ |  |
| 47 | sound-sheet | màn | ✗ / ✗ | ✗ | ✗ | ✗ | − / + thay slider |
| 48 | outdoor-measure-choice | màn | ✗ / ✗ | ✗ | ✗ | ✗ | thay `outdoor-location-ask` (task 1.17) |
| 49 | outdoor-location-prompt | màn | ✗ / ✗ | ✗ | ✗ | ✗ | một nút Continue |
| 50 | outdoor-prep | màn | ✗ / ✓ | ✗ | ✗ | ✗ | Continue ghim |
| 51 | reminder-offer | màn | ✗ / ✓ | ✗ | ✗ | ✗ |  |
| 52 | all-sessions | danh sách | ✓ / ✓ | ✓ | ✓ | ✓ | lưới 2 cột, không cuộn ngang |

## Tổng
- Trước: phải cuộn 21/50 trên iPhone 11, 31/50 trên SE (báo cáo).
- Sau (52 trạng thái, `permissions` và `outdoor-location-ask` đã tách thành 2 màn mỗi cái): phải cuộn **21** trên SE, **20** trên iPhone 11, **16** trên Pro Max; trong đó danh sách/feed được phép: 17 (SE).
- Màn không phải danh sách còn ✓ trên SE: onboarding-goal, onboarding-barriers, onboarding-body, onboarding-plan — đều thuộc onboarding cũ, được làm lại trên khung `OnboardingStepScaffold` ở milestone 2 (2.4–2.11); onboarding-plan có nút ghim nên hành động chính vẫn thấy.
- ≈ trên SE: paywall-eligible (2 dòng free/cancel dưới thanh ghim; paywall dựng lại ở 2.12), Complete buổi đầu (thẻ mời và Done trong màn), các player ghế/giãn cơ/thăng bằng (hàng Easier/Harder/Tips trong vùng cuộn giữa video và bong bóng HLV).
- Không màn nào có "…" cắt chữ hay cuộn ngang ở cỡ mặc định (đã sửa "4 o…" ở bộ đếm ghế). Ở XXL: paywall, Reminder offer, Permissions từng tràn ngang — đã sửa (1.5, 1.13).
