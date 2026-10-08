# Cá nhân hoá — hiện trạng, khoảng cách, lộ trình (08/10/2026)

_Nghiên cứu và đề xuất, không sửa code. Đọc: CLAUDE.md, app-context.md, plans/2026-10-08-steady-program.md, research/2026-10-04-*, reviews/2026-10-06-chuyen-gia-ra-soat-bai-tap-58-75.md, toàn bộ `GentleWalkCore/Plan`, `Content`, `Program`, `Progress`, `Safety`, `Notifications`, và app: Onboarding, Today, Root, Workout, Progress, Services. Số dòng theo mã ngày 08/10/2026 (commit f109cc2). Nguồn web ghi ngày truy cập 08/10/2026; con số doanh thu/đánh giá là ước tính._

## 0. Tóm tắt 5 dòng
1. App hỏi 7 thứ lúc onboarding và thu 9 tín hiệu khi tập, nhưng chỉ **giới hạn cơ thể** và **check-in Achy/Okay/Great** thực sự đổi buổi tập hằng ngày; hai thang (vịn, số lần) chạy tốt nhưng Pro. Mức cá nhân hoá hiện tại: **2,5/5**.
2. Tín hiệu bị bỏ phí: **mục tiêu (goals)**, **"How did that feel?"** (có lỗi: không bao giờ hạ cấp sau khi lên, thẻ "lên cấp" không hiện), **Easier/Harder** (không lưu), **vùng đau theo bài** (lưu nhưng không đọc), **kết quả tự kiểm tra** (chỉ vẽ biểu đồ), **bước Apple Health** (chỉ hiện), **7 câu thoại đã thu** (a9.gentle/steady/strong, a9.back.1–2, a9.shorter, a9.levelup/leveldown) chưa được đặt vào buổi nào.
3. YouTube miễn phí không nhớ gì về bà ấy; đối thủ trả tiền (LazyFit, ChillFit, Bend, SilverSneakers GO, Bold) cá nhân hoá chủ yếu **ở quiz lúc vào** và **bộ lọc thủ công**, gần như không học từ hành vi sau đó. Fitbod (ngoài ngách) là mẫu "học từ mỗi buổi" đáng tham khảo.
4. Lộ trình: **đóng tín hiệu chết trước** (6 việc cỡ S, không cần thu âm), rồi check-in tuần đổi tuần sau, HLV nhắc lại lịch sử của bà ấy bằng ghép đoạn, màn "kết quả của bạn". Tất cả trên máy, không tài khoản, không bảng chuẩn.
5. Top 8 theo tác động/chi phí: nói check-in bằng giọng · sửa vòng "How did that feel?" · nhớ chỗ đau theo bài · nhắc lại mục tiêu · nhớ Easier/Harder · check-in tuần · câu HLV theo lịch sử · màn "kết quả của bạn". 6/8 miễn phí.

## 1. Hiện trạng cá nhân hoá

### 1.1 Bảng tín hiệu → tác động

