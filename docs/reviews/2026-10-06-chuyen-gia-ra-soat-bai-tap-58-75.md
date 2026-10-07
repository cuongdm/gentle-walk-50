# Rà soát bài tập cho phụ nữ 58–75 — ba góc nhìn chuyên gia (06/10/2026)

_Ba vai: (1) sinh lý vận động người lớn tuổi (ACSM/ACE senior fitness), (2) kiểm số liệu theo nguồn gốc, (3) tuân thủ App Review 1.4.1. Phạm vi: `docs/design/infographic-nguon-bai-tap-brief.md` (v1), chương trình hiện có trong `iOS/App/Resources/Content/sessions.json`, `exercises.json`, kịch bản A2/A4/A10/A11, kế hoạch `docs/plans/2026-09-30-content-4-groups.md`. Nguồn đã đọc ghi ở cuối; mã `[S#]` theo `docs/research/2026-09-30-exercise-standards.md` (STD), mã mới `[N#]` ở mục Nguồn._

## Kết luận nhanh

1. Infographic v1: khung và nguồn đúng, nhưng **27/36 mục cần sửa**: số động tác sai (10/15/17 so với app 8/12/12), liều giãn cơ ghi "lặp 2–3 lần" trong khi app giữ 1 lần, mốc phút không khớp `sessions.json`, câu dừng trong app trích sai, "Go4Life" đã nghỉ, "sắp thêm" liệt kê bài đã có.
2. Thiếu sót lớn nhất cho 58–75: **thăng bằng chưa nằm trong lịch tuần**. WHO 2020, World Falls Guidelines 2022 (GRADE 1A), NIA, Otago đều yêu cầu ≥3 buổi/tuần. Hiện Balance là Extra Pro, không có trong `WeeklyPlanner`.
3. Giãn cơ giữ 15 s ở Gentle thấp hơn mức người lớn tuổi (ACSM 30–60 s; Feland 2001: 60 s hơn 30 s hơn 15 s ở ≥65). Sửa bằng số liệu, không cần clip.
4. Số rep ghế (5–8) thấp hơn Otago/NIA (10, 10–15) và chưa có luật tăng dần theo khả năng. Sửa bằng số liệu.
5. Không cần tạo nhiều bài mới. Phương án đề xuất: **+4 bài, 2 clip mới, 2 tranh, ~35 câu thoại**; bắt buộc trước ra mắt chỉ là bộ "Steady set" ghép từ bài sẵn có + sửa liều.
6. Tên tổ chức trên infographic: được ghi dạng trích nguồn (chữ, không logo) kèm dòng "not affiliated with or endorsed by". Chữ "NHS" là nhãn hiệu Anh: chỉ dùng trong dòng nguồn, không đưa vào tiêu đề hay tên chương trình.
7. Giữ nguyên: không nhắm mắt, không bỏ tay vịn hoàn toàn, không xuống sàn, không cầu thang. World Falls Guidelines có nhắc tập đứng dậy từ sàn, nhưng app đã chốt không làm sàn → NO-GO, ghi rõ.

## Phần 1 · Rà infographic v1

Ký hiệu: ✅ đúng · ⚠️ chưa chính xác · ❌ sai · ❔ không có nguồn. Số dòng là của file v1.

