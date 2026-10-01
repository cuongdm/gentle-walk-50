# A4 — Động tác ghế (12 động tác, 3 buổi) · bản nháp 2
_30/09/2026 (M4) · Theo [app-context.md](../../app-context.md) (Tone & copy rules, chip cơ thể), [plans/2026-09-30-content-4-groups.md](../plans/2026-09-30-content-4-groups.md) §1, §2.2, §4.1, [STD](../research/2026-09-30-exercise-standards.md) §3, §5, §8.2, [CMP](../research/2026-09-30-competitor-4-groups.md) §3–4, [P-production-prompts.md](P-production-prompts.md) §4 (clip V8–V13) · Chữ thoại tiếng Anh Mỹ, ghi chú tiếng Việt_

File này **thay** danh sách "Lời giọng A4" trong [V-exercise-clips.md](V-exercise-clips.md) §2 làm nguồn duy nhất cho câu A4. 41 câu cũ giữ ID `a4.v<n>.<k>` và chữ (trừ 5 câu ở mục 7 "Thay đổi"). Câu đếm, báo trước, an toàn chung ở [A-min-support.md](A-min-support.md) (A5, A7, A9); khởi động dùng [A1](A1-first-walk.md); hạ nhiệt dùng [A10](A10-stretch.md).

## 0. Quy ước
- Mỗi câu ≤ 16 từ, ngôi thứ hai, không gọi tên, bản dễ nói trước bản khó; bản khó chỉ phát ở Steady/Strong.
- Cột cuối mỗi bảng là câu thoại (cho `build_content.py`: chữ lấy từ ô cuối). "…" = nghỉ khoảng 1–2 giây. Phụ đề = đúng chữ.
- ID: câu cũ `a4.v<n>.<k>`, câu thêm cho bài cũ `a4.v<n>.<khe>`, bài mới `a4.<slug>.<khe>`, câu chung `a4.<khe>.<n>`.
- Trái/phải: bài một bên dùng `a4.side.right` hoặc `a4.side.left` theo **bên đầu tiên trong clip** (khai báo `firstSide` trong `exercises.json`), đổi bên bằng `a5.side`. "Right" = chân phải của người tập. Không nói bên nào khi clip chưa có số liệu.
- Đau: luôn "a gentle effort, never pain"; không "push through"; không số sức khoẻ, không kcal, không hứa lợi ích y khoa hay giảm ngã.