| # | Tín hiệu | Lưu ở đâu | Đổi gì hôm nay | Dùng lại sau không | Chấm |
|---|---|---|---|---|---|
| 1 | **Goals** (S02, tối đa 2) | `UserProfile.goals` (SchemaV2.swift:19; ghi OnboardingFlow.swift:139) | Chỉ câu HLV đáp ngay lúc chọn (OnboardingCopy.swift:157–166) | **Không.** Không chỗ nào đọc `goals` sau onboarding (grep toàn app) | 0 |
| 2 | **Barriers** (S03) | `UserProfile.barriers` | Màn S04 theo barrier đầu (OnboardingProfile.swift:54, 58; OnboardingCopy.swift:53–67) + 2–3 dòng "Why this will work" (OnboardingProfile.swift:55–56) | **Không** sau onboarding | 1 |
| 3 | **Name** | `UserProfile.name` | Chào theo giờ (TodayModel.swift:203–212), Welcome back (:239–242), tiêu đề Complete + câu chia sẻ (CompleteContent.swift:45–51, 78–81), "Your plan, Margaret" (PlanReadyView.swift:19–20). HLV không gọi tên (luật) | Có, chỉ chữ | 3 |
| 4 | **Activity + Chair answer** (S05b/c) | `activityLevel`, `chairAnswer`, `startLevel` | Chỉ quyết **cấp đi bộ khởi điểm**: In place khi "walk most days/exercise regularly" + chair "Easy" + không standingIsHard/unsteady, còn lại Seated (OnboardingProfile.swift:51–53) | `startLevel` **không bao giờ được cập nhật** (không có lệnh ghi nào ngoài onboarding) nhưng là gốc của Adaptation mỗi ngày (AppModel.swift:183 → TodayModel.swift:141) | 2 |
| 5 | Stairs answer | cột `stairsAnswer` | Không (bỏ câu hỏi 01/10, giữ cột) | — | — |
| 6 | **Body limits** (S06, 10 chip, sửa được ở Me: MeSections.swift:447–461) | `UserProfile.bodyLimits` | Ẩn bài (`hiddenFor`) và bật bản dễ (`easierFor`): BodyLimitFilter.swift:4–11, SessionBuilder.swift:33, 81–82; bỏ segment/cue `onlyFor/notFor` (SessionTemplate.swift:33–35, 51–53; SessionBuilder.swift:122–126, 134–137); câu thoại `hiddenFor` (VoiceLine.swift:31–34); đổi bộ bài ghế khi standingIsHard/dizzy (ChairSessionPlanner.swift:53, 62–74) và thế bài bị ẩn bằng bài ngồi (:78–84); steady set bản ngồi (SessionBuilder.swift:17); giãn cơ ngồi/đứng (:68); dizzy/unsteady → luôn 2 tay (SupportLadder.swift:64) và trần số lần (RepLadder.swift:70); ghi chú dưới tips (ChairPlayerModel.swift:106); lọc Everyday wins (AppModel.swift:204–207) | Có, mọi buổi | **5** |
| 7 | **Check-in Achy/Okay/Great** | Chỉ trong `TodayModel.checkedIn` (TodayModel.swift:214–217); ghi `WorkoutRecord.intensity` (SessionCompletionService.swift:79) | → `Intensity` (TrainingTypes.swift:23–29): pace walk (SessionBuilder.swift:43), bộ bài + nghỉ ngày ghế (ChairSessionPlanner.swift:15, 50–76), giữ giãn 20/30 s (TrainingTypes.swift:34–39), steady set theo cường độ (Pro, SessionBuilder.swift:16–18), trần thang vịn (SupportLadder.swift:53–58), bậc mặc định số lần (RepLadder.swift:54–61), tiêu đề Today (TodayModel.swift:400–405), phụ đề preview (WorkoutPreviewModel.swift:94–99) | `intensity` trên record **không ai đọc lại**; mất khi `reload()` dựng TodayModel mới (AppModel.swift:194). HLV **không nói** gì về check-in dù đã thu a9.gentle/steady/strong (không template nào trong sessions.json dùng) | 4 |
| 8 | **Break** | `breakCount` (WorkoutSessionModel.swift:154–158) → record | ≥2 lần buổi trước → buổi sau ngắn hơn 2 phút + thẻ "shorter" (Adaptation.swift:42–45; TodayModel.swift:309; SessionPlan.shortened). Pro: bài đang làm vào `troubledExercises` (:155, 286–287) → hạ bậc vịn/số lần (SupportLadder.swift:91–96; RepLadder.swift:84–87). "Longest walk without a break" (Snapshots.swift:134–136) | Có | 4 |
| 9 | **This hurts** (vùng + bài) | `PainReport(area, exerciseID)` (ThisHurtsModel.swift:95–100; SwiftDataPainRecorder.swift:13–16) | Trong buổi: bản dễ hoặc bỏ (ThisHurtsModel.swift:60–76). Cùng **vùng** ≥3 lần/7 ngày → thẻ Today + ép Seated (PainRules.swift:35–46; TodayModel.swift:245, 308). Pro: hạ bậc bài đó (noteTrouble :166). Không hỏi review hôm có đau (AppModel+Flows.swift:282) | `exerciseID` **lưu nhưng không đọc** (PainRules chỉ nhóm theo area). Buổi sau bài đó vẫn ở bản thường | 2,5 |
| 10 | **Easier / Harder** (player ghế, giãn) | Không lưu | Easier: đổi clip/câu trong buổi (ChairPlayerModel.swift:115–118; StretchPlayerModel.swift:118). Harder: **chỉ bật dòng chữ** `exercise.harder`, không đổi âm thanh (ChairPlayerModel.swift:121–124) | **Không** | 0 |
| 11 | **"How did that feel?"** | `WorkoutRecord.feeling` (WorkoutSessionModel.swift:309–313; SessionCompletionService.swift:99–104) | 3 lần liền cùng đáp ở cùng cấp → đổi **cấp đi bộ** (Adaptation.swift:46–56; TodayModel.swift:139–141, 245). Hiện trong lịch sử buổi (SessionHistoryItem.swift:79) | **Nửa chết**: (a) chỉ đổi cấp đi bộ, không đổi cường độ, số lần, độ dài; (b) lọc `history.filter { $0.level == level }` với `level = startLevel` không đổi → sau khi lên In place, mọi "Too hard" ở In place bị bỏ qua, **không bao giờ hạ về Seated bằng feeling**; (c) `.movedUp` không có trong `specialCard` (TodayModel.swift:307–315) → lên cấp **im lặng**; a9.levelup/leveldown/shorter đã thu, chưa dùng; (d) "Too easy" ở In place không làm gì (`harder` = nil, TrainingTypes.swift:16) | 1,5 |
| 12 | **Thang vịn** (Pro) | `supportLadder` UserDefaults (SupportLadderStore.swift) | 2 tay → 1 tay → đầu ngón, lên sau 2 buổi giữ đủ, xuống khi This hurts/Break (SupportLadder.swift:86–109); thay câu tay (SessionBuilder.swift:139–141); HLV báo đổi bậc (a11.ladder.*); "Next time…" trên Complete (SteadyProgramText.swift:61–83); thẻ Progress (ProgressScreen.swift:233–275) | Có | 4 (Pro) |
| 13 | **Thang số lần** (Pro) | `repLadder` UserDefaults (RepLadderStore.swift) | 3 bài: sit-to-stand, mini-squat, side-leg; bậc tăng sau 2 buổi đủ, trần = bậc cường độ +1 (RepLadder.swift:65–73); segment thu sẵn theo bậc (SessionBuilder.swift:104–109); nhãn "2 × 8" (ChairPlayerModel.swift:88–91) | Có. Free: số lần cố định theo cường độ | 4 (Pro) |
| 14 | **Tự kiểm tra 2 tuần** | `SelfCheckRecord` | Lịch/nhắc (SelfCheck.swift:37–52; NotificationPlanner.swift:120–123), biểu đồ + "+N since first" (ProgressScreen.swift:181–229), tổng kết 12 tuần (AppModel+Program.swift:109–115) | **Không đổi buổi tập nào** (SessionBuilder/RepLadder không đọc) | 1 |
| 15 | **Bước Apple Health** | đọc mỗi lần mở Progress (HealthService.swift:61–70) | Thẻ "All-day steps" tuần này/tuần trước | Không đổi gì | 1 |
| 16 | **Lịch sử buổi tập** (ngày, giây, loại) | `WorkoutRecord` | Ngày hoạt động → cây, `rotationIndex` xoay bài và biến thể câu (TodayModel.swift:301–305; VoiceRotation.swift); nghỉ ≥2 ngày kế hoạch → "Gentle restart 5 min" (WelcomeBack.swift:12–23); thông báo nhắc/quay lại/tổng kết (NotificationPlanner.swift:139–178); 5 ngày tập sớm hơn giờ nhắc → đề nghị bớt nhắc (:181–193); nghỉ ≥14 ngày → "Pick up at week N" (ProgramCalendar.swift:51–56) | Có | 3,5 |
| 17 | **Giờ nhắc / tần suất** | `reminderMinutes`, `reminderFrequency` | Giờ nhắc; nhắc mỗi ngày hoặc sau 2 ngày im | Giờ bà ấy **thật sự** tập không được dùng để dời giờ nhắc (chỉ dùng để bớt nhắc) | 2 |
| 18 | **Lựa chọn ở Preview** | `lastWorkoutPlace` lưu; `level` và `swaps` **không** (WorkoutPreviewModel.swift:21, 25, 49) | Buổi đó | Nơi tập được nhớ; cấp và bài đã đổi **quên ngay** | 1,5 |
| 19 | Số sit-to-stand trong buổi (tay/cảm biến) | `WorkoutRecord.sitToStandCount` | Hiện trên Complete | Không hiện ở Progress (đã thay bằng biểu đồ tự kiểm tra), không đổi gì | 1 |
| 20 | Favourites, Everyday wins | UserDefaults / `EverydayWin` | Danh sách All sessions; tick ở Progress | Không gợi ý gì từ đó | 1 |
| 21 | **Free / Pro** | StoreKit | Nhịp tuần (WeeklyPlanner.swift:47–51), ngày nghỉ (ActivityCalendar.swift:25–27), 2 thang (AppModel+Flows.swift:148–153), steady set gentle vs theo cường độ, khoá swap/extras | — | — |

