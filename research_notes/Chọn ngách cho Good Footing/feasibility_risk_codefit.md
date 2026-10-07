# Khả thi, rủi ro pháp lý và độ khớp mã khi Good Footing tập trung vào một vấn đề (07/10/2026)

_Phạm vi: 7 ngách ứng viên (A thăng bằng/đứng dậy khỏi ghế · B cứng người/linh hoạt · C đau gối/hông · D đi bộ trong nhà · E giảm cân · F xương/loãng xương · G tư thế/lưng), thị trường Mỹ. Ghi chú về nguồn: proxy chặn fda.gov, revenuecat.com, adapty.io, cov.com, ropesgray.com, honigman.com, troutman.com, innolitics.com. Phần FDA, RevenueCat, Adapty lấy từ đoạn trích kết quả tìm kiếm (WebSearch), không đọc được toàn văn. Trang App Review Guidelines và 2 thread Apple Developer Forums đọc được toàn văn. Dữ liệu trong repo đọc trực tiếp (đường dẫn ghi kèm)._

## 1. Mã và nội dung hiện có phục vụ ngách nào, ngách nào phải làm mới

### Takeaway
Mã và nội dung hiện có nghiêng hẳn về ngách A (thăng bằng + đứng dậy khỏi ghế): đã có Steady set mỗi ngày tập, thang vịn, chip "unsteady", bộ đếm ngồi–đứng, câu hỏi onboarding về đứng dậy không dùng tay, và khẩu hiệu "Steadier on your feet". Ngách D (đi bộ trong nhà) và B (giãn cơ) cũng có đủ nội dung. C và G chỉ có bộ lọc và vài động tác. E và F gần như không có gì, và đi ngược các quyết định đã chốt.

### Cited Findings
- Nội dung: 39 động tác, gồm walk 8, move (ghế) 12, stretch 13, balance 6. Mỗi động tác có `purpose` theo việc đời thường ("For getting up from chairs", "For steadier balance", "For narrow aisles and hallways"), `hiddenFor`/`easierFor` theo giới hạn cơ thể — [exercises.json](/home/user/gentle-walk-50/iOS/App/Resources/Content/exercises.json)
- 47 mẫu buổi: firstWalk; 15 buổi walk (seated / inplace / pad × gentle, steady, strong, long, commercial); 3 buổi moves; 9 đoạn ghế (open, rest, to-stand, to-stand.sts, to-sit, close); 3 buổi balance; 7 Steady set (gentle/steady/strong × a/b + seated); 6 buổi stretch (seated/standing × 3); 2 cooldown; 1 morning — [sessions.json](/home/user/gentle-walk-50/iOS/App/Resources/Content/sessions.json)
- `WeeklyPlanner`: Pro theo nhịp Walk · Stretch · Walk · Chair · Long walk. Mọi ngày tập đều có `SteadySet`: free luôn `.gentle` (hai tay vịn), Pro theo cường độ. Nguồn ghi trong comment: WFG 2022, ≥3 ngày/tuần — [WeeklyPlanner.swift](/home/user/gentle-walk-50/iOS/Packages/GentleWalkCore/Sources/GentleWalkCore/Plan/WeeklyPlanner.swift)
- `SupportLadder` (Pro): hai tay → một tay → đầu ngón tay (đầu ngón tay chỉ ở Tandem). Lên một bậc sau 2 buổi liền không bấm This hurts/Break. Xuống bậc khi bấm This hurts hoặc Break. Cường độ trong ngày giới hạn bậc cao nhất. Áp cho 8 động tác — [SupportLadder.swift](/home/user/gentle-walk-50/iOS/Packages/GentleWalkCore/Sources/GentleWalkCore/Plan/SupportLadder.swift)
- `Adaptation`: ba lần liền chọn "tooHard" hoặc "tooEasy" thì đổi cấp đi bộ. Bấm Break ≥2 lần thì buổi sau ngắn đi 2 phút. App chưa có tiến trình theo khả năng đo được — [Adaptation.swift](/home/user/gentle-walk-50/iOS/Packages/GentleWalkCore/Sources/GentleWalkCore/Plan/Adaptation.swift); bản rà soát ghi "Tiến trình: Otago 4 mức A–D theo khả năng… App: chỉ theo check-in hằng ngày → Thiếu tiến trình theo khả năng" — [review 06/10](/home/user/gentle-walk-50/docs/reviews/2026-10-06-chuyen-gia-ra-soat-bai-tap-58-75.md)
- Onboarding đã có mục tiêu `steadier`, `chairs`, `lessPain`, `loseWeight`, `moreEnergy`, `grandkids` và câu hỏi `ChairAnswer` (đứng dậy không dùng tay: notPossible/hard/easy) dùng để chọn cấp bắt đầu — [OnboardingProfile.swift](/home/user/gentle-walk-50/iOS/Packages/GentleWalkCore/Sources/GentleWalkCore/Onboarding/OnboardingProfile.swift)
- `BodyLimit`: knees, hips, lowerBack, shoulders, noFloor, standingIsHard, dizzy, jointReplacement, noJumping, unsteady. Loãng xương đã gộp vào chip "Lower back" ("or bone thinning"). App không có động tác nhảy hay tác động mạnh — [Exercise.swift](/home/user/gentle-walk-50/iOS/Packages/GentleWalkCore/Sources/GentleWalkCore/Content/Exercise.swift); [app-context.md](/home/user/gentle-walk-50/app-context.md) dòng 30/09 (6)
- HealthKit hiện chỉ đọc `stepCount` (và ghi workout/tuyến). Chưa đọc chỉ số di chuyển nào — [HealthService.swift](/home/user/gentle-walk-50/iOS/App/Services/Health/HealthService.swift) dòng 81, 108
- Các quyết định đã chốt chặn ngách E: "không kcal, không đo nhịp tim, không Focus Area"; app không hỏi cân nặng; giảm cân xếp sau vì "nhóm này nhạy giá nhất" — [app-context.md](/home/user/gentle-walk-50/app-context.md)
- Luật copy cấm "tuyên bố y khoa hoặc giảm nguy cơ ngã", "rehab, therapy". Bản rà soát chọn chip "I feel unsteady on my feet" và tránh chữ "fall" trên chip, lời HLV và copy công khai — [app-context.md](/home/user/gentle-walk-50/app-context.md); [review 06/10](/home/user/gentle-walk-50/docs/reviews/2026-10-06-chuyen-gia-ra-soat-bai-tap-58-75.md) Q3

