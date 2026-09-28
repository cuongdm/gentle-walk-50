# V — Kịch bản 6 clip động tác (+ lời giọng A4) · bản nháp 1
_28/09/2026 (danh sách job Flow; sửa bối cảnh tối giản, khung hình đủ người, góc máy) · Theo [app-context.md](../../app-context.md) và [content-plan.md](../content-plan.md) mục V và A4 · Prompt tiếng Anh, ghi chú tiếng Việt_

## 1. Quy tắc chung cho mọi clip
> **Bản hiện hành (28/09/2026):** kết quả và cách làm đã chạy được ở **mục 5·0** và [video-skill-notes.md](../video-skill-notes.md) §5e, §5f. Ba quy tắc dưới đây đã bị thay: (1) "chỉ tạo pha lên + app phát ngược" → tạo **vòng khép kín** từ tư thế cao nhất, clip chứa cả pha xuống thật; (2) "lật gương cho bên còn lại" → **cả hai bên trong một clip**, không lật (cửa sổ và ánh sáng đổi bên); (3) "ảnh khung tạo riêng cho từng động tác" → **mọi ảnh khung sửa từ khung hình thật của video V1** để cùng cỡ người và phòng. Bảng job 3b và bảng thời lượng 3c vì thế chỉ còn đúng về số job, tư thế và lời giọng; mốc dựng thật ở 5·0. Giữ nguyên phần cũ làm bài học.

- **Chỉ tạo pha "lên"** (từ tư thế đầu tới tư thế cuối), dài 2–3 giây. App phát **xuôi rồi ngược** thành vòng lặp 4–6 giây. Giữ tư thế (hold) do app dừng ở khung cuối, không nằm trong clip.
- **Luôn tạo 2 ảnh khung trước** (K1 tư thế đầu, K2 tư thế cuối) bằng cùng ảnh tham chiếu HLV, rồi cho AI tạo video **giữa K1 và K2**. Thử nghiệm PawSteps cho thấy chỉ có khung đầu thì AI tự phóng đại hoặc đổi động tác; slide mẫu 28/09/2026 cũng mắc lỗi này (Sit-to-stand không đứng lên, tay tự chắp).
- **Lật gương cho bên còn lại** (chân trái/phải) thay vì tạo thêm clip. Điều kiện: HLV không đeo nhẫn, đồng hồ, không có chi tiết lệch (ngôi tóc giữa), phông không có chữ hay vật lệch.
- **Phát ngược phải trông tự nhiên:** không tóc bay, không vải rũ mạnh, không nhún lấy đà. Nếu pha ngồi xuống cần chậm hơn, app phát ngược với tốc độ 0.7.
- 16:9 ngang, một góc máy cố định, không cắt cảnh, không zoom, không chữ, không âm thanh, không watermark. Toàn thân trong khung, chừa khoảng trên đầu và dưới chân.
- Mỗi clip: huấn luyện viên duyệt K1, K2 và clip trước khi dùng. K1, K2 được giữ làm ảnh tĩnh (Reduce Motion, thumbnail, VoiceOver).

### Khối prompt dùng chung
**CHARACTER (dán vào mọi prompt):** A woman who looks 58 to 62 years old, salt-and-pepper shoulder-length hair with a centered part, modern thin-frame glasses, a fuller figure (US size 14 to 16), sage green long-sleeve top that covers the hips, charcoal high-waist leggings, plain white sneakers, no jewelry, no watch. Calm, confident, slight natural smile. Same person as the reference images.

**SET (tối giản, cố định cho mọi clip):** A minimal, empty room. Plain warm white wall with a simple white baseboard, light oak floor, soft daylight from a window just outside the frame on the left. The only object is one wooden ladder-back dining chair without armrests or wheels, light oak finish, placed in the center. Nothing else in the room: no plants, no shelves, no books, no lamps, no armchair, no TV, no pictures, no rug, no curtains in frame.
_(Cảnh tường cho V5: cùng tường, cùng sàn, ghế đặt sát mép phải khung.)_

**CAMERA:** Static locked-off camera on a tripod, 16:9 wide shot. Framed for the standing pose: when she stands, her head is about 10% below the top edge and her feet about 8% above the bottom edge. The full body, including the head and feet, stays inside the frame at all times. Camera height about hip level of a standing adult. She is positioned slightly left of center: the center of her body is at about 38% of the frame width, and the right third of the frame is empty wall (for captions). No camera movement, no pan, no tilt, no zoom, no reframing, no cuts, no scene change, same room from first to last frame.

**STYLE (mặc định, người thật):** Photorealistic, natural skin texture, soft diffused daylight, calm and clean look.
_(Nếu đổi sang màu nước: "Soft gouache and watercolor illustration, paper texture, warm shading", giữ nguyên các khối khác.)_

**NEGATIVE:** no head or feet cut off by the frame, no scene change, no second room, no furniture other than the one chair, no text, no captions, no subtitles, no watermark, no logos, no music, no extra people, no jewelry, no camera shake, do not exaggerate the range of motion, do not change the pose between start and end except the described movement.

