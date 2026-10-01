# Ghi chú để xây skill video bài tập (từ V1-1 Sit-to-stand, 28/09/2026)
_Nguồn: phiên làm V1-1 và V2-1 trên Google Flow + dựng bằng ffmpeg. Kết quả: `assets/video/V1-1/`. Kịch bản 17 job: [scripts/V-exercise-clips.md](scripts/V-exercise-clips.md). Quy tắc sản phẩm: [app-context.md](../app-context.md)._

## 1. Skill cần làm gì
Đầu vào: một động tác trong kịch bản (mã job, tư thế đầu/cuối, câu chuyển động, lời giọng).
Đầu ra cho mỗi động tác:
| File | Mô tả |
|---|---|
| `<ID>_loop.mp4` | clip trong app: 16:9, 1280×720, 24 fps, không tiếng, lặp liền, bắt đầu ở tư thế thấp |
| `<ID>_preview.mp4` | video hướng dẫn xem thử: giới thiệu + 3 lần, giọng tạm, phụ đề không che người |
| `<ID>_voice.srt` | phụ đề khớp video xem thử |
| `<ID>_flow-source.mp4` | bản gốc Flow để dựng lại |
| `preview.json` | cấu hình cue để dựng lại video xem thử |

## 2. Quy trình 7 bước (đã chạy được)
1. **Nhân vật (một lần cho cả app):** Flow → Characters → mô tả người trên nền studio xám → sửa tới khi đúng (áo dài che hông) → đặt tên **GWCoach**, điền Character info → gọi bằng `@GWCoach` trong prompt.
2. **Ảnh khung tư thế cao nhất:** chế độ tạo trực tiếp (tắt Agent), Image, Nano Banana 2, 16:9, x2, prompt = `@GWCoach` + tư thế + SET tối giản + CAMERA. Chọn ảnh đầu và chân trọn khung, ghế đúng chỗ. Nếu ảnh là bản sửa trong một ảnh có nhiều phiên bản: mở ảnh → lịch sử → **Save to projects** để tách thành ảnh riêng.
3. **Video:** Video → Frames → 16:9 → Omni 1.1 Flash → 720p → 8s → x1. **Start = End = ảnh tư thế cao nhất.** Prompt: tư thế cao → tư thế thấp → tư thế cao, kèm "the framing stays exactly as in the first frame".
4. **Tải về:** mở video → Download → 720p (Original size). File vào `~/Downloads`.
5. **QA tự động:** `tools/video/contact_sheet.sh` (nhìn) + `tools/video/qa_measure.py` (đo) + `tools/video/lift_symmetry.py` cho động tác luân phiên. Không đạt → sửa prompt một chỗ → quay lại bước 3.
6. **Dựng clip lặp:** xác định mốc pha từ số đo (cột head_top), rồi `tools/video/build_loop.py` với danh sách đoạn, bắt đầu từ tư thế thấp, làm chậm pha đi xuống nếu nhanh.
7. **Video xem thử:** viết `preview.json` (cue theo pha) → `tools/video/build_preview.py` → xem khung ở các mốc cue.

## 3. Khối prompt đã chạy tốt
- **Ảnh khung:** `@GWCoach stands upright directly in front of a wooden ladder-back dining chair (light oak, no armrests, no wheels), arms relaxed… A minimal, empty room: plain warm white wall with a simple white baseboard, light oak floor, soft daylight from a window just outside the frame on the left. The chair is the only object in the room. No plants, no shelves… Photorealistic wide shot, 16:9. Camera on a tripod at hip height… Her head is about 10% below the top edge and her feet about 8% above the bottom edge; full body in frame with space around her. No text, no logos, no watermark, no other people.`
- **Video (vòng khép kín từ tư thế cao):** `Static tripod shot, the camera never moves: no pan, no tilt, no zoom, no reframing, no cuts… The framing stays exactly as in the first frame for the whole clip, so her head and feet are always fully visible. …starts standing… slowly sits down… pauses seated… leans her chest forward so her nose is over her toes… stands up… ending exactly in the starting pose on the last frame. Her feet stay planted… Natural, realistic movement of a healthy woman around 60, not athletic, not rushed… Silent… No text, no captions, no watermark, no extra people, no extra furniture.`
- Bản đầy đủ: [scripts/V-exercise-clips.md](scripts/V-exercise-clips.md) mục 1 và 5.

## 4. Tiêu chí QA (đo được)
| Tiêu chí | Cách đo | Ngưỡng V1-1 |
|---|---|---|
| Không mất đầu | `qa_measure.py`, head_top nhỏ nhất | ≥ 5% chiều cao (V1-1: 7%) |
| Máy quay đứng yên | độ lệch vùng tường tĩnh | < 2 (V1-1: 1.13) |
| Lặp liền | khung đầu vs khung cuối | < 1.5 và gần trung vị (V1-1: 0.81 / 0.46) |
| Không giật khi ghép | max frame-to-frame của clip lặp | ≤ 3 × trung vị (V1-1: 1.16 / 0.46) |
| Động tác đúng | contact sheet + mắt người | đứng thẳng hẳn, chân không trượt, xuống có kiểm soát |
| Không đổi cảnh, nhân vật | contact sheet | cùng phòng, ghế, quần áo |
| Phụ đề không che người | khung ở các mốc cue | toàn thân luôn thấy |
| **Đối xứng hai bên** (động tác luân phiên) | `lift_symmetry.py` (theo dõi hai giày trắng) | luân phiên đúng; thời gian nhấc hai bên lệch ≤ 10%; độ cao lệch ≤ 25%; khoảng nghỉ gần bằng nhau (V2-1 bản chính diện: 1.08/1.12 giây, 77/84 px, nghỉ 0.46/0.50) |
| **Tư thế cân bằng** | mắt người trên contact sheet (xem mục 5e) | ghế vuông góc máy, người trên trục giữa ghế, lưng song song lưng ghế, đùi và bàn chân song song, không chữ V |
`qa_measure.py` bắt đúng lượt hỏng: lượt 1 V1-1 báo `HEAD CUT RISK` (head_top 0% ở giây 3–4).
Tham số `--band` (dải ngang chứa người) và `--wall` (vùng tường tĩnh) phải chỉnh theo bố cục từng góc máy.

