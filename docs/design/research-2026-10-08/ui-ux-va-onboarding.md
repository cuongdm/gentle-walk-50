# Rà soát UI/UX toàn app và thiết kế lại onboarding — 08/10/2026

_Phạm vi: 50 ảnh chụp iPhone 11 (414×896 pt, cỡ chữ mặc định, sáng) trong `docs/design/research-2026-10-08/ip11/`, mã nguồn `iOS/App/Features/**`, `iOS/App/Design/**`, `app-context.md`, spec màn hình, nghiên cứu Chillio (MeowBreath 06/10) và rà soát App Review onboarding (MeowBreath 07/10), mẫu Mobbin H&F 104 app. Kết luận "cuộn" lấy từ phần bị cắt ở mép dưới ảnh + tính chiều cao cho iPhone SE 3 (375×667 pt, màn nhỏ nhất iOS 18 hỗ trợ). Không sửa code; chỉ tạo file trong thư mục này. Tài liệu cá nhân hoá `docs/research/2026-10-08-ca-nhan-hoa.md` xuất hiện lúc viết xong và khớp với phát hiện ở đây (goals/barriers không dùng lại, bảng tín hiệu mục 1.1 của nó có file:line đầy đủ, không lặp lại ở đây); `font-va-hinh-anh.md` (13:00) đề xuất giữ font hệ thống: New York tiêu đề, SF Pro chữ, SF Pro Rounded cho số, caption 16 pt, nút 64 pt — mockup ở đây dùng đúng bộ đó._

## 0. Tóm tắt
1. 21/50 màn phải cuộn trên iPhone 11; trên SE là 31/50. Nặng nhất: 3 màn onboarding giấu nút Continue hoặc giấu lựa chọn an toàn dưới mép (goal, barriers, body), paywall giấu gói thứ ba trên SE, màn Permissions giấu thẻ Apple Health, Self-check intro giấu "How it works".
2. Onboarding hiện không cùng một khung: Continue lúc nằm trong danh sách, lúc ghim đáy; câu HLV đáp mọc ở dưới đẩy nút đi; mỗi màn 25–110 chữ phía trên mép.
3. Câu trả lời goal, barriers, activity được lưu nhưng **không dùng lại** ở đâu sau onboarding (chỉ `bodyLimits` và tên); paywall và Today không đổi theo người (chi tiết: 2026-10-08-ca-nhan-hoa.md mục 1.1).
4. Đề xuất onboarding mới 9 màn (thay 10): một bộ khung chung (thanh bước + đường đi · câu hỏi · ô HLV cố định 2 dòng · lựa chọn ≥ 56 pt · nút ghim đáy), vừa iPhone SE không cuộn, tiêu đề ≤ 8 chữ, gợi ý ≤ 15 chữ; "nghe HLV 10 giây" ngay trên thẻ Day 1 trước paywall.
5. Bốn đề xuất đổi quyết định cũ (đánh dấu ĐỔI QUYẾT ĐỊNH CŨ): chọn 1 mục tiêu thay vì 2; bỏ màn "You're not alone" (gộp vào câu HLV đáp); bỏ câu "How active are you now?"; tách màn cơ thể thành 2.
6. Mockup: `onboarding-mockups.html` + 26 PNG (13 màn × SE/iPhone 11) trong `mockups/`; danh sách sửa toàn app P1/P2/P3 ở mục 5.

## 1. Kết quả rà soát 50 màn

Mức: **C** Critical (hành động chính hoặc lựa chọn an toàn bị giấu) · **I** Important · **M** Minor. "Chữ" = số chữ tiếng Anh phía trên mép iPhone 11 (ước lượng). Cuộn: ✓ phải cuộn · ✗ vừa · ≈ vừa sát mép.