Bảng ánh xạ (đọc từ mã và nội dung ở trên):

| Ngách | Đã có | Phải làm mới nếu chọn làm ngách chính |
|---|---|---|
| A Thăng bằng + đứng dậy khỏi ghế | Steady set mọi ngày tập (cả free); 6 bài balance + Weight shift, Single-leg stand, Heel and toe raises; SupportLadder; chip unsteady; mv.sit-to-stand + đoạn `ses.chair.to-stand.sts`; SitToStandDetector; ChairAnswer; khẩu hiệu | Chương trình có điểm đầu và điểm cuối (8–12 tuần, theo WFG ≥12 tuần); luật tăng rep sit-to-stand theo khả năng (Otago 2×10 mới tăng); tự kiểm tra định kỳ (đếm ngồi–đứng 30 giây, tư thế đứng 4 mức) dạng "so với chính mình"; biểu đồ tiến bộ; sửa bộ dò; đọc Walking Steadiness từ HealthKit (tuỳ chọn) |
| B Cứng người / linh hoạt | 13 động tác giãn; 6 buổi stretch; morning; cooldown | Lộ trình theo vùng (cổ vai, lưng trên, hông); tự kiểm tra tầm vận động (khó đo bằng điện thoại); nhiều buổi hơn để đấu Bend |
| C Đau gối/hông | Chip knees/hips/jointReplacement; `easierFor`; This hurts / PainRules; Seated leg extension, Knee curl, Mini-squat | Chương trình tăng sức mạnh cơ đùi kiểu OARSI; theo dõi mức đau (tự báo cáo); mọi copy về "đau" phải đi qua 1.4.1 |
| D Đi bộ trong nhà | 15 buổi walk ở 3 cấp; hành trình địa danh; đếm bước; ghi workout vào Health; chế độ ngoài trời | Gần như đủ; thiếu tiến trình tổng phút/tuần hướng tới 150 phút (HHS) |
| E Giảm cân | Mục tiêu `loseWeight` | Calo, cân nặng, dinh dưỡng: đi ngược quyết định "không kcal", không hỏi cân nặng |
| F Xương / loãng xương | Gộp vào chip Lower back | Tải nặng và tác động (LIFTMOR): trái với `noJumping`, "không xuống sàn" và nhóm người mới tập |
| G Tư thế / lưng | Chin tuck, Chest and shoulders, Standing back extension, Upper back reach/twist; chip lowerBack | Theo dõi tư thế (ví dụ cảm biến AirPods) là tính năng mới hoàn toàn; bộ bài lưng chuyên |

### Inferences
- A là ngách duy nhất mà phần "app làm được, YouTube không làm được" đã có sẵn trong mã: thang vịn tự lên xuống bậc, đếm ngồi–đứng, Steady set chèn vào lịch. Chi phí chuyển sang A chủ yếu là đóng gói (chương trình 12 tuần, tự kiểm tra, biểu đồ), không phải tạo nội dung mới.
- D là "bài mặc định" chứ không phải ngách khác biệt (WalkFit, Walk at Home đã chiếm). Hợp làm cửa vào hằng ngày của ngách A.
- B có nội dung nhưng đối đầu thẳng Bend.
- C, E, F, G đòi nội dung, đo lường hoặc lời hứa mà app hiện không có hoặc đã chủ động loại.

### Gaps
- Chưa đếm số câu thoại (voice lines) theo từng ngách. Chưa ước tính số giờ code cho từng hạng mục "phải làm mới".

## 2. Thứ app làm được mà YouTube miễn phí không làm được (đo lường, tiến trình, thích nghi, nhắc, Health), và giới hạn của bộ đếm ngồi–đứng

### Takeaway
Ở mọi ngách, YouTube (yes2next, Leslie Sansone) đã cho nội dung miễn phí, có cả bản ngồi lẫn bản đứng. App chỉ hơn ở: (1) tiến trình tự điều chỉnh theo từng người, (2) đo kết quả "so với chính mình", (3) nhắc và lịch tập, (4) Apple Health. Ngách A có chỉ số đo được bằng điện thoại và đã được kiểm chứng: số lần ngồi–đứng trong 30 giây. Tuy vậy, bộ dò hiện tại chưa đủ tin để làm chỉ số chính.