### Quy trình ảnh khung để khóa bối cảnh và khung hình
1. Tạo **ảnh nền trống** một lần cho mỗi góc máy: phòng tối giản, ghế đúng vị trí, chưa có người. Lưu làm tham chiếu bối cảnh.
2. Với mỗi động tác, tạo **tư thế cao nhất trước** (thường là khung cuối: đứng thẳng, chân duỗi, nhón gót), từ ảnh nền + ảnh tham chiếu HLV, kiểm tra đầu và chân nằm trọn trong khung.
3. Tạo khung còn lại bằng cách **sửa chính ảnh đó** ("same scene, same camera, same lighting, she is now seated…"), không tạo ảnh mới từ đầu. Hai khung vì vậy có cùng phòng, cùng ghế, cùng góc máy.
4. Kiểm tra trước khi tạo video: nền giống nhau từng chi tiết, ghế không đổi mẫu, đầu và chân không bị cắt, không watermark.

### Góc máy
- **Một góc cho mỗi động tác** trong MVP. Không ghép hai góc vào một khung: video chỉ chiếm một phần ba trên màn hình điện thoại, chia đôi thì người quá nhỏ; hai lần tạo riêng không khớp nhịp; AI tự ghép hai cảnh thì lệch.
- **Mặc định chính diện, đối xứng (chốt 28/09/2026):** ghế quay thẳng vào máy, người ngồi trên trục giữa ghế, lưng song song lưng ghế, đùi và bàn chân song song, gối trên cổ chân, không chữ V. Áp dụng cả V1 và V2. Quy tắc đầy đủ: [video-skill-notes.md §5e](../video-skill-notes.md). Góc chéo 45 độ cho V1 đã bỏ: Flow không tôn trọng góc và ghế xoay chéo làm tư thế trông lệch.
- Các động tác khác giữ góc đã ghi. Nếu test cho thấy cần thêm góc, thêm nút "Front view" và clip góc thẳng ở phase 2 (tăng số job, chỉ làm cho động tác cần).

## 2. Sáu động tác

### V1 · Sit-to-stand (đếm lần, có "Counted for you")
- **Góc máy:** chính diện, đối xứng (đã thử góc chéo 45 độ: Flow không giữ góc, ghế xoay chéo trông lệch).
- **K1:** ngồi giữa ghế, lưng thẳng, bàn chân phẳng rộng bằng hông, hai tay đặt trên đùi.
- **K2:** đứng thẳng hoàn toàn trước ghế, gối duỗi, hông duỗi, tay buông tự nhiên, mắt nhìn thẳng.
- **Chuyển động (prompt):** She leans her chest forward over her toes, then smoothly stands up to full height in about 2.5 seconds, using her thighs lightly for support. Feet stay planted.
- **Phát:** xuôi 2.5 giây, dừng 0.5 giây, ngược với tốc độ 0.7 (ngồi xuống chậm, có kiểm soát).
- **Bản dễ:** K1 hai tay đặt ở mép ghế; tay đẩy vào ghế khi đứng lên.
- **Bản khó:** K1 và K2 hai tay khoanh trước ngực (tư thế của bài test 30 giây); app phát ngược tốc độ 0.5 (ngồi xuống đếm 3).
- **Lời giọng A4:**
  1. "Sit-to-stand. It helps with getting up from any chair."
  2. "Scoot to the front of your chair. Feet flat, about hip-width apart."
  3. "If you need help, put your hands on the chair and push. That's a great way to start."
  4. "Lean forward, nose over toes… and stand up."
  5. "Now sit back down, slowly. Reach back for the chair with your hips."
  6. "Take a breath whenever you need one."
  7. "Want more? Cross your arms over your chest, and sit down on a slow count of three."
  8. "Lovely. That's your last one."

### V2 · Seated knee lift (tính giờ)
- **Góc máy:** chính diện, đối xứng (ghế vuông góc máy, hai chân cách máy bằng nhau).
- **K1:** ngồi thẳng, hai tay giữ nhẹ mép ghế hai bên, hai bàn chân phẳng.
- **K2:** gối phải nhấc lên khoảng 4 inch (10 cm), bàn chân rời sàn, thân vẫn thẳng, không ngả ra sau.
- **Chuyển động:** She lifts her right knee about four inches, keeping her back tall and her hands resting on the sides of the seat.
- **Phát:** xuôi rồi ngược; lần sau **lật gương** để thành chân trái. Hai bên luân phiên.
- **Bản dễ:** K2 chỉ nhấc gót, mũi chân vẫn chạm sàn.
- **Bản khó:** K2 gối cao hơn, khoảng 8 inch, tay đối diện đưa ra trước như đang đi bộ.
- **Lời giọng A4:**
  1. "Seated knee lifts. The same move you use for every step."
  2. "Hold the sides of your seat lightly. Sit tall."
  3. "Start small. Just lift your heel, then set it down."
  4. "If that feels fine, lift your whole knee a little. Then switch sides."
  5. "Keep your back tall. No need to lean back."
  6. "Want more? Lift a little higher and swing the opposite arm."
  7. "Nice and steady. Ten more seconds."