### 0.1 Bảng động tác
| Mã | Tên (giọng + thẻ, cố định) | Clip | Tiền tố ID | Tư thế | Đếm |
|---|---|---|---|---|---|
| mv.sit-to-stand | Sit-to-stand | V1-1 | a4.v1 | ngồi → đứng | rep 5–12 |
| mv.knee-lift | Seated knee lift | V2-1 | a4.v2 | ngồi | giờ 30–45 s |
| mv.leg-ext | Seated leg extension | V3-1 | a4.v3 | ngồi | giờ 30–45 s |
| mv.heel-toe | Heel and toe raises | V4-1 | a4.v4 | ngồi (khó: đứng vịn) | giờ 30–45 s |
| mv.wall-push | Wall push-up | V5-1 | a4.v5 | đứng, tường | rep 6–12 |
| mv.single-leg | Single-leg stand | V6-1 | a4.v6 | đứng sau ghế | giữ 5–10 s mỗi bên |
| mv.side-leg | Side leg raise | V8-1 | a4.side-leg | đứng sau ghế, 2 tay | rep 6–12 (chia hai bên) |
| mv.back-leg | Back leg raise | V9-1 | a4.back-leg | đứng sau ghế, 2 tay | rep 6–12 (chia hai bên) |
| mv.knee-curl | Knee curl | V10-1 | a4.knee-curl | đứng sau ghế, 2 tay | rep 6–12 (chia hai bên) |
| mv.mini-squat | Mini-squat | V11-1 | a4.mini-squat | đứng, 2 tay lưng ghế | rep 6–10 |
| mv.arm-raise | Arm raises | V12-1 | a4.arm-raise | ngồi | rep 6–12 (trước rồi ngang) |
| mv.row | Seated row | V13-1 | a4.row | ngồi | rep 6–12 |
Tên thẻ trong plan có ngoặc "(front/side)", "(no band)" — giọng chỉ đọc phần trước ngoặc; thẻ nên hiện đúng như cột này (câu hỏi #2).

## 1. Nhịp và liều (plan §1 nguyên tắc 5, STD §3.1, §7)
| Mục | Giá trị |
|---|---|
| Nhịp một rep | 2–3 s lên · 1 s giữ · 3–4 s xuống (≈ 6–8 s/rep). Clip V8–V13 tạo ở 2/1/2 s; bản chậm dựng bằng time-remap (P §6) |
| Rep | 6–12 mỗi bài; sit-to-stand 5–12; mini-squat 6–10. Gentle 5–8 · Steady 8–10 · Strong 10–12, nhưng không vượt số rep vừa khung giờ |
| Bài tính giờ | 30–45 s (knee lift, leg ext, heel-toe); single-leg giữ 5–10 s mỗi bên |
| Dừng set | khi còn làm được khoảng 2 rep (Otago) → câu `a4.count.stop` |
| Nghỉ giữa bài | 15 s = 3 hơi thở (Stronger: 10 s); đổi ngồi ↔ đứng: 30 s kèm câu chuyển |
| Thở | thở ra khi gắng (lên, đẩy, kéo), hít vào khi trở về; không bao giờ nín thở |

## 2. Câu dùng chung (mới)
| ID | Khi nào | Câu thoại |
|---|---|---|
| a4.warm.1 | mở khởi động (ngồi) | Let's warm up in your chair first. An easy march to start. |
| a4.warm.toe | khởi động, sau march | Now toe taps. Heels stay down, lift your toes and tap them. |
| a4.warm.done | cuối khởi động | Nice and warm. Let's start the moves. |
| a4.demo.1 | trước rep demo | Watch one first. |
| a4.demo.2 | trước rep demo (biến thể) | Just watch this first one. No need to move yet. |
| a4.demo.3 | trước rep demo (biến thể) | Watch me do one, nice and slow. |
| a4.with-me.1 | sau rep demo | Now with me. |
| a4.with-me.2 | sau rep demo (biến thể) | Your turn. Let's do it together. |
| a4.with-me.3 | sau rep demo (biến thể) | Now with me, at your own pace. |
| a4.breath.1 | giữa bài, mọi bài rep | Breathe out as you lift, breathe in as you lower. |
| a4.breath.2 | giữa bài | Keep breathing. Never hold your breath. |
| a4.slow.1 | giữa bài rep | Slow on the way down. No dropping. |
| a4.slow.2 | giữa bài rep (biến thể) | Smooth and steady. Slower is better here. |
| a4.count.1 | trước khi đếm rep | I'll count with you. |
| a4.count.stop | giữa set, một lần | Stop while you could still do two more. That's the right effort. |
| a4.pain.1 | mở buổi, một lần | A gentle effort, never pain. |
| a4.pain.2 | giữa bài, khi hợp | If it hurts, make it smaller or skip it. |
| a4.range | giữa bài, biến thể theo chip | Move only as far as feels comfortable. |
| a4.rest.1 | nghỉ 15 s | Rest. Three easy breaths. |
| a4.rest.2 | nghỉ (biến thể) | Let your arms and legs relax. Breathe in… and out. |
| a4.rest.3 | nghỉ (biến thể) | Shake out your hands. Next move in a moment. |
| a4.stand.setup | trước mọi bài đứng sau ghế | Stand behind your chair, both hands on the chair back. |
| a4.stand.feet | sau `a4.stand.setup` | Feet hip-width apart, knees soft. |
| a4.stand.chair | lần đầu có bài đứng | Use a sturdy chair that won't slide. A kitchen counter works too. |
| a4.to-stand.1 | chuyển ngồi → đứng (30 s) | Hands on the chair, take a breath, then stand. |
| a4.to-stand.2 | sau khi đứng lên | Stand still for a breath before we start. |
| a4.to-stand.sts | rep cuối sit-to-stand, khi bài sau là bài đứng | After this last one, stay standing. |
| a4.to-stand.behind | sau `a4.to-stand.sts` | Now step behind your chair and hold on with both hands. |
| a4.to-sit.1 | chuyển đứng → ngồi (30 s) | Walk around to the front of your chair. Take your time. |
| a4.to-sit.2 | sau `a4.to-sit.1` | Reach back for the seat, and sit down slowly. |
| a4.side.right | bài một bên, clip bắt đầu chân phải | Start with your right leg. |
| a4.side.left | bài một bên, clip bắt đầu chân trái | Start with your left leg. |
| a4.rotate.1 | mở buổi khi bài khác lần trước | A few different moves today, to keep things fresh. |
| a4.rotate.2 | lần đầu gặp một bài | This one is new. We'll take it slow. |

**Dùng lại từ file khác (không viết lại, không để ID ở ô đầu):** mở buổi `a9.chair.open`, `a9.gentle` / `a9.steady` / `a9.strong`; chuyển bài `a9.next-move`; kết `a9.chair.close`; đếm `a5.n.1`–`a5.n.15`; "two more" `a5.two-more`, "last two" `a5.last-two`, "last one" `a5.last`, `a5.one-more`; báo trước `a5.10s.change`, `a5.10s.rest`, `a5.10s`; đổi bên `a5.side`; an toàn `a7.stand`, `a7.stand.ready`, `a7.stop.1`, `a7.stop.2`, `a7.dizzy`; This hurts `a7.hurt.*`.

## 3. Sáu động tác có sẵn (câu cũ + câu thêm)
Thứ tự phát trong một bài: intro → setup → `a4.demo.*` → câu mô tả động tác → `a4.with-me.*` → câu thở → bản dễ → gợi ý tư thế → bản khó (Steady/Strong) → báo trước → kết. Câu cũ theo đúng số thứ tự; câu thêm chèn theo cột "Khi nào".

### 3.1 Sit-to-stand · V1-1
| ID | Khi nào | Câu thoại |
|---|---|---|
| a4.v1.1 | intro | Sit-to-stand. It helps with getting up from any chair. |
| a4.v1.2 | setup | Scoot to the front of your chair. Feet flat, about hip-width apart. |
| a4.v1.3 | bản dễ (nói trước) | If you need help, put your hands on the chair and push. That's a great way to start. |
| a4.v1.4 | demo / mỗi rep | Lean forward, nose over toes… and stand up. |
| a4.v1.5 | pha xuống | Now sit back down, slowly. Reach back for the chair with your hips. |
| a4.v1.6 | giữa set | Take a breath whenever you need one. |
| a4.v1.7 | bản khó | Want more? Cross your arms over your chest, and sit down on a slow count of three. |
| a4.v1.8 | rep cuối | Lovely. That's your last one. |
| a4.v1.breath | sau "now with me" | Breathe out as you stand, breathe in as you sit. |
| a4.v1.top | đứng thẳng, rep đầu | Stand all the way up, and take one full breath. |
| a4.v1.var.joint | chip Joint replacement, thay a4.v1.2 | Use a higher chair today, with arms if you have one. |
| a4.v1.var.joint-lean | chip Joint replacement, thay a4.v1.4 | Keep your chest up, lean only a little… and stand up. |

### 3.2 Seated knee lift · V2-1
| ID | Khi nào | Câu thoại |
|---|---|---|
| a4.v2.1 | intro | Seated knee lift. The same move you use for every step. |
| a4.v2.2 | setup | Hold the sides of your seat lightly. Sit tall. |
| a4.v2.3 | bản dễ (nói trước) | Start small. Just lift your heel, then set it down. |
| a4.v2.4 | vào bản chính | If that feels fine, lift your whole knee a little. Then switch sides. |
| a4.v2.5 | gợi ý tư thế | Keep your back tall. No need to lean back. |
| a4.v2.6 | bản khó | Want more? Lift a little higher and swing the opposite arm. |
| a4.v2.7 | báo trước | Nice and steady. Ten more seconds. |
| a4.v2.var.joint | chip Joint replacement | Keep your knee lower than your hip. A small lift is plenty. |

### 3.3 Seated leg extension · V3-1
| ID | Khi nào | Câu thoại |
|---|---|---|
| a4.v3.1 | intro | Seated leg extension. The move you use for climbing stairs. |
| a4.v3.2 | setup | Sit tall and hold the sides of your seat. |
| a4.v3.3 | bản dễ (nói trước) | Start with a small lift. Straighten your leg just halfway. |
| a4.v3.4 | vào bản chính | If that's comfortable, straighten it more, toes to the ceiling. Keep the knee soft. |
| a4.v3.5 | gợi ý tư thế | Keep your leg pointing straight ahead… and lower it slowly. |
| a4.v3.6 | bản khó | Want more? Hold it up for a count of three. |
| a4.v3.7 | đau gối | If your knee complains, make the lift smaller. That still counts. |
| a4.v3.breath | sau "now with me" | Breathe out as you straighten, breathe in as you lower. |

### 3.4 Heel and toe raises · V4-1
| ID | Khi nào | Câu thoại |
|---|---|---|
| a4.v4.1 | intro | Heel and toe raises. The move you use for reaching a high shelf. |
| a4.v4.2 | setup | Sit tall, feet flat on the floor. |
| a4.v4.3 | pha gót | Lift your heels a little, then lower them. |
| a4.v4.4 | pha mũi (khớp clip: 2 gót rồi 2 mũi) | Now the other way. Lift your toes, heels stay down. |
| a4.v4.5 | bản dễ / trấn an | Small and easy is perfect. |
| a4.v4.6 | bản khó (ẩn khi Dizzy, Standing is hard) | Want more? Stand behind your chair, hold on with both hands, and rise onto your toes. |
| a4.v4.var.dizzy | chip Dizzy, thay a4.v4.6 | Let's keep this one seated today. |

### 3.5 Wall push-up · V5-1 (ẩn khi Standing is hard)
| ID | Khi nào | Câu thoại |
|---|---|---|
| a4.v5.1 | intro | Wall push-up. It makes pushing doors and lifting bags easier. |
| a4.v5.2 | setup | Stand about an arm's length from the wall. Hands flat, at shoulder height. |
| a4.v5.3 | bản dễ (nói trước) | Start by standing a little closer. Bend your elbows just a bit. |
| a4.v5.4 | demo / mỗi rep | Bring your chest toward the wall… and press back. |
| a4.v5.5 | gợi ý tư thế | Keep your body straight, like a plank of wood. |
| a4.v5.6 | bản khó | Want more? Step your feet back a little. |
| a4.v5.breath | sau "now with me" | Breathe in as you lean in, breathe out as you press back. |
| a4.v5.heels | gợi ý tư thế | Heels stay on the floor. Arms straight at the end, not locked. |
| a4.v5.var.shoulder | chip Shoulders, thay a4.v5.4 | Keep it small. Bend your elbows only a little, then press back. |

### 3.6 Single-leg stand · V6-1
| ID | Khi nào | Câu thoại |
|---|---|---|
| a4.v6.1 | intro + setup | Single-leg stand. Stand behind your chair and hold on with both hands. |
| a4.v6.2 | bản dễ (nói trước) | Start easy. Lift just your heel, toes stay down. |
| a4.v6.3 | vào bản chính | If you feel steady, lift your foot a little off the floor. |
| a4.v6.4 | gợi ý | Look at one spot in front of you. It helps. |
| a4.v6.5 | giữ → hạ | Hold… you're doing great… and set it down. |
| a4.v6.6 | khi lắc | If you wobble, that's normal. Hold the chair a little tighter. |
| a4.v6.7 | bản khó (ẩn khi Dizzy) | Want more? Try holding on with just one hand. |
| a4.v6.var.dizzy | chip Dizzy, thay a4.v6.7 | Keep both hands on the chair the whole time. |
| a4.v6.breath | trong lúc giữ | Keep breathing slowly while you hold. |

## 4. Sáu động tác mới (V8–V13)
Lời mô tả khớp clip P §4: độ cao, hướng mũi chân, tư thế thân. Bài một bên: mỗi clip một chân; giọng `a4.side.right/left` theo bên đầu của clip, rồi `a5.side`.

### 4.1 Side leg raise · V8-1 (chính diện, sau ghế, chân nâng ≈ 20 cm, đế giày ngang giữa ống chân kia, mũi chân hướng trước)
| ID | Khi nào | Câu thoại |
|---|---|---|
| a4.side-leg.intro | intro | Side leg raise. For stepping sideways and getting in and out of the car. |
| a4.side-leg.setup.1 | setup (sau `a4.stand.setup`) | Feet close together, toes pointing forward. |
| a4.side-leg.demo.1 | demo | The leg lifts out to the side, foot about as high as your other shin. |
| a4.side-leg.breath | sau "now with me" | Breathe out as your leg goes out, breathe in as it comes back. |
| a4.side-leg.easier | bản dễ (nói trước) | Easier: lift it just a little. A small lift still counts. |
| a4.side-leg.form.1 | gợi ý | Keep your toes facing forward, not up to the ceiling. |
| a4.side-leg.form.2 | gợi ý | Stand tall. Don't lean away from the leg. |
| a4.side-leg.harder | bản khó (ẩn khi Dizzy) | Want more? Hold the chair with just one hand. |
| a4.side-leg.var.joint | chip Joint replacement | Keep it small, with your toes pointing forward the whole time. |
| a4.side-leg.done | kết bài | Set your foot down softly. Both sides done. |

### 4.2 Back leg raise · V9-1 (nghiêng, sau ghế, chân ra sau ≈ 20 cm, gối không gập, mũi chân hướng xuống, không cúi, không ưỡn)
| ID | Khi nào | Câu thoại |
|---|---|---|
| a4.back-leg.intro | intro | Back leg raise. For stronger steps, like walking up a hill. |
| a4.back-leg.setup.1 | setup (sau `a4.stand.setup`) | Stand close to your chair, feet hip-width apart. |
| a4.back-leg.demo.1 | demo | The leg moves straight back, just a little. The leg stays long. |
| a4.back-leg.breath | sau "now with me" | Breathe out as your leg goes back, breathe in as it returns. |
| a4.back-leg.easier | bản dễ (nói trước) | Easier: a smaller lift. Just a little way back. |
| a4.back-leg.form.1 | gợi ý | Stand tall. Don't lean forward or arch your back. |
| a4.back-leg.form.2 | gợi ý | Toes point down toward the floor. |
| a4.back-leg.harder | bản khó | Want more? Hold it at the top a little longer. |
| a4.back-leg.var.back | chip Lower back | Keep the lift small, and keep your back still. |
| a4.back-leg.done | kết bài | And rest that leg. Nicely done. |

### 4.3 Knee curl · V10-1 (nghiêng, sau ghế, gót lên về phía mông khoảng nửa tầm, đùi thẳng đứng, gối trụ mềm)
| ID | Khi nào | Câu thoại |
|---|---|---|
| a4.knee-curl.intro | intro | Knee curl. For lifting your feet over steps and curbs. |
| a4.knee-curl.setup.1 | setup (sau `a4.stand.setup`) | Stand tall, feet hip-width apart. |
| a4.knee-curl.demo.1 | demo | Bend one knee and bring your heel up behind you. |
| a4.knee-curl.breath | sau "now with me" | Breathe out as your heel comes up, breathe in as it lowers. |
| a4.knee-curl.easier | bản dễ (nói trước) | Easier: bring your heel up only a little way. |
| a4.knee-curl.form.1 | gợi ý | Keep your knees side by side. Only the lower leg moves. |
| a4.knee-curl.form.2 | gợi ý | Keep your other knee soft, and your body tall. |
| a4.knee-curl.harder | bản khó (ẩn khi Dizzy) | Want more? Loosen your grip, hands just resting on the chair. |
| a4.knee-curl.var.joint | chip Joint replacement / Knees | Bend only as far as feels comfortable for your knee. |
| a4.knee-curl.done | kết bài | Set your foot down softly. Lovely work. |

### 4.4 Mini-squat · V11-1 (nghiêng, 2 tay lưng ghế, gập gối nửa tầm, ngồi ra sau, gối trên giữa bàn chân, gót phẳng)
| ID | Khi nào | Câu thoại |
|---|---|---|
| a4.mini-squat.intro | intro | Mini-squat. For sitting down gently and getting back up. |
| a4.mini-squat.setup.1 | setup | Both hands on the chair back, feet hip-width apart. |
| a4.mini-squat.demo.1 | demo | A small bend of the knees, as if you're about to sit. |
| a4.mini-squat.breath | sau "now with me" | Breathe in as you bend, breathe out as you stand up. |
| a4.mini-squat.easier | bản dễ (nói trước) | Easier: just a tiny bend. That still counts. |
| a4.mini-squat.form.1 | gợi ý | Sit back a little. Your knees stay over your feet. |
| a4.mini-squat.form.2 | gợi ý | Heels stay down. Back straight, chest up. |
| a4.mini-squat.harder | bản khó | Want more? Go down more slowly, still only halfway. |
| a4.mini-squat.var.knees.1 | chip Knees / Joint replacement | Only go halfway. If your heels start to lift, come back up. |
| a4.mini-squat.var.knees.2 | chip Knees | Keep your knees in line with your toes. Don't let them cave in. |
| a4.mini-squat.done | kết bài | Stand tall, knees soft. Well done. |

### 4.5 Arm raises · V12-1 (chính diện, ngồi; rep 1 hai tay ra trước, rep 2 hai tay sang ngang, tới ngang vai, khuỷu mềm)
| ID | Khi nào | Câu thoại |
|---|---|---|
| a4.arm-raise.intro | intro | Arm raises. For lifting bags onto the counter. |
| a4.arm-raise.setup.1 | setup | Sit tall, feet flat, hands resting on your thighs. |
| a4.arm-raise.demo.1 | demo rep 1 | Arms rise in front of you, up to shoulder height, then slowly down. |
| a4.arm-raise.demo.2 | demo rep 2 | Now out to the sides, also to shoulder height. |
| a4.arm-raise.breath | sau "now with me" | Breathe out as your arms rise, breathe in as they lower. |
| a4.arm-raise.easier | bản dễ (nói trước) | Easier: lift only partway, below your shoulders. |
| a4.arm-raise.form.1 | gợi ý | Elbows soft, palms facing down. |
| a4.arm-raise.form.2 | gợi ý | Shoulders stay low, away from your ears. |
| a4.arm-raise.harder | bản khó | Want more? Pause at the top for a moment. |
| a4.arm-raise.var.shoulder | chip Shoulders | Stop at shoulder height or lower, wherever feels comfortable. |
| a4.arm-raise.done | kết bài | Rest your hands on your thighs. Nicely done. |

### 4.6 Seated row · V13-1 (chính diện, ngồi, tay duỗi trước ngang vai, kéo khuỷu ra sau sát sườn, khép bả vai, không dây)
| ID | Khi nào | Câu thoại |
|---|---|---|
| a4.row.intro | intro | Seated row. For pulling open heavy doors and drawers. |
| a4.row.setup.1 | setup | Sit tall, away from the back of your chair, feet flat. |
| a4.row.setup.2 | setup | No band needed. Imagine you're pulling a rope toward you. |
| a4.row.demo.1 | demo | Arms reach forward, then elbows pull straight back. |
| a4.row.breath | sau "now with me" | Breathe out as you pull back, breathe in as you reach forward. |
| a4.row.easier | bản dễ (nói trước) | Easier: a smaller pull. Bring your elbows back just a little. |
| a4.row.form.1 | gợi ý | Squeeze your shoulder blades together, gently. |
| a4.row.form.2 | gợi ý | Elbows close to your sides. Chin level. |
| a4.row.harder | bản khó | Want more? Hold the squeeze for a count of two. |
| a4.row.done | kết bài | Let your hands rest. Lovely. |

## 5. Khung buổi (plan §2.2, STD §3.5, §7)
### 5.1 Khối một bài (mọi buổi)
| Mốc trong khối | Rep (ví dụ 45 s) | Tính giờ (ví dụ 45 s) |
|---|---|---|
| 0:00 | intro bài (`…intro`, `a4.v<n>.1`); lần đầu gặp: + `a4.rotate.2` | như rep |
| 0:04 | setup (bỏ khi tư thế giống bài trước) | setup |
| 0:08 | `a4.demo.*` + câu demo; HLV làm 1 rep, người tập xem | `a4.demo.*` + câu bản dễ (bài giờ không có rep demo riêng, clip chạy sẵn) |
| 0:16 | `a4.with-me.*` + câu thở; bài một bên: `a4.side.right/left` | `a4.with-me.*` |
| 0:20 | `a4.count.1` → `a5.n.*` mỗi đỉnh rep; bản dễ nói ngay sau rep 1 | gợi ý tư thế mỗi 10–12 s |
| rep giữa | gợi ý tư thế, `a4.slow.*`, `a4.pain.2` (một lần) | bản khó (Steady/Strong) |
| còn 2 rep | `a5.two-more` hoặc `a5.last-two` | — |
| −0:10 | `a5.10s.change` (hoặc `a5.10s.rest` trước nghỉ) | `a5.10s.change` |
| cuối | `a5.last` → `…done` / `a4.v1.8` | `…done` nếu có |
| nghỉ 15 s | `a4.rest.*` (3 hơi thở) → `a9.next-move` | như rep |
Bài một bên chia khung đôi: nửa đầu bên thứ nhất, `a5.side` ở giữa, nửa sau bên kia. Rep demo ăn khoảng 8 s của khung → Gentle 45 s chỉ còn 5–6 rep (câu hỏi #4).

### 5.2 Gentle chair moves 5 — 1:00 · 3 × (45 s + 15 s) · 1:00 = 5:00, toàn bộ ngồi
| Khe | Thời điểm | Câu (ID) |
|---|---|---|
| Mở | 0:00 | `a9.gentle`/`a9.steady`/`a9.strong` (theo check-in) → `a9.chair.open` → `a4.pain.1` → `a7.stop.1` |
| Khởi động | 0:12–1:00 | `a4.warm.1` → `a1.04` (heel taps) → `a1.05` (march) → `a1.06` → `a4.warm.toe` → `a1.07` → `a4.warm.done` (0:52) |
| Bài 1–3 | 1:00–4:00 | khối 5.1; 3 bài ngồi xoay vòng từ: knee lift, leg ext, arm raise, row, heel-toe |
| Hạ nhiệt | 4:00–5:00 | `a9.to-stretch` → `a10.chest.setup` → `a10.chest.move` (Shoulders: `a10.chest.easy`) → giữ 20 s, `a10.hold.2` → `a10.release.2` → `a1.27` → `a1.28` |
| Kết | 4:56 | `a9.chair.close` |

### 5.3 Chair moves 7 — 1:30 · 5 × (40 s + 15 s) · 1:00
| Khe | Thời điểm | Câu (ID) |
|---|---|---|
| Mở + khởi động | 0:00–1:30 | như 5.2, thêm `a1.09` và `a2.warm.1` để lấp 1:30; `a4.rotate.1` khi bài khác lần trước |
| Bài 1–3 (ngồi) | | leg ext → arm raise → row |
| Bài 4 | | Standing is hard / Dizzy: heel-toe ngồi. Còn lại: sit-to-stand (bản dễ `a4.v1.3` nói trước) |
| Bài 5 | | Standing is hard: sit-to-stand. Còn lại: một bài đứng vịn xoay vòng (single-leg, side leg, heel raise đứng) — rep cuối bài 4 dùng `a4.to-stand.sts` → `a4.to-stand.behind` → `a4.to-stand.2` (30 s), rồi `a4.stand.setup` |
| Về ghế | trước hạ nhiệt | `a4.to-sit.1` → `a4.to-sit.2` (30 s) |
| Hạ nhiệt + kết | 1:00 | như 5.2 |
Thời lượng thật: 7:05 (toàn ngồi) · 7:35 (có bài đứng, thêm 2 lần chuyển 30 s) → câu hỏi #3.

### 5.4 Stronger chair moves 8 — 1:30 · 6 × (45 s + 10 s) · 1:00
| Khe | Câu (ID) |
|---|---|
| Mở + khởi động | như 5.3 |
| Bài 1–2 (ngồi) | row → leg ext |
| Bài 3 | sit-to-stand; rep cuối `a4.to-stand.sts` → `a4.to-stand.behind` → `a4.to-stand.2` (30 s) |
| Bài 4–6 (đứng vịn) | heel raise đứng (`a4.v4.6` làm câu vào) → side leg → mini-squat; xoay vòng: side leg ↔ back leg, heel raise đứng ↔ knee curl, mini-squat ↔ wall push-up (thêm 10 s dời sang tường, `a4.v5.2`) |
| Về ghế | `a4.to-sit.1` → `a4.to-sit.2` (30 s) |
| Hạ nhiệt + kết | như 5.2 |
Standing is hard: bài 3–6 thay bằng sit-to-stand (bản dễ), knee lift, arm raise, heel-toe ngồi → 8:00. Có bài đứng: 1:30 + 4:30 + 4 × 10 s + 2 × 30 s + 1:00 = 8:40 → câu hỏi #3. Dizzy: heel raise đứng → heel-toe ngồi; bỏ mọi `…harder` một tay.

### 5.5 Xoay vòng
- `rotationIndex` = số ngày ghế đã tập. Gentle 5: vòng 5 bài ngồi [knee lift, leg ext, arm raise, row, heel-toe], ngày k lấy vị trí 3k, 3k+1, 3k+2 (mod 5) → hai ngày liền nhau trùng tối đa 1 bài.
- Chair 7 bài 5 và Stronger 8 các cặp xoay vòng: đổi mỗi ngày ghế.
- Biến thể câu (demo, with-me, rest, slow): biến thể = (ngày hoạt động + khe) mod số biến thể, như A2 §2.1.
- Bài ẩn theo chip: wall push-up và mọi bài đứng ẩn khi Standing is hard; bài đứng một tay (`…harder`) ẩn khi Dizzy; câu `…var.<chip>` thay câu cùng khe khi chip bật.

## 6. Kiểm tra theo quy tắc
- Demo trước (plan nguyên tắc 1): mọi bài có `a4.demo.*` + câu demo trước `a4.with-me.*`.
- Thở (STD §8.2): mỗi bài rep có câu thở riêng hoặc `a4.breath.1`; không có "hold your breath" ngoài câu cấm nín thở.
- Báo trước 8–10 s (nguyên tắc 2): `a5.10s.change` ở −0:10 mọi bài.
- Chip: Joint replacement (V1, V2, side leg, knee curl, mini-squat), Knees (mini-squat, knee curl, V3.7), Lower back (back leg), Shoulders (V5, arm raise), Dizzy (V4, V6, bài một tay), Standing is hard (ẩn bài đứng).
- Không từ cấm, không số sức khoẻ, không "close your eyes", không hứa giảm ngã. Lint + đếm từ: xem báo cáo M4.

## 7. Thay đổi so với V-exercise-clips.md §2
| # | ID | Cũ | Mới | Lý do |
|---|---|---|---|---|
| 1 | `a4.v2.1` | Seated knee lifts. The same move… | Seated knee lift. The same move… | Tên phải trùng thẻ `mv.knee-lift` (plan nguyên tắc 8, CMP §4.6) |
| 2 | `a4.v3.1` | Seated leg extensions. The move… | Seated leg extension. The move… | Tên trùng thẻ `mv.leg-ext` |
| 3 | `a4.v3.4` | …straighten it all the way, toes to the ceiling. | …straighten it more, toes to the ceiling. Keep the knee soft. | "All the way" dễ thành khoá gối (STD §3.1, §8.1 "không khoá khớp") |
| 4 | `a4.v5.1` | Wall push-ups. They make… | Wall push-up. It makes… | Tên trùng thẻ `mv.wall-push` |
| 5 | `a4.v6.1` | Balance time. Stand behind… | Single-leg stand. Stand behind… | Tên trùng thẻ `mv.single-leg`; "Balance" là tên loại buổi cố định (Extras), không dùng cho một bài ghế |
Năm câu này mất file giọng cũ khi build (`keep_media` chỉ giữ câu không đổi chữ) → tạo lại ở M6.
