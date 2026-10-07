# Review theo mẫu Mobbin (skill `mobbin-ux-patterns`) — 02/10/2026

**Phạm vi:** toàn app, en-US, iPhone 17 Pro Max, sáng (+5 màn tối, 2 màn cỡ chữ AX3). So với danh mục 24 mẫu (A1–F24) của skill, checklist, luật craft uxpeak và 6 nguyên tắc tâm lý. Không lặp U1–U12 (30/09), D1–D48 (30/09) và các mục đã chốt 01–02/10.
**Bằng chứng:** `/tmp/gw-mobbin-review/` — **seen 92/93** trạng thái yêu cầu. Ba trạng thái không chụp được: `indoors` và `steady` không tồn tại trong `CaptureHook` (không phải state); `onboarding-plan-xxl` không có state `-xxl` trong hook. Ba ảnh `today@xxl`, `complete@xxl`, `onboarding-plan@xxl` chụp lần đầu **bị sai** (xem M10) → chụp lại bằng state `today-xxl`, `complete-xxl`, đã kiểm.
**Build:** cây làm việc hiện tại (sau commit `edf0638`), `/tmp/gw-dd`.

**Phán quyết:** Pass with notes — **0 Critical · 10 Important · 6 Minor · 4 STOP-AND-ASK** (3 trong đó là đề xuất VƯỢT LUẬT DỰ ÁN theo yêu cầu chủ app 02/10).

## Kết luận từng vùng

| Vùng | Mẫu Mobbin | Phán quyết |
|---|---|---|
| Welcome, onboarding (9 màn) | A2, A3, A5; smart defaults, endowment ("Your plan, Margaret") | Tốt. Thiếu thanh tiến độ mảnh (M6), Goal thiếu đáp án thoát và 3 câu hỏi thiếu dòng "vì sao hỏi" (M7) |
| Paywall (4 biến thể) | uxpeak A/B 1 (trial timeline), trio App Review | Rất tốt: dòng thời gian 3 mốc, giá tính thật nổi nhất, Restore · Terms · Privacy, Maybe later. Chữ nút và mốc ngày (M11) |
| Today (11 trạng thái) | B7 greeting + dải tuần, B8 một thẻ việc chính, B11 trạng thái "Done" trung thực, C13 check-in | Tốt. Câu hỏi check-in nhỏ, mờ và mất câu giải thích D6 (M1); ngày nghỉ chỉ có chữ (M15) |
| Preview, Up next, countdown, phone placement | D15 detail card + Start ghim đáy, A4 teach in seconds, D16 | Tốt, giữ |
| Walk player (trong nhà, ngoài trời, full screen, iPad) | D17 một số khổng lồ + Pause to, D18 live map + 3 ô số | Tốt. Nút trên clip trắng không thấy (M2); "min per mile" là từ của dân chạy (M12, STOP-AND-ASK); thanh tiến độ vô nghĩa khi "walking home" (M13) |
| Chair player, Rest, Stand behind chair | D17, "Next up" như lớp học | Tốt. "Starting in 3" quá nhỏ cho người đang đứng xa máy (M9) |
| Stretch player | D17 | Lỗi "Next: Upper back twist" khi đang làm Upper back twist (M5) |
| Break, This hurts, End, Sound, Watch on TV | A6 safety first (Apple COVID, Ada, Wysa SOS) | Tốt, giữ |
| Complete (6 biến thể) | E20 big tiles + lời khen + Continue, C14 feedback 3 lựa chọn | Tốt. Câu "How did that feel?" tụt dưới nếp gấp khi có bưu thiếp (M3); Level up hiện "0 of 14" (M4) |
| Permissions S16 | A5 lý do trước hộp thoại | Lý do tốt, nhưng nút chính ghim đáy là "Not now" (M8) |
| Journey, All journeys, Postcard, Locked stop | E22 journey path, B11 locked state | Tốt, giữ |
| Progress (5) | E21 lịch không đỏ, B10 verdict | Tốt. Lịch tháng thiếu một dòng số + chữ (M14); tranh cây ở chế độ tối hai tông (M16) |
| Me (4), Cancel guide | Ro: hàng nhãn xám + giá trị đậm + link | Tốt, giữ |
| Chụp màn hình | — | Hậu tố `@xxl` của script bị hook ghi đè (M10) |

