# P — Thư viện prompt và thông số sản xuất (Flow · ElevenLabs · Eleven Music) · bản nháp 1
_30/09/2026 · Thực thi kế hoạch [plans/2026-09-30-content-4-groups.md](../plans/2026-09-30-content-4-groups.md) · Prompt tiếng Anh, ghi chú tiếng Việt · Quy trình, QA và bẫy: [video-skill-notes.md](../video-skill-notes.md) · Chuẩn tư thế: [research/2026-09-30-exercise-standards.md](../research/2026-09-30-exercise-standards.md) (STD) · Kỹ thuật: [research/2026-09-30-flow-elevenlabs-production-notes.md](../research/2026-09-30-flow-elevenlabs-production-notes.md) (PROD)_

## 0. Cách dùng (cho agent)

1. Không tiêu credit trước khi chủ app OK bảng credit của đợt (12 credit/lượt 720p Omni 1.1 Flash; tối đa 3 lượt/clip; draft 360p ≈ 4 credit để thử prompt).
2. Mọi prompt video = **khối chung §1** (theo góc máy) + **khối riêng của clip** (§3–§6). Flow: Video → Frames → 16:9 → Omni 1.1 Flash → 720p → 8 s hoặc 10 s → x1; **Start = End = cùng một file ảnh khung**; `@GWCoach` trong prompt; tắt Agent; bật "Return silent videos".
3. Prompt **không** ép tốc độ nhanh/chậm. Prompt chỉ yêu cầu: tư thế đúng, chu kỳ **đều**, chuyển động lấp đầy clip. Tốc độ đích (easy / quicker / bản dễ chậm) làm ở §6 bằng time-remap có nội suy khung.
4. Sau khi tải (720p + 1080p Upscaled): **crop dấu ✦ bằng tool của chủ app** — trước tiên `/usr/bin/python3 tools/video/crop_avoid_logo.py <src_1080p> --detect-only --headroom 70` (nền khó dò: thêm `--logo x1,y1,x2,y2`) → **guard** `crop_subject_check.py <src_1080p> --crop W,H,X,Y --tool-headroom 70` (W,H,X,Y lấy từ dòng `crop` tool in ra). PASS → chạy tool thật với cùng `--headroom 70 --no-audio`. FAIL mà guard in "fits at y …: re-run with --headroom N" → chạy lại tool với `--headroom N` rồi guard lại. FAIL "taller than the window" → **tạo lại ảnh khung** trong ô CROP-SAFE, không nới crop. (`--headroom 70` thay mặc định 24 vì `subject_top` của tool bỏ sót 40–45 px tóc bạc sáng — đo 30/09 trên ảnh gốc và W1-1 v2; xem video-skill-notes §5c.) → **QC crop** (góc dưới phải 8 khung không còn dấu; `qa_measure.py` đầu ≥ 5%; kích thước 1688×950) → `contact_sheet.sh` → `qa_measure.py` (+ `lift_symmetry.py` hoặc `leg_displacement.py`) → chấm checklist STD §8.1 từng dòng → `build_loop.py` trên file `_nologo` → (§6 retime nếu cần) → QA lại → ảnh khung PNG → `preview.json` + `build_preview.py`. Ghi vào §9. Không tự viết cách crop khác; chỉ chạy tool.
5. Clip lệch kịch bản (AI thêm động tác an toàn, nhấc cao hơn…) → ghi lại ở §9, không sửa kịch bản cho hợp clip.

### 0.1 Bảng mã clip

| Mã | Nhóm | Bài | Góc / ảnh khung | Dài | Kiểu | Đợt |
|---|---|---|---|---|---|---|
| W1-1 | Walk seated | March | F-SIT (MF-01) | 8 s | nhịp | có |
| W1-2 | Walk seated | Heel dig | F-SIT | 8 s | nhịp | A |
| W1-3 | Walk seated | Side step (step out–in) | F-SIT | 8 s | nhịp | A |
| W1-4 | Walk seated | Knee lift | F-SIT | 8 s | nhịp | A |
| W1-5 | Walk seated | Toe tap forward | F-SIT | 8 s | nhịp | A |
| W1-6 | Walk seated | Weight shift | F-SIT | 8 s | nhịp | A |
| W2-1 | Walk in place | March | F-STAND (MF-02) | 8 s | nhịp | A |
| W2-2 | Walk in place | Side step | F-STAND-WIDE (MF-06) | 8 s | nhịp | A |
| W2-3 | Walk in place | Knee lift | F-STAND | 8 s | nhịp | A |
| W2-4 | Walk in place | Heel dig | P-STAND (MF-04) | 8 s | nhịp | A |
| W2-5 | Walk in place | Toe tap forward | P-STAND | 8 s | nhịp | B |
| W2-6 | Walk in place | Heel to back | P-STAND-CHAIR (MF-04c) | 8 s | nhịp | B |
| W2-7 | Walk in place | Weight shift | F-STAND | 8 s | nhịp | B |
| V1-1…V6-1 | Chair | 6 bài hiện có | — | — | — | có |
| V8-1 | Chair | Side leg raise | F-BEHIND (MF-02b) | 10 s | rep | A |
| V9-1 | Chair | Back leg raise | P-STAND-CHAIR | 10 s | rep | A |
| V10-1 | Chair | Knee curl | P-STAND-CHAIR | 10 s | rep | A |
| V11-1 | Chair | Mini-squat | P-STAND-CHAIR | 10 s | rep | A |
| V12-1 | Chair | Arm raises front/side | F-SIT | 10 s | rep | A |
| V13-1 | Chair | Seated row | F-SIT | 10 s | rep | A |
| V1-alt … | Chair | bản dễ khác tư thế (sit-to-stand tay đẩy ghế; heel raise ngồi; wall push-up gần tường; single-leg nhấc gót) | như bài gốc | 8–10 s | rep | B (V1-alt, V4-alt: A) |
| S1 | Stretch | Neck turn | F-SIT | 10 s | vào tư thế 2 bên | A |
| S2 | Stretch | Side of the neck | F-SIT | 10 s | vào 2 bên | A |
| S3 | Stretch | Chin tuck | P-SIT (MF-03c) | 8 s | nhịp chậm | A |
| S4 | Stretch | Shoulder rolls | F-SIT | 8 s | nhịp chậm | A |
| S5 | Stretch | Chest and shoulders | F-SIT (ngồi xa lưng ghế) | 8 s | vào 1 bên | A |
| S6 | Stretch | Upper back reach | P-SIT | 8 s | vào 1 bên | A |
| S7 | Stretch | Upper back twist | F-SIT | 10 s | vào 2 bên | A |
| S8 | Stretch | Side stretch | F-SIT | 10 s | vào 2 bên | A |
| S9 | Stretch | Back of the thigh | P-SIT | 10 s | vào 2 bên | A |
| S10 | Stretch | Ankle circles and points | P-SIT | 8 s | nhịp chậm | A |
| S11 | Stretch | Calf stretch | P-STAND-CHAIR | 10 s | vào 2 bên | A |
| S12 | Stretch | Overhead reach at the wall | P-WALL (MF-05c) | 8 s | vào 1 bên | A |
| S<n>-hold[-L/-R] | Stretch | clip giữ (thở, chớp mắt) | như S<n> | 8 s | giữ | B |
| B1 | Balance | Tandem stance (heel-to-toe stand) | P-STAND-CHAIR | 8 s | giữ có vào | A |
| ~~B2~~ | Balance | Sideways walking | — | — | **bỏ video (chốt 30/09)**: dùng clip W2-2 side step làm hình minh hoạ, giọng dẫn đi ngang | — |
| B3 | Balance | Heel-to-toe walk | P-WIDE | 10 s | nhịp | B |