### V3 · Seated leg extension (tính giờ)
- **Góc máy:** nhìn ngang từ bên phải (ghế và người vẫn thẳng hàng, lưng song song lưng ghế).
- **K1:** ngồi thẳng, hai tay giữ mép ghế, gối gập 90 độ, bàn chân phẳng.
- **K2:** chân phải duỗi thẳng **về phía trước, thẳng hàng với hông**, cao ngang mặt ghế, mũi chân hướng lên trần. Chân trái giữ nguyên.
- **Chuyển động:** She slowly straightens her right leg straight forward, in line with her hip, until it is level with the seat, toes pointing up. The leg does not swing out to the side.
- **Phát:** xuôi 2 giây, app dừng ở K2 (giữ 1–3 giây theo cấp), ngược tốc độ 0.8; lật gương cho chân trái.
- **Bản dễ:** K2 chỉ duỗi nửa chừng, bàn chân cao hơn sàn khoảng 6 inch.
- **Bản khó:** giống bản chính, app giữ ở K2 3 giây.
- **Lời giọng A4:**
  1. "Seated leg extensions. The move you use for climbing stairs."
  2. "Sit tall and hold the sides of your seat."
  3. "Start with a small lift. Straighten your leg just halfway."
  4. "If that's comfortable, straighten it all the way, toes to the ceiling."
  5. "Keep your leg pointing straight ahead… and lower it slowly."
  6. "Want more? Hold it up for a count of three."
  7. "If your knee complains, make the lift smaller. That still counts."

### V4 · Heel and toe raises (tính giờ)
- **Góc máy:** nhìn ngang từ bên phải, khung vẫn toàn thân (tránh cận chân gây lệch tỷ lệ).
- **K1:** ngồi thẳng, hai bàn chân phẳng.
- **K2:** hai gót nhấc lên khoảng 2 inch, mũi chân vẫn chạm sàn. **Chỉ gót nhấc, không nhấc cả bàn chân.**
- **Chuyển động:** She raises both heels about two inches while the balls of her feet stay on the floor. Nothing else moves.
- **Clip phụ V4b (toe raise):** K2 mũi chân nhấc khoảng 2 inch, gót chạm sàn.
- **Phát:** V4 xuôi–ngược 2 lần, rồi V4b xuôi–ngược 2 lần.
- **Bản dễ:** chỉ V4 (gót), bỏ V4b.
- **Bản khó:** đứng sau ghế, hai tay vịn lưng ghế, nhấc gót (K1 đứng, K2 nhón gót). Trước clip có màn "Stand behind your chair".
- **Lời giọng A4:**
  1. "Heel and toe raises. The move you use for reaching a high shelf."
  2. "Sit tall, feet flat on the floor."
  3. "Lift your heels a little, then lower them."
  4. "Now the other way. Lift your toes, heels stay down."
  5. "Small and easy is perfect."
  6. "Want more? Stand behind your chair, hold on with both hands, and rise onto your toes."

### V5 · Wall push-up (tính giờ)
- **Bối cảnh riêng:** HLV đứng trước bức tường trống, ghế đặt gần đó trong khung.
- **Góc máy:** nhìn ngang từ bên phải.
- **K1:** đứng cách tường một sải tay, hai bàn tay áp tường ngang vai, tay duỗi, thân thẳng từ đầu tới gót.
- **K2:** khuỷu tay gập, ngực tiến gần tường khoảng 6 inch, thân vẫn thẳng, gót vẫn chạm sàn.
- **Chuyển động:** She bends her elbows and brings her chest toward the wall, keeping her body in one straight line and her heels on the floor.
- **Phát:** xuôi 2 giây, ngược 2 giây.
- **Bản dễ:** đứng gần tường hơn, K2 chỉ gập khuỷu một chút.
- **Bản khó:** chân lùi xa tường thêm một bước nhỏ.
- **Lời giọng A4:**
  1. "Wall push-ups. They make pushing doors and lifting bags easier."
  2. "Stand about an arm's length from the wall. Hands flat, at shoulder height."
  3. "Start by standing a little closer. Bend your elbows just a bit."
  4. "Bring your chest toward the wall… and press back."
  5. "Keep your body straight, like a plank of wood."
  6. "Want more? Step your feet back a little."

### V6 · Chair-hold single-leg stand (giữ tư thế, tính giây)
- **Góc máy:** nghiêng thuần từ bên phải, ghế vuông góc máy (đã đổi từ 3/4, xem 5·0).
- **K1:** đứng sau ghế, hai tay vịn lưng ghế, hai bàn chân đặt song song.
- **K2:** nhấc chân phải khỏi sàn khoảng 2 inch, gối hơi gập, thân thẳng, hai tay vẫn vịn.
- **Chuyển động:** Holding the chair back with both hands, she lifts her right foot about two inches off the floor and stays balanced.
- **Phát:** xuôi 1.5 giây, **app dừng ở K2** trong thời gian giữ (5–10 giây), ngược; lật gương cho chân trái.
- **Bản dễ:** K2 chỉ nhấc gót, mũi chân vẫn chạm sàn.
- **Bản khó:** K2 chỉ một tay vịn ghế.
- **Lời giọng A4:**
  1. "Balance time. Stand behind your chair and hold on with both hands."
  2. "Start easy. Lift just your heel, toes stay down."
  3. "If you feel steady, lift your foot a little off the floor."
  4. "Look at one spot in front of you. It helps."
  5. "Hold… you're doing great… and set it down."
  6. "If you wobble, that's normal. Hold the chair a little tighter."
  7. "Want more? Try holding on with just one hand."

## 3. Danh sách job trên Flow (mỗi job ≤ 10 giây)
**Cách làm mỗi job:** Frames to Video, khung đầu và khung cuối lấy từ bảng ảnh khung bên dưới. Prompt = CHARACTER + SET + CAMERA (theo góc) + STYLE + câu chuyển động của job + câu thời lượng + NEGATIVE.

