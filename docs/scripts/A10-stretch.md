# A10 — Giãn cơ nhẹ (buổi giãn cơ + hạ nhiệt) · bản nháp 1
_29/09/2026 · Theo [app-context.md](../../app-context.md) (Tone & copy rules, mục Giãn cơ) và [content-plan.md](../content-plan.md) mục A10, V2b, D5 · Màn S12b trong [spec](../design/gentle-walk-screen-spec.html) · Chữ thoại tiếng Anh Mỹ, ghi chú tiếng Việt · Không thuê người duyệt (chốt 28/09/2026): mỗi tư thế lấy từ nguồn công khai, ghi ở cột Nguồn_

## 1. Nguồn (xem ngày 29/09/2026)
| Mã | Nguồn | Dùng cho |
|---|---|---|
| NIA-3T | NIH National Institute on Aging, [Three Types of Exercise…](https://www.nia.nih.gov/health/exercise-and-physical-activity/three-types-exercise-can-improve-your-health-and-physical) (content reviewed 14/01/2025): giãn khi cơ đã ấm và sau bài sức bền hoặc sức mạnh, nhớ thở, không giãn tới mức đau | nguyên tắc chung, thứ tự (giãn sau đi bộ) |
| NIA-CALF | NIA Go4Life, [Flexibility Exercise for Your Calf](https://go4life.nia.nih.gov/exercise/calf): đứng xa tường hơn một sải tay, tay áp tường, bước một chân tới, giữ 10–30 giây (trích từ kết quả tìm kiếm; trang Go4Life không mở được từ máy này 29/09/2026 — verify lại khi mở được) | thời gian giữ 10–30 giây, bắp chân |
| NHS-SIT | NHS, [Sitting exercises](https://www.nhs.uk/live-well/exercise/sitting-exercises/): ghế chắc không bánh xe, bàn chân phẳng, gối vuông góc; chest stretch, upper-body twist, ankle stretch, neck rotation | ngực, xoay thân trên, cổ chân, xoay cổ, luật ghế |
| NHS-FLEX | NHS, [Flexibility exercises](https://www.nhs.uk/live-well/exercise/flexibility-exercises/) và [PDF Exercises for older people: Flexibility](https://assets.nhs.uk/prod/documents/NHS-flexibility-exercise.pdf): neck rotation, neck stretch, sideways bend, calf stretch; "build up slowly" | xoay cổ, nghiêng cổ, nghiêng người khi đứng, bắp chân |
| NHS-LPT | Leicestershire Partnership NHS Trust, [Seated stretching and strengthening exercises (ed. 5)](https://www.leicspart.nhs.uk/wp-content/uploads/2022/07/134-Falls-service-stretching-and-strengthening-exercises-edition-5.pdf): leg stretch (duỗi một chân, gót chạm sàn, mũi chân hướng lên, nghiêng tới), trunk stretch (bản dễ: tay để bên người), trunk twist (đầu thẳng hàng với thân); "nếu đau khớp hoặc cơ, chỉnh tư thế rồi thử lại, còn đau thì dừng" | đùi sau, nghiêng người khi ngồi, xoay thân, luật đau |
| NHS-HIP | NHS, [Recovering from a hip replacement](https://www.nhs.uk/tests-and-treatments/hip-replacement/recovering-from-a-hip-replacement/): không gập hông quá 90 độ, không vắt chân, không cúi chạm bàn chân hoặc cổ chân | luật ẩn cho "Joint replacement" |

**Thời gian giữ trong app (sửa 30/09/2026 theo [plan 4 nhóm](../plans/2026-09-30-content-4-groups.md) §2.3, chốt #2):** Gentle (Achy) **15 giây** · Steady (Okay) 20 giây · Strong (Great) 30 giây, **mỗi bên một lần**, cộng **vòng 2** cho 3 tư thế trọng tâm (calf hoặc thigh, chest, twist) ở Steady và Strong để tổng ≥ 45 giây mỗi nhóm cơ (STD §4.1). Bản 29/09 là 10 giây cho Gentle; hai lần mỗi bên cho mọi tư thế đã bỏ vì buổi Steady dài khoảng 13 phút. Nằm trong khoảng 10–30 giây của NIA-CALF; NHS dùng 2–10 giây với nhiều lần lặp, app chọn giữ lâu hơn ít lần hơn để giọng dẫn được. Không nhún, thở đều (NIA-3T).

**Đã bỏ so với spec 28/09/2026:** tư thế "Hips" (ngồi vắt cổ chân lên gối) — không có nguồn đã xác minh, và NHS-HIP cấm vắt chân sau thay khớp háng. Thay bằng "Side stretch" khi ngồi (NHS-LPT).

## 2. Danh sách tư thế (8, cộng 4 tư thế mới ở §8.1)
Mã tư thế dùng cho `exercises.json` (`kind: stretch`), clip V2b và voice line id. Cột "Ẩn với" là giá trị `hiddenFor` theo chip S06; "Bản dễ khi" là giới hạn khiến app tự dùng bản dễ.

| Mã | Tên hiển thị (D5) | Tư thế | Hai bên | Nguồn | Ẩn với | Bản dễ khi | Gợi ý trên màn (2) | Bản dễ |
|---|---|---|---|---|---|---|---|---|
| st.neck-turn | Neck turn | ngồi | có | NHS-SIT, NHS-FLEX | — | I get dizzy easily, Shoulders | Chin level, shoulders down · Only as far as is comfortable | Turn halfway, eyes open, move slowly |
| st.neck-tilt | Side of the neck | ngồi | có | NHS-FLEX | — | I get dizzy easily, Shoulders | Hand on the opposite shoulder · Ear toward shoulder, no pulling | Tilt a little, skip the hand on the shoulder |
| st.chest | Chest and shoulders | ngồi, xa lưng ghế | không | NHS-SIT | — | Shoulders | Shoulders back and down · Chest forward and up, gently | Hands resting on your hips instead of arms out |
| st.twist | Upper back twist | ngồi | có | NHS-SIT, NHS-LPT | — | Lower back | Arms crossed, hands on shoulders · Turn from the chest, hips stay still | Turn a small way, head in line with your body |
| st.side | Side stretch | ngồi | có | NHS-LPT | — | Lower back, Shoulders | Sit tall, feet flat · Reach up and over, or slide your hand down | Arm by your side, lean a little |
| st.thigh | Back of the thigh | ngồi, mép ghế | có | NHS-LPT | Joint replacement | Lower back, Knees | Heel down, toes up · Lean forward from the hips, back long | Keep the knee a little bent, lean only a little |
| st.ankle | Ankle circles and points | ngồi | có | NHS-SIT | — | Knees | Hold the side of the seat · Point your toes away, then back | Keep your heel on the floor, just lift and lower your toes |
| st.calf | Calf stretch | đứng sau ghế, hai tay vịn lưng ghế | có | NHS-FLEX, NIA-CALF | Standing for long is hard | Knees | Both feet flat, back heel down · Hold the chair the whole time | Shorter step back, back knee a little bent |

_Hai dòng dưới là buổi giãn cơ bản 29/09; buổi theo plan 4 nhóm ở §3._
**Bản ngồi (mặc định):** st.neck-turn, st.neck-tilt, st.chest, st.twist, st.side, st.thigh, st.ankle.
**Bản đứng vịn ghế:** st.calf thay st.side (7 tư thế). Luôn có màn chen "Stand behind your chair. Hold on with both hands." (dùng lại S12). Ghi chú điều chỉnh: NHS-FLEX và NIA-CALF dùng tường; app cho vịn lưng ghế chắc **hoặc** tường ("the back of a sturdy chair, or a wall") để khớp bối cảnh ghế của app.
**Hạ nhiệt sau đi bộ (sửa 30/09/2026 theo plan §2.3):** st.calf (buổi đứng) hoặc st.ankle (buổi Seated) 20 giây · st.thigh lưng thẳng 20 giây (ẩn với Joint replacement → st.ankle) · st.chest 15 giây + 3 hơi thở. Khe và ID ở §3.2.
**Luật "Joint replacement":** ẩn st.thigh (gập hông quá 90 độ, NHS-HIP); không có tư thế vắt chân hay cúi chạm bàn chân ở đâu cả. Bản dễ st.ankle giữ gót chạm sàn nên không cần cúi.
**Luật "I get dizzy easily":** cổ quay và nghiêng nửa tầm, chậm, mắt mở (lựa chọn thận trọng của app, không phải từ nguồn; ghi rõ để người đọc biết).

## 3. Khung buổi (sửa 30/09/2026 theo [plan 4 nhóm](../plans/2026-09-30-content-4-groups.md) §2.3; bảng 3 cường độ × 7 tư thế của 29/09 đã bỏ)

### 3.1 Bốn buổi giãn cơ + hạ nhiệt sau đi bộ
Giữ mỗi bên một lần: Gentle 15 s · Steady 20 s · Strong 30 s. Vòng 2 chỉ ở Steady và Strong. Neck turn, chin tuck, shoulder rolls, ankle là vận động chậm lặp lại (đếm hoặc đồng hồ), không giữ. Kết mọi buổi: thở NHS 30–60 s [S35].

| Buổi | Khung | Tư thế (thứ tự phát) | Vòng 2 | Ước tính Gentle / Steady / Strong |
|---|---|---|---|---|
| Gentle seated stretch 6 | 1:00 seated march + arm swing · 4:00 · 1:00 thở | neck turn · chin tuck · chest · twist (nhỏ) · thigh lưng thẳng (Joint replacement → ankle) · side | — | 7,0 / 7,6 / 8,8 phút |
| Seated stretch 8 | 1:30 · 5:30 · 1:00 | neck turn · neck tilt · chin tuck · shoulder rolls · chest · upper back · twist · thigh (hoặc ankle) · side | chest, twist, thigh | 9,8 / 12,9 / 15,4 phút |
| Gentle standing stretch 6 | 1:00 march + heel dig cạnh ghế · 4:00 · 1:00 | calf (vịn ghế) · overhead (tường) · rồi ngồi: side · chest · neck turn | — | 6,0 / 6,5 / 7,5 phút |
| Standing stretch 8 | 1:30 · 5:30 · 1:00 | calf · overhead · rồi ngồi: side · chest · upper back · twist · ankle · neck turn | calf, chest | 9,3 / 11,5 / 13,5 phút |
| Hạ nhiệt sau đi bộ | 2:00–2:30, không khởi động | calf (sau In place / Walking pad) hoặc ankle (sau Seated) 20 s · thigh lưng thẳng 20 s (Joint replacement → ankle) · chest 15 s + 3 hơi thở | — | cố định, không theo cường độ |

- **Ước tính** dùng nhịp của bản 29/09: tư thế hai bên = giới thiệu 5 s + dựng 7 s + "Let's start on the left" và vào tư thế 8 s + giữ + đổi bên 4 s + giữ + ra 4 s; một bên = 22 s + giữ; vòng 2 hai bên = 14 s + 2 lần giữ; tư thế lặp 32–68 s. Số phút trên thẻ phải lấy từ `build_content.py` (nguyên tắc 7 "thời lượng thật thà"), không lấy từ tên buổi. Hai buổi "8" vượt 8 phút ở Steady/Strong → câu hỏi cho chủ app ở §8.5.
- "Standing for long is hard": calf ẩn, overhead dùng bản ngồi (`a10.overhead.seated`) → hai buổi đứng thành gần như buổi ngồi; đề xuất ẩn hai buổi đứng với chip này.
- Câu thoại không đọc số giây giữ; chỉ "hold here, breathe" rồi đếm lùi bằng A5 ([A-min-support](A-min-support.md)).

### 3.2 Khe → ID
**Buổi giãn cơ (4 buổi):**
| Khe | Khi nào | Chọn từ |
|---|---|---|
| mở | 0:00 | `a9.gentle` / `a9.steady` / `a9.strong` (theo check-in) → `a10.open.1` (buổi ngồi) hoặc `a10.open.stand` (buổi đứng) → `a10.open.2` |
| an toàn (1 lần) | sau mở | `a7.dizzy` |
| khởi động | 0:12 → hết 1:00 / 1:30 | `a10.warm.1` → `a1.05`, `a1.06`, `a2.warm.1`, `a2.warm.4` (buổi đứng: thêm heel dig `a2.move.heel-dig.*` của [A2 đầy đủ](A2-walk.md)) → `a10.warm.end` |
| vào tư thế | mỗi tư thế | `a10.<tư thế>.intro` → `.setup` (hoặc `.easy` / `.back` / `.seated` theo chip) → `a10.left` (tư thế hai bên) → `.move` → `a10.into.1` / `.2` |
| bắt đầu giữ | 0 s của mỗi lần giữ | `a10.hold.start.1` / `.2` |
| giữa giữ | Steady +8 s · Strong +8 s và +18 s · Gentle không | `a10.hold.1–5` |
| đếm lùi | Gentle, Steady: giữ − 5 s · Strong: giữ − 10 s | `a5.5s` · `a5.10s` |
| đổi bên | sau lần giữ đầu | `a10.switch.1` / `.2` → bắt đầu giữ → giữa giữ → đếm lùi |
| ra tư thế | | `a10.release.1–3` |
| vòng 2 | ngay sau ra; Steady, Strong; chỉ tư thế ở cột "Vòng 2"; không đọc lại intro, setup | `a10.again` / `a10.round2.1` / `.2` → `a10.left` → giữ → đổi bên → giữ → `a10.release.*` |
| tư thế lặp | neck turn, chin tuck, shoulder rolls, ankle | `.intro` → `.setup` → `.move` → `a10.reps` → đếm `a5.n.*` (neck turn 5 mỗi bên, chin tuck 10, shoulder rolls 5; ankle đồng hồ 0:20 mỗi bên) → `a10.release.*` |
| sang tường / ngồi | buổi đứng | `a10.to-wall` trước overhead · `a10.to-sit` trước tư thế ngồi đầu tiên |
| sang tư thế kế | | `a10.next` |
| thở NHS | 1:00 cuối | `a10.breathe.open` → `a10.breathe.how` → (`a10.breathe.in` + `a10.breathe.out`) × 2 chu kỳ có giọng → `a10.breathe.mid` → 1–2 chu kỳ im (phụ đề "In… 2… 3… 4… 5" + đồng hồ) → `a10.breathe.end` |
| kết | | `a10.close.1` / `.2` |

**Hạ nhiệt sau đi bộ (nối sau `a9.to-stretch`):**
| Khe | Chọn từ |
|---|---|
| mở | `a10.cool.open` (sau Seated) · `a10.cool.open.stand` (sau In place, Walking pad) |
| calf 20 s (đứng) | `a10.calf.intro` → `.setup` → `a10.left` → `.move` → `a10.hold.start.*` → `a10.hold.3` (+8 s) → `a5.5s` → `a10.switch.1` → giữ → `a10.release.1` → `a10.to-sit` |
| ankle 20 s (ngồi) | `a10.ankle.intro` → `.setup` → `.move` → `a10.switch.1` → `a10.release.1` |
| thigh 20 s | `a10.thigh.intro` → `.setup` → `a10.left` → `.move` (Lower back: `.back`) → giữ như calf → `a10.release.2` |
| chest 15 s + 3 hơi thở | `a10.chest.intro` → `.setup` → `.move` → `a10.hold.start.1` → `a10.hold.1` × 3 (mỗi câu một hơi thở) → `a10.release.2` |
| kết | `a10.cool.close` |

## 4. Câu thoại
Giọng như A1: nữ 58–65, trầm ấm, khoảng 130 từ/phút, không gọi tên, bản dễ trước. Chỉ nói cảm giác ("a gentle pull", "breathe into it"), không hứa hết đau, sửa tư thế hay chữa khớp. Không từ cấm. Phụ đề = đúng chữ. "…" = nghỉ khoảng 2 giây.

### 4.1 Câu dùng chung
| ID | Khi nào | Câu thoại |
|---|---|---|
| a10.open.1 | mở buổi, ngồi | Time for a gentle stretch. Sit toward the front of your chair, feet flat on the floor. |
| a10.open.2 | mở buổi, ngồi | We'll move slowly and breathe. Stretch to a gentle pull, never to pain. |
| a10.open.stand | mở buổi, bản đứng | Stand behind your chair and hold the back with both hands. Feet about hip-width apart. |
| a10.cool.open | mở hạ nhiệt sau đi bộ | Lovely walking. Stay seated, and let's cool down with a few easy stretches. |
| a10.into.1 | vào tư thế | Ease into it slowly. |
| a10.into.2 | vào tư thế | Go only as far as feels comfortable. |
| a10.hold.1 | giữa lúc giữ | Breathe in through your nose… and out through your mouth. |
| a10.hold.2 | giữa lúc giữ | Breathe into it. Let your shoulders stay soft. |
| a10.hold.3 | giữa lúc giữ | A gentle pull is enough. No bouncing. |
| a10.hold.4 | giữa lúc giữ | Keep breathing. There's no need to push. |
| a10.hold.5 | giữa lúc giữ | If it pinches or hurts, ease off a little. |
| a10.left | bắt đầu bên trái | Let's start on the left. |
| a10.switch.1 | đổi bên | And the other side. |
| a10.switch.2 | đổi bên | Come back to the middle… and now the other side. |
| a10.again | lần lặp thứ hai | Once more, just as gently. |
| a10.release.1 | ra tư thế | And slowly come back. |
| a10.release.2 | ra tư thế | Gently release, and sit tall. |
| a10.release.3 | ra tư thế | Relax. Notice how that feels. |
| a10.next | chuyển tư thế | Next one coming up. |
| a10.easier | khi bấm Easier version | Here's an easier way. Smaller and slower is just as good. |
| a10.close.1 | kết buổi | That's your stretch for today. Take one more slow breath. |
| a10.close.2 | kết buổi | Nice and easy. You gave your body some care today. |
| a10.cool.close | kết hạ nhiệt | All done. Sit for a moment, and have a sip of water. |

### 4.2 Câu theo tư thế
| ID | Câu thoại |
|---|---|
| a10.neck-turn.intro | Neck turns. They make it easier to look over your shoulder. |
| a10.neck-turn.setup | Sit tall, shoulders down, and look straight ahead. |
| a10.neck-turn.move | Slowly turn your head toward your shoulder, as far as is comfortable. |
| a10.neck-turn.easy | Just turn halfway, nice and slow, and keep your eyes open. |
| a10.neck-tilt.intro | Now the side of your neck. |
| a10.neck-tilt.setup | Rest your right hand on your left shoulder, and let that shoulder stay low. |
| a10.neck-tilt.move | Slowly tilt your head to the right, ear toward your shoulder. No pulling. |
| a10.neck-tilt.easy | Skip the hand, and just tilt your head a little. |
| a10.chest.intro | Chest and shoulders. Good for sitting tall. |
| a10.chest.setup | Sit forward, away from the back of your chair. |
| a10.chest.move | Draw your shoulders back and down. Open your arms to the sides, and lift your chest gently. |
| a10.chest.easy | Rest your hands on your hips, and just draw your shoulders back. |
| a10.twist.intro | Upper back twist. It helps with turning to reach for things. |
| a10.twist.setup | Cross your arms and rest your hands on your shoulders. Feet flat. |
| a10.twist.move | Turn your upper body to one side. Your hips stay still, your head turns with you. |
| a10.twist.easy | Turn just a small way. That's plenty. |
| a10.side.intro | Side stretch. |
| a10.side.setup | Sit tall with your feet flat and a little apart. |
| a10.side.move | Reach one arm up and over your head, and lean gently to the other side. |
| a10.side.easy | Keep your arm by your side, and just lean a little. |
| a10.thigh.intro | The back of your thigh. It makes bending down a little easier. |
| a10.thigh.setup | Sit near the front of your chair. Stretch one leg out, heel on the floor, toes pointing up. |
| a10.thigh.move | Rest your hands on your other leg. Lean forward from your hips, and keep your back long. |
| a10.thigh.easy | Keep that knee a little bent, and lean forward only a little. |
| a10.ankle.intro | Ankles. For steadier steps. |
| a10.ankle.setup | Hold the side of your seat, and lift one foot just off the floor. |
| a10.ankle.move | Point your toes away from you… then bring them back toward you. Slow and smooth. |
| a10.ankle.easy | Keep your heel on the floor, and just lift and lower your toes. |
| a10.calf.intro | Calf stretch. Hold on to your chair the whole time. |
| a10.calf.setup | Hands on the back of your chair. Step one foot back, and keep both feet flat. |
| a10.calf.move | Bend your front knee a little, keep the back leg straight and the heel down. You'll feel it in your calf. |
| a10.calf.easy | Take a shorter step back, and let your back knee bend a little. |

**Ghi chú:** st.ankle là chuyển động chậm lặp lại (NHS-SIT: 2 × 5 lần mỗi chân), không phải giữ tĩnh; màn S12b hiện đồng hồ 0:20 thay cho giữ, giọng nhắc "slow and smooth" thay câu thở. Đồng hồ và nhãn Left side / Right side giữ nguyên như spec.

Tổng: 23 câu dùng chung + 32 câu tư thế = **55 câu**, khoảng 620 từ.

## 5. Ví dụ ghép: tư thế st.thigh, Steady, bên trái
| Thời điểm | Câu (ID) | Màn S12b |
|---|---|---|
| 0:00 | a10.thigh.intro | tên "Back of the thigh", video pha vào |
| 0:05 | a10.thigh.setup | |
| 0:12 | a10.left | nhãn Left side |
| 0:14 | a10.thigh.move | |
| 0:20 | — | video dừng ở khung giữ, đồng hồ 0:20 bắt đầu |
| 0:30 | a10.hold.3 | |
| 0:40 | a10.switch.1 | nhãn Right side, video ra rồi vào bên kia |
| 0:44 | — | giữ 0:20 |
| 0:54 | a10.hold.1 | |
| 1:04 | a10.release.1 | |
| 1:08 | a10.again | lần 2 hai bên, không lặp giới thiệu |

## 6. Clip V2b cần tạo (sau khi chủ app duyệt kịch bản; báo giá credit trước)
| Mã clip | Tư thế | Góc máy | Ghi chú |
|---|---|---|---|
| V7-1 | st.neck-turn + st.neck-tilt | chính diện, cùng khung V2 | một clip hai động tác cổ, trái rồi phải |
| V7-2 | st.chest | chính diện | ngồi xa lưng ghế |
| V7-3 | st.twist | chính diện | trái rồi phải |
| V7-4 | st.side | chính diện | trái rồi phải |
| V7-5 | st.thigh | nghiêng từ bên phải, cùng khung V3 | chân gần máy rồi chân xa |
| V7-6 | st.ankle | nghiêng, cùng khung V4 | chân gần máy rồi chân xa |
| V7-7 | st.calf | nghiêng, cùng khung V6 | đứng sau ghế, chân gần máy lùi rồi chân xa |
_30/09/2026: mã clip giãn cơ đổi từ V7-x sang **S1–S12** (plan 4 nhóm §3, bảng mã ở [P-production-prompts.md](P-production-prompts.md) §0.1); bảng trên giữ làm lịch sử._
Khung giữ: app dừng video ở khung giữ (task 4.8), nên prompt cần một đoạn giữ yên 2–3 giây ở mỗi bên để lấy khung. Tạm dùng Flow Pro (chốt 29/09/2026), tạo lại trên gói không watermark trước khi nộp.

## 7. Cần kiểm tra
- Nghe thử: câu thoại có kịp trong 20 giây giữ không; st.twist và st.neck-turn có rõ "bên nào" khi chỉ nghe không.
- Test prototype (sau khi code MVP): ≥ 6/8 người vào đúng tư thế và đổi bên đúng chỉ bằng giọng (tiêu chí 3 trong docs/research/prototype-test-plan.md).
- Verify lại trang NIA Go4Life (calf, thời gian giữ) khi mở được.

## 8. Mở rộng 30/09/2026 (M4 — plan 4 nhóm §2.3, §4.2)
_Nguồn: [plan 4 nhóm](../plans/2026-09-30-content-4-groups.md) §2.3; mã `[S#]` là nguồn trong [STD](../research/2026-09-30-exercise-standards.md) §9 (F3, F4, F6, F9, F17 ở STD §4.2). Tên tư thế khớp đúng D5 ([D-min-texts.md](D-min-texts.md) "D5 — bài mới 30/09/2026"). Luật viết: ≤ 16 từ mỗi câu, bản dễ trước, "a gentle pull, never pain", không đọc số giây giữ, không ngửa cổ, không hứa sửa tư thế hay chữa khớp._

### 8.1 Bốn tư thế mới
| Mã | Tên (D5) | Tư thế | Hai bên | Liều | Nguồn | Bản dễ khi | Clip |
|---|---|---|---|---|---|---|---|
| st.chin-tuck | Chin tuck | ngồi | không | 10 lần chậm (Morning stretch: 5) | [S16 p.7] | nút Easier | S3 |
| st.shoulder-roll | Shoulder rolls | ngồi | không | 5 vòng chậm | đề xuất app (STD F4) | Shoulders | S4 |
| st.upper-back | Upper back reach | ngồi | không | giữ 15 / 20 / 30 s | [S9 p.78] | Lower back (gồm "or bone thinning"), Shoulders | S6 |
| st.overhead | Overhead reach at the wall | đứng đối tường; bản ngồi | không | giữ 15 / 20 / 30 s | [S9 p.74] | Shoulders (tới ngang mắt); Standing for long is hard → bản ngồi | S12 |
Không tư thế mới nào ẩn với Joint replacement (không gập hông, không bắt chéo chân). Upper back reach với Lower back: lưng thẳng, chỉ vươn tay (STD §3.3, [S32]); không nhắc tên bệnh trong giọng.

### 8.2 Câu thoại mới
| ID | Câu thoại | Ghi chú |
|---|---|---|
| a10.chin-tuck.intro | Chin tuck. A small, gentle move for your neck. | |
| a10.chin-tuck.setup | Sit tall and look straight ahead. Eyes stay level, and never tip your head back. | [S16 p.7] "careful not to look up" |
| a10.chin-tuck.move | Glide your head straight back, like a gentle double chin… then let it go. | khớp clip S3 |
| a10.chin-tuck.easy | Make the glide smaller. A tiny movement is plenty. | |
| a10.shoulder-roll.intro | Shoulder rolls. A nice way to loosen up your shoulders. | |
| a10.shoulder-roll.setup | Sit tall, with your hands resting on your thighs. | khớp clip S4 |
| a10.shoulder-roll.move | Roll your shoulders up, back, and down, in one slow circle. | |
| a10.shoulder-roll.easy | Make the circles smaller, and keep them slow. | chip Shoulders |
| a10.upper-back.intro | Upper back reach. You'll feel it between your shoulder blades. | |
| a10.upper-back.setup | Sit tall. Bring both arms forward at shoulder height, palms facing away. | khớp clip S6 |
| a10.upper-back.move | Reach your hands forward, and let your upper back round a little. Your lower back stays tall. | |
| a10.upper-back.easy | Keep your whole back tall, and just reach your arms. Hands a little lower is fine. | chip Lower back, Shoulders |
| a10.overhead.intro | Overhead reach at the wall. It helps with reaching a high cupboard. | |
| a10.overhead.setup | Stand facing the wall, close enough to rest your palms on it at shoulder height. | khớp clip S12 |
| a10.overhead.move | Slowly walk your hands up the wall, as high as is comfortable. Keep your heels down, and don't arch your back. | |
| a10.overhead.easy | Only reach up to eye level. That's plenty. | chip Shoulders; dùng cả cho bản ngồi |
| a10.overhead.seated | Stay in your chair instead. Sit tall, and slowly reach both arms up in front of you. | chip Standing for long is hard |
| a10.thigh.back | Just stretch the leg out and sit tall. No need to lean forward. | chip Lower back (plan §2.3: chỉ duỗi chân, không nghiêng) |
| a10.warm.1 | Let's warm up first. Easy marching, and let your arms swing. | cơ ấm trước khi giãn [S9 p.70] |
| a10.warm.end | Nice and warm. Now let's start stretching. | |
| a10.hold.start.1 | Hold here, and breathe. | thay cho đọc số giây |
| a10.hold.start.2 | Stay right there. Nice, slow breaths. | |
| a10.round2.1 | Once more. It may feel a little easier to settle in. | vòng 2, xoay vòng với `a10.again` |
| a10.round2.2 | Let's go back into that one. Ease in, a little at a time. | |
| a10.reps | Slow and gentle. I'll count for you. | tư thế lặp |
| a10.to-wall | Let go of the chair when you feel steady, and walk over to a wall. | buổi đứng, trước overhead |
| a10.to-sit | Now come and sit down. Sit toward the front of your chair, feet flat. | buổi đứng, trước tư thế ngồi |
| a10.cool.open.stand | Lovely walking. Stay close to your chair, and let's cool down with a few easy stretches. | hạ nhiệt sau In place, Walking pad |
| a10.breathe.open | Let's finish with some slow breathing. Sit back in your chair, feet flat. | NHS [S35]: ghế tựa lưng, chân phẳng |
| a10.breathe.how | Breathe in through your nose for a count of five. Then out through your mouth for five. | [S35] |
| a10.breathe.in | In through your nose… two… three… four… five. | đọc 1 số mỗi giây |
| a10.breathe.out | And out through your mouth… two… three… four… five. | đọc 1 số mỗi giây |
| a10.breathe.mid | Gentle breaths. There's no need to force them. | sau chu kỳ 2 |
| a10.breathe.end | Let your breathing go back to its own easy pace. | |

**Sản xuất giọng:** `a10.breathe.in` / `.out` đọc chậm, mỗi số cách khoảng 1 giây (`<break time="0.8s" />`, ≤ 2 tag mỗi câu theo PROMPTS §7.1, còn lại dùng "…"); đo độ dài file sau khi tạo, mục tiêu 5–6 giây mỗi câu. Hai chu kỳ có giọng ≈ 25 s, thêm 1–2 chu kỳ im → 30–60 s.

### 8.3 Tổng
Mới: 18 câu tư thế (4 tư thế × 4–5 + `a10.thigh.back`) + 16 câu khung, giữ, vòng 2, thở = **34 câu**. Cộng 55 câu cũ = **89 câu**. Dùng lại từ file khác: `a1.05`, `a1.06`, `a2.warm.*`, `a5.5s`, `a5.10s`, `a5.n.*`, `a7.dizzy`, `a9.*`.

### 8.4 Thay đổi so với bản 29/09
| Chỗ | Đổi | Lý do |
|---|---|---|
| §1 thời gian giữ | Gentle 10 s → 15 s; thêm vòng 2 cho calf/thigh, chest, twist ở Steady, Strong | plan §2.3, chốt #2 ngày 30/09 |
| §2 hạ nhiệt sau đi bộ | neck turn · thigh · chest 15 s → calf hoặc ankle 20 s · thigh 20 s · chest 15 s + 3 hơi thở | plan §2.3 |
| §3 | viết lại: 4 buổi + hạ nhiệt, bảng khe → ID; bỏ bảng 3 cường độ × 7 tư thế | plan §2.3; nhiệm vụ M4 |
| `a10.chest.move` | tách thành 2 câu, giữ nguyên chữ | 17 từ > 16 (plan §4.1) |
| `a10.thigh.move` | tách thành 2 câu ("keeping" → "and keep") | 17 từ > 16 (plan §4.1) |
| §6 | ghi chú mã clip V7-x → S1–S12 | plan §3, PROMPTS §0.1 |
Không đổi ID nào; không xoá câu nào. `a10.again` (trước đây "dành cho bản đầy đủ") nay dùng cho vòng 2.

### 8.5 Cần kiểm tra / hỏi chủ app
- **Thời lượng:** theo ước tính §3.1, Seated stretch 8 ≈ 12,9 phút (Steady) và 15,4 phút (Strong); Standing stretch 8 ≈ 11,5 / 13,5 phút. Chọn: (a) bỏ vòng 2 ở hai buổi "8", (b) bớt 2–3 tư thế, hoặc (c) giữ nội dung, thẻ hiện số phút thật từ `build_content.py`.
- **Vòng 2 ngay sau vòng 1** của cùng tư thế (như ví dụ §5) hay gom cuối buổi? Bản này chọn ngay sau, để không phải đọc lại setup.
- Hai buổi đứng với "Standing for long is hard": ẩn hẳn hay thay bằng bản ngồi?
- Nghe thử `a10.breathe.in` / `.out`: đếm có đều 1 giây không; nếu TTS đọc nhanh, tách thành 5 file số riêng.
