# Rà soát lại App Review và tiếng Việt — 08/10/2026

Phạm vi: code trên `mac/integration` 3461f6c (onboarding mới, paywall đơn giản, cá nhân hoá P1–P13, chương trình vững chân, nội dung chống chán). Đây là rà soát tĩnh: đọc code, plist, manifest và chuỗi; không build, không chạy simulator. Nhánh cloud không sửa Swift. Mỗi mục ghi file:dòng và cách sửa để phiên Mac làm.

Kết luận ngắn: **0 Critical, 2 Important, 3 Minor.** Bộ ba paywall, Restore, điều khoản, manifest, câu mục đích quyền, chặn lời hứa y tế và lời mời đánh giá đều đạt.

## 1. Kết quả theo mức

### Critical
Không có.

### Important

**I-1. Thời gian dùng thử 14 ngày được viết cứng, không đọc từ StoreKit.**
- Chỗ viết cứng:
  - `iOS/App/Features/Paywall/PaywallModel.swift:61` (`TrialTimeline(… trialLength: 14 …)`)
  - `PaywallModel.swift:79` (", free for 14 days")
  - `PaywallModel.swift:118` ("Free for 14 days, then … a year")
  - `iOS/App/Features/Paywall/PaywallView.swift:82` ("14 days free · …")
  - `iOS/App/Services/Store/StoreService.swift:177` (lời nhắc trước ngày tính phí tính lùi 14 ngày)
- Hiện vẫn khớp `GentleWalk.storekit:43` (`P2W`, free).
- Rủi ro: nếu App Store Connect đặt ưu đãi giới thiệu khác 14 ngày, hoặc gỡ ưu đãi trong khi `isEligibleForIntroOffer` vẫn đúng ở một vùng, màn hình sẽ hứa sai điều khoản dùng thử (3.1.2(a)).
- Sửa:
  - Lấy `products[yearly].subscription?.introductoryOffer` và đổi `period` (`value` × `unit`) ra số ngày.
  - Truyền số ngày đó vào `PaywallModel` và `updateTrialReminder()`.
  - Câu chữ dùng số ngày đó (`"Free for \(days) days…"`, kèm các key mới đã dịch sang vi).
  - Không có `introductoryOffer` (hoặc `paymentMode != .freeTrial`) thì coi như không có dùng thử: ẩn tiêu đề và dòng thời gian dùng thử.
  - Test bằng `SKTestSession` với `.storekit` đổi sang `P1W` để thấy câu đổi theo.
- Nếu muốn giữ chữ "14" để dịch dễ: thêm một kiểm tra khi khởi động (`assert` trong DEBUG và test) rằng ưu đãi của sản phẩm năm đúng là 14 ngày. Ghi vào checklist phát hành: "ưu đãi ASC = 2 tuần, free".

**I-2. Màn trước quyền Health và thông báo (S16) có nút "Not now".**
- Chỗ: `iOS/App/Features/Permissions/PermissionStepView.swift:90`.
- Đây là quyết định D5 của chủ app. Tuy vậy, App Review đã nhiều lần trả app theo 5.1.1(iv) khi màn tự giới thiệu trước hộp thoại hệ thống có nút thoát mà không đi tới hộp thoại.
  - Màn vị trí đã làm đúng: một nút, `OutdoorPrepView.swift:151-160`.
  - Màn Health và màn nhắc nhở thì chưa.
- Sửa (cần chủ app chốt lại D5):
  - Bỏ "Not now". Nút chính luôn mở hộp thoại của Apple; "Don't Allow" ở đó đã đi tiếp (`PermissionStepView.swift:86`), nên người dùng vẫn từ chối được.
  - Giữ "Back" ở bước 2.
  - Review Notes vẫn nói mọi quyền là tuỳ chọn.
- Nếu giữ "Not now": ghi rõ trong Review Notes rằng hộp thoại hệ thống có thể mở lại bất cứ lúc nào từ mục Tôi, và chấp nhận rủi ro.

### Minor

**M-1. Câu mục đích Health chưa nói tới gợi ý "ngày đi lại nhiều" (P11).**
- Câu hiện tại:
  - `iOS/App/Info.plist:24` và `iOS/project.yml:55`: "reads your step count to show your everyday activity in Progress."