**Câu thời lượng (dán vào mọi job):** The movement is slow, smooth and continuous, starts on the first frame and ends exactly on the last frame, and fills the whole clip. No other movement before or after.

**Dựng sau khi tạo:** cắt khung đứng yên ở đầu và cuối · tăng tốc cho pha "lên" còn 2–3 giây (thường gấp 3–4 lần; tạo chậm rồi tăng tốc giữ động tác đúng hơn tạo nhanh) · xuất 1920×1080 hoặc 1280×720, không tiếng · app phát xuôi rồi ngược, lật gương nếu có ghi.

### Cách tạo: phát ngược hoặc vòng khép kín
| Cách | Job | Khung đầu → cuối | Ưu | Nhược | Dùng cho |
|---|---|---|---|---|---|
| **Phát ngược** (mặc định trong bảng 3b) | 1 | tư thế thấp → tư thế cao | ép được tư thế cao; app dừng giữ tùy cấp | pha xuống là phát ngược, có thể trông giả | V3, V6 (có pha giữ); dự phòng cho mọi động tác |
| **Vòng khép kín** | 1 | tư thế thấp → **cùng ảnh đó** | lặp liền mạch; pha xuống là chuyển động thật | không ép được tư thế cao; tăng tốc cả clip cùng tỉ lệ | thử cho V1, V2, V4, V5 |
| **Hai job nối khung** | 2 | thấp → cao, rồi cao → thấp (khung chung) | ép tư thế cao và xuống thật | gấp đôi job | khi vòng khép kín không đứng đủ cao |

**Prompt thêm cho vòng khép kín (V1 làm mẫu):** She leans forward, stands up to full height by the 4-second mark, pauses briefly, then sits back down slowly and returns exactly to the starting pose on the last frame. Her head and feet stay inside the frame the whole time.
**Dựng vòng khép kín:** bỏ khung cuối cùng (trùng khung đầu) để không khựng khi lặp; tăng tốc cả clip về khoảng 6.6 giây (V1); nếu cần pha xuống chậm hơn, chỉnh tốc độ từng đoạn.
**Thử trước:** V1-1 làm cả hai cách (phát ngược và vòng khép kín), so sánh, rồi chọn cách cho V1, V2, V4, V5.

### 3a. Ảnh khung (tạo trước, dùng chung giữa các job)
| Mã | Góc máy | Tư thế | Dùng cho |
|---|---|---|---|
| KD-01 | chính diện | ngồi thẳng, hai tay đặt trên đùi, bàn chân phẳng | V1-1 đầu |
| KD-02 | chính diện | ngồi thẳng, hai tay giữ mép ghế hai bên, bàn chân phẳng | V1-2 đầu |
| KS-02 | ngang, bên phải | ngồi thẳng, hai tay giữ mép ghế hai bên, gối 90 độ, bàn chân phẳng | V3-1 đầu, V3-2 đầu, V4-1 đầu, V4-2 đầu |
| KD-03 | chính diện | ngồi thẳng, hai tay khoanh trước ngực | V1-3 đầu |
| KD-04 | chính diện | đứng thẳng trước ghế, tay buông tự nhiên, đầu và chân trọn trong khung | V1-1 cuối, V1-2 cuối (tạo đầu tiên) |
| KD-05 | chính diện | đứng thẳng trước ghế, hai tay khoanh trước ngực | V1-3 cuối |
| KS-06 | ngang, bên phải | như KS-02, chân phải duỗi thẳng về phía trước ngang mặt ghế, mũi chân hướng lên | V3-1 cuối |
| KS-07 | ngang, bên phải | như KS-02, chân phải duỗi nửa chừng, bàn chân cao hơn sàn khoảng 6 inch | V3-2 cuối |
| KS-08 | ngang, bên phải | như KS-02, hai gót nhấc khoảng 2 inch, mũi chân chạm sàn | V4-1 cuối |
| KS-09 | ngang, bên phải | như KS-02, hai mũi chân nhấc khoảng 2 inch, gót chạm sàn | V4-2 cuối |
| KS-10 | ngang, bên phải | đứng sau ghế, hai tay vịn lưng ghế, bàn chân phẳng | V4-3 đầu |
| KS-11 | ngang, bên phải | như KS-10, nhón hai gót khoảng 2 inch | V4-3 cuối |
| KW-01 | ngang, bên phải, cảnh tường | đứng cách tường một sải tay, tay duỗi áp tường ngang vai | V5-1 đầu |
| KW-02 | như KW-01 | khuỷu gập, ngực gần tường khoảng 6 inch, thân thẳng, gót chạm sàn | V5-1 cuối |
| KW-03 | như KW-01 | đứng gần tường hơn, tay hơi gập sẵn | V5-2 đầu |
| KW-04 | như KW-01 | từ KW-03, khuỷu gập thêm một chút | V5-2 cuối |
| KW-05 | như KW-01 | chân lùi xa tường thêm một bước nhỏ, tay duỗi | V5-3 đầu |
| KW-06 | như KW-01 | từ KW-05, khuỷu gập, ngực gần tường | V5-3 cuối |
| KF-01 | chính diện | ngồi thẳng, hai tay giữ mép ghế, bàn chân phẳng | V2-1, V2-2, V2-3 đầu |
| KF-02 | chính diện | như KF-01, gót chân phải nhấc, mũi chân chạm sàn | V2-2 cuối |
| KF-03 | chính diện | như KF-01, gối phải nhấc khoảng 4 inch | V2-1 cuối |
| KF-04 | chính diện | gối phải nhấc khoảng 8 inch, tay trái đưa ra trước như đang đi | V2-3 cuối |
| KF-05 | chính diện | đứng sau ghế, hai tay vịn lưng ghế, hai chân song song | V6-1, V6-2 đầu |
| KF-06 | chính diện | như KF-05, gót chân phải nhấc, mũi chân chạm sàn | V6-2 cuối |
| KF-07 | chính diện | như KF-05, chân phải nhấc khỏi sàn khoảng 2 inch, gối hơi gập | V6-1 cuối |
| KF-08 | chính diện | đứng sau ghế, chỉ tay phải vịn lưng ghế, tay trái buông | V6-3 đầu |
| KF-09 | chính diện | như KF-08, chân phải nhấc khoảng 2 inch | V6-3 cuối |

