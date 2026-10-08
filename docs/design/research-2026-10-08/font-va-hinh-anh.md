# Font và hình ảnh cho Good Footing — nghiên cứu 08/10/2026

_Người làm: thiết kế chữ/hình (Fable 5.1) · Phạm vi: chỉ nghiên cứu và đề xuất, chưa sửa code · Ảnh mẫu và số đo nằm cùng thư mục này._

## 0) Kết luận 5 dòng

1. **Giữ font hệ thống Apple** (New York cho tiêu đề, SF Pro cho chữ, SF Pro Rounded cho số). Đã kiểm bằng fontTools trên máy: cả ba có đủ dấu tiếng Việt chồng (ế ở ữ ặ ộ ỳ ẵ), có trục `opsz`/`wght`, không phải đóng gói, không có rủi ro lỗi glyph trên điện thoại.
2. Thay đổi duy nhất đáng làm về font: **chữ thường (body, nút, caption) đổi từ SF Pro Rounded sang SF Pro**, Rounded chỉ giữ cho **số** (đồng hồ, số lần, thống kê). SF Pro có trục quang học (Text/Display tự đổi theo cỡ), nét sắc hơn ở 15–17 pt; SF Pro Rounded không có `opsz` (fontTools: chỉ `GRAD, wght`). Đây là mẫu Apple dùng ở Fitness/Health.
3. **Không font đóng gói nào thắng rõ font hệ thống** cho mắt người 58–75 *và* đạt điều kiện tiếng Việt. Atkinson Hyperlegible Next (font "dễ đọc" nổi tiếng nhất) **không có bộ tiếng Việt** (Google Fonts METADATA: chỉ latin, latin-ext; ảnh mẫu cho thấy glyph ữ/ặ bị thay bằng font khác). Figtree, Outfit, DM Sans cũng vậy. Lexend không có số tabular.
4. Nếu chủ app muốn nét thương hiệu riêng: phương án phụ **Literata (tiêu đề) + Nunito Sans (chữ) + SF Pro Rounded (số)**; dự phòng **Fraunces + Public Sans**. Cả hai đủ tiếng Việt mọi trọng lượng, OFL, cộng 0,5–1,5 MB.
5. Hình ảnh: giữ **tranh màu nước** cho toàn app (trang bìa, hành trình, nhân vật), video người thật chỉ trong player; mở rộng dàn nhân vật phụ theo tuổi/vóc dáng/sắc tộc, luôn vẽ điểm tựa (ghế, mặt bàn) ở bài thăng bằng, không gậy/khung tập trong tranh chủ đạo, không thẩm mỹ phòng gym. Việc sửa UI ưu tiên cao: caption 15 → 16 pt, nút chính 60 → 64 pt, đậm hơn màu `secondary` khi có chữ trắng (hiện 4,6:1, sát ngưỡng).

## 1) Bảng chấm điểm font

### 1a. Cách kiểm chứng (bằng chứng thật, không chỉ đọc mô tả)

| Việc | Cách làm | File |
|---|---|---|
| Tiếng Việt của font Google | Gọi CSS API `fonts.googleapis.com/css2` cho 21 họ, đếm khối `/* vietnamese */`; font không có khối này = không có bộ tiếng Việt | `font-specimens.html` §0, `spec-00-vi-strip-*.png` |
| Tiếng Việt của font Apple | fontTools đọc cmap `/System/Library/Fonts/NewYork.ttf`, `SFNS.ttf`, `SFNSRounded.ttf`: đủ U+1EBF ế, U+1EDF ở, U+1EEF ữ, U+1EB7 ặ, U+1ED9 ộ, U+1EF3 ỳ, U+1EB5 ẵ, U+0110 Đ | (log trong phiên) |
| Glyph bị thay thế | Trang mẫu đo bề rộng chuỗi "ữữữữ" trong font so với font dự phòng (Be Vietnam Pro) → cờ FALLBACK | `measurements.txt` |
| x-height, cap-height, số tabular | Canvas `measureText` trong Chrome headless; `tnum` = bề rộng "0000" == "1111" | `measurements.txt` |
| Dung lượng đóng gói | GitHub API `google/fonts/ofl/<family>` (file TTF biến thiên + OFL.txt) | bảng dưới |
| Mắt nhìn | Chrome headless chụp 16 PNG (light/dark); font Apple chụp bằng AppKit (Chrome không gọi được New York/SF Rounded) | `spec-*.png`, `spec-system-*.png` |

