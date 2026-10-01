# Review onboarding so với đối thủ + toàn app, dữ liệu lưu và GPS — 01/10/2026

**Phạm vi:** onboarding (so với funnel LazyFit/ChillFit trong `docs/research/competitors-ui-reference.md`), màn tập, Me, Progress, Journey, All sessions; câu hỏi "GPS ngoài trời dùng làm gì, app lưu gì của một người, lưu để làm gì, lịch sử nên trông ra sao".
**Bằng chứng:** 52 ảnh iPhone 17 (en-US, sáng) qua `-ScreenshotMode`, sau commit `b9eb42b` + Home mới (chưa commit). Tờ ảnh: `docs/screens/home-redesign-2026-10-01.png` (Home); các tờ onboarding/player/tab ở scratchpad phiên này.
**Không lặp lại:** 48 mục của review 30/09 (`2026-09-30-de-hieu-bo-cuc.md`) đã sửa; chỉ nêu cái mới.

**Phán quyết:** app không rối, từng màn đã gọn. Chỗ còn "nặng" là **hành trình onboarding 14 màn với 3 màn chen không có việc gì để làm**, màn **Your plan dài 1,4 màn**, **Me dài 3 màn**, và **Progress không có lịch sử từng buổi** dù dữ liệu đã có sẵn. Đề xuất giảm onboarding 14 → 10 màn mà không bớt câu hỏi có ích.

---

## 1. Onboarding so với đối thủ

| | LazyFit / ChillFit (quiz) | Gentle Walk hiện tại |
|---|---|---|
| Số bước | 29 (web) · 34–47 (trong app) | 14 |
| Cấu trúc | 3 phần, thanh tiến độ, 1 câu/màn, Next ghim đáy | 3 phần, nhãn "Part 1 of 3 · Your goal", 1 câu/màn, Continue ghim đáy — **đã bằng chuẩn** |
| Màn chen phần | 1 s tự chuyển, không bấm | **3 màn tranh + "Part 2 · About you", phải bấm Continue** |
| Chứng thực / BMI / ảnh cơ thể / email | có cả, email trước giá | không có — **đúng với định vị**, giữ |
| Giá | giấu tới sau email | thấy ngay ở paywall, có "Maybe later" — giữ |
| Câu hỏi dùng về sau | BMI, mục tiêu cân → thực đơn | xem bảng §4: **một nửa câu trả lời không dùng ở đâu** |

### 1a. Màn dài → gọn mà chữ vẫn to
Chỉ còn **Your plan** dài (1,4 màn: thẻ plan + Why + chọn giờ nhắc). Cách gọn không cần nhỏ chữ: **chuyển "What's a good moment for your daily walk?" sang màn "Two quick things" sau buổi đầu** (S16), nơi đang xin quyền thông báo. Lý do: hỏi giờ nhắc đúng lúc xin quyền nhắc, một việc một chỗ; Your plan còn đúng một màn (thẻ plan + Why + "See my options"). Thẻ "A gentle reminder after your morning coffee" ở S16 thành: 4 ô khoảnh khắc + giờ + "Allow reminders". Mặc định khi không chọn: 8:30 AM.

Các màn hỏi (Goal 6 thẻ, Barriers 6 thẻ, Body 10 nút) đều vừa một màn iPhone 17 với chữ 17 pt; không sửa.

### 1b. Màn ngắn → gộp
| Màn | Hiện tại | Đề xuất | Tiết kiệm |
|---|---|---|---|
| Part 1 · Your goal (tranh giày + cà phê) | chỉ tranh + tên phần | **Bỏ.** Welcome đã là lời dẫn; câu đầu "What would you like from this?" tự giới thiệu phần | 1 chạm |
| Understanding (S04, "Sore knees don't mean…") + Part 2 · About you | 2 màn liên tiếp đều chỉ tranh + 2 dòng | **Gộp thành một:** tranh hai người uống trà, tiêu đề cảm thông theo barrier, dưới thêm dòng nhỏ "Next: a few questions about your day." Nhãn header đổi sang "Part 2 of 3" ngay màn này | 1 chạm |
| Part 3 · Your body | chỉ tranh + tên phần | **Bỏ**; header của Body đã ghi "Part 3 of 3 · Your body" | 1 chạm |
| Stairs ("How do you feel after one flight of stairs?") | câu trả lời **không dùng ở đâu** (`OnboardingProfile.make` chỉ đọc activity + chair + limits) và dòng "Noted. In a few weeks we'll ask again" là **lời hứa chưa có tính năng** | **Bỏ màn**, hoặc giữ và làm Fitness Check sau (plan: phase 2). Nếu giữ: bỏ câu "we'll ask again" | 1 chạm |
| Name | có Skip, bàn phím mở sẵn | giữ | — |

