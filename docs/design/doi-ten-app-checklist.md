# Checklist đổi tên app khi chốt tên store

_06/10/2026 · Rà toàn repo: `docs/`, `site/`, `app-context.md`, `CLAUDE.md`, `README.md`, `iOS/` (Swift, `Localizable.xcstrings`, `InfoPlist.xcstrings`, `Info.plist`, `project.yml`, `.storekit`, `Resources/Content/`), `tools/`, `assets/`. Tìm: "Gentle Walk", "GentleWalk", "Gentle Walk Pro", "GENTLE WALK", "gentlewalk", "gentle-walk". Số dòng tại 06/10/2026; code đang được sửa song song nên số dòng có thể lệch vài dòng._

## Tình trạng tên

> **07/10/2026: đã đổi sang Good Footing** (chủ app chốt trước test người dùng và luật sư). Đã làm bước 2–5, 7 (phần repo), 8, 10 ở mục 6; tên gom ở `iOS/App/Design/AppBrand.swift` (câu hỏi mở 2: có). Còn, cần Mac hoặc chủ app: `xcodegen generate` + build + test + xem bằng mắt (bước 11), App Store Connect (bước 7), ảnh store, icon, video (bước 9). Khẩu hiệu mới thay câu Welcome cũ (mục 5 không còn đúng cho câu này). Bảng dưới là trạng thái trước khi đổi, giữ để tra.

- **Tên làm việc:** "Gentle Walk" / "Gentle Walk 50+". Chưa phải tên store.
- **Hai tên đang test với người dùng (04/10/2026):** **Good Footing** và **Kind Pace**.
- **Mẫu tên store:** `<Tên>: Gentle Workouts` → "Good Footing: Gentle Workouts" (29 ký tự) · "Kind Pace: Gentle Workouts" (26). Giới hạn 30.
- **Phụ đề chung:** "Chair Yoga, Walks & Stretches" (29 ký tự, giới hạn 30).
- **Tên dưới icon (`CFBundleDisplayName`, nên ≤12 ký tự):** "Good Footing" (12, vừa sát) · "Kind Pace" (9).
- **Gói trả phí:** "Good Footing Pro" (16) · "Kind Pace Pro" (13).
- Nguồn: [docs/research/2026-10-04-tom-tat-thi-truong.md](../research/2026-10-04-tom-tat-thi-truong.md) mục 6; [docs/research/2026-10-03-ten-app-moi.md](../research/2026-10-03-ten-app-moi.md) mục 5.

## Đếm theo loại

| Loại | Số lần xuất hiện | Số file | Khi chốt tên |
|---|---|---|---|
| Chữ người dùng thấy trong app | **139** (77 trong `iOS/`, 62 trong `docs/i18n/` là bản nguồn và bản dịch của String Catalog) | 25 | **Đổi hết** |
| Metadata store | **12** trong repo (`.storekit` 4, `site/privacy.html` 6, checklist release 2) + các ô trên App Store Connect | 3 | **Đổi hết** |
| Tên làm việc trong tài liệu | **130** | 39 | Đổi ở tài liệu đang dùng; giữ ở báo cáo lịch sử |
| Mã nội bộ không đổi | **237** + 172 dòng `import GentleWalkCore` / `@testable import GentleWalk` | 45 (+ mọi file Swift có import) | **Không đổi** |
| Không phải tên app ("Gentle walk" là tên buổi đi bộ) | 35 | 18 | Không đổi |

Chi tiết đáng chú ý trong nhóm "chữ người dùng thấy":
- 14 khoá `Localizable.xcstrings` có tên app trong câu tiếng Anh, cộng 3 khoá chỉ bản tiếng Việt có tên (tiếng Anh dùng "we").
- 6 khoá `InfoPlist.xcstrings` × 2 ngôn ngữ (tên dưới icon, `CFBundleName`, 4 câu xin quyền).
- 6 chỗ **nằm ngoài String Catalog** (chữ cứng trong Swift): dễ sót nhất.
- Lời HLV, thông báo, hành trình, bưu thiếp (`iOS/App/Resources/Content/*.json`, `assets/voice/`): **0 câu** nhắc tên app → không phải thu giọng lại.

## 1. Chữ người dùng thấy trong app

### 1a. Tên dưới icon và câu xin quyền (Info.plist)

