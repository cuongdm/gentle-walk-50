# Quy mô và giá trị từng ngách theo dữ liệu nội bộ (107 app, 15.756 review), 07/10/2026

Ký hiệu nguồn dùng trong toàn bộ ghi chú:
- **[CSV]** = [docs/research/data/2026-10-03-niche-apps.csv](/home/user/gentle-walk-50/docs/research/data/2026-10-03-niche-apps.csv): 107 app, mỗi dòng một app.
- **[TXT]** = [docs/research/data/2026-10-03-review-analysis.txt](/home/user/gentle-walk-50/docs/research/data/2026-10-03-review-analysis.txt): bảng tổng hợp của 15.756 review.
- **[KT]** = [2026-10-03-kiem-tien-dinh-vi-doi-thu.md](/home/user/gentle-walk-50/docs/research/2026-10-03-kiem-tien-dinh-vi-doi-thu.md) · **[VD]** = [2026-10-03-van-de-va-chan-dung-khach-hang.md](/home/user/gentle-walk-50/docs/research/2026-10-03-van-de-va-chan-dung-khach-hang.md) · **[4G]** = [2026-09-30-competitor-4-groups.md](/home/user/gentle-walk-50/docs/research/2026-09-30-competitor-4-groups.md) · **[TT]** = [2026-10-04-tom-tat-thi-truong.md](/home/user/gentle-walk-50/docs/research/2026-10-04-tom-tat-thi-truong.md) · **[Y2N]** = [2026-10-07-yes2next.md](/home/user/gentle-walk-50/docs/research/2026-10-07-yes2next.md).
- **(CHÉP)** = số lấy nguyên từ file. **(TÍNH)** = tôi tính lại bằng Python từ số trong file (script ở scratchpad phiên, không ở repo). **(TÍNH NGƯỢC)** = số đếm suy ra từ tỉ lệ % × n trong [TXT]. Kiểm tra: tổng các số tính ngược khớp đúng cột "aged" của [TXT] cho cả 8 nhu cầu, nên phép tính ngược đáng tin.

## Câu hỏi 1: Dữ liệu nội bộ có gì, định dạng ra sao, có review thô để tự phân loại không?

### Takeaway
Repo **không có review thô** ở đâu cả, chỉ có số đã tổng hợp. Vì vậy **không thể** tự chạy phân loại từ khoá theo đúng 10 ngách được yêu cầu. Ghi chú này ghép hai lớp số:
1. Lớp **review theo nhu cầu**, chép và tính ngược từ [TXT]. Lớp này chỉ có 5/10 ngách: thăng bằng, cứng người, đau khớp, giảm cân, mãn kinh.
2. Lớp **app theo định vị**, tự tính từ [CSV] bằng cách phân loại tên app. Lớp này phủ 9/10 ngách; ngách xương/loãng xương có 0 app.

### Cited Findings
- **[CSV] có 16 cột:** `segment, app_id, name, seller, release_year, ratings_us, st_downloads_last_month_ww, st_revenue_last_month_ww, am_downloads_30d, am_revenue_30d, iap_prices_usd, reviews_analysed, pct_1_2_star, pct_billing_in_1_2_star, reviewers_stating_age, median_stated_age` — [CSV]
  - Không có cột ★ trung bình theo app.
  - Không có cột khen hay chê giá theo app.
  - Doanh thu và lượt tải ghi theo khoảng chữ, ví dụ "$800K", "< $5k", "> $1,000,000".
- **8 nhóm định vị trong [CSV]:**

  | Nhóm | Số app |
  |---|---|
  | lazy_beginner | 24 |
  | senior_explicit | 19 |
  | walking | 14 |
  | stretch_pain | 12 |
  | women40_menopause | 15 |
  | wall_pilates_somatic | 8 |
  | weightloss_coach_mass | 8 |
  | clinical_pt | 7 |

  (TÍNH) — [CSV]
- **[TXT] gồm ba bảng**, tính trên 15.756 review của 96 app, trong đó 303 review tự nói tuổi (trung vị 66) — [TXT]
  - Theo nhóm tuổi.
  - Theo 8 nhóm định vị (BY SEGMENT).
  - Theo 8 "nhu cầu" (BY NEED): `weight, joint_pain, balance_fall, menopause, flex_stiff, chronic, limited_mobility, energy_mood`.
  - Các cột: avg★, %1–2★, wtp+ (khen đáng tiền), wtp− (chê đắt), medAge, số người nói tuổi. Cột `bill` là tỉ lệ review 1–2★ nói về trừ tiền hoặc huỷ gói.
- **Nguồn review:** tới 500 review US mới nhất mỗi app, lấy qua RSS của Apple, cộng kho "radar". — [KT] mục 0
- **Doanh thu và lượt tải** là ước tính theo khoảng của Sensor Tower (toàn cầu, tháng trước) và AppMagic (iPhone, 30 ngày). Sensor Tower chặn sau khoảng 35 lần tra. — [KT] mục 0
- **Không tìm thấy review thô.** Tôi đã tìm `*review*`, `*niche*`, `*.db`, `*.sqlite` trên toàn máy và trong lịch sử git (`git log --all`, file đã xoá). — tìm kiếm của tôi, 07/10/2026
  - [4G] dòng 3 và 164–167 trỏ tới `~/.agents/skills/radar-research/radar-tools/data/radar.db`, nhưng file đó **không có trên máy này**.
  - Script phân loại review "trong scratchpad phiên làm việc" ([4G] dòng 167) cũng không còn.
