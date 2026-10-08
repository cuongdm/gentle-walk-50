# Nguồn icon cho Good Footing — nghiên cứu 08/10/2026

_Người làm: thiết kế hình (Fable 5.1) · Phạm vi: chỉ nghiên cứu, **chưa sửa code/nội dung/tài liệu cũ**; file mới chỉ trong thư mục này. Câu hỏi của chủ app: "Thiết kế bộ icon hoặc tìm nguồn icon thật tốt — icon hệ thống hiện tại nhìn cứng". Bằng chứng: giấy phép đọc trên trang chính thức/GitHub (ngày tra: 08/10/2026), `compare.html` kéo SVG thật của từng bộ và chụp 4 ảnh `compare-*.png` (đã xem bằng mắt, phóng 2×)._

## 0) Kết luận 5 dòng

1. **Chọn Phosphor, trọng lượng Bold (MIT, không cần ghi công, có gói SwiftUI chính thức)** làm bộ icon chính cho mọi lựa chọn onboarding, hàng Me, thẻ Today/Complete/Progress, quyền, outdoor. 1 512 hình × 6 trọng lượng (9 072 glyph, Iconify), nét bo tròn, hình "vật thật" (ghế, cốc, TV, chuông, bản đồ, dấu chân) — đủ ấm trên vệt màu nước, đọc rõ ở 20 pt (ảnh `compare-light-small.png`). Phosphor Fill cùng tên = trạng thái **đã chọn**, Bold = chưa chọn.
2. **Không bộ nào có đủ bộ phận cơ thể theo cách mình cần.** Health Icons (CC0, hạng mục y tế) có `back-pain`, `joints`, `leg`, `arm`, `spine`, `walk-supported`, `old-woman`, `cane`, `dizzy` nhưng nhìn "phòng khám"; Hugeicons free (MIT) có `shoulder`, `back-muscle-body`, `body-part-leg` nhưng là hình cơ bắp. Vẽ riêng **10–12 glyph cơ thể/tình trạng** theo đúng lưới và nét Bold của Phosphor (1–2 ngày) — hoặc giữ quyết định của báo cáo UX cùng ngày: chip cơ thể **không icon**, chỉ hình người phát sáng.
3. **Bộ "vẽ tay" không mua được sự ấm áp ở 20–30 pt**: Streamline Freehand trả phí (từ 19 $/tháng, tối đa 100 icon/dự án), bản miễn phí 1 000 hình chỉ phủ 8/18 khái niệm, nét rối ở cỡ nhỏ; Pepicons Pencil (CC BY) 8/18; Doodle Icons (CC0) không có vận động/cơ thể; OpenMoji (CC BY-SA, màu) có `knee-pain`, `backache`, `joint-pain` nhưng kiểu emoji không hợp tranh màu nước. Sự ấm đến từ **vệt màu nước + vai trò màu + nét Bold bo tròn**, không phải từ nét run.
4. Dự phòng: **Hugeicons Stroke Rounded free** (MIT, 6 000+, phủ 17/18 — nhiều nhất) nếu muốn một bộ duy nhất không vẽ thêm; nhược điểm nét mảnh ở 20 pt, không có gói Swift, bản dày hơn phải mua Pro 99 $/năm.
5. Triển khai ≈ 0,5–1 ngày (script tải SVG từ npm `@phosphor-icons/core` → `Assets.xcassets/Icons/*.imageset` SVG giữ vector, enum `AppIcon`, `IconChip` đổi sang `Image(…).renderingMode(.template)`, bộ màu glyph sáng/tối mới vào `Palette.textPairs`, file MIT trong bundle + dòng ghi nhận ở Me → Help). **VƯỢT LUẬT DỰ ÁN**: báo cáo `icon-va-chong-nham-chan.md` cùng ngày chốt "SF Symbols"; đề xuất này đổi thành Phosphor cho icon nội dung, SF Symbols chỉ còn cho điều khiển hệ thống (chevron, ✓, ✕, +). Chủ app quyết.

## 1) Bảng so sánh bộ icon

Cột "Phủ": số khái niệm của ta có icon trong 18 khái niệm thử (walk, chair, stretch, balance, knee, hip, lower back, shoulder, grandkids, coffee, TV, reminder, health, journey, steps, tree, self-check, dizzy) — đếm bằng tên icon trong gói `@iconify-json/*` (jsdelivr) ngày 08/10/2026. "Dùng trong app bán tiền" = giấy phép cho phép nhúng vào app thương mại.