## 5. Bài học và bẫy
- **Flow Agent tự viết lại prompt** (thêm sofa, cây, đồng hồ, bỏ ghế). Luôn tắt Agent, dùng tạo trực tiếp.
- **Sửa ảnh (edit) có thể tự phóng to khung.** Ảnh ngồi sửa từ ảnh đứng bị zoom → video mất đầu khi đứng. Không dựa vào ảnh tư thế thấp để khóa khung.
- **Vòng khép kín phải dùng tư thế cao hoặc rộng nhất làm Start = End.** Tư thế thấp tự nằm gọn trong khung. App bắt đầu phát từ giữa clip.
- Ảnh tạo trong Characters có thể trôi dáng (bản sửa gọn người hơn). Chốt ảnh chính của nhân vật trước khi tạo khung.
- Góc 45 độ trong prompt không được tôn trọng (ra gần chính diện). Nếu cần góc chéo, thử mô tả vị trí máy theo đồ vật ("camera placed at the front-right corner of the chair").
- Pha đi xuống AI thường nhanh (V1-1: 1.7 s) → làm chậm 1.3× khi dựng; không cần nội suy khung.
- AI thêm động tác an toàn không có trong kịch bản (với tay chạm ghế khi ngồi) → ghi lại cho huấn luyện viên, không tự sửa.
- Dấu ✦ vẫn có trên video gói Pro. Cần gói không watermark trước khi dùng thương mại; không tự xoá.
- **Động tác luân phiên, AI không tự đối xứng:** lượt 1 V2 nhấc chân phải 3 lần, chân trái 1 lần. Prompt phải chốt **số lần, thứ tự, mốc giây cho từng lần, "same speed and same height… mirror copies"** và nói rõ chân nào gần máy.
- Đo thời gian nhấc theo **đáy giày** (percentile 90 của pixel trắng), không theo tâm, vì tâm bị kéo bởi chân kia khi hai chân chồng nhau.
- Lần cuối trong clip hay ngắn hơn (AI dồn cho kịp khung cuối) → làm chậm riêng đoạn đó khi dựng (`build_loop.py` với `xSLOW`) cho bằng các lần khác.
- Không lật gương video 3/4 cho chân bên kia: cửa sổ và ánh sáng đổi bên, lặp sẽ giật cảnh. Làm cả hai chân trong một clip.
- ffmpeg trên máy này **không có libass và drawtext** → phụ đề vẽ bằng Pillow thành PNG rồi overlay.
- Phụ đề ở đáy che bàn chân → đặt vào khoảng tường trống cạnh người (trái hoặc phải tùy bố cục).
- **Phụ đề động kiểu CapCut auto (chốt 28/09/2026):** hiện **đủ lời thoại**, chia cụm 2–4 từ chạy nối tiếp theo giọng; **từ đang đọc tô vàng #F2B84B** (màu "sun" của app), các từ khác trắng; chữ Helvetica Bold 48 pt trên nền bo góc sage đậm #3F6B55 (tương phản với chữ trắng 6.1:1), mờ 240/255. Khung neo **cạnh trên cố định** (`y_top`) để không nhảy khi đổi 1 dòng ↔ 2 dòng.
- Canh giờ: `silencedetect` trên file giọng tìm khoảng lặng → khớp với các cụm câu tách ở dấu câu; trong mỗi cụm chia thời gian theo độ dài từ. Cụm dài chia đều (5 từ → 3+2, 4 từ tối đa 3 → 2+2), không để một từ đứng lẻ.
- Cấu hình `preview.json` → `caption`: `mode: dynamic`, `x` hoặc `align: right` + `right`, `y_center`/`y_top`, `max_width` (px, V1 430 bên trái, V2 330 bên phải để không chạm ghế), `max_words` (V1 4, V2 3). Đầu ra thêm `<name>_chunks.srt` (cụm có giờ), `<name>_voice.srt` giữ câu đầy đủ.
- Các bản bị chê: 32 pt nền xám (nhỏ, che chân) → 64 pt rút gọn (to quá, thiếu chữ) → 48 pt rút gọn tĩnh (thiếu chữ, không chạy) → **48 pt đủ chữ, chạy theo từ** (bản hiện tại).
- **Giọng đọc (28/09/2026): ElevenLabs**, key tạo bằng Chrome ("gentle-walk-local", chỉ quyền Text to Speech + Voices Read), lưu ở `~/.config/elevenlabs/api_key` (chmod 600, không nằm trong repo). `build_preview.py` gọi `/v1/text-to-speech/{voice}/with-timestamps` → mốc thời gian từng ký tự → tô chữ chính xác theo giọng; mỗi câu cache theo hash ở `assets/voice/cache/` (dựng lại không tốn credit). Âm lượng chuẩn hoá `loudnorm` −16 LUFS.
- **Gói Free không dùng được giọng thư viện cộng đồng qua API** (lỗi 402 `paid_plan_required`), chỉ dùng giọng có sẵn. Hiện dùng **Bella** (premade, trung niên, Mỹ, ấm) — `hpp4J3VqNfWAUOO0d1Us`, `eleven_multilingual_v2`, stability 0.6, similarity 0.75, style 0.15, speed 0.92. Mẫu so sánh Bella / Matilda / Sarah: `assets/voice/samples/`. Ứng viên giọng thư viện (cần gói Starter trở lên): Elise Hart `8fwYhwfiWkLjR4FKLHSQ`, Jane Hackett `aIu5oHglU5AHNc2x0AZu`, Carol `5u41aNhyCU6hXOcjPPv0`.
- Đổi giọng: sửa `voice` trong `preview.json` rồi dựng lại; kiểm tra câu thoại có chồng nhau không (giọng thật dài hơn `say`; V1 phải dời "Two." sang +1.35 s).