Bản dựng từ cùng nguồn (không tốn credit): `<mã>-easy`, `<mã>-quick` (§6).

## 1. Khối chung

**CHARACTER (mọi prompt, sau `@GWCoach`):** the same woman as the reference: looks 58 to 62, salt-and-pepper shoulder-length hair with a centered part, thin-frame glasses, fuller figure, sage green long-sleeve top that covers the hips, charcoal high-waist leggings, plain white sneakers, no jewelry, no watch. Same face, same hair, same clothes and the same body size as in the first frame. Calm, confident, slight natural smile.

**SET-ROOM (mặc định):** A minimal, empty room: plain warm white wall with a simple white baseboard, light oak floor, soft diffused daylight from a window outside the frame on the left. One wooden ladder-back dining chair without armrests or wheels, light oak, is the only object in the room; nothing else appears (no plants, shelves, lamps, pictures, rug or curtains).
**SET-WALL (V5, S12):** the same room and light; a plain empty wall fills the right part of the frame; the chair stands at the far left edge of the frame.
**SET-WIDE (W2-2, B2, B3):** the same room and light, framed wider so there is clear floor for three steps to each side; the chair stands against the wall at the left edge.

**CAMERA-FRONT (F-*):** Static tripod shot, locked off, one continuous shot, eye-level camera at the hip height of a standing adult, 16:9. The chair faces the camera squarely, its back parallel to the image plane and directly behind her. She is on the chair's center line; shoulders level; thighs parallel and hip-width apart, knees straight forward directly above the ankles, feet flat, parallel, toes forward (no V shape). Her body center is at about 38% of the frame width; the right third of the frame is empty wall. Standing, the top of her head is about 12% below the top edge and her soles about 12% above the bottom edge, so she fills about 76% of the frame height; sitting keeps this same framing (no zoom in). Her whole body, the chair and her farthest reach stay inside the left 86% of the frame. No pan, tilt, zoom, reframing or cuts; the framing stays exactly as in the first frame for the whole clip; head and feet always fully visible.
**CAMERA-PROFILE (P-*):** as CAMERA-FRONT, but a clean exact side view: the chair is turned 90 degrees so its back is parallel to the camera axis, **she faces the right edge of the frame** (same as the approved V3–V6 clips; a leg or arm reaching forward goes into the empty wall on the right); her body center at about 38–45% of the frame width.
**CAMERA-WIDE:** as CAMERA-FRONT but framed one third wider so she can take three steps to each side and stay fully inside the frame; her standing height is about 65% of the frame.

**STYLE:** Photorealistic, natural skin texture, soft daylight, calm and clean. Silent video. The only person is her; the only furniture is the one chair (or the chair and the wall as described). No text, captions, subtitles, logos or watermarks are part of the scene.

**TEMPO-REP (bài rep và nhịp — không nói nhanh/chậm, chỉ nói đều):** Every repetition has exactly the same speed, the same range and the same path. The movement fills the whole clip: it starts within the first second and the last repetition ends exactly in the starting pose on the last frame. No repetition is smaller, lower, faster or cut short than the others; no rushing toward the end; no pause longer than a breath between repetitions. Natural, realistic movement of a healthy woman around 60, not athletic, not rushed, not exaggerated.

**BODY-RULES (mọi clip):** Knees stay soft, never locked; knees point the same way as the toes and never collapse inward. Elbows never lock. Back tall, chin level, eyes looking straight ahead (never up at the ceiling). Feet stay flat unless the move says otherwise; both feet never leave the floor at the same time; no jumping. Hands stay where the move places them and do not fidget. Breathing is calm and visible but small.

**HOLD (clip giữ):** She holds the described pose perfectly still for the whole clip. The only motion is quiet breathing: her chest and shoulders rise and fall slowly, about one breath every four seconds, and one slow blink around 00:03 and one around 00:06. Hands, feet, head angle and the chair do not move at all. The last frame is identical to the first frame.

**CROP-SAFE (công thức cố định, chốt 30/09/2026):** dấu ✦ của Omni luôn bắt đầu ở x ≥ 1701, y ≥ 862 (1080p; 8/8 clip đo được) → `crop_avoid_logo.py` luôn cắt **1688 × 950 tại x = 0**, y trượt 0–130 để giữ đầu (24 px headroom) và chân. Suy ngược cho ảnh khung và prompt: **toàn bộ người + ghế (kể cả tay/chân duỗi xa nhất) phải nằm trong ô 0–1656 px ngang (≤ 86% chiều rộng) và cao không quá 890 px (≤ 82% chiều cao)**. Quy về câu prompt: `Her whole body, including the chair and her farthest reach, stays inside the left 86% of the frame. Standing, the top of her head is about 12% below the top edge and her soles about 12% above the bottom edge (she fills about 76% of the frame height).` **Vị trí ngang (thêm 30/09 sau lỗi V5):** tâm người ở **28–48% chiều rộng khung sau crop (đích ~38%)**, tức hơi lệch trái — phần trống bên phải để tay/chân duỗi về phía mặt nhìn. Guard báo `coach centre N% of crop width` và FAIL ngoài dải (`--center 28,48`). Nano Banana bỏ qua lệnh dời người sang trái (thử lệnh "truck move… one third of the width": người gần như không đổi chỗ) → sửa tại máy, 0 credit: `/usr/bin/python3 tools/video/recenter_frame.py <khung.jpg> <khung-mới.jpg> --shift <px>` (xoá ✦ của ảnh bằng miếng vá lấy từ chính ảnh, dời cả ảnh sang trái, lấp dải phải bằng ảnh gương — dải này gần như nằm ngoài cửa sổ crop); px = (tâm hiện tại % − 39) × 12,1 ở ảnh 1376 px. Kiểm ảnh khung trước khi tạo video: `/usr/bin/python3 tools/video/crop_subject_check.py <frame.png>` → PASS. (Agent chạy tool crop của chủ app sau khi tạo; không tự nghĩ cách crop khác.)