| Bộ | Giấy phép (link, ngày tra 08/10) | Ghi công? | App bán tiền | Số icon / kiểu | Phủ /18 | Ấm hay cứng (mắt nhìn, ảnh §2) | Hợp màu nước | Định dạng / Swift | Ghi chú |
|---|---|---|---|---|---|---|---|---|---|
| **Phosphor** | MIT — https://github.com/phosphor-icons/core (LICENSE, repo push 06/01/2026) | Giữ dòng bản quyền MIT trong bundle | ✅ | 1 512 × 6 weight (thin/light/regular/bold/fill/duotone) = 9 072 | 13 | Bold: nét đều, đầu tròn, hình vật thật → **ấm nhất trong nhóm UI**; Regular hơi mảnh ở 20 pt; Duotone (lớp 20 %) **mất hút trên vệt màu** | ✅ | SVG/PDF; gói SwiftUI chính thức https://github.com/phosphor-icons/swift (MIT) | Thiếu: bộ phận cơ thể, balance, stretch (chỉ có `person-simple-tai-chi`) |
| **Health Icons** | Icon: **CC0** (healthicons.org/about: "waived all copyright"); repo code MIT — https://github.com/resolvetosavelives/healthicons (push 28/07/2026) | Không | ✅ | ≈2 000 (2 709 kể cả 24 px/negative); outline, filled, negative | 12 | Rõ, cụ thể, nhưng **giọng y tế** (đau lưng = người ôm lưng có tia; joints = khớp xương) | ◐ (nét mảnh, hơi lâm sàng) | SVG 48 px | **Duy nhất có** back-pain, joints, leg, arm, spine, walk-supported, old-woman, cane, elderly, dizzy, exercise-yoga; không có coffee/TV/bell/map |
| Iconoir | MIT — https://github.com/iconoir-icons/iconoir (push 06/10/2026) | Giữ MIT | ✅ | 1 671, regular + solid | 12 | Nét mảnh 1,5 px, hình hình học → **cứng** | ◐ | SVG; gói SwiftUI cộng đồng | có `walking`, `stretching`, `yoga`, `community` |
| Tabler | MIT — https://github.com/tabler/tabler-icons (push 07/10/2026) | Giữ MIT | ✅ | 6 238, outline + filled | 14 | Nét 2 px đều, thiên "dashboard" → hơi cứng | ◐ | SVG; không gói Swift chính thức | có `walk`, `stretching`, `yoga`, `cane`, `physiotherapist`, `massage`, `friends`, `mood-sad-dizzy` |
| Lucide | ISC — https://github.com/lucide-icons/lucide/blob/main/LICENSE ("ISC License, (c) 2026 Lucide Icons and Contributors") | Giữ dòng ISC | ✅ | 1 869 | 11 | Mảnh, lạnh, kiểu phần mềm | ✗ | SVG; gói Swift cộng đồng | không có walk/stretch/dizzy |
| Remix Icon | Remix Icon License v1.0 (01/2026, thay Apache 2.0) — https://github.com/Remix-Design/RemixIcon/blob/master/License: "Attribution … appreciated but not required"; cấm làm logo/app icon | Không | ✅ (2.1 nêu rõ mobile app) | 3 188, line + fill | 11 | Hình đầy, góc tròn, trung tính | ◐ | SVG | giấy phép mới cấm dùng icon làm **biểu tượng app** — không ảnh hưởng ta |
| **Hugeicons** (free) | MIT theo docs https://hugeicons.com/docs/ ("MIT licensed: unlimited personal and commercial projects") và npm `@hugeicons/core-free-icons` 4.3.5 (21/09/2026, license MIT); FAQ https://hugeicons.com/faq/license: "allowed in … mobile apps … without giving credit" | Không | ✅ | 6 065 free (Stroke Rounded); Pro 60 000+/10 kiểu, 99 $/năm | **17** | Nét 1,5 px mảnh ở 20 pt; hình cơ thể là **cơ bắp/giải phẫu** | ◐ | SVG | duy nhất có `shoulder`, `back-muscle-body`, `body-part-leg`, `workout-stretching`, `yoga-01`, `elder`, `kid`, `zzz` |
| Solar | CC BY 4.0 — Figma 480 Design (https://www.figma.com/community/file/1166831539721848736; Iconify ghi CC BY 4.0) | **Có** (ghi công + link) | ✅ | 8 706 = 1 451 × 6 kiểu (Linear, Outline, Bold, Bold Duotone, Broken, Line Duotone) | 12 | Bold Duotone **mềm, nhiều "thịt"**, dễ thương; Linear bình thường | ✅ (Bold Duotone) | SVG | không có bộ phận cơ thể, steps, dizzy; `body` là cái áo |
| MingCute | Apache 2.0 — https://github.com/mingcute-design/mingcute-icons (push 31/07/2026) | Giữ NOTICE/LICENSE | ✅ | 3 320, line + fill | 14 | Đầu nét tròn, dễ chịu | ◐ | SVG | có `high-knees`, `body`, `yoga`, `walk` |
| IconPark (ByteDance) | Apache 2.0 — https://github.com/bytedance/IconPark (push cuối 24/02/2023 → **ngừng cập nhật**) | Giữ LICENSE | ✅ | 2 658 × 4 kiểu (outline, filled, two-tone, multi-color) | 13 | Nét đều, hơi "doanh nghiệp" | ◐ | SVG | có `stand-up`, `stretching`, `family`, `tea-drink` |
| **Streamline** (free: Core, Plump, Ultimate, Freehand sample…) | CC BY 4.0 — https://github.com/webalys-hq/streamline-vectors README: "You must give appropriate credit and provide a link to the Streamline website" | **Có, kèm link streamlinehq.com** | ✅ | free: Core 3 000, Freehand 1 000, Plump 1 499, Ultimate 1 999, Flex 1 500… | Freehand 8 · Ultimate 11 · Plump 6 | Freehand = nét bút run **nhưng rối ở 30 pt, mất chi tiết ở 20 pt**; Plump mập dễ thương; Ultimate mảnh | Freehand ◐ (ồn), Plump ✅ | SVG | Paid: Icons từ **19 $/tháng**, Full 29 $/tháng (https://home.streamlinehq.com/pricing); Premium: không cần ghi công nhưng **tối đa 100 icon/dự án**, giữ được icon đã nhúng sau khi huỷ (https://help.streamlinehq.com/en/articles/5354366-streamline-premium-licenses); không nói rõ "mobile app", enterprise mới ghi "embed in your app" |
| Untitled UI Icons (free) | Giấy phép riêng — https://github.com/untitleduico/icons/blob/main/LICENSE: "Use the icons in personal and commercial projects"; cấm bán lại/thư viện phái sinh; https://www.untitledui.com/license | Không | ✅ | 1 100+ line (free); Pro trả phí | (không có trên Iconify, chưa render) | Nét mảnh 1,5–2 px, rất "SaaS" | ✗ | SVG/React | không hợp giọng app |
| Fluent Emoji (Microsoft) | MIT — https://github.com/microsoft/fluentui-emoji (push 24/08/2026) | Giữ MIT | ✅ | 3D/Color/Flat/**High Contrast** (đơn sắc, 1 595) | 15 | High Contrast: người đi bộ, ngồi thiền, đứng, quỳ, cốc, TV **rất "người"**; Flat màu: đối chứng — ấm nhưng là emoji | HC ◐ (đẹp nhưng hình emoji), Flat ✗ | SVG | Cân nhắc **4–6 hình người** từ bản High Contrast nếu Phosphor thiếu |
| OpenMoji | **CC BY-SA 4.0** — https://github.com/hfg-gmuend/openmoji | Có; **share-alike** cho bản chỉnh sửa | ⚠️ được nhưng SA mập mờ khi tô lại | 4 544 màu + đen trắng | 17 | Vẽ tay, có `knee-pain`, `backache`, `joint-pain`, `older-person`, `woman-walking` | ✗ (emoji nhiều màu cạnh tranh với tranh) | SVG 72 px | Chỉ hữu ích làm **tham khảo hình** cho glyph cơ thể vẽ riêng |
| Pepicons Pencil | CC BY 4.0 — https://github.com/CyCraft/pepicons; README: dùng thương mại "purchase a license through GitHub Sponsors" | Có | ⚠️ README đòi mua qua Sponsors dù CC BY | 1 275 × 3 kiểu (pop, print, pencil) | 8 | Nét bút chì thật, đáng yêu, **không có vận động/cơ thể** | ◐ | SVG 26 px | loại vì phủ 8/18 + điều khoản mâu thuẫn |
| Doodle Icons (Khushmeen) | CC0 — https://khushmeen.com/icons.html ("no attribution required") | Không | ✅ | 400+ doodle | (không trên CDN, chưa render) | Doodle kiểu wireframe, không có ghế/đi bộ/cơ thể | ✗ | SVG/PNG/Figma | loại |
| Humbleicons | MIT — https://github.com/zraly/humbleicons | Giữ MIT | ✅ | 286 | ≈6 | Mảnh | ✗ | SVG | quá ít |
| Noun Project | Từng icon: CC BY 3.0 (phải ghi công tác giả) hoặc trả phí royalty-free bỏ ghi công — https://thenounproject.com/legal/ | CC BY: **có, từng tác giả**; trả phí: không | ✅ (điều khoản không nói riêng app) | hàng triệu, **không cùng tay vẽ** | — | Mỗi icon một kiểu → **không nhất quán**; phải ghi công từng người nếu không mua | ✗ | SVG | chỉ dùng làm nguồn tham khảo khi vẽ riêng; giá xem https://thenounproject.com/pricing (chưa xác minh con số) |
| SF Symbols (hiện tại) | Apple, chỉ dùng trong app Apple | — | ✅ | 6 000+ | ≈13 (xem `icon-va-chong-nham-chan.md`) | Hình học, cùng "giọng" với chữ hệ thống → đúng là **cứng** như chủ app nhận xét; thiếu cơ thể | ◐ | hệ thống | ưu điểm duy nhất: cân với chữ SF, không tốn dung lượng |

Ghi chú giấy phép: MIT/ISC/Apache không đòi ghi công trong UI, chỉ đòi **kèm dòng bản quyền + văn bản giấy phép** khi phân phối → bỏ file `LICENSE` của bộ vào bundle (`Resources/Licenses/`) và một mục "Acknowledgements" ở Me → Help là đủ. CC BY đòi ghi công **nhìn thấy được** (tên bộ + link). CC0 không đòi gì. App Review không bắt buộc ghi công giấy phép mở, nhưng vi phạm giấy phép là rủi ro pháp lý riêng, không phải rủi ro App Store.

## 2) Ảnh so sánh

- `compare.html` — kéo SVG thật qua Iconify API (`https://api.iconify.design/<prefix>.json?icons=…`, nguồn là gói npm `@iconify-json/<prefix>` trên jsdelivr); không commit SVG. Mở `?theme=dark`, `?size=small`.
- `compare-light.png`, `compare-dark.png` — chip 56 pt, glyph 30 pt (thẻ lựa chọn onboarding). `compare-light-small.png`, `compare-dark-small.png` — chip 44 pt, glyph 20 pt (hàng Me). Vệt màu nước dùng **đúng thuật toán `WashShape` của app** (4 thuỳ, biến thể băm từ tên icon), tô 16 %.
- Hàng "Mock: Phosphor Bold + hand-wobble filter + textured wash (custom A)" = thử nghiệm phương án vẽ riêng (a) bằng bộ lọc `feTurbulence`/`feDisplacementMap` trên glyph và mép vệt màu.

Nhận xét khi xem (phóng 2×):

| Quan sát | Hệ quả |
|---|---|
| Phosphor **Regular/Light** và Lucide/Hugeicons/Iconoir/Health Icons outline mờ ở 20 pt trên vệt màu; **Phosphor Bold và Fill** vẫn rõ | Dùng Bold ở ≤ 30 pt; Regular chỉ cho hình ≥ 40 pt nếu có |
| Phosphor **Duotone** gần như không khác Regular trên vệt màu (lớp 20 % trùng tông vệt) | Không dùng Duotone làm điểm nhấn; "hai tông" đã có sẵn nhờ vệt màu |
| Solar Bold Duotone mập, dễ thương, nhưng kiểu "app trẻ"; không có cơ thể | Không chọn |
| Health Icons: `walk-supported` (người chống gậy), `old-woman`, `back-pain`, `joints`, `leg`, `arm` rất rõ nghĩa nhưng mang giọng bệnh viện; đặt cạnh Phosphor thấy lệch nét | Chỉ làm **tham khảo hình** cho glyph vẽ riêng, hoặc dự phòng tạm |
| Hugeicons phủ nhiều nhất (17/18) nhưng `back-muscle-body` là tấm lưng cơ bắp, `body-part-leg` là bắp chân → sai giọng "không phải gym" của `app-context.md` | Dự phòng, không chính |
| Streamline Freehand: ở 30 pt nét run thành nhiễu, dizzy/TV khó đọc; ở 20 pt mất hẳn | Loại cho UI; nét vẽ tay chỉ hợp ≥ 48 pt (spot illustration) |
| Fluent Emoji High Contrast: hình người (đi bộ, đứng, ngồi thiền, quỳ, người lớn tuổi) tự nhiên, thân thiện nhất bảng; cốc, TV cũng ổn | Nguồn khả dĩ cho **4–6 hình người** nếu không vẽ riêng; phải tô lại cùng nét |
| Mock "wobble": vệt màu mép xé giấy đẹp hơn blob trơn; nét glyph run **không nhìn thấy** ở 20–30 pt | Mép vệt màu không đều là thứ đáng làm (rẻ); nét run trên icon là tốn công vô ích |
| Dark: tint sáng (sap `#9DBE78`, sky `#9DBBD4`, ochre `#E0B45A`, sienna `#E0915F`, danger `#D9776B`) đạt 5,5–8,8:1 trên `#1F1B17`; token dark hiện tại `secondary #557537` chỉ **3,25:1** | Cần bộ màu glyph riêng cho dark (mục 4) |

Tương phản glyph tính được (WCAG, glyph trên vệt 16 % trên giấy `#F8F1E6`): sap `#5E7F3A` 3,40:1 (đạt 3:1 đồ hoạ, không đạt 4,5); sap-ink `#4C6A2C` **4,57**; sky-ink `#3F6A8A` 4,15; ochre-ink `#8A5F12` 4,08; sienna-ink `#964624` **4,72**; danger-ink `#A8463B` 4,27; Hooker `#2E4A33` 6,71. Token `sky #7FA3C0` và `sun #D9A441` chỉ 2,1 và 1,8 → **không bao giờ dùng làm màu glyph**, chỉ làm vệt.

## 3) Phương án vẽ riêng

| | (a) Vector nét tay + vệt màu nước (ta tự vẽ) | (b) Spot illustration màu nước nhỏ (sinh theo phong cách tranh) | (c) Đề xuất lai: Phosphor Bold + 10–12 glyph tự vẽ cùng lưới |
|---|---|---|---|
| Cách làm | Vẽ ~60 glyph trên lưới 24/256, nét 2–2,25 px đầu tròn, cố ý lệch nhẹ; vệt màu là `WashShape` + mép không đều | Sinh 60 hình 256 px bằng model ảnh (Higgsfield/Gemini) theo prompt tranh app, tách nền, xuất PNG @2x/@3x; sáng/tối hai bản | Tải Phosphor Bold cho ~50 khái niệm UI; vẽ thêm knees, hips, lower back, shoulders, joint replacement, floor, standing long, unsteady, no jumping, walking pad, sit-to-stand, chair-lift theo nét Phosphor |
| Chi phí | 2–4 ngày designer (hoặc 1 ngày với tham khảo Health Icons/OpenMoji) + rà soát | 20–40 phút/hình kể cả chọn lọc, retouch → 3–5 ngày cho 60; mỗi lần thêm icon lại một vòng | 0,5–1 ngày tích hợp + 1–2 ngày vẽ 12 glyph |
| Nhất quán | Khó giữ cùng tay qua 60 hình; nét run làm "lệch" khác nhau mỗi hình | **Kém nhất**: model không giữ cùng độ dày, góc nhìn, bảng màu; cần bảng mẫu + nhiều lần sinh | Tốt: 80 % từ một bộ, 20 % vẽ theo khuôn |
| 20–36 pt | Nét run không thấy được ở 20 pt (ảnh mock) → công vô ích | **Hỏng** ở 20–28 pt: màu nước thành đốm; chỉ đẹp ≥ 48 pt | Tốt (Bold đọc rõ 20 pt) |
| Dark mode | Tô lại màu = 1 asset template | Phải sinh bản tối hoặc chịu viền sáng; raster không template được | Template, 1 asset |
| Mắt 58–75 | Tốt nếu nét ≥ 2 px | Chi tiết mờ, nhiều màu → tải thị giác (Wu 2022) | Tốt |
| Dung lượng | ~1 KB/SVG | 60 × 3 scale × 2 mode ≈ 3–6 MB PNG | ~1 KB/SVG |
| Kết luận | Chỉ đáng làm phần **mép vệt màu**; không đáng vẽ nét run | Chỉ cho **≤ 8 "spot" lớn** (ví dụ 6 thẻ mục tiêu onboarding, thẻ Complete) nếu muốn — không cho hàng Me/thống kê | **Chọn** |

## 4) Đề xuất + cách triển khai

**Hướng chính: Phosphor Bold (MIT) + 10–12 glyph vẽ riêng cùng nét; Fill cho trạng thái đã chọn. Dự phòng: Hugeicons Stroke Rounded free (MIT).**

### 4a. Quy tắc dùng
| Mục | Quy định |
|---|---|
| Icon nội dung (lựa chọn, hàng Me, thẻ, thống kê, quyền, outdoor) | Phosphor **Bold**; thẻ đang chọn → **Fill** cùng tên (đổi weight, không đổi hình) |
| Điều khiển hệ thống (chevron, checkmark, xmark, plus, gear, play/pause) | giữ **SF Symbols** để khớp iOS; không trộn Phosphor vào nút hệ thống |
| Tab bar | thử Phosphor Fill (`sun`, `map-trifold`, `chart-bar`, `user`) cho đồng bộ; nếu chủ app muốn giữ cảm giác "iOS" thì để SF |
| Cỡ | glyph 20 pt / chip 44 (Me), 26 pt / 52–56 (thẻ onboarding), 16 pt inline (ô thống kê Complete); glyph ≤ 50 % chip |
| Vệt màu | giữ `WashShape`, tăng 4 → 6 biến thể, thêm mép không đều nhẹ (jitter 2–3 % bán kính) |
| Màu glyph (sáng) | sap-ink `#4C6A2C`, sky-ink `#3F6A8A`, ochre-ink `#8A5F12`, sienna-ink `#964624`, danger-ink `#A8463B`, Hooker `#2E4A33`; vệt = token gốc (sap/sky/ochre/sienna/danger) 16 % |
| Màu glyph (tối) | sap `#9DBE78`, sky `#9DBBD4`, ochre `#E0B45A`, sienna `#E0915F`, danger `#D9776B`, Hooker `#8FB38F`; vệt = cùng màu 16 % trên `#1F1B17` |
| Vai trò màu | như bảng "từ vựng icon" của `icon-va-chong-nham-chan.md` (sap = buổi tập/kế hoạch, sky = hành trình/thời gian, ochre = kiểm tra/mới, sienna = người thân, danger = đau/Health/xoá) |
| VoiceOver | icon `.accessibilityHidden(true)`; chữ mang nghĩa (giữ như `IconChip`) |
| Một nghĩa một hình | giữ bảng từ vựng; đổi tên tương ứng sang Phosphor (bảng 4c) |

### 4b. Khái niệm cần vẽ riêng (không có ở Phosphor, hoặc có nhưng sai giọng)
| Khái niệm | Phosphor có? | Làm gì | Tham khảo hình |
|---|---|---|---|
| Knees, Hips, Lower back, Shoulders | ✗ | vẽ 4 glyph: hình người nghiêng đơn giản với **một chấm/vòng** ở vùng đó (cùng hình người, chỉ dời chấm) — không tia đau, không xương | Health Icons `back-pain`, `joints`; OpenMoji `knee-pain` |
| Joint replacement | ✗ | hình khớp hông/gối có đường cong nhỏ; **hoặc —** (chữ đủ) | Health Icons `joints` |
| Can't get down on the floor | ✗ | ghế + sàn gạch chéo; hoặc — | — |
| Standing long is hard | ✗ | `person-simple` + đồng hồ nhỏ; hoặc — | — |
| Dizzy | `smiley-x-eyes` (mặt chết — **không dùng**) | vẽ vòng xoáy nhỏ cạnh đầu người; hoặc — | MingCute `unhappy-dizzy` |
| Unsteady | ✗ | người với hai vạch sóng dưới chân | Health Icons `walk-supported` |
| No jumping | ✗ | người nhảy + gạch chéo | Tabler `jump-rope` |
| Stretch | chỉ `person-simple-tai-chi` | vẽ `person-simple-stretch` (tay lên, nghiêng) | Tabler `stretching`, Hugeicons `workout-stretching` |
| Balance / Steady | `person-simple-tai-chi` dùng được | giữ | — |
| Walking pad | ✗ | vẽ (đã ghi ở báo cáo UX) | Hugeicons `treadmill`? (chưa kiểm) |
| Sit-to-stand / chair question | ✗ | `chair` + mũi tên lên; hoặc — (thang 3 bậc không icon) | — |
| Grandkids | `baby` (em bé), `users-three` | vẽ người lớn nắm tay trẻ (như SF `figure.2.and.child.holdinghands`) | Fluent HC `older-person` + `child` |
| Coach/voice | `megaphone-simple`, `speaker-high`, `user-sound` | `user-sound` | — |

Quyết định đi kèm: báo cáo UX cùng ngày đề nghị **không icon** cho chip cơ thể/tình trạng (icon dễ thành nhãn bệnh). Nếu chủ app vẫn muốn, dùng đúng một hình người + chấm (không tia, không băng) và thử với 5 người dùng trước khi chốt.

### 4c. Ánh xạ SF Symbol hiện tại → Phosphor Bold (tên trong `@phosphor-icons/core`)
`figure.walk`→`person-simple-walk` · `figure.walk.motion`→`person-simple-walk` + nhãn "Long" · `chair.fill`→`chair` · `figure.flexibility`→glyph tự vẽ · `figure.stand`→`person-simple-tai-chi` · `location.fill`→`map-pin` · `map.fill`→`map-trifold` · `leaf.fill`→`leaf`, `tree.fill`→`tree` · `calendar`→`calendar-dots` · `stopwatch.fill`→`timer` · `sparkles`→`sparkle` · `arrow.up.circle.fill`→`arrow-circle-up` · `bell.fill`→`bell` · `moon.zzz.fill`→`moon-stars` · `creditcard.fill`→`credit-card` · `heart.fill`→`heart` · `hand.raised.fill`→`hand-palm` · `exclamationmark.triangle.fill`→`warning` · `speaker.wave.2.fill`→`speaker-high` · `person.wave.2.fill`→`user-sound` · `music.note`→`music-note` · `captions.bubble.fill`→`closed-captioning` · `globe`→`globe-simple` · `textformat.size`→`text-aa` · `circle.lefthalf.filled`→`circle-half` · `questionmark.circle.fill`→`question` · `envelope.fill`→`envelope-simple` · `doc.text.fill`→`file-text` · `lock.shield.fill`→`shield-check` · `arrow.clockwise`→`arrow-clockwise` · `trash.fill`→`trash` · `checkmark.seal.fill`→`seal-check` · `lock.fill`→`lock` · `cup.and.saucer.fill`→`coffee` · `fork.knife`→`fork-knife` · `tv.fill`→`television-simple` · `clock.fill`→`clock` · `sun.max.fill`→`sun` · `shoeprints.fill`→`footprints` · `forward.fill`→`fast-forward` · `person.2.fill`→`users` · `zzz`→`moon-stars` hoặc `smiley-meh` · `bandage.fill`→`bandaids` · `chart.bar.fill`→`chart-bar` · `newspaper.fill`→`newspaper` · `ear.fill`→`ear` · `info.circle`→`info`. (Tên đã kiểm tồn tại trong gói Iconify `ph` 08/10/2026 trừ các tên đánh dấu "tự vẽ".)

### 4d. Bước triển khai (ước 0,5–1 ngày code, 1–2 ngày vẽ)
1. `tools/art/build_icons.py` (mới): đọc `tools/art/icons.json` (danh sách `appName → ph:name-bold`), tải tarball npm `@phosphor-icons/core` **ghim phiên bản** (ví dụ 2.1.x), chép SVG vào `iOS/App/Assets.xcassets/Icons/<appName>.imageset/` với `Contents.json` `{"preserves-vector-representation": true, "template-rendering-intent": "template"}` (Xcode 12+ nhận SVG trực tiếp, giữ vector; không cần PDF), sinh `iOS/App/Design/AppIcon.swift` (`enum AppIcon: String, CaseIterable`) và `iOS/App/Resources/Licenses/Phosphor-MIT.txt`. Glyph vẽ riêng để trong `assets/icons/custom/*.svg`, script chép cùng cách.
2. `IconChip(icon: AppIcon, tint: IconTint)` thay `symbol: String`: `Image(icon.rawValue).renderingMode(.template).resizable().scaledToFit().frame(width: size*0.5)`; `WashShape` thêm biến thể/mép. Giữ `@ScaledMetric`, `.accessibilityHidden(true)`.
3. Màu: thêm colour set `iconSap`, `iconSky`, `iconOchre`, `iconSienna`, `iconDanger` (sáng = *-ink, tối = bảng dark ở 4a) → `Palette`; thêm cặp (glyph, vệt-trên-giấy) vào `Palette.textPairs` với ngưỡng **3:1** cho đồ hoạ (hoặc giữ 4,5:1 và dùng *-ink). Cập nhật `DesignTokenTests`.
4. Thay dần theo màn (bảng 3a–3e của `icon-va-chong-nham-chan.md`): onboarding → Me → Today/Complete/Progress → permissions/outdoor. SF Symbols chỉ còn ở điều khiển hệ thống.
5. Me → Help: hàng "Acknowledgements" mở sheet liệt kê "Phosphor Icons — MIT" (+ Health Icons CC0 nếu dùng). `copy_lint` và String Catalog cho chuỗi mới (en-US).
6. Test: `-ScreenshotMode tokens` thêm trang lưới icon (mọi `AppIcon` × 5 tint × sáng/tối × 20/26 pt); unit test mọi `AppIcon.rawValue` tồn tại trong bundle (`UIImage(named:) != nil`).
7. Dung lượng: ~60 SVG ≈ 100 KB. Không ảnh hưởng App Review (không phải nội dung, không có tên nền tảng khác).

Nếu chọn dự phòng Hugeicons: cùng quy trình với npm `@hugeicons/core-free-icons` (icon là mảng path JS, cần script xuất SVG) — nhiều việc hơn Phosphor, nét 1,5 px nên chip Me phải tăng glyph lên 22–24 pt.

## 5) Câu hỏi còn mở

1. Chip cơ thể/tình trạng: có icon (hình người + chấm, vẽ riêng, cần test 5 người) hay giữ "không icon" như báo cáo UX cùng ngày?
2. Tab bar: Phosphor Fill cho đồng bộ hay giữ SF Symbols cho cảm giác iOS?
3. Có muốn thử 6 spot illustration màu nước (phương án b) **chỉ cho 6 thẻ mục tiêu onboarding** (≥ 56 pt) để so với chip Phosphor trong cùng buổi test người dùng? Tốn ~0,5 ngày sinh + chọn.
4. Ngưỡng tương phản glyph: chấp nhận 3:1 (đồ hoạ, WCAG 1.4.11) với token gốc, hay bắt 4,5:1 bằng màu *-ink (tối hơn, hơi kém "màu nước")?
5. Ai vẽ 10–12 glyph riêng: designer ngoài (1–2 ngày) hay sinh bằng model + dọn tay trong Figma?
6. Chưa xác minh: trang giấy phép đầy đủ của Hugeicons (`hugeicons.com/license-agreement` không fetch được, chỉ có docs/FAQ nói MIT); giá NounPro; Solar chỉ có giấy phép trên Figma (fetch bị 403, dựa vào Iconify ghi CC BY 4.0).

## Trạng thái chuẩn bị (08/10)

_Làm song song với milestone 1, không đụng file cũ trong `iOS/App/` (chỉ thêm file mới), chưa chạy `xcodegen`/build/simulator, chưa commit._

**Đã có**
- `tools/art/icons-manifest.json`: **73 khái niệm** (một nghĩa → một glyph → một asset), mỗi dòng có `concept`, `asset`, `source`, `glyph`, `tint` (sap/sky/ochre/sienna/danger), `meaning`, `replaces` (SF Symbol đang dùng). **61 Phosphor + 12 vẽ riêng**. Không glyph nào mang hai nghĩa (`sharedGlyphs` rỗng); vài chỗ đã tách khỏi bảng §4c để giữ luật một nghĩa: Less pain = `hand-heart` (trái tim để cho Apple Health), I got bored = `smiley-meh` (moon-stars để cho ngày nghỉ), đếm ngược "3, 2, 1" = `hourglass-simple` (timer để cho tự kiểm tra), Long walk = `person-simple-hike`, Seated = `armchair`, Everyday wins = `thumbs-up`.
- `tools/art/build_icons.py` (stdlib): tải **`@phosphor-icons/core` 2.1.1** từ registry npm, kiểm `integrity` `sha512-v4ARvrip4qBCImOE5rmPUylOEK4iiED9ZyKjcvzuezqMaiRASCHKcRIuvvxL/twvLpkfnEODCOJp5dM4eZilxQ==` (khớp metadata registry) trước khi đọc, cache ở `~/.cache/good-footing-icons/`, đọc từng file trong bộ nhớ (không giải nén ra đĩa). Ghi ra:
  - `iOS/App/Assets.xcassets/Icons/` (thư mục có `provides-namespace`): `<asset>.imageset` (Bold = bình thường) và `<asset>-fill.imageset` (Fill = đã chọn), SVG + `Contents.json` với `preserves-vector-representation` và `template-rendering-intent: template` — 176 image set (146 + 30 lớp).
  - `iOS/App/Design/AppIcon.swift` (sinh tự động, không sửa tay): `enum AppIcon: String, CaseIterable` — `image`, `selectedImage`, `image(selected:)`, `assetName` (`"Icons/<asset>"`), `tint` (vai trò màu), `glyph`, `sharedGlyphs`; doc comment ghi luật một nghĩa một hình.
  - `iOS/App/Resources/Licenses/Phosphor-MIT.txt`: văn bản LICENSE nguyên bản trong gói (giữ CRLF).
  - `--check`: thoát mã 1 nếu thiếu/cũ/thừa file so với manifest. Chạy lại không đổi gì (idempotent).
- `tools/art/draw_custom_icons.py` → `assets/icons/custom/*.svg` (54 file): 12 glyph vẽ riêng trên lưới 256 và nét 24 của Phosphor Bold. **10 icon cơ thể/giới hạn là icon hai lớp** (sửa theo nhận xét điều phối 08/10: một màu template làm hình người và vùng nhấn lẫn vào nhau): lớp `base` = hình người (tô mực ~55 %), lớp `mark` = vùng/ý nghĩa tô sienna đặc như mock `SoreSpots.dc.html` — gối = 2 đĩa dưới, hông = dải ngang rộng, lưng dưới = hình nghiêng + cung dày ở cột sống dưới, vai = 2 đĩa trên, khớp thay = vòng rỗng ở hông (lớp base bị khoét trong vòng, như nền giấy của mock) + chấm nhỏ ở gối; sàn = thanh sàn, đứng lâu = đồng hồ, chóng mặt = vòng xoáy, không vững = hai vạch rung, không nhảy = huy hiệu cấm. Mỗi icon hai lớp có `<asset>-base`, `<asset>-base-fill` (đầu đặc = trạng thái chọn), `<asset>-mark`; `<asset>` và `<asset>-fill` vẫn có làm bản một màu dự phòng. `stretch`, `grandkids` một lớp. Manifest đánh dấu bằng `"layers": ["base", "mark"]`.
- `AppIcon.swift` thêm `isLayered`, `enum Layer`, `layerAssetName(_:selected:)` và view **`LayeredIcon(icon:baseColor:markColor:selected:)`** (ZStack hai ảnh template, `scaledToFit`, ẩn với VoiceOver; icon một lớp vẽ cả hình bằng `markColor`).
- `iOS/GentleWalkTests/AppIconTests.swift`: mọi case có ảnh Bold + Fill trong bundle (`UIImage(named:)`), là template; icon hai lớp có đủ `base`, `base-fill`, `mark` (template); đúng 10 icon cơ thể/giới hạn là hai lớp; không hai case chung glyph ngoài `sharedGlyphs`. Đã typecheck `AppIcon.swift` và test (swiftc, SDK iOS simulator, module giả) — sạch; chưa chạy thật.
- Bảng xem trước: `tools/art/preview_icons.py` → `app-icons-preview.html` (mọi icon Bold + Fill × 20/28/36 pt × sáng `#F8F1E6`/tối `#1F1B17`, trên vệt màu nước theo thuật toán `WashShape`, màu glyph *-ink/tint tối của §4a) + ảnh `app-icons-preview-1…5.png` và `app-icons-preview-body-zoom.png` (3×, các hàng hai lớp). Icon hai lớp hiển thị mực 55 % + sienna trên vệt ochre 24 % (§2c). Đã xem bằng mắt: ở 20 pt phân biệt được ngay gối / hông / lưng dưới / vai / khớp thay.

**Tạo lại**
```
python3 tools/art/draw_custom_icons.py   # chỉ khi sửa hình vẽ riêng
python3 tools/art/build_icons.py         # asset catalog + AppIcon.swift + giấy phép
python3 tools/art/build_icons.py --check # trước khi commit
python3 tools/art/preview_icons.py       # bảng xem trước
```
Đổi phiên bản Phosphor: sửa 3 hằng `PHOSPHOR_*` trong `build_icons.py` và khối `phosphor` trong manifest (lấy từ `npm view @phosphor-icons/core dist`), chạy lại, xem bảng.

**Agent chính cần làm tiếp (milestone 3)**
1. `cd iOS && xcodegen generate` để thêm `AppIcon.swift`, `AppIconTests.swift`, `Resources/Licenses/Phosphor-MIT.txt`; build + chạy `AppIconTests`. Kiểm bằng mắt trong app vài icon vẽ riêng ở 20 pt (đã dùng `stroke` + `stroke-linecap` + `fill-rule=evenodd`, không CSS/mask/`currentColor`; nếu Xcode vẽ sai nét thì báo để đổi sang path outline).
2. Me → Help: thêm hàng "Acknowledgements" mở sheet "Phosphor Icons — MIT" đọc từ `Phosphor-MIT.txt`; chuỗi mới vào String Catalog (en-US + vi), `copy_lint` 0 findings.
3. Màu glyph: colour set `iconSap/iconSky/iconOchre/iconSienna/iconDanger` (sáng = *-ink, tối = bảng §4a), map `AppIcon.Tint` → `Palette`, thêm cặp glyph/vệt vào `Palette.textPairs` cho `DesignTokenTests` (không dùng sky/sun làm màu nét).
4. `IconChip(icon: AppIcon, …)` dùng `icon.image(selected:)`, riêng `icon.isLayered` thì dùng `LayeredIcon(icon:, baseColor: mực 55 %, markColor: sienna, selected:)` trên vệt ochre 24 %; `SelectableCard` dùng Fill khi chọn. Thêm cặp màu sienna/vệt ochre vào `Palette.textPairs` (ngưỡng đồ hoạ 3:1). Thay SF Symbols trong view theo cột `replaces` của manifest (onboarding → Me → Today/Complete/Progress → permissions/outdoor). SF giữ cho chevron, ✓, ✕, +, play/pause, tab bar (câu hỏi mở §5.2), các bước hướng dẫn giao diện iOS (Screen Mirroring, huỷ gói: `hand.draw`, `rectangle.on.rectangle`, `hand.tap`, `list.bullet`, `xmark.circle`) và ảnh dự phòng `photo.artframe`.
5. Trang lưới icon trong `-ScreenshotMode tokens` (sáng/tối/XXL).

**Chưa có glyph tốt / cần chủ app xem**
- Walking pad (`figure.walk.treadmill`) và khối cool-down (`figure.cooldown`): chưa có khái niệm trong manifest; tạm giữ SF hoặc dùng `stretch` cho cool-down — chủ app chốt.
- Seed (`circle-dashed`) và Seated (`armchair`) nghĩa hơi xa. Bộ cơ thể hai lớp đã rõ ở 20 pt; vẫn nên đưa vào test 5 người như §5.1 (nhất là lưng dưới nhìn nghiêng và không nhảy).
- Fill của các icon dạng nét (restore `arrow-clockwise`, ear) mảnh hơn Bold: chỉ dùng Fill cho thẻ lựa chọn, không cho hàng Me.