### 1.2 Chấm chung: 2,5/5
- Làm tốt: giới hạn cơ thể lọc tới từng câu thoại; check-in đổi đúng 5 thứ; hai thang theo khả năng đúng Otago "2 × 10 mới tăng".
- Yếu: hầu hết tín hiệu **sau onboarding** đi vào kho rồi nằm im. Không có "trí nhớ" theo bài (đau, dễ/khó), không có vòng tuần, kết quả tự kiểm tra không quay lại kế hoạch, HLV không bao giờ nói điều gì về hôm qua ngoài 3 câu thang vịn.
- Lời hứa đã in trên S07 "We start you at the right level and **adjust after every session**" (OnboardingCopy.swift:78) hiện chỉ đúng với Break và ladder Pro.

## 2. Tín hiệu đang bị bỏ phí (ưu tiên đóng trước)

| Tín hiệu | Tình trạng | Việc tối thiểu để dùng |
|---|---|---|
| Goals | lưu, không đọc | Mục 4, P4 |
| "How did that feel?" | lọc theo `startLevel` cố định → chỉ lên không xuống; thẻ lên cấp không hiện; không đổi cường độ/số lần | P2 |
| Easier / Harder | không lưu; Harder không làm gì | P5 |
| This hurts `exerciseID` | lưu, không đọc | P3 |
| Check-in (`intensity` trên record) | ghi, không đọc | P2 (mặc định check-in hôm sau), P6 |
| Tự kiểm tra | chỉ biểu đồ | P9 |
| Bước Apple Health | chỉ thẻ | P11 (thấp) |
| Cấp và bài đổi ở Preview | quên ngay | P12 |
| 7 câu thoại đã thu, chưa đặt vào buổi | a9.gentle · a9.steady · a9.strong · a9.back.1 · a9.back.2 · a9.shorter · a9.levelup · a9.leveldown (voice-lines.json; không có trong sessions.json, không có trong Swift) | P1 — chi phí gần 0 |
| Cột `stairsAnswer` | giữ cho Fitness Check phase 2 | — |

## 3. So với YouTube và đối thủ

