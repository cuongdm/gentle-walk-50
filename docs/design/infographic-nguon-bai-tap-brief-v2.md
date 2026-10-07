# Brief infographic v2: "Bài tập của Good Footing lấy từ đâu"

_06/10/2026 · Thay bản v1 cùng ngày · Cho designer vẽ bản demo · Đã kiểm từng số với nguồn gốc: `docs/reviews/2026-10-06-chuyen-gia-ra-soat-bai-tap-58-75.md` (Phần 1) · Số liệu app lấy từ `iOS/App/Resources/Content/sessions.json`, `exercises.json`_

## Thay đổi so với v1

- Số động tác theo đúng app: Walk **8** (không phải 10), Chair moves **12** (không 15), Stretch **12** (không 17), Balance **6** (+1 sắp có). Tên bài đúng tên trên thẻ trong app.
- Liều giãn cơ: "giữ 20–30 giây, 2 vòng cho tư thế chính" (thay "15–30 giây, lặp 2–3 lần"). Đã chốt 06/10: Gentle 20 s, Steady và Strong 30 s; xem bảng mục 12.
- Thăng bằng: "Steady set 2 phút sau mỗi buổi" thay "buổi 5–6 phút, 3 ngày/tuần" (bài Balance thật dài 6–7 phút sau khi cắt; hiện 8:40).
- Thang vịn chỉ 3 bậc: hai tay → một tay → đầu ngón tay. Bậc "không vịn" để sau, ghi chú.
- Nguồn 1 đổi tên: "NIA, Exercise & Physical Activity" (Go4Life là tên cũ, trang đã đóng).
- Nguồn 5 (World Falls Guidelines) thêm "≥12 tuần" và "đi bộ đơn thuần không đủ".
- Câu dừng dùng đúng câu trong app (a7.stop.1/.2).
- Khối "Sắp thêm": bỏ chữ "65+"; thay danh sách bằng 4 bài thật sự chưa có.
- Chân trang: thêm dòng "Not affiliated with or endorsed by…"; thêm SSS 2022, OARSI 2019, Walk With Ease, AAOS OrthoInfo.
- Bỏ câu "Số liệu giữ nguyên như brief" trong checklist; thay bằng bảng số liệu ở mục 12.

## 0. Mục đích và người xem

- **Mục đích:** một trang cho thấy mọi bài trong app lấy từ hướng dẫn y tế công khai: bài nào từ nguồn nào, tập bao nhiêu, an toàn ra sao.
- **Người xem:** nội bộ trước (chủ app, designer, người viết kịch bản, người duyệt), sau có thể dùng cho web hoặc bài giới thiệu. Vì có thể công khai, mọi chữ đã qua luật copy của app-context (không "senior/elderly", không hứa chống ngã hay hết đau, không ngụ ý được tổ chức nào chứng thực).
- **Định dạng:** một tấm **dọc A3 (297 × 420 mm)** hoặc **cuộn dọc 1080 × 4000 px**, 8 khối (mục 2 → 9). Slide 16:9 nếu cần: khối 2 + 3 · khối 4 · khối 5 + 6 · khối 7 + 8 + 9.
- **Ngôn ngữ:** tên động tác **tiếng Anh đúng như trong app**, mô tả tiếng Việt. Bản web sau này toàn tiếng Anh.

## 1. Phong cách (bảng màu "Pigment" của app)

| Vai trò | Màu | Hex |
|---|---|---|
| Nền giấy | paper | `#F8F1E6` |
| Thẻ | surface | `#FFFCF6` |
| Chữ chính | ink | `#2A241F` |
| Chữ phụ | textMuted | `#655A50` |
| Màu chính, tiêu đề khối | Hooker green | `#2E4A33` |
| Nhóm Walk | sap green | `#5E7F3A` |
| Nhóm Chair moves | ochre | `#D9A441` |
| Nhóm Stretch | sky | `#7FA3C0` |
| Nhóm Balance, cảnh báo nhẹ | sienna | `#A9512C` |