- **Danh sách từ khoá của 8 nhu cầu trong [TXT] không được ghi ở đâu trong repo.** — [TXT], [KT]
  - [4G] chỉ liệt kê từ khoá cho phân tích khác (walk / chair / stretch / balance / too fast / … / knee / calorie) trên 14 app.

**Từ khoá tôi dùng để gán app vào ngách theo TÊN app** (regex, không phân biệt hoa thường; một app có thể thuộc nhiều ngách):

| Ngách | Regex trên tên app |
|---|---|
| Thăng bằng / đứng dậy | `balance(?! -)` · `steady` · `fall` · `nymbl` · `bold:` |
| Cứng người / giãn cơ | `stretch` · `mobility` · `flexib` · `pliability` · `essentrics` · `bend:` · `rom coach` · `gowod` |
| Đau gối / hông / khớp | `joint` · `pain` · `knee` · `hip` · `arthr` · `prehab` · `hinge` · `sword` · `kaia` · `physi` · `medbridge` |
| Đi bộ trong nhà | `walk` |
| Giảm cân | `weight` · `lose` · `slim` · `fat` · `lean` |
| Xương / loãng xương | `bone` · `osteo` → **0 app** |
| Tư thế / lưng | `posture` · `back pain` · `back &` · `neck` · `kaia` |
| Bài ghế | `chair` |
| Tai chi | `tai chi` · `chi:` |
| Mãn kinh | `menopause` · `peri ` · `hormone` · `women 40` |

**Bản "broad"** thêm các app đa năng theo định vị đã ghi trong [TT] và [4G]:

| App | Ngách thêm vào |
|---|---|
| LazyFit | ghế, tai chi, đi bộ, giảm cân |
| ChillFit | ghế, tai chi, giảm cân |
| WalkFit | đi bộ, tai chi, ghế, giảm cân |
| BetterMe | giảm cân, đi bộ, ghế |
| Yoga-Go | tai chi, ghế, giảm cân |
| FitMe | ghế, giảm cân |
| Bold | thăng bằng, tai chi |
| SilverSneakers GO | đi bộ, ghế |
| GentleFit | ghế, đi bộ |

43/107 app không khớp ngách nào theo tên (TÍNH). Đó là app chung như JustFit, Sweat, Muscle Booster, Down Dog, Lindywell, Evlo. Nhóm này chiếm **74,4%** tổng doanh thu ước tính (TÍNH).

**Cách quy doanh thu và lượt tải ra một con số** (TÍNH):
- Ưu tiên số của Sensor Tower; không có thì dùng AppMagic.
- "< X" lấy X/2.
- "> X" lấy X (sàn của khoảng, tức ước tính thấp).
- Tổng: **7.035.500 USD/tháng** từ 73 app có số liệu; 34 app không có số. **2.081.000 lượt tải** từ 73 app.

### Inferences
- **Mọi số "share of revenue" chỉ để so bậc**, vì ba lý do:
  - Trộn hai nguồn có phạm vi khác nhau (Sensor Tower toàn cầu, AppMagic chỉ iPhone).
  - App "> $1,000,000" bị tính đúng 1 triệu USD.
  - App "< $5k" tính 2,5 nghìn USD.
- **★ trung bình theo ngách** chỉ có ở lớp review (theo nhu cầu, theo nhóm định vị), không có ở lớp app.

### Gaps
- Không có review thô, nên không có ★ trung bình, % đề cập, tỉ lệ khen/chê giá hay phân bố tuổi cho các ngách **tư thế/lưng, xương/loãng xương, bài ghế, tai chi, đi bộ trong nhà**. Những ngách này chỉ có số theo app.
- Muốn có số, cần lấy lại radar.db hoặc tải lại review qua RSS rồi chạy phân loại mới.
- Không biết từ khoá đã dùng cho 8 nhu cầu trong [TXT], nên không kiểm được độ phủ hay nhầm lẫn của từng nhãn. Ví dụ không rõ "balance_fall" có tính "get up from a chair" không.

## Câu hỏi 2: Bảng định lượng theo từng ngách

### Takeaway
- **Về nhu cầu trong review**, ba ngách lớn và tốt nhất là **đau khớp** (5,12% review), **cứng người** (4,70%) và **thăng bằng** (2,49%). Cả ba có ★ 4,49–4,62 và chỉ 6–9% là 1–2★.
- **Giảm cân** lớn vừa (3,55%) nhưng nhiều 1–2★ hơn và tỉ lệ khen/chê giá thấp nhất.
- **Mãn kinh** nhỏ (0,47%), tệ nhất (4,00★, 23% là 1–2★) và lệch tuổi (trung vị 57).
- **Về tiền theo app định vị**, chỉ **giãn cơ** (nhờ Bend) có trung vị doanh thu đáng kể (20 nghìn USD/app). **Bài ghế, tai chi, thăng bằng, mãn kinh, tư thế, đau khớp** đều có trung vị khoảng 2,5–15 nghìn USD/app khi đứng riêng làm định vị chính.

### Cited Findings

**Bảng A. Lớp review theo nhu cầu** (15.756 review, 96 app). Nguồn: [TXT] mục "BY NEED" và bảng theo tuổi.
- Cột n, ★, %1–2★, tuổi trung vị: **CHÉP**.
- Cột % review, số khen/chê, tỉ lệ, phân bố tuổi: **TÍNH NGƯỢC**.