| # | Màn (ảnh) | Cuộn 11 / SE | Chữ | Vấn đề | Mức | file:line |
|---|---|---|---|---|---|---|
| 1 | onboarding-welcome | ✗ / ✓ | 40 | Tranh cố định 260 pt; SE mất nút Let's begin dưới mép (260+tiêu đề 2 dòng+3 dòng+nút > 647). Nội dung tốt, 3 dòng ≤ 7 chữ. | I | WelcomeView.swift:12, 55 |
| 2 | onboarding-goal | ✓ / ✓ | 45 | 7 thẻ 72 pt + câu HLV mọc dưới danh sách → câu HLV bị cắt, **Continue ngoài màn**; spec nói tối đa 6 lựa chọn. | C | QuestionViews.swift:9-24; OnboardingView.swift:17-19 (không ghim) |
| 3 | onboarding-barriers | ✓ / ✓ | 45 | 6 thẻ + câu HLV → Continue bị cắt ở mép. | C | QuestionViews.swift:34-46 |
| 4 | onboarding-understanding-joints | ✗ / ≈ | 45 | Màn không hỏi gì, 1 chạm thêm; dòng đệm "Next, a few questions about your day." Trên SE tranh 180 + 3 đoạn sát mép. | M | QuestionViews.swift:60-69 |
| 5 | onboarding-name | ✗ / ✗ | 15 | Tốt. Bàn phím che Continue (Return = continue nên ổn); câu HLV mọc giữa ô và nút làm nút nhảy. | M | QuestionViews.swift:95-98 |
| 6 | onboarding-strength | ✗ / ✗ | 25 | Tốt. Tiêu đề 9 chữ, 3 dòng. | M | QuestionViews.swift:144 |
| 7 | onboarding-body | ✓ / ✓ | 70 (+28 bác sĩ) | 10 chip + "None of these" dưới thanh ghim: **"I feel unsteady on my feet" nửa khuất, "None of these" không thấy**; người không có giới hạn không biết bấm gì; hình người nhỏ bên tiêu đề ép tiêu đề thành 2 dòng. | C | QuestionViews.swift:173-188; BodyLimitChips.swift:27-35; OnboardingView.swift:41-50 |
| 8 | onboarding-plan | ✓ / ✓ | 110 | 4 thẻ; "Why this will work for you" dưới mép; 110 chữ là màn đọc nhiều nhất của onboarding; chip giới hạn + dòng Pro trong cùng thẻ. | I | PlanReadyView.swift:18-31, 141 |
| 9 | paywall-eligible | ✓ / ✓ | 95 | 11: "Cancel anytime…" và "Or keep the free plan" bị cắt; **SE: gói thứ ba nằm dưới footer ghim**. Bộ ba Restore/Terms/Privacy, giá thu nổi bật, dòng thời gian: đạt. | I | PaywallView.swift:26-52, 150-209 |
| 10 | permissions | ✓ / ✓ | 75 | Thẻ Apple Health bị cắt, nút Connect không thấy; 2 việc trong 1 màn cuộn. Hỏi quyền sau buổi đầu: đúng. | I | PermissionsView.swift:14-52 |
| 11 | phone-placement | ✗ / ✓ | 45 | 3 thẻ tranh ~130 pt; SE mất thẻ thứ ba. | M | PhonePlacementView.swift:51-90 |
| 12 | ready-first-walk | ✗ / ≈ | 30 | Tốt: icon + 2–3 chữ. | M | WorkoutReadyView.swift:8-80 |
| 13 | preview-chair | ✓ / ✓ | 60 | Danh sách 6 động tác bị cắt (Cool-down); tranh 140 pt chiếm chỗ; Start ghim nên không nguy hiểm. | M | WorkoutPreviewView.swift:24-26, 36 |
| 14 | preview-indoor | ✓ / ✓ | 60 | 2 hàng chọn tranh + danh sách bị cắt; "Swap" dưới mép. | M | WorkoutPreviewView.swift:27-36 |
| 15 | preview-steady | ✓ / ✓ | 60 | Như 14. | M | như trên |
| 16 | countdown | ✗ / ≈ | 20 | Tốt: pha, đồng hồ 80 pt, câu HLV. | — | WorkoutCountdownView.swift |
| 17 | walk-player | ✗ / ≈ | 30 | Tốt. SE: video 188 + khối chữ sát mép, dòng gợi ý có thể bị cắt. | M | WalkPlayerView.swift |
| 18 | chair-player | ✗ / ≈ | 30 | Tốt; "Tap +1 each time you stand" 15 pt mờ (hướng dẫn không được dùng chữ phụ). | M | ChairPlayerView.swift |
| 19 | chair-counted | ✗ / ≈ | 25 | Tốt. | — | ChairPlayerView.swift |
| 20 | stretch-player | ✗ / ≈ | 25 | "Breathe with the circle" đè lên video có nền mờ: đạt. | — | StretchPlayerView.swift |
| 21 | steady-set | ✗ / ≈ | 25 | Tốt; chip "Two hands on the chair" rõ. | — | ChairPlayerView.swift |
| 22 | balance-back-walk | ✗ / ≈ | 35 | Tốt; tranh thay video. | — | ChairPlayerView.swift |
| 23 | break | ✗ / ✗ | 45 | Tốt; cảnh báo cấp cứu đúng chỗ. | — | BreakView.swift |
| 24 | this-hurts | ✗ / ✗ | 55 | 3 link chữ xếp dọc đủ 56 pt; đạt. | — | ThisHurtsView.swift |
| 25 | complete-first-walk | ✓ / ✓ | 75 | Thẻ mời 2-week check (việc kế tiếp quan trọng nhất) bị cắt ở "Later"; Done ghim cạnh tranh với "Let's do it". | I | CompleteView.swift:38-106 |
| 26 | complete-check-invite | ✓ / ✓ | 75 | Như 25 (cùng trạng thái). | I | như trên |
| 27 | complete | ✓ / ✓ | 55 | Bưu thiếp mới dưới mép; chấp nhận được vì Done ghim. | M | CompleteView.swift:77-82 |
| 28 | today | ✓ / ✓ | 60 | Feed, cuộn là bình thường; nhưng nút Start ở y≈535 (11) và ≈600 trên SE: chào + dòng cây + dải chương trình chiếm 180 pt trước thẻ buổi tập. | I | TodayView.swift:19-28; TodayCards.swift:257-292 |
| 29 | today-program | ✓ / ✓ | 60 | Như 28. | I | như trên |
| 30 | today-check-due | ✓ / ✓ | 70 | Thẻ "2-week check is ready" dưới Start: hợp lý; có 2 nút chính gần nhau (Start / Start my check). | M | TodayCards.swift:303-330 |
| 31 | today-done | ✓ / ✓ | 55 | Tốt; thẻ xanh "Done for today" rõ. | — | TodayCards.swift |
| 32 | today-new | ✓ / ✓ | 50 | "Your first walk" + Start cao: tốt. | — | TodayView.swift |
| 33 | today-rest | ✓ / ✓ | 50 | Ngày nghỉ nói tích cực: đạt mẫu Mobbin #19. | — | TodayCards.swift |
| 34 | today-swap | ✗ / ✗ | 25 | Tốt. | — | SwapSessionSheet.swift |
| 35 | journey | ✓ / ✓ | 45 | Tốt; "Start today's session" thấy được. | — | JourneyView.swift |
| 36 | journeys | ✓ / ✓ | 30 | Danh sách thẻ tranh; tốt. | — | JourneyListView.swift |
| 37 | progress | ✓ / ✓ | 40 | Số lịch 16 pt (< 17), vùng chạm ngày ~36 pt (chạm mở sheet buổi tập) < 56. | M | ProgressScreen.swift |
| 38 | progress-checks | ✓ / ✓ | 40 | Như 37; biểu đồ 2-week check dưới mép. | M | ProgressScreen.swift |
| 39 | program | ✓ / ✓ | 80 | 4 giai đoạn + checks; "You're here" ở thẻ đầu: tốt; dòng "isn't medical advice" ở cuối. | M | ProgramView.swift:30-60 |
| 40 | program-finished | ✗ / ✓ | 65 | Đoạn "What next?" 30 chữ; 2 nút rõ. | M | ProgramFinishedView.swift |
| 41 | selfcheck-intro | ✓ / ✓ | 75 | **"How it works" (3 bước) khuất dưới nút ghim** trước một bài kiểm tra thể lực. | I | SelfCheckViews.swift:48-90 |
| 42 | selfcheck-timer | ✗ / ✗ | 20 | Tốt: số to, Stop early, This hurts. | — | SelfCheckViews.swift:107 |
| 43 | selfcheck-count | ✗ / ✗ | 35 | Tốt: −/+ to, câu hỏi tay. | — | SelfCheckViews.swift:173 |
| 44 | me | ✓ / ✓ | 50 | Dài theo thiết kế; nhóm rõ. | — | MeView.swift |
| 45 | me-notifications | ✗ / ✗ | 35 | Tốt. | — | NotificationSection.swift |
| 46 | sound-sheet | ✗ / ✗ | 45 | **Hai slider** cho giọng và nhạc: spec "Tay run: không slider, dùng − / +". | I | SoundControls.swift |
| 47 | outdoor-location-ask | ✗ / ✗ | 45 | Màn mồi quyền vị trí có 2 nút ("Use my location" / "Just count my steps") — xem rủi ro 6.1. | M | OutdoorPrepView.swift:79-95 |
| 48 | outdoor-prep | ✗ / ✓ | 45 | SE: tranh 140 + 4 hàng + mẹo → cuộn. | M | OutdoorPrepView.swift:6-50 |
| 49 | reminder-offer | ✗ / ✓ | 50 | Tốt trên 11; SE cuộn (tranh 150 + lưới + stepper). | M | (sau "Not yet", AppModel+Flows) |
| 50 | all-sessions | ✓ / ✓ | 35 | Hàng cuộn ngang, thẻ thứ ba bị cắt một nửa; cuộn ngang khó phát hiện với người lớn tuổi; chữ phút 15 pt. | I | AllSessionsView.swift; SessionTile.swift |