- **Chữ:** tiêu đề serif (New York; thay bằng Source Serif hoặc Lora); nội dung sans tròn (SF Pro Rounded; thay bằng Nunito); nội dung ≥ 11 pt khi in A3. Không chữ trắng trên sky hoặc ochre.
- **Hình:** một phụ nữ khoảng **60–65 tuổi**, tóc muối tiêu ngang vai, kính, áo xanh sage dài, legging xám than, dáng đầy đặn (HLV trong app). Nét gouache/màu nước, **không 3D, không ảnh chụp**. Mỗi động tác một hình nhỏ, có ghế khi bài dùng ghế; bài đứng luôn vẽ tay trên ghế hoặc mặt bếp.
- **Icon nền:** vệt màu nước không đều (như `WashShape`), không vòng tròn hoàn hảo.
- **Cấm:** chữ "senior", "elderly", "anti-aging", "fall prevention"; hình trước/sau, cân nặng, calo; hứa chống ngã hay chữa đau; logo của tổ chức nào (chỉ tên bằng chữ trong dòng nguồn); chữ "approved", "endorsed", "certified" cạnh tên tổ chức; không đặt tên tổ chức vào tiêu đề hay tên nhóm bài.

## 2. Khối mở đầu (header)

- **Tiêu đề:** "Every move has a public source" (bản Việt: "Mỗi động tác đều có nguồn công khai").
- **Dòng phụ:** "Good Footing · walk, chair moves, stretch, balance · built from public health guidance".
- **Ba con số** (3 ô ngang): `5` bộ hướng dẫn công · `4` nhóm bài: Walk · Chair moves · Stretch · Balance · `0` bài phải xuống sàn.
- **Hình:** HLV đứng cạnh ghế, một tay đặt trên lưng ghế, vẫy tay kia.

## 3. Khối 5 nguồn (5 thẻ ngang)

Mỗi thẻ: tên nguồn · tổ chức, năm · vai trò (in đậm) · 3–4 gạch ý · chip "Dùng cho …".

| # | Tên nguồn | Tổ chức, năm | Vai trò | Nội dung chính | Dùng cho |
|---|---|---|---|---|---|
| 1 | **Exercise & Physical Activity** (Your Everyday Guide, Workout to Go; trước đây gọi là Go4Life) | NIA, Viện Lão hoá Quốc gia Mỹ (NIH) | **Thư viện động tác** | Aerobic, sức mạnh, thăng bằng, giãn cơ · hướng dẫn từng bước, cách thở · "khoảng 3 buổi thăng bằng mỗi tuần" · khi nào dừng | Chair moves, Stretch, Balance |
| 2 | **Physical Activity Guidelines for Americans**, bản 2 | HHS, Bộ Y tế Mỹ, 2018 | **Liều tập mỗi tuần** | 150–300 phút cường độ vừa · sức mạnh ≥ 2 ngày · với người lớn tuổi: thêm thăng bằng, làm theo sức mình · "start low, go slow" · "có tập vẫn hơn không" | Lịch tuần, cường độ |
| 3 | **Otago Exercise Programme** + **STEADI** | ACC và Đại học Otago (NZ); bản Mỹ: UNC 2024 · CDC Mỹ | **Thăng bằng có bậc tăng dần** | 5 bài sức mạnh chân · 12 bài thăng bằng · vịn → vịn nhẹ → (sau này) không vịn · nhịp chậm 2–3 s lên, 4–5 s xuống · Chair Rise, test thăng bằng 4 mức | Balance, Chair moves |
| 4 | **Sitting · Strength · Balance · Flexibility exercises** | NHS Live Well (nhs.uk), Anh, 2023–2024 | **Câu ngắn, dễ nghe** | Bài ngồi, sức mạnh, thăng bằng, giãn; mỗi bài 3–5 câu · "ít nhất 2 lần mỗi tuần" · ghế chắc, không bánh xe | Walk ngồi, Chair moves, Stretch |
| 5 | **World Guidelines for Falls Prevention and Management for Older Adults** | Montero-Odasso và cộng sự, *Age and Ageing*, 2022 (96 chuyên gia, 39 nước) | **Chuẩn mới nhất để kiểm lại** | Thăng bằng và bài chức năng (ngồi–đứng, bước) · ≥ 3 buổi/tuần, tăng dần, ≥ 12 tuần · cộng tai chi hoặc sức mạnh khi làm được · đi bộ đơn thuần không đủ | Kiểm liều và tần suất |