Kết quả: Welcome → Goal → Barriers → Understanding(+Part 2) → Name → Activity → Chair → Body → Plan → Paywall = **10 màn**, 8 chạm bắt buộc ít hơn, không mất câu nào có tác dụng.

### 1c. Chữ và cân đối (nhìn bằng mắt)
- Welcome: tranh 40 % màn, 3 lợi ích, "Let's begin" — cân đối, giữ.
- Goal: "Pick up to 2" nhưng **goals không dùng ở đâu** (không vào plan, không vào Why, không vào Progress). Hoặc dùng (xem §4), hoặc giảm còn "Pick one" để nhẹ quyết định.
- Chair strength: 3 lựa chọn, nửa màn trống dưới. Sau khi bỏ Stairs, đây là màn ngắn duy nhất; chấp nhận (Continue ghim đáy, giống đối thủ).
- Plan: "2 rest days a week · starting **Seated**" và "Day 1: first walk · 5 min · **seated**" nói cùng một ý hai lần → bỏ chữ "seated" ở dòng Day 1.
- Paywall: một màn, đủ bộ ba Restore/Terms/Privacy, "Maybe later" thấy ngay. Giữ.

## 2. Màn tập (player) và quanh buổi tập
Sau đợt gọn 01/10 (chair/stretch không cuộn, cảm nhận một dòng) các màn này ổn. Còn:
- **Phone placement** đã chỉ hỏi lần đầu (`PhonePlacement.seenKey`), tốt. Nhưng sau đó không có chỗ nào đổi ngoài Me: thêm dòng nhỏ "Phone: in my pocket · Change" trên Preview để đổi khi cần (ví dụ hôm nay muốn đếm sit-to-stand).
- Preview Outdoors: không có cấp/khoảng cách mục tiêu, chỉ danh sách 3 phần; đủ.
- Walk player: pill "QUICKER" + "Seated · Side step" + đồng hồ + "left in this part" + Next + caption: 6 tầng chữ nhưng đọc được từ xa; giữ.
- Break "0:48" vs player "00:09": hai định dạng giờ (D34 chưa sửa hết ở Break). Nhỏ.
- Complete outdoor: tranh HLV + 3 ô + cây + bản đồ + hành trình + thẻ "Your chair moves for today" + cảm nhận = 2 màn. Chấp nhận vì là màn kết; bản đồ có thể thấp hơn (160 pt).
- "Two quick things": đoạn Apple Health 5 dòng + 2 dòng hướng dẫn nút Apple. Rút còn: "See your everyday steps in Progress. Your data stays on this phone." + dòng nút Apple. Nếu chuyển câu hỏi giờ nhắc về đây (§1a) thì màn vẫn vừa một màn.

## 3. Me, Progress, Journey, All sessions
- **Me = 3 màn**, 9 thẻ. Gộp đề xuất: "Apple Health" + "Outdoor walks" thành một thẻ **"Phone & Health"** (Connected · Use location for outdoor walks); "Display" chỉ còn một hàng Text size (bỏ câu Reduce motion, chuyển vào chữ nhỏ dưới A−/A+). Thẻ "During a session" lặp đúng bộ Sound sheet trong player: giữ cả hai nhưng Me chỉ hiện **Captions + Move introductions**, âm lượng để trong player (chỉnh khi đang nghe mới có nghĩa). Me còn ~2 màn.
- **Progress = 2,5 màn**; Everyday wins 7 dòng chiếm gần 1 màn. Gập còn 3 dòng + "Show all 7". Thiếu **lịch sử buổi** (xem §5).
- **Journey**: bản đồ + thẻ chặng + điểm kế + "Start today's session" + danh sách tuyến; "Start today's session" lặp Today — bỏ được, tab này là để xem hành trình. Nhỏ.
- **All sessions**: ổn, có "Pick any session. It counts for today."
- **Sound sheet, Cancel guide, Not saved, Postcard**: ổn.

## 4. App lưu gì của một người, và lưu để làm gì
Tất cả trên máy (SwiftData, `SchemaV1`), không iCloud, không tài khoản.