## 5b. Bố cục cho các clip sau (từ V3)
- **Người lệch trái khoảng 10–20% chiều ngang:** tâm người ở khoảng 35–40% chiều rộng, phần 35–40% bên phải là tường trống. Lý do: phụ đề luôn ở một chỗ cố định bên phải cho mọi bài (dễ làm mẫu, người xem quen mắt); ở chế độ toàn màn hình trong app, bộ đếm và nút Break / This hurts nằm bên phải cũng không đè người.
- Thêm vào khối CAMERA: `She is positioned slightly left of center: the center of her body is at about 38% of the frame width, and the right third of the frame is empty wall.`
- V1-1 và V2-1 đã làm lại theo bố cục này (28/09/2026): người ở khoảng 36% chiều ngang, phụ đề cả hai bài bên phải (`align: right`, `right: 1255`, `max_width: 430`, `max_words: 4`).
- Không thu nhỏ người quá 75–80% chiều cao khung khi đứng: chi tiết tay, gối, bàn chân cần đủ lớn trên điện thoại.

## 5e. Đối xứng và cân bằng tư thế (chốt 28/09/2026, áp dụng mọi clip)
**Lỗi gốc:** bản V1-1/V2-1 đầu tiên ghế xoay chéo, người ngồi lệch trục ghế, hai đùi mở chữ V lệch → nhìn vẹo, sai mẫu động tác. Chủ app bắt lỗi từ ảnh chụp màn hình. Đã tạo lại cả hai clip.
**Quy tắc mặc định (trừ khi kịch bản ghi rõ góc khác):**
1. **Chính diện, máy ngang tầm:** ghế quay thẳng vào máy, lưng ghế song song mặt phẳng ảnh và nằm ngay sau người. Chỉ một ghế trong ảnh.
2. **Người trên trục giữa ghế:** ngồi giữa mặt ghế, lưng thẳng và song song lưng ghế, vai ngang.
3. **Chân cân bằng:** đùi song song, rộng bằng hông; gối hướng thẳng trước, ngay trên cổ chân; ống chân thẳng đứng; bàn chân phẳng, song song, mũi chân hướng trước — **không chữ V**. Nếu bài cần chân mở, hai bên mở đều quanh trục ghế.
4. **Tay đối xứng:** hai tay đặt cùng kiểu (cùng trên đùi hoặc cùng giữ mép ghế).
5. **Động tác luân phiên quay chính diện:** hai chân cách máy bằng nhau → độ cao và tốc độ so được bằng mắt và bằng `lift_symmetry.py`. Góc 3/4 làm chân gần máy trông to, cao hơn.
6. **Nhịp cân bằng:** lên ≈ xuống theo kịch bản; hai bên nhấc bằng nhau (≤ 10%), khoảng nghỉ bằng nhau. Nếu AI làm lệch thứ tự/số lần, **chỉ lấy một cặp trái–phải tốt nhất** làm vòng lặp (V2-1: 3.17 giây/cặp, lặp 6 lần trong preview) thay vì cố dùng cả 8 giây.
7. **Lời thoại không gọi tên bên** khi không chắc bên nào đi trước ("One side, then the other"): AI không tuân thứ tự trái/phải trong prompt (V2 prompt yêu cầu phải trước, ra trái trước).

**Câu cho khối ảnh khung (đã chạy tốt):** `sits squarely on ONE wooden ladder-back dining chair …; exactly one chair in the image. Strict frontal, mirror-symmetric pose: the level camera looks straight at the chair, the chair faces the camera squarely with its back parallel to the image plane and directly behind her. She sits tall in the middle of the seat on the chair's center line, back upright and parallel to the chair back, shoulders level and relaxed, both hands … in the same way, thighs parallel and hip-width apart, knees pointing straight forward directly above the ankles, shins vertical, feet flat, parallel and hip-width apart (no V shape, toes forward).`
**Câu cho prompt video:** `Strict frontal, mirror-symmetric movement: the chair keeps facing the camera squarely and never moves or turns. … Her body never twists or turns; shoulders level.`
**Bẫy khi tạo ảnh khung:** ảnh ra hai ghế hoặc ghế tách khỏi người (ghế đặt cạnh, người ngồi ghế khác) → ghi "exactly one chair" và loại ảnh đó. Kiểm tra ảnh khung bằng mắt trước khi tốn credit video.
**Kiểm bằng mắt (contact sheet):** kẻ trục dọc giữa ghế — đầu, cằm, rốn, giữa hai gối, giữa hai bàn chân nằm trên trục; hai mép ghế cách trục bằng nhau.