| Ngách (nhãn [TXT]) | n review | % trên 15.756 | ★ TB | % 1–2★ | Khen đáng tiền / chê đắt (số review) | Tỉ lệ khen:chê | Người nói tuổi | Tuổi trung vị | Phân bố tuổi: <50 · 50–59 · 60–69 · 70–79 · 80+ |
|---|---|---|---|---|---|---|---|---|---|
| Thăng bằng, sợ ngã (`balance_fall`) | 393 | **2,49%** | 4,54 | 8,7% | 11 / 5 ⚠️ | 2,2 | 23 ⚠️ | 68 | 2 (9%) · 1 (4%) · 10 (43%) · 9 (39%) · 1 (4%) → **60–79: 83%** |
| Cứng người, linh hoạt (`flex_stiff`) | 741 | **4,70%** | **4,62** | **6,3%** | **40 / 7** | **5,7** | 61 | 65 | 8 (13%) · 7 (11%) · 25 (41%) · 19 (31%) · 2 (3%) → 60–79: 72% |
| Đau gối, hông, lưng, khớp (`joint_pain`) | 807 | **5,12%** (lớn nhất) | 4,49 | 9,4% | 32 / 10 | 3,2 | 68 | 65,5 | 8 (12%) · 11 (16%) · 23 (34%) · 22 (32%) · 4 (6%) → 60–79: 66% |
| Giảm cân (`weight`) | 559 | 3,55% | 4,33 | 13,2% | 16 / 10 ⚠️ | **1,6** (thấp nhất) | 29 ⚠️ | 68 | 4 (14%) · 2 (7%) · 12 (41%) · 9 (31%) · 2 (7%) → 60–79: 72% |
| Mãn kinh (`menopause`) | 74 | 0,47% | **4,00** (thấp nhất) | **23,0%** (cao nhất) | 3 / 1 ⚠️ | 3,0 ⚠️ | 6 ⚠️ | **57** | 2 · 2 · 2 · 0 · 0 → 60–79: 33% |
| *(tham khảo)* bệnh mạn tính | 273 | 1,73% | 4,41 | 11,0% | 5 / 1 ⚠️ | 5,0 ⚠️ | 20 ⚠️ | 68 | 3 · 0 · 8 · 6 · 3 |
| *(tham khảo)* hạn chế vận động nặng | 76 | 0,48% | 4,16 | 15,8% | 0 / 1 ⚠️ | 0 | 4 ⚠️ | 68 | 0 · 1 · 1 · 1 · 1 |
| *(tham khảo)* năng lượng, tâm trạng | 397 | 2,52% | **4,73** | 4,3% | 9 / 3 ⚠️ | 3,0 | 20 ⚠️ | 58 | 7 (35%) · 4 · 4 · 3 · 2 |
| Đi bộ trong nhà · bài ghế · tai chi · tư thế/lưng · xương/loãng xương | — | — | — | — | — | — | — | — | **Không có nhãn nhu cầu trong [TXT]** (xem bảng C) |

⚠️ = n < 30.

- Hai cặp đã được [KT] mục 1.2 ghi đúng: cứng người "40 / 7 (≈ 5,7 lần)" và giảm cân "16 / 10 (≈ 1,6 lần), nhạy giá nhất". Số tính ngược của tôi khớp với cả hai. — [KT]
- Tổng 8 nhãn là 3.320 lượt gắn nhãn, tức khoảng 21% của 15.756 review (TÍNH). Một review có thể mang nhiều nhãn. Khoảng 79% review không nhắc nhu cầu nào trong 8 nhãn. — [TXT]

**Bảng B. Lớp app định vị theo TÊN (primary)**. Nguồn: [CSV]; tất cả là **TÍNH**.
- % 1–2★ và % về tiền: cộng có trọng số theo `reviews_analysed`.
- Tuổi: trung bình có trọng số của `median_stated_age` theo số người nói tuổi. Đây là **xấp xỉ, không phải trung vị thật**.