**Hình gợi ý:** mũi tên mảnh từ 5 thẻ chụm vào khối 4 rồi toả ra 4 nhóm bài, như sông nhánh.

**Chú thích nhỏ dưới khối:** "Khi người dùng chọn giới hạn cơ thể, app lọc thêm theo: Strong, Steady and Straight 2022 (xương thưa), OARSI 2019 và Walk With Ease của Arthritis Foundation (khớp gối, hông), AAOS OrthoInfo (đã thay khớp)."

## 4. Khối "Một tuần tập" (liều, từ nguồn 2, 3, 5)

Vẽ **lịch 7 ô** (T2 → CN), chấm màu theo nhóm bài; 2 ô nghỉ (T7, CN) để trống có chữ "Rest".

| Thành phần | Liều theo nguồn | App làm thế nào |
|---|---|---|
| 🟢 Walk (aerobic) | 150 phút/tuần cường độ vừa, chia nhiều ngày; "có tập vẫn hơn không" | Buổi 5–15 phút (thẻ ghi số phút thật); đi bộ là bài mặc định |
| 🟡 Chair moves (sức mạnh) | ≥ 2 ngày/tuần, các nhóm cơ lớn, 8–12 lần mỗi bài; Otago 3 lần/tuần cách ngày | 3 ngày/tuần có bài sức mạnh: một ngày ghế, hai ngày đi bộ kèm 1–2 bài |
| 🔴 Balance (thăng bằng) | Khoảng 3 buổi/tuần (NIA); ≥ 3 (WHO, World Falls Guidelines) | Steady set 2 phút sau mỗi buổi, miễn phí (≥ 3 ngày/tuần) + bài Balance 6–7 phút (Pro) *(đã chốt 06/10)* |
| 🔵 Stretch (giãn cơ) | ≥ 2–3 ngày/tuần, khi cơ đã ấm | Buổi 7–12 phút, hoặc 3 phút hạ nhiệt sau Walk |

**Hai ô nhỏ bên cạnh:**
- **"Talk test":** hai bong bóng thoại. "Vừa sức = nói được, không hát được."
- **"Start low, go slow":** 3 bậc thang thấp "Gentle → Steady → Strong" (3 cường độ của app, chọn theo check-in Achy / Okay / Great). Chú thích: "Làm theo sức mình hôm nay, không theo bảng."

## 5. Khối Walk: đi bộ trong nhà (màu sap `#5E7F3A`)

**Thanh 4 cấp** (4 bậc, người ở mỗi bậc): `Seated` (ngồi ghế) → `In place` (đứng tại chỗ, ghế trong tầm tay) → `Walking pad` (máy đi bộ, có tay vịn hoặc bàn để vịn) → `Outdoors` (ngoài trời).

**8 động tác** (lưới 4 × 2, mỗi ô: hình nhỏ + tên + 1 dòng + dấu ✓ bản ngồi — **cả 8 đều có bản ngồi**):