Ghi chú: font biến thiên trên Google Fonts có **một cmap chung cho mọi trọng lượng**, nên "có tiếng Việt" nghĩa là có ở mọi weight. Bộ tiếng Việt Google Fonts = U+0102-0103, 0110-0111, 0128-0129, 0168-0169, 01A0-01A1, 01AF-01B0, dấu tổ hợp 0300-0309/0323/0329, U+1EA0-1EF9, ₫.

### 1b. Bảng điểm (1–5; VI là điều kiện loại; "x/em" = x-height đo được)

| Font | Giấy phép | VI | x/em | tnum | Weight | Dynamic Type / opsz | KB (TTF + italic) | Dễ đọc mắt già | Hợp màu nước, giọng HLV | Rủi ro | **Tổng** |
|---|---|---|---|---|---|---|---|---|---|---|---|
| **New York** (hệ thống) | Apple, dùng trong app Apple | ✅ fontTools | — (Safari/AppKit) | ✅ `monospacedDigit` | 100–900 | ✅ tự Text/Display (`opsz`) | 0 | 4 | 5 (chủ app đã chọn 03/10) | 0 | **4,6** |
| **SF Pro** (hệ thống) | Apple | ✅ | 0,508 | ✅ | mọi | ✅ `opsz, wdth, GRAD` | 0 | 4 (I/l/1 giống nhau; cv alternates có qua `UIFontDescriptor`) | 3,5 | 0 | **4,4** |
| **SF Pro Rounded** (hệ thống, đang dùng) | Apple | ✅ | ≈SF | ✅ | mọi | ⚠️ không `opsz` (chỉ `GRAD, wght`) | 0 | 3,5 (nét mềm, hơi nhoè ở 15 pt — xem `spec-system-light.png` A0 vs A1) | 4,5 | 0 | **4,2** |
| Atkinson Hyperlegible Next | OFL | ❌ latin/latin-ext | 0,496 | ✅ | 200–800 | `Font.custom(relativeTo:)` | 112 + 121 | 5 (thiết kế cho thị lực kém, 0 gạch, I/l/1 rõ) | 3 | 4 (glyph VI rơi sang font khác) | **loại** |
| Atkinson Hyperlegible (2019) | OFL | ❌ | 0,496 | ✅ | 400/700 | custom | — | 5 | 3 | 4 | **loại** |
| Lexend | OFL | ✅ | 0,525 | ❌ không tabular | 100–900 | custom | 172 | 3,5 (giãn chữ rộng, dòng VI dài 17% hơn SF → xuống dòng nhiều) | 3 | 2 | 3,2 |
| Inter | OFL | ✅ | 0,516 | ✅ | 100–900 | custom, có `opsz` | 856 + 885 | 4 | 2 (lạnh, kiểu phần mềm) | 1 | 3,4 |
| Nunito | OFL | ✅ | 0,493 | ✅ | 200–1000 | custom | 270 + 275 | 3,5 | 4 (đầu nét tròn như Rounded) | 1 | 3,6 |
| **Nunito Sans** | OFL | ✅ | 0,486 | ✅ | 200–1000 | custom, có `opsz, wdth, YTLC` | 558 + 545 | 4 | 4 | 1 | **3,9** |
| Source Sans 3 | OFL | ✅ | 0,486 | ✅ | 200–900 | custom | 631 + 386 | 3 (x-height thấp, hẹp; nhìn nhỏ hơn SF cùng cỡ) | 3 | 1 | 3,2 |
| **Public Sans** | OFL (USWDS) | ✅ | 0,517 | ✅ | 100–900 | custom | 101 + 105 | 4 | 3 | 1 | **3,7** |
| Figtree | OFL | ❌ | 0,500 | ✅ | 300–900 | custom | 61 | 3,5 | 4 | 4 | **loại** |
| Plus Jakarta Sans | OFL | ✅ | 0,536 | ✅ | 200–800 | custom | 172 + 179 | 3 (hình học, I/l/1 lẫn) | 3 | 1 | 3,2 |
| Outfit | OFL | ❌ | 0,475 | ✅ | 100–900 | custom | 108 | 3 | 3 | 4 | **loại** |
| DM Sans | OFL | ❌ | 0,496 | ❌ | 100–1000 | custom | 235 + 278 | 3 | 3 | 4 | **loại** |
| Fraunces (tiêu đề) | OFL | ✅ | 0,436 | ❌ (không cần cho tiêu đề) | 100–900 | custom, `opsz, SOFT, WONK` | 352 + 405 | 3 (x-height thấp, chỉ dùng ≥ 28 pt) | 5 (mềm, "màu nước" nhất) | 1 | 3,6 |
| Newsreader (tiêu đề) | OFL | ✅ | 0,512 | ✅ | 200–800 | custom, `opsz` | 441 + 484 | 3 (gầy, kiểu báo) | 3 | 1 | 3,1 |
| **Literata** (tiêu đề) | OFL | ✅ | 0,513 | ✅ | 200–900 | custom, `opsz` | 933 + 882 | 4 (serif màn hình của Google Play Books, x-height cao) | 4 | 1 | **3,8** |
| Source Serif 4 (tiêu đề) | OFL | ✅ | 0,452 | ✅ | 200–900 | custom, `opsz` | 1181 + 835 | 3,5 | 3,5 | 1 | 3,3 |
| Lora (tiêu đề) | OFL | ✅ | 0,500 | ✅ | 400–700 | custom | 207 + 216 | 3,5 | 4 | 1 | 3,5 |
| Merriweather (tiêu đề) | OFL | ✅ | 0,521 | ✅ | 300–900 | custom, `opsz, wdth` | **4520 + 4484** | 4 | 3,5 | 2 (dung lượng) | 3,0 |