| Ngách | Số app | App có số doanh thu | Tổng doanh thu tháng ước tính | % tổng doanh thu (7,04 triệu USD) | **Trung vị doanh thu/app** | % lượt tải (2,08 triệu) | % rating US (4,69 triệu) | Review | % 1–2★ | % review 1–2★ về tiền | Người nói tuổi · tuổi xấp xỉ |
|---|---|---|---|---|---|---|---|---|---|---|---|
| Thăng bằng (Bold, Nymbl) | 2 | 1 | 2,5 nghìn USD | 0,0% | 2,5 nghìn USD ⚠️ | 0,1% | 0,3% | 209 | **4,6%** | 9,9% | 8 · 75 ⚠️ |
| Giãn cơ, mobility | 10 | 7 | **777,5 nghìn USD** | **11,1%** | **20 nghìn USD** ⚠️ | 8,2% | 4,6% | 1.716 | 12,4% | 47,0% | 72 · 64 |
| Đau khớp (chủ yếu app vật lý trị liệu) | 9 | 4 | 10 nghìn USD | 0,1% | 2,5 nghìn USD ⚠️ | 7,9% | 8,3% | 1.247 | 28,7% | 20,9% | 4 · 52 ⚠️ |
| Đi bộ | 15 | 6 | 322,5 nghìn USD (93% là WalkFit) | 4,6% | 3,75 nghìn USD ⚠️ | 4,3% | 4,6% | 1.764 | **45,0%** | **70,0%** | 13 · 74 ⚠️ |
| — riêng "indoor" (Walk At Home, Organic Walk) | 2 | 2 | 12,5 nghìn USD | 0,2% | 6,25 nghìn USD ⚠️ | — | — | 284 | 24,1% | — | 7 · 80 ⚠️ |
| Giảm cân | 18 | 11 | 440 nghìn USD | 6,3% | 5 nghìn USD ⚠️ | 9,5% | 12,4% | 2.617 | 32,4% | 63,7% | 17 · 61 ⚠️ |
| Xương, loãng xương | **0** | 0 | 0 | 0 | — | 0 | 0 | 0 | — | — | — |
| Tư thế, lưng | 3 | 2 | 5 nghìn USD | 0,1% | 2,5 nghìn USD ⚠️ | 0,2% | 0,2% | 280 | 37,6% | 49,2% | 3 · 60 ⚠️ |
| Bài ghế | 7 | 4 | 12,5 nghìn USD | 0,2% | 2,5 nghìn USD ⚠️ | 0,5% | 0,8% | 888 | 24,4% | 51,2% | 12 · 71 ⚠️ |
| Tai chi | 8 | 4 | 235 nghìn USD (85% là Yoga-Go) | 3,3% | 15 nghìn USD ⚠️ | 2,6% | 2,4% | 925 | 21,7% | 44,9% | 28 · 69 ⚠️ |
| Mãn kinh | 5 | 4 | 12,5 nghìn USD | 0,2% | 2,5 nghìn USD ⚠️ | 2,2% | 0,3% | 209 | **48,5%** | 35,9% | 1 · 45 ⚠️ |

- Hàng "indoor": tính tay từ hai dòng của [CSV]. Walk At Home: 10 nghìn USD, 234 review, 25% là 1–2★, tuổi trung vị 80 (n=7). Organic Walk: dưới 5 nghìn USD, 50 review, 20% là 1–2★. — [CSV]
- **App lẻ trong từng ngách** (doanh thu tháng, số của Sensor Tower hoặc sàn của AppMagic) — [CSV]:
  - Giãn cơ: Bend 700 nghìn USD; STRETCHIT, pliability, JustStretch mỗi app khoảng 20 nghìn USD; Essentrics TV 10 nghìn USD.
  - Tai chi: Tai Chi for Beginners Seniors 20 nghìn USD; Tai Chi Beginners & Seniors 10 nghìn; Tai Chi – Seniors & Beginners 5 nghìn.
  - Bài ghế: Light: Chair Yoga Plan 5 nghìn USD; Chair Yoga for Seniors, Yogio, Everdance mỗi app dưới 5 nghìn.
  - Giảm cân: Dancefitme 300 nghìn USD; Simple 100 nghìn (sàn AppMagic); còn lại 2,5–10 nghìn.
  - Đau khớp: Hinge, Sword, Omada, Joint Academy không có doanh thu trong app. Medbridge (70 nghìn lượt tải) và PhysiApp (90 nghìn lượt tải) dưới 5 nghìn USD.

**Bảng C. Bản "broad"**: tính cả app đa năng có mảng đó theo [TT] và [4G]. Nguồn: [CSV], **TÍNH**. Chỉ khác bảng B ở 4 ngách:

| Ngách (broad) | Số app | Có số doanh thu | Tổng doanh thu | % doanh thu | **Trung vị/app** | % lượt tải | % 1–2★ (n review) | Tuổi xấp xỉ (người nói tuổi) |
|---|---|---|---|---|---|---|---|---|
| Bài ghế | 15 | 10 | 2,81 triệu USD | **40,0%** | **200 nghìn USD** | 30,3% | 21,2% (2.812) | 70 (53) |
| Tai chi | 12 | 8 | 1,64 triệu USD | 23,3% | 110 nghìn USD | 15,7% | 15,8% (1.648) | 70 (46) |
| Đi bộ | 18 | 8 | 2,12 triệu USD | 30,2% | 7,5 nghìn USD | 23,5% | 34,7% (2.804) | 72 (39) |
| Giảm cân | 24 | 17 | 3,24 triệu USD | **46,1%** | 10 nghìn USD | 39,3% | 26,8% (3.976) | 67 (47) |

**Bảng D. Theo 8 nhóm định vị của [CSV]/[TXT]**
- Cột ★, %1–2★, tiền trong 1–2★, khen/chê, tuổi: **CHÉP** từ [TXT].
- Cột doanh thu: **TÍNH** từ [CSV].