| Lưu | Ở đâu | Dùng để | Ghi chú |
|---|---|---|---|
| Tên, giới hạn cơ thể, cấp bắt đầu, ngày nghỉ, giờ nhắc + khoảnh khắc | `UserProfile` | lọc động tác (limits), cấp buổi, lịch tuần, thông báo | dùng tốt |
| Goals, barriers, activity, stairs, chair | `UserProfile` | **chỉ lúc onboarding**: activity+chair → cấp bắt đầu; barriers → 1 màn cảm thông + 2 dòng "Why". Goals và stairs: **không dùng** | hoặc dùng, hoặc bỏ hỏi |
| Mỗi buổi: ngày, loại, cấp, cường độ, nơi (indoors/outdoors/pad), phút, dặm hành trình, **dặm ngoài trời**, số lần Break, cảm nhận | `WorkoutRecord` | ngày hoạt động + cây; lịch tháng; thích nghi cấp/phút buổi sau (feeling + breaks); "longest walk without a break"; dặm hành trình; tổng kết tuần | **đủ để làm lịch sử**, chưa có màn nào hiện từng buổi |
| Số sit-to-stand tốt nhất | `WorkoutRecord` | biểu đồ tuần ở Progress | |
| Báo đau (vùng, ngày, động tác) | `PainReport` | 3 lần/tuần cùng vùng → chuyển Seated + thẻ Today | |
| Dặm từng hành trình, bưu thiếp đã mở | `JourneyState`, `PostcardUnlock` | Journey, Complete | |
| Everyday wins đã tích | `EverydayWin` | Progress | |
| Thông báo đã gửi | `NotificationHistory` | luật không lặp 14 ngày | |
| Captions, âm lượng, giới thiệu động tác, yêu thích, bật vị trí, cỡ chữ | UserDefaults | cài đặt | |

**Không lưu:** tuyến GPS (toạ độ), bước Apple Health (đọc mỗi lần mở Progress), nhịp tim, cân nặng, calo (chủ ý).

## 5. GPS ngoài trời: dùng làm gì
Không chỉ để đẹp. Ba việc:
1. **Trong buổi:** khoảng cách · thời gian · pace sống trên player ngoài trời (`LocationService` + `RouteDistanceAccumulator`).
2. **Sau buổi:** `outdoorMiles` lưu vào `WorkoutRecord`, và **dặm hành trình tính bằng dặm thật** thay vì 0,05 dặm/phút (`ActivityDistance.miles` ưu tiên outdoorMiles). Complete ghi "0.9 mi walked".
3. **Tuyến (đường vẽ):** chỉ hiện trên Complete rồi **ghi vào Apple Health** (`HKWorkoutRoute`), app không giữ. Mở lại không xem được nữa.

Không bật GPS → vẫn đi ngoài trời, bước đếm bằng pedometer, dặm theo phút.

**Đề xuất:** giữ nguyên cách lưu (không thêm schema cho toạ độ ở MVP), nhưng nói rõ trên Complete ngoài trời: "Your route is saved in Apple Health." Nếu test prototype có người muốn xem lại đường đi → Schema V2 thêm `routeData: Data?` (polyline nén, vài KB/buổi) và ô bản đồ nhỏ trong lịch sử.

## 6. Lịch sử: gọn mà đủ ý
Không thêm màn, không thêm bảng. Hai lớp:
1. **Lịch tháng ở Progress thành lịch bấm được.** Chạm một ngày có chấm → sheet nhỏ (medium detent): "Wednesday, Oct 1 · Chair moves · 9 min · Just right"; ngoài trời thêm "0.9 mi walked"; có Break thêm "1 break"; ngày nghỉ: "Rest day". Dữ liệu đã có trong `WorkoutRecord`.
2. **Dưới lịch, "Recent sessions" 3 dòng** (ngày · loại · phút · cảm nhận) + "See all" mở danh sách cuộn theo tháng. Pro mới thấy "See all" (app-context: lịch sử chi tiết là Pro); Free thấy 3 dòng.

Một buổi hiện 4 thứ (ngày, loại, phút, cảm nhận), ngoài trời thêm dặm. Không kcal, không nhịp tim, không so với người khác.

## 7. Danh sách việc (xếp theo lợi/công)
| # | Việc | Màn | Công |
|---|---|---|---|
| R1 | Bỏ 3 màn Part intro; gộp Understanding làm màn mở Part 2 | Onboarding | nhỏ |
| R2 | Bỏ Stairs (hoặc bỏ câu "we'll ask again") | Onboarding | nhỏ |
| R3 | Chuyển chọn giờ nhắc từ Your plan sang "Two quick things" | Onboarding, S16 | vừa |
| R4 | Goals: dùng (1 dòng Why theo goal) hoặc "Pick one" | Onboarding | nhỏ |
| R5 | Lịch bấm được + Recent sessions | Progress | vừa |
| R6 | Preview có "Phone: in my pocket · Change" | Preview | nhỏ |
| R7 | Me: gộp Phone & Health, bớt âm lượng khỏi Me, Display 1 hàng | Me | nhỏ |
| R8 | Everyday wins gập 3 + "Show all" | Progress | nhỏ |
| R9 | Complete ngoài trời: "Your route is saved in Apple Health." | Complete | nhỏ |
| R10 | Break dùng "00:48" | Break | nhỏ |
| R11 | Bỏ "Start today's session" ở Journey | Journey | nhỏ |