Tổng: 3 C · 11 I · 20 M · 16 không có vấn đề. Cuộn trên iPhone 11: 21/50; trên SE: 31/50.

Nhận xét chung về tâm lý và sức khoẻ người dùng 58–75:
- **Mệt / tải nhận thức:** onboarding đọc 400–450 chữ trước paywall (10 màn); plan 110 chữ; paywall 95 chữ. Người mới thường bỏ cuộc ở màn dài nhất, tức ngay trước lúc trả tiền.
- **Sợ ngã / đau khớp:** các lựa chọn liên quan (unsteady, dizzy, None) lại là thứ bị giấu; câu bác sĩ 28 chữ 15 pt ở màn body là đúng chỗ nhưng nhỏ.
- **Ngại, thiếu tự tin:** giọng HLV đáp sau mỗi câu là điểm mạnh nhất của onboarding hiện tại (giữ), nhưng nó đẩy nút đi nên gây bối rối "bấm đâu tiếp".
- **Lo tiền:** paywall và trial timeline trung thực, nhưng người chọn "I was charged…" không thấy app ghi nhận điều đó trên paywall (câu trả lời không dùng lại).
- **Mắt và tay:** chữ ≥ 17 pt, nút 56–60 pt, tương phản đạt; trừ slider (46), số lịch (37), chữ phụ 15 pt dùng cho hướng dẫn (18), cuộn ngang (50).

