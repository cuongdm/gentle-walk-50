# Good Footing 1.0 — các trường App Store Connect chủ app điền tay
_09/10/2026 · Chữ store tiếng Anh (Mỹ) ở `appstore/metadata-json/en.json`, trang xem và copy `appstore/metadata-review.html` (tạo bằng skill appstore-metadata). Tài liệu này liệt kê những trường **tool API (`tools/appstore/asc-sync.py`) không ghi**, kèm câu trả lời đề xuất. Nguồn: `app-context.md`, `docs/design/steady-claims.md`, `docs/release/1.0/checklist.md` (§2, §3, §5), `iOS/App/PrivacyInfo.xcprivacy`, `iOS/App/Info.plist`, code app. Không ai gọi App Store Connect hay đăng gì lên mạng khi làm tài liệu này._

## Đã làm trên App Store Connect (09/10/2026)
- **Chữ listing** đẩy bằng `tools/appstore/asc-sync.py --only listing --apply`: subtitle, mô tả, từ khoá, promotional text (en-US). Mô tả còn dòng `Privacy Policy: {{PRIVACY_URL}}` chưa điền; khi có URL: sửa `en.json` và `_config.json`, rồi chạy lại đúng lệnh trên.
- **Ảnh store:** 7 ảnh iPhone 6.9" và 6 ảnh iPad 13" (en-US) tải bằng `tools/appstore/asc-upload-shots.py --apply`.
- **Danh mục:** Primary Health & Fitness, Secondary Lifestyle. **Age rating:** trả lời theo mục 3, kết quả 9+ (Việt Nam 12+, Brazil A10, Hàn Quốc ALL).
- **Giá app:** Free (base United States). **Quốc gia:** chỉ United States. **Mac và Vision Pro:** đã tắt.
- **Chủ app xác nhận 09/10/2026 và đã nhập:** Copyright `2026 Cuong Do`; Content Rights "Yes, … necessary rights"; App Review: Sign-in required tắt, liên hệ Cuong Do, +84968594822, cuongdm@live.com, ghi chú duyệt tiếng Anh (mục 7); App Privacy (dạng nháp, **chưa Publish**): Device ID (App Functionality) và Purchases (Analytics + App Functionality), cả hai không gắn danh tính, không theo dõi.
- **Còn lại:** B1/B3 (trang privacy, trang hỗ trợ, URL; sau đó điền Privacy Policy URL, bấm Publish nhãn App Privacy, sửa `{{PRIVACY_URL}}` và chạy lại `asc-sync --only listing --apply`), chọn build cho bản 1.0 (build đang tải lên), Submit do chủ app bấm. TestFlight nội bộ không cần các URL này.

## 0. Việc bị chặn ở chủ app (làm trước khi nộp)