## 5f. Một khung máy cho mọi clip (chốt 28/09/2026)
- **Lỗi gốc:** V2 bản đầu có người to hơn V1 khoảng 1.25× vì ảnh khung tạo riêng. Trong một buổi tập, chuyển bài sẽ như máy zoom đột ngột. Chủ app bắt lỗi.
- **Chuẩn:** khung theo tư thế đứng của V1 (người đứng cao khoảng 90% khung, đỉnh đầu cách mép trên khoảng 7%, người ở khoảng 34–38% chiều ngang). Bài ngồi giữ nguyên khung này, không zoom gần.
- **Cách làm được (0 credit):** lấy khung thật từ video 1080p đã đạt (`ffmpeg -ss 3.5 … -frames:v 1`), tải lên Flow (bảng chọn khung → Upload media), rồi sửa bằng Nano Banana:
  - Sửa nhỏ (chỉ tay, chỉ chân) giữ nguyên khung.
  - "Rotate only the woman and her chair 90 degrees in place … clean, exact side profile" cho ra góc nghiêng cùng phòng, cùng cỡ người.
  - Đổi bối cảnh (V5 bỏ ghế, thêm mảng tường bên phải) vẫn giữ cỡ người.
  - Sửa lớn (đứng → ngồi) từ ảnh khác thì Nano Banana tự đặt người vào giữa khung; lệnh "shift left" không có tác dụng → dùng khung thật thay vì sửa lớn.
- Mỗi ảnh khung là **một tài sản riêng** (tải lên nhiều bản sao): bảng chọn khung chỉ lấy phiên bản mới nhất.
- Tải file lên Flow bằng Claude in Chrome: nút Upload media mở hộp chọn file của hệ điều hành → chặn `HTMLInputElement.prototype.click` cho input file, gắn input vào trang rồi dùng `file_upload`; trả lại hàm gốc sau khi xong.
- **Góc nghiêng thuần** cho động tác cần thấy đường chân/tay (duỗi chân, nhấc gót, chống tường, đứng một chân). Làm cả hai bên trong một clip (chân gần rồi chân xa), không lật gương.
- Đo nhịp: `tools/video/leg_displacement.py` (độ lệch từng nửa khung so với khung nghỉ, trừ trôi chậm) khi giày nhỏ hoặc sát chân tường trắng; hoặc đường cong độ lệch một vùng cho động tác một vùng (V3–V6).
- Phụ đề: bố cục 2 dòng tự cân (không để một từ đứng lẻ dòng 2), sửa trong `build_preview.py` `layout()`.