## 2. Nguyên tắc thiết kế cho người 58–75 (nguồn, ngày)

| # | Nguyên tắc | Áp dụng ở đây | Nguồn |
|---|---|---|---|
| 1 | Một việc mỗi màn, hành động chính luôn trong tầm mắt, không phụ thuộc cuộn | Nút ghim đáy ở mọi màn hỏi; mọi lựa chọn phía trên nút trên SE | Nielsen Norman Group, "Usability for Seniors: Challenges and Changes" (2019; đọc lại 08/10/2026): người lớn tuổi đọc chậm hơn, ít cuộn, hay bỏ sót nội dung dưới mép |
| 2 | Ít lựa chọn → quyết nhanh hơn | ≤ 7 lựa chọn, nhãn ≤ 4 chữ, có lối thoát "Not sure" | Hick (1952); mẫu Mobbin A3 (Ro, Ada) 02/10/2026 |
| 3 | Chữ ≥ 17 pt, tương phản ≥ 4.5:1, vùng chạm ≥ 44 (app: 56) | Giữ token hiện có; sửa 4 chỗ vi phạm (mục 1) | Apple HIG Typography/Accessibility (08/10/2026); WCAG 2.2 1.4.3, 2.5.8 (10/2023); luật dự án CLAUDE.md |
| 4 | Không slider, không vuốt, không giữ lâu | Sound sheet → − / +; All sessions → lưới xuống dòng | Spec màn hình mục "Quy tắc 50+" (28/09/2026) |
| 5 | Bố cục ổn định: nội dung mới không được đẩy nút | Ô HLV cố định 2 dòng dưới tiêu đề; câu đáp thay dòng gợi ý trong cùng ô | uxpeak "design for the system" (docs/research/ui-redesign-uxpeak-2-video.md) |
| 6 | Cho trước, xin sau (reciprocity) và tự tay dựng kế hoạch (endowment) | Nghe HLV 10 s trên thẻ Day 1; "Your plan, Margaret" dựng từ câu trả lời; quyền hỏi sau buổi đầu | uxpeak 6 nguyên tắc (docs/research/ux-psychology-uxpeak-6-nguyen-tac.md); Chillio 06/10/2026 mục 4.4 "được phép chép" |
| 7 | Không bắt đầu từ 0 (goal gradient) | Bước 1 of 7 có người đi đã rời vạch; Complete ghi "1 of 7 active days" | Mobbin UX rules (02/10/2026) |
| 8 | Lời lẽ trung thực: không số bịa, không đếm ngược, không tội lỗi, không nhãn tuổi | Giữ nguyên; thêm: không hứa "better balance" ngoài phạm vi steady-claims | app-context Tone & copy; docs/design/steady-claims.md (08/10/2026) |
| 9 | An toàn đứng trước: câu bác sĩ, ghế vịn, dừng khi đau | Câu bác sĩ ở màn "Anything else"; chip unsteady luôn thấy | PAR-Q+ Q3, World Falls Guidelines 2022 (đã dùng trong app 06/10/2026) |
| 10 | Màn mồi quyền: lý do bằng giọng app, trước hộp thoại hệ thống, mỗi quyền một màn | Tách Permissions thành 2 màn | Apple HIG Privacy › Pre-alert screens (đọc 07/10/2026, docs/reviews MeowBreath) |
| 11 | Tiếng Việt dài hơn 20–30% | Ngân sách chữ tính theo tiếng Anh; phải chụp lại bản Việt cùng khung | docs/i18n/README.md (02/10/2026) |