| # | Việc | Vì sao | Chặn cái gì |
|---|---|---|---|
| B1 | **Đăng trang Privacy.** **Đã viết xong, chưa đăng** (nhánh `cloud/site-pages`, 09/10/2026): `site/privacy.html` (ngày "October 9, 2026", đã đối chiếu `PrivacyInfo.xcprivacy`, các `NS…UsageDescription`, code HealthKit/vị trí/chuyển động và RevenueCat; sửa chỗ sai/thiếu, chi tiết ở `docs/handoff/2026-10-09-cloud-site-ket-qua.md`), `site/support.html`, `site/index.html`, `site/style.css` và workflow `.github/workflows/pages.yml` (đăng thư mục `site/` khi push vào `main` có đổi `site/**`, hoặc chạy tay ở tab Actions). **Còn lại của chủ app:** (1) gộp nhánh vào `main`; (2) bật Pages: repo Settings → Pages → Build and deployment → Source = **GitHub Actions** (workflow **chưa** bật gì, chưa đổi cài đặt GitHub nào; trước khi bật thì lần chạy đầu sẽ báo lỗi, vô hại); (3) chạy workflow rồi mở thử URL; (4) xác nhận `cuongdm@live.com` là email hỗ trợ công khai (trang Privacy, trang Support và nút "Contact us" trong app đều dùng nó). Repo `cuongdm/gentle-walk-50` đang **public**. **URL dự kiến:** `https://cuongdm.github.io/gentle-walk-50/privacy.html` (và `/support.html`, `/`). Tên repo là tên cũ nên URL mang tên cũ; muốn tên mới thì dùng tên miền riêng (`goodfooting.app` còn trống ngày 03/10, chưa mua) hoặc đổi tên repo, chủ app quyết. | ASC bắt buộc Privacy Policy URL. 3.1.2 bắt buộc link Privacy cho app có subscription. | `asc-sync --only listing` |
| B2 | Có URL rồi thì: (a) điền `privacy_url` trong `appstore/metadata-json/_config.json` (đang là chuỗi `TODO: …`); (b) thay `{{PRIVACY_URL}}` ở cuối `description` trong `en.json`. | Tool **không** thay `{{PRIVACY_URL}}`. Nếu chạy bây giờ, nó ghi chuỗi `TODO: …` vào trường Privacy Policy URL và để nguyên `{{PRIVACY_URL}}` trong mô tả. | `asc-sync --only listing` |
| B3 | **Support URL.** **Đã viết xong, chưa đăng** (nhánh `cloud/site-pages`, 09/10/2026): `site/support.html` có email `cuongdm@live.com`, cách huỷ gói (Settings → tên bạn → Subscriptions), Restore (Me → Help → Restore purchase), xoá dữ liệu (Me → Delete all my data), vài câu hỏi thường gặp (tài khoản, máy mới, Apple Health, nhắc giờ) và câu "general fitness, not medical advice". **URL dự kiến:** `https://cuongdm.github.io/gentle-walk-50/support.html` (cùng điều kiện đăng như B1). `support_url` trong `_config.json` vẫn `null`: điền sau khi URL chạy thật (cùng lúc B2). ASC bắt buộc trường này và không nhận `mailto:`. | Bắt buộc mỗi phiên bản. | Nộp bản |
| B4 | **Quyết Device ID** trong App Privacy (mục 8). | SDK RevenueCat gửi IDFV trong header. | Nhãn App Privacy |
| B5 | **Xác nhận dòng copyright** `2026 Manh Cuong Do` (mục 4). | Phải đúng tên người giữ quyền. | Nộp bản |
| B6 | **Quyền nội dung** (mục 6): xác nhận giấy phép thương mại của giọng, nhạc và clip trước khi chọn "I have the necessary rights". | Câu trả lời phải đúng sự thật. | Nộp bản |
| B7 | **Liên hệ App Review**: họ, tên, số điện thoại (có mã nước, ví dụ +84), email (mục 7). | Bắt buộc. | Nộp bản |
| B8 | Thêm `seniors` vào keywords hay không (mục 1). Không bắt buộc. | **VƯỢT LUẬT DỰ ÁN**: Tone & copy cấm "senior". | Không chặn |

## 1. Chữ store đã viết (tool API đẩy, không cần gõ tay)
| Trường | Giá trị | Độ dài |
|---|---|---|
| Name | `Good Footing: Gentle Workouts` | 29/30 |
| Subtitle | `Chair Yoga, Walks & Stretches` | 29/30 |
| Keywords | `balance,low,impact,indoor,home,women,beginner,exercise,seated,easy,strength,mobility,pad,leg,walking` | 100/100 |
| Promotional text | "Steadier on your feet, at your own pace. A warm coach's voice guides every walk, chair move and stretch, so you can follow along without watching the screen." | 157/170 |
| Description | mở bằng khẩu hiệu; giọng dẫn; kế hoạch theo cơ thể; vững hơn từng tuần; miễn phí vs Pro; riêng tư; đoạn subscription; dòng "general fitness, not medical advice"; link Terms (EULA Apple) + `Privacy Policy: {{PRIVACY_URL}}` | 3355/4000 |
| What's New | để trống (bản 1.0; tool tự bỏ trường này khi ASC không cho sửa) | 0 |

Đã kiểm:
- Độ dài; chỉ ký tự ASCII cộng dấu `•`; không có gạch dài, dấu ba chấm hay ngoặc cong.
- Keywords không lặp chữ của tên hay phụ đề, không có tên đối thủ hay tên tổ chức (NIA, CDC, NHS, Otago…).
- Không có cụm bị cấm trong `steady-claims.md`.
- Không có giá hay số tự đặt: 12 tuần, 5–10 phút, 30 giây, 2 tuần đều lấy từ app.
- `python3 tools/lint/copy_lint.py appstore/metadata-json/en.json` → **0 findings**.