| # | Mục (dòng v1) | Đang ghi | Kết quả | Sửa thành | Nguồn |
|---|---|---|---|---|---|
| 1 | Tiêu đề (42) | "Every move, from a trusted source" | ⚠️ | "Every move has a public source" (tránh ngụ ý được chứng thực) | Luật CDC/NIH về ngụ ý endorsement [N9][N10] |
| 2 | 3 con số (45–47) | 5 nguồn · 4 nhóm · 0 bài xuống sàn | ✅ (0 sàn: `exercises.json` không có bài sàn) | Giữ; "5 bộ hướng dẫn công" thay "5 nguồn chính thống" | — |
| 3 | Nguồn 1 (56) | "Go4Life / Exercise & Physical Activity", 4 loại bài | ⚠️ | "NIA, Exercise & Physical Activity (Your Everyday Guide; Workout to Go; trước đây là Go4Life)". Trang NIA hiện tại nói **3 loại** (aerobic, sức mạnh, thăng bằng) + đoạn riêng về giãn cơ; "4 loại" chỉ đúng với Everyday Guide bản in | NIA trang hiện tại [N5]; go4life.nia.nih.gov không còn phân giải (06/10/2026); S9 |
| 4 | Nguồn 2 (57) | 150–300 phút · sức mạnh ≥2 ngày · thăng bằng cho 65+ · "start low, go slow" | ✅ | Giữ; thêm "làm việc theo sức mình" (relative intensity) | HHS 2018 p.67–68 (Key Guidelines for Older Adults), p.10 và p.88 ("start low and go slow") [N1] |
| 5 | Nguồn 3 Otago (58) | 5 bài sức mạnh chân · 12 bài thăng bằng · "vịn 2 tay → 1 tay → không vịn" | ⚠️ | 5 và 12 đúng. Thang vịn của Otago là "hold support → no support"; "2 tay → 1 tay → không" chỉ ở Sit to stand; bậc "1 ngón tay" là của NIA. Ghi: "vịn → vịn nhẹ → (sau này) không vịn" | Otago UNC 2024 p.29–30 [N4]; NIA Everyday Guide p.68 [S9] |
| 6 | Nguồn 3 STEADI (58) | Chair Rise, test thăng bằng 4 mức | ✅ | Giữ; 4 mức = chụm chân → nửa so le → so le → một chân, mỗi mức 10 s, mắt mở | Bản in lại trong Otago UNC p.23 [N4]; S17, S18 |
| 7 | Nguồn 4 NHS (59) | Bài ngồi, sức mạnh, thăng bằng, giãn; "mỗi bài 3–5 câu" | ✅ | Thêm "ít nhất 2 lần/tuần" (NHS ghi ở cả 4 trang) | NHS 4 trang, xem lại 2023–2024 [N6] |
| 8 | Nguồn 5 WFG (60) | Thăng bằng + chức năng có tăng dần · cộng sức mạnh · ≥3 buổi/tuần · tai chi có bằng chứng | ✅ | Thêm "≥12 tuần, tiếp tục lâu hơn thì tốt hơn" (GRADE 1A); tai chi và/hoặc sức mạnh kháng lực "khi khả thi" (1B); "đi bộ đơn thuần khó giảm ngã" | WFG 2022, mục Exercise interventions [N2] |
| 9 | Chú thích lọc (64) | SSS 2022, OARSI 2019, Arthritis Foundation, AAOS | ✅ | Giữ; OARSI = "tập luyện trên cạn có cấu trúc là điều trị lõi"; Walk With Ease = 3 buổi/tuần × 6 tuần | SSS [N3]; OARSI p.1 [N7]; WWE [N8]; S27 |
| 10 | Walk, liều (72) | 150 phút/tuần, "có tập vẫn hơn không" | ✅ | Giữ | HHS p.67–68 [N1] |
| 11 | Walk, app (72) | "Buổi 5–15 phút, hằng ngày theo kế hoạch" | ⚠️ | Thẻ ghi số phút thật: 5–18 phút (`sessions.json` L3631 walk.inplace.long = 17:48; L3006 strong = 12:07). Gói Pro: 3/5 ngày đi bộ, gói miễn phí: mọi ngày tập | `WeeklyPlanner.swift:29–45` |
| 12 | Chair, liều (73) | ≥2 ngày/tuần, mọi nhóm cơ lớn, 8–12 lần | ✅ | Giữ | HHS p.61, p.67 [N1] |
| 13 | Chair, app (73) | "2–3 ngày/tuần, không tập cùng nhóm cơ 2 ngày liền" | ⚠️ | Pro = 3 ngày có bài sức mạnh (ngày ghế + 2 ngày đi bộ có 1–2 bài); miễn phí = 1–2 bài mỗi ngày tập. Bỏ câu "không cùng nhóm cơ 2 ngày liền" (không thấy trên trang NIA hiện tại; STD gán cho [S7] chưa xác minh) | `WeeklyPlanner.swift:29–35, 44–45`; [N5] |
| 14 | Balance, liều (74) | "~3 buổi/tuần cho người lớn tuổi" | ✅ | Giữ; đây là mức của cả NIA, WHO, WFG | NIA [N5]; WHO 2020 [S4]; WFG [N2] |
| 15 | Balance, app (74) | "Buổi ngắn 5–6 phút, 3 ngày/tuần" | ❌ | Hiện Balance là Extra chỉ Pro, không nằm trong lịch tuần, dài 8:40. Sau sửa (Phần 2, C1): "Steady set 2 phút sau mỗi buổi + Balance 6–7 phút" | `SessionCatalog.swift:49`; `WeeklyPlanner.swift:29–35`; `sessions.json` L10323 |
| 16 | Stretch, liều (75) | ≥2–3 ngày/tuần, sau khi cơ ấm | ✅ | Giữ | ACSM 2011 qua tóm tắt [S5]; NIA [N5] |
| 17 | Stretch, app (75) | "Buổi 6–8 phút, hoặc 2–3 phút sau Walk" | ⚠️ | Thật: 7–18 phút (`sessions.json` L13131 seated.strong = 18:05); hạ nhiệt 3:10–3:27. Sau sửa: 7–12 phút | `sessions.json` L11755–L15908 |
| 18 | Talk test (78) | "nói được, không hát được" | ✅ | Giữ | HHS p.60, p.71 [N1] |
| 19 | Start low (79) | Gentle → Steady → Strong | ✅ | Giữ; ghi là cách app, không phải của nguồn | HHS p.10 [N1] |
| 20 | Walk, 10 động tác (86–99) | 10 bài gồm Grapevine, Walk forward & back; Low kick, Hamstring curl; bản ngồi "—" ở 3 bài | ❌ | **8 bài** đúng tên app: March · Heel dig · Side step · Knee lift · Toe tap forward · Heel to back · Weight shift · Arm swing / press. **Mọi bài đều có bản ngồi** (`videoSeated`). Grapevine và Walk forward & back đã bỏ 30/09 (bắt chéo chân; lùi khi chóng mặt) | `exercises.json` L5–L209; plan §2.1 |
| 21 | Nguồn từng bài đi bộ (90–99) | Toe tap "NIA"; Weight shift "NHS" | ⚠️ | Toe tap: "NIA (không khoá gối), mô tả của app"; Weight shift: "đề xuất app, cue gối theo mũi chân của NHS" | STD §2.3; S7, S12 |
| 22 | Cấu trúc buổi 10 phút (101–102) | 2:00 · 6:00 · 2:00 | ⚠️ | 2:00 · 6:00 · ~3:00 (hạ nhiệt thật: march 60 s + calf 82 s + chest 35 s) | `sessions.json` L3006 |
| 23 | Ghế đúng (108–113) | chắc, không bánh xe, ~43 cm, ngồi phía trước, bàn chân phẳng | ✅ | Giữ | NHS [N6]; STEADI 30-Second Chair Stand [S17] |
| 24 | Chair, 15 động tác (115–133) | 15 bài; tên khác app | ❌ | **12 bài** đúng tên app: Sit-to-stand · Seated knee lift · Seated leg extension · Heel and toe raises · Wall push-up · Single-leg stand · Side leg raise · Back leg raise · Knee curl · Mini-squat · Arm raises · Seated row. Toe raise gộp vào Heel and toe raises; Torso twist thuộc nhóm Stretch; Toe taps là khởi động | `exercises.json` L210–L506 |
| 25 | Liều gốc từng bài ghế (119–133) | STEADI 10–15; NIA 10–15; Otago 10; NHS 5 | ✅ | Giữ, nhưng ghi thêm "app bắt đầu 5–8 lần (Gentle), lên 10–12 (Strong)" sau khi sửa liều | S18; S9 p.48–65; [N4] p.29; [N6] |
| 26 | Ba nhãn (136–138) | Breathe out as you lift · Never lock your knees · Hands on the chair, then stand | ✅ | Giữ ("Never lock" → NIA "avoid locking") | S7, S9 p.42; A4 `a4.to-stand.1` |
| 27 | Stretch, câu chủ đề (142) | "Stretch to a gentle pull, never to pain" | ✅ | Giữ | app-context; NIA "don't stretch so far that it hurts" [N5] |
| 28 | Stretch, đồng hồ (144) | "Giữ 15–30 giây · lặp 2–3 lần" | ❌ | App hiện giữ **1 lần** 15/20/30 s, vòng 2 chỉ cho 3 tư thế ở Steady/Strong (chốt 30/09 #2). Sau sửa cho 58–75: "Giữ 20–30 giây · 2 vòng cho tư thế chính · không nhún · thở đều" | `sessions.json` L11755 (hold 15); ACSM người lớn tuổi 30–60 s [S5]; Feland 2001 [N11] |
| 29 | Stretch, 17 động tác (146–155) | 17 bài gồm quad, figure-4, wrist, cat-cow, breathing | ❌ | **12 tư thế** đúng tên app: Neck turn · Side of the neck · Chin tuck · Shoulder rolls · Chest and shoulders · Upper back reach · Upper back twist · Side stretch · Back of the thigh · Ankle circles and points · Calf stretch · Overhead reach at the wall. Thở là đoạn kết, không phải tư thế | `exercises.json` L507–L776; A10 §2, §8.1 |
| 30 | Hai mẫu buổi giãn (158–159) | 6 phút ngồi 6 bài × 40 s; 8 phút đứng 7 bài × 45 s | ❌ | Theo app: Seated gentle ≈ 9 phút (neck turn, chin tuck, chest, twist, thigh hoặc ankle, side); Standing gentle ≈ 7 phút (calf, overhead, side, chest, neck turn). Bỏ số giây từng bài | `sessions.json` L11755, L14055 |
| 31 | Thang vịn (164) | 2 tay → 1 tay → 1 ngón tay → không vịn (Otago, NIA) | ⚠️ | App chỉ đi tới "đầu ngón tay"; "không vịn" không có ở cấp nào (A11 §2.2). Vẽ 3 bàn tay + chú thích "Bậc không vịn: để sau, khi đã vững nhiều tuần". Nguồn: NIA (1 ngón), Otago (hold → no support) | A11 §2.2; S9 p.68; [N4] p.30 |
| 32 | Buổi Balance 6 phút (166–176) | 7 mốc, 6:00; tên bài khác app | ❌ | Buổi thật 8:40 (sau sửa: 6–7 phút). Tên app: Weight shift · Sit-to-stand · Tandem stance · Single-leg stand · Sideways walking · Heel and toe raises · Heel-to-toe walk (chỉ Strong, **đợt B, chưa có**) | `sessions.json` L10323; `exercises.json` bl.* |
| 33 | Liều Balance (171–176) | 5 lần; 10 s ×2; 10 bước ×2; 8+8; 5–10 bước | ✅ | Giữ (Otago: 5 stands 2 tay; tandem 10 s; one leg 10 s → 30 s; sideways 10 bước ×4; heel/toe raises 10; NHS heel-to-toe ≥5 bước) | [N4] p.29–30; [N6] |
| 34 | Câu dừng (188) | "Stop and rest if you feel chest pain, dizziness or you can't catch your breath. If it doesn't pass, call your doctor." | ❌ | Không phải câu trong app. Câu thật: "If you feel sharp pain, chest pain, or dizziness, stop and rest." · "If it keeps happening, talk to your doctor." (a7.stop.1/.2) · onboarding: "Chest pain, feeling faint or very short of breath? Stop now and call emergency services." | A-min-support L150–151; `Localizable.xcstrings` |
| 35 | 9a danh sách dừng (181–186) | 6 dấu hiệu | ✅ | Giữ | NIA Everyday Guide p.33 [S9]; MedlinePlus [S24] |
| 36 | 9b lọc theo cơ thể (194–197) | 4 chip | ⚠️ | Hông: ✅ (AAOS). Gối: ghi "Cleveland Clinic" thôi; OARSI chỉ nói tập có cấu trúc là điều trị lõi, không nói độ sâu squat. Loãng xương: "xoay chậm, biên vừa" (SSS: xoay an toàn nếu mượt), ưu tiên duỗi lưng ✅. Vai ✅ | S27, S29, S31; SSS Box 3 [N3]; S37 |
| 37 | 9c "Sắp thêm cho nhóm 65+" (199–203) | 4 ô | ❌ | Bỏ chữ "65+" (luật nhãn tuổi). Heel-to-toe walk đã có trong `exercises.json` (bl.heel-toe-walk, clip B3 đợt B); thang tay vịn Sit-to-stand đã có (A11). Thật sự còn thiếu: Walking backwards (vịn) · Walk and turn · Heel walking / Toe walking (vịn) · Standing back extension (Straight) | [N4] p.29–30; SSS [N3] |
| 38 | Chân trang nguồn (207) | "NIA Go4Life · … · World Guidelines for Falls Prevention (Age and Ageing, 2022)" | ⚠️ | Đổi "NIA Go4Life" → "NIA Exercise & Physical Activity"; thêm Strong, Steady and Straight (BJSM 2022), OARSI 2019, Arthritis Foundation Walk With Ease, AAOS OrthoInfo vì có trong thân bài; WFG ghi "Montero-Odasso et al., Age and Ageing 2022" | [N2][N3][N5] |
| 39 | Miễn trừ (208) | "general fitness… not diagnose or treat… Talk to your doctor" | ✅ | Thêm: "Not affiliated with or endorsed by any organisation named." | [N9][N10] |
| 40 | Checklist (218) | "Số liệu giữ nguyên như brief" | ❌ | Thay bằng bảng số liệu v2 | — |

**Tên tổ chức trên infographic công khai (không logo).** Ghi tên tổ chức để **trích nguồn** là cách dùng thông thường (nominative use) và không cần xin phép khi: chỉ chữ, nằm trong dòng "Sources"/"Built from", không có logo, không có chữ "approved/endorsed/certified/partner", kèm miễn trừ không liên kết. Căn cứ đã xem: CDC nói nội dung là public domain nhưng tên/logo "should never be used to promote or suggest endorsement" [N10]; NIH có chính sách tương tự về "appearance of endorsement" (chỉ thấy qua tóm tắt tìm kiếm, trang chính sách trả 403) [N9]; NHS England: chữ "NHS" là nhãn hiệu, không được dùng trong tên tổ chức, slogan hay tên chương trình (tóm tắt tìm kiếm) [N12]. Vì vậy: (a) không đặt tên tổ chức trong tiêu đề hay tên nhóm bài; (b) không viết "NHS exercises" như tên sản phẩm, chỉ "NHS Live Well (nhs.uk)" trong dòng nguồn; (c) Otago là tên chương trình của ACC/Đại học Otago: ghi "Otago Exercise Programme" trong nguồn, không gọi app là "Otago-based". Đây là nhận định nội dung, không phải tư vấn pháp lý; luật sư nhãn hiệu đang kiểm tên app có thể xác nhận cùng lúc.

## Phần 2 · Chương trình bài tập cho 58–75

### 2.1 Liều chuẩn người lớn tuổi so với app

| Thành phần | Nguồn người lớn tuổi (đã đọc) | App hiện tại | Khoảng cách |
|---|---|---|---|
| Aerobic | 150–300 phút/tuần vừa; "làm theo sức mình"; "có tập vẫn hơn không" (HHS p.67–68 [N1]; WHO [S4]; WFG [N2]) | Walk 5–18 phút, 3–5 ngày | Đạt về nguyên tắc; tổng tuần thấp nhưng đúng "start low" |
| Sức mạnh | ≥2 ngày (HHS); Otago 3 lần/tuần cách ngày, 10 rep, đủ 2×10 mới tăng [N4] p.18, 25, 29; NIA 10–15 [S9] | Pro 3 ngày, free mỗi ngày 1–2 bài; rep 5/6/8 (`sessions.json` L6810, L7743, L8788) | Rep thấp; chưa có luật tăng |
| Thăng bằng | ≥3 ngày/tuần, bài thách thức thăng bằng + chức năng, tăng dần, ≥12 tuần (WFG 1A [N2]; WHO ≥3 ngày [S4]; NIA "about three sessions" [N5]; Otago ≥3 [N4] p.18) | Extra Pro, không trong lịch; ngày ghế Steady/Strong có 1 bài thăng bằng | **Thiếu** |
| Giãn cơ | 30–60 s mỗi lần ở người lớn tuổi, ≥2–3 ngày (ACSM qua tóm tắt [S5]); 60 s hiệu quả nhất ở ≥65 [N11] | 15/20/30 s ×1 (+vòng 2 ở 3 tư thế) | Gentle thấp |
| Nhịp rep | 2–3 s lên, 4–5 s xuống; nghỉ 1–2 phút giữa set [N4] p.25 | 2–3 / 1 / 3–4 s; nghỉ 10–15 s giữa bài | Đạt |
| Tiến trình | Otago 4 mức A–D theo khả năng; WFG "progressed in intensity" | Chỉ theo check-in hằng ngày (Achy/Okay/Great) | Thiếu tiến trình theo khả năng |
| Độ dài buổi | Bài ghế ≥10 phút, không quá 1 giờ (Delphi 2014 [N13]); WWE đi bộ 10–40 phút [N8] | 5–18 phút | Đạt; giãn cơ Strong 18 phút hơi dài cho nhóm này |

### 2.2 Bảng thay đổi

Chi phí: (a) số liệu/liều · (b) câu thoại mới · (c) tranh minh hoạ · (d) clip video mới.

| Mức | Hiện tại (`file:line`) | Đề xuất | Lý do, nguồn | Chi phí |
|---|---|---|---|---|
| **Critical** | Thăng bằng không trong lịch tuần: `WeeklyPlanner.swift:29–35` (proPattern: walk, stretch, walk, chair, longWalk), `:44–45` (free: walk + 1–2 bài ghế); Balance = Extra Pro `SessionCatalog.swift:49` | **"Steady set" ~2 phút sau phần hạ nhiệt của mọi buổi chính** (cả free): Tandem stance 10 s ×2 mỗi chân + Sit-to-stand ×5 (2 tay) hoặc Single-leg stand 10 s ×2 (vịn). Chip Standing is hard → bản ngồi: Weight shift ngồi + Seated knee lift tay với. Tính là "steady minutes" trong tổng kết tuần. Balance 6–7 phút giữ làm Extra | WFG 2022: ≥3 buổi/tuần, GRADE 1A; "đi bộ đơn thuần khó giảm ngã" [N2]; Otago: "walking alone… will not reduce their chances of falling" [N4] p.26; WHO ≥3 ngày [S4]; NIA [N5] | (a) template `ses.steady-set.*` trong `sessions.json`; code `SessionBuilder`/`WeeklyPlanner`; dùng lại `a11.*`, `a4.v6.*`; (b) 4–6 câu mở/kết |
| **Critical** | Tiến trình chỉ theo check-in; mức vịn theo cường độ (A11 §2.2) | **Thang hỗ trợ theo khả năng, lưu theo bài**: 2 tay → 1 tay → đầu ngón tay; lên bậc khi 2 buổi liền giữ đủ giây mà không bấm This hurts/Break; xuống bậc khi "Wobbly" hoặc chip Dizzy. Rep: 5–6 → 8 → 10, rồi 2 set cho Sit-to-stand (nghỉ 60 s). Không bao giờ "không vịn" trong 12 tuần đầu | WFG: cá nhân hoá, tăng dần ≥12 tuần [N2]; Otago: 2×10 rồi mới tăng, levels A–D [N4] p.25, 29–30; STEADI Chair Rise 2 set nghỉ 1 phút [S18] | (a) + code (`Adaptation.swift`, schema V3 trường supportLevel); (b) ~6 câu ("Last time you were steady with one hand. Try fingertips today, if it feels right.") |
| **Important** | Giãn cơ hold 15/20/30 s ×1: `sessions.json` L11755 (`"hold": 15`), A10 §1 | Gentle 20 s ×1 + vòng 2 cho calf/thigh, chest, twist; Steady 30 s ×1 + vòng 2; Strong 30 s ×2 (tổng ≥60 s/nhóm cơ). Bù thời gian bằng bớt tư thế ở Steady/Strong để buổi ≤12 phút | ACSM người lớn tuổi 30–60 s, tổng 60 s [S5 tóm tắt]; Feland 2001 ≥65: 60 s > 30 s > 15 s [N11] | (a) `build_content.py` hold; (b) 1 câu `a5.20s` "Twenty more seconds." |
| **Important** | Rep ghế 5/6/8: `sessions.json` L6810, L7743, L8788 (`"reps"`) | Gentle 6–8 · Steady 8–10 · Strong 10–12; Sit-to-stand Strong 2 × 8–10 | Otago 10 [N4]; NIA 10–15 [S9 p.42]; HHS 1 set 8–12 p.61 [N1] | (a); `a5.n.13–15` đã có |
| **Important** | Thiếu bài Otago có vịn: Backwards walking, Walking and turning, Heel walking, Toe walking (`exercises.json` chỉ có bl.tandem, bl.side-walk, bl.heel-toe-walk) | Thêm **Walking backwards** (10 bước, tay trượt dọc mặt bếp), **Walk and turn** (đi 4–6 bước, quay chậm, về) vào Balance Steady/Strong; **Heel walking / Toe walking** (vịn mặt bếp, 10 bước) vào Balance Strong. Ẩn với Dizzy và Standing is hard | Otago levels B–D [N4] p.30; NIA ví dụ "walking backward or sideways" [N5]; WFG "stepping and walking in different directions" [N2] | (b) ~14 câu; (c) 2 tranh (lùi, quay); **không clip** (AI không làm được đi chuyển, cùng quyết định 30/09 cho Sideways walking); heel/toe walking dùng clip Heel and toe raises đứng |
| **Important** | "Straight" (duỗi lưng) chỉ có Seated row, Chest, Upper back reach, Back leg raise | Thêm **Standing back extension** (Otago warm-up: tay chống hông, ngả nhẹ ra sau 5 lần, không ngửa cổ) vào khởi động Balance và Morning stretch; cue "back long, bend from the hips" ở Sit-to-stand cho chip Lower back | SSS 2022: tăng cơ duỗi lưng, tránh gập sâu lặp lại, xoay mượt là an toàn [N3]; Otago warm-up Back Extension 5 lần [N4] p.29 | (d) **1 clip** (S13, 8 s) hoặc (c) tranh; (b) 4 câu |
| **Important** | Clip lệch giọng (A11 §7): Heel and toe raises trong Balance là bản đứng nhưng clip V4-1 ngồi; tandem clip B1 hai tay trong khi Steady nói một tay | **1 clip** Heel and toe raises đứng vịn ghế (V4-3 trong V-exercise-clips, chưa làm); tandem: chấp nhận, thêm câu "The video shows both hands; use one if you feel steady" | Nhất quán giọng–hình (CMP §4.6) | (d) 1 clip; (b) 1 câu |
| **Important** | Sàng lọc: onboarding có "heart condition, recent surgery… check with your doctor" và "Chest pain… call emergency services" (`Localizable.xcstrings`); chip Dizzy | Thêm **một chip** "I've had a fall or feel unsteady" (không hỏi bệnh): hiệu ứng = 2 tay ở mọi bài, không Heel-to-toe walk, Walking backwards chỉ 4 bước, thêm câu "If you've fallen recently, it's worth telling your doctor". Thêm vào màn Before you start: "fainting or dizziness in the last year → check with your doctor first" | WFG ba câu hỏi: ngã 12 tháng, thấy không vững, lo ngã [N2]; PAR-Q+ câu 3 [S25]; 1.4.1: chỉ lọc bài, không chẩn đoán | (a) `BodyLimit` thêm case; code lọc; (b) 2 câu |
| **Important** | Hạ huyết áp tư thế: đã có 30 s chuyển ngồi→đứng, `a7.morning.2`, `a7.dizzy` | Giữ; thêm "pause for a breath" sau mỗi Sit-to-stand trong Steady set; không nhìn lên trần trong Overhead reach (cue có sẵn) | WFG: hạ huyết áp tư thế là nguyên nhân tim mạch hay gặp nhất [N2]; S36 | (b) 1 câu |
| **Important** | Độ dài: Stretch seated strong 18:05 (`sessions.json` L13131), steady 15:35 | Cắt còn ≤12 phút (bớt neck tilt/shoulder rolls ở vòng 2); Chair moves 13–15 phút giữ | Delphi: ≥10 phút, tăng dần [N13]; nhóm 60–72 mới tập | (a) |
| Minor | Mắt nhắm, không vịn: đã cấm (A11, STD §5.1) | Giữ nguyên. Ghi rõ trong STD: "không nhắm mắt ở mọi cấp" là quyết định app, dè dặt hơn NIA | NIA cho nhắm mắt "when you are steady" [S9 p.68]; không giám sát → không | — |
| Minor | Câu Otago "recovery step is okay" chưa có | Thêm "Taking a quick step to catch yourself is fine. That's what we're practising." | Otago: cho phép bước điều chỉnh [N4] p.25 | (b) 1 câu |
| Minor | Nhịp giọng: 130 từ/phút, ≤16 từ, im 2–4 s (A2 §1) | Giữ; Gentle: đếm giây thành tiếng ở mọi lần giữ ("five… four…"), không chỉ "Five more seconds" | Người 65+ nghe không nhìn màn hình; không có nguồn, là quyết định sản phẩm | (b) đã có `a5.n.*` |
| Minor | STD §1.1 nền "adults", ghi chú chờ rà | Viết lại §1.1 theo Key Guidelines for Older Adults; thêm S48–S55 | HHS p.67 [N1] | tài liệu |
| Minor | Tai chi (phase 2) | Giữ phase 2; WFG 1B và OARSI mind-body ủng hộ khi làm | [N2][N7] | sau |
| **NO-GO** | Đứng dậy từ sàn (WFG nhắc "backward chaining") | Không làm: app không xuống sàn (app-context). Ghi trong STD lý do và để Help một dòng "nếu bạn ngã: gọi người giúp" không phải bài tập | WFG [N2]; app-context NO-GO | — |
| **NO-GO** | Cầu thang (Otago level D "as instructed") | Không làm v1: cần tay vịn và giám sát; xét lại phase 2 với màn xác nhận tay vịn như Walking pad | Otago [N4] p.30 | — |
| Giữ | Seated chỉ "quicker", không brisk; talk test; warm-up 2 phút trước pha nhanh; 5 phút không pha nhanh | Đúng cho 65+ | S22; HHS relative intensity p.67 | — |

### 2.3 Lời thoại và chữ cần đổi cho 58–75

- Không có câu nào vi phạm luật cấm trong A2/A4/A10/A11 đã đọc. Giữ "steadier", "on your feet"; không "fall", không tên bệnh.
- Thêm cho mọi bài thăng bằng: tên bài → mức vịn → "eyes on one spot ahead" → đếm giây → "both hands back on the chair". A11 đã có khung này; chỉ thêm câu bậc thang (Phần 2.2).
- Chip Lower back: "nose over toes" ở Sit-to-stand thay bằng "chest up, back long, lean a little" (SSS "think straight"); câu `a4.v1.var.joint-lean` đã gần đúng, dùng cho cả Lower back.
- Người 65+ hay dùng bản ngồi: mọi bài Steady set phải có câu bản ngồi trước (luật "bản dễ trước").

## Phần 3 · Có cần thêm bài hoặc clip không

Không cần tạo nhiều. Thiếu sót chính là **lịch và liều**, không phải số bài. Thư viện 35 bài hiện có đã phủ 5 bài sức mạnh và 7/12 bài thăng bằng của Otago.

| Phương án | Bài mới | Clip mới | Tranh | Câu thoại | Nội dung | Bắt buộc trước ra mắt |
|---|---|---|---|---|---|---|
| **Tối thiểu** | 0 | 0 | 0 | ~12 | Steady set ghép từ Tandem stance, Single-leg stand, Sit-to-stand, Heel and toe raises (clip ngồi tạm); hold giãn 20/30/30; rep 6–8/8–10/10–12; chip "fall or unsteady"; infographic v2 | Tất cả |
| **Đề xuất** | 4 (Walking backwards · Walk and turn · Heel & toe walking · Standing back extension) | **2** (Heel and toe raises đứng V4-3 · Standing back extension S13) | 2 (lùi, quay) | ~35 (EN) + bản Việt qua Vibi | Tối thiểu + thang hỗ trợ theo bài + 4 bài Otago vào Balance Steady/Strong + cắt giãn cơ ≤12 phút | Tối thiểu + clip V4-3 + thang hỗ trợ (code); 4 bài mới và S13 có thể sau ra mắt |
| **Lý tưởng** | 6 (+ Semi-tandem stance làm bài riêng · Seated steady set cho Standing is hard) | 4–5 (+ B3 Heel-to-toe walk, W2-7 Weight shift đã trong đợt B; + tranh tĩnh semi-tandem) | 3 | ~50 | Đề xuất + Balance có 3 cấp thật theo thang Otago A–D + tai chi chậm phase 2 (10–15 clip, ngoài phạm vi này) | Như Đề xuất |

Clip dùng lại / dựng lại thay vì tạo mới: Sideways walking → W2-2 (đã chốt); Heel walking / Toe walking → clip Heel and toe raises đứng (V4-3) + giọng "now walk ten small steps on your heels along the counter"; Semi-tandem → khung tĩnh từ B1; bản chậm của mọi bài ghế → time-remap (đã có quy trình). Credit ước: 2 clip × 1,5 lượt × 12–15 ≈ 40–50 credit.

## Phần 4 · Kế hoạch thực hiện (cập nhật 06/10 theo chốt Q1 = Đề xuất, Q2–Q5 ở Phần 5)

| # | Việc | File | Kiểm |
|---|---|---|---|
| 1 | Cập nhật chuẩn: STD §1.1 theo Older Adults, thêm nguồn S48–S55 (WFG, SSS, Delphi, WHO, Otago UNC, OARSI, WWE, Feland); app-context: Price model thêm "Steady set 2 phút trong gói miễn phí", Risks bỏ dòng "rà lại STD" | `docs/research/2026-09-30-exercise-standards.md`, `app-context.md` | đọc lại |
| 2 | Liều: hold Gentle 20 s · Steady 30 s · Strong 30 s, vòng 2 cho calf/thigh, chest, twist ở mọi cấp; rep 6–8/8–10/10–12; Sit-to-stand Strong 2 set nghỉ 60 s; cắt Stretch Steady/Strong ≤12 phút (bỏ neck tilt và shoulder rolls khỏi vòng 2, Strong bỏ upper back khi đã có chest ×2) | `tools/content/build_content.py` → `iOS/App/Resources/Content/sessions.json`; `docs/scripts/A10-stretch.md` §1, `A4-chair-moves.md` §1; thêm `a5.20s`, `a5.30s` đã có | `ContentValidator`: hold Gentle ≥20 s, tổng giữ mỗi nhóm cơ chính ≥40 s (Gentle) / ≥60 s (Steady, Strong), rep 6–12, Stretch ≤12:30 |
| 3 | Steady set (miễn phí, Q2): template `ses.steady-set.{gentle,steady,strong}` + bản ngồi `ses.steady-set.seated`; `PlannedDay.steadySet = true` mọi ngày tập, free và Pro; `SessionBuilder` nối sau cool-down; thẻ Today ghi "+2 min steady"; tổng kết tuần đếm "steady minutes" | `WeeklyPlanner.swift`, `SessionBuilder.swift`, `SessionPlan.swift`, `SessionCatalog.swift`, `sessions.json`, `TodayModel.swift` | test: mọi tổ hợp ngày nghỉ → ≥3 ngày có Steady set; free không mở Balance Extra |
| 4 | Chip "I feel unsteady on my feet" (Q3): `BodyLimit.unsteady`, thứ tự sau `.dizzy` trong `limitOrder`; summary "Both hands on the chair"; `BodyLimitFilter` ẩn bl.heel-toe-walk, bl.back-walk, ép 2H ở mọi bài thăng bằng, Walking backwards 4 bước; `OnboardingProfile.startLevel` = Seated khi có chip; S06 thêm dòng dưới hộp lưu ý: "Had a fall recently, or fainted or felt dizzy in the past year? Check with your doctor first." | `Exercise.swift:73`, `BodyLimitFilter.swift`, `OnboardingProfile.swift:52`, `OnboardingCopy.swift:118–139`, `BodyLimitChips.swift`, `Localizable.xcstrings`, `content.vi.json`, `docs/i18n/glossary-vi.md` | `copy_lint.py` 0 findings; test lọc; không đổi `PrivacyInfo.xcprivacy` (xử lý trên máy, không "collected") |
| 5 | Thang hỗ trợ theo bài (Pro): `supportLevel` 2H/1H/tips lưu theo bài trong schema V3; `Adaptation.swift`: lên bậc sau 2 buổi đủ giây không This hurts/Break, xuống khi Wobbly hoặc chip Dizzy/Unsteady; giọng chọn `a11.hands.*` theo bậc | `GentleWalkCore/Plan/Adaptation.swift`, schema V3, `A11-extras.md` §2.2 | test lên/xuống bậc; free luôn 2H |
| 6 | Bài mới trong `exercises.json` (đợt sau ra mắt): bl.back-walk, bl.walk-turn, bl.heel-toe-walking (tranh/clip dùng lại), st.back-ext (`source` S16 p.29 / S49 SSS; `hiddenFor`: dizzy, standingIsHard, unsteady cho hai bài đi); A11 §2.5 câu thoại (~35); D5 gợi ý màn | `exercises.json`, `A11-extras.md`, `D-min-texts.md`, `voice-lines.json` | `ReleaseContentTests` |
| 7 | Clip và tranh (Q5): **V4-3b Standing toe raise** (8 s, nghiêng MF-04c, ghép với V4-alt sẵn có thành "Heel and toe raises, standing") · **S13 Standing back extension** (8 s, nghiêng, tay chống hông, ngả ≤15°, mắt nhìn ngang; dừng sau 3 lượt → tranh) · 2 tranh Walking backwards, Walk and turn (ChatGPT thread, `build_art.py`, 0 credit) | `P-production-prompts.md` §9, `assets/video/A/`, `assets/art/`, `tools/art/build_art.py` | guard PASS; checklist STD §8.1 thêm dòng "không ưỡn quá, không ngửa cổ"; bảng cận đầu–vai 4 khung/giây |
| 8 | Giọng: render câu mới EN (ElevenLabs) + VI (Vibi), QC `tools/voice/qc_lines.py`; câu mới cho Steady set ưu tiên trước ra mắt (~12), phần còn lại cùng đợt bài mới | `assets/voice/`, `content.vi.json` | QC xanh; `ReleaseContentTests` |
| 9 | Infographic v2 giao designer; mục 12 đổi "chờ chốt" → số đã chốt (Steady set miễn phí, hold 20/30/30, rep 6–8→10–12) | `docs/design/infographic-nguon-bai-tap-brief-v2.md` | — |

Thứ tự: 1 → 2 → 3 → 4 (đủ để ra mắt) → 8 (câu Steady set) → 5 → 7 → 6 → 8 (phần còn lại) → 9 song song từ đầu.

## Nguồn đã đọc (06/10/2026)

**Đã đọc toàn văn** (curl/pdftotext, trích đúng chữ):
- [N1] HHS, *Physical Activity Guidelines for Americans*, 2nd ed. 2018 (PDF): Key Guidelines for Older Adults p.67–68; "about three sessions a week" (chương trình chống ngã) p.73; talk test p.60, p.71; "start low and go slow" p.10, p.88; 1 set 8–12 rep p.61.
- [N2] Montero-Odasso M et al., *World guidelines for falls prevention and management for older adults: a global initiative*, Age and Ageing 2022;51(9):afac205, doi:10.1093/ageing/afac205 (PMC9523684). 96 chuyên gia, 39 nước. Exercise: thăng bằng + chức năng ≥3 buổi/tuần, tăng dần ≥12 tuần, GRADE 1A; Tai Chi và/hoặc kháng lực tăng dần 1B; "General physical activity alone (e.g. walking) is unlikely to prevent falls"; ba câu hỏi 3KQ; hạ huyết áp tư thế; đứng dậy từ sàn.
- [N3] Brooke-Wavell K, Skelton DA et al., *Strong, steady and straight: UK consensus statement on physical activity and exercise for osteoporosis*, BJSM 2022;56:837–846 (PMC9304091). Strong: kháng lực 2–3 ngày/tuần; Steady: thăng bằng + sức mạnh ≥2 lần/tuần [C], người hay ngã 3 giờ/tuần ≥4 tháng [E], Otago/FaME; Straight: tránh gập sâu lặp lại/kéo dài [C], xoay mượt an toàn, tăng cơ duỗi lưng; "how to, not don't do".
- [N4] UNC CGWEP, *Otago Exercise Program: Guide for Physical Therapists*, April 2024 (PDF 83 trang): tần suất p.18; nhịp, nghỉ, bước điều chỉnh p.25; đi bộ ≥2 lần/tuần tới 30 phút và "walking alone… will not reduce their chances of falling" p.26; 4-Stage Balance Test (bản in lại STEADI) p.23; Levels and Repetitions p.29–30 (5 bài sức mạnh, 12 bài thăng bằng).
- [N5] NIA, *Three Types of Exercise Can Improve Your Health and Physical Ability* (trang hiện tại, curl 06/10/2026): 3 loại + đoạn giãn cơ; "Aim for about three sessions of balance exercises a week"; sức mạnh ≥2 ngày; ví dụ walking backward or sideways, heel-to-toe walk, standing from sitting.
- [N6] NHS Live Well: Sitting exercises (xem lại 18/01/2024), Strength exercises (28/02/2024), Balance exercises (07/11/2023), Flexibility exercises (20/11/2023): "at least twice a week"; số lần/giây giữ từng bài.
- [N7] Bannuru RR et al., *OARSI guidelines for the non-surgical management of knee, hip, and polyarticular osteoarthritis*, Osteoarthritis and Cartilage 2019 (PDF mirror ESCEO): Core = arthritis education + structured land-based exercise programs (Type 1 strengthening/cardio/balance-neuromuscular; Type 2 mind-body tai chi/yoga).
- [N8] Osteoarthritis Action Alliance, Walk With Ease program page: "WWE group sessions meet three times per week for 6 weeks", đi 10–40 phút có khởi động và hạ nhiệt; trang Arthritis Foundation (WebFetch) nêu 6 tuần, "manage your pain", "learn to exercise safely".
- [N10] CDC, *Use of Agency Materials*: nội dung public domain; logo/tên không được dùng để ngụ ý endorsement.
- [N13] Robinson KR et al., *Developing the principles of chair based exercise for older people: a modified Delphi study*, BMC Geriatrics 2014;14:65 (Europe PMC XML): 16 chuyên gia, 46 phát biểu, 4 vòng; định nghĩa 5 thành phần (chủ yếu ngồi; ghế để ổn định khi ngồi và đứng; là bậc trong chuỗi tiến tới bài đứng); mỗi buổi có khởi động (88,2%) và hạ nhiệt (82,3%); kháng lực tăng dần theo cá nhân (93,7%); buổi tối thiểu 10 phút (75%), không quá 1 giờ.
- Otago manual ACC/Đại học Otago (PDF [S15]): giảm 35% số ngã trong thử nghiệm có giám sát (không được mượn vào copy).
- WHO 2020 (PMC7719906 [S4], đọc lại): 65+ "varied multicomponent physical activity that emphasises functional balance and strength training at moderate or greater intensity on 3 or more days a week".

**Chỉ abstract hoặc tóm tắt thứ cấp:**
- [N11] Feland JB et al., Phys Ther 2001;81:1110–7 (abstract Europe PMC): ≥65 tuổi, 60 s/lần hiệu quả hơn 30 s hơn 15 s.
- ACSM Position Stand 2009 (Chodzko-Zajko, abstract): aerobic + sức mạnh + giãn cơ; số liệu 30–60 s và thăng bằng ≥2 lần/tuần chỉ qua tóm tắt Kravitz [S5] và kết quả tìm kiếm.
- [N9] NIH Policy Manual 1186 (tên/logo NIH, "appearance of endorsement"): trang trả 403, chỉ qua tóm tắt tìm kiếm.
- [N12] NHS England identity guidelines ("NHS" là nhãn hiệu; không dùng trong tên tổ chức, slogan, tên chương trình): trang trả rỗng, chỉ qua tóm tắt tìm kiếm.
- Go4Life: go4life.nia.nih.gov không phân giải DNS (06/10/2026); trang NIA hiện tại không dùng tên này; không tìm được thông báo nghỉ chính thức.

**Không mở được:** CDC STEADI PDF trực tiếp (chặn; dùng mirror S17/S18 và bản in lại trong [N4]); trang NIA balance (404); ACSM 2009 toàn văn; Mayo [S33].

## Câu hỏi cho chủ app

_Cập nhật 06/10: câu 1 chủ app đã chốt (phương án Đề xuất); câu 2–5 có đề xuất chốt ở Phần 5; còn mở: câu 6 và 7._

1. Steady set 2 phút có vào **gói miễn phí** không? Đề xuất có, vì "steadier" là lời hứa lõi và nguồn yêu cầu ≥3 ngày/tuần.
2. Chấp nhận thêm chip "I've had a fall or feel unsteady" ở S06 (không phải câu hỏi y khoa) không?
3. Thang hỗ trợ theo bài cần schema V3 (lưu bậc từng bài). Làm trước ra mắt hay sau?
4. Giãn cơ: chọn Gentle 20 s hay 30 s? (20 s dè dặt, 30 s đúng ACSM; Feland ủng hộ 60 s nhưng quá dài cho giọng dẫn.)
5. Standing back extension: clip (≈15 credit) hay tranh? Walking backwards / Walk and turn: tranh, không clip — đồng ý?
6. Cắt Stretch Steady/Strong xuống ≤12 phút: bỏ tư thế nào (đề xuất bỏ vòng 2 của neck tilt và shoulder rolls)?
7. Tên tổ chức trên infographic: dùng bản chữ + miễn trừ như Phần 1; có đưa luật sư nhãn hiệu xem cùng lúc với tên app không?

## Phần 5 · Đề xuất chốt câu 2–5 (06/10/2026)

_Chủ app đã chốt Q1 = phương án Đề xuất (Steady set + sửa liều + chip + infographic v2 + 4 bài Otago + 2 clip + 2 tranh + ~35 câu). Dưới đây mỗi câu một bảng, một khuyến nghị._

### Q2 · Steady set: miễn phí hay chỉ Pro?

Bằng chứng:
- Nguồn: WFG 2022 khuyến nghị 1A áp dụng "cho mọi người lớn tuổi, bất kể mức nguy cơ"; Otago và WFG nói đi bộ đơn thuần không giảm ngã [N2][N4 p.26]. Gói miễn phí hiện = đi bộ mỗi ngày + 1–2 bài ghế (app-context Price model) → người miễn phí nhận đúng phần "chưa đủ" của chương trình.
- Thị trường: nhóm review nói về thăng bằng/sợ ngã n=393, trung bình 4,54★, tuổi trung vị 68, sẵn lòng trả 2,8% (review-analysis, "BY NEED"); đây là nhóm app nhắm. Đối thủ: Bold/SilverSneakers miễn phí qua bảo hiểm có lớp thăng bằng; yes2next miễn phí có nhóm balance; Bend chỉ mở một routine miễn phí ("Wake Up") và bị "chơi" nhiều nhất; LazyFit paywall ngay sau quiz và 51% review 1–2★ về tiền (CMP §2d; doi-thu). Lời chê lớn nhất của ngách là tiền, không phải thiếu nội dung miễn phí.
- App Review: không có luật bắt nội dung an toàn phải miễn phí; nhưng 1.4.1 soi "greater scrutiny" với app sức khoẻ, và onboarding đã hứa "Steadier it is. Balance moves always come with a chair beside you" (`OnboardingCopy.swift`) — hứa ở màn miễn phí thì nội dung phải có ở gói miễn phí.

| Phương án | Ưu | Nhược | Khuyến nghị |
|---|---|---|---|
| A. Steady set miễn phí (Gentle, 2 tay), Balance Extra 6–7 phút và thang hỗ trợ là Pro | Đúng chuẩn ≥3 ngày/tuần cho mọi người; lời hứa "steadier" thật; Pro vẫn có lý do mua (bài dài, 3 cấp, tiến trình, lịch sử); chỉ thêm 2 phút nội dung miễn phí | Thêm 2 phút vào buổi miễn phí; cần câu "upgrade" không ép | **Chọn** |
| B. Chỉ Pro | Thêm lý do nâng cấp | Người miễn phí (đa số 65+) chỉ có đi bộ, trái WFG 1A; mâu thuẫn câu hứa ở onboarding; dễ bị review "they lock the balance part" trong ngách nhạy tiền | Không |
| C. Miễn phí 14 ngày rồi khoá | Thử rồi mua | Mất đúng lúc thói quen hình thành; app đã cam kết "không bao giờ mất" | Không |

### Q3 · Chip "I've had a fall or feel unsteady"

Bằng chứng:
- WFG ba câu hỏi: ngã trong 12 tháng · thấy không vững khi đứng/đi · lo ngã [N2]. Câu 2 là trạng thái hiện tại, không phải tiền sử bệnh, hợp với kiểu chip S06 ("Knees", "I get dizzy easily").
- 1.4.1 (đọc nguyên văn 06/10): soi app "could be used for diagnosing or treating"; chip chỉ lọc bài, không kết luận, không lưu "tiền sử ngã" → cùng loại với các chip hiện có. 5.1.3: không lưu health data lên iCloud — đã đúng (`cloudKitDatabase: .none`).
- App Privacy: Apple định nghĩa "collect" = truyền khỏi máy; "Data that is processed only on device is not 'collected' and does not need to be disclosed" → không đổi nhãn Privacy, không đổi `PrivacyInfo.xcprivacy`.
- Tone: không "senior", không tên bệnh; từ "fall" không bị cấm trong chip người dùng tự chọn, nhưng A11 và infographic tránh "fall" trong lời HLV và copy công khai → chọn chữ không có "fall" cho chip, để "fall" chỉ trong câu nhắc đi khám.

| Phương án | Ưu | Nhược | Khuyến nghị |
|---|---|---|---|
| A. Chip **"I feel unsteady on my feet"** ở S06 Your body, ngay sau "I get dizzy easily"; summary "Both hands on the chair" | Đúng câu 2 của WFG; cùng mẫu với chip có sẵn (1 màn, không thêm bước); không lưu sự kiện ngã; dịch dễ ("Mình đứng không vững") | Không bắt được "đã ngã nhưng tự thấy vững" | **Chọn** |
| B. "I've had a fall or feel unsteady" | Bắt cả hai | Chữ "fall" lên màn; lưu một tiền sử sự kiện y khoa trên máy; dài, khó dịch gọn | Không |
| C. Màn hỏi riêng 3 câu kiểu WFG (ngã / không vững / lo ngã) | Nhạy nhất | Thành bảng hỏi y khoa (1.4.1 "greater scrutiny"); thêm 1 màn vào onboarding 10 màn vừa rút gọn | Không |
| D. Không thêm chip, chỉ dùng "I get dizzy easily" | Không đổi gì | Chóng mặt ≠ không vững; bỏ sót nhóm lớn nhất | Không |

Tác động trong kế hoạch khi chọn chip: mọi bài thăng bằng 2 tay, không lên bậc; ẩn Heel-to-toe walk và Walking backwards (Walk and turn giữ, 4 bước, tay trên mặt bếp); cấp đi bộ bắt đầu Seated; Steady set dùng Sit-to-stand 2 tay thay Single-leg stand; thẻ Your plan: "Both hands on the chair". Dòng nhắc trên S06 (dưới hộp lưu ý có sẵn): "Had a fall recently, or fainted or felt dizzy in the past year? Check with your doctor first." (PAR-Q+ câu 3; WFG câu 1) — là lời nhắc, không lưu câu trả lời.

### Q4 · Giữ giãn cơ Gentle: 20 s hay 30 s?

Bằng chứng:
- NIA Everyday Guide: 10–30 s, lặp 3–5 lần [S9 p.70]; NHS: 5–10 s nhiều lần [N6]; ACSM: người lớn tuổi 30–60 s, tổng 60 s mỗi nhóm cơ (qua tóm tắt [S5]); Feland 2001: 60 s tốt nhất nhưng mẫu tuổi trung bình 84,7, có giám sát, 5 buổi/tuần [N11] — không chép nguyên cho người mới 60–72 tự tập theo giọng.
- Chịu đựng: người mới, cứng người, hay đau khớp (chân dung khách) khó giữ 30 s tư thế đứng vịn ghế ngay buổi đầu; "a gentle pull" dễ thành "đau" khi giữ dài. Hai lần 20 s có nghỉ đạt tổng 40 s và dễ hơn một lần 30 s.
- Thời lượng (đo từ `sessions.json`): Seated Gentle hiện 9:17 với 7 lần giữ 15 s. 20 s ×1: +35 s → ~9:52. 20 s + vòng 2 cho chest, twist, thigh (+5 lần giữ, +chuyển): ≈ +2:15 → ~11:30. 30 s ×1 không vòng 2: +1:45 → ~11:00 nhưng tổng mỗi nhóm cơ chỉ 30 s. Steady hiện 15:35 (20 s, vòng 2) và Strong 18:05 (30 s, vòng 2) → phải bớt tư thế, không phải bớt giây.

| Phương án | Ưu | Nhược | Khuyến nghị |
|---|---|---|---|
| A. **Gentle 20 s × 2 vòng cho 3 tư thế chính** (calf/thigh, chest, twist), 20 s × 1 cho còn lại; Steady 30 s × 2 (3 tư thế chính); Strong 30 s × 2 mọi tư thế giữ, bớt số tư thế để ≤12 phút | Tổng 40 s (Gentle) / 60 s (Steady, Strong) mỗi nhóm cơ chính; không lần giữ nào quá 30 s; tăng dần đúng "start low"; buổi 11–12 phút | Gentle chưa đạt 60 s của ACSM | **Chọn** |
| B. Gentle 30 s × 1 | Đúng chữ ACSM | Khó cho buổi đầu; tổng vẫn 30 s/nhóm; giọng phải lấp 30 s im lặng | Không |
| C. Giữ 15 s như hiện tại | Không đổi | Dưới mọi nguồn cho người lớn tuổi | Không |

Số lần cho bài lặp (không giữ), mọi cấp: Neck turn 5 mỗi bên (Otago 5) · Chin tuck 10 (Otago 10) · Shoulder rolls 5 · Ankle 10 gập–duỗi + 5 vòng mỗi chiều (Otago ankle 10) · thở kết 30–60 s. Vòng 2 không đọc lại intro/setup (A10 §3 đã có).

### Q5 · Standing back extension: clip hay tranh? (và tính lại V4-3)

**Cách tính.** Omni 1.1 Flash 720p: 8 s = 12 credit, 10 s = 15; draft 360p ≈ 4; ảnh khung Nano Banana 0; 1080p Upscaled 0; retime/ping-pong hold 0 (P §5, §9; video-skill-notes §6). Tỉ lệ lượt thực tế (P §9.2, 30 clip đợt A): 12 clip đạt lượt 1, 6 clip 2 lượt, 4 clip 3 lượt, 2 clip 4 lượt → trung bình ≈ 1,7 lượt/clip; bài tĩnh tại chỗ (S5 chest, S4, S6, V12, B1) đạt lượt 1; bài có tư thế đầu/cổ dễ sai an toàn cần 2–4 lượt (S3 chin tuck lượt 1 ngửa cằm, S2 bốn lượt). Luật đợt: tối đa 3 lượt/clip rồi dừng (như B2).

**S13 Standing back extension** (Otago warm-up: đứng, tay chống hông, ngả nhẹ ra sau, mắt nhìn ngang, 5 lần; SSS: không ưỡn sâu). Rủi ro AI: ưỡn quá, ngửa cổ, nhấc gót — đúng lỗi an toàn với xương thưa → prompt khoá "lean back no more than a hand-width, chin level, eyes on the horizon, heels down", QC bảng cận đầu–vai 4 khung/giây, góc nghiêng MF-04c để thấy cột sống. Không cần bản retime (bài vốn chậm); hold không cần (động tác lặp).

| | Thấp | Dự kiến | Cao |
|---|---|---|---|
| Draft 360p | 0 | 4 | 4 |
| Lượt 720p 8 s | 1 × 12 | 2 × 12 | 3 × 12 |
| Làm lại sau chủ app QC | 0 | 0 | 12 |
| **S13** | **12** | **28** | **52** |

**V4-3 Heel and toe raises, standing.** `assets/video/A/V4-alt` đã có clip **heel raise đứng** (1 lượt, đạt, nghiêng MF-04c; `exercises.json` mv.heel-toe `videoAlt: V4-alt.mp4`). Chỉ thiếu nửa **toe raise đứng** (nhấc mũi chân, gót chạm sàn, tay vịn ghế). Tạo 1 clip 8 s cùng khung MF-04c rồi ghép với V4-alt như V4-1 (heel rồi toe), crossfade ở tư thế đứng. Rủi ro: AI nhấc gót thay vì mũi (lỗi "heel dig vs toe tap" ở W1-5 cần 3 lượt).

| | Thấp | Dự kiến | Cao |
|---|---|---|---|
| Draft 360p | 0 | 4 | 4 |
| Lượt 720p 8 s | 1 × 12 | 2 × 12 | 3 × 12 |
| **V4-3b** | **12** | **28** | **40** |

**Tổng hai clip: thấp 24 · dự kiến 56 · cao 92 credit** (gói Pro 1.000/tháng + 50/ngày; ≈ 3–9% tháng).

| Phương án cho S13 | Ưu | Nhược | Khuyến nghị |
|---|---|---|---|
| A. **Clip** (dừng sau 3 lượt → tranh) | Bài tĩnh tại chỗ là thế mạnh của Omni (5/5 bài cùng loại đạt lượt 1); video cho thấy **biên nhỏ** rõ hơn tranh — đúng điểm an toàn cần dạy; nhất quán với Morning stretch và Stretch (12/12 tư thế có clip); hold/ping-pong 0 credit; ≈ 28 credit | Rủi ro ưỡn quá phải làm lại; cần chủ app QC bảng cận | **Chọn** |
| B. Tranh | 0 credit; cùng cách với Sideways walking | Sideways walking dùng tranh vì AI không làm được di chuyển, không phải vì tranh tốt hơn; tranh tĩnh khó cho thấy "ngả ít thôi"; lệch với 12 tư thế giãn có clip; tranh ChatGPT vẫn cần vẽ, cắt, duyệt | Dự phòng khi A thất bại |
| C. Không làm bài này | 0 | Mất mảnh "Straight" duy nhất đứng cho xương thưa | Không |

### Chốt đề xuất

1. **Q1** (chủ app đã chốt): phương án Đề xuất.
2. **Q2**: Steady set 2 phút **miễn phí** (Gentle, hai tay); Balance Extra 6–7 phút, 3 cấp và thang hỗ trợ là Pro.
3. **Q3**: chip **"I feel unsteady on my feet"** ở S06 sau "I get dizzy easily", summary "Both hands on the chair"; dòng nhắc đi khám dưới hộp lưu ý S06; xử lý trên máy, không đổi nhãn Privacy.
4. **Q4**: Gentle **20 s × 2 vòng** cho 3 tư thế chính (20 s × 1 còn lại); Steady 30 s × 2 (3 tư thế chính); Strong 30 s × 2, bớt tư thế để ≤12 phút.
5. **Q5**: S13 Standing back extension làm **clip** (≈28 credit, dừng sau 3 lượt → tranh); V4-3b chỉ tạo nửa toe raise đứng và ghép với V4-alt sẵn có (≈28 credit). Hai clip: 24 / 56 / 92 credit.

## Phần 6 · Đã làm (06/10/2026, Opus 5.5)

| # | Việc (Phần 4) | Trạng thái |
|---|---|---|
| 1 | Chuẩn tập (STD) theo Older Adults, nguồn S48–S55 | Xong (agent tài liệu) |
| 2 | Liều: hold 20/30/30 + vòng 2; rep 8/10/12; Sit-to-stand Strong 2 × 8; giãn cơ ≤ 12:15 | Xong (`sessions_stretch.py`, `sessions_chair.py`) |
| 3 | Steady set miễn phí, mọi ngày tập; bản ngồi | Xong (`WeeklyPlanner`, `SessionBuilder`, khối `.steady` chạy bằng màn ghế) |
| 4 | Chip "I feel unsteady on my feet" + dòng nhắc bác sĩ | Xong (EN + VI) |
| 5 | Thang vịn theo bài (Pro) | Xong, lưu UserDefaults thay schema V3 (`SupportLadder`, `SupportLadderStore`) |
| 6 | 4 bài mới | Xong (`bl.back-walk`, `bl.walk-turn`, `bl.heel-toe-walking`, `st.back-ext`) |
| 7 | Clip S13, V4-3 + 2 tranh | Xong (74,24 + 1 credit Higgsfield) |
| 8 | 25 câu thoại EN + VI | Xong (Vibi, khoảng 2.924 credit) |
| 9 | Infographic v2 hết "chờ chốt" | Xong |

Kiểm: Core 164 test, app test (kết quả cuối ở báo cáo bàn giao), `SessionSyncTests` 315 buổi: giọng lệch tối đa 2,3 s (EN) / 2,9 s (VI), câu đếm lệch ≤ 0,7 s; copy lint 0; vi 703/703 khoá, 617/617 câu có giọng.