## Phát hiện

| ID | Mức | Màn (ảnh) | File:dòng | Chỗ sai | Người dùng cảm thấy | Sửa | Mẫu · app tham chiếu |
|---|---|---|---|---|---|---|---|
| M1 | Important | `today.png`, `today-xxl.png` | `iOS/App/Features/Today/TodayView.swift:152` | "How do your joints feel today?" là `.caption` 15 pt màu `textMuted` (Tokens.swift:28 ghi rõ textMuted "never instructions"). Câu D6 "We'll set today's session to match." đã mất khỏi mã (grep = 0). | Bà 58 tuổi bỏ qua câu hỏi vì nó trông như chú thích; bấm "Great" thì tên bài đổi thành "Strong walk" mà không hiểu vì sao. | Câu hỏi `.typeRole(.body)` + `Palette.text`; thêm lại một dòng `.caption` dưới 3 pill: "We'll set today's session to match." | C13 check-in to, rõ · Fabulous "I feel good/ok/bad", Alan Mind daily tracker, Visible |
| M2 | Important | `walk-player.png`, `chair-player.png`, `stretch-player.png`, `outdoor-player.png` | `iOS/App/Features/Workout/Shared/InterfaceOrientation.swift:41-57`; `Outdoor/OutdoorLiveMap.swift:60-74` | `VideoCornerButton` là vòng tròn `surface` 92 % không viền, không bóng. Mọi clip của app đều là tường trắng: nút gần như tan vào nền (đúng "mistake #1" của uxpeak: thiết kế cho ảnh mẫu, không cho cả hệ). Nút Recenter trên bản đồ cũng không bóng. | Không biết có nút phóng to; trên bản đồ sáng không thấy Recenter. | `VideoCornerButton`: thêm `.overlay(Circle().strokeBorder(Palette.textMuted.opacity(0.35), lineWidth: 1))` + `.shadow(color: .black.opacity(0.12), radius: 4, y: 1)`. Recenter: cùng bóng như `TrackingBadge` (đã có). Thử trên clip sáng nhất (S5) và tối nhất. | uxpeak #1 "icon trên ảnh cần nền mờ + viền" · NTC, Peloton, Open (video controls) |
| M3 | Important | `complete.png`, `complete-first-walk.png`, `complete-stopped.png` | `iOS/App/Features/Workout/Complete/CompleteView.swift:31-75` | Thứ tự: hero → 3 ô → cây → hành trình → bưu thiếp (150 pt) → "How did that feel?". Khi có bưu thiếp, câu hỏi cảm nhận bị đẩy xuống dưới nút Done ghim (ảnh: chỉ thấy tiêu đề câu hỏi bị cắt). U4 chỉ kiểm biến thể không có bưu thiếp. | Bà bấm Done luôn, app mất tín hiệu "Too hard" để chỉnh ngày mai (đây là cơ chế thích nghi chính). | Đưa `FeelingQuestion` lên ngay sau `CompleteStats` (trước cây). Bưu thiếp là phần thưởng, bà sẽ cuộn tới. | E20 + C14 "How helpful was this routine?" ngay sau số · pliability, Breathwrk, Paired |
| M4 | Important | `complete-level-up.png` | `CompleteView.swift:36`; `Features/Progress/TreeMilestone.swift:19-24` | Màn mừng "You reached Sprout" nhưng ngay dưới là "0 of 14 active days to Sapling" với thanh trống. | Vừa lên cấp đã thấy mình ở số 0 — đúng điều goal gradient cấm ("0 % là đứng yên"). | Khi `content.reachedLevel != nil`: thay `TreeMilestoneLine` bằng một dòng không thanh: "Next: Sapling, 14 active days from here." (thanh và "x of 14" quay lại từ buổi sau). | Goal gradient (uxpeak) · Breathwrk "Level 5 achieved!", Me+ |
| M5 | Important | `stretch-player.png`, `stretch-switch-side.png` | `iOS/App/Features/Workout/Stretch/StretchPlayerModel.swift:55-60` | `followingName` lấy phase kế trong block; với tư thế hai bên, phase kế là bên còn lại của cùng tư thế → "Next: Upper back twist" trong lúc đang làm Upper back twist (cả hai bên). | Tưởng app lặp bài hoặc đếm sai. | Bỏ qua các phase có cùng `exerciseID`; nếu phase kế là bên kia → "Next: other side"; nếu không còn → "Last stretch". Test Core/App: `followingNameSkipsTheOtherSide`. | D17 "Next" rõ ràng · Peloton "Up next", Tempo |
| M6 | Important | `onboarding-goal.png` … `onboarding-body.png` | `iOS/App/Features/Onboarding/OnboardingView.swift:65-83`; `OnboardingFlow.swift:46-53` | Chỉ có nhãn "Part 2 of 3 · About you", không có thanh tiến độ mảnh. 9 màn hỏi, không biết còn bao xa. | "Còn bao nhiêu câu nữa?" — nỗi mệt quyết định với người mới. | Dưới `OnboardingProgressHeader`: `ProgressView(value:)` 4 pt, tint `secondary`, giá trị `step.rawValue / OnboardingStep.plan.rawValue` (Welcome tính là bước đã xong → không bắt đầu ở 0). Giữ nhãn Part. | A3 thanh tiến độ mảnh · Ro, LazyFit, Tolan; goal gradient |
| M7 | Important | `onboarding-goal.png`, `onboarding-name.png`, `onboarding-strength.png` | `Packages/GentleWalkCore/Sources/GentleWalkCore/Onboarding/OnboardingProfile.swift:4`; `OnboardingCopy.swift:7-37`; `QuestionViews.swift:69,104,121` | Goal bắt chọn ≥1 trong 6 mục tiêu, không có đáp án thoát (review 01/10 §4: goals không dùng ở đâu). Name, Activity, Chair không có dòng "vì sao hỏi". | Người "chỉ muốn khoẻ hơn" phải chọn bừa; hỏi tên mà không nói để làm gì. | Thêm `Goal.notSure` "Not sure yet, just to feel better" (cuối danh sách, icon `sparkles`). Phụ đề: Name "The coach never says it; we use it to say hello." · Activity "So we start you at a comfortable level." · Chair "It helps us pick your first chair moves." | A3 escape answer + why-we-ask · Ro "Not sure yet", Ada "What does this mean?", Tolan birthday |
| M8 | Important | `permissions.png` | `iOS/App/Features/Permissions/PermissionsView.swift:52-61, 17-28` | Nút duy nhất ghim đáy là link "Not now"; "Allow reminders" là nút viền nằm giữa thẻ, dưới 4 ô + giờ. Thẻ Health còn dưới nếp gấp. | Người lớn tuổi bấm cái ghim đáy vì "đó là nút để đi tiếp" → tắt luôn lời nhắc, công cụ giữ thói quen chính của app. | Vùng ghim: chưa cho nhắc → primary "Allow reminders" + link "Not now"; đã cho nhắc, chưa Health → primary "Connect Apple Health" + link "Done"; đủ → "Done". Nút trong thẻ giữ làm trạng thái "Reminders on". | A5 một lời xin, một nút, lý do trước · Tolan, Sweatcoin |
| M9 | Important | `chair-stand-behind.png` | `iOS/App/Features/Workout/Chair/ChairPlayerView.swift:308-312` | "Starting in 3" là `.cardTitle` màu mờ, đứng dưới tiêu đề. Màn này dành cho lúc bà đã đứng dậy, điện thoại trên bàn 1–2 m. | Không thấy đếm, bị bất ngờ khi giọng bắt đầu. | Số đếm `.typeRole(.stat)` (40 pt) + `Palette.text`, chữ "Starting in" `.caption` ở trên; giữ `contentTransition(.numericText())`. | D16 đếm ngược to · Ladder "Add Prep Time 3", Sweatcoin "Get ready" |
| M10 | Important (công cụ) | `today@xxl` (ảnh đầu, sai) vs `today-xxl.png` | `iOS/App/RootView.swift:84`; `iOS/scripts/capture_states.sh:17-21` | `CaptureRouter` ghim `.dynamicTypeSize(.large)` cho mọi state không có hậu tố `-xxl`, nên hậu tố `@xxl` của script (đổi cỡ chữ simulator) **bị vô hiệu**: ảnh ra cỡ thường mà không báo. | Người review tin nhầm là app ổn ở cỡ chữ lớn; mọi ảnh `@xxl` của state không có `-xxl` từ trước tới nay có thể sai. | Router chỉ ép `.accessibility3` khi state có `-xxl`; **không** ép `.large` cho state khác (để simulator quyết). Thêm test `CaptureHookTests`: state thường không set `dynamicTypeSize`. | — (quy ước chụp của dự án) |
| M11 | Minor | `paywall-eligible.png` | `iOS/App/Features/Paywall/PaywallModel.swift:66`; `PaywallView.swift:77-80` | Nút "Start free trial" (uxpeak: "Start **my** free trial" tạo sở hữu). Dòng thời gian trộn hai hệ: "Day 12" (ngày tương đối) và "Oct 16" (ngày lịch). | Phải tự đổi "Day 12" ra ngày. | Nút "Start my free trial"; mốc 2 dùng `trial.reminderDate` → "Oct 14 · We'll remind you" (cùng định dạng mốc 3). | uxpeak A/B 1 · Calm, Headspace trial timeline |
| M12 | Minor · **STOP-AND-ASK** | `outdoor-player.png` | `iOS/App/Features/Outdoor/OutdoorLiveMap.swift:119-145` | Ô thứ ba "5:33 min per mile" là pace của dân chạy; với người mới 50–64 là thuật ngữ và dễ đọc thành điểm số. | "Tôi chậm quá à?" — so với người khác, trái tông. | Chủ app chọn: (a) 2 ô distance · time; (b) ô 3 = "steps" từ `PedometerService`; (c) giữ pace. Đề xuất (b). | D18 komoot/Garmin 2–4 ô · Garmin "Distance 0.72 mi" |
| M13 | Minor | `walk-home.png` | `iOS/App/Features/Workout/Walk/WalkPlayerView.swift:114,173` | Khi "walking home" (phase không có điểm kết) `NextUpRow` vẫn vẽ thanh tiến độ ở 0 và không có "Next". | Thanh trống như bị kẹt. | `NextUpRow` nhận `progress: Double?`; `nil` khi `model.isWalkingHome` → ẩn thanh. | D17 secondary nhỏ, không rác |
| M14 | Minor | `progress.png` | `iOS/App/Features/Progress/ProgressScreen.swift:96` | Lịch tháng chỉ có tiêu đề "October 2026"; không có số + câu đời thường. | Phải tự đếm chấm xanh. | Dưới tiêu đề: "3 active days so far this month" (0 → "Your first active day this month will show here."). Dùng `Plural.activeDays`. | B10 verdict + plain sentence · Outsiders, Visible, Google Fit "3/7" |
| M15 | Minor | (đọc mã; state rest chưa có) | `iOS/App/Features/Today/TodayView.swift:198-249` | Thẻ ngày nghỉ chỉ có "Rest day · Rest days are part of the plan." và icon trăng. | Ngày nghỉ trống trải, không gợi gì. | Thêm tranh `walkerRest` 96 pt bên phải và link `.smallTextLink` "A short stretch if you like" → All sessions (tuỳ chọn, không ép). | D19 Gentler Streak "Day to Rest and Recover" + gợi ý Active Recovery |
| M16 | Minor | `progress-dark.png` | `ProgressScreen.swift:67`; asset tranh cây | Ô tranh cây ở chế độ tối hiện hai tông: nền giấy trong PNG sáng hơn `artPaper` tối. | Ô trông như bị lỗi ảnh. | Xuất lại 4 PNG cây với nền trong suốt, hoặc `ArtImage` tô `artPaper` dưới ảnh có `blendMode(.multiply)` chỉ cho tranh cây. | F24 tối dịu |

