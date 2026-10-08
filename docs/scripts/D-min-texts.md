# D — Chữ trong app, bản tối thiểu cho demo MVP · bản nháp 1
_29/09/2026 · Theo [app-context.md](../../app-context.md) (Tone & copy rules, từ vựng cố định) và [content-plan.md](../content-plan.md) mục D · Chữ hiển thị tiếng Anh Mỹ_

D1 onboarding, D4 paywall, D11 trạng thái và Settings: **đã có chữ đủ trong [spec](../design/gentle-walk-screen-spec.html)** (S01–S08, S20, S21, Trạng thái đặc biệt) — code lấy thẳng từ spec. File này viết các mục spec mới chỉ có ví dụ. Không số liệu bịa ("9 out of 10"), không từ cấm, không tuyên bố y khoa.

## D2. Màn thấu hiểu S04 (6, theo lựa chọn đầu tiên ở S03)
| Khoá S03 | Tiêu đề | Đoạn 2 dòng |
|---|---|---|
| joints | Sore knees don't mean you can't move. | Every move here starts seated. If something hurts, one tap swaps it for an easier one. |
| too-fast | You set the pace here. | A calm voice guides each step, and you can pause anytime. No one is racing you. |
| busy | You look after everyone. This is for you. | Five minutes is enough to start. Pick a moment in your day, and we'll keep it there. |
| bored | Something new every week. | Walks, chair moves and gentle stretches take turns, and every minute takes you somewhere new. |
| charged | No surprises with money. | We'll always show the exact date before you're billed. Canceling takes one tap. |
| not-sure | You don't need a plan. We'll bring one. | Tell us a little about you, and we'll start you somewhere comfortable. |

## D3. "Why this will work for you" ở S07 (6, hiện 2–3 dòng theo S03)
| Khoá S03 | Dòng |
|---|---|
| joints | Everything starts seated, and moves are filtered for your joints. |
| too-fast | Videos went too fast? Here a calm voice sets the pace, and you can pause anytime. |
| busy | Sessions are 5 to 10 minutes, at the moment of the day you choose. |
| bored | Your week mixes walks, chair moves and stretches, and your journey keeps moving. |
| charged | You'll see your billing date today, get a reminder before it, and can cancel in one tap. |
| not-sure | We start you at the right level and adjust after every session. |
Khi người dùng chọn ít hơn 2 mục ở S03: thêm dòng mặc định "You can do it with your phone in your pocket. Just follow the voice."

## D5. Mẹo động tác ghế (6 × 3 gợi ý + bản dễ + bản khó)
Giãn cơ: xem [A10](A10-stretch.md) §2 (2 gợi ý + bản dễ mỗi tư thế). Tên và dòng mục đích ("For …") nói việc đời thường, không hứa lợi ích sức khoẻ.
| Mã | Tên · mục đích | 3 gợi ý | Easier version | Harder version |
|---|---|---|---|---|
| mv.sit-to-stand | Sit-to-stand · For getting up from chairs | Feet flat, hip-width apart · Lean forward, nose over toes · Use your hands on the chair if you need to | Push up with your hands on the chair | Arms crossed, sit down on a slow count of three |
| mv.knee-lift | Seated knee lift · For every step you take | Hold the sides of your seat · Sit tall, don't lean back · Lift, then set down softly | Just lift your heel, toes stay down | Lift a little higher and swing the opposite arm |
| mv.leg-ext | Seated leg extension · For climbing stairs | Hold the sides of your seat · Leg points straight ahead · Lower it slowly | Straighten your leg only halfway | Hold it up for a count of three |
| mv.heel-toe | Heel and toe raises · For reaching a high shelf | Feet flat to start · Lift heels, then lower · Now lift toes, heels stay down | Heels only, small lifts | Stand behind your chair and rise onto your toes |
| mv.wall-push | Wall push-up · For pushing doors and lifting bags | Hands flat at shoulder height · Body straight, like a plank · Heels stay on the floor | Stand closer, bend your elbows just a bit | Step your feet back a little |
| mv.single-leg | Single-leg stand · For steadier balance | Hold the chair with both hands · Look at one spot ahead · Lift your foot just a little | Lift only your heel, toes stay down | Hold on with just one hand |