| # | Tên (đúng app) | Mô tả 1 dòng | Nguồn |
|---|---|---|---|
| 1 | March | Đi tại chỗ, nhấc chân đặt xuống nhẹ, tay vung tự nhiên | Otago, NHS |
| 2 | Heel dig | Gót chạm trước, mũi chân kéo lên, thân thẳng | Otago, NHS |
| 3 | Side step | Bước sang bên rồi khép, gối mềm, hông ngang | NHS, Otago |
| 4 | Knee lift | Nhấc gối, đùi không cao quá hông | AAOS OrthoInfo |
| 5 | Toe tap forward | Chạm mũi chân ra trước, gối trụ mềm, không khoá gối | NIA (không khoá khớp); mô tả của app |
| 6 | Heel to back | Gót kéo về phía mông, vịn ghế | Otago, NIA |
| 7 | Weight shift | Dồn trọng tâm sang từng bên, gối theo mũi chân | Mô tả của app; cue gối theo NHS |
| 8 | Arm swing / press | Vung tay đối chân, hoặc đẩy ra trước ngang vai | Otago (walking tips) |

**Hình phụ: cấu trúc buổi Strong walk 10**, thanh ngang 3 đoạn: `Warm-up 2:00 (chậm)` → `Chính 6:00 (6 khối × 1 phút, 30 s easy / 30 s brisk)` → `Cool-down ~3:00 (đi chậm + calf + chest)`.

**Ghi chú dưới:** "Không nhảy · ghế luôn trong tầm tay · Seated chỉ 'quicker', không 'brisk' · brisk = vẫn nói được."

## 6. Khối Chair moves: động tác với ghế (màu ochre `#D9A441`)

**Hình đầu khối, "Ghế đúng":** ghế chắc, không bánh xe, không ghế bành · cao khoảng 43 cm (17 in) · ngồi phía trước mặt ghế, bàn chân phẳng, gối vuông góc · khi vịn để đứng: lưng ghế sát tường hoặc mặt bếp. (NHS; STEADI 30-Second Chair Stand; Otago)

**12 động tác** (lưới 4 × 3, mỗi ô: hình + tên + ngồi/đứng vịn + liều gốc):

| # | Tên (đúng app) | Tư thế | Mô tả | Liều gốc | Nguồn |
|---|---|---|---|---|---|
| C1 | Sit-to-stand | ngồi ↔ đứng | Nghiêng từ hông, đứng lên, ngồi xuống chậm; tay đẩy ghế nếu cần | 10–15 lần, nghỉ 1 phút (STEADI); 5 lần hai tay → 10 lần (Otago) | STEADI, NIA, NHS, Otago |
| C2 | Seated knee lift | ngồi | Nhấc gối luân phiên, đặt xuống có kiểm soát | theo thời gian; NHS 5 mỗi chân | NHS |
| C3 | Seated leg extension | ngồi | Duỗi thẳng một chân, mũi chân kéo về, giữ 1 giây | 10–15 mỗi chân | NIA, Otago |
| C4 | Heel and toe raises | ngồi; đứng vịn khi khoẻ hơn | Kiễng gót rồi nhấc mũi chân, chậm | 10–15 (NIA); 10 (Otago) | NIA, NHS, Otago |
| C5 | Wall push-up | đứng, tường | Chống đẩy vào tường, thân thẳng | 10–15 | NIA, NHS |
| C6 | Single-leg stand | đứng vịn | Đứng một chân tới 10 giây, mắt nhìn một điểm | 10 giây mỗi chân (NIA, Otago); 5–10 s × 3 (NHS) | NIA, Otago, NHS |
| C7 | Side leg raise | đứng vịn | Nhấc chân sang bên, mũi chân hướng trước | 10–15 mỗi chân | NIA, NHS, Otago |
| C8 | Back leg raise | đứng vịn | Đưa chân thẳng ra sau, không ngả người | 10–15 mỗi chân | NIA, NHS |
| C9 | Knee curl | đứng vịn | Gập gối đưa gót về mông | 10–15 mỗi chân | NIA, Otago |
| C10 | Mini-squat | đứng, 2 tay lưng ghế | Khuỵu nửa chừng, gối hướng mũi chân, dừng khi gót nhấc | 5 (NHS); 10 (Otago) | NHS, Otago |
| C11 | Arm raises | ngồi | Nâng tay ra trước, sang ngang (không tạ) | 10–15 | NIA |
| C12 | Seated row | ngồi | Kéo khuỷu tay ra sau, ép bả vai | 10–15 | NIA |