| Nhóm | App | Review | ★ TB | 1–2★ | Về tiền trong 1–2★ | Khen đáng tiền / chê đắt (% → số) | Tuổi trung vị (người nói tuổi) | 60+ | Tổng doanh thu (% tổng) | Trung vị/app (n có số) |
|---|---|---|---|---|---|---|---|---|---|---|
| lazy_beginner | 24 | 3.538 | 4,16 | 17,6% | 51,4% | 0,9% / 0,9% → khoảng 32 / 32 | 70 (46) | 84,8% | 2,62 triệu USD (37,2%) | 20 nghìn USD (21) |
| senior_explicit | 19 | 2.999 | 4,26 | 15,1% | 26,5% | 1,2% / 0,7% → khoảng 36 / 21 | 69 (141) | 82,3% | **105 nghìn USD (1,5%)** | **7,5 nghìn USD** (10) |
| walking | 14 | 1.712 | **3,05** | **44,9%** | **70,8%** | 1,3% / **2,2%** → khoảng 22 / 38 | 67 (13 ⚠️) | 100% | 322,5 nghìn USD (4,6%) | 3,75 nghìn USD (6) |
| stretch_pain | 12 | 1.461 | 4,24 | 14,6% | 50,7% | **4,3%** / 2,1% → khoảng 63 / 31 | 49 (18 ⚠️) | 38,9% | 770 nghìn USD (10,9%) | 20 nghìn USD (7) |
| clinical_pt | 7 | 1.017 | 3,45 | 33,4% | 18,2% | 0,4% / 1,1% → khoảng 4 / 11 | 58,5 (2 ⚠️) | 50% | 7,5 nghìn USD (0,1%) | 2,5 nghìn USD (3) |
| wall_pilates_somatic | 8 | 853 | 3,85 | 26,0% | 57,2% | 1,9% / 1,8% → khoảng 16 / 15 | 80 (3 ⚠️) | 100% | 27,5 nghìn USD (0,4%) | 3,75 nghìn USD (6) |
| women40_menopause | 15 | 2.192 | 3,94 | 21,8% | 46,4% | 3,2% / 1,4% → khoảng 70 / 31 | 56 (39) | 38,5% | 1,16 triệu USD (16,5%; Sweat chiếm 1 triệu) | 3,75 nghìn USD (12) |
| weightloss_coach_mass | 8 | 1.984 | 3,70 | 25,9% | 53,7% | 2,1% / **2,8%** → khoảng 42 / 56 | 68 (41) | 75,6% | 2,03 triệu USD (28,8%) | **150 nghìn USD** (8) |

Ghi chú bảng D:
- Số app theo [TXT] (chỉ tính app có review): 19 / 18 / 14 / 10 / 7 / 7 / 13 / 8. Bảng trên dùng số app trong [CSV].
- **Phân bố tuổi chung** (303 người nói tuổi) — [TXT], CHÉP:

  | Nhóm tuổi | n | Tỉ lệ | ★ TB | 1–2★ |
  |---|---|---|---|---|
  | <50 | 40 | 13,2% | 4,90 | 2,5% |
  | 50–59 | 38 | 12,5% | 4,97 | 0% |
  | 60–69 | 100 | 33,0% | 4,80 | 3,0% |
  | 70–79 | 95 | 31,4% | 4,65 | 5,3% |
  | 80+ | 30 | 9,9% | **4,23** | **20%** |

- **Giới:** 133 dấu hiệu nữ so với 27 dấu hiệu nam. — [TXT]

### Inferences
- **Ngách "cứng người/giãn cơ" là ngách duy nhất mạnh ở cả hai lớp.** Ở lớp review: ★ cao nhất, ít 1–2★ nhất, tỉ lệ khen:chê giá cao nhất. Ở lớp app: doanh thu cao nhất trong các app định vị một ngách (11,1%).
- **Doanh thu ở lớp app không chảy về các app định vị một ngách hẹp.** Nó chảy về app "beginner/lazy" và "coach" đa năng, gói nhiều ngách (ghế + tai chi + đi bộ + giảm cân). Cụ thể: 74,4% doanh thu nằm ở 43 app không mang tên ngách nào, và trung vị ghế-broad là 200 nghìn USD so với ghế-tên chỉ 2,5 nghìn USD.
- **"Đau khớp" có nhu cầu lớn nhất trong review (5,12%) nhưng gần như không có doanh thu tiêu dùng.** App định vị theo đau đa số là vật lý trị liệu do bảo hiểm hoặc công ty trả: 7,9% lượt tải nhưng chỉ 0,1% doanh thu.

### Gaps
- **Xương/loãng xương:** 0 app trong mẫu 107 app, không có nhãn nhu cầu trong [TXT]. Không thể nói gì về quy mô hay giá trị từ dữ liệu nội bộ. Mẫu được tìm bằng 40 từ khoá ([KT] mục 0); không rõ có từ khoá "osteoporosis" hay không.
- **Tư thế/lưng, bài ghế, tai chi, đi bộ trong nhà:** không có % đề cập trong review, ★ trung bình theo ngách hay tỉ lệ khen/chê giá. Chỉ có % 1–2★ theo app.
- **"Getting up from a chair":** không có nhãn riêng; không biết `balance_fall` có bao gồm hay không.
- **Tuổi theo ngách ở lớp app** là trung bình của trung vị từng app, không phải trung vị thật. Đa số ngách có dưới 30 người nói tuổi.
- 34/107 app không có số doanh thu (Sensor Tower bị chặn). Trung vị ở bảng B nhiều ngách chỉ dựa trên 1–7 app.

## Câu hỏi 3: Ngách nào nhiều app nhưng doanh thu thấp (bão hoà), ngách nào ít app nhưng doanh thu cao (còn cửa)?

