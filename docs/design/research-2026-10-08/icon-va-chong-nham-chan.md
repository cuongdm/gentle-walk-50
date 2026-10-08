# Icon cho mọi lựa chọn và chống nhàm chán — nghiên cứu 08/10/2026

_Người làm: UX (Fable 5.1) · Phạm vi: nghiên cứu + spec, **chưa sửa code, nội dung hay tài liệu cũ**; file mới chỉ trong thư mục này. Bằng chứng: 50 ảnh `ip11/`, mã `iOS/App/**`, nội dung `iOS/App/Resources/Content/*.json`, ba báo cáo cùng ngày (`tong-hop.md`, `ui-ux-va-onboarding.md`, `font-va-hinh-anh.md`, `../../research/2026-10-08-ca-nhan-hoa.md`). Mockup: `icon-mockups.html` → `icon-mockups/*.png` (375×667, đã xem bằng mắt)._

## 0) Kết luận 6 dòng

1. **"Icon ở mọi lựa chọn và mọi màn" — OK có điều kiện:** icon giúp khi là **vật cụ thể, quen thuộc, luôn đi kèm chữ** (ghế, chuông, cốc cà phê, thẻ tín dụng); hại khi trừu tượng, khi đứng một mình, hoặc khi "trang trí" từng dòng chữ. Nghiên cứu theo tuổi (Leung 2011, Ghayas 2013, Gatsou 2011) nói đúng điều này: người lớn tuổi hiểu icon kém hơn và **chữ mới là thứ họ dựa vào**; icon là mốc để tìm nhanh, không phải để đọc.
2. Quy tắc: **icon + chữ, không bao giờ icon một mình; SF Symbols; một nghĩa cho một biểu tượng toàn app; 24–28 pt trên vệt màu nước 44–56 pt; icon ẩn khỏi VoiceOver, chữ mang nghĩa.** Hiện app vi phạm "một nghĩa": `chair.fill` vừa là buổi ghế vừa là tự kiểm tra; `figure.stand` vừa là mục tiêu "vững" vừa là dải chương trình; `hand.raised.fill` vừa là "This hurts" vừa là bước "khoanh tay" của tự kiểm tra.
3. Có icon rồi: mục tiêu (7), tab (4), paywall timeline (3), permissions (2), Up next (6), tự kiểm tra (4), Help (4), loại buổi ở Preview. **Chưa có:** rào cản (6), mức vận động (4), câu hỏi ghế (3), 10 chip cơ thể, 4 mốc nhắc, ~14 hàng Me, thẻ Today, 3 ô thống kê Complete, thẻ Progress, 4 ô Outdoor prep. Bảng icon đầy đủ ở mục 3. Chip cơ thể: SF Symbols không có gối/hông/lưng/vai → **bộ icon tự vẽ** (hình người của `BodyGlowFigure` + chấm sienna ở vùng đau; mục 2c), 5 icon vùng đau đọc rõ ở 36 pt; 5 icon "Anything else" (sàn, ghế, chóng mặt, không vững, không nhảy) còn yếu, đưa vào test người dùng. **Không icon** cho 3 mức "đứng dậy khỏi ghế" và các thang Achy/Okay/Great, Too easy/Just right/Too hard.
3b. Thẻ lựa chọn gọn (chủ app 08/10): icon 36 pt **cùng hàng** với nhãn, không vòng tròn rỗng, chọn = nền + viền + tick; 6 lựa chọn cao **400 pt** thay vì 502 pt hiện tại (−20 %), 2 cột khi nhãn vừa một dòng → 260 pt (−48 %). Số đo ở mục 2b.
4. Nhàm chán hiện tại là có thật và đo được: người tập 5 ngày/tuần trong 12 tuần nghe **cùng một mẫu đi bộ ~24 lần**, cùng mẫu giãn cơ 12 lần, cùng 2 mẫu Steady set 30 lần mỗi mẫu, **cùng 1 bản nhạc mỗi lần tập** (app có đúng 3 track), thấy cùng một tranh và 3 câu tiêu đề Complete 60 lần; cây đứng yên từ ngày 42 tới hết chương trình; 4/5 hành trình chỉ có **1 câu HLV** cho cả tuyến; 14 câu HLV đã thu (`a9.*`) chưa dùng.
5. Thứ cần làm trước (rẻ, không thu âm): bật 14 câu a9 + mở rộng vòng xoay câu; Complete có 6 biến thể theo ngữ cảnh; thẻ "Mới tuần này" + 12 chủ đề tuần; Today có **lựa chọn thứ hai**; kỷ lục so với chính mình. Cần tiền/asset: ≥ 3 nhạc mỗi loại buổi xoay theo tuần; 5 câu HLV/tuyến cho 4 hành trình Pro; tranh đầu màn theo buổi trong ngày/mùa.
6. Đừng làm: streak, đếm ngược, phần thưởng ngẫu nhiên kiểu "mở hộp", huy hiệu xếp hạng, hoạt ảnh dài. Biến đổi phải **đoán trước được về cấu trúc, mới về nội dung** (cùng chỗ, cùng nút; khác tranh, khác câu, khác chủ đề) — người 58–75 cần bố cục ổn định để không bối rối.

## 1) Nguồn nghiên cứu (đọc/tra 08/10/2026)

