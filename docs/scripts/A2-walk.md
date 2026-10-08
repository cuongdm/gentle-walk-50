# A2 — Dẫn đi bộ, bản đầy đủ · bản nháp 1
_30/09/2026 · Milestone M4 của [kế hoạch nội dung 4 nhóm](../plans/2026-09-30-content-4-groups.md) (§1 10 nguyên tắc, §2.1 Walks, §2.4 Commercial break, §4.1–§4.2) · Chuẩn: [STD](../research/2026-09-30-exercise-standards.md) §1–§2, §4.3, §7, §8.2 · Điểm đau người dùng: [CMP](../research/2026-09-30-competitor-4-groups.md) §3–§4 · Quy tắc chữ: [app-context.md](../../app-context.md) (Tone & copy rules) · Thay [A2-walk-min.md](A2-walk-min.md) (giữ mọi ID cũ) · Chữ thoại tiếng Anh Mỹ, ghi chú tiếng Việt_

## 1. Phạm vi
- Đủ để app dựng **5 buổi đi bộ** của plan §2.1: Gentle walk 5 · Steady walk 8 · Strong walk 10 · Longer walk 15 (đợt B) · Commercial break walk 5 (Extras, §2.4); ở 3 cấp Seated · In place · Walking pad. **Outdoors dùng bộ A3** trong [A-min-support.md](A-min-support.md), không dùng file này.
- 8 động tác `wk.*` với tên đúng cột "Tên" của plan và dòng D5 trong [D-min-texts.md](D-min-texts.md): March · Heel dig · Side step · Knee lift · Toe tap forward · Heel to back · Weight shift · Arm swing / press.
- Dùng lại theo ID, không viết lại: A1 (`a1.02`–`a1.28`), A5 đếm (gồm `a5.10s.change`), A6 động viên, A7 Break / This hurts / câu dừng `a7.stop.*` / an toàn Walking pad `a7.pad.*` (A-min-support, bổ sung 30/09), A9 chuyển bài và check-in, câu dùng chung của A4 (`a4.demo.*`, `a4.with-me.*`, `a4.pain.*` trong [A4-chair-moves.md](A4-chair-moves.md)), A10 giãn cơ hạ nhiệt (`a10.*`). Danh sách ở §5.
- Giọng như A1: nữ 58–65, trầm ấm, khoảng 130 từ/phút (ElevenLabs speed 0,92), mỗi câu ≤ 16 từ, im 2–4 giây sau câu. Không gọi tên người dùng. Phụ đề = đúng chữ. "…" = nghỉ khoảng 2 giây.

## 2. Nguyên tắc đã áp (plan §1, STD §8.2)
| Nguyên tắc | Cách làm trong file này |
|---|---|
| 1 · Demo trước | Mỗi khối động tác: `intro` (tên) → `a4.demo.*` ("Watch one first.", dùng chung với A4) → `a2.move.<m>.demo` (câu tự mô tả đủ một lần làm, nên người chỉ nghe cũng làm được; clip chạy bản easy) → `a4.with-me.*` / `a2.now.*` ("Now with me"). |
| 2 · Báo trước 8–10 s | `a2.move.<m>.next` ("Ten more seconds. Next up: …") ở −0:10 trước mỗi lần đổi động tác (dự phòng: `a5.10s.change`); `a2.soon.*` / `a2.round.*` ở −0:10 trước pha quicker; `a2.brisk.end.*` trước khi thả lỏng. |
| 3 · Khởi động chậm thật | Buổi 5 phút **không có pha quicker**; buổi 8/10 phút: 2:00 khởi động trước pha quicker đầu tiên; buổi 15 phút: 3:00. |
| 4 · Seated không brisk | Câu pha quicker của Seated chỉ nói "a little quicker", "a little faster arms"; không có chữ brisk hay moderate. `a2.brisk.again.2` ("Brisk again") và `a2.brisk.mid.1` ("breathing a bit harder") **chỉ dùng cho In place / Walking pad**. |
| 4 · Talk test, không số | `a2.talk.*` và `a1.11`, `a1.14`: "can still talk, but singing would be hard". Không nhịp tim, không số bước, không mile, không kcal. |
| 6 · Biến thể theo cơ thể | Mỗi động tác có câu an toàn thay cho câu "harder" khi người dùng có chip tương ứng (§3.7). |
| 8 · Tên và trái/phải cố định | Mọi động tác luân phiên **bắt đầu bằng chân phải** (khớp clip W1-*, W2-*: "right foot first", PROMPTS §4); In place: **ghế bên trái**, tay trái vịn (khớp MF-04, W2-3). Tên động tác trong giọng = tên trên thẻ. |
| Bản dễ trước | Trong khối: câu `easy` luôn trước câu `harder`; `harder` chỉ ở Steady/Strong và không bao giờ ở Gentle. |
| An toàn | Mỗi buổi `a4.pain.1` (+ `a4.pain.2`) ở khởi động ("A gentle effort, never pain"); câu dừng `a7.stop.1` + `a7.stop.2` mỗi buổi đầu ở cấp mới và khi tăng cường độ, `a7.stop.breath` trong pha quicker; Walking pad: `a7.pad.*` + câu riêng §4.2, đúng thứ tự STD §2.5 (§3.6). |

## 3. Khung buổi và khe