### Takeaway
- **Bão hoà, đã thành hàng hoá:** bài ghế cho "senior", tai chi cho "senior", đi bộ/giảm cân bằng đi bộ, giảm cân nói chung. Nhiều app, trung vị chỉ 2,5–15 nghìn USD/app, nhiều 1–2★. App tai chi đang mọc thêm rất nhanh.
- **Ít app, doanh thu cao:** chỉ có **giãn cơ/mobility** (10 app, 11% doanh thu), nhưng bị **một app (Bend) chiếm 90%**. Đây là thế "người thắng ăn gần hết", không phải ngách bỏ trống.
- **Ít app, gần như chưa có doanh thu tiêu dùng nhưng nhu cầu và hài lòng cao:** **thăng bằng/vững chân** (2 app, cả hai đi qua bảo hiểm; 2,49% review, 4,54★). Đây là khoảng trống rõ nhất. Khoảng trống này chưa chứng minh được khách sẵn sàng trả: chỉ có 11 review khen đáng tiền.

### Cited Findings
- **Ghế (theo tên): 7 app**, tổng khoảng 12,5 nghìn USD/tháng (0,2%), trung vị 2,5 nghìn USD, 24,4% là 1–2★ trên 888 review (TÍNH). — [CSV]
  - Chair Yoga for Seniors: 13.906 rating US nhưng doanh thu dưới 5 nghìn USD; **62%** review gần đây là 1–2★. — [CSV]; [KT] mục 1.1
- **Tai chi: 8 app**, trong đó **6 app ra năm 2025–2026** (TÍNH, cột `release_year`). — [CSV]
  - 2025: Fast Builder "Tai Chi for Beginners Seniors", GentleFit, ZenFit.
  - 2026: PRODIGYAI, Dmytro Hrechko, YUAN QI.
  - App tai chi thuần có doanh thu cao nhất: 20 nghìn USD (Tai Chi for Beginners Seniors). Các app khác 5–10 nghìn USD hoặc không có số.
- **Fast Builder có hơn 10 app** (SeniorFit, Tai Chi, Chair Yoga…), mỗi app 5–100 nghìn USD. Họ "phủ kín từ khoá senior / chair / tai chi", nhưng sản phẩm "mỏng, na ná nhau". — [KT] mục 3
- **Nhóm senior_explicit:** 19 app, tổng 105 nghìn USD (1,5% doanh thu), trung vị 7,5 nghìn USD (TÍNH). — [CSV]
  - Tuổi trung vị người review 69 (n=141), 82,3% là 60+. — [TXT]
  - So với 12 app doanh thu cao nhất ngách: cùng khách (trung vị 68), nhưng doanh thu 200 nghìn – 1 triệu USD/app. — [KT] mục 1.1
- **Đi bộ:** 15 app (theo tên).
  - 93% doanh thu của nhóm là WalkFit; trung vị 3,75 nghìn USD. — TÍNH từ [CSV]
  - Nhóm walking: ★ 3,05, **44,9%** là 1–2★, 70,8% trong số đó về tiền. — [TXT]
  - "14 app chỉ đi bộ có 45% review 1–2★… Đếm bước miễn phí ở khắp nơi nên thể loại đi bộ khó bán." — [KT] mục 2
  - WalkFit tụt từ #31 (2025) xuống #58 (09/2026). — [VD] mục 3
- **Giảm cân (theo tên):** 18 app, trung vị 5 nghìn USD, 32,4% là 1–2★, 63,7% trong số đó về tiền (TÍNH). — [CSV]
  - Làn sóng "lazy workout / giảm cân cho phụ nữ" đại trà đang đi xuống. — [VD] mục 3
    - JustFit: #13 → #95.
    - Yoga-Go: #31 → ngoài top 100.
    - BetterMe: #12 → #24.
- **Giãn cơ:** 10 app, 777,5 nghìn USD (11,1%), trung vị 20 nghìn USD (n=7) (TÍNH). Bend chiếm 700 nghìn USD. — [CSV]
  - Bend tăng hạng đều: #65 (2023) → #41 (2026). — [VD] mục 3
  - Essentrics TV: 189,99 USD/năm, người review trung vị 66 tuổi (n=57), 3% là 1–2★. — [KT] mục 1.4
- **Thăng bằng:** 2 app theo tên (Bold, Nymbl). Bold dưới 5 nghìn lượt tải và dưới 5 nghìn USD/tháng. — [CSV]
  - Bold là "Miễn phí qua bảo hiểm". — [KT] mục 3
  - Bold: 12.034 rating US, chỉ 2% là 1–2★ trên 141 review. — [CSV]
  - Bend "không có nhóm Balance" (review 4★). — [4G] mục 2c
  - yes2next dùng balance làm nhóm riêng và có "15-Day Better Balance Challenge". — [Y2N] mục 2
- **Mãn kinh:** 5 app, 12,5 nghìn USD, 48,5% là 1–2★ trên 209 review (TÍNH). — [CSV]
  - Người review nhóm women40_menopause có trung vị 56 tuổi; chỉ 38,5% là 60+. — [TXT]
- **Đau khớp:** app chủ yếu là vật lý trị liệu (Hinge, Sword, Kaia, Omada, Joint Academy, Medbridge, PhysiApp).
  - Nhóm clinical_pt: 7,8% lượt tải nhưng 0,1% doanh thu (TÍNH).
  - Theo [KT] mục 1.4: "bảo hiểm hoặc công ty trả; người dùng không trả".
- **Tập trung doanh thu:** 10 app chiếm **78,2%** tổng doanh thu ước tính (TÍNH). 17 app đạt từ 100 nghìn USD/tháng trở lên; không app nào trong số đó mang tên ngách ghế, tai chi, thăng bằng, mãn kinh hay tư thế. — [CSV]

