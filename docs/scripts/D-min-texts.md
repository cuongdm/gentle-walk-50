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

## D8. Kho thông báo tối thiểu (28 câu)
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
| Me → Help | Gentle Walk is for general fitness. It isn't medical advice. |
Câu thứ hai dựa trên NHS-HIP (xem A10 §1); không nói "safe", "prevents", "treats".

## Tổng
| Mục | Số mục tối thiểu | Ghi chú |
|---|---|---|
| D1, D4, D11 | theo spec | đã có |
| D2 | 6 | |
| D3 | 6 + 1 mặc định | |
| D5 | 6 động tác + 8 tư thế (A10) | |
| D6 | 5 | |
| D7 | 6 (New York) | 4 tuyến trả phí: chỉ bưu thiếp đầu dùng câu A8, mặt sau viết sau |
| D8 | 28 | 14 nhắc trung tính thay cho 42 |
| D9 | 8 | |
| D10 | 5 | |