| File | Dòng / khoá | Chữ hiện tại | Loại | Khi chốt tên |
|---|---|---|---|---|
| `iOS/project.yml` | 53 `CFBundleDisplayName` | Gentle Walk | chữ người dùng thấy | Đổi thành tên ngắn (≤12 ký tự). Đây là nguồn: XcodeGen ghi đè `Info.plist` |
| `iOS/project.yml` | 55–58 `NSHealthShare…`, `NSHealthUpdate…`, `NSMotion…`, `NSLocationWhenInUse…` | "Gentle Walk reads… / saves… / uses motion… / uses your location…" | chữ người dùng thấy | Thay "Gentle Walk" bằng tên ngắn; giữ nguyên phần còn lại |
| `iOS/App/Info.plist` | 8, 24, 26, 28, 30 | như trên | chữ người dùng thấy | Không sửa tay: chạy `xcodegen generate` trong `iOS/` |
| `iOS/App/InfoPlist.xcstrings` | `CFBundleDisplayName` (en 11, vi 17) | Gentle Walk | chữ người dùng thấy | Tên ngắn, cả en và vi (tên riêng, không dịch) |
| `iOS/App/InfoPlist.xcstrings` | `CFBundleName` (en 29, vi 35) | GentleWalk | chữ người dùng thấy (dự phòng khi thiếu display name) | Đổi giá trị thành tên ngắn (≤15 ký tự). **Không** đổi `PRODUCT_NAME` |
| `iOS/App/InfoPlist.xcstrings` | 4 khoá `NS…UsageDescription` (en 47, 65, 83, 101; vi 53, 71, 89, 107) | "Gentle Walk reads…" / "Gentle Walk đọc…" | chữ người dùng thấy | Đổi tên trong cả 8 câu |
| `docs/i18n/source/infoplist.json`, `docs/i18n/vi/infoplist.json` | 2–7 | như trên | bản nguồn / bản dịch | Đổi cùng lúc để lần chạy `apply_catalog.py` sau không ghi lại tên cũ |

### 1b. Chữ cứng trong Swift, ngoài String Catalog (dễ sót)

| File | Dòng | Chữ hiện tại | Loại | Khi chốt tên |
|---|---|---|---|---|
| `iOS/App/Features/Onboarding/WelcomeView.swift` | 15 | `Text(verbatim: "GENTLE WALK")` | chữ người dùng thấy (màn đầu tiên) | "GOOD FOOTING" hoặc "KIND PACE"; xem lại độ rộng chữ hoa ở cỡ chữ lớn |
| `iOS/App/Features/Onboarding/WelcomeView.swift` | 18 | `.accessibilityLabel(Text(verbatim: "Gentle Walk"))` | VoiceOver đọc | Tên ngắn |
| `iOS/App/Features/Workout/Complete/ShareCardRenderer.swift` | 42 | `Text(verbatim: "Gentle Walk")` | in lên ảnh chia sẻ (ra ngoài máy) | Tên ngắn |
| `iOS/App/Services/Audio/NowPlayingController.swift` | 37 | `MPMediaItemPropertyArtist: "Gentle Walk"` | màn khoá, Control Center | Tên ngắn |
| `iOS/App/Services/Content/AppLanguage.swift` | 25 (en), 26 (vi) | "close Gentle Walk and open it again… swipe Gentle Walk up" · "đóng hẳn Gentle Walk… vuốt Gentle Walk lên" | chữ người dùng thấy, 2 ngôn ngữ, 4 lần | Đổi cả 4 chỗ |

### 1c. Khoá String Catalog (`iOS/App/Localizable.xcstrings`)

Khoá là câu tiếng Anh. Sửa chữ trong Swift sẽ tạo **khoá mới**; bản Việt phải thêm lại cho khoá mới, khoá cũ thành "stale" và cần xoá.

| Swift (`iOS/App/Features/`…, file:dòng) | Khoá hiện tại (dòng trong xcstrings) | Bản Việt hiện tại | Khi chốt tên |
|---|---|---|---|
| `Paywall/PaywallModel.swift:66` | "Gentle Walk Pro: free for 14 days" (1962) | Gentle Walk Pro: miễn phí 14 ngày | "<Tên> Pro: free for 14 days" — tiêu đề paywall |
| `Paywall/PaywallModel.swift:66`, `Me/MeSections.swift:76` | "Gentle Walk Pro" (1938) | Gentle Walk Pro | "<Tên> Pro" — phải khớp tên nhóm subscription trên ASC |
| `Me/MeSections.swift:74` | "Gentle Walk Pro · renews %@" (1950) | Gentle Walk Pro · gia hạn %@ | "<Tên> Pro · renews %@" |
| `Onboarding/PlanReadyView.swift:123` | "With Gentle Walk Pro, your week mixes walks, chair moves and stretches." (6624) | Với Gentle Walk Pro, tuần của bạn… | Đổi tên |
| `Progress/SessionHistoryViews.swift:32` | "See all sessions, with Gentle Walk Pro" (4831) | Xem tất cả buổi tập, với Gentle Walk Pro | Đổi tên (nhãn VoiceOver) |
| `Journey/JourneyMapView.swift:115` | "%@, part of Gentle Walk Pro" (266) | %@, thuộc Gentle Walk Pro | Đổi tên (nhãn VoiceOver) |
| `Journey/JourneyRouteList.swift:143` | "With Gentle Walk Pro · at %@" (6613) | Với Gentle Walk Pro · ở mốc %@ | Đổi tên |
| `Journey/JourneyView.swift:72` | "You walked the free leg. The rest of this route comes with Gentle Walk Pro, and your distance keeps counting." (6869) | …có trong Gentle Walk Pro… | Đổi tên |
| `Journey/JourneyListView.swift:147` | "I walked to %@ with Gentle Walk." (2593) | Tôi đã đi bộ đến %@ cùng Gentle Walk. | Đổi tên — câu chia sẻ ra ngoài |
| `Workout/Complete/ShareCardRenderer.swift:15` | "Gentle Walk" (1926) | Gentle Walk | Tên ngắn (tiêu đề xem trước khi chia sẻ) |
| `Me/CancelGuideView.swift:18` | "Choose Gentle Walk" (1004) | Chọn Gentle Walk | Phải khớp tên hiện trong Cài đặt → Đăng ký (thường là tên store) |
| `Me/MeSections.swift:359` | "Location is off for Gentle Walk on this iPhone." (3147) | Vị trí đang tắt cho Gentle Walk trên iPhone này. | Tên ngắn (khớp tên trong Cài đặt iOS) |
| `Me/MeSections.swift:393` | "Gentle Walk is for general fitness. It isn't medical advice." (1973) | Gentle Walk dành cho việc rèn luyện… | Đổi tên |
| `Paywall/PaywallLegalFooter.swift:87` | "Gentle Walk keeps everything on this phone." (1985) | Gentle Walk lưu mọi thứ trên điện thoại này. | Đổi tên |
| (khoá tiếng Anh không có tên) | "If you connect Apple Health, we read…" (2670, bản vi dòng 2677) | Nếu bạn kết nối Apple Health, Gentle Walk đọc… (2 lần) | Chỉ sửa bản Việt |
| (khoá tiếng Anh không có tên) | "Purchases are handled by Apple. We never see your payment details." (4414, vi 4421) | …Gentle Walk không bao giờ thấy… | Chỉ sửa bản Việt |
| (khoá tiếng Anh không có tên) | "We don't have accounts, servers, ads or tracking…" (6314, vi 6321) | Gentle Walk không có tài khoản… | Chỉ sửa bản Việt |

