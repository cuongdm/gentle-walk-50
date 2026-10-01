# Kế hoạch nội dung 4 nhóm bài — Walks · Chair moves · Stretches · Short extras (30/09/2026 — **đã duyệt 30/09/2026**, xem §7 và app-context decisions log)

**Mục tiêu:** thay bộ demo hiện có (6 clip ghế, 1 clip đi bộ thử, 8 tư thế giãn cơ chưa có clip, kịch bản "tối thiểu") bằng thư viện nội dung thật cho 4 nhóm của màn All sessions, đúng chuẩn sức khoẻ có nguồn, hình người thật do AI tạo với chuyển động **tự nhiên, tốc độ thật, không tua nhanh, không giật**, và tài liệu đủ để một agent sản xuất trên Google Flow + ElevenLabs mà không cần hỏi lại.

**Nguồn của kế hoạch này (đọc trước khi làm):**
- Chuẩn sức khoẻ có trích dẫn: [research/2026-09-30-exercise-standards.md](../research/2026-09-30-exercise-standards.md) (gọi tắt **STD**; mã `[S#]` là nguồn trong đó).
- Đối thủ và điểm đau người dùng: [research/2026-09-30-competitor-4-groups.md](../research/2026-09-30-competitor-4-groups.md) (**CMP**).
- Kỹ thuật Flow / ElevenLabs / Eleven Music: [research/2026-09-30-flow-elevenlabs-production-notes.md](../research/2026-09-30-flow-elevenlabs-production-notes.md) (**PROD**) + [video-skill-notes.md](../video-skill-notes.md) (quy trình, QA, bẫy).
- Prompt và thông số để sản xuất: [scripts/P-production-prompts.md](../scripts/P-production-prompts.md) (**PROMPTS**).
- Quy tắc sản phẩm: [app-context.md](../../app-context.md) (Tone & copy rules), [content-plan.md](../content-plan.md).

**Trạng thái hiện tại (30/09/2026):** All sessions có 14 buổi (`SessionCatalog.swift`): Walks 4 · Chair 3 · Stretches 4 · Extras 3, ghép từ 6 động tác ghế + 8 tư thế giãn cơ + khung đi bộ 5/8/10 phút. Clip đã có: V1-1…V6-1 (ghế, 1 góc máy, cùng khung), W1-1 (đi bộ ngồi, thử). Giãn cơ dùng ảnh placeholder. Kịch bản: A1, A2 tối thiểu, A4, A10, A-min-support. Giọng: ElevenLabs Bella gói Free (chỉ prototype).

---

## 1. Kết luận từ nghiên cứu → 10 nguyên tắc cho nội dung

| # | Nguyên tắc | Căn cứ |
|---|---|---|
| 1 | **Demo trước, tập sau.** Mỗi động tác: HLV làm một lần chậm trong khi giọng mô tả tư thế, rồi "now with me". | Lời chê lặp lại nhất trên thị trường: "explanations… happen after the demonstration", khen "shows you the exercise first and speaks slowly" (CMP §3, §4.2) |
| 2 | **Báo trước 8–10 giây** khi sắp đổi động tác hoặc pha ("Ten more seconds, then we change"). | Khen Walk At Home "enough lead time", Tai Chi "10 second warning" (CMP §3) |
| 3 | **Khởi động chậm thật: ≥ 2 phút trước bất kỳ pha nhanh nào; ≥ 2 phút thả lỏng cho buổi ≥ 8 phút.** Buổi 5 phút không có pha nhanh. | Otago 2 + 2 phút (STD §1.2, [S15]); Walk At Home bị chê "jump right into speed walking" (CMP) |
| 4 | **Seated không gọi là brisk/moderate**; chỉ "quicker" và tăng tay; cường độ đo bằng talk test, không số. | Seated marching 88 bpm = 1.98 MET, light (STD §2.1, [S22]); talk test (STD §1.3) |
| 5 | **Liều theo nguồn:** ghế 6–12 rep, tempo 2–3 s lên / 1 s giữ / 3–4 s xuống, nghỉ 15–60 s; giãn cơ 15–30 s mỗi lần, tổng 45–60 s mỗi nhóm cơ; thăng bằng tay vịn 2H → 1H, không nhắm mắt. | STD §3.1, §4.1, §5.1 |
| 6 | **Biến thể theo cơ thể có sẵn cho từng động tác** (Joint replacement, Knees, Lower back, Shoulders, Dizzy, Standing is hard), không chỉ ẩn bài. | JustFit/GentleFit/LazyFit bị chê bỏ qua hồ sơ gối (CMP §4.8); quy tắc STD §3.3 |
| 7 | **Thời lượng thật thà**: số phút trên thẻ = tổng cả nghỉ và chuyển bài. | "lists 12 minutes, but it takes 18" (CMP §3) |
| 8 | **Tên động tác và trái/phải cố định** giữa giọng, phụ đề, thẻ và clip; clip luân phiên chứa cả hai bên, không lật gương. | LazyFit đổi tên, Chair Yoga for Seniors nói phải làm trái (CMP §4.6); video-skill-notes §5e |
| 9 | **Prompt lo tư thế đúng và chuyển động sạch ở một nhịp tự nhiên; nhịp nhanh/chậm làm bằng hậu kỳ** (time-remap + nội suy khung optical flow, biên 0,75×–1,3×, QA giật/nhoè), không ép AI theo tốc độ và không tua "thô" (không nội suy) quá 1,15×; giữ tư thế = clip "đứng yên thở" lặp, không freeze-frame. | Chủ app 30/09 ("nhanh chậm dùng kỹ thuật can thiệp"); PROD §2.2, §2.4 |
| 10 | **Không kcal, không nhịp tim, không mile, không hứa giảm ngã**; ghi nguồn cho từng bài trong `exercises.json` (`source`). | app-context; CMP §4.5; STD §8.3 |