## 2. Ảnh gốc và ảnh khung gốc (Nano Banana, 0 credit, tắt Agent)

**Kết quả M2 (30/09/2026)** — file ở `assets/video/frames/` (JPG 1376×768, tải "1K Original", không upscale), bảng duyệt `assets/video/frames/M2-frames-sheet.jpg`. Tạo trong Flow project "Sep 30 - 11:09", nhân vật `GWCoach` (ảnh tham chiếu = `W1-1v2_start-frame.png`). Mọi ảnh qua tool crop (`--headroom 70`) + guard: **PASS**.
| Ảnh | File | Người: đỉnh–đáy (px @1080) · cao | Ghi chú |
|---|---|---|---|
| GWCoach-master = MF-02 | `GWCoach-master.jpg`, `MF-02_F-STAND.jpg` | 106–916 · 75% | tạo mới rồi sửa "zoom out" (lần đầu người cao 83–84%, Nano Banana bỏ qua con số %) |
| MF-01 F-SIT | `MF-01_F-SIT.jpg` | 192–919 · 67% | lượt đầu "Failed" (không tính phí), thử lại đạt |
| MF-02b F-BEHIND | `MF-02b_F-BEHIND.jpg` | 106–995 (chân ghế) · 82% | sát ngưỡng dưới (khe 36 px) |
| MF-03 P-SIT | `MF-03_P-SIT.jpg` | 191–888 · 64% | quay mặt sang phải (giữ, khớp V3–V6); tâm 46% sát ngưỡng → dùng MF-03c |
| MF-03c P-SIT | `MF-03c_P-SIT.jpg` | 191–888 · 65% | MF-03 dời trái 82 px bằng `recenter_frame.py`; tâm 39%, guard PASS. Dùng cho S3, S6, S9, S10 |
| MF-04b P-STAND-CHAIR | `MF-04b_P-STAND-CHAIR.jpg` | 55–892 · 77% | người + ghế lệch sang ~55% ngang; đầu sát trên (tool chọn y≈31) — **tâm 53% → không đạt luật ngang, dùng MF-04c** |
| MF-04c P-STAND-CHAIR | `MF-04c_P-STAND-CHAIR.jpg` | 55–892 · 78% | MF-04b dời trái 174 px bằng `recenter_frame.py` (✦ của ảnh được xoá); tâm 39%, guard PASS. Dùng cho V9–V11, S11, B1, W2-6 |
| MF-05 P-WALL | `MF-05_P-WALL.jpg` | 213–988 · 72% | góc phòng; lượt 1 ra cột tường sai → sửa thành góc; lùi máy thêm để tay giơ quá đầu (S12) còn trong khung — guard lại trên clip S12 — tâm 55% → dùng MF-05c |
| MF-05c P-WALL | `MF-05c_P-WALL.jpg` | 213–~922 · 66% | MF-05 (tâm 55%) dời trái 188 px bằng `recenter_frame.py`; tâm 39%. Guard báo "bottom −31" là báo nhầm vân sàn (đế giày y≈922, vừa ở mọi y 0–130). Dùng cho S12 |
| MF-05c P-WALL-HANDS | `MF-05c_P-WALL-HANDS.jpg` | 208–~950 · 69% | MF-05b (tay áp tường, tâm 56%) dời trái 204 px bằng `recenter_frame.py`; tâm 39%. Guard báo "bottom −15" là **báo nhầm** (vân sàn dưới giày bị tính là chân); đo tay: đế giày y≈948, cách mép crop ~96 px. Dùng cho V5 |
| MF-06 F-STAND-WIDE | `MF-06_F-STAND-WIDE.jpg` | 126–894 · 71% | ghế sát tường trái; W2-2/B2 chỉ bước sang phải rồi về, không cần chỗ bên trái |
| MF-04 P-STAND | — | — | chưa làm (chỉ dùng cho clip đợt B) |
Bài học: con số phần trăm trong prompt ảnh bị bỏ qua; mô tả khoảng trống bằng vật ("empty wall as tall as her head and neck") và lệnh sửa "Zoom out… camera 30% farther back" thì ăn. Sửa ảnh luôn chọn đúng phiên bản gốc trong lịch sử trước khi gõ lệnh. Ảnh tạo trong Flow có sẵn ✦ ở góc (khác vị trí dấu video) — nằm ngoài cửa sổ crop.


**Ảnh gốc GWCoach-master (tạo mới, không dùng khung đã upscale):** `@GWCoach` standing upright and relaxed, arms at her sides, feet hip-width apart, facing the camera, in SET-ROOM, CAMERA-FRONT framing (standing height rule), STYLE. Sharp, clean edges, no halo around hair or shoulders, no over-sharpening. → chọn ảnh không viền sáng, kiểm trên contact sheet 200%.

Mọi ảnh khung dưới đây **sửa từ GWCoach-master** ("same scene, same camera, same lighting, same body size; only change: …"), không tạo mới từ đầu (video-skill-notes §5f).

| Mã | Ảnh khung gốc | Chỉ thị sửa |
|---|---|---|
| MF-01 F-SIT | ngồi chính diện | Only change: she now sits tall in the middle of the seat on the chair's center line, toward the front of the seat, back upright and parallel to the chair back, hands resting on her thighs, feet flat and hip-width apart, toes forward. Framing, room and chair unchanged. |
| MF-02 F-STAND | đứng chính diện trước ghế | = master (đứng thẳng, tay xuôi), ghế ngay sau. |
| MF-02b F-BEHIND | đứng sau ghế, 2 tay vịn lưng ghế | Only change: she now stands directly behind the chair, both hands resting lightly on the top of the chair back, arms relaxed, feet hip-width apart; the chair back is between her and the camera. |
| MF-03 P-SIT | ngồi nghiêng | Rotate only the woman and her chair 90 degrees in place so the camera sees a clean, exact side profile from her right; she faces the left edge of the frame; seated tall, hands on thighs, feet flat. Room, camera distance and body size unchanged. |
| MF-04 P-STAND | đứng nghiêng, ghế bên trái (gần tường) | Side profile as MF-03 but standing tall, arms relaxed; the chair stands just to her left within reach (toward the left edge). |
| MF-04b P-STAND-CHAIR | đứng nghiêng sau ghế, tay vịn | Side profile: she stands behind the chair with her right hand (nearest the camera) resting on the top of the chair back, left hand also on the chair back, feet hip-width apart. |
| MF-05 P-WALL | đứng nghiêng đối tường | SET-WALL; side profile from her right; she faces the wall at the left, standing a little more than an arm's length from it, arms relaxed at her sides; the chair at the far left edge behind her is out of the way. |
| MF-06 F-STAND-WIDE | đứng chính diện, khung rộng | SET-WIDE + CAMERA-WIDE; she stands centered-left with clear floor on both sides; the chair against the wall at the left edge. |