### 3.1 Khung 5 buổi (plan §2.1, §2.4; STD §2.6, §7)
| Buổi | Cấp mặc định | Khởi động | Phần chính | Thả lỏng | Tổng | Động tác (theo thứ tự khối) |
|---|---|---|---|---|---|---|
| Gentle walk 5 | Seated | 1:00 | 3 × 1:00, **không pha quicker** (Steady chỉ thêm tay) | 1:00 | 5:00 | March · Heel dig · Side step |
| Steady walk 8 | In place | 2:00 | 4 × 1:00 = 0:40 easy + 0:20 quicker | 2:00 | 8:00 | March · Side step · Knee lift · Heel dig |
| Strong walk 10 | In place | 2:00 | 6 × 1:00 = 0:30 easy + 0:30 quicker | 2:00 | 10:00 | March · Side step · Knee lift · Heel dig · Toe tap forward · Heel to back |
| Longer walk 15 (B) | In place | 3:00 | 6 × 1:30 = 1:00 easy + 0:30 quicker (3 vòng × 2 khối, xem câu hỏi #1) | 3:00 | 15:00 | vòng 1: March · Side step · vòng 2: Knee lift · Heel dig · vòng 3: Toe tap forward · Weight shift (Heel to back thay một bài theo `rotationIndex`) |
| Commercial break walk 5 | Seated hoặc In place | 1:00 | 3 × 1:00, không pha quicker | 1:00 | 5:00 | March · Heel dig · Weight shift |
| Commercial break walk 3 (B) | Seated hoặc In place | 0:30 | 3 × 0:40, không pha quicker | 0:30 | 3:00 | March · Side step · Heel dig (STD §5.3) |

- **Walking pad:** cùng khung In place, nhưng mọi khối chỉ là **March** (khối lẻ) và **Arm swing / Arm press** (khối chẵn) trên nền march; không Side step, Weight shift hay Heel to back trên belt (plan §2.1, STD §2.5). Pha quicker trên pad: tăng tốc một nấc **hoặc** giữ tốc độ và vung tay nhiều hơn (câu hỏi #2).
- **Seated** với Heel to back: bản ngồi (gót trượt về gầm ghế), chưa có clip → màn hiện ảnh khung tĩnh.
- Buổi 5 phút dưới mức 2 + 2 phút của Otago → chỉ Gentle/Steady, không Strong (STD §2.6).
- Nhãn player (chốt #3): khởi động, pha easy, thả lỏng = EASY WALK; pha quicker = **QUICKER** ở Seated, BRISK WALK ở In place / Walking pad. Gentle walk 5 và Commercial break chỉ có EASY WALK. ID `a2.brisk.*` là mã nội bộ, không đọc ra.
- Chuông đổi pha phát trước câu 1 giây (như A1). Sau thả lỏng, ngày có động tác ghế thì nối `a9.to-chair` → A4.

### 3.2 Chọn biến thể
Như bản tối thiểu: biến thể = (ngày hoạt động + số thứ tự khe) mod số biến thể của khe, để hai ngày liền nhau khác câu. Câu có ghi "chỉ …" trong cột Ghi chú bị lọc trước khi chọn. Khe để trống khi mọi biến thể bị lọc (im lặng tốt hơn câu sai).

**Kho xoay mở rộng (08/10/2026, kế hoạch UI/cá nhân hoá task 3.9, `VoiceRotation.pools`):** `a2.warm.2–8` xoay với nhau (`a2.warm.1` giữ vai câu mở "Easy steps to start"); khởi động In place 7 câu nên 5 buổi liền không lặp câu nào. Cũng xoay: `a6.*` trừ `a6.6` ("stronger than last time", chỉ đúng khi có so sánh) và `a6.9` ("almost there", theo vị trí); `a7.break.1–2`, `a3.open.1–2`, `a9.back.1–2`. Một buổi không bao giờ nói lại một câu (xoay là dịch vòng, không bốc ngẫu nhiên).

### 3.3 Khe khởi động
**1:00 (Gentle walk 5, Commercial break 5)**
| Khe | Thời điểm | Chọn từ |
|---|---|---|
| mở | 0:00 | `a9.gentle` / `a9.steady` (nếu có check-in) hoặc `a2.open.*`; Commercial: `a11.break.open.1` → `a11.break.open.2` |
| dựng tư thế | 0:06 | `a2.setup.<cấp>.*`; Joint replacement + Seated: thêm `a2.setup.seated.joint` |
| an toàn | 0:16 | `a4.pain.1` + `a4.pain.2` (hoặc `a1.03`) |
| khởi động | 0:26, 0:38 | Seated: `a1.04` → `a1.05`; In place / Pad: `a2.warm.1`, `a2.warm.2`, `a2.warm.8` |
| báo đổi | 0:50 | `a2.move.march.next` |

**2:00 (Steady walk 8, Strong walk 10)**
| Khe | Thời điểm | Chọn từ |
|---|---|---|
| mở | 0:00 | `a9.steady` / `a9.strong` hoặc `a2.open.*` |
| dựng tư thế | 0:06 | `a2.setup.<cấp>.*` |
| dựng tư thế 2 | 0:16 | Seated: `a2.setup.seated.3`; In place: `a2.setup.inplace.3`, `a2.setup.inplace.shoes`; Pad: §3.6 theo thứ tự |
| an toàn | 0:26 | `a4.pain.1` + `a4.pain.2`; buổi đầu ở cấp mới: `a7.stop.1` + `a7.stop.2` (Pad: `a7.pad.dizzy`) |
| khởi động | 0:36 → 1:40, mỗi 10–12 s | `a1.04`–`a1.11`, `a2.warm.*`; Seated có `a1.08`, bỏ `a2.warm.2`, `a2.warm.6`, `a2.warm.8`; đứng bỏ `a1.08`; Joint replacement bỏ `a1.09` |
| thêm tay | 1:10 | `a2.move.arms.intro` → `a2.move.arms.swing` (Pad: `a2.move.arms.pad`) |
| báo đổi | 1:50 | `a2.move.march.next` |

**3:00 (Longer walk 15)**: như 2:00, mở bằng `a2.long.open`, khởi động kéo tới 2:50 (thêm `a2.warm.3`, `a2.warm.4`, `a2.warm.5`, `a2.warm.7`, `a1.09`, `a1.10`), báo đổi ở 2:50.

**0:30 (Commercial break 3, B)**: `a11.break.open.1` 0:00 → `a2.setup.<cấp>.*` 0:06 → `a1.04` hoặc `a2.warm.1` 0:14 → `a2.move.march.next` 0:20.

### 3.4 Khe trong một khối động tác
Thời điểm tính từ đầu khối. `<m>` = động tác của khối; `<cấp>` = `seated` hoặc `inplace` (Pad dùng `inplace`). Nếu khối 1 là March và khởi động đã march: bỏ `demo` và `now`, nói `a2.move.march.<cấp>` ngay sau `intro`.

**Khối easy 1:00 (Gentle walk 5, Commercial break 5)**
| Khe | Thời điểm | Chọn từ |
|---|---|---|
| tên | +0:00 | chuông đổi pha, `a2.move.<m>.intro` |
| demo | +0:03 | `a4.demo.*` → `a2.move.<m>.demo[.<cấp>]` |
| cùng làm | +0:10 | `a4.with-me.*`, `a2.now.*` |
| tư thế | +0:16 | `a2.move.<m>.<cấp>` |
| bản dễ | +0:28 | `a2.move.<m>.easy` |
| giữa | +0:40 | Commercial khối 2: `a11.break.mid`; Gentle: `a2.gentle.*`; Steady: `a2.gentle.arms` rồi `a2.move.arms.swing`; có chip: câu an toàn của động tác (§3.7) |
| báo đổi | +0:50 | `a2.move.<m kế>.next` (dự phòng `a5.10s.change`, `a2.next.*`); khối cuối: `a1.24` |

**Khối 40/20 (Steady walk 8)**
| Khe | Thời điểm | Chọn từ |
|---|---|---|
| tên, demo, cùng làm | +0:00, +0:03, +0:10 | như khối easy |
| tư thế | +0:16 | `a2.move.<m>.<cấp>` |
| bản dễ | +0:24 | `a2.move.<m>.easy` (có chip: câu an toàn) |
| báo quicker | +0:30 | khối 1: `a1.12`, `a2.soon.*`; khối sau: `a2.round.*`, `a2.soon.3`, `a2.soon.4` |
| vào quicker | +0:40 | chuông; khối 1: `a2.brisk.<cấp>.*`, `a1.13`; khối sau: `a1.19`, `a2.brisk.again.*`; khối cuối: `a2.brisk.last` |
| giữa quicker | +0:46 | khối 1 và 3 (mỗi 2 phút): talk test §4.7; khối 2 và 4: `a2.move.<m>.harder` hoặc `a2.brisk.mid.*`, `a7.stop.breath` (một lần mỗi buổi) |
| báo đổi | +0:50 | `a2.move.<m kế>.next`; khối cuối: `a2.brisk.end.*` |

**Khối 30/30 (Strong walk 10)**
| Khe | Thời điểm | Chọn từ |
|---|---|---|
| tên, demo, cùng làm | +0:00, +0:03, +0:10 | như khối easy |
| tư thế hoặc bản dễ | +0:15 | khối lẻ: `a2.move.<m>.<cấp>`; khối chẵn: `a2.move.<m>.easy` |
| báo quicker | +0:20 | `a1.12`, `a2.soon.*`, `a2.round.*`; 30 giây: có thể `a1.18` |
| vào quicker | +0:30 | như khối 40/20 |
| khó hơn | +0:36 | `a2.move.<m>.harder` (có chip: câu an toàn thay) |
| giữa quicker | +0:44 | khối 1, 3, 5: talk test; khối 2, 4, 6: `a2.brisk.mid.*`, `a1.14`, `a1.20` |
| báo đổi | +0:50 | `a2.move.<m kế>.next`; khối cuối: `a2.brisk.end.*` |

**Khối 1:00 easy + 0:30 quicker (Longer walk 15)**
| Khe | Thời điểm | Chọn từ |
|---|---|---|
| tên, demo, cùng làm | +0:00, +0:03, +0:10 | như khối easy; đầu vòng 2 và 3: `a2.long.round.2`, `a2.long.round.3` trước `intro` |
| tư thế | +0:18 | `a2.move.<m>.<cấp>` |
| bản dễ | +0:30 | `a2.move.<m>.easy` |
| giữa easy | +0:42 | `a2.easy.mid.*`, `a2.warm.5`; khối 4: `a2.long.half` |
| báo quicker | +0:50 | `a2.soon.*`, `a2.round.*`, `a1.18` |
| vào quicker | +1:00 | như khối 40/20 |
| khó hơn / talk test | +1:08 | khối 1, 3, 5 (mỗi 3 phút): talk test; khối 2, 4, 6: `a2.move.<m>.harder` |
| báo đổi | +1:20 | `a2.move.<m kế>.next`; khối cuối: `a2.brisk.end.*` |

**Khối 0:40 easy (Commercial break 3, B)**: `intro` +0:00 · `demo` +0:03 · `now` +0:10 · `easy` +0:18 · `next` +0:30.

### 3.5 Khe thả lỏng (STD §4.3; câu giãn cơ lấy từ A10 theo ID)
**2:00 (Steady walk 8, Strong walk 10)**
| Khe | Thời điểm | Chọn từ |
|---|---|---|
| vào thả lỏng | 0:00 | chuông, `a2.cool.<cấp>.*` (Pad: `a2.cool.pad.1`) |
| đi chậm | 0:10, 0:22, 0:34, 0:46 | `a2.cool.mid.*`, `a1.17`, `a1.26`, `a1.23` |
| dừng chân | 0:55 | Seated / In place: `a2.cool.feet`; Pad: `a7.pad.off` → `a2.cool.pad.2` |
| sang giãn | 1:00 | `a2.cool.stretch.*` |
| bắp chân / cổ chân | 1:04 | In place, Pad: `a10.calf.intro` → `a10.calf.setup` → `a10.calf.move`, giữ 20 s mỗi bên (`a10.switch.1`); Knees: `a10.calf.easy`. Seated hoặc Standing for long is hard: `a10.ankle.setup` → `a10.ankle.move`, 20 s mỗi chân (Knees: `a10.ankle.easy`) |
| ngực + thở | 1:45 | `a10.chest.move` (Seated thêm `a10.chest.setup` trước; Shoulders: `a10.chest.easy`), trong 15 s giữ: `a2.cool.breath` → `a1.27` → `a2.cool.breath.last` |
| kết | 2:00 | `a2.close.*` |

**1:00 (Gentle walk 5, Commercial break 5):** `a2.cool.<cấp>.*` 0:00 · `a2.cool.mid.*` hoặc `a1.26` 0:12 · `a2.cool.feet` 0:30 · `a10.chest.move` 0:34 · giữ 15 s với `a2.cool.breath` → `a1.27` → `a2.cool.breath.last` · kết `a2.close.*` hoặc `a11.break.close.*` ở 1:00. Không bắp chân (không đủ thời gian).

**3:00 (Longer walk 15):** như 2:00 nhưng đi chậm tới 1:30; sau bắp chân/cổ chân thêm `a10.thigh.intro` → `a10.thigh.setup` → `a10.thigh.move` 20 s mỗi bên, ngồi (ẩn với Joint replacement → bỏ, giữ lâu hơn ở cổ chân; Lower back hoặc Knees: `a10.thigh.easy`); rồi ngực + thở.

**0:30 (Commercial break 3, B):** `a2.cool.<cấp>.*` 0:00 · `a2.cool.breath` → `a1.27` 0:15 · `a11.break.close.*` 0:30.

### 3.6 Câu Walking pad đặt ở đâu
| Khi nào | Câu |
|---|---|
| 3 buổi Pad đầu tiên, khe dựng tư thế (thứ tự STD §2.5, thay khe khởi động 0:36–1:10) | `a7.pad.clip` → `a7.pad.rail` → `a7.pad.start` (hai chân hai bên, rồi bật belt) → `a7.pad.slow` hoặc `a2.setup.pad.2` → `a2.setup.pad.1` (vịn, bước lên khi belt chạy chậm) → `a7.pad.phone` → `a2.pad.moves` |
| Từ buổi Pad thứ 4 | `a7.pad.start` → `a7.pad.slow` hoặc `a2.setup.pad.2` → `a2.setup.pad.1`, rồi một câu xoay vòng (`a7.pad.rail`, `a2.pad.moves`, `a7.pad.phone`, `a7.pad.clip`) |
| Trước câu vào quicker đầu tiên | `a7.pad.slow` (build up a little at a time) |
| Khe an toàn của buổi Pad | `a7.pad.dizzy` thay `a7.stop.1` |
| Thả lỏng | `a2.cool.pad.1` → `a7.pad.off` (dừng belt, chờ đứng yên) → `a2.cool.pad.2` (vịn khi bước xuống, sang ghế) |
| Break trong buổi Pad | `a7.pad.off` trước `a7.break.1` |
Màn xác nhận trước buổi Pad đầu ("I can hold on" / "Use In place today", chốt #7) là chữ màn hình, không phải giọng.

### 3.7 Biến thể theo chip giới hạn (S06; khớp bảng chip D5)
| Chip | Động tác | Thay đổi |
|---|---|---|
| Joint replacement | March | bỏ `a2.move.march.harder`, `a1.09`, `a2.brisk.inplace.1` → nói `a2.move.march.joint` |
| Joint replacement | Knee lift | bỏ `harder` → `a2.move.knee-lift.joint` |
| Joint replacement | Heel to back | bỏ `harder` → `a2.move.heel-back.joint` |
| Joint replacement | Seated (mọi buổi) | thêm `a2.setup.seated.joint` |
| Knees | Toe tap forward | bỏ `harder` (low kick) → `a2.move.toe-tap.knees` |
| I get dizzy easily | Side step | bỏ `harder` → `a2.move.side-step.dizzy` |
| Shoulders | Arm swing / press | bỏ `a2.move.arms.press` và `harder` → `a2.move.arms.shoulders` |
| Standing for long is hard | mọi buổi | cấp Seated; thả lỏng dùng cổ chân, không bắp chân |
| Lower back (or bone thinning) | — | không đổi câu đi bộ (không có gập hay xoay mạnh); thả lỏng: `a10.thigh.easy` |

## 4. Câu thoại

### 4.1 Mở và dựng tư thế (câu an toàn dùng `a4.pain.*`, `a7.stop.*` theo ID)
| ID | Câu thoại | Ghi chú |
|---|---|---|
| a2.open.1 | Welcome back. Let's get your feet moving. | |
| a2.open.2 | Good to see you. This walk is all at your pace. | |
| a2.open.3 | Ready when you are. Let's start slow and easy. | |
| a2.open.4 | Here we go. Easy steps first, and we'll build from there. | mới |
| a2.setup.seated.1 | Sit toward the front of your chair, feet flat, back tall. | |
| a2.setup.seated.2 | Find the front of your seat and plant your feet. Hands can rest on your thighs. | |
| a2.setup.seated.3 | Use a sturdy chair with no wheels. Sit tall, away from the back. | mới; STD §6 |
| a2.setup.seated.joint | A higher chair works best for you, with arms if you have one. | mới; chỉ Joint replacement (chốt #5) |
| a2.setup.inplace.1 | Stand near your chair so you can hold it if you need to. Feet about hip-width apart. | |
| a2.setup.inplace.2 | Stand tall with your chair close by. Soft knees, relaxed shoulders. | |
| a2.setup.inplace.3 | Clear a little space around you. Keep your chair on your left, within reach. | mới; ghế bên trái như clip |
| a2.setup.inplace.shoes | Shoes with good grip are best. Please skip socks on a smooth floor. | mới; STD §6 |

### 4.2 Walking pad (STD §2.5; an toàn chung ở `a7.pad.*`, thứ tự ở §3.6)
| ID | Câu thoại | Ghi chú |
|---|---|---|
| a2.setup.pad.1 | Hold on, and step onto the belt while it moves slowly. | **sửa** (§6); sau `a7.pad.start` + `a7.pad.slow` |
| a2.setup.pad.2 | Start your pad nice and slow. You can change the speed anytime. | biến thể của `a7.pad.slow`, sau `a7.pad.start` |
| a2.pad.moves | On the pad, we just walk and use our arms. No side steps on the belt. | mới |

### 4.3 Khởi động
| ID | Câu thoại | Ghi chú |
|---|---|---|
| a2.warm.1 | Easy steps to start. Let your arms swing naturally. | |
| a2.warm.2 | Keep it light. Heels, then toes, nice and steady. | chỉ In place / Pad (ngồi đặt cả bàn chân) |
| a2.warm.3 | Roll your shoulders once or twice. Stay loose. | |
| a2.warm.4 | Just warming up. No rush at all. | |
| a2.warm.5 | Look ahead, not down at your feet. | mới; Otago |
| a2.warm.6 | Stand tall, like a string is lifting the top of your head. | mới; chỉ đứng (Seated dùng `a1.08`) |
| a2.warm.7 | Breathe easy. Your breath should stay calm here. | mới |
| a2.warm.8 | Soft knees, relaxed hands. Let each step land gently. | mới; chỉ In place / Pad |

### 4.4 Báo trước và chuyển động tác
| ID | Câu thoại | Ghi chú |
|---|---|---|
| a2.soon.1 | Quicker steps coming up in a few seconds. | đặt ở −0:10 |
| a2.soon.2 | Get ready to pick up the pace, just a little. | |
| a2.soon.3 | Ten seconds, then a little quicker. | mới |
| a2.soon.4 | In ten seconds, we'll go a little faster. Same move. | mới |
| a2.next.1 | Nearly time for something new. Ten more seconds. | mới; biến thể của `a5.10s.change`, dự phòng khi thiếu câu `.next` riêng |
| a2.now.1 | Now let's do it together, right side first. | mới; biến thể của `a4.with-me.*` |
| a2.now.2 | Your turn. Join in whenever you're ready. | mới |
| a2.now.3 | Together now. Nice and easy to start. | mới |

### 4.5 Động tác
Mỗi động tác: `intro` (tên) · `a4.demo.*` ("Watch one first.") rồi `demo` (mô tả một lần làm) · câu tư thế theo cấp · `easy` · `harder` · câu an toàn theo chip · `next` (báo trước 10 s). Chân phải trước.

**March** (`wk.march`)
| ID | Câu thoại | Ghi chú |
|---|---|---|
| a2.move.march.intro | March. Our basic walking step. | |
| a2.move.march.demo | The right knee lifts, the foot sets down, then the left. | |
| a2.move.march.seated | Sit tall. Lift each foot a little off the floor, and set it down flat. | |
| a2.move.march.inplace | Stand tall. Each foot lands softly, heel first, then the toes. | cũng dùng cho Pad |
| a2.move.march.easy | For an easier version, just lift your heels. Toes stay on the floor. | |
| a2.move.march.harder | For a little more, lift your knees higher, but keep them below your hips. | |
| a2.move.march.joint | Keep your knees well below your hips the whole time. | Joint replacement |
| a2.move.march.next | Ten more seconds. Next up: March. | |

**Heel dig** (`wk.heel-dig`)
| ID | Câu thoại | Ghi chú |
|---|---|---|
| a2.move.heel-dig.intro | Heel dig. Heel out in front, toes up. | |
| a2.move.heel-dig.demo | The right heel reaches forward, toes point up, then it comes back. | |
| a2.move.heel-dig.seated | Slide your foot forward, rest the heel down, and pull your toes toward you. | |
| a2.move.heel-dig.inplace | Keep your standing knee soft, and your chair within reach. | |
| a2.move.heel-dig.easy | For an easier version, go slower, and keep the heel close to you. | |
| a2.move.heel-dig.harder | For a little more, switch feet a little quicker, in a steady rhythm. | |
| a2.move.heel-dig.next | Ten more seconds. Next up: Heel dig. | |

**Side step** (`wk.side-step`) — không dùng trên Walking pad
| ID | Câu thoại | Ghi chú |
|---|---|---|
| a2.move.side-step.intro | Side step. | |
| a2.move.side-step.demo.seated | The right foot steps out to the side, then back in. | |
| a2.move.side-step.demo.inplace | Step to the right, and bring your left foot to meet it. | |
| a2.move.side-step.seated | Keep your foot low as it slides out. Your hips stay still on the seat. | |
| a2.move.side-step.inplace | Two steps to the right, then two back to the left. Hips level, knees soft. | khớp clip W2-2 |
| a2.move.side-step.easy | For an easier version, take smaller steps, with your hands on your hips. | |
| a2.move.side-step.harder | For a little more, take wider steps and open your arms out to the sides. | |
| a2.move.side-step.dizzy | Keep your steps small, and stay close to your chair. | I get dizzy easily |
| a2.move.side-step.next | Ten more seconds. Next up: Side step. | |

**Knee lift** (`wk.knee-lift`)
| ID | Câu thoại | Ghi chú |
|---|---|---|
| a2.move.knee-lift.intro | Knee lift. A little higher than a march. | |
| a2.move.knee-lift.demo | The right knee comes up, foot pointing forward, then down. | |
| a2.move.knee-lift.seated | Hold the sides of your seat if you like. Sit tall as you lift. | |
| a2.move.knee-lift.inplace | Rest your left hand on your chair. Your knee comes no higher than your hip. | khớp clip W2-3 |
| a2.move.knee-lift.easy | For an easier version, lift just a little, and hold your chair. | |
| a2.move.knee-lift.harder | For a little more, touch each knee with the opposite hand. | |
| a2.move.knee-lift.joint | Keep your knee clearly below your hip. A lower lift is just right. | Joint replacement |
| a2.move.knee-lift.next | Ten more seconds. Next up: Knee lift. | |

**Toe tap forward** (`wk.toe-tap`)
| ID | Câu thoại | Ghi chú |
|---|---|---|
| a2.move.toe-tap.intro | Toe tap forward. | |
| a2.move.toe-tap.demo | The right toes tap the floor in front, then come back. | |
| a2.move.toe-tap.seated | Reach your foot a little forward, tap, and bring it home under your knee. | |
| a2.move.toe-tap.inplace | Keep your standing knee soft, and stay tall. Don't lean back. | |
| a2.move.toe-tap.easy | For an easier version, tap a little closer to you, and slower. | plan để "—"; khớp D5 "tap closer" (chờ duyệt) |
| a2.move.toe-tap.harder | For a little more, turn the tap into a low kick. Keep that knee a little bent. | |
| a2.move.toe-tap.knees | Keep it a gentle tap today. No kicks. | Knees |
| a2.move.toe-tap.next | Ten more seconds. Next up: Toe tap forward. | |

**Heel to back** (`wk.heel-back`)
| ID | Câu thoại | Ghi chú |
|---|---|---|
| a2.move.heel-back.intro | Heel to back. | |
| a2.move.heel-back.demo.seated | The right heel slides back under your chair, then forward again. | chưa có clip ngồi |
| a2.move.heel-back.demo.inplace | The right heel comes back and up behind you, then sets down. | khớp clip W2-6 (B) |
| a2.move.heel-back.seated | Sit tall, feet flat. Slide one heel back, then the other. | |
| a2.move.heel-back.inplace | Stand behind your chair, both hands on the back. Stay tall, no leaning forward. | |
| a2.move.heel-back.easy | For an easier version, make it smaller. Halfway up is plenty. | |
| a2.move.heel-back.harder | For a little more, let go of the chair if you feel steady. Stay close to it. | chỉ In place |
| a2.move.heel-back.joint | Bend your knee only as far as feels comfortable. | Joint replacement (plan: Knee replacement) |
| a2.move.heel-back.next | Ten more seconds. Next up: Heel to back. | |

**Weight shift** (`wk.shift`)
| ID | Câu thoại | Ghi chú |
|---|---|---|
| a2.move.shift.intro | Weight shift. | |
| a2.move.shift.demo.seated | Lean gently to the right, then through the middle to the left. | |
| a2.move.shift.demo.inplace | Shift your weight onto your right foot, then over to the left. | |
| a2.move.shift.seated | Keep both feet flat and your head level. Just a small lean. | |
| a2.move.shift.inplace | Feet a little wider than your hips. Knees point the same way as your toes. | |
| a2.move.shift.easy | For an easier version, hold your chair, and keep the shift small. | |
| a2.move.shift.harder | For a little more, let the lighter heel lift a little off the floor. | chỉ In place |
| a2.move.shift.next | Ten more seconds. Next up: Weight shift. | |

**Arm swing / press** (`wk.arms`) — lớp tay trên nền March, không clip riêng
| ID | Câu thoại | Ghi chú |
|---|---|---|
| a2.move.arms.intro | Now let's add your arms. | |
| a2.move.arms.swing | Arm swing. Bend your elbows, and swing your arms with your steps. | |
| a2.move.arms.press | Arm press. Push your hands forward at shoulder height, then draw them back. | |
| a2.move.arms.soft | Keep your elbows soft, never locked straight. | |
| a2.move.arms.easy | For an easier version, keep your hands below your shoulders. | |
| a2.move.arms.harder | For a little more, press up and out at an angle, if your shoulders feel good. | |
| a2.move.arms.shoulders | Keep your arms below shoulder height today. Small and easy is fine. | Shoulders |
| a2.move.arms.pad | If you feel steady, let go and swing your arms. Keep the rail close. | chỉ Pad |
| a2.move.arms.next | Ten more seconds. Next up: Arm swing. | Pad, khối chẵn |

### 4.6 Pha quicker
| ID | Câu thoại | Ghi chú |
|---|---|---|
| a2.brisk.seated.1 | A little quicker now. March your feet, and let your arms join in. | chỉ Seated |
| a2.brisk.seated.2 | Pick up the pace in your chair. Quick, small steps. | chỉ Seated |
| a2.brisk.seated.3 | A little faster arms now. Your feet can follow. | mới; chỉ Seated |
| a2.brisk.seated.4 | A little quicker, same move. Swing your arms a bit bigger. | mới; chỉ Seated |
| a2.brisk.inplace.1 | A little quicker now. Lift your knees a bit and swing your arms. | chỉ In place, khối March / Knee lift; không Joint replacement |
| a2.brisk.inplace.2 | Pick up the pace, right where you are. Stay close to your chair. | chỉ In place |
| a2.brisk.inplace.3 | Quicker steps now, same move. Let your arms help. | mới; chỉ In place |
| a2.brisk.inplace.4 | A little faster now. Keep your steps small and light. | mới; chỉ In place |
| a2.brisk.pad.1 | Turn your pad up a notch, or just take quicker steps. | chỉ Pad |
| a2.brisk.pad.2 | A little faster now, if it feels right. Hold the rail, or your table, as you speed up. | **sửa** (§6); chỉ Pad |
| a2.brisk.pad.3 | Same speed is fine too. Just swing your arms a bit more. | mới; chỉ Pad |
| a2.brisk.again.1 | Here we go again. Quicker steps. | |
| a2.brisk.again.2 | Brisk again. Find that same rhythm. | **chỉ In place / Pad** (§6) |
| a2.brisk.again.3 | And a little quicker again. Same move. | mới |
| a2.brisk.again.4 | Back to a little quicker. Your arms can do some of the work. | mới |
| a2.brisk.mid.1 | You should be breathing a bit harder, but still able to talk. | **chỉ In place / Pad** (§6) |
| a2.brisk.mid.2 | Nice rhythm. Keep your shoulders relaxed. | |
| a2.brisk.mid.3 | If it feels like too much, slow down a little. That still counts. | |
| a2.brisk.mid.4 | Look ahead, and keep breathing. You're doing well. | mới |
| a2.brisk.last | Last quicker round. You've got this. | |
| a2.brisk.end.1 | Ten more seconds, then we slow down. | mới; khối cuối |
| a2.brisk.end.2 | Almost done with the quicker part. Ten more seconds. | mới; khối cuối |

### 4.7 Talk test (thay mọi con số; Steady/Strong mỗi 2 phút, Longer mỗi 3 phút, buổi 5 phút một lần bằng `a1.11`)
| ID | Câu thoại | Ghi chú |
|---|---|---|
| a2.talk.1 | Quick check. You can still talk, but singing would be hard. That's the spot. | chỉ In place / Pad |
| a2.talk.2 | Try saying a few words out loud. If that's easy, you're doing fine. | |
| a2.talk.3 | Hard to get the words out? Slow down until talking feels easy. | |
| a2.talk.seated | You should be able to chat easily. Add a little more arm swing if you like. | chỉ Seated |

### 4.8 Pha easy và buổi không có pha quicker
| ID | Câu thoại | Ghi chú |
|---|---|---|
| a2.easy.1 | And ease off. Easy steps, catch your breath. | Longer 15, pha easy giữa buổi |
| a2.easy.2 | Slow it down. Nice and relaxed. | |
| a2.easy.3 | Back to easy. Same move, a little slower. | mới |
| a2.easy.4 | Nice and easy again. Let your arms relax. | mới |
| a2.easy.mid.1 | Let your breathing settle. You're doing well. | |
| a2.easy.mid.2 | Easy pace. Loosen your hands. | |
| a2.easy.mid.3 | Easy pace. This part matters just as much. | mới |
| a2.round.1 | Another quicker round in a few seconds. | đặt ở −0:10 |
| a2.round.2 | Get ready. One more round coming up. | |
| a2.gentle.1 | Steady and easy. There's nothing to hurry today. | mới; Gentle walk 5, Commercial |
| a2.gentle.2 | Keep this gentle pace. Moving is what matters. | mới |
| a2.gentle.3 | Stay comfortable. Smaller is fine, too. | mới |
| a2.gentle.arms | If you'd like a little more, bring your arms in. | mới; chỉ cường độ Steady trong buổi 5 phút (plan §2.1) |

`a2.easy.1`, `a2.easy.2` còn dùng ở Longer walk 15 khi khối kế tiếp là cùng động tác (không đổi động tác thì không có `intro`).

### 4.9 Thả lỏng
| ID | Câu thoại | Ghi chú |
|---|---|---|
| a2.cool.seated.1 | Time to wind down. Slow your feet until they're barely moving. | |
| a2.cool.seated.2 | Let's slow down. Small, easy steps in your chair. | mới |
| a2.cool.inplace.1 | Time to wind down. Slow, gentle steps, then let your feet rest. | |
| a2.cool.inplace.2 | Slow march now. Arms low and loose. | mới |
| a2.cool.pad.1 | Bring your pad down to a slow stroll. | |
| a2.cool.pad.2 | Hold on as you step off. Then stand behind your chair. | **sửa** (§6); sau `a7.pad.off` |
| a2.cool.mid.1 | Shake out your hands. Let your breathing slow down. | |
| a2.cool.mid.2 | Nice and slow. Let your breathing come back to easy. | mới |
| a2.cool.mid.3 | Notice your breath slowing down. You did the work. | mới |
| a2.cool.feet | Let your feet come to rest. | mới |
| a2.cool.stretch.1 | Now, a few easy stretches to finish. | mới; rồi câu A10 theo §3.5 |
| a2.cool.stretch.2 | Let's finish with two gentle stretches. Stay right where you are. | mới |
| a2.cool.breath | Three slow breaths to finish. | mới; rồi `a1.27` |
| a2.cool.breath.last | And one last breath in… and slowly out. | mới |

### 4.10 Kết (không streak, không trách)
| ID | Câu thoại | Ghi chú |
|---|---|---|
| a2.close.1 | That's your walk for today. Well done. | |
| a2.close.2 | All done. Every minute counts, and you did them all. | |
| a2.close.3 | That's it for today. Your journey just moved a little further. | |
| a2.close.4 | That's your walk. Thank you for making time for yourself. | mới |
| a2.close.5 | Walk done. Have a sip of water when you can. | mới |
| a2.close.6 | Lovely work. Enjoy the rest of your day. | mới |

### 4.11 Commercial break walk
Câu mở, giữa và kết riêng của buổi này nằm ở [A11-extras.md](A11-extras.md) §4 (`a11.break.open.1`, `a11.break.open.2`, `a11.break.mid`, `a11.break.close.1`, `a11.break.close.2`), không viết lại ở đây. Phần còn lại dùng câu A2 theo khe §3.3–§3.5.

### 4.12 Longer walk 15 (đợt B)
| ID | Câu thoại | Ghi chú |
|---|---|---|
| a2.long.open | A longer walk today, with plenty of easy time built in. | |
| a2.long.round.2 | Round two. Same easy start, then a little quicker. | |
| a2.long.round.3 | Last round. Take it at your pace. | |
| a2.long.half | About halfway. Have a sip of water, if you have some nearby. | STD §6 nước |
| a2.long.tired | Feeling tired? Stay at the easy pace from here. It all counts. | thay `a2.soon.*` khi bấm Break ≥ 1 lần |

## 5. Câu dùng lại từ file khác (không chép chữ; chữ gốc ở file nguồn)
| ID | Dùng ở khe | Lưu ý |
|---|---|---|
| a1.02 | dựng tư thế Seated | biến thể thứ 4 của `a2.setup.seated.*` |
| a1.03 | an toàn | biến thể của `a4.pain.1` + `a4.pain.2` |
| a1.04 | khởi động Seated | heel taps trước |
| a1.05 | khởi động Seated | rồi marching |
| a1.06 | khởi động, thêm tay | |
| a1.07 | khởi động | |
| a1.08 | khởi động | chỉ Seated |
| a1.09 | khởi động | bỏ khi Joint replacement |
| a1.10 | khởi động | |
| a1.11 | khởi động, talk test buổi 5 phút | |
| a1.12 | báo quicker khối 1 | không dùng ở buổi 5 phút |
| a1.13 | vào quicker khối 1 | mọi cấp |
| a1.14 | giữa quicker | |
| a1.15 | giữa quicker (−0:10) | chỉ khi khối không đổi động tác (Longer) |
| a1.16 | vào easy | chỉ khối March (câu có chữ "marching") |
| a1.17 | đi chậm thả lỏng | |
| a1.18 | báo quicker | **chỉ khi pha quicker dài 0:30** (Strong, Longer) |
| a1.19 | vào quicker khối sau | |
| a1.20 | giữa quicker | |
| a1.21 | giữa quicker (−0:10) | như `a1.15` |
| a1.22 | vào easy | |
| a1.23 | đi chậm thả lỏng | |
| a1.24 | báo thả lỏng buổi 5 phút | |
| a1.25 | thả lỏng Seated | |
| a1.26 | thả lỏng | |
| a1.27 | thở cuối | |
| a1.28 | thở cuối | Longer 15 |
| a4.demo.1 | demo, trước `a2.move.<m>.demo` | `a4.demo.2`, `a4.demo.3` xoay vòng (A4-chair-moves.md) |
| a4.with-me.1 | cùng làm | `a4.with-me.2`, `a4.with-me.3` xoay vòng cùng `a2.now.*` |
| a4.pain.1 | an toàn, mỗi buổi | luôn kèm `a4.pain.2` |
| a5.10s.change | báo đổi −0:10 | dự phòng khi thiếu `a2.move.<m>.next`; `a5.10s` cho khe −0:10 khác |
| a6.1 | giữa khối | a6.1–a6.10 xoay vòng; `a6.6` chỉ khi có dữ liệu thật |
| a7.stop.1 | an toàn, buổi đầu ở cấp mới | kèm `a7.stop.2`; `a7.stop.breath` trong pha quicker Steady/Strong |
| a7.pad.start | Walking pad | cả bộ `a7.pad.*` (start, slow, rail, clip, phone, off, dizzy), thứ tự ở §3.6 |
| a7.break.1 | Break | A7 nguyên bộ: Break, This hurts, Pause, `a7.dizzy` |
| a11.break.open.1 | Commercial break | cả bộ `a11.break.*` (open 1–2, mid, close 1–2) |
| a9.gentle | mở buổi | `a9.steady`, `a9.strong` tương tự; `a9.to-chair`, `a9.to-stretch` sau buổi |
| a10.calf.intro | thả lỏng In place / Pad | cùng `a10.calf.setup`, `a10.calf.move`, `a10.calf.easy`, `a10.switch.1` |
| a10.ankle.setup | thả lỏng Seated | cùng `a10.ankle.move`, `a10.ankle.easy` |
| a10.chest.move | thả lỏng | cùng `a10.chest.setup` (Seated), `a10.chest.easy` (Shoulders) |
| a10.thigh.intro | thả lỏng Longer 15 | cùng `a10.thigh.setup`, `a10.thigh.move`, `a10.thigh.easy`; ẩn Joint replacement |
Ghi chú: `a10.cool.open` ("Stay seated…") chỉ hợp Seated → buổi đứng dùng `a2.cool.stretch.*`.

## 6. Thay đổi so với bản tối thiểu
| ID / mục | Cũ | Mới | Lý do |
|---|---|---|---|
| Khung Gentle | 2:00 · 2 × (0:30 nhanh + 0:30 chậm) · 1:00 | 1:00 · 3 × 1:00 động tác · 1:00, **không pha quicker** | plan §2.1 (đã duyệt), nguyên tắc 3: buổi 5 phút không có pha nhanh |
| Khung Steady | 2:00 · 2 × (1:00 + 1:00) · 2:00 | 2:00 · 4 × 1:00 (40 s easy / 20 s quicker) · 2:00 | plan §2.1 |
| Khung Strong | 2:00 · 3 × (1:00 + 1:00) · 2:00 | 2:00 · 6 × 1:00 (30/30) · 2:00 | plan §2.1 |
| Nhãn pha nhanh | BRISK WALK mọi cấp | Seated: QUICKER; In place / Pad: BRISK WALK | chốt #3; STD §2.1 (ngồi chỉ là mức nhẹ) |
| `a2.setup.pad.1` | Step onto your walking pad and start it at a slow, easy speed. | Hold on, and step onto the belt while it moves slowly. | Câu cũ bước lên rồi mới bật máy, ngược STD §2.5. Thứ tự mới: `a7.pad.start` (hai chân hai bên, bật belt) → `a7.pad.slow` → `a2.setup.pad.1` (vịn, bước lên). Phần "đứng hai bên + bật" đã có ở `a7.pad.start` nên câu này chỉ giữ bước lên, không lặp |
| `a2.cool.pad.2` | When you're ready, stop your pad and step off carefully. | Hold on as you step off. Then stand behind your chair. | STD §2.5, §8.1: phải chờ belt dừng hẳn mới bước xuống; phần dừng belt đã có ở `a7.pad.off` (nói ngay trước), câu này chỉ giữ bước xuống có vịn và dẫn sang ghế cho giãn cơ |
| `a2.brisk.pad.2` | … Hold the handle if your pad has one. | … Hold the rail, or your table, as you speed up. | chốt #7: buổi Pad chỉ khi có chỗ vịn (tay vịn **hoặc** bàn), không để "nếu có"; thống nhất chữ "rail", "table" với `a7.pad.rail` |
| `a2.brisk.again.2` | dùng mọi cấp | chữ giữ, **chỉ In place / Pad** | "Brisk" không dùng cho Seated (nguyên tắc 4) |
| `a2.brisk.mid.1` | dùng mọi cấp | chữ giữ, **chỉ In place / Pad**; Seated dùng `a2.talk.seated` | ngồi ở mức nhẹ, "breathing a bit harder" có thể sai (STD §2.1) |
| `a2.warm.2` | mọi cấp | chữ giữ, chỉ In place / Pad | bản ngồi đặt cả bàn chân xuống (clip W1-1), không "heels, then toes" |
| `a2.brisk.inplace.1` | mọi khối | chữ giữ, chỉ khối March / Knee lift, không Joint replacement | "Lift your knees" sai với Side step, Heel dig…; gối ≤ hông |
| `a2.soon.*`, `a2.round.*`, `a2.brisk.*`, `a1.12`–`a1.21` | mọi buổi | không dùng ở Gentle walk 5 và Commercial break | hai buổi này không có pha quicker |
| `a1.18` ("Just thirty seconds") | mọi buổi | chỉ khi pha quicker dài 0:30 | thời lượng nói phải đúng (nguyên tắc 7) |
| `a1.16` ("Easy marching") | vào pha chậm | chỉ khi động tác là March | khối có thể là động tác khác |
| Khe "vào chậm", "báo vòng tiếp" | mỗi vòng | thay bằng khe khối động tác §3.4 | khung mới đổi động tác mỗi khối |
Các ID cũ còn lại giữ nguyên chữ và cách dùng. Câu mới trùng ý với câu đã có ở A4/A5/A7/A11 (Watch one first, Now with me, A gentle effort, câu dừng, an toàn pad, Ten more seconds then we change, mở/kết Commercial break) **không viết lại**, dùng theo ID (§5).

## 7. Tổng số câu
| Mục | Giữ từ bản tối thiểu | Mới | Cộng |
|---|---|---|---|
| 4.1 Mở, dựng tư thế | 7 | 5 | 12 |
| 4.2 Walking pad | 2 | 1 | 3 |
| 4.3 Khởi động | 4 | 4 | 8 |
| 4.4 Báo trước, chuyển | 2 | 6 | 8 |
| 4.5 Động tác (8) | 0 | 66 | 66 |
| 4.6 Pha quicker | 12 | 10 | 22 |
| 4.7 Talk test | 0 | 4 | 4 |
| 4.8 Pha easy, buổi không quicker | 6 | 7 | 13 |
| 4.9 Thả lỏng | 5 | 9 | 14 |
| 4.10 Kết | 3 | 3 | 6 |
| 4.12 Longer walk 15 | 0 | 5 | 5 |
| **Câu `a2.*` trong file này** | **41** (đủ mọi ID cũ, 3 câu sửa chữ) | **120** | **161** |
| Dùng lại A1 (`a1.02`–`a1.28`) | | | 27 |
| **Câu riêng cho đi bộ** | | | **188** |
| Dùng chung theo ID (không tính ở trên) | | | A4 (`a4.demo.*`, `a4.with-me.*`, `a4.pain.*`) · A5 · A6 · A7 (`a7.stop.*`, `a7.pad.*`, Break) · A9 · A10 · A11 (`a11.break.*`) |
Vượt ước ~150 của plan §4.2 vì mỗi động tác cần mô tả demo, câu tư thế theo cấp, câu an toàn theo chip và câu báo trước có tên (nguyên tắc 1, 2, 6, 8). Nếu cần cắt: bỏ câu `.next` riêng (8 câu, thay bằng `a5.10s.change`) và `a2.now.*` (3 câu, dùng `a4.with-me.*`).

## 8. Kiểm tra theo quy tắc
- `lint_md.sh` (chạy `tools/lint/copy_lint.py` trên mọi dòng có ID): **0 findings** (30/09/2026).
- Số từ: mọi câu tiếng Anh ≤ 16 từ (kiểm bằng script, 30/09/2026).
- Seated: không câu nào nói brisk/moderate; câu Seated chỉ "a little quicker", "a little faster arms".
- Không số nhịp tim, số bước, mile, kcal; thời lượng nói ra (ten seconds, five minutes) khớp khung.
- Không nhắm mắt, không "push through", không tuyên bố sức khoẻ; an toàn: "A gentle effort, never pain", câu dừng STD §1.4 mỗi buổi đầu ở cấp mới.
- Không gọi tên người dùng; không streak; câu kết chỉ nói hôm nay.

## 9. Cần kiểm tra khi thu thử
- Khối 1:00 có 6–7 câu: nghe thử xem có dày quá không (CMP: "constant pauses… to talk about the next exercise are disruptive"). Nếu dày: bỏ khe "tư thế" ở lần thứ hai cùng động tác trong tuần.
- "Watch one first" khi người dùng không nhìn màn: câu demo tự mô tả đủ; kiểm ≥ 6/8 người làm đúng chỉ bằng giọng (prototype-test-plan).
- Thả lỏng 2:00 chật: 1:00 đi chậm + bắp chân 2 × 20 s + ngực 15 s. Nếu lố, rút đi chậm xuống 0:55 (nguồn: 60–90 s) chứ không kéo tổng quá 8:00/10:00 (nguyên tắc 7).
- Nhạc −26 LUFS dưới giọng: câu "Ten more seconds" phải nghe rõ khi đang đi nhanh.

## 10. Câu hỏi cho chủ app
1. **Longer walk 15:** plan ghi "3:00 · 3 vòng × 3 động tác (1:00 easy / 0:30 quicker) · 3:00" nhưng 9 khối × 1:30 = 13:30, không ra 15:00. File này chọn **6 khối × 1:30** (3 vòng × 2 động tác) để tổng đúng 15:00. Phương án khác: 9 khối × 1:00 (40 s / 20 s), 3 động tác mỗi vòng. Câu thoại dùng được cho cả hai; chỉ đổi `sessions.json`.
2. **Pha quicker trên Walking pad:** đổi tốc độ belt 4–6 lần mỗi buổi thì nhiều thao tác. Đề xuất: chỉ tăng một nấc ở pha quicker đầu (`a2.brisk.pad.1/2`), các pha sau giữ tốc độ (`a2.brisk.pad.3`). Lưu ý `a2.brisk.pad.3` (vung tay) chỉ hợp khi không cần vịn; người đang vịn thì bỏ câu này.
3. **Toe tap forward, bản dễ:** plan để "—"; file dùng "tap a little closer to you, and slower" (khớp D5). Giữ hay bỏ?
4. **Heel to back ngồi:** chưa có clip (W2-6 là bản đứng, đợt B) → màn hiện ảnh tĩnh ở cấp Seated. Chấp nhận, hay bỏ Heel to back khỏi buổi Seated?
5. **`a7.pad.rail`** ("Hold the rail if your pad has one, or rest a hand on a sturdy table") và chốt #7 (buổi Pad chỉ khi vịn được): hai câu khớp nhau, nhưng A2 đã đổi `a2.brisk.pad.2` bỏ "if your pad has one". Nếu muốn một cách nói, sửa `a7.pad.rail` ở A-min-support.