**Ma trận** (TÍNH, kết hợp bảng A, B, C):

| Ngách | Số app theo tên | Trung vị/app | Nhu cầu trong review | Xếp loại |
|---|---|---|---|---|
| Bài ghế (định vị riêng, "senior") | 7 (+ 8 app đa năng có mảng ghế) | 2,5 nghìn USD | không có nhãn | **Bão hoà, hàng hoá**; tiền nằm ở app đa năng có mảng ghế |
| Tai chi | 8 (6 app ra 2025–26) | 15 nghìn USD | không có nhãn | **Đang bão hoà nhanh** |
| Đi bộ (giảm cân) | 15 | 3,75 nghìn USD | không có nhãn | **Bão hoà + bị ghét** (44,9% là 1–2★) |
| Giảm cân | 18 | 5 nghìn USD | 3,55% · 4,33★ | **Đông, nhạy giá, đang đi xuống** |
| Giãn cơ, mobility | 10 | **20 nghìn USD** | 4,70% · **4,62★** | **Giá trị cao, nhưng một app thống trị** |
| Thăng bằng, vững chân | **2** | khoảng 0 (bảo hiểm) | 2,49% · 4,54★ | **Khoảng trống**: nhu cầu và hài lòng cao, chưa có app tiêu dùng trả phí |
| Đau khớp | 9 (đa số vật lý trị liệu) | khoảng 0 | **5,12%** · 4,49★ | Nhu cầu lớn nhất; tiền đi qua bảo hiểm; rủi ro tuyên bố y khoa |
| Tư thế, lưng | 3 | 2,5 nghìn USD | không có nhãn | Nhỏ, mẫu ít |
| Mãn kinh | 5 | 2,5 nghìn USD | 0,47% · 4,00★ | Nhỏ, kém hài lòng, lệch tuổi so với 58–75 |
| Xương, loãng xương | 0 | — | — | Không có dữ liệu |

### Inferences
- **Mô hình thắng trong dữ liệu là "gói nhiều ngách cho người mới"** (LazyFit, ChillFit, BetterMe), không phải app một ngách hẹp có chữ "senior". Ngách hẹp (ghế, tai chi) bán tốt như **tính năng bên trong** gói, kém khi đứng riêng.
- **Thăng bằng/vững chân là khoảng trống định vị** trong mẫu 107 app. Không app trả phí nào lấy nó làm lời hứa chính, trong khi:
  - Người nhắc thăng bằng có 83% ở tuổi 60–79 (n=23 ⚠️), khớp nhất với tệp 58–75.
  - ★ 4,54 và chỉ 8,7% là 1–2★.
  - Khẩu hiệu đã chốt "Steadier on your feet" trùng đúng ngách này.

  Rủi ro: chưa có bằng chứng trả tiền trực tiếp (chỉ 11 khen / 5 chê). Đối thủ gần nhất về chủ đề (Bold, Nymbl, SilverSneakers) là kênh bảo hiểm miễn phí.
- **Giãn cơ có tiền nhưng phải đối đầu Bend.** Cách né là kết hợp "cứng người + vững chân" (Bend không có Balance và ít bài ngồi, [4G], [TT]) thay vì làm thêm một app giãn cơ thuần.

### Gaps
- Không có số lượt tìm kiếm App Store (độ khó từ khoá) theo từng ngách trong dữ liệu nội bộ, nên "bão hoà" ở đây chỉ đo bằng số app và doanh thu trong mẫu 107 app.
- Mẫu 107 app được chọn bằng 40 từ khoá không được liệt kê. Ngách nào bị bỏ sót trong lúc tìm (xương, tư thế) có thể bị đánh giá thấp.
- Doanh thu từng app tai chi, ghế, thăng bằng đa số rơi vào khoảng "< 5 nghìn USD", nên không phân biệt được 0 USD và 4.999 USD.

## Câu hỏi 4: Ngách nào hài lòng nhất và sẵn sàng trả nhất, ngách nào nhạy giá nhất?

### Takeaway
- **Hài lòng và sẵn sàng trả cao nhất: cứng người/giãn cơ.** ★ 4,62; 6,3% là 1–2★; 40 khen đáng tiền / 7 chê đắt, tỉ lệ 5,7 (n=741). Nhóm stretch_pain cũng có tỉ lệ khen đáng tiền cao nhất trong 8 nhóm (4,3%). Xếp sau: đau khớp (3,2) và thăng bằng (2,2).
- **Nhạy giá nhất:**
  - Theo nhu cầu: **giảm cân** (1,6; 13,2% là 1–2★).
  - Theo nhóm định vị: **đi bộ** (chê đắt 2,2% > khen 1,3%; 70,8% review 1–2★ về tiền) và **coach giảm cân đại trà** (chê đắt 2,8% > khen 2,1%).
- Mãn kinh kém hài lòng nhất (4,00★, 23% là 1–2★), nhưng mẫu quá nhỏ để kết luận về giá.