## Đã tốt (giữ nguyên)

- **Welcome** (A2): tranh, một lời hứa, một nút, "Restore purchase" nhỏ — như MacroFactor, Future.
- **Onboarding** (A3): một câu một màn, thẻ to có tick, "Pick up to 2", "None of these", smart default (Okay, After my morning coffee, Yearly), "Your plan, Margaret" + Day 1 (endowment).
- **Paywall**: đúng mẫu thắng của uxpeak — "How your free trial works" dạng 3 mốc, lợi ích trước, giá tính thật nổi nhất, "Or keep the free plan", Restore · Terms · Privacy, "Maybe later" luôn thấy; không đếm ngược, không gạch giá. Me ghi "Free trial · ends Oct 14, then $39.99 a year" (Ro).
- **Today**: lời chào + "13 active days · Sprout", một thẻ chính với Start to, dải tuần có tick và "Today" viền đậm, "4 active days this week · 2 rest days are part of the plan" (mục tiêu mềm, không chuỗi), "Done for today / Today counts as an active day" (trạng thái rỗng thành lời yên tâm như Ro).
- **Preview + Up next + countdown**: thẻ chi tiết với ô tranh chọn nơi/mức, Start ghim đáy; "Have ready" và "Then" bằng icon; 3-2-1 có "Skip the countdown".
- **Player**: đồng hồ 80 pt với nhãn "left in this part", Pause 76 pt, Break · This hurts cố định (A6: SOS luôn thấy), phụ đề chữ thường, End có viền; Rest hiện clip động tác kế (lớp học); full screen có panel riêng.
- **Break / This hurts**: đếm lên có nhãn "Resting for", dấu hiệu khẩn cấp in sẵn, "I'm okay, go back".
- **Complete**: 3 ô số to + lời khen + Done ghim; "Good call to stop." không ăn mừng khi dừng vì đau.
- **Progress**: lịch không có ngày đỏ, chú thích, "An active day is any day you finish a session.", "Recent sessions" + "See all · Pro" trung thực.
- **Journey**: "First leg free · to …" + Pro, "Next stop", "Reach it at 2.2 mi", hộp xác nhận đổi tuyến giữ tiến độ.
- **Dark mode**: Today, Walk player, Complete, Paywall đạt; chỉ M16.
- **Cỡ chữ AX3** (`today-xxl`, `complete-xxl`): pill xếp dọc, ô số xếp dọc, không cắt chữ.
- **Trial reminder**: `NotificationPlanner` lên lịch `.trialEnd` đúng `trial.reminderDate`; thẻ Today từ ngày 10 (I1) bù khi không có quyền thông báo → lời hứa "We'll remind you" là thật.