Trọng số: VI là cổng loại; sau đó dễ đọc 35 %, chính thống/không rủi ro 25 %, hợp thương hiệu 20 %, số & weight 10 %, dung lượng 10 % (theo yêu cầu chủ app 08/10: "ưu tiên font chính thống, dùng điện thoại không lỗi, dễ nhìn").

### 1c. Bằng chứng về "dễ đọc cho mắt già"

- Người lớn tuổi nhạy với khác biệt giữa font hơn người trẻ; chữ nét mảnh, hẹp, ít khoảng cách đọc chậm hơn ở cỡ nhỏ — Beier & Oderkerk, *Visible Language* 53(3), 12/2019: https://journals.uc.edu/index.php/vl/article/view/4654
- Font nhân văn (humanist) dễ nhận hơn grotesque vuông khi liếc nhanh, hiệu ứng tăng theo tuổi; chữ đen nền sáng dễ đọc hơn trắng nền đen — Dobres, Chahine, Reimer et al., *Ergonomics* 59(10), 2016 (MIT AgeLab + Monotype): https://pmc.ncbi.nlm.nih.gov/articles/PMC5213401
- 14 pt dễ đọc hơn 12 pt với người lớn tuổi, đọc nhanh hơn và được ưa thích — Bernard, Liao & Mills, CHI 2001: https://doi.org/10.1145/634067.634173
- Tổng quan 12 nghiên cứu cỡ chữ trên di động cho người già: dải 14–22 pt (42–66 phút cung), có "cỡ tới hạn" và cỡ quá lớn cũng làm đọc chậm — Hou, Anicetus & He, *Frontiers in Psychology* 13:931646, 2022: https://pmc.ncbi.nlm.nih.gov/articles/PMC9376262/
- Atkinson Hyperlegible: Braille Institute phát hành bản Next 10/02/2025, 7 weight, "150+ ngôn ngữ", OFL; nghiên cứu định lượng với người thị lực kém chỉ trình bày ở hội nghị CSUN 2024 cho bản gốc, chưa thấy công bố — https://www.brailleinstitute.org/freefont/ · https://www.csun.edu/cod/conference/sessions/2024/index.php/public/presentations/view/3108.html · METADATA không có `vietnamese`: https://raw.githubusercontent.com/google/fonts/main/ofl/atkinsonhyperlegiblenext/METADATA.pb
- Lexend: bằng chứng là đọc trôi chảy ở học sinh (Shaver-Troup), không có nghiên cứu với người trên 60; nguồn chủ yếu từ chính tác giả/Google — https://design.google/library/lexend-readability
- Font Apple: `Font.custom(_:size:relativeTo:)` có từ iOS 14, font tuỳ chỉnh **không** tự đổi Text/Display theo cỡ như SF/New York, và SwiftUI không tự tổng hợp bold/italic cho font tuỳ chỉnh — https://developer.apple.com/documentation/swiftui/applying-custom-fonts-to-text · `UIFontMetrics` cho UIKit: https://developer.apple.com/documentation/uikit/uifontmetrics