- Nhưng `iOS/App/Services/Health/HealthService.swift:72-83` (`isBusyDay`) còn dùng số bước để gợi ý giãn cơ trên Hôm nay.
- 5.1.1(i) yêu cầu nêu đúng mục đích.
- Sửa (cả hai chỗ trên, cùng `InfoPlist.xcstrings` vi):
  - Câu mới: "Good Footing reads your step count to show your everyday activity in Progress and to suggest a lighter session on busy days."
  - Bản vi: "Good Footing đọc số bước để hiện mức vận động hằng ngày ở mục Tiến bộ và gợi ý buổi nhẹ hơn vào ngày bạn đi lại nhiều."
- Chính sách riêng tư trong app (`iOS/App/Features/Paywall/PaywallLegalFooter.swift:93-117`) thêm cùng ý.

**M-2. Nút "Close" vẫn hiện ở bước 3 của màn chuẩn bị ra ngoài (trước hộp thoại vị trí).**
- Chỗ: `iOS/App/Features/Outdoor/OutdoorPrepView.swift:41-48`.
- Close đóng cả luồng đi bộ ngoài trời, không phải "từ chối vị trí", nên rủi ro thấp. Nhưng người duyệt có thể đọc nó là lối thoát khỏi màn trước quyền (giống I-2).
- Sửa: ẩn hàng Close khi `flow?.step == .locationPrompt`. Lúc đó cô ấy đã chọn "Map and distance" ở bước 2; muốn bỏ thì "Don't Allow" sẽ chuyển sang chỉ đếm bước.

**M-3. Nội dung chống chán chưa nối vào app.**
- Các mảnh chưa nối: `CompleteCheer`, `Greetings`, `WeekTheme.line`, `JourneyCoach.lineID` (GentleWalkCore).
- Đây không phải lỗi duyệt. Ghi lại để không chụp ảnh store cho các câu này trước khi nối: chuỗi đã có trong `docs/i18n/vi/ui-extra-11.json`, nhưng `extract_sources.py` chỉ thấy chúng khi Swift dùng tới.

## 2. Các mục đã đạt (bằng chứng)

| Mục | Kết quả | Chỗ |
|---|---|---|
| Restore dùng `AppStore.sync()` | Đạt | `Services/Store/StoreService.swift:101` |
| Restore · Terms · Privacy luôn hiện dưới nút mua, cả khi thu gọn và khi "See other plans" | Đạt | `Features/Paywall/PaywallLegalFooter.swift` (footer), `PaywallView.swift:283-298` |
| Terms = EULA chuẩn của Apple; Privacy mở chính sách trong app | Đạt | `PaywallModel.swift:150-154`, `PaywallLegalFooter.swift:93-117` |
| Giá bị trừ là giá nổi bật nhất (cardTitle đậm), giá quy đổi chỉ là chú thích | Đạt | `PaywallView.swift:205-281` |
| Điều khoản dùng thử và tự gia hạn ngay dưới nút: giá, kỳ, "Renews until you cancel, at least 24 hours before renewal" | Đạt (xem I-1 về số ngày) | `PaywallModel.swift:114-126` |
| Dòng thời gian dùng thử: hôm nay → ngày nhắc → ngày tính phí | Đạt | `PaywallView.swift:138-154` |
| Tiêu đề chỉ nói "free for 14 days" khi đủ điều kiện dùng thử | Đạt | `PaywallModel.swift:75-80`, `StoreService.swift:162-169` |
| "Maybe later" và nút X 56 pt luôn hiện; không đếm ngược, không gạch giá | Đạt | `PaywallView.swift:89-133`, `PaywallLegalFooter.swift` |
| Màn "Next, Apple will ask you to confirm" chỉ nói "won't be charged today" khi là dùng thử | Đạt | `PaywallLegalFooter.swift:66-89` |
| Câu mục đích: một câu cho mỗi quyền thật sự dùng (Health đọc bước, Health ghi buổi tập + lộ trình, Vị trí khi dùng, Chuyển động) | Đạt (xem M-1) | `Info.plist:23-30`, `project.yml:55-58`; dùng ở `HealthService.swift:92-93`, `PedometerService.swift:52`, `MotionService.swift:15` |
| Background modes chỉ `audio`, `location`; entitlements chỉ HealthKit | Đạt | `Info.plist:31-35`, `GentleWalk.entitlements` |
| `PrivacyInfo.xcprivacy`: UserDefaults CA92.1. Các key mới hôm nay (`exerciseMemory`, `weeklyNotes`, `reminderSuggestionAnsweredAt`, `selfCheckDismissedAt`, các key ladder, habit) đều là UserDefaults của chính app nên vẫn nằm trong CA92.1; không thêm API cần lý do mới (không file timestamp, disk space, boot time) | Đạt | `PrivacyInfo.xcprivacy`, `Services/Data/PersonalisationStores.swift`, `Features/Root/AppModel+Program.swift:9` |
| "Xoá dữ liệu" xoá cả các key mới | Đạt | `Services/Data/DataEraser.swift:20-31` (`AppDefaultsKeys.all`) |
| Hỏi quyền đúng lúc cần: Health và thông báo sau buổi đầu (S16), vị trí ở bước chuẩn bị ra ngoài, chuyển động khi chọn "Held to my chest" | Đạt | `PermissionStepView.swift`, `OutdoorPrepView.swift:151-160`, `Features/Workout/PhonePlacementView.swift:14` |
| Màn trước quyền vị trí: một nút, không "Allow" | Đạt (xem M-2) | `OutdoorPrepView.swift:151-160` |
| Lời mời đánh giá chỉ qua `ReviewPromptPolicy`, không từ nút bấm | Đạt | `Features/Shared/ReviewPromptModifier.swift`, dùng ở `Features/Workout/WorkoutView.swift:105` |
| Tự kiểm tra: "This is not a medical test. You compare only with yourself." trên màn giới thiệu, đồng hồ, nhập số, kết quả và màn hết 12 tuần | Đạt | `Features/SelfCheck/SelfCheckViews.swift:84,130,205,320`, `Features/Program/ProgramFinishedView.swift:37` |
| So sánh chỉ với chính mình, cùng cách làm (có hoặc không chống tay); không bảng chuẩn theo tuổi | Đạt | `Features/SelfCheck/SelfCheckFlowModel.swift:60-66,139-149`, `AppModel+Program.swift:111-118` |
| Âm thanh tự kiểm tra là một `AVPlayer` trên một composition; không phát im lặng | Đạt | `Features/SelfCheck/SelfCheckAudioPlayer.swift` |