Bản nguồn và bản dịch đi kèm (đổi cùng lúc): `docs/i18n/source/ui.json` (14 khoá: dòng 127, 679, 756, 856, 902, 1053, 1060, 1131, 2302, 2436, 2444, 2732, 3185, 3299) · `docs/i18n/vi/ui-1.json` (dòng 23, 90, 101, 115, 121, 142, 143, 284, 285, 289, 292, 303, 304) · `docs/i18n/vi/ui-2.json` (36, 92, 108) · `docs/i18n/vi/ui-extra-3.json` (18) · `docs/i18n/vi/ui-extra-4.json` (11, 24). Hai khoá trong `ui-1.json:121` ("…your miles keep counting") và `ui-extra-4.json:11` ("…Gentle Walk doesn't ask for your weight…") đã cũ, không còn trong catalog: sửa hoặc bỏ.

## 2. Metadata store

| Nơi | Dòng / ô | Chữ hiện tại | Loại | Khi chốt tên |
|---|---|---|---|---|
| App Store Connect → App Information | Name | (chưa tạo) | metadata store | "<Tên>: Gentle Workouts" (≤30) |
| App Store Connect → App Information | Subtitle | (chưa tạo) | metadata store | "Chair Yoga, Walks & Stretches" |
| App Store Connect → Subscriptions | Tên nhóm subscription | "Gentle Walk Pro" (dự kiến, `docs/release/1.0/checklist.md:5`) | metadata store | "<Tên> Pro", mọi ngôn ngữ |
| App Store Connect → 3 sản phẩm | Display name | theo `.storekit` | metadata store | "<Tên> Pro, yearly / monthly / one payment" |
| `iOS/App/GentleWalk.storekit` | 12, 31, 48, 69 | "Gentle Walk Pro, one payment" · "Gentle Walk Pro" (nhóm) · "…, yearly" · "…, monthly" | metadata store (bản test cục bộ) | Đổi chữ cho khớp ASC; **giữ** tên file và product id |
| `docs/release/1.0/checklist.md` | 36 (App Review notes) | "Gentle Walk needs no account and works offline…" | metadata store | Đổi tên trong ghi chú cho người duyệt |
| `site/privacy.html` | 6, 18, 21, 27, 45, 50 | `<title>`, `<h1>`, 4 câu "Gentle Walk…" | metadata store (URL Privacy Policy trên ASC) | Đổi 6 chỗ; xoá ghi chú HTML dòng 17 |
| Ảnh store, video preview, icon | chú thích ảnh, chữ trên icon nếu có | — | metadata store | Làm lại với tên mới |
| Tên miền, Support URL, email | — | chưa có | metadata store | Đăng ký theo tên mới (`docs/todo.md` M5) |

## 3. Tên làm việc trong tài liệu

Báo cáo, kế hoạch đã duyệt và review là lịch sử: **giữ nguyên**. Chỉ đổi tài liệu còn dùng hằng ngày.