## STOP-AND-ASK (chủ app quyết, không lên lịch)

### S1 · M12 — Ô "min per mile" trên bản đồ ngoài trời
Xem bảng. Đề xuất (b) steps. Không phải vượt luật; là lựa chọn sản phẩm.

### S2 · VƯỢT LUẬT DỰ ÁN — Nhãn một chữ "Lowest monthly cost" trên gói Yearly (paywall)
- **Luật bị bẻ:** Tone & copy "không hype"; quyết định D4 (30/09) chốt bố cục paywall.
- **Vì sao hợp nhóm này:** uxpeak A/B 2: một nhãn một chữ ("Cheaper") giúp quyết trong 2 giây; nhóm 50–64 sợ chọn sai gói. Nhãn là sự thật số học ($3.33 vs $7.99 một tháng), không bịa số, không gạch giá.
- **Rủi ro:** nghe như bán hàng; nếu giá đổi ở App Store Connect mà nhãn vẫn cứng → sai (phải tính từ `Product`). **App Review:** không ảnh hưởng (không countdown, không giá gạch, giá tính thật vẫn nổi nhất).
- **Nếu OK:** `PlanOptionCard` nhận `badge: LocalizedStringResource?`; `PaywallModel` tính `monthly(yearly) < monthly` → badge; `Palette.sky` chữ `onLightFill`.