| # | Nguồn | Điểm dùng ở đây |
|---|---|---|
| 1 | Harley, NN/g "Icon Usability" (27/07/2014) — https://www.nngroup.com/articles/icon-usability/ | Icon "phổ quát" rất hiếm (home, search, print); luôn kèm **chữ hiện rõ**, không chỉ tooltip; luật 5 giây: nghĩ quá 5 giây chưa ra icon thì icon đó sẽ không truyền được nghĩa |
| 2 | Leung, McGrenere, Graf, *Behaviour & Information Technology* 30(5) 2011, DOI 10.1080/01449290903171308 — https://www.cs.ubc.ca/labs/edapt/papers/leung2011.pdf · hồ sơ UBC https://open.library.ubc.ca/collections/24/items/1.0052115 | Người lớn tuổi hiểu icon điện thoại kém hơn; cải thiện bằng **giảm khoảng cách ngữ nghĩa** (vật vẽ gần với chức năng) và **gắn nhãn**; icon cụ thể (giống vật thật) dễ hơn trừu tượng |
| 3 | Gatsou, Politis, Zevgolis, *Information Services & Use* 2011 — https://content.iospress.com/articles/information-services-and-use/isu657 · bài 2012 *Int. J. Computer Science & Applications* 9(3):92–107 (chỉ thấy mục lục DBLP, chưa đọc toàn văn) | Người trẻ thích nút icon, **người lớn tuổi chọn nút chữ**; kết quả thao tác phụ thuộc tuổi |
| 4 | Ghayas, Sulaiman, Khan, Jaafar 2013 — https://khub.utp.edu.my/scholars/3354/ | Nhận diện icon ở nhóm 50+ phụ thuộc **độ quen thuộc**, không phụ thuộc đẹp/xấu |
| 5 | Wu et al., *IJERPH* 2022, tổng quan icon và lão hoá — https://www.ncbi.nlm.nih.gov/pmc/articles/PMC9026834/ | Nhãn chữ đúng nghĩa giúp người lớn tuổi hiểu icon; nhưng icon + chữ + màu quá nhiều lại tăng tải thị giác → mỗi hàng **một icon, một nhãn** |
| 6 | Apple HIG: Icons, SF Symbols, Settings (trang trả về rỗng khi fetch; đọc trên máy cùng ngày) — https://developer.apple.com/design/human-interface-guidelines/icons · /sf-symbols · /settings | Dùng SF Symbols cho nhất quán với chữ hệ thống; icon trang trí ẩn khỏi VoiceOver; nút chỉ có icon phải có accessibility label; hàng Settings của iOS = icon màu nền + nhãn |
| 7 | Sylvester et al., *J Behav Med* 39(4) 2016 (RCT 121 người ít vận động, 6 tuần) — https://researchportal.bath.ac.uk/en/publications/variety-support-and-exercise-adherence-behaviour-experimental-and/ · bản well-being: https://selfdeterminationtheory.org/wp-content/uploads/2017/06/Sylvester_et_al-2016-Applied_Psychology-_Health_and_Well-Being.pdf | Nhóm được **hỗ trợ đa dạng** bám chương trình hơn; tác động qua **cảm nhận có đa dạng** (perceived variety), cảm nhận này độc lập với 3 nhu cầu SDT; đa dạng còn tăng sinh khí, giảm cảm xúc tiêu cực |
| 8 | Univ. of Florida 2000 (Glaros & Janelle, 114 người, 3 nhóm) — https://archive.news.ufl.edu/articles/2000/10/adding-variety-to-an-exercise-routine-helps-increase-adherence.html | Nhóm đổi loại bài giữa các buổi **bỏ cuộc ít hơn rõ rệt** và thích hơn nhóm lặp một bài; là thông cáo, không có số từng nhóm |
| 9 | Sheldon & Lyubomirsky, *PSPB* 2012, mô hình HAP — https://sonjalyubomirsky.com/wp-content/uploads/2024/07/Sheldon-Lyubomirsky-2012.pdf | Niềm vui từ một thay đổi tích cực mòn đi qua 2 đường (cảm xúc nhạt dần, kỳ vọng tăng); hai thứ hãm lại: **biết ơn/để ý** và **đa dạng trong trải nghiệm** liên quan |
| 10 | Lally, van Jaarsveld, Potts, Wardle, *EJSP* 40 (2010) — https://www.ucl.ac.uk/news/2009/aug/how-long-does-it-take-form-habit | Tự động hoá tăng nhanh nhất ở những lần đầu rồi phẳng dần; trung vị 66 ngày (18–254), mẫu nhỏ, chưa lặp lại; bỏ 1 lần không phá thói quen → **không phạt bỏ buổi** |
| 11 | Tổng hợp định tính SDT ở người 65–97 (21 nghiên cứu), *JMIR* 2021 e26235 — https://jmir.org/2021/7/e26235 · Teixeira et al. 2012 *IJBNPA* — https://ijbnpa.biomedcentral.com/track/pdf/10.1186/1479-5868-9-78 | Ở người lớn tuổi: **lựa chọn giữa các bài ở mức độ khác nhau**, phản hồi từ HLV, quan hệ bạn bè nuôi động lực tự thân; định kiến "già thì xuống dốc" làm mất cảm giác năng lực; động lực tự thân dự đoán bám lâu dài |
| 12 | Tổng quan hệ thống gamification mHealth ở người ≥ 60 (8 RCT, 1.454 người), *JMIR Aging* 2025 — https://www.ncbi.nlm.nih.gov/pmc/articles/PMC12577663/ | Gamification tăng bước và phút vận động; phần tử hay dùng nhất là **đặt mục tiêu và phần thưởng**; mẫu nhỏ, không theo dõi dài hạn; không tách được tác dụng riêng của điểm/huy hiệu |
| 13 | Clemson et al., *JMIR Aging* 2025 (đã dùng ở `font-va-hinh-anh.md`) — https://pmc.ncbi.nlm.nih.gov/articles/PMC12199841 | Người lớn tuổi suy ra "app có dành cho mình không" từ hình và chữ; ghét gym, ghét tên bài hype |
| 14 | Nội bộ: HeartSteps (thông báo mất tác dụng sau ~4 tuần, `app-context.md` Risks); LazyFit 18 % review 1–2★ chê lặp 28 ngày (`docs/research/2026-10-04-tom-tat-thi-truong.md`); mẫu Mobbin H&F (`docs/reviews/2026-10-02-mobbin-patterns.md`) | Lặp là lý do bỏ app ở chính ngách này; "không lặp sau 28 ngày" đã là lợi thế ghi trong bảng Market |

Chưa tìm được RCT riêng cho **người 58–75** về "đa dạng vs bỏ cuộc" (FEXO 2026 *BMJ Open* có nhắc adherence/động lực nhưng chưa đọc được). Bằng chứng đa dạng là từ người trẻ/ít vận động; chuyển sang người lớn tuổi phải kèm điều kiện "bố cục ổn định" (nguồn 2, 3, 5).

## 2) Quy tắc icon

**Khi nào có icon, khi nào không**

| Có icon (icon + chữ) | Không icon |
|---|---|
| Lựa chọn onboarding là **vật/cảnh cụ thể** (ghế, cốc cà phê, TV, thẻ, người) | Thang mức độ 3 bậc (Không thể / Khó / Dễ; Achy / Okay / Great; Too easy / Just right / Too hard): icon làm thang thành 3 thứ khác nhau, mất tính "cùng một trục" |
| Hàng Me/settings (mẫu Settings của iOS) | "None of these", "Not sure" trong chip cơ thể: lối thoát, không cần hình |
| Vùng cơ thể (gối, hông, lưng, vai, khớp thay): **icon tự vẽ** hình người + chấm ở vùng đó (mục 2c) — không dùng băng/dấu chéo/ký hiệu y khoa | Hai icon cạnh nhau cho một ý (icon + tick + màu): một hàng = một icon + một nhãn + một trạng thái chọn |
| Thẻ trên Today, Complete, Progress: icon **loại buổi** hoặc **loại thông tin** ở đầu thẻ | Câu văn, gợi ý, caption, câu HLV: không chèn icon vào giữa dòng |
| Tab bar (4), chip trạng thái (Done, Rest, Pro, Video) | Nút chỉ có icon (trừ ✕ End đã có viền chữ "End"; ↗ mở rộng video — chấp nhận vì phụ, có accessibility label) |
| Danh sách "Có sẵn trước khi tập" (ghế, nước, chỗ trống) | Nút chỉ có icon (trừ ✕ End đã có viền chữ "End"; ↗ mở rộng video — chấp nhận vì phụ, có accessibility label) |

**2b. Thẻ lựa chọn gọn (mẫu chốt với chủ app 08/10)**

| Mục | Quy định |
|---|---|
| Bố cục | Chip 36 pt (glyph 20 pt) **bên trái, cùng hàng** với nhãn 17 pt semibold; nhãn chiếm phần còn lại; không có vòng tròn rỗng ở thẻ chưa chọn (viền thẻ đã nói "chạm được") |
| Trạng thái chọn | Nền sap 10 % + viền 3 pt `primary` + **tick tròn 24 pt bên phải** chỉ hiện khi chọn; VoiceOver `.isSelected` |
| Cỡ | Cao tối thiểu 60 pt có icon, 56 pt không icon; đệm 8×12; khoảng cách 8 pt |
| Cột | 2 cột **chỉ khi mọi nhãn vừa một dòng** ở cỡ chữ mặc định (≈ ≤ 12 ký tự với chip, ≤ 16 ký tự không chip, cột 167 pt trên SE); còn lại 1 cột; cỡ trợ năng luôn 1 cột |
| Ô HLV | Ô cố định 2 dòng dưới tiêu đề (gợi ý trước, câu HLV đáp sau), nội dung dưới không dịch chuyển |

Số đo trên 375×667 (đo bằng `icon-mockups.html?measure=1`, Chrome headless):