Kiểm trước khi tạo video: một ghế duy nhất, đầu/chân trọn khung, kích thước người bằng master (đo chiều cao người px), không viền sáng, không ✦ (ảnh tải lên từ máy), và **`crop_subject_check.py <ảnh>` = PASS** (người + ghế trong ô 86% × 82%). Với bài dang tay/duỗi chân (V8, V12, S5, S8, S12, W2-2, B2): kiểm cả ảnh khung ở tư thế rộng nhất.

## 3. Clip đi bộ (W) — 8 s, 2 chu kỳ ≈ 4 s… **hoặc** nhịp bước tự nhiên; Start = End = ảnh khung

Prompt = `@GWCoach` + CHARACTER + SET-ROOM + CAMERA (theo bảng) + STYLE + BODY-RULES + TEMPO-REP + **ACTION** dưới đây. Nhịp mục tiêu trong prompt: **one step about every 0.6 seconds** (≈ 96–100 spm, giữa easy và quicker; hai bản trong app dựng ở §6). Với bài luân phiên: nói rõ chân nào trước (gần máy khi nghiêng), số bước và mốc giây, "mirror copies".

| Mã | ACTION |
|---|---|
| W1-1 (có) | Seated march: [00:00-00:08] Sitting tall toward the front of the seat, hands resting lightly on her thighs, she marches in place: the right thigh lifts so the foot rises straight up about 10 centimeters under the knee, then sets down flat; then the left; one step about every 0.6 seconds, continuously for the whole clip, every step the same height and speed, mirror copies left and right. Feet land flat, toes forward; no kick, no lean back. |
| W1-2 | Seated heel dig: [00:00-00:08] Sitting tall, hands on her thighs, she slides her right foot forward and plants the heel on the floor with the toes lifted toward her, then brings it back flat under the knee; then the left; one change about every 0.7 seconds, continuously, both sides mirror copies, same reach every time. Upper body stays still. |
| W1-3 | Seated side step: [00:00-00:08] Sitting tall, hands on her thighs, she steps her right foot out to the side about one foot-width (foot stays flat and slides low), then back to hip-width; then the left foot out and back; one step about every 0.7 seconds, continuously, same distance every time. Knees stay pointing the same way as the toes; hips stay still on the seat. |
| W1-4 | Seated knee lift: as W1-1 but each thigh lifts higher, the foot about 20 centimeters off the floor, the knee never higher than the hip; hands hold the sides of the seat lightly; one lift about every 0.8 seconds, alternating, mirror copies. |
| W1-5 | Seated toe tap forward: [00:00-00:08] Sitting tall, hands on her thighs, she extends her right leg a little and taps the toes on the floor about 30 centimeters in front of the chair with the knee slightly bent, then returns the foot flat under the knee; then the left; one tap about every 0.7 seconds, continuously, mirror copies, same reach. No kick above knee height. |
| W1-6 | Seated weight shift: [00:00-00:08] Sitting tall with feet flat a little wider than hip-width, hands on her thighs, she shifts her weight gently to the right so the right hip and thigh take more weight and the torso leans a few degrees, then through the middle to the left; one full side-to-side cycle every 4 seconds, two identical cycles, both feet always flat. Head stays level. |
| W2-1 | Standing march in place: [00:00-00:08] Standing tall next to the chair, arms bent at the elbows and swinging naturally close to the body (opposite arm to leg), she marches on the spot: the right thigh lifts so the foot rises straight up about 15 centimeters under the knee and lands flat heel first, then the left; one step about every 0.6 seconds, continuously, every step the same height and speed, mirror copies. Arms never swing out to the sides; knees stay below hip height. |
| W2-2 | Side step: SET-WIDE, CAMERA-WIDE. [00:00-00:08] She steps her right foot to the right about one shoulder-width and brings the left foot to meet it, then steps the left foot to the left and brings the right to meet it; one step about every 0.7 seconds, two steps right then two steps left, continuously, always returning to the same center spot; knees soft, hips level (no dropping to one side), hands loosely on her hips. |
| W2-3 | Standing knee lift: as W2-1 but each thigh lifts to just below hip height (the foot about 25 centimeters off the floor), the foot pointing forward; her left hand rests lightly on the chair back; one lift about every 0.8 seconds, alternating, mirror copies. |
| W2-4 | Heel dig (profile): [00:00-00:08] Standing tall, the chair within reach behind her, she places her right heel (nearest the camera) on the floor about one step in front with the toes lifted toward her shin and the standing knee soft, then brings it back under her; then the left; one change about every 0.7 seconds, continuously, mirror copies, same reach every time; arms swing gently opposite. |
| W2-5 | Toe tap forward (profile): as W2-4 but the toes tap the floor in front with the knee slightly bent, heel up; no kick; one tap about every 0.7 seconds, alternating. |
| W2-6 | Heel to back (profile, chair): [00:00-00:08] Standing behind the chair, both hands on the chair back, she bends her right knee to bring the heel back toward her buttock about halfway (thigh stays vertical, standing knee soft, no leaning forward), then sets the foot down flat; then the left; one curl about every 1 second, continuously, mirror copies, same height every time. |
| W2-7 | Standing weight shift: [00:00-00:08] Standing with feet a little wider than hip-width, knees soft, hands loosely on her hips, she shifts her weight to the right leg so the left heel lightens (stays touching the floor), then through the middle to the left; one full cycle every 4 seconds, two identical cycles; knees track over the toes, head level, torso upright. |

Dựng: `build_loop.py` lấy đúng số cặp bước nguyên ở giữa clip (như W1-1: 2 cặp = 2,33 s) → §6 tạo `-easy` (0,90–0,92×) và `-quick` (1,06–1,10×) rồi **cắt lại đúng số chu kỳ nguyên** sau remap để mối nối ≤ 1,5.

## 4. Clip ghế mới (V8–V13) — 10 s, 2 rep × 4 s + đệm; Start = End

Prompt = `@GWCoach` + CHARACTER + SET-ROOM + CAMERA + STYLE + BODY-RULES + TEMPO-REP + ACTION. Nhịp trong prompt: **lên 2 giây, giữ 1 giây, xuống 2 giây** (đều; bản dễ "xuống chậm" làm ở §6). Hai bên trong cùng clip khi bài một bên (rep 1 chân gần máy, rep 2 chân xa).