**Chú thích liều:** "App: 6–8 lần (Gentle) · 8–10 (Steady) · 10–12 (Strong); Sit-to-stand ở Strong 2 lượt, nghỉ 60 giây; nhịp 2–3 giây lên, 1 giây giữ, 3–4 giây xuống." *(đã chốt 06/10)*

**Ba nhãn bên lề:** "Breathe out as you lift" · "Never lock your knees" · "Hands on the chair, then stand".

## 7. Khối Stretch: giãn cơ nhẹ (màu sky `#7FA3C0`)

**Câu chủ đề:** "Stretch to a gentle pull, never to pain".

**Đồng hồ nhỏ:** "Giữ 20–30 giây · 2 vòng cho tư thế chính · không nhún · thở đều." *(đã chốt 06/10: Gentle 20 s × 2 cho 3 tư thế chính, 20 s × 1 còn lại; Steady 30 s × 2 cho 3 tư thế chính; Strong 30 s × 2, ít tư thế hơn để buổi ≤ 12 phút)*

**12 tư thế** (hình người chia vùng, số chỉ tới từng vùng):

| Vùng | Tư thế (đúng app) |
|---|---|
| Cổ | Neck turn · Side of the neck · Chin tuck |
| Vai, ngực, lưng trên | Shoulder rolls · Chest and shoulders · Upper back reach · Overhead reach at the wall |
| Thân | Upper back twist (xoay chậm, biên vừa) · Side stretch |
| Chân | Back of the thigh (lưng thẳng; ẩn khi đã thay khớp) · Calf stretch (vịn ghế) |
| Cổ chân | Ankle circles and points |
| Kết thúc | Thở: hít mũi đếm 5, thở miệng đếm 5 (NHS) — không phải tư thế, vẽ nhỏ |

**Hai mẫu buổi** (2 thanh ngang, không ghi giây từng bài):
- **Seated stretch, Gentle (~9 phút):** 1:00 đi tại chỗ ngồi → Neck turn · Chin tuck · Chest and shoulders · Upper back twist · Back of the thigh (hoặc Ankle) · Side stretch → 1:00 thở.
- **Standing stretch, Gentle (~7 phút):** 1:00 đi tại chỗ → Calf stretch · Overhead reach at the wall · Side stretch · Chest and shoulders · Neck turn → 1:00 thở.

## 8. Khối Balance: thăng bằng (màu sienna `#A9512C`)

**Thang vịn**, 3 bàn tay trên lưng ghế, mờ dần: `hai tay` → `một tay` → `đầu ngón tay`. Chú thích: "Chỉ lên bậc khi thấy vững hai buổi liền. Không nhắm mắt. Bậc không vịn: để sau nhiều tuần." (Otago: vịn → không vịn; NIA: tới một ngón tay.)

**Steady set 2 phút** (ô nhỏ, vẽ sau Walk; ghi "Free"): Tandem stance 10 s mỗi chân × 2 → Sit-to-stand × 5 (hai tay) hoặc Single-leg stand 10 s mỗi chân × 2, vịn. Bản miễn phí: Gentle, hai tay. *(đã chốt 06/10)*

**Buổi Balance (~6–7 phút)**, dòng thời gian 6 mốc:

| Thứ tự | Bài (đúng app) | Liều | Nguồn |
|---|---|---|---|
| 1 | Đứng thẳng, 3 hơi thở, Weight shift | vịn ghế | Otago (standing posture) |
| 2 | Sit-to-stand | 5 lần (hai tay → một tay) | Otago mức A/B; STEADI |
| 3 | Tandem stance | 10 giây mỗi chân × 2 | Otago; STEADI mức 3 |
| 4 | Single-leg stand | 10 giây mỗi chân × 2, vịn | Otago, NIA, NHS |
| 5 | Sideways walking | 10 bước mỗi hướng × 2, dọc mặt bếp | Otago, NHS |
| 6 | Heel and toe raises | 8 + 8, đứng vịn | Otago, NIA |
| (Strong, sắp có) | Heel-to-toe walk | 5–10 bước, ngón tay chạm tường | NHS, NIA, Otago |

## 9. Khối An toàn và "Sắp thêm"

**9a. Khi nào dừng** (hộp viền sienna, icon bàn tay giơ): dừng, nghỉ, gọi bác sĩ nếu không hết:
- Đau hoặc tức ngực, đau lan cổ, vai, tay, hàm
- Chóng mặt, choáng, buồn nôn
- Khó thở tới mức không nói được
- Tim đập không đều
- Toát mồ hôi lạnh
- Đau khớp hoặc chuột rút dữ dội

(NIA Everyday Guide; MedlinePlus)

Câu trong app (đúng chữ): *"If you feel sharp pain, chest pain, or dizziness, stop and rest."* · *"If it keeps happening, talk to your doctor."* Màn Before you start: *"Chest pain, feeling faint or very short of breath? Stop now and call emergency services."*

**9b. App lọc bài theo cơ thể** (6 chip, mỗi chip một dòng):

| Giới hạn | App làm gì | Nguồn |
|---|---|---|
| Joint replacement | Gối không cao quá hông · không bắt chéo chân · ẩn Back of the thigh · ghế cao, có tay vịn nếu có | AAOS OrthoInfo |
| Knees | Không khuỵu sâu, không lunge, không nhảy · Mini-squat nửa chừng · "tập có cấu trúc là điều trị lõi" | Cleveland Clinic; OARSI 2019 |
| Lower back (or bone thinning) | Không gập sâu về trước lặp lại · xoay chậm biên vừa · ưu tiên duỗi lưng, sức mạnh, thăng bằng · "how to", không "don't" | Strong, Steady and Straight 2022; IOF |
| Shoulders | Tay giữ dưới ngang vai, trong biên không đau | NHS Scotland |
| I get dizzy easily | Hai tay ở mọi bài thăng bằng · không quay nhanh · đứng dậy chậm, dừng một hơi thở | World Falls Guidelines (hạ huyết áp tư thế); NHS |
| I feel unsteady on my feet | "Both hands on the chair" ở mọi bài thăng bằng · bỏ Heel-to-toe walk · đi bộ bắt đầu ngồi · lọc trên máy, không lưu tiền sử *(đã chốt 06/10)* | World Falls Guidelines (câu hỏi "thấy không vững") |

**9c. Sắp thêm** (4 ô viền đứt nét, chữ "Coming next", không ghi tuổi):
- Walking backwards, tay trượt dọc mặt bếp (Otago)
- Walk and turn: đi vài bước, quay chậm, về (Otago)
- Heel walking / Toe walking, vịn mặt bếp (Otago)
- Standing back extension: tay chống hông, ngả nhẹ ra sau (Otago warm-up; Strong, Steady and Straight)

## 10. Chân trang

- **Dòng nguồn (chữ nhỏ):** "Sources: NIA, Exercise & Physical Activity (nia.nih.gov) · HHS, Physical Activity Guidelines for Americans, 2nd ed. (2018) · Otago Exercise Programme (ACC / University of Otago; UNC guide 2024) · CDC STEADI · NHS Live Well (nhs.uk) · Montero-Odasso et al., World Guidelines for Falls Prevention and Management for Older Adults, Age and Ageing 2022 · Brooke-Wavell et al., Strong, Steady and Straight, BJSM 2022 · OARSI Guidelines 2019 · Arthritis Foundation, Walk With Ease · AAOS OrthoInfo."
- **Miễn trừ (chữ nhỏ):** "Good Footing is for general fitness. It does not diagnose or treat any condition. Talk to your doctor if you have a health condition. Good Footing is not affiliated with or endorsed by any organisation named above."
- **Tên app:** Good Footing (chốt 07/10/2026; "Gentle Walk" là tên làm việc cũ). Luật sư nhãn hiệu xem tên app và dòng nguồn cùng lúc.