---

## 2. Thư viện nội dung đề xuất (số lượng theo nhóm)

Ký hiệu: **A** = bắt buộc trước test prototype/ra mắt · **B** = đợt sau ra mắt. "Clip" = một file lặp trong app (720p + 1080p). Mọi động tác đều có bản ngồi hoặc bản vịn ghế.

### 2.1 Walks — 5 buổi · 8 động tác · 18 clip (A: 10)

**Động tác (từ vựng cố định, STD §2.3):**

| Mã | Tên (giọng + thẻ) | Ngồi | Đứng (In place) | Bản dễ | Bản khó hơn | Ẩn / thay với | Nguồn |
|---|---|---|---|---|---|---|---|
| wk.march | March | nhấc gối luân phiên, tay vung | tại chỗ, gót chạm trước | heel taps (gót nhấc, mũi chạm sàn) | gối cao hơn (≤ hông), tay đẩy trước | Joint replacement: gối dưới hông | [S11][S15][S16] |
| wk.heel-dig | Heel dig | duỗi chân, gót chạm, mũi kéo về | gót chạm trước, đổi bên | chậm hơn | đổi nhanh theo nhịp | — | [S16 #5][S11] |
| wk.side-step | Side step | bàn chân bước ra – khép, luân phiên | bước sang – khép | bước nhỏ, tay chống hông | bước rộng, tay mở ngang | Dizzy: bước nhỏ, gần ghế | [S13][S16 #10] |
| wk.knee-lift | Knee lift | gối cao hơn march một chút | gối ≤ hông, bàn chân thẳng | nhấc thấp, tay vịn ghế | tay đối diện chạm gối | Joint replacement: rõ ràng dưới hông | [S29][S28] |
| wk.toe-tap | Toe tap forward | mũi chân chạm trước, luân phiên | chạm mũi chân trước, gối trụ mềm | — | low kick (đá thấp, không khoá gối) | Knees: không đá | [S7][S43b] |
| wk.heel-back | Heel to back | gót trượt về gầm ghế | gót kéo về mông, vịn ghế | biên nhỏ | không vịn | Knee replacement: tới mức thoải mái | [S16 #3][S9 p.58] |
| wk.shift | Weight shift | dồn trọng tâm sang từng bên (ngồi: nghiêng nhẹ) | chân rộng bằng vai, gối theo mũi chân | vịn ghế | nhấc gót bên nhẹ tải | — | [S12][S31] |
| wk.arms | Arm swing / press (bồi thêm, không có clip riêng) | vung tay, đẩy trước ngang vai | như ngồi | tay dưới vai | đẩy chéo lên (không quá đầu nếu đau vai) | Shoulders: dưới ngang vai | [S16 p.29][S37] |

**Bỏ:** grapevine (bắt chéo chân — hông nhân tạo [S27], thăng bằng), walk forward/back 4+4 (cần không gian, lùi khi chóng mặt) → để B nếu test cho thấy nhàm.

**Buổi (khung theo STD §2.6, §7):**

| Buổi | Cấp mặc định | Khung | Động tác | Cường độ |
|---|---|---|---|---|
| Gentle walk 5 | Seated | 1:00 warm · 3 × 1:00 · 1:00 cool | march · heel dig · side step | không pha nhanh; Steady chỉ thêm tay |
| Steady walk 8 | In place | 2:00 · 4 × 1:00 (40 s easy / 20 s quicker) · 2:00 | march · side step · knee lift · heel dig | talk test mỗi 2 phút |
| Strong walk 10 | In place | 2:00 · 6 × 1:00 (30/30) · 2:00 | + toe tap · heel to back | |
| Longer walk 15 (B) | In place | 3:00 · 3 vòng × 3 động tác (1:00 easy / 0:30 quicker) · 3:00 | 6–7 động tác xoay vòng | cần template mới trong `build_content.py` |
| Commercial break walk 5 | Seated hoặc In place | như Gentle walk 5 | march · heel dig · shift | xem §2.4 |

Cool-down 2:00 của mọi buổi đi bộ: 60–90 s march chậm → calf (đứng) hoặc ankle (ngồi) 20 s → chest 15 s + 3 hơi thở (STD §4.3). Walking pad: cùng khung In place nhưng chỉ march + tay (không side step trên belt), câu an toàn riêng (STD §2.5); không clip.

**Clip đi bộ:** một clip nguồn cho mỗi (động tác × cấp), tạo ở nhịp tự nhiên ≈ 96 bước/phút (một chân chạm mỗi 0,625 s — nằm giữa hai nhịp đích). Hai bản trong app **dựng từ cùng nguồn bằng time-remap có nội suy khung**: easy ≈ 88 spm (0,92×) và quicker ≈ 104 spm (1,08×) — nằm trong "easy < 100 spm, brisk ≥ 100" (STD §2.1). Seated: bản quicker chỉ khác nhịp tay, cũng dựng từ nguồn. Không tạo clip nhịp riêng.

| Nhóm clip nguồn | Số | Đợt |
|---|---|---|
| Seated: march (W1-1 có), heel dig, side step, knee lift, toe tap, shift | 6 | A |
| In place: march, side step, knee lift, heel dig | 4 | A |
| In place: toe tap, heel to back, shift | 3 | B |
| **Tổng nguồn** | **13** (→ 26 file lặp: easy + quicker) | A = 10 |

### 2.2 Chair moves — 3 buổi · 12 động tác · 24 clip (A: 12)

**Động tác (STD §3.4):** giữ 6 hiện có, thêm 6.

| Mã | Tên | Tư thế | Đếm | Bản dễ | Bản khó hơn | Ẩn / biến thể | Nguồn |
|---|---|---|---|---|---|---|---|
| mv.sit-to-stand | Sit-to-stand | ngồi → đứng | rep (5–12) | tay đẩy ghế; ghế cao | tay khoanh ngực, ngồi xuống đếm 3 | Joint replacement: ghế cao, không cúi > 90° | [S18][S9 p.60] |
| mv.knee-lift | Seated knee lift | ngồi | giờ 30–45 s | chỉ nhấc gót | tay vung đối chân | Joint replacement: gối ≤ hông | [S11] |
| mv.leg-ext | Seated leg extension | ngồi | giờ | duỗi nửa | giữ 3 s | — | [S9 p.59][S16 #1] |
| mv.heel-toe | Heel and toe raises | ngồi | giờ | chỉ gót | đứng vịn ghế | Dizzy: ngồi | [S9 p.62][S16 #4–5] |
| mv.wall-push | Wall push-up | đứng, tường | rep (6–12) | gần tường | xa tường | Standing is hard: ẩn · Shoulders: biên nhỏ | [S9 p.54][S12] |
| mv.single-leg | Single-leg stand | đứng sau ghế | giữ 5–10 s | nhấc gót | 1 tay | Dizzy: 2 tay, không NS | [S9 p.65][S16 #9] |
| mv.side-leg **(mới)** | Side leg raise | đứng sau ghế, 2 tay | rep 8–12/bên | biên nhỏ | 1 tay | mũi chân hướng trước (hông nhân tạo OK biên nhỏ) | [S9 p.57][S16 #2] |
| mv.back-leg **(mới)** | Back leg raise | đứng sau ghế | rep 8–12/bên | biên nhỏ | giữ 1 s | Lower back: không ưỡn, biên nhỏ | [S9 p.56][S12] |
| mv.knee-curl **(mới)** | Knee curl | đứng sau ghế | rep 8–12/bên | biên nhỏ | không vịn | Knee replacement: tới mức thoải mái | [S9 p.58][S16 #3] |
| mv.mini-squat **(mới)** | Mini-squat | đứng, 2 tay lưng ghế | rep 6–10 | rất nông | chậm hơn | Knees: chỉ nửa tầm, dừng khi gót nhấc; gối không sập vào | [S12][S16 #6][S31] |
| mv.arm-raise **(mới)** | Arm raises (front/side) | ngồi | rep 8–12 | tay dưới vai | giữ 1 s; overhead khi vai không đau | Shoulders: chỉ tới ngang vai | [S9 p.48–50] |
| mv.row **(mới)** | Seated row (no band) | ngồi | rep 8–12 | biên nhỏ | giữ 2 s | — (tốt cho loãng xương) | [S9 p.53][S32] |

Toe taps (STD C15) và hip march làm **khởi động** của mọi buổi ghế (dùng clip W seated). Torso twist ở nhóm Stretch.

**Buổi (STD §3.5):**

| Buổi | Khung | Bài | Chuyển |
|---|---|---|---|
| Gentle chair moves 5 | 1:00 warm (seated march + toe taps) · 3 × (45 s + 15 s) · 1:00 chest stretch + thở | 3 bài ngồi, xoay vòng từ: knee lift, leg ext, arm raise, row, heel-toe | 15 s = 3 hơi thở |
| Chair moves 7 | 1:30 · 5 × (40 s + 15 s) · 1:00 | sit-to-stand dễ, leg ext, heel-toe, arm raise, row (+1 bài đứng vịn khi không Standing is hard) | 30 s + câu "hands on the chair, take a breath, then stand" khi ngồi ↔ đứng |
| Stronger chair moves 8 | 1:30 · 6 × (45 s + 10 s) · 1:00 | sit-to-stand, leg ext, heel raise đứng, side leg, mini-squat, row (xoay vòng với back leg, knee curl, wall push-up) | như trên |

Xoay vòng theo `rotationIndex` để 2 ngày ghế liền nhau khác bài (CMP §4.10, "too easy and repetitive"). Mỗi bài trong buổi: 1 rep demo chậm (giọng mô tả) → "now with me" → đếm rep hoặc giờ → "ten more seconds" → nghỉ.

**Clip:** 6 clip chính hiện có (chờ huấn luyện viên/chủ app duyệt lại theo checklist STD §8.1: V1 tay chạm ghế khi ngồi, V6 chân nhấc cao hơn kịch bản) + 6 clip chính mới (A) + 12 clip bản dễ (B; sit-to-stand tay đẩy ghế và heel raise ngồi ưu tiên A) = **24**.

### 2.3 Stretches — 4 buổi + hạ nhiệt · 12 tư thế · 32 clip (A: 12)

**Tư thế (STD §4.2):** giữ 8 hiện có (A10), thêm 4; bỏ figure-4 (đã bỏ), bỏ quad đứng (thăng bằng một chân + nắm bàn chân, NIA cảnh báo mổ hông/lưng [S9 p.85] → thay bằng leg extension).

| Mã | Tên | Tư thế | Hai bên | Ẩn / bản dễ khi | Nguồn |
|---|---|---|---|---|---|
| st.neck-turn | Neck turn | ngồi | có | Dizzy: nửa tầm, mắt mở | [S9 p.71][S14][S16 p.6] |
| st.neck-tilt | Side of the neck | ngồi | có | Dizzy | [S14] |
| st.chin-tuck **(mới)** | Chin tuck | ngồi | không (10 lần nhẹ) | không ngửa cổ | [S16 p.7] |
| st.shoulder-roll **(mới)** | Shoulder rolls | ngồi | không (5 vòng) | Shoulders: biên nhỏ | đề xuất app (STD F4) |
| st.chest | Chest and shoulders | ngồi xa lưng ghế | không | Shoulders: tay trên hông | [S9 p.75][S11] |
| st.upper-back **(mới)** | Upper back reach | ngồi | không | Lower back / loãng xương: lưng thẳng, chỉ vươn tay | [S9 p.78] |
| st.twist | Upper back twist | ngồi | có | Lower back: biên nhỏ, chậm | [S11][S9 p.77] |
| st.side | Side stretch | ngồi | có | Lower back, Shoulders | [S14][NHS-LPT] |
| st.thigh | Back of the thigh | ngồi mép ghế, lưng thẳng | có | **Joint replacement: ẩn**; Lower back: chỉ duỗi chân, không nghiêng | [S9 p.83][S31][S27][S32] |
| st.ankle | Ankle circles and points | ngồi | có | Knees: gót chạm sàn | [S9 p.79][S11] |
| st.calf | Calf stretch | đứng vịn ghế | có | Standing is hard: ẩn; Knees: bước ngắn | [S9 p.88][S14] |
| st.overhead **(mới)** | Overhead reach at the wall | đứng đối tường (hoặc ngồi vươn) | không | Shoulders: tới ngang mắt; Standing is hard: bản ngồi | [S9 p.74] |

Kết mọi buổi: hít thở NHS (mũi 1–5 / miệng 1–5) 30–60 s [S35].

**Thời gian giữ (chốt lại, câu hỏi #2 cuối file):** Gentle 15 s · Steady 20 s · Strong 30 s, **một lần mỗi bên**, cộng **vòng 2 cho 3 tư thế trọng tâm** (calf/thigh, chest, twist) ở Steady và Strong để tổng ≥ 45 s mỗi nhóm cơ (STD §4.1). Neck turn, chin tuck, shoulder rolls, ankle là vận động chậm lặp lại, không giữ.

**Buổi:**

| Buổi | Khung | Tư thế |
|---|---|---|
| Gentle seated stretch 6 | 1:00 seated march + arm swing (cơ ấm trước khi giãn [S9 p.70]) · 4:00 · 1:00 thở | neck turn, chin tuck, chest, twist (nhỏ), thigh (lưng thẳng) hoặc ankle, side |
| Seated stretch 8 | 1:30 · 5:30 · 1:00 | + neck tilt, upper back, shoulder rolls; vòng 2 cho chest, twist, thigh |
| Gentle standing stretch 6 | 1:00 march + heel dig · 4:00 · 1:00 | calf, overhead (wall), side, chest, neck turn |
| Standing stretch 8 | 1:30 · 5:30 · 1:00 | + upper back, twist (ngồi), ankle; vòng 2 cho calf, chest |
| Hạ nhiệt sau đi bộ 2:00–2:30 | — | calf (đứng) hoặc ankle (ngồi) 20 s · thigh (lưng thẳng, ẩn Joint replacement → ankle) 20 s · chest 15 s + 3 hơi thở |
| Morning stretch 6 (Extras) | xem §2.4 | |

**Clip (PROD §2.4 — giữ tư thế là clip "đứng yên thở" lặp, không freeze-frame):**
- **Clip vào tư thế** (10 s, cả hai bên trong một clip với 2–3 s giữ tự nhiên mỗi bên; tư thế một bên: vào – giữ – ra): 12 clip — **A** (app hiện dừng ở khung giữ, task 4.8; đủ cho test prototype).
- **Clip giữ** (8 s, chỉ thở và chớp mắt, Start = End, lặp crossfade): 8 tư thế hai bên × 2 + 4 tư thế một bên × 1 = 20 clip — **B**; chin tuck, shoulder rolls, ankle không cần clip giữ (vận động lặp).
- Tổng **32**.

### 2.4 Short extras — 3 buổi (A) + 2 (B) · 3 clip mới (A)

| Buổi | Khung (STD §5) | Nội dung | Clip |
|---|---|---|---|
| Commercial break walk 5 | = Gentle walk 5, không pha nhanh; bản 3 phút (B): 0:30 · 3 × 0:40 · 0:30 | march · heel dig · shift; ngồi hoặc tại chỗ | dùng clip W |
| Morning stretch 6 | 0:30 ngồi thẳng 3 hơi thở + kiểm chóng mặt · 4:30 · 1:00 sit-to-stand ×3 chậm 2 tay, đứng yên 3 hơi thở | neck turn 5/bên, chin tuck 5, shoulder rolls 5, chest 2 × 10 s, twist nhỏ 5/bên, hip march 10/chân, leg ext 8/chân, ankle pumps 10 + circles 5 | dùng clip S và V; không giữ lâu (cơ chưa ấm [S9 p.70]); không ngửa cổ; không gập trước |
| Balance 6 | 0:45 tư thế + 3 hơi thở + weight shift · 4:45 · 0:30 | sit-to-stand ×5 (2H → 1H) · tandem stance 10 s/chân ×2 · one-leg stand 10 s/chân ×2 (vịn) · sideways walking 10 bước ×2 · heel raises ×8 + toe raises ×8 · (Strong) heel-to-toe walk 5–10 bước vịn tường | **mới:** bl.tandem (giữ), bl.heel-toe-walk (B). Sideways walking: **không có video riêng** (chốt 30/09 — AI bắt chéo chân khi đi ngang), dùng clip W2-2 side step làm hình minh hoạ |
| Wind-down 5 (B) | thở NHS ≥ 3 phút + neck turn, neck tilt, chest 15 s | tối, ngồi tựa lưng | dùng clip S |
| Posture reset 3 (B) | chin tuck · chest · upper back reach · row · overhead wall | không hứa "fix posture" | dùng clip |

Quy tắc thăng bằng: ghế/tường luôn trong tầm tay; tay vịn khai báo từng bài (2H / 1H / NS); người mới không NS ở one-leg stand; **không nhắm mắt** (STD §5.1). Extras là "thêm", không thay buổi chính (CMP §4.9).

### 2.5 Tổng số

| Nhóm | Buổi | Bài / tư thế | Clip A | Clip B | Tổng clip |
|---|---|---|---|---|---|
| Walks | 5 | 8 | 10 (1 có) | 3 | 13 nguồn (26 file) |
| Chair moves | 3 | 12 | 12 (6 có) | 12 | 24 |
| Stretches | 4 + hạ nhiệt | 12 | 12 | 20 | 32 |
| Extras | 3 (+2) | dùng lại + 3 | 2 | 1 | 3 |
| **Tổng** | **15 (+2)** | **35** | **36 (7 có → 29 mới)** | **36** | **72 nguồn** |

Bản dễ của bài ghế (12 clip đợt B) cũng xét dựng từ nguồn khi chỉ khác **tốc độ** (ví dụ sit-to-stand ngồi xuống chậm hơn: time-remap đoạn xuống 1,3×); chỉ tạo clip riêng khi khác **tư thế** (tay đẩy ghế, biên nhỏ hơn).

Credit Flow (PROD §5, 12 credit/lượt 720p, ước 1,5 lượt/clip nhờ không ép nhịp + draft 360p): đợt A ≈ 27 × 1,5 × 12 + draft ≈ **550–650 credit** (Pro 1.000/tháng → 1 tháng); đợt B ≈ 700–800. Ảnh khung 0 credit.

**Dấu ✦ (chốt 30/09/2026, thay quyết định 29/09 "làm lại trên gói không watermark"):** sau khi tạo, agent chạy tool của chủ app `tools/video/crop_avoid_logo.py` rồi guard `tools/video/crop_subject_check.py` và QC từng video (§3). Vị trí ✦ cố định → công thức cố định 1688×950 và ô CROP-SAFE 86% × 82% cho ảnh khung (§3). Đã test 30/09: dấu dò đúng 8/8 clip; crop giữ 77% khung; giật không đổi. Guard trên 7 clip cũ với crop của tool: **V1 FAIL (đầu bị cắt 42 px khi đứng — tool lấy trung vị đầu của khung ngồi), V6 FAIL (giày bị cắt 82 px — người cao 958 px > cửa sổ 950)**; V2–V5, W1-1 v2 PASS (V5 khe chân 23 px, sát). Đầu ra crop là 1688×950 (không phải 1920×1080); scale lên 1080 bằng Lanczos làm nét giảm ~35% → §7 #8b.

---

## 3. Chuẩn kỹ thuật clip (áp cho mọi clip mới)

| Hạng mục | Chuẩn | Nguồn |
|---|---|---|
| Model | Omni 1.1 Flash, Frames, **Start = End cùng một file ảnh**, 720p (draft 360p để thử prompt), 16:9, 8 s cho bài một pha, **10 s** cho bài nhịp (2 chu kỳ × 4 s) và clip giữ | PROD §1–2; video-skill-notes §5g |
| Nhân vật | `@GWCoach` + ảnh khung sửa từ **một ảnh gốc sạch** (tạo mới bằng Nano Banana, không lấy từ khung đã upscale) | PROD §2.5; video-skill-notes §5g |
| Khung máy | Máy tĩnh ngang hông, người ở ~38% chiều ngang, phần ba bên phải trống; đứng cao ~75–80% khung (giữ vùng crop an toàn cho chủ app tự cắt dấu ✦ — không tự crop) | video-skill-notes §5b, §5c, §5f; memory chủ app |
| Góc máy | Chính diện đối xứng: bài ngồi, sit-to-stand, arm raise, row, side step, side leg raise, neck/chest/twist · Nghiêng thuần: leg ext, heel-toe, knee curl, back leg, mini-squat, single-leg, calf, thigh, wall push-up, overhead wall · Khung rộng riêng: sideways walking, tandem, heel-to-toe walk | V-exercise-clips §5·0 |
| Nhịp trong prompt | Chỉ một nhịp tự nhiên, mô tả **đều** chứ không nhanh/chậm: mốc giây `[00:00-00:02]`, "one repetition every 4 seconds, every repetition the same speed and range, the movement fills the whole clip"; đi bộ "one step about every 0.6 seconds… every step the same height and speed". Mục tiêu của prompt là **tư thế đúng + chu kỳ đều**, không phải tốc độ đích | PROD §2.1–2.2; chủ app 30/09 |
| Nhịp khi dựng (kỹ thuật) | Tốc độ đích làm bằng **time-remap có nội suy khung** (`ffmpeg minterpolate` mode `mci`/`mc_mode=aobmc`, hoặc RIFE khi minterpolate nhoè vùng chân): easy 0,85–0,95×, quicker 1,05–1,15×, bản dễ ghế xuống chậm 1,2–1,3×; biên tuyệt đối 0,75×–1,3×; **tua thô không nội suy chỉ ≤ 1,15×**; chọn chu kỳ giữa clip; lặp liền hoặc crossfade 0,3–0,5 s; bỏ tiếng. Lệnh mẫu: PROMPTS §6 | Nguyên tắc 9; PROD §2.4 |
| QA đo được | `qa_measure.py`: đầu ≥ 5%, máy lệch < 2, mối nối ≤ 3× trung vị · `lift_symmetry.py` / `leg_displacement.py`: hai bên lệch thời gian ≤ 10%, độ cao ≤ 25%; **các chu kỳ trong clip nguồn lệch nhau ≤ 10%** (đều thì mới remap được) · **sau remap:** nhịp đo được trong ±5% nhịp đích; max frame-to-frame ≤ 3× trung vị (không giật); không "ghosting" ở chân/tay trên contact sheet 12 fps (nhoè → đổi sang RIFE hoặc giảm hệ số) | video-skill-notes §4 + mới |
| QA bằng mắt | Checklist tư thế STD §8.1 (gối theo mũi chân, không khoá khớp, bàn chân phẳng, gối ≤ hông, không bắt chéo, không gập cột sống, ghế đúng, tay vịn đúng cấp, không nhảy, không nhắm mắt) — chấm PASS/FAIL từng dòng trên contact sheet | STD §8.1 |
| Dấu ✦ — công thức cố định | Omni 1.1 Flash, 1080p Upscaled: ✦ luôn bắt đầu ở x ≥ 1701, y ≥ 862 (8/8 clip đo 30/09; 720p: 1136/576 cùng tỉ lệ) → `crop_avoid_logo.py` luôn cắt **1688×950 tại x=0**, y trượt 0–130 giữ đầu (headroom 24 px) và chân. **Suy ngược cho khung hình (CROP-SAFE):** người + ghế + tầm với xa nhất nằm trong 0–1656 px ngang (≤ 86%) và cao ≤ 890 px (≤ 82%); prompt: đầu cách mép trên ~12%, đế giày cách mép dưới ~12%, người cao ~76% khung. Ảnh khung kiểm bằng `crop_subject_check.py <ảnh>` = PASS **trước khi tốn credit** | chủ app 30/09; PROMPTS §1 |
| Crop dấu ✦ (sau tạo) | `/usr/bin/python3 tools/video/crop_avoid_logo.py <src_1080p> --no-audio` (→ `<src>_16x9_nologo.mp4`); nền khó dò → `--detect-only` rồi `--logo x1,y1,x2,y2`. Rồi **guard** `crop_subject_check.py <src_1080p> --crop W,H,X,Y` (dòng `crop` tool in ra): FAIL = tạo lại ảnh khung, không nới crop. Mọi bước dựng sau đó (loop, retime, ảnh khung tĩnh) làm trên file `_nologo` | chủ app 30/09 |
| QC sau crop (từng video) | (a) dấu đã mất: contact sheet góc dưới phải 300×200 px, 8 khung; (b) guard PASS (khe ≥ 24 px ở mép bị cắt; mép trùng mép khung không cần khe); (c) `qa_measure.py` đầu ≥ 5%, giật/máy như QA nguồn; (d) kích thước 1688×950, ghi vào PROMPTS §9 | test 30/09 |
| Đầu ra | `<ID>_loop.mp4` (720p + `1080/`), `<ID>_flow-source.mp4`, `<ID>_flow-source_1080p_16x9_nologo.mp4`, ảnh khung đầu/cuối PNG (Reduce Motion, thumbnail, VoiceOver), `preview.json`, `<ID>_preview.mp4` (giọng + phụ đề để duyệt) | video-skill-notes §1 |

Đặt tên clip (giữ tương thích file đã có): đi bộ `W1-<n>` (Seated) · `W2-<n>` (In place); ghế `V1…V6` giữ nguyên, mới `V8…V13` (V7 để trống, đã dùng cho giãn cơ trong A10 §6 → đổi giãn cơ sang `S<n>`); giãn cơ `S1…S12`, hậu tố `-hold-L` / `-hold-R` / `-hold`; thăng bằng `B1…B3`; bản dựng từ cùng nguồn: hậu tố `-easy` (chậm) / `-quick` (nhanh); bản khác tư thế: `-alt`. Bảng mã đầy đủ ở PROMPTS §0.

**Sửa app kèm theo:** `WalkVideo.fileName(for:)` hiện chỉ theo cấp → cần thêm tham số động tác + pha (easy/quicker) để chọn file; `exercises.json` thêm `videoEasy` cho bản dễ dựng từ nguồn.

---

## 4. Giọng, nhạc, chuông

### 4.1 Giọng (ElevenLabs)
- Nâng **Creator 1 tháng (~$22, 121k credit)** trước khi tạo hàng loạt: đủ ~600 câu × 1,5 lượt + nhạc + chuông (PROD §5); quyền thương mại từ gói trả phí; giọng Voice Library có giấy phép thương mại, **lưu file gốc + hoá đơn + ảnh trang giọng có ngày** (PROD §3.5).
- Model `eleven_multilingual_v2` (ổn định long-form, có `<break>`, stitching, timestamps đang chạy); v3/v4 chỉ khi cần cảm xúc (PROD §3.1–3.3).
- Cài đặt: stability 0.65 · similarity 0.75 · style 0.1 · speed 0.92 (A/B với 0.88) · speaker boost · seed cố định · `previous_text` = câu trước trong cùng bài (đưa vào hash cache). Chi tiết JSON ở PROMPTS §7.
- Nghe lại 3 ứng viên thư viện (Elise Hart, Jane Hackett, Carol) so với Bella trên gói mới; chọn một giọng, tạo lại **toàn bộ** cache (`assets/voice/cache/` hiện chỉ prototype).
- Quy tắc viết câu (bổ sung A1–A10): ≤ 16 từ/câu; demo trước ("Watch one first"); báo trước 8–10 s; thở ("breathe out as you lift"); talk test thay số; "a gentle pull, never pain"; tên bài + trái/phải cố định; không từ cấm; `copy_lint.py` = 0 findings. Checklist từng câu: STD §8.2.

### 4.2 Kịch bản cần viết/mở rộng
| File | Việc | Số câu ước |
|---|---|---|
| A2 đầy đủ | 3 cấp × 3 cường độ, 3–4 biến thể mỗi khe; câu theo động tác đi bộ (8 động tác × intro/setup/easy/harder); Longer walk 15 | ~150 (đang 67) |
| A4 mở rộng | 6 động tác mới × 8 câu; câu demo/now with me/ten more seconds dùng chung; câu chuyển ngồi ↔ đứng | ~70 (đang ~45) |
| A10 mở rộng | 4 tư thế mới × 4 câu; vòng 2; câu thở NHS | ~20 (đang 55) |
| A11 Extras **(mới)** | Balance (tay vịn 2H/1H, tandem, sideways, heel-to-toe) ~25; Morning ~15; Commercial ~6; Wind-down/Posture (B) ~15 | ~60 |
| A-min-support | đếm rep 1–15, "ten more seconds", "last one", an toàn walking pad, kiểm chóng mặt buổi sáng | +20 |
| D5 | gợi ý màn hình cho 18 bài mới (3 gợi ý + dễ + khó / 2 gợi ý + dễ) | ~90 mục |

### 4.3 Nhạc và chuông
- Eleven Music trên cùng tài khoản: 3 phong cách × 4 bản × 2,5 phút, `force_instrumental`, ghi BPM (feel-good 70s–80s: 92–104 BPM khớp nhịp đi bộ; calm piano 60–66; country 96); intro/outro mềm cùng pad để app crossfade khi lặp; giấy phép self-serve cho phép dùng thương mại trừ film/TV/radio/Studio Games — chụp trang điều khoản có ngày (PROD §4.1). Prompt ở PROMPTS §8.
- Chuông: tổng hợp bằng ffmpeg (2 nốt A5→D6, 0 chi phí, không giấy phép) — lệnh ở PROMPTS §8; SFX chỉ nếu muốn âm singing bowl.
- Trộn: giọng −16 LUFS, nhạc −26 LUFS khi giọng nói (ducking đã có trong player), chuông −18 LUFS; test với người 50+ vì "music drowns out the instructions" là lời chê chung (CMP §4.7).

---

## 5. Quy trình cho agent (mỗi đợt)

1. **Chuẩn bị (0 credit):** đọc PROMPTS §0–1; tạo/kiểm ảnh gốc GWCoach sạch; tạo 6 ảnh khung gốc (MF-01…MF-06, PROMPTS §2) và **chủ app duyệt** trước khi có bất kỳ video nào.
2. **Báo giá và giới hạn:** liệt kê clip của đợt, credit dự kiến (12/lượt, tối đa 3 lượt/clip), xin OK.
3. **Thử 1 clip mỗi kiểu chuyển động** (nhịp đi bộ, rep sức mạnh, vào tư thế, giữ, đi ngang) ở 360p → 720p; chạy QA; **dựng thử cả hai bản remap (easy/quicker) từ clip đi bộ mẫu** và so với bản nguồn trên contact sheet; gửi contact sheet + preview có giọng tạm; **chủ app duyệt kiểu rồi mới nhân rộng**.
4. **Sản xuất theo góc máy** (hết chính diện ngồi → chính diện đứng sau ghế → nghiêng ngồi → nghiêng đứng → tường → khung rộng) để giữ ánh sáng và ghế đồng nhất; mỗi clip: tạo → tải 720p + 1080p Upscaled → `contact_sheet.sh` + `qa_measure.py` (+ `lift_symmetry.py` / `leg_displacement.py`) → chấm checklist STD §8.1 → đạt thì `build_loop.py` (chọn chu kỳ) → `retime` (PROMPTS §6, chỉ khi cần bản nhịp khác) → QA lại bản remap → ảnh khung PNG → `preview.json` + `build_preview.py`.
5. **Ghi kết quả** vào bảng clip trong PROMPTS §9 (lượt, credit, số đo, ghi chú lệch kịch bản); không sửa kịch bản để hợp với clip lỗi — ghi lại cho người duyệt.
6. **Giọng:** sau khi kịch bản được duyệt và gói Creator đã mua: `tools/voice/render_lines.py` với cài đặt PROMPTS §7, chuẩn hoá −16 LUFS, xuất phụ đề từ kịch bản; `ReleaseContentTests` xanh là điều kiện đóng gói.
7. **Cập nhật nội dung app:** `exercises.json` (bài mới với `source`, `hiddenFor`, `videoFile`), `sessions.json` qua `build_content.py` (thêm template Walk 15, Balance, Morning, hạ nhiệt mới), kiểm bằng quy tắc STD §7 (không brisk trước 2:00 warm-up; Seated không brisk; rep 6–12; giữ ≤ 30 s; cool-down ≥ 1:00/2:00) — thêm test `ContentValidator` cho 6 quy tắc này.

---

## 6. Thứ tự và mốc

| Mốc | Việc | Đầu ra | Điều kiện qua |
|---|---|---|---|
| M1 · Chốt (chủ app) | Duyệt kế hoạch này + câu hỏi cuối file; duyệt lại 6 clip V1–V6 theo STD §8.1 | quyết định ghi vào app-context decisions log | OK |
| M2 · Khung (0 credit) | Ảnh gốc GWCoach sạch; MF-01…MF-06; ảnh khung cho đợt A | **xong 30/09: master + 7 khung gốc, PASS guard** (`assets/video/frames/`, PROMPTS §2); MF-04 để đợt B; 30/09 chiều thêm luật tâm ngang 28–48% → MF-03c, MF-04c, MF-05c (tường), MF-05c tay áp tường dời trái bằng `recenter_frame.py` (0 credit) | chủ app duyệt `M2-frames-sheet.jpg` |
| M3 · Mẫu 5 kiểu | W2-1 march (nguồn + 2 bản remap) · V8 side leg raise (+ bản `-easy` remap xuống chậm) · S5 chest (vào tư thế) · S5-hold · B2 sideways walking; thêm script `tools/video/retime.py` (minterpolate/RIFE + QA) | 5 clip + 3 bản remap + QA + preview — **xong 30/09 (180 credit)**: V5 (lượt 2), W2-1 + easy/quick, V8, S5, S5-hold đạt; B2 bỏ (chốt a) | chủ app duyệt kiểu chuyển động và chất lượng remap |
| M4 · Kịch bản | A2 đầy đủ, A4 mở rộng, A10 mở rộng, A11, D5; `copy_lint.py` 0 findings | file trong `docs/scripts/` — **đang viết 30/09** | chủ app đọc duyệt |
| M5 · Đợt A clip | 29 clip nguồn mới + các bản remap (mục 2.5) | `assets/video/`, bảng kết quả | QA đo (nguồn và remap) + checklist PASS |
| M6 · Giọng + nhạc + chuông | Creator; chọn giọng; tạo lại toàn bộ; 12 bản nhạc; 3 chuông | `assets/voice/`, `assets/music/` | nghe thử 2 buổi trọn với người 50+ |
| M7 · Tích hợp | `exercises.json`, `sessions.json`, template mới, test ContentValidator, ảnh khung tĩnh, All sessions hiện Video badge đúng | test xanh, chụp màn 4 nhóm | test prototype (docs/research/prototype-test-plan.md) |
| M8 · Đợt B | 40 clip còn lại; Wind-down, Posture reset, Longer walk 15 | | sau ra mắt hoặc khi có gói không watermark |

---

## 7. Câu hỏi — đã chốt 30/09/2026 (chi tiết trong app-context decisions log)

| # | Câu hỏi | Chốt |
|---|---|---|
| 1 | Số lượng và đợt | Theo đề xuất; đợt A 27 clip mới (bỏ W1-6 seated weight shift và W2-4 heel dig đứng khỏi A) |
| 1b | Công cụ remap | `minterpolate` trước, RIFE dự phòng khi nhoè > 1,1×; biên 0,75–1,3× |
| 2 | Giữ giãn cơ | 15/20/30 s ×1; vòng 2 cho 3 tư thế trọng tâm (calf/thigh, chest, twist) chỉ ở Steady và Strong |
| 3 | Seated "brisk" | Đổi nhãn pha nhanh ở cấp Seated thành "QUICKER" (giọng "a little quicker"); In place/Pad giữ BRISK. Việc: String Catalog + spec S11 |
| 4 | Clip giữ | Ra mắt với khung giữ (hiện có); clip "đứng yên thở" làm ở đợt B chỉ nếu test prototype chê hình "chết" |
| 5 | Ghế | Mặc định không tay vịn; biến thể Joint replacement cho phép ghế cao có tay vịn, một câu setup riêng ("a higher chair, with arms if you have one") |
| 6 | Loãng xương | Gộp vào chip "Lower back", mô tả thêm "or bone thinning"; không thêm chip riêng |
| 7 | Walking pad | Màn xác nhận một lần trước buổi Pad đầu: "I can hold on" / "Use In place today" |
| 8 | Dấu ✦ | Quy trình của chủ app: tạo → `crop_avoid_logo.py` → QC từng video (§3). Đã test 2 clip. Không còn phụ thuộc gói Ultra |
| 8b | Kích thước sau crop | **Chốt 30/09: giữ 1688×950**, app scale khi phát; không Lanczos lên 1080 (nét giảm 1591 → 1022) |
| 8c | 6 clip cũ V1–V6 | **Chốt 30/09: tạo lại V1 và V6** trong đợt A với ảnh khung CROP-SAFE (+2 clip, ~30 credit). **Phát hiện thêm 30/09 chiều (guard bản cuối):** V5 cũng không vừa — đế giày ở hàng ~1057/1080, người ~960 px > cửa sổ 950 (các lần đo trước bỏ sót giày). Đề xuất tạo lại cả V5 (+1 clip, ~15 credit) — **chờ chủ app OK**. V2–V4, W1-1 v2 đạt |
| 9 | HLV duyệt | Pending |