## 2) Ảnh mẫu

Tất cả trong `docs/design/research-2026-10-08/`:

| File | Nội dung |
|---|---|
| `font-specimens.html` | Trang mẫu; mở bằng **Safari** để thấy đúng New York/SF Rounded (`ui-serif`, `ui-rounded`); Chrome thay bằng Times/SF. Thêm `?theme=dark`, `?section=N` |
| `spec-system-light.png`, `spec-system-dark.png` | **Font Apple vẽ thật bằng AppKit**: A0 hiện tại (New York + SF Pro Rounded) · A1 đề xuất (New York + SF Pro, Rounded cho số) · A2 chỉ SF Pro; EN và VI |
| `spec-00-vi-strip-light/dark.png` | 21 họ, câu "Đứng lên rồi ngồi xuống, theo nhịp của bạn · ế ở ữ ặ ộ ỳ ẵ Ự", cờ FALLBACK đỏ khi glyph bị thay |
| `spec-02-pair-*.png` | B · Fraunces + Nunito Sans |
| `spec-03-pair-*.png` | C · Literata + Lexend |
| `spec-04-pair-*.png` | D · Source Serif 4 + Source Sans 3 |
| `spec-05-pair-*.png`, `spec-08-pair-*.png` | E · Newsreader + Public Sans · F · Lora + Nunito (dự phòng) |
| `spec-06-numerals-*.png` | Đồng hồ 0:11 / 1:11 / 8:88 · 2 × 8, tabular bật/tắt, chuỗi "Il1 0O ag 69 rn m" cho mọi sans |
| `measurements.txt` | x-height, cap-height, tnum, cờ fallback, bề rộng "Good morning, Margaret" 17 px |
| `ip11/*.png` | 51 màn hình thật trên iPhone 11 (font hiện tại) |

Nhận xét khi nhìn ảnh:
- Atkinson Next/2019, Figtree, Outfit, DM Sans: chữ "ữ ặ ộ" đổi sang dáng Be Vietnam Pro (hình học, dấu lệch) → không dùng được.
- Lexend: "0:11" và "1:11" lệch bề rộng → đồng hồ nhảy. DM Sans cũng vậy.
- Source Sans 3 và Newsreader nhìn nhỏ hơn hẳn ở cùng cỡ (x-height thấp, hẹp) → phải tăng cỡ, mất lợi thế.
- Literata + Nunito Sans và Fraunces + Nunito Sans là hai cặp đóng gói đẹp nhất trên giấy `#F8F1E6`; Fraunces mềm hơn nhưng x/em 0,436 nên chỉ dùng tiêu đề ≥ 28 pt.
- Font Apple (`spec-system-light.png`): A0 và A1 gần như nhau ở 19–22 pt; ở 15 pt A1 (SF Pro) sắc hơn A0 (Rounded). A2 (chỉ SF Pro) mất cảm giác "sổ tay" của New York — không khuyên.

## 3) Cặp font đề xuất + thang chữ

### 3a. Đề xuất chính — font hệ thống (A1)

**New York** (tiêu đề) · **SF Pro** (chữ, nút, caption) · **SF Pro Rounded** (số lớn). Lý do: đủ tiếng Việt đã kiểm, `opsz` tự động, Dynamic Type chuẩn, 0 KB, không file giấy phép, không rủi ro App Review, giữ quyết định 03/10 (tiêu đề serif) và chỉ đổi một dòng `design` trong `TypeRole`.