27 ảnh khung, cộng 4 ảnh nền trống (KD, KS, KW, KF). Tạo theo quy trình ở mục 1: ảnh nền → tư thế cao nhất → sửa thành tư thế còn lại.

### 3b. Job video
| Job | Động tác · bản | Khung đầu → cuối | Câu chuyển động (prompt) | Dựng |
|---|---|---|---|---|
| V1-1 | Sit-to-stand · chính | KD-01 → KD-04 | She leans her chest forward over her toes, then stands up to full height, hands sliding off her thighs. Feet stay planted. | lên 2.5 giây; ngược tốc độ 0.7 |
| V1-2 | Sit-to-stand · dễ | KD-02 → KD-04 | She leans forward, pushes on the edges of the seat with both hands, and stands up to full height. Feet stay planted. | lên 2.5 giây; ngược tốc độ 0.7 |
| V1-3 | Sit-to-stand · khó | KD-03 → KD-05 | With arms crossed over her chest, she leans forward and stands up to full height without using her hands. | lên 2.5 giây; ngược tốc độ 0.5 |
| V2-1 | Knee lift · chính | KF-01 → KF-03 | She lifts her right knee about four inches, back tall, hands resting on the sides of the seat. | lên 1.5 giây; ngược; lật gương cho chân trái |
| V2-2 | Knee lift · dễ | KF-01 → KF-02 | She lifts only her right heel, toes stay on the floor. | lên 1 giây; ngược; lật gương |
| V2-3 | Knee lift · khó | KF-01 → KF-04 | She lifts her right knee about eight inches and swings her left arm forward, as if walking. | lên 1.5 giây; ngược; lật gương |
| V3-1 | Leg extension · chính (và khó) | KS-02 → KS-06 | She slowly straightens her right leg straight forward, in line with her hip, until it is level with the seat, toes pointing up. The leg does not swing out to the side. | lên 2 giây; app giữ 1 giây (khó: 3 giây); ngược 0.8; lật gương |
| V3-2 | Leg extension · dễ | KS-02 → KS-07 | She straightens her right leg halfway, straight forward, foot about six inches above the floor. | lên 1.5 giây; ngược; lật gương |
| V4-1 | Heel raise · chính và dễ | KS-02 → KS-08 | She raises both heels about two inches while the balls of her feet stay on the floor. Nothing else moves. | lên 1 giây; ngược; lặp 2 lần |
| V4-2 | Toe raise · chính | KS-02 → KS-09 | She lifts the front of both feet about two inches while her heels stay on the floor. Nothing else moves. | lên 1 giây; ngược; lặp 2 lần sau V4-1 |
| V4-3 | Heel raise · khó (đứng) | KS-10 → KS-11 | Holding the chair back with both hands, she rises onto the balls of her feet about two inches. Body stays upright. | lên 1.5 giây; ngược 0.8 |
| V5-1 | Wall push-up · chính | KW-01 → KW-02 | She bends her elbows and brings her chest toward the wall, body in one straight line, heels on the floor. | lên 2 giây; ngược 2 giây |
| V5-2 | Wall push-up · dễ | KW-03 → KW-04 | Standing close to the wall, she bends her elbows slightly more. | lên 1.5 giây; ngược |
| V5-3 | Wall push-up · khó | KW-05 → KW-06 | With her feet a little farther back, she bends her elbows and brings her chest toward the wall, body straight. | lên 2 giây; ngược 2 giây |
| V6-1 | Single-leg stand · chính | KF-05 → KF-07 | Holding the chair back with both hands, she lifts her right foot about two inches off the floor and stays balanced. | lên 1.5 giây; app giữ 5–10 giây; ngược; lật gương |
| V6-2 | Single-leg stand · dễ | KF-05 → KF-06 | Holding the chair back with both hands, she lifts only her right heel; toes stay down. | lên 1 giây; app giữ; ngược; lật gương |
| V6-3 | Single-leg stand · khó | KF-08 → KF-09 | Holding the chair back with only her right hand, she lifts her right foot about two inches and stays balanced. | lên 1.5 giây; app giữ; ngược; lật gương |

### 3c. Thời lượng từng video
- **Tạo trên Flow:** mọi job đặt **8 giây** (dưới giới hạn 10 giây, đủ chỗ cho chuyển động chậm).
- **Clip sau dựng:** chỉ pha "lên", đã cắt khung thừa và tăng tốc. Đây là file đưa vào app.
- **Một vòng trong app:** lên + giữ (app dừng khung cuối) + xuống (app phát ngược, tốc độ ghi trong ngoặc). Động tác một bên chân: vòng ghi cho một bên, hai bên gấp đôi.