| Danh sách | Trước (app hiện tại, thẻ 72 pt + cách 14) | Lưới v1 (icon trên nhãn, 2 cột) | **Gọn (chốt)** |
|---|---|---|---|
| 6 lựa chọn, nhãn dài, 1 cột (Barriers) | 6×72 + 5×14 = **502 pt** | ~290 pt (3 hàng 90) | **400 pt** (−20 %); đáy danh sách y = 585, nút ghim vừa khít SE (0 pt dư) |
| 6 lựa chọn, nhãn ngắn, 2 cột (Sore spots: 4 ô + 2 ô trải hàng) | 502 pt | ~290 pt | **260 pt** (−48 %) |
| 7 lựa chọn, 1 cột (Goal với nhãn hiện tại) | 7×72 + 6×14 = 588 pt | ~390 pt | 468 pt → **tràn SE 21 pt** → mockup dùng 6 mục (bỏ "Lose some weight", câu hỏi mở #2 của báo cáo UI) = 400 pt vừa |
| 4 mốc nhắc, 1 cột | 4×72 + 42 = 330 pt (lưới 2×2 hiện tại ≈ 150 pt nhưng nhãn 3 dòng) | 128 pt (2 cột, "Morning coffee" gãy dòng) | **264 pt** 1 cột, nhãn gốc một dòng |
| 6 "Anything else", 1 cột | 502 pt | — | **396 pt** (hàng "None" 56 pt) |

Lưới v1 (icon trên nhãn) gọn nhất về chiều cao nhưng chủ app thấy hàng icon lãng phí và nhãn dài phải gãy dòng; mẫu gọn một cột đọc như danh sách, thẳng hàng, đổi 1 cột ↔ 2 cột không làm người dùng học lại.

**2c. Bộ icon vùng cơ thể tự vẽ (custom asset, không phải SF Symbol)**

| Mục | Quy định |
|---|---|
| Hình nền | Đúng hình người của `BodyGlowFigure` (`OnboardingMotion.swift:181–203`): khung 100×180, đầu ellipse (38,6)–(62,30), thân (32,40)→(68,40)→(74,84)→(26,84), tay (32,42)→(20,82) và (68,42)→(80,82), chân (40,86)→(36,172) và (60,86)→(64,172); nét 5 (ở 36 pt ≈ 1 pt), màu `ink` opacity 0,55 (tối: `text` tối cùng opacity) |
| Điểm nhấn | Chấm sienna (#A9512C, opacity 0,9) bán kính 11 đúng toạ độ `BodyGlowFigure.spots`: knees (39,126)(61,126) · hips (38,90)(62,90) · lower back (50,80) r 13 · shoulders (32,44)(68,44); joint replacement = 6 chấm r 7 viền `surface` ở vai, hông, gối |
| "Anything else" | floor: vạch sàn sienna dưới chân · standing: ghế sienna cạnh phải · dizzy: xoáy sienna trên đầu + đầu tô · unsteady: ghế cạnh trái + hai bàn chân tô · no jumping: hai vạch sàn + bàn chân tô. **Ở 36 pt còn yếu** (ghế thành chữ "h"); đưa vào test người dùng; phương án B: chip 44 pt cho màn này hoặc không icon |
| Chip | 36 pt, nền `ochre` 24 % (vệt màu nước), không dùng sap để không lẫn với icon buổi tập |
| Cách làm | Cách 1 (đề xuất): `BodyRegionIcon: View` dùng `Canvas` + enum vùng, tái dùng đường vẽ của `BodyGlowFigure` (tách path ra `BodyFigurePath` dùng chung); màu lấy token nên tự theo dark mode, không cần asset. Cách 2: 10 PDF template `Assets.xcassets/Icons/body-{knees,hips,back,shoulders,joint,floor,standing,dizzy,unsteady,jump}.pdf` ("Preserve Vector Data", render as template, chấm bằng lớp màu riêng → cần 2 ảnh/biểu tượng hoặc `Image` 2 lớp). Cách 1 ít file hơn và khớp pixel với hình bên tiêu đề |
| Tên trong `AppSymbol` | `.body(.knees)` … để bảng từ vựng vẫn "một nghĩa một tên"; mọi chỗ khác (Me → Your body chip, Plan) dùng cùng view |
| Tiếng Việt / VoiceOver | Icon ẩn; nhãn chip mang nghĩa như hiện nay |

**Hệ icon**

| Mục | Quy định |
|---|---|
| Bộ | **SF Symbols** có từ iOS 16 trở xuống (an toàn cho iOS 18); mỗi tên ở mục 3 đã kiểm theo bản SF Symbols 4 (iOS 16), vài tên ghi rõ "SF 5 / iOS 17". Icon tự vẽ chỉ hai chỗ: **vùng cơ thể** (mục 2c) và, để sau, **walking pad** (SF không có; tạm `figure.walk` + chữ "Walking pad") |
| Một nghĩa | Mỗi biểu tượng **một nghĩa toàn app** (bảng "từ vựng icon" dưới). Sửa 3 trùng hiện có: tự kiểm tra → `stopwatch.fill` (không `chair.fill`); dải chương trình → `calendar` (không `figure.stand`); bước "khoanh tay" tự kiểm tra → `figure.arms.open` (không `hand.raised.fill`) |
| Cỡ | Thẻ lựa chọn và hàng Me: chip **36 pt**, glyph 20 pt (chủ app 08/10, mục 2b); đầu thẻ Today/Complete: chip 44 pt, glyph 24 pt; weight **medium**; vệt màu nước = `IconChip` + `WashShape` hiện có. Vùng chạm là cả hàng ≥ 56 pt, không phải chip |
| Màu (vai trò, không trang trí) | `sap` #5E7F3A = buổi tập, kế hoạch, mặc định của hàng Me · `sky` #7FA3C0 = hành trình, nơi chốn, thời gian, "không chắc" · `ochre` #D9A441 = mốc, kỷ niệm, kiểm tra, "mới" · `sienna` #A9512C = người thân, tab đang chọn · `dangerSoft` = đau, dừng, xoá, Apple Health (trái tim đỏ như biểu tượng Health) · Me: **một màu sap cho mọi hàng** trừ Health và Delete, để trang cài đặt yên |
| Dynamic Type | Chip theo `@ScaledMetric(relativeTo: .body)` (đã có); ở cỡ trợ năng **ẩn icon trong thẻ lựa chọn** (đã có ở `SelectableCard`) nhưng **giữ icon hàng Me** 44 pt cố định vì hàng xuống nhiều dòng vẫn còn chỗ |
| VoiceOver | Icon trang trí `.accessibilityHidden(true)` (đã có trong `IconChip`); nhãn chữ mang nghĩa; chip trạng thái có `accessibilityLabel` đầy đủ ("Pro, locked") |
| Tương phản | Glyph trên vệt màu nước ≥ 3:1 (đồ hoạ, WCAG 1.4.11), thực tế dùng màu đậm hơn vệt: `sap` trên sap 16 % đạt; `sky` nhạt → glyph dùng sky đậm (#3F6A8A) hoặc `Palette.primary`; `ochre` → glyph #8A5F12. Thêm các cặp vào `Palette.textPairs` nếu glyph dùng màu mới |
| Dark mode | Vệt màu giữ opacity, glyph lấy bản tối của token (asset colour sets) |
| Không | Emoji; icon kèm icon; icon thay chữ ở nút chính; icon cho câu HLV |

**Từ vựng icon cố định (one symbol, one meaning)**

| Nghĩa | SF Symbol | Màu |
|---|---|---|
| Walk / đi bộ | `figure.walk` | sap |
| Long walk | `figure.walk.motion` (iOS 16) | sap |
| Chair moves / cái ghế | `chair.fill` | sap |
| Stretch | `figure.flexibility` | sky |
| Balance / Steady set / vững | `figure.stand` | sky |
| Seated (cấp ngồi) | `figure.seated.side` (SF 5, iOS 17) | sap |
| Outdoors / vị trí | `location.fill` | sky |
| Journey / địa danh / bưu thiếp | `map.fill` | sky |
| Cây / ngày hoạt động | `leaf.fill` (Seed `circle.dotted`, Sapling `leaf.fill`, Tree `tree.fill` — giữ như `CompleteContent`) | sap |
| Chương trình 12 tuần / tuần | `calendar` | sap |
| 2-week check / 30 giây | `stopwatch.fill` | ochre |
| Mới / điều mới tuần này | `sparkles` | ochre |
| Kỷ lục của mình / lên cấp | `arrow.up.circle.fill` (xuống cấp `arrow.down.circle.fill`) | sap |
| Nhắc / thông báo | `bell.fill` | sap |
| Nghỉ / ngày nghỉ | `moon.zzz.fill` | sap |
| Tiền / gói / trial | `creditcard.fill` | sap |
| Apple Health | `heart.fill` | danger |
| Đau / This hurts / dừng | `hand.raised.fill` | danger |
| Cảnh báo an toàn | `exclamationmark.triangle.fill` | danger |
| Âm thanh | `speaker.wave.2.fill`; giọng HLV `person.wave.2.fill`; nhạc `music.note`; phụ đề `captions.bubble.fill` | sap |
| Ngôn ngữ & đơn vị | `globe` | sap |
| Cỡ chữ / hiển thị | `textformat.size`; giao diện sáng tối `circle.lefthalf.filled` | sap |
| Trợ giúp | `questionmark.circle.fill`; liên hệ `envelope.fill`; điều khoản `doc.text.fill`; riêng tư `hand.raised.fill` **đổi thành** `lock.shield.fill` để không trùng "đau" | sap |
| Khôi phục mua | `arrow.clockwise` | sap |
| Xoá dữ liệu | `trash.fill` | danger |
| Done / hoàn thành | `checkmark.seal.fill` (thẻ Done đang dùng, giữ) | trắng trên sap |
| Pro / khoá | `lock.fill` (ProBadge, giữ) | — |

## 3) Bảng icon cho từng lựa chọn / màn

Cột "Hiện có": ✓ đã có icon trong code/ảnh · ✗ chưa · ◐ có nhưng cần đổi. "Đề xuất": tên SF Symbol; **—** = không icon (cố ý).

### 3a. Onboarding (theo bố cục 7 bước của `ui-ux-va-onboarding.md`; thẻ gọn mục 2b như mockup `goal-se.png`)

| Màn | Lựa chọn | Hiện có | Đề xuất | Màu | Lý do / ghi chú |
|---|---|---|---|---|---|
| Goal | Less pain | ✓ `heart` | `heart.fill` | danger (đỏ nhạt) | trái tim = "cảm thấy", quen |
| | Steadier feet | ✓ `figure.stand` | `figure.stand` | sky | = từ vựng "vững" |
| | Up from chairs | ✓ `chair` | `chair.fill` | sap | vật cụ thể nhất |
| | More energy | ✓ `sun.max` | `sun.max.fill` | ochre | mặt trời = năng lượng, quen |
| | Keep up with grandkids | ✓ `figure.2.and.child.holdinghands` | giữ (iOS 16) | sienna | người cụ thể |
| | Lose some weight | ◐ `figure.walk` | `figure.walk` giữ **hoặc** — | sap | `scalemass` (cái cân) nhắc cân nặng, app không cân → không dùng; đi bộ là cách app trả lời mục tiêu này |
| | Not sure yet | ✓ `sparkles` | `sparkles` | sky | cùng nghĩa "mới/chưa rõ"; chấp nhận trừu tượng vì là lối thoát, không phải nội dung |
| Barriers | My joints hurt | ✗ | `bandage.fill` **(thử ở test người dùng; dự phòng —)** | danger | băng dán = đau cụ thể nhưng có thể nghe "chấn thương"; nếu 2/5 người test đọc thành "bị thương" thì bỏ icon |
| | Videos go too fast | ✗ | `forward.fill` | sky | nút tua nhanh, ai xem video cũng biết |
| | No time for me / busy | ✗ | `person.2.fill` | sienna | "lo cho người khác" = hai người |
| | I got bored | ✗ | `zzz` | ochre | ngáp/ngủ; dễ hiểu, không mỉa |
| | Surprise charges | ✗ | `creditcard.fill` | sap | = từ vựng tiền |
| | Didn't know where to start | ✗ | `questionmark.circle.fill` | sky | phổ quát |
| Name | ô nhập | — | — | | không icon |
| Chair (Standing up without hands is…) | Not possible / Hard / Easy | ✗ | **—** | | thang 3 bậc; nếu muốn hình thì **một** tranh nhỏ sit-to-stand phía trên câu hỏi, không icon từng dòng |
| Activity (nếu giữ) | mostly sit / short walks / most days / exercise regularly | ✗ | **—** | | cũng là thang; `sofa.fill`/`figure.walk` chỉ phân biệt được 2 bậc đầu |
| Sore spots | Knees · Hips · Lower back · Shoulders · Joint replacement | ✗ | **custom** `body-knees` · `body-hips` · `body-back` · `body-shoulders` · `body-joint` (mục 2c) | ochre nền, sienna chấm | hình người + chấm ở vùng; 2 cột cho 4 khớp, Joint replacement và None trải hàng; None không icon |
| Anything else | Can't get down on the floor · Standing long is hard · Dizzy · Unsteady · No jumping · None | ✗ | **custom** `body-floor` · `body-standing` · `body-dizzy` · `body-unsteady` · `body-jump` (thử; yếu ở 36 pt) | ochre/sienna | 1 cột; None không icon; nếu test không đọc được → bỏ icon màn này |
| Reminder moments (S16 / Reminder offer / Me) | After my morning coffee | ✗ | `cup.and.saucer.fill` | ochre | 4 icon này là ví dụ tốt nhất của "vật cụ thể"; **1 cột** (nhãn gốc không vừa nửa cột) |
| | After lunch | ✗ | `fork.knife` | ochre | |
| | During evening TV | ✗ | `tv.fill` | ochre | |
| | Pick a time | ✗ | `clock.fill` | ochre | |
| Plan (Your plan) | 5–10 min a day / Starts Seated / Rest days | ◐ `calendar`, `figure.walk` | `calendar` · `figure.seated.side` · `moon.zzz.fill` | sap | 3 dòng, 3 icon, mỗi dòng ≤ 6 chữ |
| | Hear your coach · 10 s | ✗ | `play.fill` trong nút | sap | nút có chữ |
| Welcome | 12 weeks / seated / voice | ✓ `calendar`, `chair.fill`, `ear` | giữ; `ear` → `ear.fill` cho đồng bộ nét | sap | |

### 3b. Me / cài đặt (mẫu hàng Settings iOS; mockup `me-se.png`)

| Nhóm | Hàng | Hiện có | Đề xuất |
|---|---|---|---|
| — | Subscription / Good Footing Pro | ✗ | `creditcard.fill` |
| Your plan | Your 12 weeks | ✗ | `calendar` |
| | Your body | ✗ | `figure.arms.open` (iOS 16) — người "mở" = cơ thể, không bệnh |
| | Your week / Rest days | ✗ | `moon.zzz.fill` |
| | Notifications: Walk reminder | ✗ | `bell.fill` |
| | · When I reach a new postcard | ✗ | `map.fill` |
| | · Weekly recap | ✗ | `chart.bar.fill` (= tab Progress) |
| | · Self-check reminders | ✗ | `stopwatch.fill` |
| | · New journeys | ✗ | `newspaper.fill` |
| During a session | Captions | ✗ | `captions.bubble.fill` |
| | Music (style) | ✗ | `music.note` |
| | Voice louder than music | ✗ | `person.wave.2.fill` |
| App | Language and units | ✗ | `globe` (Distance/Weight/Height bên trong: không icon, là bảng chọn) |
| | Display: Appearance | ✗ | `circle.lefthalf.filled` |
| | Display: Text size | ✗ | `textformat.size` |
| Phone and Health | Apple Health | ✗ | `heart.fill` đỏ |
| | Outdoor walks (location) | ✗ | `location.fill` |
| Help | Restore purchase | ✓ `arrow.clockwise` | giữ |
| | Contact us | ✓ `envelope` | `envelope.fill` |
| | Terms of Use | ✓ `doc.text` | `doc.text.fill` |
| | Privacy | ◐ `hand.raised` | `lock.shield.fill` (tránh trùng This hurts) |
| | Delete all my data | ✗ | `trash.fill` đỏ |
| Cancel guide | 3 bước | ✓ `hand.tap`, `list.bullet`, `xmark.circle` | giữ |

Ghi chú: các hàng Me hiện là **thẻ có tiêu đề + link chữ** (Edit, Change, See plan). Đổi sang **hàng kiểu Settings iOS: chip 36 pt trái · nhãn (+ dòng phụ) · giá trị/công tắc/chevron phải** (mockup `me-se.png`, hàng 56 pt) vừa thêm icon vừa rút chiều cao ~35 % (Me hiện cuộn dài, `ui-ux-va-onboarding.md` #44). Hàng có công tắc giữ công tắc bên phải.

### 3c. Today (mockup `today-se.png`)

| Thành phần | Hiện có | Đề xuất |
|---|---|---|
| Dòng cây dưới lời chào | ✓ `leaf.fill` trong vòng | giữ, gộp "· Week 3 of 12" vào cùng dòng (P2 của báo cáo UI) |
| Dải chương trình | ◐ `figure.stand` | `calendar` (hoặc bỏ dải, xem dòng trên) |
| Thẻ buổi tập: Walk / Chair moves / Stretch / Long walk / Outdoors | ◐ chỉ chair có `chair.fill` lớn góc phải | icon theo từ vựng ở **đầu tiêu đề**, 44 pt: `figure.walk` · `chair.fill` · `figure.flexibility` · `figure.walk.motion` · `location.fill` |
| Check-in Achy / Okay / Great | — | **—** (thang) |
| Thẻ "Or: 6-min stretch" (lựa chọn thứ hai, mục 5) | ✗ | icon loại buổi |
| Thẻ 2-week check (invite/due/in N days) | ◐ `chair.fill` | `stopwatch.fill` ochre |
| Thẻ Done for today | ✓ `checkmark.seal.fill` | giữ |
| Thẻ Rest day | ✗ (lịch tuần có `moon`) | `moon.zzz.fill` |
| Gentle restart / Welcome back | ✗ | `figure.walk` + chữ "5 min" (không icon riêng cho "quay lại") |
| Shorter today / Moved down / Moved up | ✗ | `arrow.down.circle.fill` · `arrow.up.circle.fill` |
| Pain alert (cùng vùng ≥ 3 lần) | ✗ | `hand.raised.fill` danger |
| Trial ending (ngày 10–14) | ✗ | `creditcard.fill` |
| Journey card | ✓ tranh | giữ tranh, không thêm icon |
| Lịch tuần | ✓ tick / `figure.walk` / moon | giữ; moon ≥ 16 pt (font doc: hiện ~12 pt) |
| Tab bar | ✓ `sun.max.fill` `map.fill` `chart.bar.fill` `person.fill` | giữ |

### 3d. Complete, Progress, Program

| Màn | Thành phần | Hiện có | Đề xuất |
|---|---|---|---|
| Complete | 3 ô thống kê: min moving / +mi journey / active days | ✗ | icon 14 pt trong nhãn: `clock.fill` · `map.fill` · `leaf.fill` (mockup `complete-*.png`) |
| | How did that feel? | — | — |
| | Thẻ cây / thẻ hành trình | ✗ | `leaf.fill` · `map.fill` ở đầu thẻ |
| | Thẻ mời 2-week check | ✗ | `stopwatch.fill` |
| | Route saved in Apple Health | ✓ `heart.text.square` | giữ |
| | Level up | ✓ `arrow.up.circle.fill` | giữ |
| Progress | Thẻ cây | tranh | giữ tranh |
| | Lịch tháng: Active / Rest | ✓ chấm, `moon.fill` | giữ; moon ≥ 16 pt |
| | Your 2-week checks | ✗ | `stopwatch.fill` |
| | Hands on the chair (Pro) | ✗ | `figure.stand` |
| | Longest walk without a break | ✗ | `figure.walk.motion` |
| | Everyday wins | ✗ | `checkmark.circle.fill`; từng win: — |
| | All-day steps | ✗ | `shoeprints.fill` (iOS 16) |
| | Recent sessions (hàng) | ✓ icon loại buổi | giữ, theo từ vựng |
| Program | 4 giai đoạn Steady base / Building strength / Gentle challenge / Your routine | ✗ | `figure.seated.side` · `figure.stand` · `figure.walk.motion` · `calendar` — hoặc **—** và dùng số 1–4 to; không dùng `dumbbell` (gym) |
| | "isn't medical advice" | ✗ | `info.circle` |

### 3e. Permissions, Outdoor, Self-check, Paywall

| Màn | Thành phần | Hiện có | Đề xuất |
|---|---|---|---|
| Permissions (2 màn mới) | Reminders · Apple Health | ✓ `bell.fill`, `heart.fill` | giữ; Motion (khi chọn "Held to my chest") `iphone.radiowaves.left.and.right`; Location `location.fill` |
| Outdoor prep | Water with you | ✗ | `waterbottle.fill` (SF 5, iOS 17 — đã dùng ở Up next) |
| | Sturdy shoes | ✗ | `shoe.fill` (iOS 16) |
| | Phone charged | ✗ | `battery.100percent` |
| | One ear free to hear traffic | ✗ | `ear.fill` |
| | Hot-day tip | ✓ `sun.max` | `thermometer.sun.fill` |
| | Use my location / Just count my steps | ✗ | `location.fill` · `shoeprints.fill` |
| Self-check intro | Sturdy chair · feet flat · arms · stop if hurts | ✓ `chair.fill` `shoeprints.fill` `hand.raised.fill` `exclamationmark.circle.fill` | `hand.raised.fill` → `figure.arms.open`; còn lại giữ |
| | Tiêu đề thẻ "How it works" | ✗ | — (bước 1–2–3 bằng số) |
| Self-check timer/count | − / + | ✓ | giữ, không thêm |
| Paywall | 3 dòng lợi ích | ✓ tick | **tick giữ** (NN/g: tick là icon phổ quát) — không thay bằng icon riêng từng dòng để không "bán hàng"; nếu dòng đầu theo goal thì icon goal đi kèm (1 icon) |
| | Timeline Today / Remind / Billed | ✓ `lock.open.fill` `bell.fill` `creditcard.fill` | giữ |
| | Restore / Terms / Privacy | chữ | giữ chữ (luật paywall: link rõ) |
| Up next (WorkoutReady) | Have ready / Then | ✓ 6 icon | giữ (mẫu tốt nhất hiện có: icon + 2–3 chữ) |
| Sound sheet | Giọng / Nhạc | ✓ `person.wave.2`, `music.note` | giữ, thay slider bằng − / + (báo cáo UI) |

## 4) Nhàm chán hiện tại — số đếm

Giả định: người dùng Pro, tập **5 ngày/tuần × 12 tuần = 60 buổi**, cấp In place, cường độ Steady đa số ngày (check-in "Okay"). Nhịp tuần Pro (`WeeklyPlanner.proPattern`): Walk+1 ghế · Stretch · Walk+2 ghế · Chair · Long walk → 24 walk, 12 long walk, 12 stretch, 12 chair; Steady set 2 phút **mọi** buổi (60).

| Thứ bà ấy gặp | Kho hiện có | Lặp trong 12 tuần | Nhận xét |
|---|---|---|---|
| Mẫu đi bộ (`sessions.json`) | 15 walk (5 cấp × gentle/steady/strong/long/commercial) + First Walk | **cùng 1 mẫu `ses.walk.inplace.steady` ≈ 24 lần**; `…long` 12 lần; đổi check-in mới đổi mẫu (tối đa 3) | `commercial` (6 phút) không nằm trong kế hoạch tuần |
| Câu HLV trong walk | 620 câu tổng; walk inplace.steady 85 cue; **31 họ câu xoay vòng** (`VoiceRotation.families`), họ có 2–4 biến thể (`a2.open` 4, `a2.warm` 8 nhưng **không xoay**) | mở đầu: 4 câu cho 36 buổi walk → mỗi câu ~9 lần; khởi động 8 câu **cố định thứ tự** → giống hệt 36 lần | Xoay vòng là cơ chế tốt nhưng phủ ~1/3 họ câu |
| Buổi ghế | 3 mẫu (`ses.moves.gentle/steady/strong`), 12 bài, vòng xoay bài theo `rotationIndex` | mở/kết **không có câu riêng** (`a9.chair.open/close` đã thu, chưa dùng) → 12 lần cùng cấu trúc | bài xoay nên nội dung đỡ lặp hơn walk |
| Giãn cơ | 6 mẫu (seated/standing × 3) + `ses.morning` (không trong kế hoạch) | cùng 1 mẫu ≈ **12 lần** | |
| Steady set | 2 mẫu/cường độ (a, b) + 1 bản ngồi | mỗi mẫu ≈ **30 lần** | 2 phút nghe mỗi ngày, nhanh thuộc lòng nhất |
| **Nhạc** (`music.json`) | **3 track**, 1 cho walk, 1 ghế, 1 giãn; Me ghi "Music · Coming soon" | track walk **36 lần**, ghế 12, giãn 12; **không buổi nào nhạc khác hôm trước cùng loại** | Nguồn lặp lớn nhất và rẻ nhất để sửa |
| Câu HLV theo trạng thái ngày | 14 câu `a9.*` đã thu EN+VI (achy/steady/strong, back, shorter, level up/down, to-chair, to-stretch, extras…) | **0 lần** (không template nào dùng) | đã nêu ở `2026-10-08-ca-nhan-hoa.md` P1 |
| Today | 1 bố cục; lời chào 3 biến thể theo giờ; tiêu đề buổi 5 kiểu; 6 thẻ đặc biệt theo tình huống | 60 lần cùng bố cục, cùng thứ tự thẻ | không tranh, không mùa, không "mới" |
| Complete | 3 tiêu đề (Lovely walk / Nice and easy / You did it) + buổi đầu + dừng sớm; **1 tranh** `walker-celebrate`; 3 ô số cố định; thanh cây; thanh hành trình | **60 lần cùng tranh**, cùng 3 ô | khác nhau chỉ ở số |
| Hành trình | 5 tuyến × 6 điểm = 30 bưu thiếp; 0,05 mi/phút; NY 5 mi (free) = 100 phút ≈ 10 buổi; mỗi tuyến Pro 12 mi = 240 phút ≈ 24 buổi; điểm dừng mỗi 2,4 mi ≈ 48 phút ≈ **1 bưu thiếp/tuần** | 12 tuần ≈ 600 phút = 30 mi → NY + 2 tuyến Pro, **~16 bưu thiếp**; mỗi bưu thiếp có `back` + `coachLine` riêng | nhịp 1/tuần là tốt. Nhưng câu HLV trong buổi về tuyến (`a8.*`): NY **6** câu, **4 tuyến Pro mỗi tuyến 1 câu** → từ tuần 3 tới tuyến trong im lặng |
| Cây | Seed → Sprout ngày 7 → Sapling 21 → Tree 42 → vòng năm mỗi 42 ngày | 3 sự kiện trong 6 tuần đầu, **0 sự kiện tuần 7–12** (vòng năm đầu ở ngày 84, sau chương trình) | nửa sau chương trình không có mốc trực quan nào ngoài bưu thiếp |
| Thông báo | 14 câu nhắc, không lặp 14 ngày; 4 check, 3 day2, 2 back, 3 week | đạt luật | đã tốt |
| Everyday wins | 8 | tick 1 lần rồi hết | |
| Hình ảnh toàn app | 63 tranh (30 bưu thiếp, 5 bìa, 10 nhân vật, 5 cảnh, 4 cây, 3 moment, 3 điện thoại, 2 bài) | Today/Me/Progress **không có tranh** ngoài cây và bìa tuyến | tranh dồn ở onboarding và hành trình |

Kết luận mục 4: cấu trúc buổi lặp là **đúng ý** (người lớn tuổi cần đoán trước được), nhưng **lớp âm thanh và lớp kỷ niệm** lặp quá sớm: nhạc 1 track/loại, mở đầu 4 câu, Complete 1 tranh, nửa sau chương trình không có mốc. Lời hứa đã in ở onboarding cho người chọn "I got bored": "Something new every week." (`OnboardingCopy.understanding(.bored)`) hiện **chưa có cơ chế nào đứng sau**.

## 5) Cơ chế chống nhàm chán — xếp hạng

Nguyên tắc chung (từ nguồn 2, 3, 7, 9, 11): **đa dạng về nội dung, ổn định về khung** — cùng vị trí nút, cùng thứ tự thẻ, cùng cách nói; khác tranh, khác câu, khác bài, khác chủ đề. Mọi "bất ngờ" chỉ nằm ở **nội dung bà ấy nhận được**, không bao giờ ở **việc bà ấy có được tính công hay không**. Không streak, không đếm ngược, không phần thưởng xác suất, không so với người khác (app-context Tone). Cỡ: S ≤ ½ ngày · M 1–2 ngày · L 3–5 ngày (gồm EN/VI, test). Đo: không backend → (a) bộ đếm DEBUG trên máy test, (b) test prototype 5–8 người 58–75, (c) App Store Connect giữ chân ngày 7/14/28.

| # | Cơ chế | Thay đổi trên màn / âm thanh | Cỡ | Rủi ro & cách giữ | Đo |
|---|---|---|---|---|---|
| 1 | **Bật kho câu HLV đã thu + mở rộng xoay vòng** | Chèn `a9.gentle/steady/strong` sau câu mở theo check-in; `a9.back.*`, `a9.shorter`, `a9.levelup/down` theo tình huống; `a9.chair.open/close`, `a9.to-chair/to-stretch/next-move` nối phần; thêm `a2.warm` vào họ xoay nếu các câu tương đương (kiểm script A2) | **S** | Câu nhắc tình trạng ("joints achy") chỉ trong buổi, không lên màn khoá | test prototype: "HLV có biết hôm nay bạn thế nào?" |
| 2 | **Nhạc: ≥ 3 track mỗi loại, xoay theo tuần + 1 bản "lặng"** | `music.json` 3 → 9–12 track (Eleven Music/Lyria, quyết định 29/09); `MusicStyle` "Feel-good / Calm / Quiet" ở Me (chỗ "Coming soon" đã chừa); tuần lẻ/chẵn đổi track; cùng tempo theo pha để cue không lệch | **M** (asset) | Nhạc mới làm lệch nhịp cue → giữ BPM cố định theo loại; người thích quen → chọn "Keep this music" ở Me | tỉ lệ tắt nhạc (DEBUG); câu hỏi test |
| 3 | **Chủ đề tuần + thẻ "Mới tuần này"** | 12 tuần = 12 chủ đề 2–3 chữ gắn với 4 giai đoạn (vd. tuần 1 "First steps", 4 "Turning with ease", 5 "A little longer", 9 "Heel and toe"); mỗi tuần **một thứ mới thật**: bài mới vào vòng xoay, câu HLV mới, tuyến/bưu thiếp, bậc vịn, đổi nhạc; Today thẻ ochre `sparkles` "New this week · Heel raises join your chair moves" (mockup); HLV nói 1 câu đầu tuần | **M** (chữ + 12 câu thoại, có thể dùng P7 ghép "Week N") | Phải mới thật, không "mới" giả; tuần không có gì mới thì ẩn thẻ (trung thực) | tỉ lệ mở thẻ "See"; retention tuần 5–8 |
| 4 | **Complete 6 biến thể theo ngữ cảnh** | Chọn biến thể theo thứ tự ưu tiên, **tối đa 1 "lớn" mỗi buổi**: (1) Postcard day — tranh bưu thiếp + nút "Send this postcard" (mockup); (2) Tree day — cây lớn; (3) Record day — "Your longest walk without a break: 9 min, up from 7" (mockup quiet); (4) Week done — "4 of 5 this week" + tranh ghế; (5) Back day — sau nghỉ ≥ 3 ngày, tranh `walker-wave`, "Good to have you back"; (6) Quiet day — tranh thay phiên 4 nhân vật (`walker-*`), tiêu đề 3 câu hiện có + 3 câu mới. Dòng kicker nhỏ (POSTCARD DAY / WEDNESDAY · WALK 3 OF 3) nói lý do | **S–M** (0 tranh mới nếu dùng 10 tranh nhân vật có sẵn) | "Record" chỉ so với chính mình, không điểm; không confetti/âm thanh ồn; Reduce Motion = tĩnh | test: kể lại được 2 buổi khác nhau không? |
| 5 | **Lựa chọn thứ hai trên Today** (SDT autonomy, nguồn 11) | Thay link "Pick a different session" bằng **thẻ nhỏ** "Or: 6-min stretch · Counts the same" (mockup); nội dung = buổi khác loại, ngắn hơn, cùng cấp; All sessions vẫn ở dưới | **S** | 2 nút chính cạnh nhau → thẻ phụ nhỏ hơn, không nút Start riêng (chạm thẻ = preview) | tỉ lệ chọn phụ (DEBUG); không tăng bỏ buổi |
| 6 | **Kỷ lục so với chính mình** (competence) | 4 số của bà ấy: longest walk without break, chair count 30 s, số lần sit-to-stand (Pro), tuần liên tiếp có ≥ 1 buổi; hiện ở Complete khi vừa lập (biến thể 3) và thẻ đầu Progress (P8 của tài liệu cá nhân hoá) | **M** | Không "score", không bảng tuổi; kỷ lục tụt không hiển thị tiêu cực | test |
| 7 | **Tuyến có tiếng: 5 câu HLV/tuyến cho 4 hành trình Pro** | `a8.smoky/camino/ne/pch` từ 1 → 6 câu (1 mỗi điểm, như NY), phát khi tới điểm + 1 câu "sắp tới" (`nt.near` đã có bản thông báo); bưu thiếp mặt sau giữ | **M** (20 câu EN+VI qua Vibi) | Không bịa số liệu địa lý; câu ≤ 12 chữ | — |
| 8 | **Cây sống nửa sau chương trình** | Giữ 7·21·42; thêm **lá/hoa theo tuần** sau Tree (không đổi hằng số core): mỗi tuần có ≥ 3 ngày hoạt động → cây thêm 1 chi tiết (chim, hoa, quả theo mùa) hết tuần 12; hoặc đẩy vòng năm đầu về ngày 63 (**đổi quyết định 29/09**, chờ chủ app) | **S** (code) + **M** (4–6 lớp tranh) | Mốc theo "tuần có 3 ngày", không streak ngày; không mất chi tiết khi nghỉ | — |
| 9 | **Tranh đầu màn theo giờ và mùa** | Today: dải tranh 90–110 pt sau lời chào, 3 thời điểm (sáng/chiều/tối) × 4 mùa = 12 tranh (phòng khách, hiên, công viên gần nhà — cùng nhân vật); câu chào có 2–3 biến thể mỗi thời điểm; mùa theo lịch máy, không hỏi | **M–L** (12 tranh) | Chiếm chỗ đẩy Start xuống → dải thấp, ẩn ở SE khi cỡ chữ lớn; mùa Nam bán cầu sai → chỉ theo tháng + "US first" | test prototype |
| 10 | **Gửi bưu thiếp cho người thân** (relatedness) | Nút "Send this postcard" trên Complete postcard day và trong Journey: ảnh bưu thiếp + dòng "Margaret walked to Times Square today." qua share sheet (đã có `shareLine`) | **S** | Không tên người thật ngoài tên bà ấy; không xin danh bạ | số lần share (DEBUG) |
| 11 | **Thư cuối tuần của HLV** (surprise-but-not-random) | Chủ nhật: thẻ "A note from your coach" 2–3 câu dựng từ dữ liệu thật (ngày hoạt động, điều mới tuần sau, 1 câu ấm); không đọc được trước Chủ nhật (bất ngờ về nội dung, đều về thời điểm) | **M** (ghép câu chữ; 0 thu âm) | Không lộ sức khoẻ trên màn khoá; không guilt khi tuần 0 ngày ("Your plan is here when you are") | tỉ lệ mở |
| 12 | **Nhịp hình ảnh theo tab** (mục 6) | Mỗi tab một màu đầu màn + 1 tranh spot; Today ấm (ochre), Journey sky, Progress sap, Me trung tính | **S** | Không đổi màu nút chính | — |
| 13 | **Dùng mẫu buổi có sẵn mà kế hoạch chưa dùng** | `ses.walk.*.commercial` (6 phút) làm lựa chọn thứ hai ngày bận; `ses.morning` làm Stretch tuần chẵn | **S** | Nhãn rõ "6 min" | — |
| 14 | **Check-in tuần → tuần sau đổi** | P6 của tài liệu cá nhân hoá (2 câu Chủ nhật) — gộp với #11 cùng một thẻ | **M** | xem tài liệu đó | |

Không đề xuất: huy hiệu/điểm (nguồn 12 không tách được tác dụng, dễ thành so sánh), streak ("không bao giờ mất chuỗi" là luật), hoạt ảnh pháo hoa, "mystery reward", đổi bố cục Today theo ngày, thay giọng HLV.

Thứ tự gợi ý: **đợt 1 (trước 1.0, ~3 ngày code, 0 thu âm):** #1, #4, #5, #13, #12 · **đợt 2 (1.0):** #3, #6, #10, #8-code · **đợt 3 (1.1, cần asset):** #2, #7, #9, #8-tranh, #11/#14.

## 6) Mẫu bố cục sống động mà yên

| # | Mẫu | Cách làm | Ví dụ màn |
|---|---|---|---|
| L1 | **Dải tranh đầu màn theo tab** | 90–110 pt, tranh màu nước cắt ngang, chữ tiêu đề New York đè nền giấy (không đè tranh); mỗi tab 1 tranh cố định + Today đổi theo giờ/mùa (#9) | Today (phòng khách sáng), Journey (bìa tuyến hiện tại — đã có), Progress (cây), Me (không dải, chỉ tiêu đề) |
| L2 | **Chip icon vệt màu nước** | `IconChip` 44 pt, màu theo vai trò, glyph medium 22–24 pt; cùng một chip cho hàng Me, đầu thẻ, lựa chọn | Me rows (`me-se.png`), Today session card (`today-se.png`) |
| L3 | **Ba dạng thẻ trong một hệ** (bo 14/16, cùng nền `surface`) | (a) thẻ hành động: tiêu đề + check-in + nút ghim trong thẻ; (b) thẻ thông tin: icon + 2 dòng + chevron; (c) ô số: số Rounded 22 pt + nhãn có icon 14 pt. Mỗi màn dùng ≤ 3 dạng, xen kẽ a-b-b-c, không hai thẻ a liền nhau | Today: a (buổi) → b×2 nhỏ cạnh nhau → b (journey); Complete: c×3 → bưu thiếp → pill |
| L4 | **Tranh spot ở trạng thái rỗng/xong** | Nhân vật 100–120 pt cạnh tiêu đề thay vì tranh toàn chiều rộng; 10 tranh nhân vật có sẵn xoay theo biến thể | Complete (`complete-quiet-se.png`: ngồi ghế; postcard: giơ tay), Done for today (vẫy tay), Rest day (walker-rest) |
| L5 | **Thẻ lựa chọn gọn** (mục 2b) | chip 36 pt cùng hàng nhãn, 60 pt, không vòng tròn rỗng, tick chỉ khi chọn; 1 cột mặc định, 2 cột khi nhãn ngắn | Goal, Barriers, Sore spots, Anything else, Reminder (`goal-se.png` … `reminder-se.png`) |
| L6 | **Dòng kicker màu sienna** trên tiêu đề | 13–15 pt, chữ hoa, nói ngữ cảnh ("POSTCARD DAY", "WEDNESDAY · WALK 3 OF 3", "WEEK 5 · A LITTLE LONGER") — là thứ đổi mỗi lần nhìn, chữ to phía dưới giữ ổn định | Complete, Today (dưới lời chào), Program |

Mockup (375×667, SE, cỡ chữ mặc định, sáng; đã xem từng ảnh sau lần sửa theo ý chủ app: không gì tràn, Me cuộn theo thiết kế, Barriers và Anything else vừa khít nút ghim): `icon-mockups/goal-se.png`, `barriers-se.png`, `body-se.png`, `body2-se.png`, `reminder-se.png`, `me-se.png`, `today-se.png`, `complete-postcard-se.png`, `complete-quiet-se.png`. Nguồn `icon-mockups.html` (`?only=<id>` xem một khung; `?measure=1` ghi chiều cao danh sách vào `<title>`; icon SF là SVG thay thế, tên thật ở mục 3; icon cơ thể là SVG đúng hình học mục 2c; tranh chép vào `icon-mockups/art/`, mặt HLV cắt đúng ô 110 px tại (95,15) của `walker-wave` như `CoachFace` và nhúng data URI để mở ở đâu cũng hiện). Chưa vẽ: tối, tiếng Việt, cỡ trợ năng.

## 7) Việc cần đưa vào kế hoạch

| # | Việc | File | Cỡ |
|---|---|---|---|
| T1 | Từ vựng icon: `enum AppSymbol` (một nghĩa một tên) trong `iOS/App/Design/AppSymbols.swift`; test `DesignTokenTests` kiểm không trùng và mọi tên có `UIImage(systemName:)` trên iOS 18 | mới + `Tokens.swift`, test | S |
| T2 | Sửa 3 trùng nghĩa: check `chair.fill`→`stopwatch.fill` (`TodayCards.swift:312`, `SelfCheckViews.swift`), dải chương trình `figure.stand`→`calendar` (`TodayCards.swift:273`), self-check arms `hand.raised.fill`→`figure.arms.open` (`SelfCheckViews.swift:63`), Privacy → `lock.shield.fill` (`MeSections.swift:415`) | như trên | S |
| T3 | `SelectableCard` gọn (mục 2b): chip 36 pt, minHeight 60/56, bỏ vòng tròn rỗng, tick chỉ khi chọn; `LazyVGrid` 1/2 cột theo luật nhãn một dòng (đo bằng `ViewThatFits` hoặc cờ tĩnh theo màn); `OnboardingCopy.symbol/tint` cho `Barrier`, `DailyMoment`; `BodyLimitChips` dùng cùng thẻ | `SelectableCard.swift`, `OnboardingCopy.swift`, `QuestionViews.swift`, `BodyLimitChips.swift`, `DailyMomentPicker.swift` | M |
| T3b | `BodyRegionIcon` (mục 2c): tách path của `BodyGlowFigure` thành `BodyFigurePath` dùng chung; enum 10 vùng; snapshot test sáng/tối; `OnboardingCopy.symbol(BodyLimit)` trả view này | `OnboardingMotion.swift`, mới `iOS/App/Design/Components/BodyRegionIcon.swift`, test | S–M |
| T4 | Me: `SettingsRow` có `IconChip` 44 pt + chevron; đổi 6 `SettingsCard` thành nhóm hàng; `NotificationSection` hàng có icon | `MeSections.swift`, `MeView.swift`, `NotificationSection.swift` | M |
| T5 | Today: icon loại buổi đầu tiêu đề thẻ; thẻ phụ "Or: …"; thẻ đặc biệt có icon theo bảng 3c; thẻ "New this week" (ẩn khi không có gì mới) | `TodayCards.swift`, `TodayView.swift`, `TodayModel.swift` | M |
| T6 | Complete: `CompleteVariant` (postcard/tree/record/weekDone/back/quiet) chọn trong `CompleteContent`; kicker; ô số có icon; tranh theo biến thể; nút "Send this postcard" | `CompleteContent.swift`, `CompleteView.swift` | M |
| T7 | Progress/Outdoor/Program icon theo bảng 3d–3e | `ProgressScreen.swift`, `OutdoorPrepView.swift`, `ProgramView.swift` | S |
| T8 | Bật câu a9 + mở rộng `VoiceRotation.families` sau khi rà script A2/A4 (câu nào tương đương) | `SessionBuilder.swift`, `ChairSessionPlanner.swift`, `VoiceRotation.swift`, `docs/scripts/A2-walk.md` (ghi chú) | S |
| T9 | Chủ đề tuần: bảng 12 tên EN/VI trong `ProgramCalendar` hoặc content JSON `program.json`; `copy_lint` + steady-claims lint | `Program/ProgramCalendar.swift`, `Resources/Content/`, `Localizable.xcstrings` | M |
| T10 | Nhạc: thêm track, `MusicStyle` ở Me, xoay theo tuần | `music.json`, `tools/music/`, `MeSections.swift` (WorkoutAudioSection) | M + asset |
| T11 | 20 câu `a8.*` cho 4 tuyến Pro (Vibi EN+VI) + 12 câu "Week N / chủ đề" | `docs/scripts/A8-journeys.md` (mới), `voice-lines.json`, `content.vi.json` | M + thu âm |
| T12 | Tranh: 4–6 lớp cây sau Tree; 12 tranh đầu Today (giờ × mùa) — đợt sau | `assets/art/`, `tools/art/build_art.py` | L |
| T13 | Chụp lại: `onboarding-goal`, `onboarding-barriers`, `me`, `today`, `complete*` ở SE + i11, sáng/tối, EN/VI, cỡ xLarge | `CaptureHook.swift` | S |
| T14 | Test prototype: thêm 3 câu hỏi (icon nào không hiểu? kể 2 buổi Complete khác nhau? nhạc có chán không?) | `docs/research/prototype-test-plan.md` (chủ app cập nhật) | S |

## 8) Câu hỏi còn mở

1. Icon cho **"My joints hurt"**: `bandage.fill` hay không icon? Đề xuất thử ở test người dùng, mặc định **không**.
2. Bộ icon "Anything else" (sàn, ghế, chóng mặt, không vững, không nhảy) ở 36 pt còn yếu: giữ và test, tăng chip lên 44 pt cho riêng màn này, hay bỏ icon ở màn này (giữ 5 icon vùng đau)? 3 bậc "đứng dậy khỏi ghế": chốt không icon?
2b. Goal 7 mục một cột tràn SE 21 pt: bỏ "Lose some weight" (6 mục, vừa), hay giữ 7 và chấp nhận cuộn với nút ghim?
3. Me: chuyển từ thẻ-tiêu-đề sang **hàng icon + chevron** (mockup) hay chỉ thêm icon vào thẻ hiện tại?
4. Cây nửa sau chương trình: thêm chi tiết theo tuần (giữ 7·21·42) hay đẩy vòng năm đầu về ngày 63 (**đổi quyết định 29/09**)?
5. Nhạc: mua/tạo thêm 6–9 track bây giờ (đợt 3) hay ra 1.0 với 3 track + bản "lặng"?
6. "Send this postcard": có vào 1.0 không (chia sẻ = Mother's Day hook trong app-context)?
7. "New this week" cần mới thật mỗi tuần: ai duy trì bảng 12 tuần khi nội dung đổi (content build) — đưa vào `ContentValidator` kiểm "mỗi tuần ≥ 1 thứ mới"?
8. Thẻ phụ "Or: 6-min stretch" ở bản Free: cho phép (hiện Free chỉ walk + ghế) hay hiện kèm `ProBadge`?
9. Có dùng tranh đầu Today theo giờ/mùa (12 tranh, cỡ L) hay chỉ đổi câu chào + tranh spot nhân vật (cỡ S)?