| `TypeRole` | Font | Cỡ mặc định (pt) | Weight | Neo Dynamic Type | Line height | Tracking | Ghi chú |
|---|---|---|---|---|---|---|---|
| `screenTitle` | New York | 30 (giữ) | semibold | `.title` | hệ thống (≈ 36) | 0 | tối đa 2 dòng; VI cần `lineSpacing(2)` vì dấu chồng |
| `cardTitle` | SF Pro | 22 | semibold | `.title2` | ≈ 28 | 0 | đổi từ Rounded |
| `body` | SF Pro | 19 (giữ) | regular | `.body` | ≈ 24, thêm `lineSpacing(2)` | 0 | tối đa ~60 ký tự/dòng |
| `button` | SF Pro | 20 | semibold | `.body` | — | 0 | đổi từ Rounded |
| `caption` | SF Pro | **16** (từ 15) | regular | `.callout` | ≈ 21 | 0 | chỉ thông tin phụ; không bao giờ là hướng dẫn |
| `phaseLabel` | SF Pro Rounded | 34 | bold | `.largeTitle` | — | 1,5 (giữ) | chữ hoa, pill màu pha |
| `timer` | SF Pro Rounded | 80 | regular → **medium** | `.largeTitle` | — | 0 | tabular (`monospacedDigit`, giữ); medium để không mảnh ở dark/sand |
| `transition` | SF Pro Rounded | 52 | bold | `.largeTitle` | — | 1,5 | |
| `stat` | SF Pro Rounded | 40 | bold | `.largeTitle` | — | 0 | tabular |
| `wallClock` | SF Pro Rounded | 160 | regular | `.largeTitle` | — | 0 | iPad/ngang |

Thay đổi code tối thiểu: `TypeRole.design` trả `.serif` cho `screenTitle`, `.rounded` cho `phaseLabel/timer/transition/stat/wallClock`, `.default` cho còn lại; `caption` 15 → 16 và neo `.callout`; thêm `lineSpacing(2)` cho `body` và `screenTitle`. Không đụng String Catalog.

### 3b. Phương án phụ — font đóng gói (nếu muốn nét riêng)

- **B1 (khuyên)**: Literata semibold `opsz` cho tiêu đề · Nunito Sans cho chữ · SF Pro Rounded cho số. Ấm, x-height cao, đủ VI, số tabular. Cộng ≈ 1,5 MB (Literata 933 KB + Nunito Sans 558 KB; bỏ italic).
- **B2 (dự phòng nhẹ)**: Fraunces (SOFT 60) cho tiêu đề · Public Sans cho chữ · SF Pro Rounded cho số. Cộng ≈ 450 KB. Fraunces mềm nhất, hợp màu nước, nhưng x-height thấp nên không dùng dưới 28 pt.
- Chỉ nên chọn B1/B2 sau khi test với 3–5 người dùng 60–72 đọc cùng màn Today và Paywall trên máy thật ở cả Large và xLarge Dynamic Type.

## 4) Hướng hình ảnh

Nguồn nền:
- AARP × Getty "Disrupt Aging" (23/09/2019): người trên 50 bị vẽ tiêu cực gấp 7 lần người trẻ, hay bị gắn với tóc bạc/cô lập/kém công nghệ; 51 % phụ nữ 50+ thấy "vô hình" trong quảng cáo — https://www.aarp.org/press/releases/2019-9-23-aarp-and-getty-images-announce-collaboration-to-change-the-look-of-aging.html
- Clemson, Grey, Barnett, Burfitt, Gillison, *JMIR Aging* 8:e68951, 19/06/2025 (19 người 65–84 nghĩ-thành-tiếng trên web tập luyện): người già **suy ra mình có được chào đón không từ hình ảnh và ngôn từ**; muốn thấy **nhiều tuổi, nhiều vóc dáng, nhiều mức khả năng** chứ không chỉ người già; ghét phòng gym (trẻ, chuộng ngoại hình); tên lớp kiểu "SHRED" gây phản cảm; hình quá "siêu khoẻ" cũng gây ngại — https://pmc.ncbi.nlm.nih.gov/articles/PMC12199841
- Leitão & Silva, PLoP 2012 (40 người 65–95, Nexus S): độ chính xác chạm giảm rõ dưới **14 mm**, không khác biệt trên 14 mm; vuốt cần ≥ 10,5 mm; khoảng cách giữa nút không ảnh hưởng — https://mural.maynoothuniversity.ie/6045/
- NN/g, Kane, "Usability for Older Adults: Challenges and Changes", 08/09/2019: chữ nhỏ và chữ nhạt là vấn đề xuyên suốt; nút quá nhỏ; cần dung sai lỗi — https://www.nngroup.com/articles/usability-for-senior-citizens/
- W3C WAI "Older Users and Web Accessibility" (cập nhật 20/11/2025): giảm độ nhạy tương phản, đổi cảm nhận màu, khó nhìn gần; giảm khéo léo tay; giảm trí nhớ ngắn hạn, dễ xao nhãng — https://www.w3.org/WAI/older-users/
- Ảnh > pictogram/clip-art về nhận diện ở 120 người lớn tuổi (2011) — nền cho việc giữ video người thật trong player.