| Video | Tạo trên Flow | Clip sau dựng | Giữ (app) | Xuống (app phát ngược) | Một vòng trong app |
|---|---|---|---|---|---|
| V1-1 Sit-to-stand · chính | 8 giây | 2.5 giây | 0.5 giây | 3.6 giây (0.7×) | 6.6 giây |
| V1-2 Sit-to-stand · dễ | 8 giây | 2.5 giây | 0.5 giây | 3.6 giây (0.7×) | 6.6 giây |
| V1-3 Sit-to-stand · khó | 8 giây | 2.5 giây | 0.5 giây | 5.0 giây (0.5×) | 8.0 giây |
| V2-1 Knee lift · chính | 8 giây | 1.5 giây | 0 | 1.5 giây (1×) | 3.0 giây mỗi bên · 6.0 giây hai bên |
| V2-2 Knee lift · dễ | 8 giây | 1.0 giây | 0 | 1.0 giây (1×) | 2.0 giây mỗi bên · 4.0 giây hai bên |
| V2-3 Knee lift · khó | 8 giây | 1.5 giây | 0 | 1.5 giây (1×) | 3.0 giây mỗi bên · 6.0 giây hai bên |
| V3-1 Leg extension · chính | 8 giây | 2.0 giây | 1 giây | 2.5 giây (0.8×) | 5.5 giây mỗi bên · 11.0 giây hai bên |
| V3-1 Leg extension · khó (cùng clip) | — | 2.0 giây | 3 giây | 2.5 giây (0.8×) | 7.5 giây mỗi bên · 15.0 giây hai bên |
| V3-2 Leg extension · dễ | 8 giây | 1.5 giây | 0 | 1.5 giây (1×) | 3.0 giây mỗi bên · 6.0 giây hai bên |
| V4-1 Heel raise · chính và dễ | 8 giây | 1.0 giây | 0 | 1.0 giây (1×) | 2.0 giây · lặp 2 lần = 4.0 giây |
| V4-2 Toe raise · chính | 8 giây | 1.0 giây | 0 | 1.0 giây (1×) | 2.0 giây · lặp 2 lần = 4.0 giây (nối sau V4-1: 8.0 giây) |
| V4-3 Heel raise · khó (đứng) | 8 giây | 1.5 giây | 0 | 1.9 giây (0.8×) | 3.4 giây |
| V5-1 Wall push-up · chính | 8 giây | 2.0 giây | 0 | 2.0 giây (1×) | 4.0 giây |
| V5-2 Wall push-up · dễ | 8 giây | 1.5 giây | 0 | 1.5 giây (1×) | 3.0 giây |
| V5-3 Wall push-up · khó | 8 giây | 2.0 giây | 0 | 2.0 giây (1×) | 4.0 giây |
| V6-1 Single-leg stand · chính | 8 giây | 1.5 giây | 5–10 giây | 1.5 giây (1×) | 8–13 giây mỗi bên |
| V6-2 Single-leg stand · dễ | 8 giây | 1.0 giây | 5–10 giây | 1.0 giây (1×) | 7–12 giây mỗi bên |
| V6-3 Single-leg stand · khó | 8 giây | 1.5 giây | 5–10 giây | 1.5 giây (1×) | 8–13 giây mỗi bên |

Tổng thời gian tạo trên Flow: 17 job × 8 giây. Tổng thời lượng clip đưa vào app: khoảng 28 giây (nhẹ khi đóng gói offline). Giữ ở V6 do cấp của người dùng quyết định: dễ 5 giây, chính 8 giây, khó 10 giây.

**Tổng: 17 job video, 27 ảnh khung, 4 ảnh nền.** Thứ tự làm: V1-1 và V3-1 trước (cần nền KD và KS, KD-04, KD-01, KS-06, KS-02), huấn luyện viên duyệt, sửa prompt, rồi làm phần còn lại theo góc máy (hết nhóm KD, KS, rồi KW, rồi KF) để giữ ánh sáng và vị trí ghế đồng nhất. Báo giá credit trước mỗi đợt. Nếu một job hỏng, chỉ tạo lại job đó.

## 4. Nhận xét lượt thử 28/09/2026 (Flow)
- Nhân vật đã đúng mô tả: khoảng 58–62 tuổi, tóc muối tiêu, kính, áo sage, legging tối, giày trắng.
- Lỗi cần sửa: phòng và ghế đổi giữa các ảnh (ghế Windsor phòng nhiều đồ, ghế thang phòng trống, một ảnh ghép hai phòng) · video Sit-to-stand mất đầu khi đứng ở khoảng giây 2 · cuối video chuyển sang phòng khác có TV · vẫn có dấu ✦.
- Đã sửa trong kịch bản: khối SET tối giản với một ghế cố định, khối CAMERA khung hình theo tư thế đứng, NEGATIVE cấm cắt đầu và đổi cảnh, quy trình ảnh khung sửa từ cùng một ảnh, V1 đổi sang góc chéo 45 độ.