## D5 — bài mới 30/09/2026
_Theo [kế hoạch nội dung 4 nhóm](../plans/2026-09-30-content-4-groups.md) §2.1–§2.4 (tên khớp đúng cột "Tên"), §4.2 dòng D5 · Tư thế và chống chỉ định: [STD](../research/2026-09-30-exercise-standards.md) §2–§5, §8.2 · Gợi ý khớp hình trong clip: [PROMPTS](P-production-prompts.md) §3–§6 · Chữ màn hình tiếng Anh Mỹ: gợi ý ≤ 8 từ, mục đích ≤ 6 từ, không dấu chấm cuối (như bảng trên). Mục đích nói việc đời thường, không hứa sức khoẻ; thăng bằng không hứa giảm ngã; không bao giờ nhắm mắt._

D-min-texts trước ngày này **chưa có** chữ theo từng động tác đi bộ (chỉ có khung buổi ở A2) → thêm 8 dòng `wk.*`. Một dòng dùng cho cả Seated và In place (gợi ý viết để đúng cả hai: "Stand or sit tall", "Hold the chair or seat").

### Walks (8)
| Mã | Tên · mục đích | 3 gợi ý | Easier version | Harder version |
|---|---|---|---|---|
| wk.march | March · For keeping up on family walks | Stand or sit tall, eyes ahead · Lift one foot, set it down softly · Arms swing, or hands rest on thighs | Just lift your heels, toes stay down | Knees a little higher, arms press forward |
| wk.heel-dig | Heel dig · For stepping over doorsteps | Heel down in front, toes up · Bring the foot back, then switch · Upper body stays tall and still | Slow it down, same small reach | Switch feet a little quicker |
| wk.side-step | Side step · For moving around the kitchen | Step out to the side, then together · Knees soft, toes point forward · Hips stay level, eyes ahead | Small steps, hands on your hips | Wider steps, arms open to the sides |
| wk.knee-lift | Knee lift · For stepping into the car | Hold the chair or seat lightly · Knee no higher than your hip · Foot points forward, body tall | Lift lower, hand on the chair | Touch the knee with the opposite hand |
| wk.toe-tap | Toe tap forward · For crossing the street | Tap your toes out in front · Knee stays a little bent · Stay tall, don't lean back | Tap a little closer to you | A low kick, knee never locked |
| wk.heel-back | Heel to back · For walking up hills | Hold the chair, stand tall · Bring your heel back and up · Knee points down, don't lean forward | Lift your heel only a little | Hands off the chair, if you feel steady |
| wk.shift | Weight shift · For standing steady in line | Feet a little wider than your hips · Shift your weight side to side · Knees stay over your toes | Hold the chair as you shift | Let the other heel lift a little |
| wk.arms | Arm swing / press · For carrying the groceries in | Swing your arms, elbows soft · Or press forward at shoulder height · Shoulders stay down and relaxed | Keep your hands below your shoulders | Press up and out at an angle |
- `wk.toe-tap` bản dễ: plan §2.1 để "—" (toe tap đã là bản dễ của low kick) → app đề xuất "tap closer", chờ duyệt.
- `wk.heel-back` bản ngồi (gót trượt về gầm ghế) chưa có clip; gợi ý viết theo bản đứng vịn ghế (W2-6, đợt B). `wk.arms` không có clip riêng (bồi thêm trên march).