## 5c. Watermark ✦ (quyết định 28/09/2026)
- **Không crop, che, làm mờ hay xoá dấu ✦.** Điều khoản chung của Google: "Don't remove, obscure, or alter any of our branding, logos, or legal notices" ([Google Terms](https://policies.google.com/terms?hl=en-US)). Crop để giấu dấu là che logo → rủi ro tài khoản và phải làm lại clip nếu bị phát hiện muộn. SynthID (dấu ẩn) vẫn còn trong video dù xoá dấu hiển thị.
- Đã kiểm tra tài khoản Pro (menu hồ sơ, menu ba chấm, bánh răng project): **không có tuỳ chọn "Visible watermarking"** mà một hướng dẫn bên thứ ba nhắc tới. Bánh răng có "Return silent videos" (nên bật cho clip sau).
- **Cập nhật 29/09/2026 (trang trợ giúp Flow chính thức, support.google.com/flow/answer/16353333):** dấu hiển thị bật/tắt bằng công tắc "Visible watermarking" dưới ảnh hồ sơ, **nhưng "A visible watermark will be applied automatically if you reside in India, South Korea, or Vietnam."** → đây là lý do tài khoản Pro không có công tắc. Ultra ở Việt Nam có công tắc hay không: chỉ có nguồn bên thứ ba, **chưa xác minh**. SynthID luôn còn.
- Chủ app (29/09) yêu cầu dựng người lùi vào trong khung để **chủ app tự crop**; agent chỉ làm bố cục, không thực hiện bước crop/che dấu.
- Cách hợp lệ: gói Google AI Ultra (video Flow không có dấu hiển thị, theo nguồn bên thứ ba, cần xác minh trên trang gói của Google) hoặc công cụ tạo video khác cho phép dùng thương mại không watermark. Chủ app quyết định trước khi sản xuất hàng loạt.
- **Cập nhật 30/09/2026 (chủ app chốt):** chủ app viết tool `tools/video/crop_avoid_logo.py` (dò dấu bằng pixel sáng hơn + ít bão hoà hơn nền, gom blob ở góc; crop 16:9 lớn nhất không chạm dấu, khe 12 px) và **giao agent chạy tool này** sau mỗi lần tạo; agent không tự nghĩ cách crop/che khác. Test 30/09 trên `W1-1/v2/W1-1v2_omni_try2_1080p.mp4` và `V3-1/1080/V3-1_flow-source_1080p.mp4`: dấu dò đúng (hộp 1710,870–1773,931 và 1701,862–1810,979), crop 1696×954 @ (0,63) và 1688×950 @ (0,65), giữ 77–78% khung; QC: góc phải dưới sạch trên 8 khung, đầu 12% / 32%, máy lệch 0,56 / 0,60, seam 0,95 / 0,70, giật không đổi. Đầu ra không phải 1920×1080; Lanczos lên 1080 làm nét vùng người giảm 1591 → 1022 (Laplacian) → chủ app chọn giữ 1696×954 hay scale (plan §7 #8b). Ghi chú pháp lý ở trên vẫn đúng (Google ToS về logo); quyết định là của chủ app.
- **Vị trí ✦ cố định (đo 30/09/2026, `--detect-only` trên 8 clip Omni 1080p):** hộp dò bắt đầu ở x 1701–1710, y 862–870 (V1 1702,863 · V2 1703,862 · V3 1701,862 · V4 1703,863 · V5 1703,863 · V6 1702,862 · W1-1 1710,870 · W1-1 v2 1710,870); chiều rộng hộp 63–131 px tuỳ viền mờ. 720p: 1136–1140 / 576–578 (cùng tỉ lệ). Veo 3.1 có chữ "Veo" ở 1305–1896 × 912–1079 (không dùng). → Công thức cố định: crop **1688×950 tại x=0**, y = clamp(đỉnh đầu − 24, 0, 130) (tool tự trượt theo `subject_top`).
- **Suy ngược cho khung hình (CROP-SAFE, PROMPTS §1):** người + ghế + tầm với xa nhất trong 0–1656 px ngang (≤ 86%) và cao ≤ 890 px (≤ 82%); prompt: đầu ~12% dưới mép trên, đế giày ~12% trên mép dưới, người cao ~76%. Guard `tools/video/crop_subject_check.py` (ảnh khung hoặc clip, `--crop` lấy từ dòng tool in ra; mask = legging tối + áo sage + da + tóc, gộp blob lớn; mép trùng mép khung không cần khe; khe 24 px ở mép bị cắt). Kết quả 7 clip cũ: V1 FAIL (đầu −42 px khi đứng: `subject_top` lấy trung vị nên khung ngồi thắng), V6 FAIL (giày −82 px: người 958 px > 950), V2–V4 PASS (đáy trùng mép khung), V5 khe chân 23 px (thiếu 1 px so với ngưỡng 24, không cắt vào người — chấp nhận), W1-1 v2 PASS. Bẫy của tool cần biết: `subject_top` là trung vị các khung → bài có pha đứng/ngồi phải kiểm bằng guard, không tin y tự chọn.
- **Bẫy thứ hai (đo 30/09, M2):** `subject_top` dùng ngưỡng "khác nền > 30" nên **bỏ sót 40–45 px tóc bạc sáng** trên tường trắng (ảnh gốc: tóc thật ở hàng 106, tool đo 148 → với headroom 24 cắt y=124, lẹm 18 px vào tóc; W1-1 v2: đường cắt chạm đúng đỉnh tóc). Cách xử lý không sửa tool: chạy với **`--headroom 70`** (3 ảnh khung mới, W1-1 v2, V2–V4 PASS); clip nào guard báo lệch thì dùng `--headroom` guard gợi ý (V5: 56 → khe 30/30 px). Đề xuất cho chủ app (chưa làm): hạ ngưỡng tóc trong `subject_top` hoặc đặt y theo tâm người thay vì đỉnh đầu.
- **Guard `crop_subject_check.py` (bản 30/09 chiều):** lõi = cột có áo sage hoặc legging than (tối **và** ít bão hoà, để gỗ ghế nâu không lọt); so từng hàng trong dải với nền nội suy giữa dải tường/sàn trống hai bên (bù vệt sáng cửa sổ); đỉnh đi lên từ thân với ngưỡng mềm (bắt tóc bạc); đáy = lớn nhất của (đoạn liền ≥ 14 px khác nền) và (dò bàn chân ngay dưới thân: legging tối hoặc giày trắng **không màu** — giày trong bóng chỉ sáng ~200, bằng sàn, nhưng sàn sồi có màu). Đo khớp mắt trên 7 ảnh khung M2. Bắt được lỗi các bản trước bỏ sót: **V5 giày ở hàng ~1057** (người 960 px > cửa sổ 950). Hạn chế: hộp chỉ đo người, ghế tách xa (MF-04b, MF-06) không nằm trong hộp — ghế vẫn phải kiểm bằng mắt trên bảng `M2-frames-sheet.jpg`. Không truyền `--crop` thì tự lấy y như tool (đỉnh − 24); truyền `--tool-headroom` thì khi FAIL gợi ý `--headroom` đặt người giữa cửa sổ. Hạn chế: cảnh tường V5 (mảng tường bên phải) làm dải nền bên phải kém tin cậy — kiểm thêm bằng mắt.

## 5d. Chất lượng đầu ra (so sánh 28/09/2026)
- Flow tạo video tối đa **720p** (Omni 1.1 Flash chỉ có 360p/720p). Khi tải có **1080p Upscaled** (AI phóng to, Pro, không thấy báo tốn credit, mất khoảng 1 phút; không chạy nhiều lượt phóng to cùng lúc); 4K cần gói cao hơn.
- Bản 1080p **khớp từng khung** với bản 720p (192/192 khung, lệch 0.7 khi thu nhỏ) → dùng lại nguyên mốc cắt của clip lặp.
- Độ nét (Laplacian variance vùng người): V1 720p 113 → Flow 1080p 207; V2 63 → 125; phóng thường 720p→1080p chỉ 26 và 15. Tóc, kính, vân len rõ hơn; AI thêm vân sọc dọc trên legging (nhỏ, trông tự nhiên). (Ảnh so sánh bản cũ đã xoá cùng clip cũ.)
- Mã hoá 1080p: clip lặp `build_loop.py … 16` (CRF 16, high profile), xem thử CRF 17 preset slow, AAC 192 kbps (`crf`, `preset`, `audio_bitrate` trong `preview_1080p.json`). `build_preview.py` tự co giãn phụ đề theo độ phân giải (bố cục viết cho 1280×720, ×1.5 ở 1080p).
- Dung lượng: clip lặp 1.1–1.2 MB (720p) → 2.9 MB (1080p); 17 clip ≈ 20 MB (720p) hoặc ≈ 50 MB (1080p) trong app.
- Giọng ElevenLabs gói Free tối đa MP3 128 kbps; 192 kbps / PCM cần gói trả phí.

## 5g. Veo 3.1 Quality (thử W1-1 bản 2, 30/09/2026)
- Flow có 4 model video: Omni 1.1 Flash, Veo 3.1 Lite, Veo 3.1 Fast, **Veo 3.1 Quality**. Quality **100 credit / video 8 s** (Omni Flash 12), không có tuỳ chọn độ phân giải (720p) và không đổi được thời lượng; tải về có 720p gốc, 1080p Upscaled, còn 4K phải nâng gói.
- Dấu hiển thị của Veo 3.1 là chữ **"Veo"** nhỏ ở góc dưới phải (khoảng 60×30 px ở 1080p), nhỏ hơn dấu ✦ của Omni.
- Độ nét: vùng mặt ở bản 1080p đo được 5190, bản 1 (Omni) là 2223, **nhưng một phần con số đến từ viền sáng (halo) quanh tóc và vai, cộng vân sàn "giun" do làm nét quá tay**. Viền sáng đã có sẵn trong ảnh khung, vì ảnh khung lấy từ một khung video đã upscale rồi phóng thêm 1.14×; Veo giữ lại viền đó và bước upscale làm nó đậm thêm. → **Ảnh khung phải sạch**: tạo mới bằng Nano Banana, không lấy từ khung video đã upscale.
- Động tác lượt 1: tay dang ngang ra hai bên (như cánh máy bay), chân đá duỗi về trước thay vì nâng gối, chỉ khoảng 4 bước. Prompt phải tả tay sát thân, khuỷu gập, và "thigh lifts, foot rises straight up under the knee, no kick".
- Lượt 2 (ảnh khung chụp mới bằng Nano Banana Pro, prompt cấm tay dang ngang): chân đã đúng (bàn chân đi thẳng lên dưới gối), nhưng **tay vẫn dang ngang** và chỉ đi khoảng 3–4 bước mỗi bên, đứng yên hơn 2 giây cuối. Viền sáng vẫn đậm ở bản 1080p → **viền do chính bước "1080p Upscaled" của Flow**, không chỉ do ảnh khung. Độ nét mặt 2960, bản 1 là 2223.
- Ảnh khung dùng trong Flow mang theo dấu ✦ vào video (lượt 2 có cả ✦ lẫn chữ "Veo"). Ảnh tải lên từ máy (lượt 1) thì không có.
- Nano Banana Pro khi có ảnh tham chiếu thường chép gần nguyên pixel, kể cả lỗi viền. Muốn ảnh sạch phải tạo lại hẳn.
- **Kết luận 30/09/2026:** với W1-1, Veo 3.1 Quality **không đáng** 100 credit: nét hơn không nhiều sau upscale, và bám động tác kém hơn Omni. Giữ **Omni 1.1 Flash** (12 credit) cho clip động tác; Veo Quality chỉ đáng thử cho cảnh cần chi tiết mà ít động tác.
- File: `assets/video/W1-1/v2/` (bản 720p và 1080p của lượt 1 và lượt 2, ảnh khung, `qa/`).
- **W1-1 bản 2 làm bằng Omni (30/09/2026, 2 lượt, 24 credit):** ảnh khung tải lên từ máy (`W1-1v2_start-frame.png`, người cao khoảng 75% khung, không có ✦), Start = End.
  - Lượt 1: tay đúng, nhưng bước chân nhỏ dần và nhanh dần.
  - Lượt 2 đạt, nhờ thêm vào prompt: "one step about every 0.8 seconds… foot rises about 15 centimeters… every step exactly the same height and speed; the steps never get smaller, lower or faster". Từ giây 3,25 đến 7,25 chân bước xen kẽ đều (nhấc 0,33–0,42 giây, nghỉ 0,21 giây, cao 6–9% chiều cao người).
  - Clip lặp lấy đoạn 4,375–6,708 giây (2,33 giây, hai cặp bước). Đo: máy lệch 0,69, chỗ nối 1,34, đầu ≥ 16%. Vùng crop an toàn: 1696×954 ở (0,63).
- Phóng lên 1080p: "1080p Upscaled" của Flow nét hơn nhiều (độ nét mặt 3515) nhưng có viền sáng; tự phóng 720p bằng Lanczos thì mềm (600) và không có viền. Ảnh so sánh: `qa/omni2_flowup-vs-lanczos.png`.

## 5h. Bài học M3 (30/09/2026, 6 clip mẫu, 180 credit)
- **Một nhịp tự nhiên + remap** chạy thật: W2-1 ra đều ~78 spm (không theo con số 0,6 s trong prompt) → `retime.py` ×1,12 / ×1,28 cho bản easy / quicker; không bóng đôi ở giày.
- **Động tác hai bên: tách mỗi clip một bên** (Start = End cùng ảnh khung) rồi ghép có crossfade 0,3 s ở tư thế nghỉ. Khi để AI làm hai bên trong một clip, V8 hai lượt liền một bên đá cao ~45°, bên kia đúng. Tách ra thì chỉ làm lại bên hỏng.
- **QC động tác nâng chân bắt buộc bảng cận bàn chân 4 khung/giây** (crop vùng chân, `fps=4,tile=8x4`), chấm từng khung: chân phải rời sàn liên tục suốt pha giữ. Bảng 1–2 khung/giây đã bỏ sót V8 lượt 3 (chân chạm sàn 3,0–3,5 s). Đo số theo đáy giày không dùng được: bàn chân đưa ra cũng nhích về phía máy nên mức sàn đổi theo phối cảnh (đã thử, đã bỏ công cụ).
- **Độ cao chân phải có mốc cơ thể + giới hạn hai đầu**: "vài cm" → AI lê chân; "20 cm" không mốc → đá cao. Đạt khi viết "đế giày ngang giữa ống chân kia (~20 cm), ở yên trên không suốt pha giữ, không chạm sàn, không cao quá gối".
- **Giữ tư thế (hold) không cần clip riêng**: cắt đoạn giữ trong clip vào tư thế, phát xuôi rồi ngược (ping-pong) → hold 8 s sống động, nối 0,19.
- **Clip lặp rep**: AI hay dồn lần cuối nhanh hơn (V5 lần 2 ngắn 27%) → chỉ lấy lần lặp đầu tiên đủ dài; crossfade 0,35 s ở tư thế duỗi để mối nối gần như vô hình.
- **Đi ngang (B2) thất bại 3 cách**: (1) Start = End: không quay về chỗ cũ; (2) ép "về đúng chỗ": gần như không di chuyển; (3) 2 khung nối A→B: di chuyển đúng nhưng **bắt chéo chân** (grapevine). Chuyển động di chuyển trong không gian là điểm yếu của Omni ở 8–10 s.
- **Bẫy Flow**: bảng chọn khung chỉ lấy **phiên bản mới nhất** của asset — sửa ảnh trên asset MF-06 làm MF-06 thành khung B. Luôn tải ảnh khung từ máy lên dưới **tên riêng** trước khi dùng làm Start/End.
- **Bẫy Flow 2**: khi cửa sổ Chrome bị ẩn/thu nhỏ, `document.visibilityState = hidden` và mọi chụp màn hình treo → nhờ chủ app mở cửa sổ.
- Tải **720p trước** để chấm (nhanh), chỉ tải 1080p Upscaled cho clip đạt. Menu tải: chọn theo nhãn ("720p Original size") thay vì toạ độ.
- Guard ở 720p: khe an toàn quy đổi `--margin-px 16` (24 @1080); headroom tool `--headroom 47` (70 @1080).
- zsh: `$VAR[label]` bị hiểu là chỉ số mảng trong chuỗi filter ffmpeg ; `$A:end` bị hiểu là modifier `:e` → dùng `${VAR}` hoặc Python.
- **Vị trí ngang (lỗi V5 lượt 1, chủ app bắt):** guard cũ chỉ kiểm người có bị crop cắt không, nên người đứng ở 57% chiều rộng vẫn PASS. Từ 30/09 guard đo thêm tâm người trên khung sau crop, dải **28–48% (đích ~38%)**. Đo lại cả bộ khung M2: MF-04b 53%, MF-05 55%, MF-05b 56% không đạt; MF-03 46% sát ngưỡng.
- **Nano Banana không dời người theo lệnh** (thử "truck move… one third of the width": gần như không đổi) → `tools/video/recenter_frame.py` dời cả ảnh sang trái tại máy (0 credit), xoá ✦ của ảnh trước bằng miếng vá lấy trong chính ảnh (nếu không, ✦ trượt vào cửa sổ crop và video Omni sẽ vẽ lại nó), lấp dải phải bằng ảnh gương (dải này gần như nằm ngoài cửa sổ crop). MF-05c_P-WALL-HANDS (dời 204 px), MF-04c (174), MF-03c (82), MF-05c_P-WALL (188) đều đạt tâm 39%; cả bộ khung M2 giờ trong dải.
- Guard báo "bottom" âm trên khung đứng sát sàn gỗ có thể là báo nhầm (vân sàn dưới giày bị tính là chân): mở ảnh ra đo đế giày trước khi kết luận.
- Flow ở tab ẩn: menu cài đặt vẫn mở được bằng click toạ độ vào chip `Video · 720p · 8s` (click theo ref không mở); chọn 10s rồi zoom kiểm dòng "15 credits" trước khi bấm tạo.

## 6. Chi phí
- ElevenLabs: V1 + V2 = 16 câu, khoảng 800 ký tự (tính theo ký tự của gói). Mẫu thử 3 giọng: khoảng 260 ký tự.
 (Flow, gói Pro, 28/09/2026)
| Việc | Credit |
|---|---|
| Ảnh Nano Banana 2 (mỗi ảnh, kể cả sửa) | 0 |
| Video Omni 1.1 Flash 720p 8 s x1 | 12 |
| Video Omni 1.1 Flash 720p 8 s x2 | 24 |
| V1-1 thực tế | 2 lượt video = 24 |
| V2-1 thực tế | 2 lượt video = 24 |
| Làm lại V1-1 + V2-1 chính diện đối xứng | 2 lượt video = 24 |
| V2 cùng khung V1 + V3–V6 | 5 lượt video = 60 (đều đạt lượt đầu) |
Gói Pro có thêm 50 credit Flow mỗi ngày (banner Flow). Ước tính 17 job × 1–2 lượt = khoảng 200–400 credit.

## 7. Điều khiển Flow bằng Claude in Chrome (ghi chú UI 28/09/2026)
- URL `labs.google/fx/tools/flow` → chuyển về `flow.google.com`. Tài khoản đã đăng nhập, gói PRO.
- Project mới: nút "New project". Thanh nhập ở đáy; chip "Agent" bật/tắt Agent; chip cài đặt (ví dụ `Video · 720p · 8s`) mở bảng Image/Video, Frames/Ingredients, tỉ lệ, model, độ phân giải, thời lượng, số bản, **dòng "Generating will use N credits"**.
- Chế độ Frames hiện hai ô Start/End → bảng "Select a frame image" → chọn ảnh → "Add to prompt".
- Gõ `@` trong ô nhập mở bảng tài sản → chọn nhân vật → "Add to prompt" (thành chip).
- Agent settings (biểu tượng sliders khi mở Agent): "Confirm before generating: Always" để Agent hỏi trước khi tiêu credit.
- Toạ độ thay đổi khi cửa sổ đổi cỡ → dùng `find` lấy ref thay vì toạ độ cố định.
- Ảnh có nhiều phiên bản: bảng chọn khung chỉ lấy phiên bản mới nhất → "Save to projects" để lấy phiên bản cũ.
- Trong bảng chọn khung, phím mũi tên xuống xem trước từng ảnh → chắc chắn chọn đúng ảnh trước khi "Add to prompt".
- Tải **1080p Upscaled phải ở lại trang** đến khi tải xong; rời trang (mở clip khác) là huỷ tải.
- Dọn dẹp: đưa ảnh/video hỏng vào Trash của Flow, không xoá vĩnh viễn.

## 8. Đề xuất cấu trúc skill (tên tạm `exercise-clip-flow`)
- **Đầu vào:** mã job trong `V-exercise-clips.md` + tên nhân vật Flow.
- **Checkpoint 1 (hỏi chủ app):** báo credit dự kiến và giới hạn số lượt thử.
- **Vòng lặp:** tạo khung → tạo video → tải → `qa_measure.py` + contact sheet → sửa một chỗ trong prompt → tối đa N lượt.
- **Dựng:** `build_loop.py` (mốc lấy từ số đo), `build_preview.py` (cue từ lời giọng A4 và quy tắc "phát khi nào").
- **Checkpoint 2:** gửi preview + bảng QA; chủ app hoặc huấn luyện viên duyệt.
- **Ghi lại:** cập nhật mục kết quả trong `V-exercise-clips.md`, `content-plan.md`.
- **Đóng gói trong skill:** `tools/video/qa_measure.py`, `lift_symmetry.py`, `contact_sheet.sh`, `build_loop.py`, `build_preview.py`, mẫu `preview.json`, khối prompt mục 3, bảng QA mục 4, bẫy mục 5.

## 9. Việc còn mở
- Gói Flow không watermark và điều khoản thương mại.
- Giọng HLV thật (thu người thật, TTS cao cấp hay clone có đồng ý).
- Góc 45 độ chưa đạt (hiện mặc định chính diện, mục 5e).
- Huấn luyện viên duyệt V1-1 (đặc biệt động tác chạm ghế khi ngồi).
- Tự động phát hiện mốc pha (đứng/ngồi) từ head_top để khỏi nhập tay đoạn cắt.

## 5i. Kiểm định theo kịch bản động tác + vòng lặp cắt thẳng (01/10/2026)
- **Lỗi gốc:** `loop.sh`/`join.sh` hoà 0,3–0,35 s giữa hai tư thế khác nhau → mặt in đôi ở chỗ nối (W1-6, W2-3, V5…, chủ app bắt). `clip_health.py` đo cả vùng người nên không thấy.
- **Pose:** `tools/video/pose_track.py` (MediaPipe 0.10.21 solutions.pose, CPU; venv `tools/video/.venv`) → `<clip>.pose.npz` 33 điểm/khung.
- **Kịch bản:** `tools/video/motion_logic.py --pattern alternate|sides|sides:head_turn|head_tilt|twist|side_bend|profile|symmetric|hold` (cột `pattern` trong `video-catalog.json`). Bắt: lặp cùng chân, vòng lặp nối cùng bên, số lần L/R lệch, nhịp không đều (CV>0,3), biên độ không đều, chỉ một bên làm, nhảy tư thế ở chỗ nối (×bước khung và >1,5% thân), **in đôi mặt** (ô mặt bám mũi, độ nét so khung lân cận <0,72 ≥3 khung, đáy <0,62; chỉ tính ở chỗ nối/ghép hoặc đáy <0,30). Clip quay nghiêng: không xét trái/phải (chân xa bị che).
- **Sửa:** `tools/video/loop_best.py` chọn đoạn đủ chu kỳ đúng kịch bản và cắt thẳng ở 2 khung khớp tư thế + vận tốc (không crossfade, gắn metadata `gw-loop:hardcut`). Bản easy/quick: nối 3 vòng, `minterpolate`, lấy vòng giữa (hai đầu nội suy liền).
- Kết quả 01/10: 25 file thay, lỗi in đôi chỗ nối còn 0; còn W1-2, W1-5, W2-4 (nguồn sai nhịp) và V6 (một bên nhấc rất thấp) phải tạo lại.