## 5·0. Bản hiện hành: đủ 6 clip chính V1–V6 (28/09/2026) — ĐẠT, chờ huấn luyện viên duyệt
Mục 5 và 5b bên dưới là **bản cũ (góc chéo, đã bỏ, file đã xoá)**; giữ lại làm bài học.
| Clip | File (`assets/video/<id>/`, bản 1080p trong `1080/`) | Số đo |
|---|---|---|
| V1-1 Sit-to-stand | `V1-1_loop.mp4` 7.6 giây lặp liền (ngồi 0–1.0 · đứng lên 1.0–2.0 · giữ đứng 2.0–4.4 · ngồi xuống 4.4–5.3 · ổn định 5.3–7.6) · `V1-1_preview.mp4` 40 giây, giới thiệu + 3 lần · `V1-1_flow-source.mp4` | đầu ≥ 11% · máy lệch 1.6 · nối 0.16 · max 1.38 |
| V2-1 Seated knee lift | `V2-1_loop.mp4` 2.5 giây = một cặp trái–phải · `V2-1_preview.mp4` 35 giây, giới thiệu + 8 cặp | nhấc 0.71/0.72 giây · nghỉ 0.50/0.50 · đầu 30% (ngồi, cùng khung V1) |
| V3-1 Seated leg extension | `V3-1_loop.mp4` 8.9 giây: chân gần máy duỗi–giữ–hạ, rồi chân xa (đã làm chậm 1.3× cho bằng lần 1) · `V3-1_preview.mp4` 42 giây, giới thiệu + 3 vòng | máy lệch 0.55 · nối 0.61 |
| V4-1 Heel and toe raises | `V4-1_loop.mp4` 7.6 giây: 2 lần nhấc gót rồi 2 lần nhấc mũi (lần cuối tăng tốc 0.8×) · `V4-1_preview.mp4` 33 giây | máy lệch 0.70 · nối 0.73 |
| V5-1 Wall push-up | `V5-1_loop.mp4` 8.0 giây: 2 lần, mỗi lần khoảng 3.2 giây, thân thẳng, gót chạm sàn · `V5-1_preview.mp4` 40 giây | máy lệch 0.59 · nối 0.77 |
| V6-1 Single-leg stand | `V6-1_loop.mp4` 8.3 giây: chân gần nhấc–giữ–hạ, rồi chân xa (1.1×) · `V6-1_preview.mp4` 36 giây | máy lệch 0.69 · nối 0.75 · chân nhấc 4–6 inch, cao hơn kịch bản 2 inch: HLV xem lại |
Mốc cắt: V1 `3.4-4.3,4.3-6.1x1.2,6.1-8.0x0.5,0.0-0.6x0.5,0.6-2.3x1.3,2.3-3.4` · V2 `2.15-3.35,3.35-4.15x1.3,4.15-4.35` · V3 `0.0-4.4,4.4-7.4x1.3,7.4-8.0` · V4 `0.0-6.1,6.1-7.9x0.8,7.9-8.0` · V5 `0.0-8.0` · V6 `0.0-4.6,4.6-7.4x1.1,7.4-8.0`. Cấu hình giọng/phụ đề V3–V6: `tools/video/make_preview_configs_v3_v6.py`.
**Một khung máy cho mọi clip (chốt 28/09/2026):** V2 làm lại vì người to hơn V1 khoảng 1.25× (ảnh khung V2 cũ tạo riêng, máy gần hơn). Mọi ảnh khung giờ lấy từ **khung hình thật của video V1** (1080p) rồi sửa: V2 chỉ sửa tay; V3, V4 xoay người và ghế sang nghiêng; V6 xoay sang nghiêng, đứng sau ghế; V5 bỏ ghế, thêm mảng tường bên phải. Phòng, sàn, khoảng cách máy và cỡ người giữ nguyên.
**Góc máy:** V1, V2 chính diện; V3–V6 nghiêng thuần (profile) nhìn từ bên phải, ghế vuông góc máy. V6 đổi từ 3/4 sang nghiêng để ghế không xoay chéo và thấy rõ chân nhấc.
**Giọng:** ElevenLabs Bella cho cả 6 bài, lời theo A4. V2 đổi "Right, then left" thành "One side, then the other" vì AI nhấc chân trái trước.
**Chi phí:** V1+V2 bản chính diện 24 credit; V2 làm lại cùng khung + V3–V6: 5 lượt × 12 = 60 credit; tất cả đạt ở lượt đầu. Ảnh 0 credit.

## 5. Kết quả V1-1 Sit-to-stand (28/09/2026) — bản cũ góc chéo, đã thay
**File:** `assets/video/V1-1/`
| File | Dùng cho |
|---|---|
| `V1-1_loop.mp4` | clip trong app: 1280×720, 24 fps, không tiếng, 7.4 giây, bắt đầu từ tư thế ngồi, lặp liền |
| `V1-1_preview.mp4` | video hướng dẫn xem thử 39 giây: giới thiệu + 3 lần, giọng tạm (macOS Samantha), phụ đề động kiểu CapCut: đủ lời, chạy theo từ (từ đang đọc tô vàng), 48 pt trên nền sage, bên trái không che người |
| `V1-1_voice.srt`, `V1-1_chunks.srt` | phụ đề theo câu và theo cụm chữ khớp video xem thử |
| `V1-1_flow-source_try2.mp4` | bản gốc từ Flow, 8 giây, để dựng lại khi cần |