Hướng chốt đề xuất:

| Chủ đề | Đề xuất | Vì sao |
|---|---|---|
| Tranh hay ảnh | **Tranh màu nước** cho Welcome, onboarding, hành trình, Complete, cây; **video người thật (AI)** chỉ trong player để thấy đúng kỹ thuật | Tranh tránh "ảnh stock người già" và lỗi AI-photo; video giúp nhận diện động tác (ảnh > pictogram) |
| Nhân vật | Giữ Margaret; thêm 2–3 nhân vật phụ cố định (đã có bạn da đen ở màn khớp — tốt): tuổi 58–75, vóc dáng đầy/vừa/gầy, 1 người ngồi xe lăn *không* cần (ngoài đối tượng) | JMIR 2025: đa tuổi, đa vóc dáng, đa khả năng; không chỉ toàn người già |
| Điểm tựa | Mọi tranh bài thăng bằng/đứng có **ghế, mặt bàn hoặc tường** trong tầm tay; ghế có lưng, không bánh | Chip "unsteady", nguồn Otago; an toàn thấy được |
| Tránh | Gậy, khung tập, viện dưỡng lão, tay run, nhìn xuống buồn; cũng tránh legging bó + tạ + gương gym, cơ thể "siêu khoẻ" | AARP (clichés yếu ớt) và JMIR (gym, quá khoẻ) |
| Bối cảnh | Phòng khách, bếp, ghế băng công viên, cửa sổ sáng — như hiện nay | Người dùng tập ở nhà |
| Dark mode cho tranh | Tranh giữ nền giấy sáng dạng thẻ (quyết định cũ) — đúng; không tối hoá tranh | Tranh là "giấy", mắt già cần tương phản |
| Icon nền vệt màu nước | Giữ; icon SF Symbols ≥ 24 pt, weight medium, luôn kèm chữ | Nhận diện icon kém theo tuổi; chữ đi kèm |
| Store/marketing | Chuyển toàn bộ sang tranh + 1 khung video; không ảnh stock | Thống nhất; tránh ageism |

## 5) Màu, cỡ, mật độ, chuyển động

**Màu (Pigment) — đã tính lại tương phản**: ink/paper 13,7:1 · textMuted/paper 6,0:1 · accent sienna chữ trên paper **4,8:1** (đạt nhưng sát; chữ nhỏ 13 pt ở tab) · onLightFill trên sky 5,8:1, trên sun 6,8:1 · trắng trên secondary #5E7F3A **4,6:1 (sát ngưỡng)** — chip "Okay"/"Easier"/"Yes, with my hands" dùng màu này · trắng trên primary tối 5,6:1 · textMuted tối 8,2:1.
- Mắt già/đục thuỷ tinh thể: thuỷ tinh thể vàng hấp thụ xanh lam, giảm phân biệt xanh/tím, giảm tương phản (tổng quan, PMC1913934; mô phỏng kính lọc *Sci Rep* 2020). Giấy `#F8F1E6` đã ấm → tốt; **không dùng xanh lam cho chữ** (hiện không có); không phân biệt pha chỉ bằng màu (đã có chữ "QUICKER"/"EASY" — tốt).
- Dark mode: Dobres 2016 — chữ đen nền sáng dễ đọc hơn; giữ Auto, nền tối `#1F1B17` (không đen tuyền) đúng; tăng weight số lớn lên medium ở dark để tránh hiệu ứng loá (halation) với người loạn thị.