| Mã | Ảnh khung | ACTION |
|---|---|---|
| V8-1 Side leg raise | MF-02b | [00:00-00:01] She stands behind the chair, both hands on the chair back, feet hip-width apart, standing still. [00:01-00:05] She lifts her right leg straight out to the side about 20 centimeters, toes pointing forward, torso upright and not leaning, standing knee soft: 2 seconds up, 1 second hold, 2 seconds down to flat. [00:05-00:09] The same with the left leg, a mirror copy at the same height and speed. [00:09-00:10] She stands still in the starting pose until the last frame. Hips stay level; the lifted foot stays low. |
| V9-1 Back leg raise | MF-04c | Side profile behind the chair, both hands on the chair back. Rep 1: she lifts her right leg (nearest the camera) straight back about 20 centimeters without bending the knee and without leaning forward or arching her back, 2 seconds up, 1 second hold, 2 seconds down. Rep 2: the left leg, mirror copy. Starting pose at the start and the end. Toes point down, not out. |
| V10-1 Knee curl | MF-04c | Side profile behind the chair, both hands on the chair back. Rep 1: she bends her right knee to bring the heel back and up toward her buttock about halfway, thigh vertical, standing knee soft, torso upright, 2 seconds up, 1 second hold, 2 seconds down to flat. Rep 2: left leg, mirror copy. Starting pose first and last. |
| V11-1 Mini-squat | MF-04c (tay vịn) | Side profile, both hands on the chair back, feet hip-width apart. Two identical shallow squats: she bends her knees only halfway, sitting back a little so the knees stay over the middle of the feet and never pass the toes, heels flat, back straight and chest up, 2 seconds down, 1 second hold, 2 seconds up to standing with knees soft. Starting pose first and last. The squat is small; the thighs never reach horizontal. |
| V12-1 Arm raises | MF-01 | Front view, seated tall, hands starting on her thighs. Rep 1: both arms rise straight forward, elbows soft, palms down, to shoulder height and no higher, 2 seconds up, 1 second hold, 2 seconds down. Rep 2: both arms rise straight out to the sides to shoulder height, 2 seconds up, 1 second hold, 2 seconds down. Shoulders stay down, back tall, feet flat. Starting pose first and last. |
| V13-1 Seated row | MF-01 | Front view, seated tall. She starts with both arms extended forward at shoulder height, palms facing each other. Two identical reps: she draws her elbows straight back past her ribs, squeezing the shoulder blades together, forearms level, 2 seconds back, 1 second hold, 2 seconds forward to extended arms. Torso upright and still, feet flat, chin level. Starting pose (arms extended) first and last. |

Bản dễ khác tư thế (B; V1-alt, V4-alt làm ở A): V1-alt sit-to-stand hai tay đẩy mép ghế (như V-exercise-clips V1-2) · V4-alt heel raise **ngồi** (V4-1 hiện đã ngồi → V4-alt là **đứng vịn ghế**, khó hơn; bản dễ = chỉ gót, dựng từ V4-1) · V5-alt wall push-up đứng gần tường · V6-alt single-leg chỉ nhấc gót · V8/V9/V10-alt biên nhỏ hơn (dùng lại prompt, "about 10 centimeters") · V11-alt "bends the knees only a quarter". Bản "xuống chậm" (sit-to-stand 1,3×, mini-squat) dựng từ nguồn ở §6.

## 5. Clip giãn cơ (S) — vào tư thế (A) và giữ (B)

**Vào tư thế, hai bên (10 s):** `[00:00-00:01]` starting pose still · `[00:01-00:03]` slowly into the pose on the LEFT side · `[00:03-00:05]` holds still, breathing · `[00:05-00:06]` slowly back to the middle · `[00:06-00:08]` slowly into the pose on the RIGHT side, a mirror copy · `[00:08-00:09]` holds still · `[00:09-00:10]` slowly back to exactly the starting pose. Với góc nghiêng: bên gần máy trước. Với tư thế một bên (8 s): vào 2 s · giữ 4 s · ra 2 s.
Thêm sau TEMPO: "The movement into the stretch is slow and smooth with no bounce; the pose is moderate, never extreme; her face stays relaxed."

| Mã | Ảnh khung | POSE (điền vào mẫu) | Không được (viết vào prompt dạng khẳng định) |
|---|---|---|---|
| S1 Neck turn | MF-01 | turns her head to look over her left shoulder as far as is comfortable, chin level, shoulders down and still | chin stays level (no tilting up or down); the torso does not turn |
| S2 Side of the neck | MF-01 | rests her right hand on top of her left shoulder, keeps that shoulder down, and tilts her head to the right, ear toward the right shoulder, a small comfortable tilt | the hand does not pull the head; the chin stays forward |
| S3 Chin tuck (nhịp chậm, 8 s) | MF-03c | glides her head straight back to make a gentle double chin, eyes level, then releases; 4 identical slow tucks, one every 2 seconds | the head does not tip up or down; the shoulders stay still |
| S4 Shoulder rolls (nhịp chậm, 8 s) | MF-01 | rolls both shoulders slowly up, back and down in a smooth circle; 4 identical circles, one every 2 seconds, hands resting on thighs | the head stays still; no shrug-and-drop |
| S5 Chest (một bên, 8 s) | MF-01 (ngồi xa lưng ghế) | sitting forward away from the chair back, opens both arms out to the sides at shoulder height, palms forward, draws the shoulders back and down and lifts the chest gently | the lower back does not arch; the chin stays level |
| S6 Upper back reach (một bên) | MF-03c | seated, brings both arms forward at shoulder height with palms facing away and reaches the hands forward so the upper back rounds slightly between the shoulder blades, head in line with the spine | the lower back stays upright; she does not bend forward at the waist |
| S7 Upper back twist | MF-01 | with arms crossed and hands on opposite shoulders, turns her upper body to the left from the chest, head turning with the chest, hips and feet still | the hips do not move; the turn is small and smooth |
| S8 Side stretch | MF-01 | reaches her right arm up and over her head and leans gently to the left, left hand resting on the seat, both hips staying on the seat | no forward bend, no twist; the lean is small |
| S9 Back of the thigh | MF-03c | sitting toward the front of the seat, extends her right leg (nearest the camera) forward with the heel on the floor and toes up, hands on the left thigh, and hinges forward from the hips a little with a long straight back | the back stays straight (no rounding); the forward lean is small, well under 90 degrees at the hip |
| S10 Ankle (nhịp chậm, 8 s) | MF-03c | holding the side of the seat, lifts her right foot just off the floor and slowly points the toes away, then pulls them back toward her; 3 slow cycles, one every 2 seconds, then sets the foot down | the knee stays still; only the ankle moves |
| S11 Calf stretch | MF-04c | with both hands on the chair back, steps her right foot (nearest the camera) back about one shoe length and bends the front knee a little, keeping the back leg straight and the back heel flat on the floor, hips facing forward | the back heel never lifts; no bouncing |
| S12 Overhead reach at the wall (một bên) | MF-05c | facing the wall with both palms on it at shoulder height, walks her hands slowly up the wall until the arms are above her head as far as is comfortable, then holds | the heels stay flat; the lower back does not arch; the head does not tip back |