Lựa chọn trong chữ:
- **"walking"** cố ý có trong keywords dù phụ đề đã có "Walks". App Store không chắc gộp "walks" với "walking", mà "indoor walking" và "walking pad" là cụm người ta gõ.
- **Không có "tai chi"**: app chưa có bài tai chi (để phase 2). Từ khoá không đúng nội dung có thể bị Apple từ chối.
- **Không có "seniors"**: chờ chủ app quyết (B8). Nếu thêm, đổi `mobility` (8 ký tự) lấy `senior` (6 ký tự). Khi đó `copy_lint.py` sẽ báo 1 lỗi ở trường keywords, vì nó đọc mọi chuỗi trong file.
- **Hành trình địa danh và đi ngoài trời không có trong mô tả**, theo app-context ("Bồi thêm, không lên listing"). Ảnh store số 5 (`journey`) lại có hành trình. Nếu muốn mô tả khớp với ảnh, thêm một dòng vào phần Pro: "• More walking journeys along real routes".
- Phần subscription không ghi giá và không ghi số ngày dùng thử ("shown in the app before you buy"), vì app đọc số ngày từ App Store. Có đủ các ý: tự gia hạn, 24 giờ, huỷ trong Settings, xoá app không huỷ gói, phần trial chưa dùng hết bị mất khi mua.

## 2. Category
- **Primary: Health & Fitness.** App là bài tập dẫn bằng giọng, đối thủ cùng nhóm (LazyFit, Bend, WalkFit) đều ở đây, và app-context đã chốt.
- **Secondary: Lifestyle** (đề xuất). App là thói quen nhẹ mỗi ngày tại nhà. Thêm một bảng xếp hạng để lọt vào, mà không kéo app sang nhóm khác.
- **Không chọn Medical**: chọn Medical làm reviewer soi kỹ theo 1.4.1 và trái với định vị "general fitness". Cũng không chọn Sports: sai khách.

## 3. Age rating (ASC tự tính bậc từ câu trả lời; ghi lại bậc ra)
Bộ câu hỏi mới của ASC (từ 2025) chia theo nhóm. Tên câu hỏi trên màn có thể khác chút; trả lời theo nghĩa.

| Nhóm | Câu hỏi | Trả lời | Ghi chú |
|---|---|---|---|
| In-app controls | Parental Controls · Age Assurance | No · No | |
| Capabilities | Unrestricted Web Access | No | Chỉ mở link Terms cố định và mailto |
| | User-Generated Content · Messaging and Chat | No · No | Không có mạng xã hội, không chat |
| | Advertising | No | Không quảng cáo trong app |
| Mature themes | Profanity or Crude Humor · Horror/Fear · Alcohol, Tobacco, Drugs | None | |
| Medical or wellness | **Medical or Treatment Information** | **None / No** | App là **hướng dẫn tập thể dục chung, không phải thông tin y tế**: Me ghi "is for general fitness. It isn't medical advice"; tự kiểm tra ghi "This is not a medical test". Câu "Check with your doctor first" là lời nhắc an toàn, không phải thông tin điều trị. |
| | **Health or Wellness Topics** | **Yes** | Bài tập, giãn cơ, thăng bằng |
| Sexuality or nudity | mọi câu | None | |
| Violence | mọi câu (gồm Guns or Other Weapons) | None | |
| Chance-based | Simulated Gambling · Gambling · Contests · Loot Boxes | No / None | |
| Khác | Made for Kids | **Không chọn** | Khách 58–75 |

Bậc dự kiến thấp (4+). Nếu câu "Health or Wellness Topics" làm ASC ra bậc cao hơn, **vẫn giữ câu trả lời đúng**: khách 58–75 không bị ảnh hưởng bởi bậc tuổi.

## 4. Copyright (App Information → General → Copyright)
`2026 Manh Cuong Do` — **cần chủ app xác nhận** (B5): đúng tên pháp lý trên tài khoản Apple Developer cá nhân và đúng thứ tự tên mong muốn. Theo mẫu của ASC: năm + tên, không ký hiệu ©, không URL.

## 5. Pricing and Availability
- **Price: Free** (0 USD). Pro bán bằng In-App Purchase: năm có dùng thử, tháng, trả một lần. Giá đặt ở từng sản phẩm (checklist §1), **không** đặt ở giá app.
- **Availability: chỉ United States** cho 1.0 (app-context: Mỹ trước, sau đó UK, CA, AU). Khi mở UK/CA/AU, listing en-US hiện ở đó nếu chưa có bản en-GB/en-CA/en-AU; xem lại keywords theo từng nước.
- **Mac (Apple silicon) và Apple Vision Pro: bỏ chọn** "Make this app available". App iPad mặc định được bật trên hai nền này, nhưng HealthKit, chuyển động và đi ngoài trời chưa test ở đó.
- Pre-order: không. Distribution: Public.