## 3. Onboarding mới

**Khung chung mọi màn hỏi** (cao dùng được trên SE ≈ 647 pt):
- Trên (≈ 70): "Back" có chữ · "Step n of 7" · đường đi uốn với người đi (giữ từ 03/10, mỏng 22 pt).
- Tiêu đề New York ≤ 8 chữ, ≤ 2 dòng (≈ 68). Ô cố định 2 dòng (≈ 50): lúc đầu là dòng gợi ý ≤ 15 chữ; sau khi chọn, thành mặt HLV + câu đáp ≤ 14 chữ. Nội dung dưới không dịch chuyển.
- Giữa (≈ 345): tối đa 7 lựa chọn; hàng đơn 64 pt hoặc lưới 2 cột 64–72 pt; chip 56 pt; viền chọn 3 pt + dấu tick; chữ 18–19 pt semibold.
- Đáy (≈ 80): một nút chính 60 pt ghim; link "Skip" 48 pt chỉ ở màn tên. Không tự chuyển màn, không thanh tải giả, mọi chuyển động < 0,6 s (giữ quyết định 03/10).
- Câu HLV đáp: ấm, ngắn, nói việc app sẽ làm, không hứa sức khoẻ; mỗi lựa chọn một câu; hiện ≤ 0,4 s sau khi chạm; VoiceOver đọc một lần.