## 11. Danh sách kiểm tra cho designer

- [ ] Đủ 8 khối đúng thứ tự: header → 5 nguồn → tuần → Walk → Chair → Stretch → Balance → An toàn.
- [ ] Mỗi nhóm đúng màu; không chữ trắng trên sky hoặc ochre.
- [ ] Người minh hoạ 60–65 tuổi, một nhân vật xuyên suốt; mọi bài đứng có tay trên ghế hoặc mặt bếp.
- [ ] Không hình nằm sàn, nhảy, tạ, thảm; không nhắm mắt.
- [ ] Không "senior", "elderly", "fall prevention", calo, cân nặng, hứa chữa; không logo tổ chức; không "approved/endorsed".
- [ ] Tên động tác đúng chữ mục 5–8 (đúng app); số liệu đúng mục 12; muốn rút gọn thì hỏi lại.
- [ ] Bản demo đầu: phác thảo trắng đen 8 khối, chốt rồi mới tô màu.

## 12. Bảng số liệu (một nguồn sự thật cho designer)

| Mục | Số in trên tấm | Trạng thái |
|---|---|---|
| Aerobic tuần | 150–300 phút cường độ vừa | nguồn, đã kiểm |
| Sức mạnh | ≥ 2 ngày/tuần; 8–12 lần/bài; app 3 ngày có bài sức mạnh | đã kiểm |
| Thăng bằng | khoảng 3 buổi/tuần; app: Steady set 2 phút sau mỗi buổi, miễn phí (Gentle, hai tay); Balance Extra và thang vịn là Pro | **đã chốt 06/10** (Q2) |
| Giãn cơ | giữ 20–30 giây, 2 vòng tư thế chính: Gentle 20 s × 2 (3 tư thế chính), 20 s × 1 còn lại · Steady 30 s × 2 (3 tư thế chính) · Strong 30 s × 2, ít tư thế hơn | **đã chốt 06/10** (Q4) |
| Rep ghế trong app | Gentle 6–8 · Steady 8–10 · Strong 10–12; Sit-to-stand Strong 2 lượt, nghỉ 60 s | **đã chốt 06/10** |
| Nhịp rep | 2–3 s lên · 1 s giữ · 3–4 s xuống | đã kiểm |
| Ghế | ~43 cm (17 in), không bánh xe | đã kiểm |
| Số bài | Walk 8 · Chair 12 · Stretch 12 · Balance 6 (+1) | đã kiểm (exercises.json 06/10) |
| Buổi Walk | 5–15 phút trên thẻ | đã kiểm (dài nhất 18 phút, thẻ ghi số thật) |
| Buổi Balance | 6–7 phút (Pro) | **đã chốt 06/10** (app đang 8:40, sẽ cắt) |
| Buổi Stretch | 7–12 phút | **đã chốt 06/10** (Q6: Steady/Strong bỏ vòng 2 của Side of the neck và Shoulder rolls; Strong bỏ Upper back reach khi Chest and shoulders đã 2 lần. App đang tới 18 phút, sẽ cắt) |
| Thang vịn | hai tay → một tay → đầu ngón tay | đã kiểm (A11 §2.2) |

Mọi số trong bảng đã chốt 06/10/2026 (`docs/reviews/2026-10-06-chuyen-gia-ra-soat-bai-tap-58-75.md`, Phần 5). In số đã chốt; app đang được sửa theo cùng số này.