## 6. Content Rights (App Information → Content Rights)
- "Does your app contain, show, or access third-party content?" → **Yes**: giọng AI qua Vibi/ElevenLabs, nhạc AI, clip AI, icon Phosphor (MIT).
- "Do you have all necessary rights?" → **Yes, chỉ sau khi chủ app xác nhận** (B6):
  1. Mọi file giọng EN và VI tạo trên gói có quyền thương mại, không còn file của gói ElevenLabs Free (app-context, Risks).
  2. Nhạc trong `music.json` có giấy phép thương mại; bản thử Lyria cũng phải đủ điều kiện.
  3. Clip không còn dấu ✦ hay watermark và theo điều khoản thương mại của Flow/Higgsfield (asset-checklist).

## 7. App Review Information
- **Sign-in required: không chọn** (app không có tài khoản, nên không có tài khoản demo).
- **Contact** (B7): First name, Last name, Phone (+84…), Email. Reviewer có thể gọi, nói tiếng Anh.
- **Attachment (khuyên làm)**: một video quay màn hình ngắn: đi ngoài trời với "Map and distance", khoá màn hình, giọng vẫn chạy. Apple hay đòi video khi app dùng background location.
- **Notes**: dán nguyên khối dưới (3.748/4.000 ký tự, chỉ ASCII). Viết lại từ checklist §5 theo luồng app hiện tại: onboarding 7 câu, paywall gọn, Restore và "How to cancel" ở Me, quyền Motion, RevenueCat.

```text
Good Footing needs no account or sign-in, so there is no demo account. Workouts play offline; buying and restoring need a connection.

WHERE TO FIND THINGS
- Paywall: finish the short onboarding (Welcome, 7 short questions, "Your plan"; about 2 minutes). The paywall follows "Your plan". Later: tap any item with a "Pro" badge (Today > Short extras > See all, a locked journey on the Journey tab, Progress > Recent sessions > See all) or Me > See Pro plans.
- Restore: in the paywall footer and in Me > Help > Restore purchase. Me also has "How to cancel".
- Pro content: the extra sessions and the fuller chair and stretch sessions, more reps and less hand support on the chair as she gets steadier, choosing rest days, full session history, and 4 of the 5 journeys (the first leg of each is free).

PAYWALL
The first view shows the yearly plan with its free-trial timeline; "See other plans" opens the monthly plan and the one-time purchase on the same screen. Restore, Terms of Use (Apple standard EULA), Privacy Policy, the billed price and the renewal terms are visible in both views, and "Maybe later" or Close dismisses it. Prices and the trial length come from the App Store. Purchases use StoreKit through the RevenueCat SDK under an anonymous ID.

PERMISSIONS (all optional, never at launch)
- Notifications and Apple Health: asked after the first finished workout, one per screen. Each screen has one button that opens the system dialog; "Don't Allow" leaves the app fully usable, and both can be turned on later in Me.
- Location (When In Use): only for an outdoor walk. On Today, open the walk, choose "Outdoors" on the preview, then "Map and distance". Indoor sessions never use location.
- Motion: only if the user picks "Held to my chest" on the phone-placement screen before the first walk (to count stand-ups), or measures an outdoor walk without location.

BACKGROUND MODES
- Audio: continuous spoken guidance, bells and optional music during a workout, so the user can follow with the screen locked. The app never plays silent audio.
- Location: only during an outdoor walk the user started with "Map and distance", to measure distance and draw the route. It is switched off when the walk ends.

HEALTHKIT
Step count is read for the Progress screen and, on days the user has already walked much more than her own usual, to suggest a gentle stretch instead. Nothing from Apple Health is stored by the app or sent off the device. Workouts are written after each session.

GENERAL FITNESS, NOT MEDICAL
The app says it is general fitness, not medical advice. The 2-week check is a self-counted 30-second chair stand, compared only with the user's own earlier checks done the same way. It shows no norms, scores or risk levels, and results stay on the device.

PERSONALISATION AND PRIVACY
The plan adapts to the user's own answers (goal and body limits, "How did that feel?", an optional weekly check-in, "This hurts"). All of it stays on the device: no account, no server of our own, no analytics or advertising SDKs. RevenueCat receives purchase records under an anonymous ID; no health data, answers or location are sent.

HOW IT DIFFERS FROM A TIMER APP (4.3)
Voice-led interval walks at three intensities (seated, in place or on a walking pad), seated chair moves with looping demonstration clips, stretches held per intensity, a short balance set on workout days, a 12-week plan that adapts to feedback and pain reports, and landmark journeys that move with active minutes.

OTHER
- "Hear your coach" on "Your plan" plays two bundled lines of the first session (the real recording, voice only) and stops when the screen closes.
- "Watch on your TV" only explains the system Screen Mirroring; the app has no TV code of its own.
```