### 3.1 YouTube miễn phí (yes2next, More Life Health, Grow Young Fitness, HASfit, Eldergym, Walk at Home…)
Mạnh: thư viện lớn, HLV thật, miễn phí, có cộng đồng; More Life Health một video ghế 30 phút ~1,9 triệu lượt xem; Grow Young Fitness đã có app trả phí riêng (App Store id6466878352, 4,0★/43 đánh giá) — [tìm kiếm 08/10/2026](https://apps.apple.com/app/id6466878352). yes2next → app Get Moving 50+ trên Studio.com (docs/research/2026-10-07-yes2next.md).

Một kênh YouTube **không thể**:
1. Nhớ bà ấy: không biết gối đau, không biết hôm qua bấm Break, không biết đang ở tuần mấy.
2. Lọc bài theo giới hạn cơ thể tới từng câu nói (app: `hiddenFor`, `onlyFor/notFor` ở cấp cue).
3. Đổi số lần, mức vịn, độ dài **theo bà ấy** giữa hai lần xem; video 10 phút hôm nay giống hôm qua.
4. Phản ứng "This hurts" ngay trong bài (đổi bản dễ, bỏ bài, ghi nhớ).
5. Tự kiểm tra 2 tuần có lịch, có biểu đồ so với chính mình.
6. Dẫn bằng giọng khi điện thoại trong túi (video bắt nhìn màn hình).
7. Biết bà ấy đã nghỉ 2 tuần và mở lại bằng 5 phút nhẹ, không phạt.

Nhưng YouTube **có** thứ app chưa có: HLV nói chuyện như người quen ("tuần trước mình đã…"), bình luận của người cùng tuổi, series theo tuần có cốt truyện. → Đề xuất P7 (câu HLV theo lịch sử) và P6 (check-in tuần) lấy lại cảm giác "được biết đến" mà không cần người thật.

### 3.2 Đối thủ trả tiền — họ cá nhân hoá gì

| App | Lúc vào | Trong buổi | Học từ hành vi sau đó | Nguồn (08/10/2026) |
|---|---|---|---|---|
| **LazyFit** (~0,8–1 tr USD/tháng, ước tính) | Quiz chấn thương (gối, lưng) → "Chair exercises are beneficial"; Plan Settings: loại bài, giới hạn, cấp, thời lượng, nơi tập (ghế/giường/thảm/tường) | Video; giọng AI chỉ 15 s "Get ready" | **Không thấy.** Kế hoạch 28 ngày giống nhau mỗi ngày; 18% review 1–2★ chê lặp | docs/research/2026-10-04-tom-tat-thi-truong.md §4.1 |
| **ChillFit** | Sao chép LazyFit: quiz vùng chấn thương → "Knee-Friendly Chair Yoga 28 ngày" | Đếm ngược, giọng bật/tắt | Không thấy | cùng nguồn |
| **Bend** | Routine theo vùng (hông, lưng), tự ghép routine | Tranh + đồng hồ | Streak, nhắc, widget; không đổi nội dung theo phản hồi | cùng nguồn |
| **WalkFit** | Mục tiêu bước, kế hoạch đi bộ | Video + đếm bước | Theo bước, không theo cơ thể; không bản ngồi | cùng nguồn |
| **SilverSneakers GO** (miễn phí qua Medicare Advantage) | 3 mức beginner/intermediate/advanced cho strength/flexibility/walking | Đổi bài **dễ hơn/khó hơn** theo ý người dùng (thông cáo 2018) | Tự xếp lịch tuần (review: xếp quá 1 tuần "không làm được"); ~4,2–4,3★/1,6–1,7 nghìn | [App Store](https://apps.apple.com/app/id1410437380), [flyer 2020](https://www.rsa-al.gov/uploads/files/SilverSneaker_GO_App_Features_Flyer.pdf), [PR 2018](https://prn.to/2Ahe9Cs) |
| **Bold** (agebold, miễn phí qua MA/ACCESS) | Hỏi nền tảng, mục tiêu, sở thích, số ngày/tuần → chương trình 12 tuần, 3 lớp/tuần; có "Assess my fitness" (bài tiểu sử Princeton nói có đo thăng bằng/sức mạnh; FAQ không nói) | Sửa bài theo "mobility, pain, energy on a given day"; HLV đưa biến thể trong lớp | "Bộ lớp mới mỗi tuần"; trang thứ ba nói "re-tune khi tiến bộ" — **chưa xác nhận trên trang Bold**. Claim "giảm 46% nguy cơ ngã" là của Bold | [FAQ](https://www.agebold.com/faq), [About](https://agebold.com/about), [Princeton PAW](https://paw.princeton.edu/article/amanda-rees-12-launches-online-business-help-aging-people-prevent-falls) |
| **Sworkit** | Custom workout thủ công, bộ low-impact (premium), HLV 1-1 | Skip/lặp/tạm dừng | **Không** học từ phản hồi (không nguồn nào nói) | [PeopleKeep](https://www.peoplekeep.com/marketplace/sworkit-health), [KUTV](https://kutv.com/features/studio-guests/the-tech-report-workout-with-sworkit) |
| **Fitbod** (tham chiếu ngoài ngách) | Mục tiêu, kinh nghiệm, dụng cụ | Log set; đổi/ghim bài | **Có, mỗi buổi**: ước 1RM từ set đã log; "recovery" từng nhóm cơ 0–100% tránh cơ vừa tập 48–72 h; Reps-in-Reserve quyết tải buổi sau; Max Effort Day; hoạt động từ Apple Health cộng vào mệt | [fitbod.me/blog/fitbod-algorithm](https://fitbod.me/blog/fitbod-algorithm), [help](https://help.fitbod.me/hc/en-us/articles/360004429814-How-Fitbod-Creates-Your-Workout) (trang help trả 403 khi mở, đọc qua tóm tắt tìm kiếm) |
| **StandingTall** (nghiên cứu, NeuRA, Úc) | Chương trình thăng bằng ">6.000 bài", "programmed to suit the ability of the user", tăng độ khó khi thăng bằng tốt lên | Tablet, lịch tuần, đặt mục tiêu | RCT BMJ 2021: 503 người ≥70, 2 năm; kết quả chính 12 tháng **không** có ý nghĩa thống kê; 24 tháng ngã ít hơn 16%; bám dùng 80% ở 6 tháng, 68% ở 1 năm, 52% ở 2 năm (số của nhóm nghiên cứu) | [BMJ 2021;373:n740](https://www.bmj.com/content/373/bmj.n740), [NeuRA](https://neura.edu.au/project/standing-tall), [PMC8022322](https://pmc.ncbi.nlm.nih.gov/articles/PMC8022322) |

Bằng chứng cá nhân hoá có ích (chỉ tóm tắt tìm kiếm, chưa mở toàn văn): JMIR 2025 e73145, RCT bài tập cá nhân hoá qua smartphone cho người lớn tuổi, cải thiện thăng bằng động và sức mạnh tay so với hai nhóm chứng, có tác dụng ngay cả khi chỉ ~1,5 buổi/tuần trong 8 tuần — [jmir.org/2025/1/e73145](https://www.jmir.org/2025/1/e73145) (trang trả rỗng khi fetch; cần đọc lại trước khi trích). Không tìm thấy RCT 2024–2025 so trực tiếp "app cá nhân hoá" với "app chung" ở người lớn tuổi.

**Kết luận mục 3:** khoảng trống trong ngách là **học từ hành vi sau onboarding**. Mọi đối thủ 50+ dừng ở quiz + bộ lọc; chỉ Fitbod (gym) và StandingTall (nghiên cứu) tăng dần theo kết quả thật. Good Footing đã có hạ tầng (ladders, PainReport, feeling, self-check) nhưng chưa nối dây.

## 4. Đề xuất

### 4.1 Xếp hạng top 8

| # | Đề xuất | Tín hiệu | Giá trị | Chi phí | Free/Pro | Thu âm mới |
|---|---|---|---|---|---|---|
| 1 | **P1 HLV nói check-in và trạng thái ngày** | check-in, restart, shorter, level | HLV "biết" hôm nay bà ấy thế nào; dùng 7 câu đã thu | **S** | Free | 0 |
| 2 | **P2 Sửa và mở rộng "How did that feel?"** | feeling | Lời hứa "adjust after every session" thành thật; hạ cấp được | **S** | Free (cấp, độ dài) · Pro (số lần) | 0 |
| 3 | **P3 Nhớ chỗ đau theo bài** | This hurts (exerciseID) | Bài làm đau tự mềm đi lần sau, rồi tạm bỏ | **M** | Free | 0–2 câu |
| 4 | **P4 Nhắc lại mục tiêu của bà ấy** | goals | Today/Complete/Progress nói đúng điều bà ấy muốn | **S** | Free | 0 |
| 5 | **P5 Nhớ Easier / Harder** | Easier/Harder | Bản dễ thành mặc định; Harder có nghĩa | **S** | Free (Easier) · Pro (Harder → thang) | 0 |
| 6 | **P6 Check-in tuần đổi tuần sau** | 2 câu hỏi Chủ nhật | Vòng lặp tuần như Bold "bộ lớp mới mỗi tuần" nhưng theo bà ấy | **M** | Free | 0 (chữ) |
| 7 | **P7 Câu HLV theo lịch sử (ghép đoạn)** | tuần, lần tự kiểm tra, số ngày tập | "Last check: eight. Let's see today." — YouTube không làm được | **M** | Free | ~10 khung câu EN+VI |
| 8 | **P8 Màn "Kết quả của bạn"** | tất cả | Một chỗ thấy mình khá lên, chỉ so với mình | **M** | Free (cơ bản) · Pro (số lần, vịn) | 0 |

Tiếp theo (9–13): P9 tự kiểm tra quay lại kế hoạch (S, Pro) · P10 giờ và độ dài theo hành vi thật (M, Free) · P11 bước Apple Health → ngày "đã đi nhiều" (S, Free, thấp) · P12 nhớ lựa chọn Preview (S, Free) · P13 nghỉ dài → hạ một bậc thang (S, Pro).

### 4.2 Chi tiết

**P1 — HLV nói check-in và trạng thái ngày** (S, Free)
- Làm: sau câu mở `a2.open.*` chèn `a9.gentle` / `a9.steady` / `a9.strong` theo `Intensity`; buổi "Gentle restart" mở bằng `a9.back.1/2` (xoay); buổi bị rút ngắn chèn `a9.shorter`; ngày lên/xuống cấp chèn `a9.levelup` / `a9.leveldown`. Chỗ sửa: `SessionBuilder.build` thêm segment intro 4–6 s (như `ChairSessionPlanner.afterWalk` dòng 41) hoặc `WorkoutRequest.plan`. Bản Việt đã có trong content.vi.json (kiểm `tools/voice/qc_lines.py`).
- Đo: không đo được tự động (không backend); kiểm ở test prototype: hỏi "HLV có biết hôm nay bạn thấy thế nào không?".
- Rủi ro: câu a9.gentle "Your joints are a bit achy today" nhắc tình trạng — chỉ trong buổi, không trên màn khoá → ổn.

**P2 — Sửa và mở rộng "How did that feel?"** (S, Free + Pro)
- Sửa lỗi: `Adaptation.next` lọc theo cấp **đang dùng** (cấp đã thích nghi), không theo `startLevel`; lưu cấp mới vào `UserProfile.startLevel` (hoặc cột `currentLevel`) khi đổi, để Preview và Today đồng ý; thêm `.movedUp` vào `TodaySpecialCard` ("You're ready for a little more: In place today. Seated is one tap away.").
- Mở rộng (Free): "Too hard" ×2 liên tiếp (không cần 3) → check-in hôm sau **mặc định** Achy và ngắn hơn 2 phút (không ép, bà ấy đổi được); "Too easy" ×2 ở In place → gợi ý Strong ở check-in và, nếu Pro, cho RepLadder lên bậc sau 1 buổi thay vì 2 (`sessionsToRaise` thành tham số).
- Đo (trên máy, hiện ở Me → "Your plan"): tỉ lệ buổi có trả lời feeling; số lần đổi cấp; tỉ lệ "Too hard" giảm theo tuần — chỉ hiện cho chủ app ở DEBUG, không ship.
- Rủi ro: dao động cấp qua lại → giữ ngưỡng 2–3 buổi và một chiều mỗi tuần.

**P3 — Nhớ chỗ đau theo bài** (M, Free)
- Làm: `PainRules` thêm `exerciseRules(reports:)`: bài có This hurts (có chọn vùng) trong 14 ngày → vào `plan.easierExerciseIDs` (đã có cơ chế, SessionBuilder.swift:81) và HLV nói câu bản dễ sẵn có (`a4.pain.*`, `a10.easier`); 2 lần trong 28 ngày → bài đó ra khỏi `allowed` 4 tuần, `ChairSessionPlanner` tự thế bằng bài ngồi (cơ chế :78–84); thẻ Today 1 dòng "We've set Mini-squat aside for now. Bring it back in Me." với công tắc ở Me → Your plan.
- Cũng dùng vùng: `BodyArea` → gợi ý thêm chip BodyLimit tương ứng ("Add 'Easy on knees' to your plan?") thay vì chỉ "see a doctor".
- Đo: số báo đau lặp trên cùng bài giảm; số buổi "Stop for today" giảm.
- Rủi ro: ẩn bài quá tay → luôn có nút bật lại; không gọi là "injury". Chữ qua `copy_lint.py`.

**P4 — Nhắc lại mục tiêu của bà ấy** (S, Free)
- Làm: `goals` → (a) dòng nhỏ trên thẻ buổi Today khi buổi có bài khớp (chairs → sit-to-stand: "For getting up from chairs"; steadier → steady set; energy → walk); (b) Complete: 1 dòng theo goal thay câu chung; (c) Progress: thẻ "Your goal" ghim lên đầu, hiện 1–2 số đo khớp goal (bảng mục 5); (d) Everyday wins xếp theo goal; (e) Me → Your plan: đổi goal được.
- Đo: test prototype; tỉ lệ tick Everyday wins.
- Rủi ro: "Lose some weight" không có số đo nào (app không cân) → chỉ nói "minutes moved", không hứa.

**P5 — Nhớ Easier / Harder** (S)
- Easier (Free): ghi `(exerciseID, date)` vào UserDefaults như ladder; 2 lần trong 14 ngày → bản dễ mặc định (`easierExerciseIDs`), nhãn "Easier version, as you chose" và nút "Try the usual one".
- Harder (Pro): Harder hiện chỉ bật chữ; đổi thành tín hiệu: với 3 bài trên `RepLadder`, Harder + buổi làm đủ → đếm như 2 buổi (lên bậc ngay buổi sau). Với bài khác, Harder giữ chữ hướng dẫn như nay. Free: nút Harder hiện chữ "With Pro, more reps when you're ready" 1 lần.
- Đo: tần suất bấm Easier trên cùng bài giảm sau khi mặc định; Harder → số bậc lên.

**P6 — Check-in tuần đổi tuần sau** (M, Free)
- Làm: Chủ nhật (hoặc buổi cuối tuần) màn 2 câu, 20 giây: "This week felt…" (Easier than I expected / About right / Harder) và "One thing that felt a bit better?" (chip: Getting up from a chair · Stairs · Stiffness in the morning · Energy · Sleep · Walking outside · Nothing yet). Lưu `WeeklyNote` (SchemaV3). Tác động tuần sau: Harder → walk −2 phút, check-in mặc định Achy, ladder không lên; Easier → +2 phút (trần theo template), check-in mặc định Great; chip → dòng Today thứ Hai "Last week you said stairs felt a bit better. Let's keep the leg work going." và tổng kết tuần (nt.week.*) thêm chữ đó (không ghi sức khoẻ trên màn khoá → chỉ trong app).
- Đo: tỉ lệ trả lời; số tuần liên tiếp có trả lời; "Harder" giảm theo chặng.
- Rủi ro: là tự báo, không phải đo; chữ phải né "pain relief" → dùng "felt a bit better" (bảng steady-claims).

**P7 — Câu HLV theo lịch sử bằng ghép đoạn** (M, Free)
- Có thể làm **không thu thêm**: số 1–15 đã có (`a5.n.*`), "Halfway there", "Last one"; câu thang vịn đã là câu lịch sử. Cần thu **khung câu** (EN qua Vibi, VI qua Vibi): ~10 câu ngắn, ghép với số: "Last check, you stood up [N] times. Let's see today." (mở tự kiểm tra từ lần 2) · "Week [N] of twelve." (mở buổi đầu tuần) · "That's [N] active days this week." (Complete) · "Third walk this week. Nice and steady." (biến thể cố định cho 2/3/4/5). Ghép bằng `AVMutableComposition` sẵn có; khoảng nghỉ 0,25 s giữa đoạn; số đọc bằng cùng giọng Bella nên liền tai. Cần làm: "[N] times" phải thu "times." riêng hoặc thu "stood up N times" cho N = 3…20 (18 câu) — chọn cách 2 cho tự nhiên.
- Không làm: gọi tên (luật), đọc ngày tháng, so với người khác.
- Đo: test prototype (câu nào nghe "ghép"); QC `tools/voice/qc_lines.py` cho từng tổ hợp.
- Rủi ro: ngữ điệu ghép lệch → giới hạn 1 câu ghép mỗi buổi, đặt ở chỗ nhịp chậm (mở đầu, kết).

**P8 — Màn "Kết quả của bạn"** (M, Free + Pro)
- Gom lên đầu Progress một thẻ 4 ô, mỗi ô là **của bà ấy** và chỉ so với tuần 0/lần đầu: Chair count (tự kiểm tra, có/không tay) · Hands on the chair (Pro, bậc thấp nhất hiện tại) · Longest walk without a break · Minutes moved this week vs your usual (trung vị 4 tuần của chính bà ấy). Dưới là biểu đồ 8 tuần phút/tuần và số ngày hoạt động/tuần (Swift Charts, đã có). Pro thêm: reps hiện tại vs tuần 1 cho 3 bài thang. Xem chi tiết mục 5.
- Đo: thời gian ở tab Progress không đo được → test prototype; tỉ lệ bấm "Your goal".

**P9 — Tự kiểm tra quay lại kế hoạch** (S, Pro): cùng cách làm, tăng ≥2 so với lần trước → `RepLadder.today` cho trần `base + 2` trong 2 tuần; giảm ≥2 → tuần sau trần `base`, check-in mặc định Okay, không lên bậc vịn. Chỉ là "cho phép", vẫn phải làm đủ 2 buổi. Không nhãn, không ngưỡng tuyệt đối.

**P10 — Giờ và độ dài theo hành vi thật** (M, Free): giờ bắt đầu thật (`WorkoutRecord.date − activeSeconds`) 5 buổi gần nhất lệch >45 phút so với giờ nhắc → thẻ "Move your reminder to 9:15?" (mở rộng `offersFewerReminders`). Độ dài: 2/3 buổi gần nhất kết thúc sớm ở 60–85% kế hoạch (không phải vì đau) → buổi sau mặc định ngắn hơn 2 phút + thẻ "shorter"; ngược lại hay làm Extra ngay sau → gợi ý Long walk. Đo: tỉ lệ hoàn thành trọn buổi.

**P11 — Bước Apple Health → ngày đã đi nhiều** (S, Free, thấp): bước hôm nay trước giờ nhắc > 1,5× trung vị 4 tuần **của bà ấy** → Today gợi "You've been on your feet a lot today. A gentle stretch fits." (không đổi lịch, không bỏ nhắc). Chỉ khi đã cho quyền. Rủi ro: dữ liệu trễ, iPhone để nhà.

**P12 — Nhớ lựa chọn Preview** (S, Free): cấp chọn ở Preview ghi vào profile (cùng cơ chế P2); bài đổi (`swaps`) → bài bị đổi đi ra sau trong vòng xoay 2 tuần, bài đổi vào được ưu tiên.

**P13 — Nghỉ dài → hạ một bậc** (S, Pro): khi "Pick up at week N" được bấm (≥14 ngày), `RepLadder`/`SupportLadder` hạ 1 bậc mỗi bài (không về 0), HLV nói `a11.ladder.down`. Otago bắt đầu lại nhẹ sau nghỉ; tránh bật lên "2 × 10" sau 3 tuần nghỉ.

### 4.3 Thứ tự làm gợi ý
1. Đợt 1 (trước 1.0, ~2–3 ngày code, 0 thu âm): P1, P2, P4, P5-Easier, P12.
2. Đợt 2 (1.0 hoặc 1.1): P3, P8, P13, P9.
3. Đợt 3 (1.1, cần thu âm ~30 câu Vibi + SchemaV3): P6, P7, P5-Harder, P10.
4. Để sau: P11.

## 5. Theo dõi kết quả gì và hiện ra sao

| Kết quả | Nguồn trong app | Có sẵn? | Hiện ở đâu | Cách nói (so với mình) |
|---|---|---|---|---|
| Chair count 30 s (có/không tay) | `SelfCheckRecord` | Có | Progress (biểu đồ), P8 ô 1, Program finish | "+2 since your first check" · không "score", không "normal for your age" |
| Mức vịn từng bài | `supportLadder` (Pro) | Có | Progress thẻ "Hands on the chair", P8 ô 2 | "One hand, up from two in week 1" |
| Số lần từng bài thang | `repLadder` (Pro) | Có | **Chưa hiện** → P8 | "Sit-to-stand: 1 × 10, from 1 × 6" |
| Longest walk without a break | `WorkoutRecord` | Có | Progress | giữ |
| Phút tập mỗi tuần, 8 tuần | `WorkoutRecord.activeSeconds` | Dữ liệu có, chưa vẽ | P8 | "Your usual: 38 min a week" (trung vị của bà ấy) |
| Ngày hoạt động/tuần | `ActivityCalendar` | Có | Today dòng tuần, lịch tháng | giữ, không bao giờ đếm ngày bỏ |
| Đều đặn (tuần có ≥1 buổi, liên tiếp) | tính từ record | Chưa | P8 | "6 weeks in a row with at least one session" — không phải streak ngày, không "mất" |
| Cấp đi bộ hiện tại | profile (sau P2) | Có | Me → Your plan | "In place since Oct 20" |
| Bài đang để bản dễ / tạm bỏ | P3, P5 | Chưa | Me → Your plan | công tắc bật lại |
| Lời bà ấy nói mỗi tuần | P6 `WeeklyNote` | Chưa | Progress dòng thời gian | nguyên văn chip, không diễn giải |
| Bước cả ngày | Apple Health | Có | Progress | tuần này vs tuần trước |

Không hiện: kcal, cân nặng, nhịp tim, điểm, hạng, bảng chuẩn tuổi, "fall risk".

**Đo hiệu quả đề xuất mà không có backend:** (a) test prototype và TestFlight với 5–8 người 58–75 (docs/research/prototype-test-plan.md) với bảng hỏi sau 2 tuần; (b) số liệu App Store Connect: giữ chân ngày 7/14/28, tỉ lệ trial → trả; (c) bộ đếm cục bộ DEBUG ở Me (tỉ lệ trả lời feeling, số lần đổi cấp, số báo đau lặp) để chủ app xem trên máy test; (d) nếu sau này muốn số thật từ người dùng, cần quyết định riêng về đo lường ẩn danh (ngoài phạm vi, vi phạm "không backend").

## 6. Rủi ro và luật

| Rủi ro | Đề xuất liên quan | Cách giữ |
|---|---|---|
| Tuyên bố y khoa / phòng ngã (1.4.1, steady-claims.md) | P3, P4, P6, P8 | Chữ mới qua `copy_lint.py`; "felt a bit better", không "relieves"; tự kiểm tra là "your chair count", không "test/score" |
| Nhãn nguy cơ, bảng chuẩn | P8, P9 | Chỉ so với lần đầu/trung vị của chính bà ấy; không ngưỡng tuyệt đối |
| Dữ liệu sức khoẻ ra khỏi máy | tất cả | Giữ SwiftData `cloudKitDatabase: .none`, UserDefaults; "Delete all my data" xoá cả `WeeklyNote`, bộ nhớ đau/Easier (`DataEraser`) |
| Thông báo lộ tình trạng (màn khoá) | P6, P7 | Lời bà ấy chỉ hiện trong app; nt.week.* giữ số ngày |
| Dao động cấp/bậc | P2, P9 | Mỗi tuần tối đa 1 bước lên; xuống ngay khi đau/Break; luôn có nút "easier" |
| Giọng ghép nghe máy móc | P7 | 1 câu ghép/buổi, QC từng tổ hợp, ưu tiên thu nguyên câu cho N = 3…20 |
| Quyền | P11 | Không xin thêm; chỉ đọc bước đã được phép; `PrivacyInfo.xcprivacy` không đổi |
| Pro vs Free | P5-Harder, P9, P13 | Paywall không đổi bố cục, chỉ thêm dòng "reps and support that grow with you"; không khoá phản hồi an toàn (Easier, This hurts luôn free) |
| Schema | P6 | SchemaV3 thêm `WeeklyNote`, `ExerciseMemory`; không xoá V1/V2 |

## 7. Câu hỏi còn mở
1. P2: lưu cấp đã thích nghi vào `startLevel` (đổi nghĩa cột) hay thêm cột `currentLevel` ở SchemaV3? Đề xuất: cột mới, giữ `startLevel` để hiện "Started seated".
2. P3: tạm bỏ bài sau **2** báo đau/28 ngày có quá nhanh? Hay 3 như PainRules?
3. P5-Harder cho Pro: Harder + làm đủ → lên bậc sau **1** buổi, có vi phạm "2 × 10 mới tăng" của Otago không? (Otago nói 2 buổi; đề xuất giữ 2 nhưng Harder cho phép bỏ qua trần `base + 1`.)
4. P6: hỏi Chủ nhật bằng màn trong app hay thẻ Today thứ Hai? Người nghỉ T7–CN có mở app Chủ nhật không?
5. P7: thu 18 câu "stood up N times" hay thu khung + số rời? Cần chủ app nghe thử 2 bản ghép trước khi quyết (Vibi ~1.500 credit cho EN+VI, ước tính).
6. Có chấp nhận hỏi lại **goals** sau 12 tuần ("Still the same goal?") không — hay goal cố định?
7. P8: màn "Kết quả của bạn" là thẻ đầu Progress hay màn riêng push từ dải Program? (bản vẽ Program hiện có chỗ cho "See how far you've come".)
8. Có muốn đo gì từ người dùng thật không (đụng luật "không backend")? Nếu không, mọi "đo" ở mục 5 chỉ là test prototype + App Store Connect.