### S3 · VƯỢT LUẬT DỰ ÁN — Mục tiêu tuần mềm "4 of 5 this week" trên dải tuần Today
- **Luật bị bẻ:** app-context Price model/Thông báo: "ngày hoạt động, không có streak"; dải tuần hiện chỉ đếm xuôi.
- **Vì sao hợp nhóm này:** skill E21 "flexible targets" (Ten Percent Happier "10 of 14 days", Google Fit "3/7") là dạng chuỗi *không bao giờ mất*; số ngày tập trong tuần = số ngày không nghỉ trong kế hoạch, nên "4 of 5" là mô tả, không phải đe doạ.
- **Rủi ro:** tuần bệnh thấy "1 of 5" vẫn là áp lực; trái tinh thần "chỉ so với chính mình" nếu đặt sai chỗ. Giảm rủi ro: chỉ hiện khi ≥1 ngày tập, chữ "so far", không màu đỏ. **App Review:** không.
- **Nếu OK:** `TodayModel.weekLine` → "\(active) of \(7 - restDays.count) active days so far this week · rest days are part of the plan".

### S4 · VƯỢT LUẬT DỰ ÁN — "Try a 2-minute seated walk first" ngay trên Welcome (trước câu hỏi và paywall)
- **Luật bị bẻ:** quyết định 27/09 và 01/10 về luồng onboarding 10 màn → paywall → buổi đầu; thứ tự reciprocity hiện tại đã là "buổi đầu trước S16".
- **Vì sao hợp nhóm này:** A4 Tempo "Your body is primed to try your first workout", Breathwrk "teach you the basics in 90 seconds"; nhóm "sợ không theo kịp video" sẽ tin app nhất khi đã *nghe* giọng dẫn 2 phút trước khi trả lời 9 câu hỏi. Seated march không cần giới hạn cơ thể.
- **Rủi ro:** thêm một nhánh luồng (player trước profile) → cần `WorkoutRequest` mặc định Seated/Gentle, không ghi `WorkoutRecord` (hoặc ghi và tính là ngày 1 — lại một quyết định); kéo dài thời gian tới paywall. **App Review:** không.
- **Nếu OK:** nút phụ trên `WelcomeView` → `AppCover.workout(request: .trial)`; Complete rút gọn "That's the voice. Now a few questions." → quay lại Goal.