**Cỡ**:
- Body 19 pt ở Large đã nằm trong dải 14–22 pt của tổng quan Hou 2022 — giữ, không tăng mặc định (cỡ quá lớn cũng làm đọc chậm; người cần lớn hơn dùng Dynamic Type).
- Caption 15 → **16 pt** (NN/g: chữ nhỏ là lỗi thường gặp nhất); giới hạn caption cho thông tin phụ.
- Nút chính 60 → **64 pt** (≈ 10 mm trên iPhone; Leitão 2012: 10,5 mm đạt 93–96 %, 14 mm ≈ 90 pt là trần không cần với); mục chạm dạng hàng ≥ 64 pt; icon đơn ≥ 56 pt (giữ).
- Tab bar nổi: nhãn ≈ 13 pt → cân nhắc 15 pt và màu `accent` tối hơn (#8F4323) cho chữ nhỏ.

**Mật độ, tải đọc**:
- Onboarding đã "một ý một màn" — tốt. Today có 6 khối cuộn dài: cân nhắc đưa thẻ buổi tập lên đầu, dòng "Week 3 of 12 · Plan" thành dòng mỏng dưới tiêu đề.
- Dòng chữ ≤ 60 ký tự (iPad `readableWidth` 700 pt hơi rộng cho 19 pt → 620).
- Mỗi màn ≤ 1 nút chính + ≤ 2 nút phụ; link gạch chân (Pick a different session, Restore) rất rõ với nhóm này — giữ.

**Chuyển động**: giữ luật 03/10 (< 0,6 s, Reduce Motion = chỉ fade). Thêm: không parallax, không tự cuộn, đường tiến trình onboarding chỉ chạy một lần; kiểm `accessibilityReduceMotion` ở mọi hiệu ứng tuỳ chỉnh — Apple HIG Motion và tiêu chí App Store Connect "Reduced Motion" (https://developer.apple.com/help/app-store-connect/manage-app-accessibility/reduced-motion-evaluation-criteria); WCAG 2.3.3 (AAA) https://www.w3.org/WAI/WCAG21/Understanding/animation-from-interactions.

**Icon**: SF Symbols, medium, ≥ 24 pt, luôn có chữ; nút mở rộng video (↗) chưa có chữ — chấp nhận vì phụ; biểu tượng mặt trăng "ngày nghỉ" trên lịch ~12 pt quá nhỏ.

## 6) Danh sách sửa UI theo ưu tiên

| Ưu tiên | Việc | File liên quan | Bằng chứng |
|---|---|---|---|
| P0 | `TypeRole.design`: body/button/cardTitle/caption → `.default` (SF Pro); giữ `.serif` tiêu đề; `.rounded` cho số | `iOS/App/Design/Typography.swift` | §3a; `spec-system-light.png` |
| P0 | `caption` 15 → 16 pt, neo `.callout` | `Typography.swift` | NN/g 2019; Bernard 2001 |
| P0 | `Metrics.buttonHeight` 60 → 64; mục chạm hàng ≥ 64 | `Tokens.swift`, `ButtonStyles.swift` | Leitão & Silva 2012 |
| P0 | `secondary` (light) đậm hơn khi là nền chữ trắng, ví dụ #54722F (≈ 5,3:1), hoặc chip chọn dùng `primary`; cập nhật `Palette.textPairs` | `Tokens.swift`, Assets | tính toán §5 |
| P1 | `lineSpacing(2)` cho `body` và `screenTitle` (dấu tiếng Việt chồng) | `Typography.swift` | `spec-system-*.png` VI |
| P1 | Timer/stat weight regular → medium | `Typography.swift` | dark mode, §5 |
| P1 | Lịch Progress: biểu tượng ngày nghỉ 12 → 16 pt, thêm nhãn "Rest" khi VoiceOver | `ip11/progress-checks.png` | NN/g |
| P1 | Tab bar: nhãn 15 pt, `accent` chữ tối hơn | `ip11/today.png` | 4,8:1 sát ngưỡng |
| P1 | Journey: huy hiệu ✓ trên điểm dừng ≥ 24 pt, thumbnail ≥ 80 pt | `ip11/journey.png` | mục chạm |
| P2 | Today: thẻ buổi tập lên đầu, dòng tuần mỏng | `ip11/today.png` | mật độ |
| P2 | Player: "00:24" → "0:24" cho khớp spec `0:11`; "left in this part" 16 pt | `ip11/walk-player.png` | nhất quán |
| P2 | Chair player: câu HLV đang nói ("Two.") lên 22 pt, trong bong bóng như onboarding | `ip11/chair-player.png` | tải đọc |
| P2 | `readableWidth` 700 → 620 trên iPad | `Tokens.swift` | ≤ 60 ký tự/dòng |
| P3 | Dàn nhân vật phụ (2–3), bảng nhân vật + điểm tựa trong mọi tranh thăng bằng | `assets/art/`, `tools/art/` | §4 |
| P3 | Chụp lại `ip11/` ở dark mode và xLarge để rà soát | `-ScreenshotMode` | chưa có ảnh dark |

Những gì đang tốt, giữ nguyên: tiêu đề New York; bong bóng HLV có avatar; link gạch chân; End có viền không đỏ; Break xanh / This hurts đỏ tách rõ; tranh phòng khách Welcome; giấy ấm; chip to.

## 7) Chi phí triển khai

**Phương án chính (font hệ thống)**: 1–2 giờ. Sửa `Typography.swift` (design theo role, caption 16, lineSpacing), `Tokens.swift` (buttonHeight, secondary), chạy `DesignTokenTests`, chụp lại `-ScreenshotMode tokens` và các màn ảnh hưởng ở Large + xLarge, light + dark. String Catalog không đổi. Không ảnh hưởng App Review.

**Phương án phụ (font đóng gói, nếu chọn)**: 0,5–1 ngày.
- Chép TTF biến thiên (không italic) vào `iOS/App/Resources/Fonts/`, thêm `UIAppFonts` vào `iOS/project.yml` (`info.properties`), `xcodegen generate`.
- `TypeRole` chuyển sang `Font.custom(name, size:, relativeTo:)` (iOS 14+); weight phải chọn bằng tên instance hoặc `fontDesign` + `weight` không tự tổng hợp; cần kiểm trên máy xem CoreText có tự đặt `opsz` theo cỡ cho font biến thiên không (chưa xác minh).
- Kèm `OFL.txt` của từng font trong bundle và dòng ghi nhận ở Me → Trợ giúp (OFL cho phép bán app, cấm bán riêng font, giữ tên gốc).
- Dung lượng thêm: B1 ≈ 1,5 MB, B2 ≈ 0,45 MB. `monospacedDigit()` hoạt động với font có `tnum` (Nunito Sans, Public Sans có; Lexend không).
- Rủi ro: font tuỳ chỉnh không có bảng tracking theo cỡ của Apple, phải tự chỉnh `tracking` ở 15–16 pt; Dynamic Type xLarge+ cần kiểm từng màn.

## 8) Câu hỏi còn mở

1. Chủ app chấp nhận đổi chữ thường sang SF Pro (A1) hay giữ SF Pro Rounded toàn bộ (A0)? Khác biệt nhỏ ở 19 pt, rõ hơn ở 15–16 pt và dark.
2. Nút chính 64 pt kéo dài màn trên iPhone SE/11 — có chấp nhận cuộn thêm ở Paywall và Your body không?
3. Có muốn thử B1 (Literata + Nunito Sans) trong buổi test người dùng cùng lúc với tên app, hay chốt luôn font hệ thống để giảm biến số?
4. Dark mode chưa có ảnh chụp — cần chụp bộ `ip11` ở Dark và xLarge trước khi chốt weight số lớn.
5. Nhân vật phụ: có thêm nhân vật đàn ông (chồng/bạn tập) để tránh app "chỉ phụ nữ" theo JMIR 2025, hay giữ toàn nữ theo định vị?