## 3. Quét lời hứa y tế và chống ngã

- `python3 tools/lint/copy_lint.py` (xcstrings + content JSON): **0 findings**.
- `copy_lint.py` trên ui-extra-9…12, voice-a12, voice-a13, voice-a8b và 54 câu vi mới sửa: **0 findings**.
- Quét tay EN và VI tìm fall / bone / pain / risk / prevent / medical / té ngã / xương / nguy cơ / chữa / bác sĩ:
  - Chỉ thấy câu an toàn ("Stop if it hurts or you feel dizzy").
  - Câu hỏi chỗ đau nhức ("Any sore spots?", "Sore joints? Everything starts seated."): hỏi để làm nhẹ bài, không hứa giảm đau.
  - Câu miễn trừ "not medical advice".
  - Tên địa danh có chữ "Falls" (Laurel Falls, McWay Falls): là tên thác nước, không phải lời hứa.
- Không câu nào hứa "phòng ngã", "giảm nguy cơ", "chắc xương", "hết đau".

## 4. Duyệt tiếng Việt (mục 2)

Phạm vi:
- `docs/i18n/vi/ui-extra-9.json` … `ui-extra-12.json`
- `voice-a12.json`, `voice-a13.json`, `voice-a8b.json`

Giữ nguyên key, chỉ sửa bản dịch. Nguyên tắc:
- Giọng nói với phụ nữ lớn tuổi: lịch sự, ấm, câu ngắn.
- Thống nhất thuật ngữ: "thanh toán / tính phí" thay "trừ tiền" trong câu điều khoản. "Bị trừ tiền bất ngờ" giữ nguyên vì đó là lời của người dùng.
- Dùng "chậm nhất 24 giờ trước kỳ gia hạn", vì "ít nhất 24 giờ trước kỳ hạn" dễ hiểu sai là "gia hạn ít nhất 24 giờ".
- "chỉ lưu trên điện thoại này" thay cho "ở lại trên điện thoại này" (dịch sát chữ).
- Đổi "sức sống" thành "sức lực" cho khớp với mục "Energy".
- "Nặng cho vai / lưng dưới" khớp với "nặng cho hông / gối".
- "Khá hơn / dễ hơn" thay "dễ chịu hơn" khi nói về đứng dậy, cầu thang, giấc ngủ.

Sửa tổng cộng 54 câu, gồm 52 câu giao diện và 2 câu giọng.