## Câu hỏi chưa giải quyết
1. M12/S1: giữ pace, bỏ, hay thay bằng bước chân?
2. S2–S4: chủ app duyệt từng đề xuất VƯỢT LUẬT riêng; không làm nếu không có "OK".
3. M7: thêm `Goal.notSure` vào Core là đổi enum `Codable` (string) — hồ sơ cũ không ảnh hưởng; có cần hiện trong `Why this will work for you` không? Đề xuất: không.
4. M10: có cần chụp lại bộ ảnh AX5 của review 30/09 (U2) bằng hook đã sửa không? Đề xuất: chỉ chụp lại 6 màn U2 nêu tên.

## Nhật ký sửa (02/10/2026, Opus 5.5; review và kế hoạch do Fable 5.1)

| ID | Task | Kết quả |
|---|---|---|
| M5 | T1 | Đã sửa, **khác kế hoạch**. Hai tư thế giống nhau đứng liền nhau trong `sessions.json` (st.chest, st.chest; st.twist, st.twist) là *vòng thứ hai*, mỗi lần đã tự đổi trái sang phải. "Next: other side" sẽ sai, nên dùng "Next: Upper back twist, once more". Helper `FollowingMove.label` dùng chung cho Chair và Stretch; test `FollowingMoveTests` |
| M3 | T2 | Đã sửa: "How did that feel?" nằm ngay dưới 3 ô số |
| M4 | T3 | Đã sửa, gọn hơn kế hoạch: `TreeMilestoneLine` tự đổi chữ khi `done == 0` ("Next: Sapling, 14 active days from here.", không có thanh), dùng chung cho Complete và Progress; test `TreeMilestoneTextTests` |
| M9 | T4 | Đã sửa: dòng "Starting in" và con số 40 pt |
| M2 | T5 | Đã sửa: `VideoCornerButton` có viền và bóng; Recenter có bóng |
| M1 | T6 | Đã sửa: câu check-in cỡ body, màu chữ chính; thêm dòng "We'll set today's session to match." |
| M6 | T7 | Đã sửa: thanh 5 pt dưới hàng Back, bắt đầu từ 1/8; test `progressNeverStartsAtZero` |
| M7 | T8 | Đã sửa: `Goal.notSure` ("Not sure yet, I just want to start", luôn đứng một mình); thêm dòng phụ ở Name, Activity, Chair; test `notSureStandsAlone` |
| M8 | T9 | Đã sửa: nút lớn ghim đáy là quyền kế tiếp (Allow reminders, rồi Connect Apple Health), link "Not now" / "Done" bên dưới |
| M10 | T10 | Đã sửa: hook chỉ ghim cỡ chữ cho state `-xxl`; `@xxl` giờ chụp đúng cỡ lớn; test `onlyXxlStatesPinTheTextSize` |
| M11 | T11 | Đã sửa: nút "Start my free trial"; mốc nhắc là ngày lịch ("Oct 14"); test `PaywallModelTests` |
| M13 | T12 | Đã sửa: không có thanh tiến độ khi "walking home" |
| M14 | T13 | Đã sửa: "1 active day so far this month" hoặc dòng cho tháng trống; test `MonthSummaryTests` |
| M15 | T14 | Đã sửa: tranh `walkerRest` và link "Like to move a little? Pick a short session"; thêm state `today-rest` |
| M16 | T15 | Đã sửa: tranh cây `blendMode(.multiply)` lên nền giấy |
| M12, S2–S4 | — | Chờ chủ app quyết (STOP-AND-ASK) |

