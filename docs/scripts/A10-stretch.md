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

**Thời gian giữ trong app:** Gentle (Achy) 10 giây · Steady (Okay) 20 giây · Strong (Great) 30 giây, **mỗi bên một lần** (sửa 29/09/2026: hai lần mỗi bên làm buổi Steady dài khoảng 13 phút, vượt khung 5–10 phút). Nằm trong khoảng 10–30 giây của NIA-CALF; NHS dùng 2–10 giây với nhiều lần lặp, app chọn giữ lâu hơn ít lần hơn để giọng dẫn được. Không nhún, thở đều (NIA-3T).

**Đã bỏ so với spec 28/09/2026:** tư thế "Hips" (ngồi vắt cổ chân lên gối) — không có nguồn đã xác minh, và NHS-HIP cấm vắt chân sau thay khớp háng. Thay bằng "Side stretch" khi ngồi (NHS-LPT).

## 2. Danh sách tư thế (8)
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

**Bản ngồi (mặc định):** st.neck-turn, st.neck-tilt, st.chest, st.twist, st.side, st.thigh, st.ankle.
**Bản đứng vịn ghế:** st.calf thay st.side (7 tư thế). Luôn có màn chen "Stand behind your chair. Hold on with both hands." (dùng lại S12). Ghi chú điều chỉnh: NHS-FLEX và NIA-CALF dùng tường; app cho vịn lưng ghế chắc **hoặc** tường ("the back of a sturdy chair, or a wall") để khớp bối cảnh ghế của app.
**Hạ nhiệt sau đi bộ (2 phút, luôn ngồi):** st.neck-turn, st.thigh (ẩn với Joint replacement → thay st.ankle), st.chest. Giữ 15 giây mỗi bên, một lần.
**Luật "Joint replacement":** ẩn st.thigh (gập hông quá 90 độ, NHS-HIP); không có tư thế vắt chân hay cúi chạm bàn chân ở đâu cả. Bản dễ st.ankle giữ gót chạm sàn nên không cần cúi.
**Luật "I get dizzy easily":** cổ quay và nghiêng nửa tầm, chậm, mắt mở (lựa chọn thận trọng của app, không phải từ nguồn; ghi rõ để người đọc biết).

## 3. Thời lượng buổi (khớp S10 biến thể ngày giãn cơ, task 2.8; số đo từ sessions.json do tools/content/build_content.py sinh)
| Cường độ | Giữ mỗi bên | Số tư thế | Tổng |
|---|---|---|---|
| Gentle (Achy) | 10 giây × 1 | 7 | khoảng 5,5 phút |
| Steady (Okay) | 20 giây × 1 | 7 | 7,9 phút (bản ngồi) · 8,0 phút (bản đứng) |
| Strong (Great) | 30 giây × 1 | 7 | khoảng 10 phút |
Một tư thế hai bên (Steady): giới thiệu 5 s · dựng tư thế 7 s · "Let's start on the left" + vào tư thế 8 s · giữ 20 s (một câu thở ở giữa) · đổi bên 4 s · giữ 20 s · ra tư thế 4 s = 68 s. Hạ nhiệt sau đi bộ: bỏ câu dựng tư thế, giữ 15 giây, tổng 2,4 phút. `a10.again` dành cho bản đầy đủ sau này.

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
| a10.chest.move | Draw your shoulders back and down, open your arms to the sides, and lift your chest gently. |
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
| a10.thigh.move | Rest your hands on your other leg, and lean forward from your hips, keeping your back long. |
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
Khung giữ: app dừng video ở khung giữ (task 4.8), nên prompt cần một đoạn giữ yên 2–3 giây ở mỗi bên để lấy khung. Tạm dùng Flow Pro (chốt 29/09/2026), tạo lại trên gói không watermark trước khi nộp.

## 7. Cần kiểm tra
- Nghe thử: câu thoại có kịp trong 20 giây giữ không; st.twist và st.neck-turn có rõ "bên nào" khi chỉ nghe không.
- Test prototype (sau khi code MVP): ≥ 6/8 người vào đúng tư thế và đổi bên đúng chỉ bằng giọng (tiêu chí 3 trong docs/research/prototype-test-plan.md).
- Verify lại trang NIA Go4Life (calf, thời gian giữ) khi mở được.