**Clip giữ (B, 8 s):** ảnh khung = khung giữ lấy từ clip vào tư thế (bên trái và bên phải riêng); prompt = `@GWCoach` + CHARACTER + SET + CAMERA + STYLE + **HOLD** + một câu tả tư thế đang giữ (từ cột POSE). Lặp crossfade 0,4 s; app phát clip giữ trong 15–30 s.

## 6. Kỹ thuật nhịp (retime) và clip thăng bằng

### 6.1 Retime bằng time-remap có nội suy khung (đã thử trên W1-1 30/09/2026)
Nguyên tắc: **prompt tạo một nhịp tự nhiên; tốc độ đích dựng bằng kỹ thuật** (quyết định chủ app 30/09). Biên: 0,75×–1,3×; tua thô (chỉ `setpts`, không nội suy) ≤ 1,15×.

```bash
# F = hệ số tốc độ (0.92 = chậm hơn, 1.08 = nhanh hơn). Chạy trên bản 1080p, 24 fps.
F=0.92; IN=W2-1_loop_1080p.mp4; OUT=W2-1-easy_1080p.mp4
ffmpeg -y -i "$IN" -vf "setpts=PTS/$F,minterpolate=fps=24:mi_mode=mci:mc_mode=aobmc:me_mode=bidir:vsbmc=1" -an -c:v libx264 -crf 16 -preset slow "$OUT"
```
- Đo thử W1-1 (2,33 s): 0,92× → 2,46 s; 1,08× → 2,13 s; 17 s xử lý mỗi bản; trung vị frame-to-frame 0,51–0,57 (nguồn 0,57), max 1,07–1,17 (nguồn 1,22) → **không giật thêm**; nhoè nhẹ ở giày đang di chuyển trong 1–2 khung (chấp nhận được ở ±8%).
- **Mối nối lặp tăng** (1,13 → 1,62/1,95) vì remap làm lệch khung cuối → sau remap phải **cắt lại đúng số chu kỳ nguyên** (`build_loop.py` trên file đã remap, chọn mốc từ `leg_displacement.py`) hoặc crossfade 0,3 s.
- Nhoè rõ (ghosting hai giày) hoặc hệ số > 1,15× / < 0,85× → dùng RIFE (`rife-ncnn-vulkan`, local) tạo 48 fps rồi `setpts` + `fps=24`; nếu vẫn nhoè → giảm hệ số hoặc tạo clip riêng.
- Bản dễ "xuống chậm" (sit-to-stand, mini-squat): remap **chỉ đoạn xuống** 1,25–1,3× (`build_loop.py` với `xSLOW` trên đoạn đã nội suy).
- QA sau remap: nhịp đo được ±5% nhịp đích (đếm đỉnh `leg_displacement.py` / thời gian); max ≤ 3× trung vị; contact sheet 12 fps vùng chân không có bóng đôi; mối nối ≤ 1,5.

### 6.2 Clip thăng bằng
| Mã | Ảnh khung | ACTION |
|---|---|---|
| B1 Tandem stance | MF-04c | Side profile behind the chair, both hands on the chair back. [00:00-00:01] standing still, feet hip-width. [00:01-00:03] She slowly places her right foot (nearest the camera) directly in front of the left so the right heel touches the left toes, both feet pointing forward on one line, knees soft. [00:03-00:07] She holds this heel-to-toe stance perfectly still, breathing quietly, eyes level looking ahead, hands resting on the chair back. [00:07-00:08] She steps the right foot back beside the left to the starting pose. |
| B2 Sideways walking (**bỏ 30/09**, lưu làm tham khảo) | MF-06 | SET-WIDE, CAMERA-WIDE. [00:00-00:10] Starting centered, hands loosely on her hips, she takes three slow side steps to the right (step the right foot out about one shoulder-width, bring the left to meet it, feet always pointing forward, hips level, knees soft), pauses one second, then three side steps to the left back to the same center spot, pauses one second, and repeats the same to the right and back once more, ending exactly at the starting spot in the starting pose. Every step is the same length and speed; she looks straight ahead, not at her feet. |
| B3 Heel-to-toe walk (B) | P-WIDE (MF-06 xoay nghiêng) | Side view, a wall within reach on her left. Six slow heel-to-toe steps forward, each heel touching the toes of the other foot, fingertips brushing the wall, eyes ahead, knees soft, one step every 1.5 seconds, then two ordinary steps to stop still. (App phát một chiều, không lặp; dùng làm demo.) |

## 7. Giọng (ElevenLabs)

### 7.1 Cài đặt (render_lines.py / build_preview.py)
```json
{
  "model_id": "eleven_multilingual_v2",
  "voice_settings": { "stability": 0.65, "similarity_boost": 0.75, "style": 0.10, "use_speaker_boost": true, "speed": 0.92 },
  "seed": 20260930,
  "output_format": "mp3_44100_192",
  "apply_text_normalization": "auto",
  "previous_text": "<câu trước trong cùng bài, đưa vào hash cache>",
  "pronunciation_dictionary_locators": ["<gw-terms>"]
}
```
- A/B `speed` 0.92 với 0.88 trên 3 câu (setup, đếm, thở); nghe với người 50+. Không dùng audio tag của v3 cho coach; ngắt bằng `<break time="0.8s" />` (≤ 2 tag/câu, ≤ 1,0 s) hoặc "…"; khoảng lặng giữa các câu do timeline app đặt (PROD §3.3).
- Từ điển phát âm `gw-terms`: "Gentle Walk" (nhấn đều), "sit-to-stand" (không đọc dấu gạch), "heel dig", "tandem", tên địa danh (Camino de Santiago, Bethesda).
- Chuẩn hoá `loudnorm` I=−16 LUFS, TP −1,5 dB; chuông −18 LUFS; nhạc −26 LUFS khi có giọng (ducking trong player).
- Trước khi tạo hàng loạt: mua Creator; nghe lại Elise Hart / Jane Hackett / Carol so với Bella; **tạo lại toàn bộ cache** trên gói mới; lưu hoá đơn + ảnh trang giọng có ngày.