Bằng chứng:
- Core `swift test`: 152/152.
- App `xcodebuild test`: 177/177.
- `copy_lint.py`: 0 findings.
- `apply_catalog.py vi --check`: 681/681.
- Ảnh trong `/tmp/gw-mobbin-fix/`, chụp các màn đã sửa ở sáng, tối và `@xxl`.

### Việc chờ quyết, chủ app chốt 02/10/2026
| ID | Quyết định | Kết quả |
|---|---|---|
| S1 (M12) | (b) số bước | `LiveStatsStrip(miles:seconds:steps:)`. Có GPS thì bộ đếm bước chỉ chạy khi quyền Motion đã có sẵn (`PedometerProviding.isAuthorized`), không bật hộp hỏi quyền giữa buổi; không có thì 2 ô. Test `runningOnlyBetweenStartAndStop` |
| S2 | Làm | Nhãn "Lowest monthly cost" khi `yearly/12 < monthly` (giá từ `Product`); test `lowestMonthlyComesFromThePrices` |
| S3 | Làm | `TodayModel.weekLine` ghi "x of y active days so far · …" khi 1 ≤ x ≤ y; test `weekLineIsASoftTarget` |
| S4 | Bỏ | — |

Test: app 180/180, `copy_lint` 0 findings, vi 684/684. Ảnh: `/tmp/gw-mobbin-fix/sheetS.jpg`.