## 8. App Privacy (nhãn quyền riêng tư)
Khớp `iOS/App/PrivacyInfo.xcprivacy` (tracking `false`, không tracking domain, chỉ khai Purchase History) và manifest riêng của SDK RevenueCat 5.94.0.

- **"Do you or your third-party partners collect data from this app?" → Yes** (vì có RevenueCat; không còn "Data Not Collected").
- **Purchases → Purchase History**: Collected · **Linked to the user: No** (mã ẩn danh của RevenueCat, không đăng nhập, không email) · **Used for tracking: No** · Purposes: **App Functionality** + **Analytics**.
- **Identifiers → Device ID: CHỦ APP QUYẾT (B4).** SDK gửi IDFV trong header `X-Apple-Device-Identifier`, máy chủ thấy địa chỉ IP.
  - (A) Không khai, theo hướng dẫn của RevenueCat: chỉ phải khai khi dùng IDFA, mà app không dùng và đã tắt thu định danh tự động.
  - (B) Khai cho chắc: Device ID · Not linked · No tracking · App Functionality.
  - Nghiêng về **B**: thêm một dòng "Data Not Linked to You" trên nhãn, đổi lại ít rủi ro reviewer hỏi lại.
- **Không khai** (dữ liệu không rời máy, nên theo định nghĩa của Apple là không "collect"): Health & Fitness (HealthKit, buổi tập, báo đau), Location (tuyến đi ngoài trời), Contact Info, User Content, Usage Data, Diagnostics, Identifiers → User ID (chỉ dùng mã ẩn danh).
- **Tracking: không** → không có màn ATT.
- Privacy Policy URL: chờ B1/B2. Privacy Choices URL: bỏ trống.
- Kiểm lại với trang "Apple App Privacy" của RevenueCat lúc nộp (checklist §3).

## 9. URL
| Trường | Trạng thái | Ai ghi |
|---|---|---|
| Privacy Policy URL | **Chờ đăng trang** (B1; trang đã viết; sau đó B2). Dự kiến `https://cuongdm.github.io/gentle-walk-50/privacy.html` | tool, từ `_config.json` → `locales.en.privacy_url` |
| Support URL | **Chờ đăng trang** (B3; trang đã viết). Dự kiến `https://cuongdm.github.io/gentle-walk-50/support.html` | tool, từ `_config.json` → `support_url` |
| Marketing URL | Không bắt buộc; để `null` cho 1.0, thêm khi có trang chủ | tool, từ `_config.json` → `marketing_url` |
| Terms of Use (EULA) | Xong: EULA chuẩn của Apple, link nằm trong description; trường License Agreement giữ mặc định | — |

## 10. Accessibility Nutrition Labels (không bắt buộc, App Store → Accessibility)
Chỉ khai tính năng đã kiểm trên **các tác vụ chính** (onboarding, bắt đầu và theo hết một buổi, paywall):
- **Khai được ngay**:
  - Larger Text: Dynamic Type, Me → Text size.
  - Dark Interface: có Appearance.
  - Sufficient Contrast: `DesignTokenTests` kiểm 4,5:1 ở cả sáng và tối.
  - Reduced Motion: chỉ còn mờ dần.
  - Differentiate Without Color Alone: trạng thái chọn có dấu check và viền.
- **Chỉ khai sau khi test đủ**: VoiceOver, Voice Control, Captions (phụ đề lời HLV).
- **Không khai**: Audio Descriptions.

## 11. Khác (không phải tool API)
- **Export compliance**: `Info.plist` chưa có `ITSAppUsesNonExemptEncryption`, nên ASC hỏi ở mỗi build. App chỉ dùng HTTPS (RevenueCat), nên trả lời là chỉ dùng mã hoá chuẩn, được miễn. Muốn khỏi hỏi lại thì thêm key `false` vào `iOS/project.yml` (việc code, chưa làm).
- **In-App Purchases**: tool chỉ ghi tên hiển thị và mô tả (từ `GentleWalk.storekit`). Giá, trial 2 tuần, ảnh review, ghi chú review từng IAP, và **gắn cả 3 IAP vào bản 1.0** là việc tay (checklist §1).
- **Version**: 1.0, chọn build, Release: chủ app chọn tự phát hành hay phát hành tay. **Submit do chủ app bấm.**