### Chair moves — 6 bài mới
| Mã | Tên · mục đích | 3 gợi ý | Easier version | Harder version |
|---|---|---|---|---|
| mv.side-leg | Side leg raise · For getting out of the car | Hold the chair back with both hands · Lift about a hand's height, toes forward · Stay tall, no leaning to the side | A smaller lift, both hands on the chair | Hold on with just one hand |
| mv.back-leg | Back leg raise · For stepping up onto curbs | Stand tall, hands on the chair · Leg moves straight back, toes down · Don't lean forward or arch your back | A smaller lift, just off the floor | Pause at the top for a moment |
| mv.knee-curl | Knee curl · For stepping into the bathtub | Hands on the chair, stand tall · Bring your heel up behind you · Knee points down, thigh stays still | Bend your knee only a little | Hands off the chair, if you feel steady |
| mv.mini-squat | Mini-squat · For lowering into a chair | Both hands on the chair, feet hip-width · Sit back a little, heels stay down · Knees point forward, not past your toes | Just a small bend at the knees | Lower on a slow count of three |
| mv.arm-raise | Arm raises · For putting dishes away | Sit tall, feet flat · Raise your arms to shoulder height · Elbows soft, shoulders stay down | Lift only partway, below your shoulders | Pause at the top, or reach overhead |
| mv.row | Seated row · For pulling open heavy doors | Arms out in front, palms facing in · Pull your elbows back past your ribs · Squeeze your shoulder blades together | Pull back only halfway | Hold the squeeze for a count of two |
- Khớp clip: V8 (hai tay vịn, nhấc ~20 cm = "about a hand's height", mũi chân hướng trước, thân không nghiêng) · V9 (chân thẳng ra sau, mũi chân xuống, không ưỡn) · V10 (gót lên khoảng nửa, đùi thẳng đứng) · V11 (hai tay vịn, gối không qua mũi chân, gót phẳng) · V12 (trước rồi ngang, tới ngang vai) · V13 (tay duỗi trước, lòng bàn tay đối nhau, khuỷu qua sườn).
- `mv.knee-curl` và `wk.heel-back` cùng chuyển động (STD C10 / walk #6), khác nhịp: một bài rep chậm, một bài nhịp đi bộ. Bản khó "Hands off the chair" theo plan ("không vịn"), kèm điều kiện "if you feel steady".

### Stretches — 4 tư thế mới (2 gợi ý + bản dễ, không bản khó)
| Mã | Tên · mục đích | 2 gợi ý | Easier version | Harder version |
|---|---|---|---|---|
| st.chin-tuck | Chin tuck · For after reading or screen time | Glide your head straight back · Eyes level, don't look up | A smaller glide, just a few times | — |
| st.shoulder-roll | Shoulder rolls · For shoulders after a busy day | Roll up, back, then down, slowly · Head still, hands on your thighs | Make the circles smaller | — |
| st.upper-back | Upper back reach · For reaching across the table | Arms forward, palms facing away · Reach forward, lower back stays tall | Keep your hands a little lower | — |
| st.overhead | Overhead reach at the wall · For reaching the top cupboard | Walk your hands up the wall · Heels down, don't arch your back | Stop when your hands reach eye level | — |
- 8 tư thế cũ giữ ở [A10](A10-stretch.md) §2 (chưa có dòng mục đích "For …"; nếu thẻ tư thế cần dòng này thì viết bổ sung sau).

### Balance (Extras) — bài mới
| Mã | Tên · mục đích | 3 gợi ý | Easier version | Harder version |
|---|---|---|---|---|
| bl.tandem | Tandem stance · For narrow aisles and hallways | Hold the chair the whole time · Front heel touches your back toes · Knees soft, eyes straight ahead | Front foot a little to the side | Just your fingertips on the chair |
| bl.side-walk | Sideways walking · For getting through crowded rooms | Step to the side, feet together · Toes point forward, hips level · Stay near a counter or wall | Smaller steps, one hand on the counter | Slightly bigger steps, same slow pace |
| bl.heel-toe-walk | Heel-to-toe walk · For garden paths and trails | Fingertips on the wall beside you · Heel lands right in front of toes · Eyes ahead, one slow step at a time | Leave a small gap between steps | A few more steps, same slow pace |
| bl.back-walk | Walking backwards · For stepping back from a counter | Hands slide along the counter · Toes first, then the heel · Eyes ahead, small slow steps | Fewer, smaller steps | Ten steps, one hand on the counter |
| bl.walk-turn | Walk and turn · For turning around at home | Walk along your counter · Turn in tiny steps · A hand within reach the whole time | Both hands on the counter for the turn | Five steps each way |
| bl.heel-toe-walking | Heel and toe walking · For uneven paths and lawns | One hand on the counter · Toes up for the heel steps · Heels up for the toe steps | Raise heels and toes standing still | A few more steps, same slow pace |
- `bl.heel-toe-walk`: đợt B (clip B3), chỉ buổi Strong.
- Thêm 06/10/2026 (rà soát docs/reviews/2026-10-06-chuyen-gia-ra-soat-bai-tap-58-75.md, Otago levels B–D [S16 p.30]): `bl.back-walk`, `bl.walk-turn`, `bl.heel-toe-walking` có vịn mặt bếp; không có clip riêng (AI không làm được di chuyển, cùng lý do Sideways walking) → tranh minh hoạ; `bl.heel-toe-walking` dùng clip Heel and toe raises đứng. Ẩn với "Standing for long is hard"; `bl.back-walk` và `bl.heel-toe-walking` ẩn với "I feel unsteady on my feet"; `bl.back-walk` và `bl.walk-turn` ẩn với "I get dizzy easily".

### Giãn cơ — bài mới 06/10/2026
| Mã | Tên · mục đích | 3 gợi ý | Easier version | Harder version |
|---|---|---|---|---|
| st.back-ext | Standing back extension · For standing tall | Hands on your hips · Lean back only a little · Chin level, eyes ahead | Hold the chair, a smaller lean | — |
- `st.back-ext`: Otago warm-up Back extension 5 lần [S16 p.29]; "Straight" trong Strong, Steady and Straight 2022 (cơ duỗi lưng; biên nhỏ, không ngửa cổ). Clip S13. Dùng ở phần khởi động Balance.
- `bl.side-walk`: không có video riêng (chốt 30/09) → màn hiện clip **W2-2 side step**; gợi ý viết để khớp hình (bước sang – khép, tay chống hông, hông ngang), giọng A11 dẫn đi ngang 10 bước. Không có "không vịn" ở mọi bài thăng bằng.
- **Dùng lại, không thêm dòng:** one-leg stand của buổi Balance **là cùng bài `mv.single-leg`** (STD C7 = Otago #9 = NIA Stand on One Foot, vịn ghế 2 tay → 1 tay) → dùng dòng `mv.single-leg` ở trên, không tạo `bl.one-leg`. Cũng dùng lại: sit-to-stand (`mv.sit-to-stand`), heel raises + toe raises đứng vịn (`mv.heel-toe`, hình bản khó "Stand behind your chair…"), weight shift (`wk.shift`).

### Biến thể theo chip S06 (chữ trên màn khi người dùng chọn chip)
Bảng D5 trên không có cột biến thể → bảng riêng. Nhãn chip đúng chữ S06 trong spec ("I get dizzy easily", "Standing for long is hard"); "Lower back" gồm cả "or bone thinning" (chốt #6). Chỉ ghi chỗ plan §2.1–§2.4 có biến thể; bài bị ẩn không cần chữ.
| Mã | Chip | Text |
|---|---|---|
| wk.march | Joint replacement | Keep your knees well below your hips |
| wk.side-step | I get dizzy easily | Small steps, close to your chair |
| wk.knee-lift | Joint replacement | Knees stay clearly below your hips |
| wk.toe-tap | Knees | Tap only, no kicks |
| wk.heel-back | Joint replacement | Bend only as far as feels comfortable |
| wk.arms | Shoulders | Keep your hands below shoulder height |
| mv.side-leg | Joint replacement | A small lift, toes and knee face forward |
| mv.back-leg | Lower back | A small lift, no arching your back |
| mv.knee-curl | Joint replacement | Bend only as far as feels comfortable |
| mv.mini-squat | Knees | Halfway only, stop if your heels lift |
| mv.arm-raise | Shoulders | Only up to shoulder height |
| st.shoulder-roll | Shoulders | Make small, slow circles |
| st.upper-back | Lower back | Back stays straight, just reach your arms |
| st.overhead | Shoulders | Reach only to eye level |
| st.overhead | Standing for long is hard | Sit tall and reach up instead |
| bl.tandem | Joint replacement | Feet stay in line, never crossing over |
| bl.tandem | I get dizzy easily | Both hands on the chair |
| bl.side-walk | I get dizzy easily | Small steps, one hand on the counter |
| bl.tandem | I feel unsteady on my feet | Both hands on the chair |
| mv.single-leg | I feel unsteady on my feet | Both hands, lift just your heel |
| bl.side-walk | I feel unsteady on my feet | Both hands on the counter, small steps |
| bl.walk-turn | I feel unsteady on my feet | Both hands on the counter |
| st.back-ext | Lower back | A small lean, back long |
- Plan ghi "Knee replacement" cho `wk.heel-back`, `mv.knee-curl`; S06 không có chip riêng → gắn vào "Joint replacement".
- `bl.tandem` + Joint replacement: STD §5.1 chấp nhận vì chân đặt thẳng hàng, không bắt chéo; khó chịu → đổi sang side step.

## D6. Mô tả hành trình (5)
| Mã | Tên | Mô tả (dưới tên, luôn kèm "A gentle version of the route") |
|---|---|---|
| jr.ny | New York City · Central Park to Brooklyn Bridge | From the zoo in Central Park, through Times Square, all the way to the Brooklyn Bridge. About 2–3 weeks. |
| jr.smoky | Smoky Mountains and the Blue Ridge Parkway | Quiet valleys, waterfalls and mountain views, from Cades Cove to the Linn Cove Viaduct. About 4–6 weeks. |
| jr.camino | The Camino de Santiago · the last 100 km | Stone villages and green hills of Galicia, from Sarria to the great square in Santiago. About 4–6 weeks. |
| jr.ne | New England lighthouses · Maine to Cape Cod | Rocky coastline and white lighthouses, from Portland Head Light to Nauset Light. About 4–6 weeks. |
| jr.pch | Pacific Coast Highway · Big Sur | Cliffs, beaches and ocean views, from Carmel-by-the-Sea past Bixby Bridge. About 4–6 weeks. |
Độ dài tuần là ước tính theo 0,05 dặm mỗi phút tập (plan 2.1), không phải lời hứa; người viết nội dung kiểm lại khi có số dặm thật của từng tuyến.

## D7. Mặt sau bưu thiếp New York (6 × 2 câu + 1 câu HLV)
Chỉ nêu điều dễ kiểm chứng, không ngày tháng hay con số lịch sử cho tới khi người viết nội dung kiểm.
| Mã | Mặt sau | Câu HLV |
|---|---|---|
| pc.ny.zoo | Tucked inside Central Park, the zoo is a favorite stop for families and first walks alike. | Your very first stop. Here's to many more. |
| pc.ny.bethesda | The fountain sits by the lake in the middle of the park, with a wide terrace for resting and people-watching. | A lovely place to catch your breath. |
| pc.ny.times | Bright screens, busy sidewalks and theaters all around. It's one of the most famous crossroads in the world. | Look how far those minutes have carried you. |
| pc.ny.bryant | A leafy park in Midtown, with a lawn, green chairs and a quiet library next door. | A calm spot in the middle of it all. |
| pc.ny.union | A lively square with a farmers market on many days of the week. | Almost at the river. Keep going. |
| pc.ny.bridge | The bridge crosses the East River to Brooklyn, with a wide walkway above the traffic. | You walked all of New York. I'm so proud of you. |
Cần kiểm trước khi phát hành: lịch chợ Union Square, "green chairs" Bryant Park (chi tiết hình ảnh, không thương hiệu).

## D8. Kho thông báo tối thiểu (32 câu)
Luật (spec mục Thông báo, plan 7.1–7.8): tối đa 1/ngày, không ghi sức khoẻ trên màn khoá (không "knee", "pain", "weight", "joints"), không lặp trong 14 ngày, không "streak". Plan 7.10 tính 42 câu nhắc (14 × 3 mốc); **demo dùng 14 câu trung tính cho mọi mốc** — đủ để không lặp 14 ngày với một người (mỗi người chọn một mốc). Bản đầy đủ viết thêm câu theo mốc sau.
| Loại | ID | Câu |
|---|---|---|
| Nhắc tập | nt.remind.1 | Ready for a few easy minutes? Seated counts too. |
| | nt.remind.2 | Your walk is ready whenever you are. |
| | nt.remind.3 | A short walk today? Five minutes is enough. |
| | nt.remind.4 | Time for your walk. Take it at your pace. |
| | nt.remind.5 | Your chair is right there. Want to start? |
| | nt.remind.6 | A few minutes for you, before the day gets busy. |
| | nt.remind.7 | Let's get your feet moving. Just a little. |
| | nt.remind.8 | Your journey is waiting for today's steps. |
| | nt.remind.9 | Got a few minutes? Your walk is set up. |
| | nt.remind.10 | Today's session is a short one. Ready? |
| | nt.remind.11 | A calm voice and a few easy minutes. Shall we? |
| | nt.remind.12 | Feel like moving a little? Your plan is ready. |
| | nt.remind.13 | Your time. Your pace. Your walk. |
| | nt.remind.14 | Just press start. The voice will do the rest. |
| Ngày 2 | nt.day2.1 | Yesterday was your first walk. Today's is just as short. |
| | nt.day2.2 | Day two. Same easy pace as yesterday. |
| | nt.day2.3 | Nice start yesterday. Ready for another few minutes? |
| Gần địa danh | nt.near.ny.1 … nt.near.ny.6 | You're one walk away from [stop name]. (6 câu, tên từ D6/D7) |
| Tổng kết tuần | nt.week.up | [n] active days this week. That's more than last week. |
| | nt.week.same | [n] active days this week, same as last week. Nice and steady. |
| | nt.week.less | [n] active days this week. A new week starts tomorrow. |
| Quay lại | nt.back.3 | Your journey is right where you left it. Want an easy 5 minutes? |
| | nt.back.10 | Whenever you're ready, a gentle restart is waiting. |
| Tự kiểm tra 2 tuần (08/10/2026) | nt.check.1 | Your 2-week check is ready when you are. |
| | nt.check.2 | Thirty seconds and a chair: your 2-week check is today. |
| | nt.check.3 | Time for your 2-week check. Only you see the number. |
| | nt.check.4 | Your 2-week check is here. Same chair, same way as last time. |
| Hết trial | nt.trial | Your free trial ends on [date]. You'll be billed [price] unless you cancel. Manage it in Settings. |
| Tuyến mới | nt.newjourney | A new journey is ready: [journey name]. |
| Thẻ ít nhắc hơn (Today) | card.fewer | You're doing this on your own now. Want fewer reminders? |
Nút trên thông báo nhắc tập: "Start walk" · "Rest today". `nt.week.less` không nêu ngày bỏ tập.

## D9. Everyday wins (tối thiểu 8)
Got up from the sofa without using my hands · Carried the groceries in one trip · Walked the whole store · Climbed the stairs without stopping · Played on the floor with the grandkids · Reached the top shelf without a stool · Walked to the mailbox and back, easily · Stood through a whole concert or ball game
"Played on the floor" chỉ hiện nếu S06 không chọn "I can't get down on the floor".

## D10. An toàn và hỏi bác sĩ (5)
| Chỗ | Chữ |
|---|---|
| S06 hộp nền nhạt | If you have a heart condition, recent surgery or you've been told to limit exercise, check with your doctor first. |
| S06 chọn Joint replacement | We'll leave out deep hip bends and crossed legs. Follow your surgeon's advice first. |
| Thẻ báo đau 3 lần (Today) | You've mentioned [area] pain 3 times this week. We've switched you to seated moves. Consider checking with your doctor. |
| S14 Break | Take your time. Sit down, sip some water, breathe slowly. Your progress is saved. |
| Me → Help | Good Footing is for general fitness. It isn't medical advice. |
Câu thứ hai dựa trên NHS-HIP (xem A10 §1); không nói "safe", "prevents", "treats".

### Tự kiểm tra 2 tuần (thêm 08/10/2026, Task 1.3 kế hoạch steady-program)
Dùng nguyên văn trên mọi màn của luồng tự kiểm tra; bản Việt và lý do ở [design/steady-claims.md](../design/steady-claims.md).
| Chỗ | Chữ |
|---|---|
| Màn chuẩn bị, cuối màn | This is not a medical test. |
| Màn chuẩn bị, dòng mở đầu; màn nhập số | You compare only with yourself. |
| Màn chuẩn bị, lời dặn an toàn; màn bấm giờ | Stop if anything hurts or you feel dizzy. |

## Tổng
| Mục | Số mục tối thiểu | Ghi chú |
|---|---|---|
| D1, D4, D11 | theo spec | đã có |
| D2 | 6 | |
| D3 | 6 + 1 mặc định | |
| D5 | 6 động tác + 8 tư thế (A10) | 30/09: + 8 đi bộ, 6 ghế, 4 giãn cơ, 3 thăng bằng, 18 biến thể chip |
| D6 | 5 | |
| D7 | 6 (New York) | 4 tuyến trả phí: chỉ bưu thiếp đầu dùng câu A8, mặt sau viết sau |
| D8 | 28 | 14 nhắc trung tính thay cho 42 |
| D9 | 8 | |
| D10 | 5 | |