**Kiểm hôm nay:** Home mới chạy đủ bộ test app (TEST SUCCEEDED), copy lint 0 findings.

## Câu hỏi chờ chủ app
1. R2: bỏ hẳn Stairs, hay giữ để làm Fitness Check phase 2?
2. R3: đồng ý hỏi giờ nhắc sau buổi đầu (thay vì ở Your plan)?
3. R5: lịch sử "See all" chỉ cho Pro (theo app-context) hay mở cho cả Free?
4. GPS: giữ "tuyến chỉ vào Apple Health" cho MVP, hay lưu polyline ngay (Schema V2)?

## Quyết định chủ app (01/10/2026) và nhật ký sửa
Đồng ý cả 4 đề xuất (xem app-context decisions log). Đã làm:
| Mục | Đã sửa |
|---|---|
| R1 | Bỏ P1–P3 (`PartIntroView`); S04 thêm dòng "Next, a few questions about your day."; header giữ nhãn phần. Onboarding 10 màn. |
| R2 | Bỏ màn Stairs; `stairsAnswer` lưu rỗng (cột giữ cho Fitness Check). Dòng dưới câu ghế đổi "Noted. We'll start you somewhere comfortable." (câu hứa hỏi lại đi cùng câu cầu thang). |
| R3 | `DailyMomentPicker` tách ra `Features/Shared/`; Your plan còn 1 màn; S16: thẻ nhắc có câu hỏi khoảnh khắc + giờ, lưu ngay khi chọn (`PermissionsCover` giữ model khi profile đổi); "Not now/Continue" ghim đáy. |
| R5 | `SessionHistoryItem` + `RecentSessionsCard`, `DaySessionsSheet`, `SessionHistoryScreen` (route `ProgressRoute.sessions`); lịch: ngày có tập bấm được; Free bấm "See all" → paywall (nội dung khoá). Test `SessionHistoryTests`. |
| R9 | Complete ngoài trời: "Your route is saved in Apple Health." khi đã kết nối. |
| Thêm (chủ app hỏi giữa chừng) | Complete: Done ghim đáy (trước đây phải cuộn 2 màn mới thấy). S16 nhấn nhá: icon chuông/tim trong vòng tròn nhạt, chữ đậm ý chính, hướng dẫn nút Apple thành ô nhấn màu sky có icon, trạng thái "Reminders on" / "Apple Health connected" thành ô xanh. |

Chưa làm (không nằm trong 4 câu đã chốt): R4 goals, R6 Change trên Preview, R7 Me, R8 Everyday wins, R10, R11. Lịch Progress chỉ hiện tháng hiện tại: ngày 1 của tháng thì lịch trống, phải xem lịch sử qua Recent sessions; cân nhắc nút ‹ › đổi tháng.

## Đợt 3 (01/10/2026, tối) — chủ app hỏi thêm
| Việc | Đã làm |
|---|---|
| Continue ở phone placement vào thẳng 3-2-1 | Stage `.ready` + `WorkoutReadyView` ("Up next": ô icon Have ready, dải Then, "I'm ready" / "Not yet"). Preview → Start now và outdoor prep vẫn vào thẳng đếm ngược (đã thấy buổi tập). `AppModel.begin(_:showsReady:)`, `beginFromPreview`. |
| "Not yet" | Đóng buổi, không lưu; Today khi chưa có buổi nào: "Your first walk · 5 min", không check-in, Start → Up next (`TodayModel.isNew`, `startFromToday`). Test `noSessionYetOffersTheFirstWalk`. |
| End to hay nhỏ | Giữ nhỏ (không phải hành động chính, chống bấm nhầm bằng hộp xác nhận) nhưng rõ: `EndSessionButton` viên thuốc viền + ✕, 56 pt. Không đỏ. |
| Đồng hồ đếm ngược | Đọc lại `WorkoutCountdownView.run`: 3 → 2 → 1 (mỗi số 1 s, ting) → Go (chime, 0,7 s) → `countdownFinished` (chỉ chạy khi stage còn `.countdown`); Skip dừng âm và kết thúc; rời màn thì task huỷ và dừng sau lần sleep. Đúng, không sửa. |
| Light / Dark / Auto | `AppearanceChoice` (UserDefaults `appearance`, mặc định auto), áp lên `UIWindow.overrideUserInterfaceStyle`; Me → Display 3 nút; xoá dữ liệu trả về Auto. Kiểm trên simulator: Dark → Auto trở lại sáng. |
| Capture | Thêm `ready-first-walk`, `today-new` (92 trạng thái). |