| File | Dòng | Số lần | Chữ mẫu | Khi chốt tên |
|---|---|---|---|---|
| `CLAUDE.md` | 1 | 1 | # Gentle Walk 50+ (tên làm việc) | Đổi dòng tiêu đề; app-context.md do chủ app sửa |
| `README.md` | 1 | 1 | # Gentle Walk 50+ (tên làm việc) | Đổi tiêu đề khi chốt (tài liệu đang dùng) |
| `app-context.md` | 1, 6, 25, 131 | 4 | # App context — Gentle Walk 50+ (tên làm việc) | Chủ app sửa: Identity → tên store đã chốt; giữ tên làm việc trong nhật ký |
| `assets/video/video-manager.html` | 6, 109 | 2 | <title>Kho video Gentle Walk</title> | Đổi tiêu đề khi chốt (tài liệu đang dùng) |
| `docs/content-plan.md` | 1 | 1 | # Kế hoạch nội dung — Gentle Walk 50+ (MVP) | Đổi tiêu đề khi chốt (tài liệu đang dùng) |
| `docs/design/gentle-walk-screen-spec.html` | 1, 103 | 2 | <title>Gentle Walk screen spec</title> | Đổi tiêu đề khi chốt (tài liệu đang dùng) |
| `docs/design/infographic-nguon-bai-tap-brief-v2.md` | 1, 47, 201, 202 | 5 | # Brief infographic v2: "Bài tập của Gentle Walk lấy từ đâu" | Đổi dòng phụ mục 2 và câu miễn trừ |
| `docs/design/infographic-nguon-bai-tap-brief.md` | 1, 43, 208, 209 | 4 | # Brief infographic: "Bài tập của Gentle Walk lấy từ đâu" | Giữ (v1, đã thay bằng v2) |
| `docs/i18n/README.md` | 1, 17 | 3 | # Đa ngôn ngữ — Gentle Walk | Đổi tiêu đề khi chốt (tài liệu đang dùng) |
| `docs/i18n/glossary-vi.md` | 1, 12, 50 | 4 | # Bảng thuật ngữ tiếng Việt — Gentle Walk | Dòng 50: "<Tên> Pro · Pro (giữ nguyên)"; dòng 12: dùng tên mới |
| `docs/idea/gentle-walk-voice.md` | 1 | 1 | # Ý tưởng: Gentle Walk 50+ (gentle-walk-voice) | Giữ nguyên (báo cáo, kế hoạch lịch sử) |
| `docs/idea/session-choice.md` | 13 | 1 | "Lặp lại, không đổi được bài" là lời chê lặp lại trong revie… | Giữ nguyên (báo cáo, kế hoạch lịch sử) |
| `docs/owner-todo-after-mvp.md` | 11, 45 | 2 | - [ ] **3.7 Màn khoá:** hiện "Gentle Walk · First walk"; bấm… | Đổi tiêu đề khi chốt (tài liệu đang dùng) |
| `docs/plans/2026-09-29-mvp.md` | 1, 50, 111, 113, 118, 220, 228, 235 … | 15 | # Gentle Walk 50+ MVP — kế hoạch 29/09/2026 (đã duyệt toàn b… | Giữ nguyên (báo cáo, kế hoạch lịch sử) |
| `docs/plans/2026-09-29-session-choice.md` | 1 | 1 | # Gentle Walk 50+ — Session choice (milestone 10) — kế hoạch… | Giữ nguyên (báo cáo, kế hoạch lịch sử) |
| `docs/release/1.0/asset-checklist.md` | 1 | 1 | # Gentle Walk 1.0 — asset thật cần có trước khi nộp (task 9.… | Đổi tiêu đề khi chốt (tài liệu đang dùng) |
| `docs/release/1.0/checklist.md` | 1, 48 | 2 | # Gentle Walk 1.0 — checklist release (task 9.4) | Đổi tiêu đề khi chốt (tài liệu đang dùng) |
| `docs/release/1.0/screenshots.md` | 1 | 1 | # Gentle Walk 1.0 — màn chụp cho store (task 9.5) | Đổi tiêu đề khi chốt (tài liệu đang dùng) |
| `docs/research/2026-09-30-competitor-4-groups.md` | 145, 196 | 2 | ## 4. Khoảng trống cơ hội cho Gentle Walk | Giữ nguyên (báo cáo, kế hoạch lịch sử) |
| `docs/research/2026-09-30-exercise-standards.md` | 1 | 1 | # Chuẩn tập luyện cho Gentle Walk 50+ — tham chiếu kỹ thuật … | Đổi tiêu đề khi chốt (tài liệu đang dùng) |
| `docs/research/2026-09-30-flow-elevenlabs-production-notes.md` | 92 | 1 | \| 'pronunciation_dictionary_locators' \| tối đa 3/lượt \| 1… | Giữ nguyên (báo cáo, kế hoạch lịch sử) |
| `docs/research/2026-10-03-kiem-tien-dinh-vi-doi-thu.md` | 45, 144, 224 | 3 | - Người dùng thật của Gentle Walk (TestFlight hoặc bản phát … | Giữ nguyên (báo cáo, kế hoạch lịch sử) |
| `docs/research/2026-10-03-ten-app-moi.md` | 5, 34, 96 | 6 | - "Gentle Walk" kéo app về thể loại đi bộ. Trong mẫu 14 app … | Giữ nguyên (báo cáo, kế hoạch lịch sử) |
| `docs/research/2026-10-03-van-de-va-chan-dung-khach-hang.md` | 47, 128, 146 | 3 | Đây đúng là ba trụ của Gentle Walk: minh bạch tiền, mọi bài … | Giữ nguyên (báo cáo, kế hoạch lịch sử) |
| `docs/research/2026-10-04-tom-tat-thi-truong.md` | 1, 3, 137, 150 | 4 | # Tóm tắt thị trường — Gentle Walk 50+ (tên làm việc) · 04/1… | Giữ (đã có ghi chú tên làm việc) |
| `docs/research/competitors-ui-reference.md` | 20, 21, 833, 835, 837, 858, 865, 870 … | 22 | 4. [So sánh với Gentle Walk 50+](#c-so-sánh-với-gentle-walk-… | Giữ nguyên (báo cáo, kế hoạch lịch sử) |
| `docs/research/mobbin-xem-nhanh-2026-10-02.md` | 83, 106 | 2 | ## Điểm chung đáng học (xếp theo độ hợp với Gentle Walk) | Giữ nguyên (báo cáo, kế hoạch lịch sử) |
| `docs/research/prototype-test-plan.md` | 1 | 1 | # Kế hoạch test prototype — Gentle Walk 50+ (một trang) | Đổi tiêu đề khi chốt (tài liệu đang dùng) |
| `docs/research/ui-redesign-uxpeak-2-video.md` | 105, 107 | 2 | ## Áp vào Gentle Walk 50+ (đề xuất, chưa làm) | Giữ nguyên (báo cáo, kế hoạch lịch sử) |
| `docs/research/ux-psychology-uxpeak-6-nguyen-tac.md` | 100, 131 | 2 | - **Không áp dụng nguyên văn cho Gentle Walk.** | Giữ nguyên (báo cáo, kế hoạch lịch sử) |
| `docs/reviews/2026-09-28-tai-lieu.md` | 1 | 1 | # Rà soát tài liệu — Gentle Walk 50+ (28/09/2026) | Giữ nguyên (báo cáo, kế hoạch lịch sử) |
| `docs/reviews/2026-09-29-tai-lieu-ke-hoach.md` | 83, 89 | 3 | M8 [Plan] [Minor] plan 5.9 · spec S08 — Trạng thái không đủ … | Giữ nguyên (báo cáo, kế hoạch lịch sử) |
| `docs/reviews/2026-09-30-de-hieu-bo-cuc.md` | 4, 23, 25, 62, 72, 88, 116, 118 … | 15 | **Bằng chứng:** 81 ảnh iPhone 17, sáng, cỡ chữ mặc định, en-… | Giữ nguyên (báo cáo, kế hoạch lịch sử) |
| `docs/reviews/2026-10-01-onboarding-va-toan-app.md` | 13 | 1 | \| \| LazyFit / ChillFit (quiz) \| Gentle Walk hiện tại \| | Giữ nguyên (báo cáo, kế hoạch lịch sử) |
| `docs/scripts/D-min-texts.md` | 193 | 1 | \| Me → Help \| Gentle Walk is for general fitness. It isn't… | Đổi cùng chuỗi Help trong app |
| `docs/scripts/P-production-prompts.md` | 212 | 1 | - Từ điển phát âm 'gw-terms': "Gentle Walk" (nhấn đều), "sit… | Thêm tên mới vào từ điển phát âm (chỉ cần nếu có câu HLV đọc tên app; hiện không có) |
| `docs/todo.md` | 1, 27, 61, 64 | 5 | # Việc cần làm — Gentle Walk 50+ | Tick dòng "Tên mới" và M11 |
| `site/privacy.html` | 17 | 1 | <!-- "Gentle Walk" là tên làm việc; tên store đang test: Goo… | Xoá ghi chú khi đổi tên |
| `tools/video/video-manager-template.html` | 6, 109 | 2 | <title>Kho video Gentle Walk</title> | Đổi tiêu đề khi chốt (tài liệu đang dùng) |
## 4. Mã nội bộ (không đổi)

| File | Dòng | Số lần | Dạng | Ghi chú |
|---|---|---|---|---|
| `.gitignore` | 9 | 1 | GentleWalk | Giữ: tên file, bundle id, product id, xcodeproj trong lệnh |
| `CLAUDE.md` | 9, 10, 30, 38 | 5 | GentleWalk, gentlewalk | Giữ: tên file, bundle id, product id, xcodeproj trong lệnh |
| `README.md` | 8, 17, 24, 25 | 7 | GentleWalk, gentle-walk | Giữ: tên file, bundle id, product id, xcodeproj trong lệnh |
| `app-context.md` | 3, 56, 76, 97, 103, 105, 106, 110 | 11 | GentleWalk, gentle-walk, gentlewalk | Giữ: tên file, bundle id, product id, xcodeproj trong lệnh |
| `docs/content-plan.md` | 6, 7 | 4 | gentle-walk | Giữ: tên file, bundle id, product id, xcodeproj trong lệnh |
| `docs/design/gentle-walk-screen-spec.html` | 105 | 1 | gentle-walk | Giữ: tên file, bundle id, product id, xcodeproj trong lệnh |
| `docs/i18n/README.md` | 21 | 2 | GentleWalk | Giữ: tên file, bundle id, product id, xcodeproj trong lệnh |
| `docs/idea/gentle-walk-voice.md` | 1, 3, 150, 155 | 4 | gentle-walk | Giữ: tên file, bundle id, product id, xcodeproj trong lệnh |
| `docs/idea/session-choice.md` | 23, 26 | 3 | gentle-walk | Giữ: tên file, bundle id, product id, xcodeproj trong lệnh |
| `docs/owner-todo-after-mvp.md` | 8, 29 | 4 | GentleWalk, gentlewalk | Giữ: tên file, bundle id, product id, xcodeproj trong lệnh |
| `docs/plans/2026-09-29-mvp.md` | 3, 6, 10, 12, 28, 29, 30, 31 … | 86 | GentleWalk, gentle-walk, gentlewalk | Giữ: tên file, bundle id, product id, xcodeproj trong lệnh |
| `docs/plans/2026-09-29-session-choice.md` | 12, 30, 34 | 7 | GentleWalk | Giữ: tên file, bundle id, product id, xcodeproj trong lệnh |
| `docs/plans/2026-10-02-mobbin-patterns-fixes.md` | 11, 13, 15, 20, 33, 46, 71, 76 … | 15 | GentleWalk | Giữ: tên file, bundle id, product id, xcodeproj trong lệnh |
| `docs/release/1.0/checklist.md` | 6, 7, 8, 10 | 4 | GentleWalk, gentlewalk | Giữ: tên file, bundle id, product id, xcodeproj trong lệnh |
| `docs/research/2026-09-30-competitor-4-groups.md` | 169 | 1 | gentle-walk | Giữ: tên file, bundle id, product id, xcodeproj trong lệnh |
| `docs/research/2026-10-03-ten-app-moi.md` | 98 | 2 | gentlewalk | Giữ: tên file, bundle id, product id, xcodeproj trong lệnh |
| `docs/research/competitors-ui-reference.md` | 20, 21 | 2 | gentle-walk | Giữ: tên file, bundle id, product id, xcodeproj trong lệnh |
| `docs/research/prototype-test-plan.md` | 2 | 1 | gentle-walk | Giữ: tên file, bundle id, product id, xcodeproj trong lệnh |
| `docs/reviews/2026-09-28-tai-lieu.md` | 3 | 2 | gentle-walk | Giữ: tên file, bundle id, product id, xcodeproj trong lệnh |
| `docs/reviews/2026-09-29-tai-lieu-ke-hoach.md` | 6, 93 | 3 | gentle-walk, gentlewalk | Giữ: tên file, bundle id, product id, xcodeproj trong lệnh |
| `docs/reviews/2026-09-29-toan-app.md` | 6 | 1 | GentleWalk | Giữ: tên file, bundle id, product id, xcodeproj trong lệnh |
| `docs/reviews/2026-09-30-de-hieu-bo-cuc.md` | 40 | 1 | GentleWalk | Giữ: tên file, bundle id, product id, xcodeproj trong lệnh |
| `docs/reviews/2026-10-02-mobbin-patterns.md` | 38 | 2 | GentleWalk | Giữ: tên file, bundle id, product id, xcodeproj trong lệnh |
| `docs/reviews/2026-10-06-chuyen-gia-ra-soat-bai-tap-58-75.md` | 130 | 1 | GentleWalk | Giữ: tên file, bundle id, product id, xcodeproj trong lệnh |
| `docs/scripts/A10-stretch.md` | 2 | 1 | gentle-walk | Giữ: tên file, bundle id, product id, xcodeproj trong lệnh |
| `docs/scripts/D-min-texts.md` | 4 | 1 | gentle-walk | Giữ: tên file, bundle id, product id, xcodeproj trong lệnh |
| `docs/todo.md` | 15 | 1 | GentleWalk | Giữ: tên file, bundle id, product id, xcodeproj trong lệnh |
| `docs/video-skill-notes.md` | 63 | 1 | gentle-walk | Giữ: tên file, bundle id, product id, xcodeproj trong lệnh |
| `iOS/App/Design/Tokens.swift` | 4 | 1 | gentle-walk | Giữ: tên type, target, file, test |
| `iOS/App/Features/Me/MeSections.swift` | 236 | 1 | Gentle Walk | Chú thích code; sửa tuỳ ý |
| `iOS/App/Features/Onboarding/OnboardingMotion.swift` | 4 | 1 | Gentle Walk | Chú thích code (tên bản thiết kế); giữ |
| `iOS/App/GentleWalk.storekit` | 16, 52, 73 | 3 | gentlewalk | Giữ: product id |
| `iOS/App/GentleWalkApp.swift` | 8 | 1 | GentleWalk | Giữ: tên type, target, file, test |
| `iOS/App/Persistence/MigrationPlan.swift` | 4 | 1 | GentleWalk | Giữ: tên type, target, file, test |
| `iOS/App/Persistence/ModelContainerFactory.swift` | 19 | 1 | GentleWalk | Giữ: tên type, target, file, test |
| `iOS/App/Services/Audio/SessionPlayer.swift` | 49 | 1 | gentlewalk | Giữ: subsystem log = bundle id |
| `iOS/App/Services/Content/AppLanguage.swift` | 47, 57 | 2 | Gentle Walk | Chú thích code; sửa tuỳ ý |
| `iOS/GentleWalkTests/CaptureHookTests.swift` | 10, 11, 12, 13, 14, 15, 16 | 7 | GentleWalk | Giữ: tên type, target, file, test |
| `iOS/GentleWalkTests/ReleaseContentTests.swift` | 9 | 1 | GentleWalk | Giữ: tên type, target, file, test |
| `iOS/GentleWalkTests/StoreConfigTests.swift` | 5, 9, 12, 20, 21, 22 | 8 | GentleWalk, gentlewalk | Giữ: tên type, target, file, test |
| `iOS/GentleWalkTests/StoreServiceTests.swift` | 15, 20 | 2 | GentleWalk | Giữ: tên type, target, file, test |
| `iOS/Packages/GentleWalkCore/Package.swift` | 4, 7, 10, 13, 15, 16 | 7 | Gentle Walk, GentleWalk | Giữ tên package; chú thích dòng 4 sửa tuỳ ý |
| `iOS/Packages/GentleWalkCore/Sources/GentleWalkCore/Store/EntitlementRules.swift` | 3, 5, 6, 7 | 4 | GentleWalk, gentlewalk | Giữ: product id |
| `iOS/project.yml` | 1, 19, 20, 22, 28, 32, 35, 36 … | 19 | GentleWalk, gentlewalk | Giữ: tên project, target, PRODUCT_NAME, bundle id, file .storekit/.entitlements |
| `iOS/scripts/capture_states.sh` | 9, 15, 24 | 3 | GentleWalk, gentlewalk | Giữ: tên type, target, file, test |
## 5. Không phải tên app

"Gentle walk" (chữ w thường) là tên buổi đi bộ Gentle walk 5 và nhãn "Gentle walk · %lld min". **Không đổi.** (Câu Welcome "Gentle walks and chair moves, at your pace." đã được thay bằng khẩu hiệu mới ngày 07/10/2026.) Vị trí: `docs/design/gentle-walk-screen-spec.html` L260 · `docs/i18n/source/ui.json` L4286, 4401, 4775 · `docs/i18n/vi/ui-2.json` L229, 245, 297 · `docs/plans/2026-09-29-mvp.md` L805 · `docs/plans/2026-09-30-content-4-groups.md` L58, 62, 151 · `docs/reviews/2026-09-30-can-duyet.md` L41, 44 · `docs/scripts/A11-extras.md` L123 · `docs/scripts/A2-walk.md` L5, 28, 38, 45, 72, 131, 357, 464 · `iOS/App/Features/Onboarding/WelcomeView.swift` L20 · `iOS/App/Features/Sessions/SessionPreset+Request.swift` L26 · `iOS/App/Features/Today/TodayModel.swift` L328 · `iOS/App/Features/Workout/Preview/WorkoutPreviewModel.swift` L83 · `iOS/App/Features/Workout/WorkoutRequest.swift` L70 · `iOS/App/Localizable.xcstrings` L2085, 2096, 2107 · `iOS/GentleWalkTests/TodayModelTests.swift` L33 · `iOS/Packages/GentleWalkCore/Sources/GentleWalkCore/Plan/SessionCatalog.swift` L32 · `tools/content/sessions_walk.py` L2, 157 · `tools/lint/test_copy_lint.py` L37.

## 6. Đổi một lượt khi chốt tên

Làm theo thứ tự, trong một nhánh, một commit. `<Tên>` = Good Footing hoặc Kind Pace.

1. **Trước khi sửa code:** tên đã qua test người dùng và luật sư nhãn hiệu; đã giữ tên trên App Store Connect; đã có tên miền.
2. **Info.plist:** sửa `iOS/project.yml` dòng 53 (`CFBundleDisplayName: <Tên>`, ≤12 ký tự) và dòng 55–58 (4 câu xin quyền). Chạy `xcodegen generate` trong `iOS/`. Không sửa tay `Info.plist`.
3. **`InfoPlist.xcstrings`:** en và vi cho `CFBundleDisplayName`, `CFBundleName` (giá trị = tên ngắn, không đổi `PRODUCT_NAME`), 4 câu `NS…UsageDescription`. Sửa cùng `docs/i18n/source/infoplist.json` và `docs/i18n/vi/infoplist.json`.
4. **Chữ cứng ngoài catalog (mục 1b):** Welcome "GENTLE WALK" → chữ hoa của tên mới (dòng 15) và nhãn VoiceOver (dòng 18); thẻ chia sẻ; Now Playing; câu đóng-mở app ở `AppLanguage.swift` (en + vi).
5. **Chữ trong catalog (mục 1c):** sửa 11 file Swift. Rồi:
   ```bash
   cd iOS && xcodebuild build -project GentleWalk.xcodeproj -scheme GentleWalk -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath /tmp/gw-dd SWIFT_EMIT_LOC_STRINGS=YES && cd ..
   python3 tools/i18n/extract_sources.py /tmp/gw-dd
   ```
   Thêm bản Việt cho 14 khoá mới vào một file `docs/i18n/vi/ui-extra-<n>.json` (tên riêng giữ nguyên, không dịch: "Good Footing Pro", "Kind Pace Pro"). Sửa 3 bản Việt chỉ có tên (Apple Health, Purchases, We don't have accounts). Rồi:
   ```bash
   python3 tools/i18n/apply_catalog.py vi
   python3 tools/i18n/apply_catalog.py vi --check
   python3 tools/i18n/scan_literals.py
   ```
   Xoá các khoá cũ có "Gentle Walk" đã thành stale trong `Localizable.xcstrings`.
6. **Lời HLV và nội dung:** `grep -rn "Gentle Walk" iOS/App/Resources/Content assets/voice` phải ra 0 (06/10: 0). Nếu sau này có câu HLV đọc tên app: thu lại EN (ElevenLabs) và VI (Vibi), thêm tên vào từ điển phát âm `gw-terms` (`docs/scripts/P-production-prompts.md:212`).
7. **StoreKit và App Store Connect (mục 2):** đổi chữ trong `GentleWalk.storekit` (4 chỗ); trên ASC đặt Name, Subtitle, tên nhóm subscription "<Tên> Pro" mọi ngôn ngữ, display name 3 sản phẩm, App Review notes. Paywall, Me và hộp mua của Apple phải cùng một tên "<Tên> Pro".
8. **`site/`:** đổi 6 chỗ trong `privacy.html`, xoá ghi chú tên làm việc; cập nhật URL Privacy Policy, Support URL trên ASC.
9. **Ảnh store và icon:** chụp lại màn có tên (Welcome, paywall, Me) bằng `-ScreenshotMode`, làm lại chú thích ảnh, video preview; kiểm icon không có chữ "Gentle Walk".
10. **Tài liệu đang dùng (mục 3, cột "Đổi"):** `README.md`, `CLAUDE.md` dòng 1, `docs/todo.md` (tick "Tên mới", M11), `docs/i18n/README.md`, `docs/i18n/glossary-vi.md`, `docs/release/1.0/*`, brief infographic v2, spec màn hình. Chủ app tự sửa `app-context.md` (Identity: tên store đã chốt; nhật ký giữ nguyên). Không sửa báo cáo lịch sử.
11. **Kiểm:**
    - `grep -rn "Gentle Walk\|GENTLE WALK" iOS/App site` chỉ còn chú thích code (mục 4).
    - `python3 tools/lint/copy_lint.py` → `0 findings`.
    - Test: `LocalizationTests`, `StoreConfigTests`, `PaywallModelTests`.
    - Xem bằng mắt, tiếng Anh: Welcome, paywall (có và không có trial), Me (Pro, Help, quyền vị trí), Journey (chặng khoá), thẻ chia sẻ, 4 hộp xin quyền, tên dưới icon trên Home (không bị cắt), màn khoá khi đang tập, Cài đặt → Đăng ký so với câu "Choose <Tên>". Tiếng Việt chỉ khi chủ app yêu cầu test đủ.

**Tuỳ chọn (chủ app quyết):** gom tên vào một hằng số Swift (ví dụ `AppBrand.name`) và chèn bằng interpolation ("\(AppBrand.name) Pro"). Lần đổi tên sau chỉ sửa một chỗ, khoá catalog thành "%@ Pro" nên bản dịch không phải làm lại. Đổi cách này cũng tạo khoá mới một lần.

## 7. Không được đổi

| Mục | Giá trị | Vì sao |
|---|---|---|
| Bundle ID | `com.kmd.goodfooting` (app), `com.kmd.goodfooting.tests` (test) | Đổi ngày 09/10/2026 từ `com.kmd.gentlewalk` (chủ app quyết, chưa có app trên ASC). Từ lúc tạo app trên ASC thì không đổi: đổi là app mới, mất review và người dùng |
| Product ID | `com.kmd.goodfooting.pro.yearly`, `.pro.monthly`, `.pro.lifetime` | Đổi cùng bundle ID ngày 09/10/2026 (chưa tạo trên ASC). Sau khi tạo thì không đổi được; người đã mua mất quyền |
| Log subsystem | `com.kmd.goodfooting` (`SessionPlayer.swift:49`) | Gắn với bundle ID, lệnh `log stream` trong tài liệu |
| App Group | Hiện không có (entitlements chỉ có HealthKit). Nếu thêm widget sau: `group.com.kmd.goodfooting` | Theo bundle ID, không theo tên store |
| Project, target, scheme, `PRODUCT_NAME` | `GentleWalk`, `GentleWalkTests`, package `GentleWalkCore` | Đổi làm vỡ build, đường dẫn, lệnh test, `import` ở 172 dòng |
| Tên file | `GentleWalk.storekit`, `GentleWalk.entitlements`, `GentleWalkApp.swift`, `GentleWalk.xcodeproj`, `docs/idea/gentle-walk-voice.md`, `docs/design/gentle-walk-screen-spec.html` | Nhiều tài liệu và test trỏ tới; `SKTestSession(configurationFileNamed: "GentleWalk")` |
| Tên type Swift | `GentleWalkApp`, `GentleWalkMigrationPlan` | Nội bộ; đổi migration plan không có lợi, dễ rủi ro dữ liệu |
| File dữ liệu SwiftData | Store mặc định, không gắn tên app | Giữ nguyên để không mất dữ liệu người dùng |
| Tên thư mục repo | `Gentle Walk 50+` | Không ai thấy; đổi làm hỏng đường dẫn trong memory, script |
| "Gentle walk" (tên buổi) | xem mục 5 | Không phải tên app |

## Câu hỏi còn mở

1. Tên dưới icon "Good Footing" dài 12 ký tự, sát ngưỡng bị cắt: cần chụp Home trên iPhone nhỏ nhất app hỗ trợ trước khi chốt.
2. Gom tên vào một hằng số Swift (mục 6, tuỳ chọn): làm ngay lần đổi tên này hay không?