### 7.2 Mẫu câu theo kiểu bài (điền tên bài; ≤ 16 từ/câu; theo Tone & copy rules)
| Khe | Bài rep (ghế) | Bài nhịp (đi bộ) | Giãn cơ | Thăng bằng |
|---|---|---|---|---|
| intro | "<Name>. It helps with <việc đời thường>." | "<Name>. Easy steps, at your pace." | "<Name>." | "Balance time. Hands on your chair." |
| demo | "Watch one first. <mô tả tư thế ngắn>." | "Like this. <mô tả>." | "Here's the shape. <mô tả>." | "Here's how it looks." |
| setup | "<ghế/tay/chân>. Take a breath." | "Feet flat, shoulders easy." | "Sit toward the front of your chair, feet flat." | "Hold the chair with both hands." |
| go | "Now with me. Breathe out as you lift… in as you lower." | "Now with me. Find a steady rhythm." | "Ease into it slowly. A gentle pull, never pain." | "Lift… and hold. Look at one spot ahead." |
| mid | đếm rep "one… two…" hoặc "keep it smooth" | "Still able to talk? That's your pace." (Steady/Strong) | "Breathe into it. No bouncing." | "Wobbling is normal. Hold a little tighter." |
| warn | "Ten more seconds, then we change." | "Ten more seconds, then a new step." | "Three more breaths." | "Five more seconds." |
| easier | "Easier: <bản dễ>. That still counts." | "Easier: heel taps. That still counts." | "Easier: <bản dễ>." | "Easier: keep both hands on. Just lift your heel." |
| harder | "Want more? <bản khó>." | "Want more? <tay/gối>." | — (giữ lâu hơn) | "Want more? One hand on the chair." |
| switch | "And the other side." | "Other side leads." | "Come back to the middle… and the other side." | "Hands back on the chair. Other foot." |
| rest | "Rest. Three easy breaths." | — | "And slowly come back. Sit tall." | "Feet together. Breathe." |
| safety (1 lần/buổi) | "If it hurts, make it smaller or skip it. Stop and rest if you feel chest pain, dizziness or can't catch your breath." | | | + "Keep the chair within reach the whole time." |

Kiểm từng câu: STD §8.2 · không từ cấm · không số sức khoẻ · tên bài + trái/phải giống thẻ và phụ đề · `python3 tools/lint/copy_lint.py` → 0 findings.

## 8. Nhạc (Eleven Music) và chuông

Mỗi bài `POST /v1/music` với `music_length_ms: 150000`, `force_instrumental: true`, `model_id: music_v2_5`; tạo 4 bản mỗi phong cách, chọn 3–4; lưu prompt + ngày + gói. Không có loop liền mạch → intro/outro mềm cùng pad, app crossfade 2 s.

| Phong cách | Prompt |
|---|---|
| Feel-good 70s–80s (mặc định, đi bộ) | Instrumental only. Warm, feel-good late-70s soft-pop groove at 98 BPM, key of G major: light drum kit with brushes, round electric bass, Rhodes electric piano, clean rhythm guitar, subtle strings pad; steady and unhurried, no vocals, no solos, no big changes; gentle 8-bar intro that fades in from a soft pad and an 8-bar outro that fades back to the same pad so the track loops; 150 seconds. |
| Calm piano (giãn cơ, thở) | Instrumental only. Calm solo felt piano with a soft warm pad, 62 BPM, key of D major, slow and spacious, no drums, no melody hook that repeats obviously, gentle 8-bar intro swelling from the pad and 8-bar outro fading to the same pad for looping; 150 seconds. |
| Country (tuỳ chọn) | Instrumental only. Easygoing acoustic country at 96 BPM, key of A major: acoustic guitar, light brushed drums, upright bass, soft pedal steel in the background; relaxed and steady, no vocals, no solos; soft 8-bar intro and outro on the same sustained pad for looping; 150 seconds. |

Bản đi bộ: 96–104 BPM khớp nhịp bước (một bước mỗi phách); calm piano không dùng trong pha đi bộ.

**Chuông (ffmpeg, 0 chi phí, không giấy phép):** chuông đổi pha 2 nốt trầm (D4→G4), chuông đếm 1 nốt, chuông xong 3 nốt lên.
```bash
ffmpeg -y -f lavfi -i "sine=frequency=293.66:duration=1.4" -f lavfi -i "sine=frequency=392:duration=1.6" \
 -filter_complex "[0]afade=t=in:d=0.01,afade=t=out:st=0.5:d=0.9,volume=0.5[a];[1]adelay=650|650,afade=t=in:d=0.01,afade=t=out:st=0.6:d=1.0,volume=0.45[b];[a][b]amix=inputs=2:normalize=0,aformat=sample_rates=44100,loudnorm=I=-18:TP=-1.5" \
 -t 2.4 phase_chime.wav
```
Thêm hài âm 2× tần số ở volume 0.15 nếu muốn "kim loại" hơn. SFX ElevenLabs chỉ khi muốn âm singing bowl (PROD §4.2).