### Cited Findings
- **Xếp hạng tỉ lệ khen đáng tiền : chê đắt theo nhu cầu** (TÍNH NGƯỢC từ [TXT]; [KT] mục 1.2 ghi cùng số cho cứng người và giảm cân):

  | Hạng | Nhu cầu | Khen / chê | Tỉ lệ | n |
  |---|---|---|---|---|
  | 1 | Cứng người | 40/7 | **5,7** | 741 |
  | 2 | Bệnh mạn tính | 5/1 ⚠️ | 5,0 | 273 |
  | 3 | Đau khớp | 32/10 | 3,2 | 807 |
  | 4 | Mãn kinh | 3/1 ⚠️ | 3,0 | 74 |
  | 4 | Năng lượng, tâm trạng | 9/3 ⚠️ | 3,0 | 397 |
  | 6 | Thăng bằng | 11/5 ⚠️ | 2,2 | 393 |
  | 7 | Giảm cân | 16/10 ⚠️ | **1,6** | 559 |
  | 8 | Hạn chế vận động nặng | 0/1 ⚠️ | 0 | 76 |

- **★ theo nhu cầu** — [TXT], CHÉP:

  | Nhu cầu | ★ TB | % 1–2★ |
  |---|---|---|
  | Năng lượng, tâm trạng | 4,73 | 4,3% |
  | Cứng người | 4,62 | 6,3% |
  | Thăng bằng | 4,54 | 8,7% |
  | Đau khớp | 4,49 | 9,4% |
  | Bệnh mạn tính | 4,41 | 11,0% |
  | Giảm cân | 4,33 | 13,2% |
  | Hạn chế vận động nặng | 4,16 | 15,8% |
  | Mãn kinh | 4,00 | 23,0% |

  Nhóm năng lượng/tâm trạng có ★ cao nhất nhưng trẻ hơn (trung vị 58; 35% dưới 50 tuổi trong n=20).
- **Theo nhóm định vị: chê đắt nhiều hơn khen đáng tiền ở 3 nhóm** — [TXT], CHÉP:
  - walking: 1,3% / 2,2%.
  - weightloss_coach_mass: 2,1% / 2,8%.
  - clinical_pt: 0,4% / 1,1%.
- **Nhóm khen đáng tiền nhiều nhất:** stretch_pain 4,3% / 2,1%, women40_menopause 3,2% / 1,4%. — [TXT]
- **Tỉ lệ review 1–2★ nói về tiền, theo nhóm:** — [TXT]

  | Nhóm | % 1–2★ về tiền |
  |---|---|
  | walking | **70,8%** |
  | wall_pilates_somatic | 57,2% |
  | weightloss_coach_mass | 53,7% |
  | lazy_beginner | 51,4% |
  | stretch_pain | 50,7% |
  | women40_menopause | 46,4% |
  | senior_explicit | 26,5% |
  | clinical_pt | 18,2% |

- "Gần một nửa review 1–2★ (49%) là về tiền; ở review 4–5★ chỉ 3%." — [KT] mục 2; [TT] mục 1
- **Bằng chứng giá cao trong ngách giãn cơ/tập theo phương pháp:** — [KT] mục 1.4
  - Essentrics 189,99 USD/năm (người review trung vị 66 tuổi, n=57, 3% là 1–2★).
  - Giá in-app cao nhất trung vị của các app giãn cơ: 122,49 USD (TÍNH từ cột `iap_prices_usd`, [CSV]).
  - So với: đi bộ 69,99 USD, giảm cân 59,99 USD, bài ghế 83,99 USD, tai chi 79,99 USD.
- **Theo tuổi:** người 80+ có ★ 4,23 và 20% là 1–2★; nhóm này không có review nào khen đáng tiền (0,0%). — [TXT]; [KT] mục 1.3

### Inferences
- **Lời hứa chính nên xoay quanh "bớt cứng người + vững chân hơn", không phải giảm cân hay đi bộ.** Đây cũng là điều [KT] và [TT] đã đề xuất; số tính lại ở đây xác nhận.
  - Cứng người là nơi hội tụ hài lòng cao và sẵn sàng trả cao.
  - Thăng bằng có hồ sơ tuổi khớp nhất với 58–75 (83% ở 60–79).
- **Đi bộ nên là bài mặc định, không phải định vị.** Nhóm đi bộ là nhóm nhạy giá và bị ghét nhất, dù người dùng lớn tuổi (60+ = 100%, n=13).
- **"Đau khớp" là lời hứa có giá trị** (nhu cầu lớn nhất, khen:chê 3,2) **nhưng chạm luật tuyên bố y khoa** (App Review 1.4.1, theo `CLAUDE.md` của dự án). Nên dùng theo cách "thân thiện với gối, có bản ngồi", không hứa giảm đau.

### Gaps
- Phần "sẵn sàng trả" dựa trên số rất nhỏ. Mọi số khen/chê đều dưới 41 review mỗi nhu cầu. [KT] mục 0 cũng nói: "Câu nói về tiền trong review hiếm, nên phần 'sẵn sàng trả' dựa chủ yếu vào doanh thu thật".
- Không biết định nghĩa wtp+ / wtp− (từ khoá nào) trong [TXT].
- Lệch chọn mẫu: review có nhắc nhu cầu cơ thể thường là review khen, nên ★ theo nhu cầu (4,3–4,7) cao hơn ★ theo nhóm định vị (3,05–4,26). Không thể so trực tiếp hai lớp.
- Không có dữ liệu sẵn sàng trả cho tai chi, bài ghế, tư thế, xương và đi bộ trong nhà ở lớp review. Muốn có thì phải tải lại review thô và phân loại mới.