| Bước | Mục đích | Nội dung (EN) | Số chữ (tiêu đề / gợi ý / đáp) | Điều khiển | Dùng lại câu trả lời ở đâu |
|---|---|---|---|---|---|
| 0 Welcome | An toàn trong 5 giây | GOOD FOOTING · "Steadier on your feet, at your own pace." · 12 weeks, 5–10 minutes a day · Every move has a seated version · Follow the voice, no need to watch · [Let's begin] · Restore purchase | 8 / 3×≤7 / — | Nút chính + link nhỏ; tranh 200 pt (SE) / 250 (11), video lặp 3,3 s | — |
| 1 Goal | Một mục tiêu để nói chuyện cả app | "What matters most to you?" · 7 ô: Less pain · Steadier feet · Up from chairs · More energy · Keep up with grandkids · Lose some weight · Not sure yet, just start · Đáp ví dụ: "Steadier it is. Balance moves keep a chair beside you." | 5 / — / 9 | Lưới 2 cột, ô cuối trải hết hàng; chọn 1 (**ĐỔI QUYẾT ĐỊNH CŨ**: spec S02 "Pick up to 2") | Tiêu đề phụ màn Plan ("For steadier feet"), dòng lợi ích đầu của paywall, thẻ Day 1 trên Today, câu thông báo tuần 1 |
| 2 Barriers | Thấu hiểu + chọn thông điệp | "What got in the way before?" · My joints hurt · Videos go too fast · No time for me · I got bored · Surprise charges · Didn't know where to start · Gợi ý "Pick any that fit. No judgment." · Đáp theo lựa chọn đầu, lấy từ S04 rút gọn: "Sore knees don't stop you here. Every move has a seated version." / "No surprises: you'll see the exact date before any charge." | 6 / 7 / ≤ 14 | Lưới 2 cột 6 ô, chọn nhiều (**ĐỔI QUYẾT ĐỊNH CŨ**: bỏ màn S04 "You're not alone"; tranh bạn bè chuyển sang màn Apple Health) | 2 dòng "why" trên Plan; thứ tự lợi ích paywall (charged → dòng thời gian lên đầu, bored → journeys); câu thông báo tuần 1 |
| 3 Name | Endowment, chào đúng tên | "What should we call you?" · ô nhập, bàn phím mở sẵn · "Only to say hello. It stays on this phone." · Đáp "Nice to meet you, Margaret." · [Continue] · Skip | 5 / 9 / 5 | Ô nhập 64 pt, Return = Continue | "Your plan, Margaret" · "Good morning, Margaret" · "You did it, Margaret!" |
| 4 Chair | Cấp bắt đầu + bài ghế đầu + thang số lần | "Standing up without your hands is…" · Not possible right now · Hard, but I can · Easy · Gợi ý "This picks your first chair moves." | 6 / 6 / (không đáp, chỉ tick) | 3 hàng 64 pt (**ĐỔI QUYẾT ĐỊNH CŨ**: bỏ S05b "How active are you now?"; `startLevel` = Easy ∧ không có standingIsHard/unsteady → In place, còn lại Seated) | `startLevel`; bài sit-to-stand đầu 6/8; thẻ Day 1 "Seated · march in your chair"; kỳ vọng 2-week check |
| 5 Sore spots | Lọc bài theo khớp | "Any sore spots?" · Knees · Hips · Lower back · Shoulders · Joint replacement · None of these · Gợi ý "Tap all that apply." · Đáp "Got it. We'll go easy on your knees." | 3 / 4 / ≤ 12 | Lưới 2 cột 6 chip 56 pt, None luôn thấy (**ĐỔI QUYẾT ĐỊNH CŨ**: S06 tách làm 2 màn) | Chip trên Plan và Me; biến thể Joint replacement; lọc bài |
| 6 Anything else | Giới hạn hằng ngày + an toàn | "Anything else we should know?" · Can't get down on the floor · Standing long is hard · I get dizzy easily · I feel unsteady on my feet · No jumping · None of these · Câu bác sĩ 24 chữ 15 pt ngay trên Continue · Đáp "Thanks. Balance moves will keep both hands on the chair." | 5 / — / 10 | Lưới 2 cột 6 chip; caption bác sĩ cố định | Steady set bản ngồi, cue hai tay, Seated bắt đầu, bậc vịn |
| 7 Plan | Thấy kế hoạch của mình, nếm thử | "Your plan, Margaret" · "For steadier feet. Built from your answers." · Thẻ: "5–10 min a day, 12 weeks · Starts Seated · Sat & Sun are rest days" + tuần 7 ô + dòng giới hạn · Thẻ Day 1: "Your first walk · 5 min · Seated · march in your chair" + **[▶ Hear your coach · 10 seconds]** · 2 dòng ✓ theo barriers · [See my options] | 3 / 7 / — | Nút play 56 pt phát 1 câu thật từ A1 First Walk (giọng Bella đã có trong bundle, cả EN và VI); không thanh tải | Tất cả câu trước gom ở đây; thẻ Day 1 lặp lại trên Today |
| 8 Paywall | Minh bạch tiền | "Good Footing Pro, free for 14 days" · 3 dòng ✓ (dòng đầu theo goal) · dòng thời gian Today / Oct 20 nhắc / Oct 22 thu $39.99 · 3 gói (năm chọn sẵn, giá thu to nhất, "lowest per month" chỉ khi đúng) · "Or keep the free plan…" · [Start my free trial] · điều khoản tự gia hạn · Maybe later · Restore · Terms · Privacy | 6 / — / — | Footer ghim; trên SE cả 3 gói còn trong tầm mắt (xem mockup) | Dòng lợi ích đầu theo goal; thứ tự theo barriers (phối hợp với tài liệu cá nhân hoá) |

Sau onboarding (không đổi luồng): Phone placement → Up next → First Walk → Complete (thẻ mời 2-week check đứng ngay sau "How did that feel?") → **Reminder (S16a)** → **Apple Health (S16b)** → Today. Hai màn quyền cùng khung, mỗi màn một quyền, một nút chính + "Not now".

Vì sao bỏ/gộp:
- S04 You're not alone: không hỏi gì, 45 chữ, thêm 1 chạm; nội dung chính (câu thấu hiểu) sống tốt hơn ở ngay khoảnh khắc chạm chọn (Chillio: "lắng nghe" ngay sau câu trả lời).
- S05b How active: chỉ dùng để cộng điều kiện `active` vào `startLevel` (OnboardingProfile.swift:51-53); bỏ thì người "Easy" không giới hạn đứng bắt đầu In place 5 phút, có sẵn cơ chế lùi cấp ("We moved you back to Seated").
- Goal chọn 1: câu trả lời chỉ dùng để nói chuyện (tiêu đề phụ, dòng đầu paywall, thông báo); 2 mục tiêu làm câu nói chung chung; người lớn tuổi quyết 1 việc nhanh hơn.
- Body tách 2: 10 chip + None không bao giờ vừa SE với câu bác sĩ; 2 màn đều, mỗi màn 6 ô, an toàn không bị giấu.

Thứ tự bước: 9 màn (Welcome + 6 câu + Plan + Paywall) thay 10; số chữ trước paywall ≈ 230 (giảm ~45%).

## 4. Ảnh mockup

- Nguồn: `docs/design/research-2026-10-08/onboarding-mockups.html` (mở trực tiếp; `?only=<id>&size=se|i11` để xem một khung). Font: `-apple-system`/SF cho chữ, `ui-serif`/New York cho tiêu đề (Chrome trên Mac thay New York bằng serif hệ thống; trên máy thật là New York). Tranh lấy từ `iOS/App/Assets.xcassets/Art/**`.
- Từng màn (13 màn × 2 cỡ) trong `docs/design/research-2026-10-08/mockups/`: `welcome`, `goal`, `barriers`, `name`, `chair`, `body1`, `body2`, `plan`, `paywall`, `perm-reminder`, `perm-health`, `today`, `complete-first` + hậu tố `-se.png` (375×667 @2x) và `-i11.png` (414×896 @2x).
- Bảng ghép để xem nhanh: `mockups/sheet-1-onboarding-a-se.png` · `-i11.png` (Welcome → Chair), `mockups/sheet-2-onboarding-b-se.png` · `-i11.png` (Sore spots → Paywall), `mockups/sheet-3-after-first-walk-se.png` · `-i11.png` (Reminder, Health, Today, Complete).
- Đã kiểm bằng mắt: không màn nào tràn trên SE ở cỡ chữ mặc định, trừ paywall SE còn dòng "Or keep the free plan…" nằm dưới footer (3 gói, giá, bộ ba link, Maybe later đều thấy). Chữ nhỏ nhất 16 pt (caption, theo font-va-hinh-anh.md), thân 17/19 pt, nút 20 pt trên nút cao 64 pt.
- Chưa vẽ: bản tiếng Việt (chờ font-va-hinh-anh.md), cỡ chữ trợ năng XXL (nút ghim chuyển thành cuộn như code hiện tại), chế độ tối (token đã có bản tối).

## 5. Sửa UI toàn app theo ưu tiên

Ước lượng: S ≤ ½ ngày · M 1–2 ngày · L 3–5 ngày (gồm test + String Catalog EN/VI).

| Ưu tiên | Việc | File | Cỡ |
|---|---|---|---|
| P1 | Khung onboarding chung: luôn ghim Continue (`pinnedActions(true)` trừ cỡ trợ năng), ô HLV cố định dưới tiêu đề thay `CoachNote` dưới danh sách, nhãn "Step n of 7" | OnboardingView.swift:14-50; OnboardingMotion.swift:69-93; OnboardingFlow.swift:46-59 | M |
| P1 | Bước mới: bỏ `.understanding`, `.activity`; thêm `.body2`; goal chọn 1; lưới 2 cột cho goal/barriers; `startLevel` không cần activity (giữ cột `activityLevel` trong schema, không xoá) | OnboardingFlow.swift:9-11, 96-110; QuestionViews.swift; BodyLimitChips.swift:16-17; OnboardingProfile.swift:50-53 + test | L |
| P1 | Plan: gọn 2 thẻ + 2 dòng why; nút "Hear your coach · 10 s" phát câu A1 từ cache giọng qua `AVPlayer` (không phát âm im lặng) | PlanReadyView.swift:16-32, 76-109 | M |
| P1 | Paywall vừa SE: tiêu đề 2 dòng, hàng gói 52–56 pt, timeline 1 dòng/mốc, dòng free plan dưới gói; dòng lợi ích đầu theo goal | PaywallView.swift:26-52, 72-90, 150-209; PaywallModel.swift | S |
| P1 | Tách Permissions thành 2 màn (Reminder · Apple Health), cùng khung, mỗi màn 1 nút + Not now | PermissionsView.swift:14-78; AppModel+Flows.swift (điều hướng) | M |
| P1 | Self-check intro: "How it works" lên trên "Before you start" hoặc gộp 4 gạch đầu dòng ≤ 8 chữ để vừa trên nút ghim | SelfCheckViews.swift:48-90 | S |
| P1 | Welcome: tranh cao theo màn (`containerRelativeFrame` hoặc `GeometryReader` tỉ lệ 0,3–0,32 chiều cao), tối đa 260 | WelcomeView.swift:47-62 | S |
| P2 | Today: gộp dòng cây + dải chương trình thành một dòng dưới lời chào ("13 active days · Week 3 of 12 · Plan ›") để Start lên nửa trên màn | TodayView.swift:19-28; TodayCards.swift:257-292 | S |
| P2 | Complete buổi đầu: thẻ mời 2-week check ngay sau "How did that feel?", dòng cây + journey gộp 1 caption | CompleteView.swift:41-95 | S |
| P2 | Sound sheet: thay slider bằng − / + (5 nấc) theo spec "không slider" | SoundControls.swift | S |
| P2 | All sessions: hàng cuộn ngang → lưới 2 cột xuống dòng; phút 17 pt | AllSessionsView.swift; SessionTile.swift | M |
| P2 | Preview: bỏ tranh 140 pt khi danh sách > 4 phần; "Swap" là nút 56 pt | WorkoutPreviewView.swift:24-26, SegmentList | S |
| P2 | Phone placement / Outdoor prep / Reminder offer vừa SE: tranh 110–120 pt, thẻ 100 pt | PhonePlacementView.swift:92+; OutdoorPrepView.swift:6-50 | S |
| P2 | Chair player: "Tap +1 each time you stand" lên 17 pt, màu text | ChairPlayerView.swift | S |
| P3 | Progress: số lịch ≥ 17 pt, ô ngày ≥ 44 pt (lịch 7 cột vẫn vừa 335 pt) | ProgressScreen.swift | S |
| P3 | Program finished: đoạn "What next?" → 2 gạch đầu dòng | ProgramFinishedView.swift | S |
| P3 | Program: dòng "isn't medical advice" lên dưới tiêu đề (1.4.1 thấy ngay) | ProgramView.swift:45 | S |
| P3 | Today check-due: khi check đến hạn, thẻ check đứng trên thẻ buổi tập hoặc gộp "Start my check" vào thẻ buổi tập để chỉ còn 1 nút chính | TodayView.swift:36-38 | S |
| P3 | Chụp lại 50 trạng thái ở SE 3 + XXL + tiếng Việt sau khi sửa; thêm trạng thái `onboarding-body2`, `permissions-health` vào CaptureHook | CaptureHook.swift:10-18 | S |

## 6. Rủi ro App Review

| # | Rủi ro | Mức | Xử lý |
|---|---|---|---|
| 6.1 | Màn mồi quyền có nút thứ hai ("Not now" ở Reminder/Health; "Just count my steps" ở vị trí) — HIG Pre-alert screens khuyên một nút; có ca bị từ chối 5.1.1(iv) (forum 03/2026) với màn vị trí | Trung bình-thấp (vị trí) · thấp (thông báo, Health) | Giữ theo luật dự án; viết Review Notes "every permission is optional, app fully usable after Don't Allow"; phương án B: màn vị trí còn một nút "Continue" → hộp thoại iOS, "Just count my steps" chuyển thành kết quả của Don't Allow |
| 6.2 | 1.4.1 lời hứa sức khoẻ: "Balance sessions for steadier feet", "stronger legs and better balance" (Welcome hiện tại) | Thấp | Chạy `tools/lint/copy_lint.py` + steady-claims lint trên mọi chuỗi mới; "steadier" trong danh sách nên dùng; không viết "prevent falls", "improve balance" như kết quả |
| 6.3 | 3.1.2: paywall SE hiện tại giấu gói thứ ba, mockup mới sửa; "lowest per month" chỉ khi StoreKit chứng minh | Thấp | Giữ `isLowestMonthly`; giá, kỳ hạn, điều khoản tự gia hạn dưới nút như hiện nay |
| 6.4 | "Hear your coach" phải là nội dung thật, không phải demo giả; không chơi audio nền khi chưa tập | Thấp | Phát qua `AVPlayer` thường, không bật background audio ở onboarding |
| 6.5 | Thu thập dữ liệu: tên chỉ lưu máy; không hỏi tuổi/giới; câu hỏi khớp là tình huống chứ không chẩn đoán | Thấp | Giữ PrivacyInfo + Privacy Policy như hiện tại; không đưa câu trả lời onboarding ra ngoài máy |
| 6.6 | Trial: hứa "We'll remind you Oct 20" — app phải gửi (ngày 12) kể cả khi không có quyền thông báo (thẻ Today từ ngày 10) | Thấp | Đã có quyết định 29/09 (I1); kiểm tra lại khi bỏ màn Permissions cũ |

## 7. Câu hỏi cho chủ app
1. Chốt 4 đề xuất ĐỔI QUYẾT ĐỊNH CŨ: (a) chọn 1 mục tiêu; (b) bỏ màn "You're not alone"; (c) bỏ "How active are you now?"; (d) tách màn cơ thể thành 2. Nếu giữ (c), onboarding là 10 màn, vẫn vừa SE.
2. Giữ "Lose some weight" trong 7 mục tiêu? (nhóm nhạy giá nhất; app không theo dõi cân nặng; có thể gộp với "More energy").
3. "Hear your coach · 10 seconds": dùng câu nào của A1 First Walk (đề xuất 2 câu mở đầu), có cho nghe cả bản tiếng Việt không?
4. Câu bác sĩ: để ở màn "Anything else" (đề xuất) hay lặp lại trên Plan?
5. "Not now" trên 2 màn quyền và "Just count my steps" ở vị trí: giữ theo luật dự án hay đổi sang một nút như HIG (6.1)?
6. iPhone SE 2/3 có là máy mục tiêu không? Nếu không, mức C/I cho các màn chỉ cuộn trên SE hạ xuống M.
7. Dòng lợi ích đầu của paywall theo mục tiêu và thứ tự theo rào cản: chờ tài liệu cá nhân hoá hay làm luôn trong đợt này?
8. Đã có simulator iPhone 11 tạm; cần tạo thêm SE 3 để chụp lại 50 trạng thái sau khi sửa (hạn mức 2 simulator → xoá iPhone 17 Pro Max hoặc iPhone 11 tạm trước)?