## 9. Kết quả sản xuất (agent điền)
Credit Flow: Omni 1.1 Flash 720p · **8 s = 12, 10 s = 15**. Tổng M3 (30/09/2026): **180 credit** (814 → ~634), gồm 24 credit làm lại V8 sau khi chủ app bắt lỗi chân chạm sàn và 15 credit làm lại V5 sau khi chủ app bắt lỗi người lệch phải. File: `assets/video/M3/<mã>/` (nguồn `_tryN_720p.mp4`, sau crop `_nologo.mp4`, vòng lặp `_loop.mp4`), lưới duyệt `assets/video/M3/M3_review_grid.mp4`. Tất cả 720p (bản 1080p Upscaled tải sau khi chủ app duyệt).
| Mã | Lượt · credit | Kết quả | Số đo | Ghi chú / lệch kịch bản |
|---|---|---|---|---|
| V5 Wall push-up (làm lại) | 2 · 30 | **Đạt (lượt 2)** | vòng 3,83 s (lần 1: xuống ~2,2 · lên ~1,3 s); nối 0,31 sau crossfade 0,35 s; trôi máy 0,27; guard PASS, **tâm 40%** | lượt 1 (tâm 57%, lệch phải — chủ app bắt lỗi; guard lúc đó chưa đo ngang) → giữ `V5_try1_loop_offcentre.mp4` để so. Lượt 2 dùng khung `MF-05c_P-WALL-HANDS.jpg` (MF-05b dời trái bằng `recenter_frame.py`). Lần 2 trong clip ngắn và nhún giữa chừng → chỉ lấy lần 1 |
| W2-1 March in place | 1 · 15 | **Đạt** | 13 bước luân phiên đều, ~0,75 s/bước (≈78 spm, chậm hơn prompt 0,6 s nhưng đều); vòng 2 chu kỳ 3,08 s, nối 1,25; `-easy` ×1,12 (≈87 spm), `-quick` ×1,28 (≈100 spm) bằng `retime.py`, không bóng đôi, nối ~2,0 | chân nhấc thấp (gần như đi tại chỗ nhấc gót) — hợp nhóm mới tập; headroom tool 72 (720p) |
| V8 Side leg raise | 5 · 66 | **Đạt (làm lại)** | vòng 14,2 s = nâng trái (lượt 4) + nâng phải (lượt 5), crossfade 0,3 s ở tư thế nghỉ; mỗi bên bàn chân **trên không liên tục ~3 s** (trái 1,75–5,0 s, phải 1,75–4,5 s), chân xiên ~30°, dưới gối; nối 0,54; guard PASS | lượt 1–2 đá cao ~45° lệch bên; lượt 3 (prompt "vừa rời sàn, vài cm") **chân chạm sàn giữa pha giữ** — tôi chấm sót, chủ app bắt lỗi. Prompt đúng: "sole at about the middle of her other shin, ~20 cm… stays in the air the whole hold, never touches or brushes the floor… never a kick, never higher than her other knee". Mỗi clip một chân |
| S5 Chest stretch | 1 · 15 | **Đạt** | vào 1–2 s · giữ 2–6,75 s (thở nhẹ) · ra 6,75–8 s; nối 0,70 | bàn tay hơi ngửa cao hơn vai một chút — chủ app xem |
| S5-hold | 0 · 0 | **Đạt (không tạo video)** | đoạn giữ 2,5–6,5 s của S5, phát xuôi + ngược = 8 s; nối 0,19 | thay cho clip "đứng yên thở" riêng (P §5) — tiết kiệm 15 credit/tư thế |
| B2 Sideways walking | 4 · 54 | **Không đạt — dừng** | lượt 1: không quay về điểm đầu; lượt 2: gần như không di chuyển; lượt 3 (2 khung nối A→B): đi đúng hướng nhưng **bắt chéo chân** ở giây 2,5 và 6–6,5 | **Chốt 30/09 (a):** không làm video đi ngang; màn Balance dùng clip **W2-2 Side step** (bước sang–khép tại chỗ) làm hình minh hoạ, giọng HLV vẫn dẫn "10 side steps along the counter" theo Otago; clip W2-2 vì thế bắt buộc ở đợt A |

### 9.2 Mốc 5 — đợt A (30/09/2026, chạy song song 2 tài khoản Flow)
Tài khoản chính (`Sep 30 - 11:09`, nhân vật `@GWCoach`): Walks + Chair. Tài khoản 2 (`trananhquan23896`, project `Sep 30 - 16:11`, không có nhân vật — chỉ khung Start = End, mở đầu prompt bằng "The woman in the first frame"): Stretches + Balance. Nguồn ở `assets/video/A/<mã>/` (`_tryN_720p.mp4`, `_nologo.mp4`, `_loop.mp4`, `-easy/-quick_loop.mp4`, `-hold_loop.mp4`); file app ở `iOS/App/Resources/Media/Video/`.
Quy tắc rút ra: **bài một bên = mỗi bên một clip** rồi ghép (`join.sh`, crossfade 0,3 s + crossfade vòng 0,5 s); mô tả bên theo **phía của ảnh** ("toward the LEFT side of the image") vì AI hay nhầm trái/phải của người — khi vẫn ra ngược bên thì chỉ đổi nhãn; bài động tác bàn chân tiến/lùi quay **nghiêng**; tư thế với tay cao thì crop lại bằng `--headroom` guard gợi ý; nền tường sáng làm tool dò nhầm ✦ → `--logo 1134,575,1200,632` (720p).

| Mã | Lượt | Kết quả / ghi chú |
|---|---|---|
| W1-2 heel dig | 2 | lượt 1 chính diện khó thấy → nghiêng MF-03c đạt |
| W1-3 side step | 4 | lượt 1 hai chân cùng ra; lượt 2 chân phải đứng ngoài; tách R + L (L lượt 2) → ghép, dùng lần bước đầu mỗi bên |
| W1-4 knee lift | 2 | lượt 1 thấp như march → mốc "đế giày ngang giữa ống chân kia" đạt |
| W1-5 toe tap | 3 | chính diện khó thấy; nghiêng lượt 1 ra heel dig; "gót nhấc, mũi chạm, không phải heel dig" đạt |
| W1-6 weight shift | 2 | lượt 1 lệch to/nhỏ; lượt 2 chu kỳ đầu cân (+10/−9 px) |
| W2-2 / W2-3 / W2-4 | 1 / 1 / 1 | đạt; W2-4 dùng khung tường MF-05c (chưa có MF-04 P-STAND) |
| V1 / V1-alt | 1 / 1 | crop lại `--headroom 150` (đứng lên cao hơn khung ngồi) |
| V4-alt heel raise đứng | 1 | quay nghiêng MF-04c (chính diện không thấy gót) |
| V6 single-leg | 2 (R+L) | V6-R crop `--headroom 39` |
| V9 back leg / V10 knee curl | 2 + 2 | đạt, lệch nhỏ: V9 hơi nghiêng trước, chân cao hơn một bàn tay; V10 đùi hơi ra trước |
| V11 mini-squat | 1 | hơi sâu hơn nửa chừng |
| V12 arm raises | 1 | đạt |
| V13 seated row | 2 | chính diện khuỷu mở ngang vai → nghiêng MF-03c đạt |
| S1 neck turn | 2 (R+L) | ra ngược bên → đổi nhãn |
| S2 side of neck | 4 | lượt 1 (tay đặt vai) đầu nghiêng sai hướng → bỏ tay, nghiêng tai về vai (NHS); lượt 2 ngược bên → đổi nhãn; mắt nhắm lúc giữ |
| S3 chin tuck | 2 | lượt 1 ngửa cằm (lỗi an toàn) → "như ngăn kéo đóng, mắt nhìn thẳng" đạt |
| S4 shoulder rolls / S6 / S7 / S9 / S10 | 1 / 1 / 2 / 2 / 1 | đạt; S10 duỗi thẳng chân rồi gập duỗi cổ chân (biến thể, gối yên) |
| S8 side stretch | 3 | 2 clip đầu cùng nghiêng trái → S8-R lượt 2 theo phía ảnh; crop `--headroom 115/122` |
| S11 calf | 3 | S11-R lượt 1 nhấc gót sau → "cả bàn chân sau áp sàn" đạt |
| S12 overhead wall | 2 | lượt 1 tay rời tường, vượt khung → tay trượt trên tường tới hơi cao hơn đầu; tool crop dò nhầm ✦ → `--logo` |
| B1 tandem | 1 | đạt |