**Mốc trong clip lặp:** ngồi 0–0.6 · nghiêng và đứng lên 0.6–3.3 · giữ đứng 3.3–3.9 · ngồi xuống 3.9–6.1 (đã làm chậm 1.3×) · ổn định 6.1–7.4. Điểm nối cuối về đầu lệch 0.48 (trung bình giữa hai khung liên tiếp 0.46), không giật.

**Chấm theo 6 điểm:** đứng thẳng hẳn ✓ · không mất đầu, chân (đỉnh đầu luôn cách mép trên khoảng 7%) ✓ · chân không trượt ✓ · ngồi xuống có kiểm soát ✓ · khung cuối trùng khung đầu ✓ · phòng, ghế, nhân vật không đổi ✓.
**Còn lại:** dấu ✦ ở góc phải dưới (gói Pro vẫn có; cần gói không watermark trước khi dùng thương mại) · khi ngồi xuống HLV với tay ra sau chạm ghế (an toàn, khác kịch bản "tay trên đùi") · góc máy gần chính diện, chưa đúng 45 độ · giọng là giọng tạm.

### Công thức đã chạy được trên Flow
1. **Nhân vật:** Characters → tạo **GWCoach** (mô tả người, nền studio xám) → sửa áo dài che hông → gọi bằng `@GWCoach` trong prompt.
2. **Ảnh khung (Nano Banana 2, 0 credit, x2):** chế độ tạo trực tiếp, **không dùng Agent** (Agent tự viết lại prompt: thêm sofa, cây, đồng hồ). Tạo **tư thế cao nhất** (đứng) trước.
3. **Video (Omni 1.1 Flash, 720p, 8 giây, 16:9, x1 = 12 credit):** Frames, **khung đầu = khung cuối = ảnh tư thế cao nhất** (đứng), prompt: đứng → ngồi xuống → nghiêng → đứng lên, "the framing stays exactly as in the first frame".
4. **Dựng (ffmpeg):** cắt 3.6–7.3 + 0.4–0.6 + 0.6–2.3 (chậm 1.3×) + 2.3–3.6, bỏ tiếng → clip lặp bắt đầu từ ngồi.

**Bài học:**
- Lượt 1 (khung ngồi làm đầu và cuối) **mất đầu khi đứng**: Flow tự phóng to khung khi sửa ảnh đứng thành ảnh ngồi. → Vòng khép kín luôn dùng **tư thế cao nhất** làm khung đầu và cuối; tư thế thấp tự nằm gọn trong khung.
- Áp dụng cho V2 (gối cao nhất), V4-3, V5 (tay duỗi), V6: khung đầu/cuối là tư thế cao hoặc rộng nhất.
- Chi phí V1-1: 2 lượt video = 24 credit; ảnh 0 credit.

## 5b. Kết quả V2-1 Seated knee lift (28/09/2026) — bản cũ góc 3/4, đã thay
**File:** `assets/video/V2-1/` — `V2-1_loop.mp4` (8.1 giây, không tiếng, phải–trái–phải–trái, lặp liền) · `V2-1_preview.mp4` (31 giây, giọng tạm, phụ đề động kiểu CapCut, đủ lời, bên phải, không chạm ghế) · `V2-1_voice.srt` · `preview.json` · `V2-1_flow-source_try2.mp4`.
**Khác kịch bản:** không lật gương; một clip chứa cả hai chân luân phiên (tránh cảnh đổi bên cửa sổ khi lật). Góc chéo 3/4 đạt (thấy rõ đùi và ống chân gần máy).

| Lần | Chân | Thời gian nhấc | Độ cao (px, crop chân) |
|---|---|---|---|
| 1 | phải (gần máy) | 1.33 giây | 55 |
| 2 | trái (xa máy) | 1.42 giây | 68 |
| 3 | phải | 1.42 giây | 57 |
| 4 | trái | 1.46 giây (đã làm chậm 1.25× từ 1.12) | 50 |
Khoảng nghỉ: 0.62 · 0.50 · 0.58 · 0.79 giây (dài nhất ở điểm nối). Điểm nối 0.90, máy quay lệch 0.65, đầu 7%.
**Còn lại:** độ cao chân trái lần 2 thấp hơn lần 1 · dấu ✦ · giọng tạm.

**Lượt thử:** lượt 1 hỏng đối xứng (chân phải 3 lần, chân trái 1 lần và cao hơn nhiều). Lượt 2 sửa prompt: **đúng 4 lần, luân phiên, mốc thời gian cho từng lần (0–2, 2–4, 4–6, 6–8 giây), "same speed and same height… mirror copies", nói rõ chân nào gần máy**. Chi phí V2-1: 24 credit.

## 6. Cần kiểm tra
- Câu mở đầu mỗi bài chỉ gắn động tác với việc đời thường (đứng dậy khỏi ghế, leo cầu thang, với kệ cao), không hứa lợi ích sức khoẻ hay giảm nguy cơ ngã.
- Phát ngược Sit-to-stand có trông như ngồi xuống thật không, hay cần tạo riêng pha ngồi xuống.
- Lật gương có lộ chi tiết lệch không (tóc, bóng đổ, ánh sáng cửa sổ bên trái sẽ thành bên phải).
- Nhịp giọng khớp nhịp clip: câu "stand up" phải bắt đầu cùng lúc clip bắt đầu pha lên.
- Huấn luyện viên duyệt: độ cao nhấc chân, khoảng cách tường, tư thế lưng.