Kiểm tra:
- Không key nào có hai bản dịch khác nhau giữa các file `ui*.json`.
- `python3 tools/i18n/apply_catalog.py vi --check`: 929/929 key, 0 thiếu, 0 lỗi định dạng.

**Hai câu giọng cần thu lại** (bản ghi vi hiện có khớp câu cũ):
- `a12.check.setup`:
  - Câu cũ "Ngồi phía trước ghế" nghĩa là ngồi ở trước cái ghế (trên sàn). Đây là lỗi nghĩa, cần ưu tiên.
  - Câu mới: "Ngồi gần mép trước của ghế, hai chân đặt phẳng. Sẵn sàng nhé."
- `a8.camino.4`:
  - Câu cũ "Phần Camino đã đi giờ nhiều hơn phần còn lại" đọc trúc trắc.
  - Câu mới: "Melide. Bạn đã đi được hơn nửa chặng Camino."

Trên Mac làm theo thứ tự:
1. `python3 tools/voice/render_lines.py --voice bella-v4-vi a12.check.setup a8.camino.4`.
2. `python3 tools/i18n/build_content_overlay.py vi --cache assets/voice/cache-vi-bella-v4`.

Lưu ý:
- Đừng chạy bước 2 trước bước 1: overlay sẽ bỏ bản ghi của hai câu này, khi đó chỉ còn chuông và chữ.
- `iOS/App/Resources/Content/content.vi.json` chưa đổi trên nhánh này, nên app vẫn khớp với bản ghi cũ cho tới khi Mac thu lại.

Câu giao diện: chạy `python3 tools/i18n/apply_catalog.py vi` trên Mac để ghi vào `Localizable.xcstrings`. Nhánh cloud không sửa catalog.

Bảng thay đổi:

| File | Key (EN) | Cũ | Mới |
|---|---|---|---|
| ui-extra-9.json | %@ charged today, then every month until you cancel. | Trừ %@ hôm nay, rồi mỗi tháng cho đến khi bạn huỷ. | Thanh toán %@ hôm nay, rồi mỗi tháng cho đến khi bạn huỷ. |
| ui-extra-9.json | %@ charged today, then every year until you cancel. | Trừ %@ hôm nay, rồi mỗi năm cho đến khi bạn huỷ. | Thanh toán %@ hôm nay, rồi mỗi năm cho đến khi bạn huỷ. |
| ui-extra-9.json | Billed %@ | Trừ %@ | Tính phí %@ |
| ui-extra-9.json | Cancel anytime in Settings, at least 24 hours before renewal. Deleting the app doesn't cancel. | Huỷ bất cứ lúc nào trong Cài đặt, ít nhất 24 giờ trước ngày gia hạn. Xoá app không huỷ gói. | Huỷ bất cứ lúc nào trong Cài đặt, chậm nhất 24 giờ trước ngày gia hạn. Xoá app không huỷ gói. |
| ui-extra-9.json | Only while you walk. It stays on this phone. | Chỉ khi bạn đang đi. Vị trí ở lại trên điện thoại này. | Chỉ khi bạn đang đi bộ. Vị trí chỉ lưu trên điện thoại này. |
| ui-extra-9.json | Your data stays on this phone. | Dữ liệu của bạn ở lại trên điện thoại này. | Dữ liệu của bạn chỉ lưu trên điện thoại này. |
| ui-extra-9.json | Sit near the front, feet flat | Ngồi gần mép ghế, chân đặt phẳng | Ngồi gần mép trước của ghế, hai chân đặt phẳng |
| ui-extra-9.json | Sturdy chair, no wheels, by a wall | Ghế chắc, không bánh, sát tường | Ghế chắc chắn, không có bánh xe, kê sát tường |
| ui-extra-9.json | You're ready for a little more | Bạn đã sẵn sàng cho thêm một chút | Bạn đã sẵn sàng tập thêm một chút |
| ui-extra-9.json | Your first walk waits on Today. We can nudge you once a day. | Buổi đi bộ đầu tiên đang chờ bạn. App có thể nhắc mỗi ngày một lần. | Buổi đi bộ đầu tiên đang chờ ở mục Hôm nay. App có thể nhắc mỗi ngày một lần. |
| ui-extra-10.json | Finding your rhythm | Tìm nhịp quen | Tìm nhịp của mình |
| ui-extra-10.json | Steady feet | Bàn chân vững vàng | Đôi chân vững vàng |
| ui-extra-10.json | We've set %@ aside for now. Bring it back in Me. | Tạm để bài %@ sang một bên. Bật lại trong Tôi. | Tạm gác bài %@ lại. Bật lại trong mục Tôi. |
| ui-extra-10.json | Moves set aside | Bài tạm để sang bên | Bài đang tạm gác |
| ui-extra-10.json | One thing that felt a bit better? | Có điều gì thấy dễ chịu hơn một chút không? | Có điều gì thấy khá hơn một chút không? |
| ui-extra-10.json | Last week you said getting up from a chair felt a bit better. Let's keep the leg work going. | Tuần trước bạn nói đứng dậy khỏi ghế thấy dễ chịu hơn một chút. Mình cứ tiếp tục tập chân nhé. | Tuần trước bạn nói đứng dậy khỏi ghế dễ hơn một chút. Mình cứ tiếp tục tập chân nhé. |
| ui-extra-10.json | Last week you said stairs felt a bit better. Let's keep the leg work going. | Tuần trước bạn nói leo cầu thang thấy dễ chịu hơn một chút. Mình cứ tiếp tục tập chân nhé. | Tuần trước bạn nói leo cầu thang dễ hơn một chút. Mình cứ tiếp tục tập chân nhé. |
| ui-extra-10.json | Last week you said sleep felt a bit better. Let's keep it going. | Tuần trước bạn nói ngủ thấy dễ chịu hơn một chút. Mình cứ giữ nhịp nhé. | Tuần trước bạn nói giấc ngủ khá hơn một chút. Mình cứ giữ nhịp nhé. |
| ui-extra-11.json | %@ charged today, then every year. Renews until you cancel, at least 24 hours before renewal. | Trừ %@ hôm nay, rồi mỗi năm. Tự gia hạn cho đến khi bạn huỷ, ít nhất 24 giờ trước kỳ gia hạn. | Thanh toán %@ hôm nay, rồi mỗi năm. Tự gia hạn cho đến khi bạn huỷ, chậm nhất 24 giờ trước kỳ gia hạn. |
| ui-extra-11.json | %@ every month. Renews until you cancel, at least 24 hours before renewal. | %@ mỗi tháng. Tự gia hạn cho đến khi bạn huỷ, ít nhất 24 giờ trước kỳ gia hạn. | %@ mỗi tháng. Tự gia hạn cho đến khi bạn huỷ, chậm nhất 24 giờ trước kỳ gia hạn. |
| ui-extra-11.json | Free for 14 days, then %@ a year. Renews until you cancel, at least 24 hours before renewal. | Miễn phí 14 ngày, rồi %@ mỗi năm. Tự gia hạn đến khi bạn huỷ, ít nhất 24 giờ trước kỳ hạn. | Miễn phí 14 ngày, rồi %@ mỗi năm. Tự gia hạn cho đến khi bạn huỷ, chậm nhất 24 giờ trước kỳ gia hạn. |
| ui-extra-11.json | First charge, unless you cancel | Trừ tiền nếu chưa huỷ | Bắt đầu tính phí, nếu bạn chưa huỷ |
| ui-extra-11.json | Pay %@ once | Trả %@ một lần | Thanh toán %@ một lần |
| ui-extra-11.json | Every plan unlocks the same things. | Gói nào cũng mở đủ mọi thứ như nhau. | Gói nào cũng mở khoá đầy đủ như nhau. |
| ui-extra-11.json | Anything else we should know? | Còn điều gì khác? | Còn điều gì app nên biết không? |
| ui-extra-11.json | For more energy, one walk at a time. | Để thêm sức sống, từng buổi đi bộ một. | Để có thêm sức lực, từng buổi đi bộ một. |
| ui-extra-11.json | Great. Start steady, and go stronger anytime. | Tuyệt. Bắt đầu đều đặn, muốn khoẻ khoắn hơn lúc nào cũng được. | Tuyệt. Bắt đầu vừa sức, muốn tập mạnh hơn lúc nào cũng được. |
| ui-extra-11.json | Good one. Sit-to-stands start with hands on the chair. | Hay đấy. Ngồi–đứng bắt đầu với tay vịn ghế. | Được rồi. Bài ngồi–đứng sẽ bắt đầu với tay vịn ghế. |
| ui-extra-11.json | Got it. Moves that strain shoulders stay out. | Đã rõ. Động tác gây mỏi vai sẽ được bỏ ra. | Đã rõ. Động tác nặng cho vai sẽ được bỏ ra. |
| ui-extra-11.json | Got it. Moves that strain the lower back stay out. | Đã rõ. Động tác gây mỏi lưng dưới sẽ được bỏ ra. | Đã rõ. Động tác nặng cho lưng dưới sẽ được bỏ ra. |
| ui-extra-11.json | Standing tires me | Đứng lâu mệt | Đứng lâu là mệt |
| ui-extra-11.json | I got bored | Tôi thấy chán | Thấy chán |
| ui-extra-11.json | Tap all that apply, or None of these. | Chọn mọi mục đúng, hoặc Không có mục nào. | Chọn tất cả mục đúng với bạn, hoặc Không có mục nào. |
| ui-extra-11.json | Tap all that apply. We'll go easy there. | Chọn mọi chỗ đúng. Bài tập sẽ nhẹ ở đó. | Chọn tất cả chỗ đúng với bạn. Bài tập sẽ nhẹ nhàng ở những chỗ đó. |
| ui-extra-11.json | You'll see the billing date before any charge. | Bạn sẽ thấy ngày trừ tiền trước khi bị trừ. | Bạn sẽ thấy ngày thanh toán trước mỗi lần tính phí. |
| ui-extra-11.json | We'll always show the date before any charge. | Luôn cho bạn biết ngày trước khi trừ tiền. | App luôn báo ngày trước khi tính phí. |
| ui-extra-11.json | Small sessions add up. | Những buổi ngắn cộng lại thành nhiều. | Buổi ngắn cộng dồn lại cũng thành nhiều. |
| ui-extra-11.json | That's your week. | Trọn tuần rồi. | Xong trọn tuần rồi. |
| ui-extra-11.json | Rest well. Next week is ready when you are. | Nghỉ ngơi cho khoẻ. Tuần sau sẵn sàng khi bạn sẵn sàng. | Nghỉ ngơi cho khoẻ. Khi nào bạn sẵn sàng, tuần sau đã có sẵn. |
| ui-extra-11.json | Good morning to you | Chúc bạn buổi sáng vui | Chúc bạn một buổi sáng vui vẻ |
| ui-extra-11.json | Good morning to you, %@ | Chúc %@ buổi sáng vui | Chúc %@ một buổi sáng vui vẻ |
| ui-extra-11.json | Good afternoon to you | Chúc bạn buổi chiều vui | Chúc bạn một buổi chiều vui vẻ |
| ui-extra-11.json | Good afternoon to you, %@ | Chúc %@ buổi chiều vui | Chúc %@ một buổi chiều vui vẻ |
| ui-extra-11.json | Good evening to you | Chúc bạn buổi tối vui | Chúc bạn một buổi tối vui vẻ |
| ui-extra-11.json | Good evening to you, %@ | Chúc %@ buổi tối vui | Chúc %@ một buổi tối vui vẻ |
| ui-extra-11.json | Hello this morning | Xin chào sáng nay | Chào bạn sáng nay |
| ui-extra-11.json | Hello this afternoon | Xin chào chiều nay | Chào bạn chiều nay |
| ui-extra-11.json | Hello this evening | Xin chào tối nay | Chào bạn tối nay |
| ui-extra-11.json | Turn slowly, in small steps, with your chair or counter in reach. | Xoay người chậm, bước nhỏ, ghế hoặc mặt bếp trong tầm tay. | Xoay người chậm, bước nhỏ, ghế hoặc bàn bếp trong tầm tay. |
| ui-extra-12.json | With Pro, more reps when you're ready | Với Pro, thêm lần tập khi bạn sẵn sàng | Với bản Pro, tăng số lần tập khi bạn sẵn sàng |
| ui-extra-12.json | In a row with 3+ active days | Liên tiếp có từ 3 ngày vận động | Tuần liên tiếp, mỗi tuần từ 3 ngày vận động |
| ui-extra-12.json | Week of %@ | Tuần từ %@ | Tuần bắt đầu %@ |
| voice-a12.json | a12.check.setup | Ngồi phía trước ghế, chân đặt phẳng. Sẵn sàng nhé. | Ngồi gần mép trước của ghế, hai chân đặt phẳng. Sẵn sàng nhé. |
| voice-a8b.json | a8.camino.4 | Melide. Phần Camino đã đi giờ nhiều hơn phần còn lại. | Melide. Bạn đã đi được hơn nửa chặng Camino. |