### Cited Findings
- yes2next: khoảng 300 video miễn phí; trong cùng một video có bản đứng và bản ngồi; có "15-Day Better Balance Challenge" và nhóm bài thăng bằng. App trả phí Get Moving 50+ (Studio.com) có kế hoạch mỗi ngày, AI hỏi đáp, theo dõi chuỗi ngày tập, và gắn nhãn nhóm bài "fall prevention" — [docs/research/2026-10-07-yes2next.md](/home/user/gentle-walk-50/docs/research/2026-10-07-yes2next.md)
- Nghiên cứu 24 người làm bài đứng lên ngồi xuống 30 giây, đếm bằng gia tốc kế iPhone: tương quan với đếm tay PCC = 0,890; >95% điểm Bland–Altman nằm trong giới hạn đồng thuận 95%; độ tin cậy lặp lại ICC = 0,968 — [JMIR mHealth 2017, "iPhone sensors in tracking outcome variables of the 30-second chair stand test"](https://pmc.ncbi.nlm.nih.gov/articles/PMC5681723); [UKY scholars](https://scholars.uky.edu/en/publications/iphone-sensors-in-tracking-outcome-variables-of-the-30-second-cha/)
- Bộ dò hiện tại (đọc mã): ngưỡng lobe gia tốc dọc 0,12 g, lobe phải kéo dài ≥0,12 s, khoảng cách giữa hai lobe ≤0,6 s, một rep ≤8 s. "Lean" lấy từ `abs(sample.pitchDegrees)` ≥10° (pitch tuyệt đối, không trừ góc lúc bắt đầu). Chỉ báo `confident` khi mọi rep có lean — [SitToStandDetector.swift](/home/user/gentle-walk-50/iOS/Packages/GentleWalkCore/Sources/GentleWalkCore/Motion/SitToStandDetector.swift)
- Hiện trạng sản phẩm: mặc định đếm giờ, "luôn có đếm tay", tự đếm chỉ khi áp điện thoại vào ngực, không lên listing — [app-context.md](/home/user/gentle-walk-50/app-context.md)
- HealthKit cho app bên thứ ba dùng Walking Steadiness của iPhone (`appleWalkingSteadiness`, `HKAppleWalkingSteadinessClassification`, `appleWalkingSteadinessEvent`). Apple mô tả chỉ số này giúp app "interpret someone's quality of walking and risk of falling". Có `sixMinuteWalkTestDistance` (Apple Watch tự ghi hằng tuần; app được phép ghi mẫu riêng) — [WWDC21 10287](https://developer.apple.com/videos/play/wwdc2021/10287/); [HealthKit docs sixMinuteWalkTestDistance](https://developer.apple.com/documentation/healthkit/hkquantitytypeidentifier/sixminutewalktestdistance)

### Inferences
- Bộ dò đặt sai giả định cho chính nhóm khách cần nó nhất:
  - Người đứng dậy chậm, đứng dậy nhờ chống tay, hoặc nhóm "unsteady" sinh gia tốc đỉnh thấp và lobe dài, dễ không vượt ngưỡng 0,12 g nên bị đếm thiếu.
  - Pitch tuyệt đối làm "lean" phụ thuộc cách cầm máy: máy nghiêng sẵn >10° thì rep nào cũng được tính là có lean; cầm thẳng mà người ít cúi thì `confident` = false.
  - Bài sit-to-stand trong app cho phép dùng tay (`ses.chair.to-stand` "Hands on the chair, then stand"), khác bài test chuẩn 30 giây (khoanh tay, ghế cao chuẩn). Vì vậy số đếm không so được với bảng chuẩn nếu sau này muốn dùng.
  - Nghiên cứu JMIR chỉ có 24 người, gắn máy và làm theo quy trình chuẩn, nên không chứng minh bộ dò của app đúng.
- Muốn dùng "số lần đứng dậy trong 30 giây" làm chỉ số chính của ngách A:
  - Cần đổi lean sang góc tương đối so với lúc ngồi yên (baseline 1–2 s đầu), ngưỡng thích nghi hoặc thêm điều kiện theo thời lượng, và thử trên người 65+ đứng dậy chậm.
  - Luôn cho sửa số bằng tay, và không gọi đó là "test" hay so với bảng chuẩn theo tuổi (xem mục 3 về 1.4.1).
  - Phương án an toàn hơn cho bản 1.0: người dùng tự đếm, app chỉ bấm giờ 30 giây và vẽ đường tiến bộ của chính họ.
- Ở ngách B, C, G, điện thoại không có chỉ số khách quan rẻ và tin được. Tầm vận động và tư thế cần camera/pose hoặc AirPods; "mức đau" chỉ là tự báo cáo. Lợi thế so với YouTube vì vậy chỉ còn tiến trình và nhắc. Ở ngách D có bước chân và phút tập (đã có).
- Đọc Walking Steadiness là điểm cộng cho ngách A, nhưng chỉ nên hiện xu hướng do Apple tính, không tự diễn giải nguy cơ ngã. Chỉ số này còn cần iPhone 8 trở lên và người dùng mang điện thoại khi đi (giới hạn chưa kiểm chứng trong ghi chú này).

### Gaps
- Không đọc được toàn văn nghiên cứu JMIR (đặc điểm người tham gia, vị trí đặt máy). Không có dữ liệu về độ chính xác của thuật toán kiểu ngưỡng lobe ở người đứng dậy chậm.
- Chưa xác minh điều kiện thiết bị của Walking Steadiness trong nguồn chính thức (trang Apple bị giới hạn trong phiên này).

## 3. Rủi ro App Store (1.4.1) và pháp lý Mỹ (FDA General Wellness, FTC) theo từng cụm từ

### Takeaway
Ngách A, B, D và G làm được hoàn toàn bằng lời nói kiểu wellness ("steadier", "getting up from a chair", "looser", "stand tall"). Ngách C và F đòi lời hứa về bệnh hoặc triệu chứng ("reduce knee pain", "build bone"). Ngách E đòi lời hứa kết quả cân nặng. Ba ngách này dễ chạm FDA (claim điều trị), FTC (cần RCT) và 1.4.1. "Fall prevention" là cụm từ rủi ro nhất cho ngách A: các app đo nguy cơ ngã là thiết bị y tế được FDA cấp phép. Nên bán ngách A bằng chức năng ("steadier on your feet", "get up from a chair more easily"), không bằng "ngã".

### Cited Findings
- 1.4.1 nguyên văn: "Medical apps that could provide inaccurate data or information, or that could be used for diagnosing or treating patients may be reviewed with greater scrutiny. Apps must clearly disclose data and methodology to support accuracy claims relating to health measurements, and if the level of accuracy or methodology cannot be validated, we will reject your app… Apps should remind users to check with a doctor in addition to using the app and before making medical decisions." — [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- 2.3.1(a): quảng cáo app sai sự thật ("promoting content or services that it does not actually offer") có thể bị gỡ app và khoá tài khoản — [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- 5.1.3(ii): "Apps must not write false or inaccurate data into HealthKit… and may not store personal health information in iCloud" — [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- Bị từ chối theo 1.4.1 vì thiếu trích dẫn: app mẹo ăn, vận động, ngủ, giảm cân bị từ chối "due to lack of citations". Người trả lời trên diễn đàn: mỗi lời khẳng định sức khoẻ cần 1–2 nguồn y khoa kiểm chứng được — [Apple Developer Forums 696430](https://developer.apple.com/forums/thread/696430)
- Bị từ chối theo 1.4.1 dù tự nhận "wellness-only": app chỉ báo stress/HRV dạng khoảng tương đối, đã có disclaimer, vẫn nhận "Medical-related data, health-related measurements, diagnoses or treatment advice without appropriate regulatory clearance". Apple không giải thích ranh giới, chỉ gợi ý kháng nghị (11/2025) — [Apple Developer Forums 807508](https://developer.apple.com/forums/thread/807508)
- FDA General Wellness: bản 06/01/2026 thay bản 09/2019. Bản mới giữ khung hai điều kiện (chỉ dùng cho wellness và rủi ro thấp) và hai loại claim: (1) claim wellness thuần, không nhắc bệnh (quản lý cân nặng, thể lực, ngủ); (2) claim nhắc bệnh gắn với lối sống lành mạnh, chỉ khi "well understood" rằng lối sống đó "may help reduce the risk" hoặc "may help living well with" bệnh mạn tính — [Foley](https://www.foley.com/p/102meea/digital-health-policy-fda-relaxes-restrictions-over-wearables-and-ai-decision-ma/); [King & Spalding](https://www.kslaw.com/news-and-insights/fda-updates-general-wellness-and-clinical-decision-support-guidance-documents); [Covington (tiêu đề)](https://www.cov.com/en/news-and-insights/insights/2026/01/fda-issues-revised-guidance-on-general-wellness-products)
- Bản 2026 nới cho wearable ước tính chỉ số sinh lý (huyết áp, đường huyết, SpO2, HRV) nếu chỉ dùng cho wellness. Không thấy thay đổi riêng cho app tập luyện — [Foley](https://www.foley.com/p/102meea/digital-health-policy-fda-relaxes-restrictions-over-wearables-and-ai-decision-ma/)
- Ví dụ FDA cho loại (2): "promote physical activity, which, as part of a healthy lifestyle, may help reduce the risk of high blood pressure"; app theo dõi calo giúp "live well with high blood pressure and type 2 diabetes". Claim chẩn đoán, điều trị, chữa hoặc phòng một bệnh nằm ngoài chính sách wellness, ví dụ "helps treat an anxiety disorder" — [NatLawReview](https://www.natlawreview.com/article/fda-finalizes-general-wellness-guidance); [RegDesk](https://www.regdesk.co/blog/fda-guidance-summary-general-wellness-policy-for-low-risk-devices/)
- Đánh giá thăng bằng / nguy cơ ngã là thiết bị y tế:
  - Sway Balance (app iOS dùng gia tốc kế) được FDA cấp 510(k) K121590 năm 2012, chỉ dùng theo chỉ định.
  - BTrackS đăng ký theo 21 CFR 890.1575.
  - Kinesis Balance tự mô tả là app smartphone "for assessment of balance and falls risk in older adults" (có mã thiết bị GUDID).
  - Nguồn: [510k Innolitics K121590](https://510k.innolitics.com/device/K121590); [MobiHealthNews Sway](https://mobihealthnews.com/node/108856); [AccessGUDID Kinesis Balance](https://accessgudid.nlm.nih.gov/devices/05391542950027)
- FTC Health Products Compliance Guidance (20/12/2022): áp cho mọi claim sức khoẻ, kể cả app. Chuẩn là "competent and reliable scientific evidence", thường là RCT trên người. Nghiên cứu quan sát, khuyến nghị y tế công cộng và lời kể cá nhân thường không đủ — [Covington](https://www.cov.com/en/news-and-insights/insights/2023/01/ftc-issues-new-guidance-on-health-related-claims-to-replace-the-dietary-supplements-advertising-guide); [Jones Day](https://jonesday.com/pt/insights/2023/01/ftc-overhauls-and-expands-25yearold-health-products-advertising-compliance-guide)
- Tiền lệ FTC với app: Lumosity trả 2 triệu USD (2016) vì claim "10–15 phút vài lần mỗi tuần" làm chậm suy giảm trí nhớ do tuổi tác mà không có bằng chứng. Lệnh buộc phải có "competent and reliable scientific evidence" trước mọi claim về suy giảm do tuổi tác. FTC cũng xử lời chứng thực khách hàng không công khai việc được thưởng — [The Register](https://www.theregister.com/2016/01/05/lumosity_ftc_2m_false_claims/); [Olshan](https://www.olshanlaw.com/Advertising-Law-Blog/Luminosity-FTC-Charges-Deceptive-Advertising)
- Bằng chứng nền cho ngách A: WFG 2022 khuyến nghị bài thăng bằng + chức năng ≥3 buổi/tuần, ≥12 tuần (GRADE 1A), và "general physical activity alone (e.g. walking) is unlikely to prevent falls". Otago giảm 35% số ca ngã trong thử nghiệm có giám sát. Bản rà soát ghi rõ con số này "không được mượn vào copy" — [review 06/10](/home/user/gentle-walk-50/docs/reviews/2026-10-06-chuyen-gia-ra-soat-bai-tap-58-75.md) [N2], [S15]
- StandingTall (RCT, BMJ 2021, 503 người ≥70 tuổi, 2 năm): nhóm can thiệp có tỷ lệ ngã thấp hơn 16% và ngã có chấn thương thấp hơn 20% sau 2 năm. Ở mốc 12 tháng, tiêu chí chính không có ý nghĩa — [BMJ 2021;373:n740](https://www.bmj.com/content/373/bmj.n740); [Maastricht CRIS](https://cris.maastrichtuniversity.nl/en/publications/e-health-standingtall-balance-exercise-for-fall-prevention-in-old)
- Bằng chứng nền cho ngách F: trong LIFTMOR, bài tập giúp xương là tập tải nặng và tác động có giám sát (5×5 ở >85% 1RM, 8 tháng). Nhóm đối chứng tập nhẹ tại nhà: 72,1% bị giảm mật độ xương cột sống thắt lưng (so với 18,6% ở nhóm tập nặng) — [JBMR 2018 (Watson)](https://academic.oup.com/jbmr/article/33/2/211/7605709); [Healio](https://www.healio.com/news/endocrinology/20171004/highintensity-training-increases-bmd-in-postmenopausal-women)
- Bằng chứng nền cho ngách C: OARSI 2019 xếp chương trình tập trên cạn có cấu trúc (sức mạnh, cardio, thăng bằng; tai chi/yoga) là "Core" cho thoái hoá khớp gối/hông — [review 06/10](/home/user/gentle-walk-50/docs/reviews/2026-10-06-chuyen-gia-ra-soat-bai-tap-58-75.md) [N7]

Bảng cụm từ (suy luận từ các nguồn trên, chưa có luật sư duyệt):

| Cụm từ | Mức rủi ro | Lý do |
|---|---|---|
| "Steadier on your feet", "Feel steadier", "Get up from a chair more easily", "Balance moves with a chair beside you" | Thấp | Chức năng hằng ngày, không nhắc bệnh, đúng loại (1) |
| "Helps maintain balance as part of an active life" | Thấp–vừa | Gần loại (1); tránh gắn với "falls" |
| "Fall prevention", "Prevent falls", "Reduce your risk of falling" | Cao | "Prevent" là claim phòng bệnh hoặc chấn thương. App đánh giá nguy cơ ngã là thiết bị được FDA cấp phép. FTC đòi RCT trên đúng sản phẩm. Otago và StandingTall có RCT nhưng chương trình khác và có giám sát. Luật copy của app đã cấm |
| "Looser, less stiff", "Move more freely" | Thấp | Loại (1) |
| "Reduce knee pain", "Relieve joint pain", "Arthritis relief" | Cao | Claim điều trị triệu chứng hoặc bệnh. yes2next dùng "relieve joint pain", app đã chốt không dùng |
| "Gentle moves for achy knees", "Knee-friendly" | Vừa | Không hứa kết quả, nhưng 1.4.1 có thể đòi trích dẫn hoặc nhắc hỏi bác sĩ |
| "Build bone", "Strengthen bones", "Reverse osteoporosis" | Cao, và sai sự thật với app này | Bài nhẹ tại nhà là đúng loại bài của nhóm đối chứng LIFTMOR. "Reverse" là claim điều trị |
| "Lose weight", "Burn fat" | Vừa–cao | FTC soi kỹ claim giảm cân. "burn" đã bị cấm trong copy |
| "Fix your posture", "Back pain relief" | Vừa–cao | "Sửa tư thế, chữa khớp" đã bị cấm trong luật giãn cơ |

### Inferences
- Định vị theo ngách A an toàn khi bán bằng kết quả chức năng (đứng dậy khỏi ghế, đi qua lối hẹp, đứng vững khi xếp hàng). Bản thân `purpose` của từng động tác đã viết theo cách này.
- Mọi phiên bản "test" hay "score" có thang chuẩn theo tuổi hoặc nhãn nguy cơ sẽ đưa app vào vùng "health measurement" của 1.4.1 (phải công bố phương pháp và độ chính xác) và gần với Sway/Kinesis về FDA. Nên gọi là "your chair count" hoặc "self-check", chỉ so với chính mình, kèm nhắc hỏi bác sĩ (đã có trên S06).
- Đổi sang ngách C hoặc F buộc phải viết copy kiểu "for your knees" mà không hứa giảm đau, hoặc "bone-friendly" mà không hứa tăng xương. Lời hứa yếu nên bán khó hơn đối thủ dám nói "relieve". Nếu làm, đó là rủi ro cạnh tranh, không phải rủi ro pháp lý.
- Rủi ro 1.4.1 không chỉ nằm ở chữ. Bằng chứng: app wellness-only vẫn bị từ chối (thread 807508). Cần review notes trích nguồn (WHO, WFG, NIA, Otago) và nhắc "check with your doctor" như đã làm.

### Gaps
- Không đọc được toàn văn hướng dẫn FDA 2016/2019/2026 (fda.gov bị chặn). Chưa xác minh hướng dẫn có ví dụ nào về thăng bằng, ngã, viêm khớp hay loãng xương. Các ví dụ dẫn ở trên chỉ là huyết áp, tiểu đường type 2 và lo âu. Muốn biết "may help living well with osteoarthritis" có lọt loại (2) không, cần đọc bản gốc hoặc hỏi luật sư.
- Không tìm được ca từ chối App Store công khai nào nêu đích danh cụm "fall prevention" hay "pain relief" ở app tập luyện. Hai thread đọc được là app mẹo sức khoẻ và app chỉ số stress.
- Không tìm được vụ FTC nào nhắm app bài tập cho người lớn tuổi.

## 4. Bằng chứng về độ bám tập (adherence) và giữ chân: chương trình một vấn đề so với app tập chung; sẵn lòng trả tiền

### Takeaway
Chương trình có cấu trúc, có điểm kết thúc, giải đúng một vấn đề có độ bám cao hơn hẳn mức nền. Các ví dụ: StandingTall 68% sau 1 năm, Hinge 73% hoàn thành 12 tuần. Nhưng các con số cao này đều có điều kiện mà app indie không có: được cấp miễn phí, có huấn luyện viên người thật, hoặc nằm trong thử nghiệm. Ở bên ngoài, bám tập 3 lần/tuần sau 1 năm chỉ khoảng 25–37%; chương trình 9 tuần kiểu Couch-to-5K chỉ khoảng 27% làm hết. Trong dữ liệu review của chính repo, nhóm "balance/fall" và "flex/stiff" hài lòng cao, nhưng tỷ lệ người nói sẵn sàng trả tiền thì không cao hơn nhóm khác.

### Cited Findings
- StandingTall: 80% còn dùng sau 6 tháng, 68% sau 1 năm, 52% sau 2 năm. Mức dùng đặt ra 2 giờ/tuần. Đây là người tham gia thử nghiệm, được phát chương trình miễn phí — [BMJ 2021;373:n740](https://www.bmj.com/content/373/bmj.n740); [Maastricht CRIS](https://cris.maastrichtuniversity.nl/en/publications/e-health-standingtall-balance-exercise-for-fall-prevention-in-old)
- Otago tại nhà: trong 747 người còn lại ở mốc 12 tháng, 274 người (36,7%) còn tập ≥3 lần/tuần. Một nghiên cứu khác: ở 12 tháng, 25% tập ≥3 lần/tuần, 55% tập ≥2 lần/tuần — [Age and Ageing 2010;39(6):681](https://academic.oup.com/ageing/article/39/6/681/9467) (đoạn trích tìm kiếm, chưa đối chiếu từng con số với bài)
- Tổng quan hệ thống: chương trình tập có công nghệ ở người lớn tuổi có độ bám trung vị 91,25%, cao hơn chương trình truyền thống. Một nghiên cứu khác ghi bám tập tại nhà chỉ khoảng 30%. Độ bám dao động rất rộng giữa các nghiên cứu — [J Geriatr Phys Ther, Adherence to Technology-Based Exercise Programs in Older Adults](https://www.ovid.com/jnls/jgpt/abstract/10.1519/jpt.0000000000000095~adherence-to-technology-based-exercise-programs-in-older?redirectionsource=fulltextview); [Age and Ageing 2022 meta-analysis](https://academic.oup.com/ageing/article/51/11/afac243/6806169)
- App bài tập cơ xương khớp tại nhà cho người lớn tuổi (thí điểm): bám tập trung bình 84% trong 8 tuần, 95% người tham gia ở lại — [JMIR mHealth 2021;9(1):e21094](https://mhealth.jmir.org/2021/1/e21094/)
- Hinge Health: tỷ lệ hoàn thành chương trình 12 tuần là 73%, nhờ "1-on-1 coaching", trung bình 35 buổi. Người hoàn thành tập trung bình 90% số tuần. Hinge được trả qua chủ lao động hoặc bảo hiểm, người dùng không tự trả. Con số này do chính công ty công bố — [BusinessWire 2021](https://www.businesswire.com/news/home/20210825005182/en); [Hinge press release](https://hingehealth.com/resources/press-releases/worlds-largest-digital-msk-study)
- Couch-to-5K: một nghiên cứu ghi 27,3% làm hết chương trình 9 tuần sửa đổi. Yếu tố dự báo bỏ cuộc là tốc độ tăng tải và chấn thương (19% bị chấn thương cơ xương) — [IJERPH 2023;20:6682](https://clok.uclan.ac.uk/48883/1/ijerph-20-06682.pdf); [WCRF](https://www.wcrf.org/about-us/news-and-blogs/from-couch-to-5k-how-apps-are-getting-people-physically-active/)
- Dữ liệu review trong repo, nhóm theo nhu cầu (15.756 review của 107 app; wtp+ = tỷ lệ review nói sẵn lòng trả, 1–2★ = tỷ lệ review 1–2 sao):

  | Nhu cầu | Số review | Sao TB | wtp+ | 1–2★ | Tuổi trung vị |
  |---|---|---|---|---|---|
  | Cứng người (flex_stiff) | 741 | 4,62 | 5,4% | 6,3% | 65 |
  | Đau khớp (joint_pain) | 807 | 4,49 | 4,0% | 9,4% | 65,5 |
  | Thăng bằng / ngã (balance_fall) | 393 | 4,54 | 2,8% | 8,7% | 68 |
  | Giảm cân (weight) | 559 | 4,33 | 2,9% | 13,2% | 68 |

  Nguồn: [2026-10-03-review-analysis.txt](/home/user/gentle-walk-50/docs/research/data/2026-10-03-review-analysis.txt) mục BY NEED.
- Cùng file đó, nhóm app lâm sàng/PT (Omada Joint & Muscle, Joint Academy…): sao trung bình 3,45, 33,4% review 1–2★, wtp+ chỉ 0,4% — [2026-10-03-review-analysis.txt](/home/user/gentle-walk-50/docs/research/data/2026-10-03-review-analysis.txt)
- Trong review từng app lớn, nhu cầu được nhắc nhiều nhất là joint_pain và flex_stiff, thường 18–29% mỗi loại. balance_fall chỉ khoảng 2,6–10% — [2026-10-03-review-analysis.txt](/home/user/gentle-walk-50/docs/research/data/2026-10-03-review-analysis.txt) dòng 4–12
- Thông báo nhắc mất tác dụng sau khoảng 4 tuần (HeartSteps), nên app đã chốt kho câu xoay vòng và giảm dần — [app-context.md](/home/user/gentle-walk-50/app-context.md) Risks

### Inferences
- Độ bám cao trong các chương trình một vấn đề đi kèm ba thứ: mục tiêu rõ có điểm kết thúc, tăng tải chậm và cá nhân hoá, và người thật theo dõi hoặc được cấp miễn phí. App indie lấy được hai thứ đầu (chương trình 12 tuần, thang vịn, Adaptation). Thứ ba thì không. Dự báo thực tế nên lấy mức Otago tại nhà (25–37% sau 1 năm), không lấy StandingTall hay Hinge.
- Trong review, thăng bằng ít được nhắc hơn đau khớp hay cứng người. Đây là nhu cầu người dùng không tự gọi tên nhiều: "sợ ngã" khó nói ra, trong khi "cứng người" và "đau gối" thì dễ nói. Ngách A vì vậy nên được bán bằng ngôn ngữ cứng người và đứng dậy khó, còn sản phẩm thì giải bằng thăng bằng. Cách này khớp với khẩu hiệu hiện tại.
- Nhóm C (đau khớp) có cầu cao nhất nhưng là sân của sản phẩm lâm sàng miễn phí qua bảo hiểm (Hinge, Sword, Omada). Người dùng đánh giá thấp nhóm này và gần như không nói sẵn lòng trả. App tự trả tiền khó cạnh tranh nếu không dám hứa "giảm đau".
- Chưa có bằng chứng định lượng rằng app "một vấn đề" giữ chân tốt hơn app tập chung trên thị trường tự trả tiền. Bằng chứng chỉ gián tiếp, qua chương trình có cấu trúc.

### Gaps
- Không có số giữ chân (D30/D90) công khai cho app tập luyện thương mại theo ngách. Không có số hoàn thành chương trình của Sword (chỉ thấy số Hinge, do Hinge tự công bố).
- Không tìm được nghiên cứu so trực tiếp sẵn lòng trả cho chương trình theo vấn đề với thư viện chung ở người 58–75.
- Không xác minh được từng con số Otago với toàn văn bài (chỉ có đoạn trích).

## 5. Đội nhỏ nên làm app một vấn đề hay app tập nhẹ diện rộng (case thị trường, benchmark RevenueCat)

### Takeaway
Benchmark Health & Fitness cho thấy tiền nằm ở gói năm và tỷ lệ gia hạn thấp: trung vị gia hạn gói năm 25%. Lời hứa rõ ràng, đo được kết quả giúp vượt trung vị. Ví dụ thị trường gần nhất là Bend: một trục duy nhất (giãn cơ), khoảng 0,7–1 triệu USD/tháng. Ngược lại, app "một vấn đề y khoa" (đau lưng, tư thế) có doanh thu rất nhỏ. Hướng hợp lý cho đội nhỏ: một lời hứa chính (vững chân) làm trục cho onboarding, chương trình và đo lường, nhưng giữ thư viện rộng (đi bộ, ghế, giãn cơ) làm lý do dùng hằng ngày. Không thu hẹp thành app chữa một bệnh.

### Cited Findings
- RevenueCat (báo cáo 2025/2026, qua đoạn trích tìm kiếm), nhóm Health & Fitness:
  - Trial → trả tiền: trung vị 39,9%, top 10% đạt 68,3%. Trial 17–32 ngày có tỷ lệ chuyển đổi trung vị cao nhất, 45,7%.
  - Gia hạn gói năm: P25 = 16%, trung vị 25%, P75 = 37%. Gia hạn gói tháng: 46% / 57% / 68%.
  - Doanh thu thực tế sau 1 năm (RLTV) trung vị 35,64 USD mỗi người trả tiền.
  - Gói năm chiếm 59–60,6% doanh thu; 68% gói là gói năm.
  - Doanh thu mỗi lượt cài (RPI) trung vị 0,48 USD ở ngày 14 và 0,66 USD ở ngày 60.
  - Người đi qua trial có LTV cao hơn 63,6% so với người mua thẳng.
  - Tỷ lệ hoàn tiền nhóm Health & Fitness 4,71% (2025), cao thứ hai sau Education.
  - Nguồn: [RevenueCat SOSA 2026](https://www.revenuecat.com/state-of-subscription-apps); [SOSA 2025](https://www.revenuecat.com/state-of-subscription-apps-2025); [RevenueCat renewal benchmarks](https://www.revenuecat.com/blog/growth/average-subscription-renewal-rates-by-app-category); [tasu.ai RPI](https://tasu.ai/library/app-category-revenue-per-install-benchmark). Không mở được trang gốc để kiểm từng số.
- Bend (một trục giãn cơ): khoảng 0,7–1 triệu USD/tháng (Sensor Tower, AppMagic >1 triệu USD/30 ngày), xếp hạng #65 → #41, 9% review 1–2★, doanh thu/lượt tải tháng khoảng 7 USD. Thuộc nhóm "Thống trị mảng giãn cơ" — [kiem-tien-dinh-vi-doi-thu.md](/home/user/gentle-walk-50/docs/research/2026-10-03-kiem-tien-dinh-vi-doi-thu.md) dòng 134, 171; [niche-apps.csv](/home/user/gentle-walk-50/docs/research/data/2026-10-03-niche-apps.csv)
- Một nguồn ngoài ghi Bend "$550k in revenue" và ">10 million users", nhưng không rõ kỳ tính. Lệch với số Sensor Tower trong repo — [ScreensDesign](https://screensdesign.com/apps/stretching-flexibility-bend/)
- LazyFit (chủ đề rộng cho người mới: ghế, tai chi, pilates): Sensor Tower khoảng 800 nghìn USD/tháng, doanh thu/lượt tải khoảng 8 USD. WalkFit (đi bộ) khoảng 300 nghìn USD/tháng, khoảng 4,3 USD — [niche-apps.csv](/home/user/gentle-walk-50/docs/research/data/2026-10-03-niche-apps.csv); [kiem-tien-dinh-vi-doi-thu.md](/home/user/gentle-walk-50/docs/research/2026-10-03-kiem-tien-dinh-vi-doi-thu.md)
- App một vấn đề y khoa trong cùng tập dữ liệu: "Back pain exercises at home" <5 nghìn lượt tải và <5 nghìn USD/tháng. "ROM Coach" <5 nghìn USD. "Perfect Posture: Back & Neck" chỉ có 337 đánh giá ở Mỹ. Không có app riêng cho thăng bằng/ngã nào lọt vào tập 107 app. Các app "Tai Chi for Seniors" mới (2025–2026) có hàng nghìn đánh giá nhờ quảng cáo — [niche-apps.csv](/home/user/gentle-walk-50/docs/research/data/2026-10-03-niche-apps.csv)
- Các app doanh thu cao nhất ngách đạt mức của mình nhờ quiz onboarding, trial gói năm chọn sẵn, gói phụ và quảng cáo nhắm đúng tệp — [kiem-tien-dinh-vi-doi-thu.md](/home/user/gentle-walk-50/docs/research/2026-10-03-kiem-tien-dinh-vi-doi-thu.md) dòng 210
- Đối thủ trực tiếp ở ngách A: Get Moving 50+ (yes2next) dán nhãn "fall prevention", có thương hiệu người thật và kênh khoảng 650 nghìn người đăng ký. Bold/SilverSneakers có lớp thăng bằng miễn phí qua bảo hiểm — [yes2next.md](/home/user/gentle-walk-50/docs/research/2026-10-07-yes2next.md); [app-context.md](/home/user/gentle-walk-50/app-context.md)

### Inferences
- Thị trường thưởng app "một trục, nhiều nội dung" (Bend: chỉ giãn cơ, nhưng thư viện lớn và cá nhân hoá). Không thấy thị trường thưởng app "một bệnh" (đau lưng, tư thế: doanh thu nhỏ). Ngách A theo nghĩa "vững chân trong sinh hoạt" giống mẫu Bend. "Phòng ngã" giống mẫu app bệnh, và còn vướng pháp lý.
- Với trung vị gia hạn năm 25%, lý do người dùng ở lại sang năm thứ hai phải là thứ đo được và còn tiếp tục: số lần đứng dậy, bậc vịn, tổng phút tập/tuần. Ngách A có sẵn các thước đo này. Ngách B, C, G thì không.
- Đội nhỏ, không backend, không người thật theo dõi, không có bằng chứng lâm sàng riêng thì không nên làm phiên bản "lâm sàng" của bất kỳ ngách nào (C, F, phòng ngã). Nên làm phiên bản wellness của ngách A: chương trình 12 tuần "Steady", tự kiểm tra so với chính mình, thang vịn. Giữ đi bộ, ghế, giãn cơ làm phần hằng ngày, để không thành "simple timer" (4.3) và không mất người đến vì cứng người.
- Không thấy app thăng bằng chuyên biệt trong top doanh thu. Có hai cách hiểu: (a) khoảng trống, hoặc (b) nhu cầu không tự gọi tên nên khó bán (khớp với tỷ lệ nhắc thấp trong review, mục 4). Cần kiểm bằng test quảng cáo/ASO trước khi coi là khoảng trống.

### Gaps
- Không mở được báo cáo RevenueCat hay Adapty gốc. Chưa có số tách theo ngách con của Health & Fitness, theo tuổi người dùng, hay theo app một vấn đề so với app rộng.
- Không có case study công khai về doanh thu của Calm/Bend giai đoạn đội nhỏ. Số Bend trong repo là ước tính Sensor Tower/AppMagic, nguồn ngoài cho số khác.
- Chưa có dữ liệu lượng tìm kiếm App Store cho "balance exercises", "chair exercises", "fall prevention" ở Mỹ (có thể lấy bằng Semrush hoặc Apple Search Ads ở bước khác).
