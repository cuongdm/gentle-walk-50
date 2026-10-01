# Flow/Veo/Omni + ElevenLabs: ghi chú sản xuất (tra cứu 30/09/2026)
_Bổ sung cho `docs/video-skill-notes.md` (quy trình, QA, bẫy đã biết) và `docs/research/audio-api-options.md` (so sánh nền tảng, giá). Chỉ ghi điều **mới hoặc còn thiếu**. Trích dẫn ≤ 15 từ, kèm URL; mục đánh dấu **[chưa xác minh]** là nguồn bên thứ ba hoặc chưa thấy trong tài liệu chính thức._

## 1. Tóm tắt & khuyến nghị
1. **Giữ Omni 1.1 Flash** cho clip động tác (đã chốt 30/09); dùng thời lượng **10 s** (Omni có 4/6/8/10 s) khi cần 2–3 lần lặp chậm, và **360p draft** (một phần ba credit) để thử prompt trước khi render 720p.
2. **Prompt theo mốc giây** `[00:00-00:02] …` (Google khuyến nghị cho Veo 3.1) + nhịp "one repetition every 4 seconds" + "the movement fills the whole clip" + Start = End cùng một ảnh. Đây là cách chống dồn nhanh cuối clip đã chạy được ở W1-1.
3. **Extend trong Flow chỉ có cho Veo** (Lite: 8 s; Fast/Quality: không). Omni: trang trợ giúp ghi "Coming soon", báo chí nói 10 s/lần tới 40 s → **kiểm tra trong UI trước khi lên kế hoạch clip dài**. Với Omni hiện tại: ghép 2 clip Start = End bằng `build_loop.py`.
4. **Hold 10–20 s:** không có hướng dẫn chính thức. Cách an toàn: tạo một clip "standing still" 8–10 s với động tác vi mô (thở, chớp mắt), Start = End, rồi **lặp có crossfade**; không freeze-frame (chết hình, lộ AI).
5. **Nhất quán nhân vật 30+ clip:** Characters (1–2 ảnh, mô tả, tên) là cơ chế chính thức "strictly consistent across multiple generations"; nhưng **ảnh khung Start (từ một ảnh gốc duy nhất) mới khoá được cỡ người và phòng**. Dùng cả hai: `@GWCoach` + Start frame lấy từ cùng ảnh gốc.
6. **Watermark:** Flow ghi rõ Việt Nam bị gắn dấu tự động; Google blog nói Ultra trong Flow không có dấu — **Ultra ở Việt Nam có bỏ được không: chưa xác minh**. Google ToS: không xoá/che logo. Quyền sở hữu: "Google won't claim ownership over that content."
7. **ElevenLabs TTS:** giữ `eleven_multilingual_v2` cho lời dẫn: ổn định nhất long-form, có `<break time="1.0s" />`, request stitching, timestamps đã chạy. **v3/v4 không có SSML break, không có request stitching (v3)**, tag có thể bị đọc thành lời → chỉ dùng v3/v4 khi cần cảm xúc.
8. **Cài đặt giọng coach chậm, ấm:** `stability 0.6–0.7`, `similarity 0.75`, `style 0–0.15`, `speed 0.90–0.95` (biên 0.7–1.2), `use_speaker_boost true`, `seed` cố định; ngắt bằng `<break time="0.8s" />` (≤ 3 s, ít tag/lượt) hoặc "…" .
9. **Giấy phép:** gói trả phí (Starter trở lên) có quyền thương mại cho nội dung tạo ra; giọng Voice Library "come with a free commercial use license"; Eleven Music self-serve cho phép mọi dùng thương mại **trừ film, TV, radio, Studio Games** (app không phải game). Free: phi thương mại + ghi công.
10. **Chuông:** tạo bằng ElevenLabs SFX (`duration_seconds 1.5–2`, ~80 credit/lượt trên web, giấy phép cùng gói) **hoặc** tự tổng hợp bằng ffmpeg sine (0 chi phí, không giấy phép). Khuyên: ffmpeg cho chuông 2 nốt; SFX nếu muốn chất liệu "singing bowl" thật.

## 2. Flow / Veo / Omni

### 2.1 Cấu trúc prompt chuẩn (Google)
- Vertex AI Veo prompt guide chia prompt thành **Subject · Action · Style · Camera positioning & motion · Composition · Focus/lens · Ambiance**; Action có cả "standing still" và "Subtle actions: a gentle breeze ruffling hair… a subtle nod". Nguồn: [Vertex AI video-gen prompt guide](https://docs.cloud.google.com/vertex-ai/generative-ai/docs/video/video-gen-prompt-guide).
- Google Cloud blog cho Veo 3.1: công thức "[Cinematography] + [Subject] + [Action] + [Context] + [Style & Ambiance]" và **prompt theo mốc giây** `[00:00-00:02] …` (xem 2.2). Nguồn: [Ultimate prompting guide for Veo 3.1](https://cloud.google.com/blog/products/ai-machine-learning/ultimate-prompting-guide-for-veo-3-1).
- Omni (DeepMind): ít cần tả chi tiết, nhưng có từ khoá máy quay chính thức: "one continuous shot", "static", "locked off". Nguồn: [Gemini Omni prompt guide](https://deepmind.google/models/gemini-omni/prompt-guide). Bên thứ ba trích lời Google: "change one variable per turn, and explicitly state what should stay the same" **[chưa xác minh trên trang DeepMind]** ([Atlas Cloud](https://www.atlascloud.ai/blog/guides/gemini-omni-prompt-guide)).
- Negative prompt (ô riêng trên Vertex): "avoid prompts such as 'no walls'"; ghi danh sách thứ không muốn: "wall, frame". Flow không có ô negative riêng → trong prompt chính vẫn viết câu mô tả khẳng định ("The chair is the only object in the room") thay vì chỉ liệt kê "no…".

**Mẫu điền (một khối cho mọi clip động tác, Omni 1.1 Flash, Frames, Start = End):**
```
CAMERA: Static tripod shot, locked off, one continuous shot, eye-level, 16:9. No pan, tilt, zoom, reframing or cuts. The framing stays exactly as in the first frame for the whole clip; her head and feet always fully visible.
SUBJECT: @GWCoach (same face, glasses, sage top, same body size as the first frame) <vị trí: standing / sitting squarely on the chair…>.
SET: <phòng tối giản như ảnh khung>; the chair is the only object; nothing else appears.
ACTION (timed):
[00:00-00:01] She stands still in the starting pose, breathing calmly.
[00:01-00:05] Repetition 1: <pha xuống> slowly over 2 seconds, <pha lên> slowly over 2 seconds.
[00:05-00:09] Repetition 2: identical to repetition 1, same speed, same height, same path.
[00:09-00:10] She returns to exactly the starting pose and holds it, breathing calmly, until the last frame.
TEMPO: One repetition every 4 seconds; every repetition has the same speed and the same range; the movement fills the whole clip; the movement never speeds up, shrinks or stops early; no rushing toward the end.
BODY RULES: <tay sát thân / chân không trượt / "thigh lifts, foot rises straight up under the knee, no kick"…>. Natural, realistic movement of a healthy woman around 60, not athletic, not rushed.
STYLE: Photorealistic, soft daylight, silent. No text, captions, logos, extra people or furniture.
```
Ghi chú: thay `<…>`; số lần lặp = (thời lượng − 2 s đệm) ÷ chu kỳ. Với 8 s: 1 s đệm + 1 lần 4 s + 1 lần 3 s là quá chật → chọn **10 s** cho 2 lần đủ 4 s, hoặc chu kỳ 3 s cho 8 s.

### 2.2 Ngôn ngữ nhịp / chống dồn nhanh cuối clip
- Chính thức: Google chỉ có **timestamp prompting** ("By assigning actions to timed segments…") và từ vựng nhịp ("slow pan", "standing still"). Không có tham số tốc độ.
- Thực nghiệm của dự án (30/09): "one step about every 0.8 seconds… every step exactly the same height and speed; the steps never get smaller, lower or faster" đã sửa được lỗi bước nhỏ dần, nhanh dần ở W1-1. Giữ cách này, thêm mốc giây.
- Lý do dồn nhanh: model phải "giải quyết" khoảng cách tới End frame. fal (bên thứ ba) về Omni: "almost is worse than obviously different" — End frame gần giống nhưng lệch khiến model phải bù trong vài giây cuối. → **End = đúng file ảnh Start**, không dùng ảnh "gần giống". Nguồn: [fal Omni 1.1 guide](https://fal.ai/learn/tools/how-to-use-gemini-omni-flash-1-1) **[chưa xác minh chính thức]**.
- Vẫn dự phòng bằng dựng: `build_loop.py … xSLOW` cho lần cuối (đã có), và chỉ lấy các chu kỳ giữa clip.

### 2.3 Extend: chain 8 s → 16–24 s?
| | Veo 3.1 (Flow) | Omni 1.1 Flash (Flow) |
|---|---|---|
| Extend trong Flow | "You can currently only extend Veo generated videos." Lite: có (8 s); Fast, Quality: không | Trang model: "Extend videos: Coming soon" |
| Cơ chế (Gemini API) | Mỗi lần +7 s, tối đa 20 lần, "up to 148 seconds"; chỉ 720p; model "finalize the final second or 24 frames" rồi tiếp; **không dùng cùng reference images** | Báo chí 28/08/2026: "Extensions can be generated in 10-second increments, up to 40 seconds cumulatively" **[chưa xác minh trong Flow UI]** |
| Hạn chế | "can't apply other edit modes such as insert, remove, and camera to extended video clips" | — |
Nguồn: [Flow models & features](https://support.google.com/flow/answer/16352836), [Flow edit/extend](https://support.google.com/flow/answer/16935718), [Gemini API Veo](https://ai.google.dev/gemini-api/docs/veo), [Android Authority 28/08/2026](https://www.androidauthority.com/google-flow-gemini-omni-1-1-flash-video-update-3704288/).
**Kết luận:** Extend giữ máy và nhân vật vì nối từ giây cuối, nhưng không cho đặt End frame và không cho ingredients → không kiểm soát được tư thế kết thúc. Cho clip lặp trong app, **không cần Extend**: một chu kỳ tốt + lặp bằng ffmpeg đã đủ. Chỉ cân nhắc Extend (Veo Lite) cho video xem thử dài một cảnh.

### 2.4 Hold 10–20 s trông "sống"
- Không có tài liệu Google riêng cho hold. Vertex liệt kê "standing still" là Action hợp lệ và "Subtle actions" (thở, gật nhẹ) → prompt hold hợp lệ theo cấu trúc chính thức.
- Khuyến nghị (thực hành, **[chưa xác minh]**): tạo clip hold 8–10 s, Start = End, prompt:
  `She holds the <pose> perfectly still for the whole clip. The only motion is quiet breathing: her chest and shoulders rise and fall slowly, about one breath every 4 seconds; one slow blink around 00:03 and 00:07. Hands, feet and the chair do not move at all. Static tripod shot, locked off.`
  Rồi lặp bằng `build_loop.py` với crossfade ngắn (0.3–0.5 s) ở mối nối; kiểm bằng `qa_measure.py` (độ lệch tường < 2, mối nối ≤ 3× trung vị). Freeze-frame chỉ dùng làm ảnh tĩnh (thumbnail), không dùng làm hold vì mất thở/chớp mắt.
- Nếu Omni thêm chuyển động thừa (đổi tư thế tay), giảm về 6 s và ghi rõ "no other movement at all".

### 2.5 Nhất quán nhân vật qua 30+ clip
| Cơ chế | Chính thức nói gì | Giới hạn |
|---|---|---|
| **Characters** (`@name`) | "A character must contain at least one image"; "upload or generate 1 or 2 images"; "remain strictly consistent across multiple generations without needing to upload the same images every time" | Giữ mặt/quần áo, **không giữ cỡ người và bố cục** (kinh nghiệm 5f) |
| **Ingredients** (reference images) | "provide subject or product references on a plain or segmented background"; "text prompt should complement, not contradict, your visual inputs"; Gemini API: "up to three reference images" | Veo Quality không hỗ trợ; Veo Lite/Fast chỉ 8 s; không đi cùng Extend; theo bên thứ ba **không dùng cùng First/Last frame trên Veo** [chưa xác minh] |
| **Start/End frame** | Frames to video: "starts and ends with specific images" | Cách duy nhất khoá khung máy và cỡ người |
Nguồn: [Create a character](https://support.google.com/flow/answer/16935308), [Create videos](https://support.google.com/flow/answer/16353334), [Gemini API Veo](https://ai.google.dev/gemini-api/docs/veo).
**Quy tắc:** một ảnh gốc "GWCoach master" (Nano Banana, sạch, không upscale) → mọi ảnh khung sửa từ ảnh này (mục 5f) → video Frames với `@GWCoach` trong prompt để giữ mặt. Không trộn Ingredients với Frames trên cùng lượt.

### 2.6 Watermark và giấy phép
- Flow: "A visible watermark will be applied automatically if you reside in India, South Korea, or Vietnam." Công tắc "Visible watermarking" dưới ảnh hồ sơ cho vùng khác. SynthID luôn có. [Get started with Flow](https://support.google.com/flow/answer/16353333)
- Google blog 07/2025: "adding a visible watermark to all videos, except for videos generated by Ultra members in Flow". [blog.google](https://blog.google/products/gemini/veo-3-expansion-mobile/) → Ultra + Việt Nam: **chưa có nguồn chính thức nói có bỏ được**; trang gói AI Ultra chỉ ghi "Tăng độ phân giải video lên 4K", không nhắc dấu. [Google AI plans](https://one.google.com/about/google-ai-plans/)
- Credit Flow theo gói (trang gói, tiếng Việt): Plus 200, Pro 1.000, Ultra 10.000 credit/tháng **[đọc từ trang bán hàng, con số có thể đổi]**.
- Điều khoản: Google ToS: "Google won't claim ownership over that content." và "Don't remove, obscure, or alter any of our branding, logos, or legal notices." [policies.google.com/terms](https://policies.google.com/terms). Trang "Generative AI Additional Terms" ghi đã gộp vào ToS chính từ 22/05/2024. [policies.google.com/terms/generative-ai](https://policies.google.com/terms/generative-ai)
- Hành động: trước khi sản xuất hàng loạt, chủ app thử 1 tháng Ultra **hoặc** hỏi hỗ trợ Google về công tắc ở Việt Nam; giữ quyết định 5c (không crop/che dấu).

## 3. ElevenLabs TTS

### 3.1 Bảng cài đặt cho giọng coach chậm, ấm
| Tham số | Biên / mặc định (API) | Đề xuất | Ghi chú |
|---|---|---|---|
| `model_id` | mặc định `eleven_multilingual_v2` | `eleven_multilingual_v2` | "Most stable on long-form generations"; hỗ trợ `<break>`, stitching, timestamps (đang chạy) |
| `stability` | 0–1, mặc định 0.5 | 0.6–0.7 | "Higher values can result in a monotonous voice" → không lên 0.9 |
| `similarity_boost` | mặc định 0.75 | 0.75 | |
| `style` | mặc định 0 | 0–0.15 | "increases latency when non-zero"; cao dễ trôi giọng |
| `use_speaker_boost` | mặc định true | true | |
| `speed` | 0.7–1.2, mặc định 1.0 | 0.90–0.95 | "Extreme values may affect the quality"; v3 có speed, `eleven_v3_conversational` bỏ qua speed [bên thứ ba] |
| `seed` | 0–4294967295 | cố định một số | tái tạo gần giống khi dựng lại |
| `previous_text` / `next_text` | chuỗi | câu trước/sau trong cùng bài | giữ ngữ điệu giữa các câu ngắn |
| `previous_request_ids` | tối đa 3, "no older than two hours" | id 1–3 câu trước | **không có cho `eleven_v3`** |
| `pronunciation_dictionary_locators` | tối đa 3/lượt | 1 từ điển (.pls/.txt) cho tên bài, "Gentle Walk" | alias/phoneme; v2 hỗ trợ `<phoneme alphabet="cmu-arpabet">` |
| `apply_text_normalization` | auto/on/off | auto | |
Nguồn: [TTS convert API](https://elevenlabs.io/docs/api-reference/text-to-speech/convert), [Controls](https://elevenlabs.io/docs/best-practices/prompting/controls), [Request stitching](https://elevenlabs.io/docs/cookbooks/text-to-speech/request-stitching), [Models](https://elevenlabs.io/docs/overview/models).
- Giới hạn ký tự/lượt: v4 10.000; v3 5.000; Multilingual v2 10.000; Flash v2.5 40.000.
- `with-timestamps` trả `alignment.characters / character_start_times_seconds / character_end_times_seconds` và `normalized_alignment`; non-streaming. v3 có timestamps hay không: **chưa xác minh**. [with-timestamps](https://elevenlabs.io/docs/api-reference/text-to-speech/convert-with-timestamps)
- `speed` và `stability` độc lập; speed thấp + stability cao cho giọng đều, nhưng speed < 0.85 bắt đầu "kéo" âm. Thử 0.92 (đang dùng) và 0.88 rồi nghe A/B.

### 3.2 Audio tags (v3/v4) — chỉ khi cần cảm xúc
- Tài liệu liệt kê: `[laughs]`, `[laughs harder]`, `[starts laughing]`, `[wheezing]`, `[whispers]`, `[sighs]`, `[exhales]`, `[sarcastic]`, `[curious]`, `[excited]`, `[crying]`, `[snorts]`, `[mischievously]`; SFX `[gunshot]`, `[applause]`, `[clapping]`, `[explosion]`, `[swallows]`, `[gulps]`; thử nghiệm `[strong X accent]`, `[sings]`, `[woo]`. [Prompting v4](https://elevenlabs.io/docs/best-practices/prompting/eleven-v4) (v3 dùng chung: "prompting techniques in Prompting Eleven v4 also apply to Eleven v3").
- `[short pause]`, `[long pause]`, `[exhales sharply]`, `[inhales deeply]`, `[thoughtful]` xuất hiện trong ngữ cảnh "enhance" của docs, **không nằm trong danh sách chính** [chưa xác minh]. `[slowly]`, `[softly]`, `[calm]`, `[gently]`, `[rushed]`, `[drawn out]`: **không có trong docs chính thức** (chỉ bên thứ ba) → nếu dùng phải nghe kiểm.
- Cảnh báo chính thức: "the model will still speak out the emotional delivery guides" và tag "can occasionally be interpreted as a request for a sound effect". → với coach thì tránh tag; dùng dấu câu.
- Stability v3 trong UI có 3 nấc Creative / Natural / Robust; mô tả chi tiết chỉ thấy ở bên thứ ba ([Runware](https://runware.ai/docs/models/elevenlabs-v3/guides/directing-with-audio-tags)) **[chưa xác minh trong docs ElevenLabs]**. Nếu dùng v3: Natural hoặc Robust.

### 3.3 Ngắt nghỉ nhất quán
| Cách | Model | Ghi chú chính thức |
|---|---|---|
| `<break time="1.0s" />` | v2 (Multilingual v2, Flash v2.5) | "up to 3 seconds"; "too many break tags in a single generation can cause instability" |
| "…" (ellipses), gạch ngang | mọi model | "Ellipses (...) add pauses and weight"; ở v3/v4 là cách chính ("less consistent" hơn break) |
| SSML break | v3/v4 | "Eleven v4 and Eleven v3 do not support SSML break tags" |
Khuyến nghị: mỗi câu lệnh là **một request riêng** (đang làm) + khoảng lặng cố định do `build_preview.py` chèn theo cue → ngắt tuyệt đối chính xác, không phụ thuộc model. Trong câu chỉ dùng 1–2 `<break>` ≤ 1.0 s (ví dụ "Sit tall. <break time=\"0.8s\" /> Breathe in.").

### 3.4 Stitching cho nhiều câu ngắn
- Có: `previous_text`/`next_text` (chuỗi văn bản) và `previous_request_ids`/`next_request_ids` (tối đa 3, trong 2 giờ, request phải "processed completely"). Hiệu quả "depends on the model, voice and voice settings". Không có cho `eleven_v3`.
- Áp dụng vào cache theo hash: đưa `previous_text` = câu trước trong cùng bài (không cần request id, nên cache vẫn tái lập); ghi `previous_text` vào hash để không lệch cache.

### 3.5 Giấy phép và hạn mức
- "When generating content on our paid plans, you get commercial rights to use that content." / "If you are on the free plan, you can use the content non-commercially with attribution." [Billing](https://elevenlabs.io/docs/overview/administration/billing)
- Voice Library: "All voices in the Voice Library come with a free commercial use license." [Voices guide](https://elevenlabs.io/elevenlabs-voices-a-comprehensive-guide). Voice Library Addendum: giọng có thể bị gỡ "in our sole discretion… with or without notice", nhưng "Outputs generated… will continue to exist and remain available for use thereafter" [VLA](https://elevenlabs.io/vla) → audio đã đóng gói vào app vẫn hợp lệ; **lưu file gốc + hoá đơn + ảnh chụp trang giọng có ngày**. Free plan không gọi được giọng thư viện qua API (402, đã gặp).
- Gói (trang pricing 30/09/2026): Free $0 · 10.000 credit, không thương mại; Starter $6 · 30.000; Creator $22 · 121.000, MP3 192 kbps; Pro $99 · 600.000, PCM 44,1 kHz qua API. [Pricing](https://elevenlabs.io/pricing)
- API PAYG (trang API pricing): v3 $0.08/1.000 ký tự; Multilingual v2 $0.08; Flash/Turbo $0.04; v4 $0.022 khuyến mãi tới 12/10 (thường $0.08); ghi "Commercial use licensing on Starter+ plans". [API pricing](https://elevenlabs.io/pricing/api) → **PAYG thuần không có dòng giấy phép thương mại riêng: chưa xác minh**, an toàn là mua Creator 1 tháng như đã khuyến nghị.

## 4. Eleven Music & Sound Effects

### 4.1 Eleven Music
- API `POST /v1/music`: `prompt` hoặc `composition_plan` (không cùng lúc), `music_length_ms` 3.000–600.000 (docs capabilities ghi tối đa 5 phút; API ghi 10 phút — lấy 5 phút làm an toàn), `force_instrumental: true` "guarantees that the generated song will be instrumental" (chỉ với prompt), `model_id` `music_v1`/`music_v2`/`music_v2_5`, inpainting để tạo lại một đoạn. [Compose API](https://elevenlabs.io/docs/api-reference/music/compose), [Music](https://elevenlabs.io/docs/overview/capabilities/music)
- Prompt (best practices): chốt trước **genre, mood, instrumentation, tempo, production era**; "instrumental only"; ghi BPM ("holds a stated BPM and key precisely"); kể cấu trúc "start with… then bring in…"; cho loop: ghi số bar, BPM, key và điều loại trừ. **Không có tính năng loop liền mạch** trong docs → tạo bài 2–3 phút có intro/outro mềm, rồi tự crossfade khi lặp trong app. [Best practices](https://elevenlabs.io/docs/overview/capabilities/music/best-practices)
  Mẫu: `Calm instrumental only, 62 BPM, key of D major, soft felt piano, warm pad, light acoustic guitar, no drums, no melody hooks that repeat too obviously; steady and unhurried for 150 seconds; gentle 8-bar intro that swells in, gentle 8-bar outro that fades to the same pad as the intro so the track can loop.`
- Giấy phép (Music model-specific terms): self-serve Free→Business: "All online and offline commercial use permitted, except film, TV, radio, & Studio Games"; Free phải ghi công "denote Eleven Music"; streaming cấm ở Free/Starter, cho phép từ Creator. Dùng trong app di động: không bị nêu trong loại trừ **[không được nêu rõ, nên chụp trang điều khoản có ngày]**. [Music terms](https://elevenlabs.io/eleven-music-model-specific-terms)
- Giá: API $0.15/phút (trang API pricing); credit/phút trong gói: 900 [ghi chú cũ + bên thứ ba, **xác nhận lại trên trang pricing khi đăng nhập**].

### 4.2 Sound Effects (chuông 2 nốt)
- API `POST /v1/sound-generation`: `text`, `duration_seconds` 0.5–30, `prompt_influence` 0–1 (mặc định 0.3), `loop` (chỉ `eleven_text_to_sound_v2`), output MP3 44,1 kHz hoặc WAV 48 kHz. [SFX API](https://elevenlabs.io/docs/api-reference/text-to-sound-effects/convert)
- Credit: web 200/lượt khi AI tự chọn độ dài, 40 credit/giây khi đặt độ dài (docs capabilities); API 100/lượt hoặc 11 credit/giây [help center, đọc qua tóm tắt tìm kiếm — **xác nhận**]. Giấy phép: cùng quy tắc gói trả phí. [SFX](https://elevenlabs.io/docs/overview/capabilities/sound-effects)
  Prompt: `soft two-note meditation chime, small brass singing bowl struck gently twice, first note then a slightly higher note one second later, warm, no reverb tail longer than 2 seconds, studio quality` với `duration_seconds: 2.5`, `prompt_influence: 0.6`, 3–4 lượt chọn.
- Thay thế: **ffmpeg sine** (0 chi phí, không giấy phép, lặp lại chính xác):
  `ffmpeg -f lavfi -i "sine=frequency=880:duration=1.2" -f lavfi -i "sine=frequency=1174.66:duration=1.4" -filter_complex "[0]afade=t=in:d=0.01,afade=t=out:st=0.4:d=0.8,volume=0.5[a];[1]adelay=700|700,afade=t=in:d=0.01,afade=t=out:st=0.5:d=0.9,volume=0.45[b];[a][b]amix=inputs=2:normalize=0,aformat=sample_rates=44100" -t 2.4 chime_A5_D6.wav` (A5→D6, quãng 4; thêm hài âm bằng `sine` 2× tần số ở âm lượng nhỏ nếu muốn "kim loại" hơn). Freesound CC0 cũng hợp lệ nhưng phải lưu trang giấy phép từng file.
- **Khuyến nghị:** ffmpeg cho chuông (đơn giản, lặp 10 lần/bài không lộ), SFX chỉ nếu chủ app muốn âm sắc singing bowl.

## 5. Chi phí ước tính (số chính thức + số đã đo trong dự án)
| Việc | Đơn giá | Ước tính |
|---|---|---|
| Clip động tác Omni 1.1 Flash 720p 8 s | 12 credit (đo, 28/09) | 30 clip × 2 lượt = **720 credit** |
| Thêm draft 360p để thử prompt | "one-third the cost" của 720p → ≈ 4 credit [suy ra] | 30 × 2 = ≈ 240 credit |
| Clip hold 8–10 s | 12 credit | 15 hold × 1,5 lượt = 270 credit |
| Veo 3.1 Quality (không khuyên) | 100 credit/8 s (đo, 30/09) | — |
| Ảnh Nano Banana | 0 (đo) | 0 |
| Gói Pro | 1.000 credit/tháng (trang gói) | ≈ 1,2 tháng cho toàn bộ; Ultra 10.000 |
| Lời giọng, Multilingual v2 | 1 credit/ký tự (ghi chú cũ; $0.08/1.000 ký tự API) | 600 câu × 70 ký tự × 1,5 lượt ≈ **63.000 credit** ≈ $5 PAYG |
| Nhạc | $0.15/phút API; 900 credit/phút [xác nhận] | 15 bài × 2,5 phút = 37,5 phút ≈ 33.750 credit ≈ $5,6 |
| Chuông SFX | 40 credit/giây (web) | 4 lượt × 2,5 s = 400 credit; ffmpeg: 0 |
| **Tổng ElevenLabs** | | ≈ 97.000 credit → **Creator 1 tháng ($22, 121.000) đủ**; Starter (30.000) không đủ trong 1 tháng |

## 6. Nguồn (xem 30/09/2026)
Google
- [Get started with Flow — watermark, vùng](https://support.google.com/flow/answer/16353333)
- [Flow models & supported features](https://support.google.com/flow/answer/16352836)
- [Create videos in Flow — Frames, Ingredients, @Characters](https://support.google.com/flow/answer/16353334)
- [Create a character](https://support.google.com/flow/answer/16935308)
- [Edit videos & build scenes — Extend](https://support.google.com/flow/answer/16935718)
- [Gemini API — Veo 3.1: extend 7 s ×20, 148 s, 3 reference images, 24 fps](https://ai.google.dev/gemini-api/docs/veo)
- [Vertex AI — Veo prompt guide (Subject/Action/Camera/Ambiance/Negative)](https://docs.cloud.google.com/vertex-ai/generative-ai/docs/video/video-gen-prompt-guide)
- [Google Cloud blog — Ultimate prompting guide for Veo 3.1 (timestamps)](https://cloud.google.com/blog/products/ai-machine-learning/ultimate-prompting-guide-for-veo-3-1)
- [DeepMind — Gemini Omni prompt guide](https://deepmind.google/models/gemini-omni/prompt-guide)
- [Google blog 07/2025 — visible watermark trừ Ultra trong Flow](https://blog.google/products/gemini/veo-3-expansion-mobile/)
- [Google AI plans — credit Flow, 4K Ultra](https://one.google.com/about/google-ai-plans/)
- [Google Terms of Service](https://policies.google.com/terms) · [Generative AI Additional Terms (đã gộp)](https://policies.google.com/terms/generative-ai)
- Bên thứ ba: [Android Authority 28/08/2026 — Omni end frames, 4K, 360p, extend 40 s](https://www.androidauthority.com/google-flow-gemini-omni-1-1-flash-video-update-3704288/) · [fal — Omni 1.1 guide](https://fal.ai/learn/tools/how-to-use-gemini-omni-flash-1-1) · [Atlas Cloud — Omni prompt guide](https://www.atlascloud.ai/blog/guides/gemini-omni-prompt-guide) · [invideo — Veo 3.1 guide (frames vs references)](https://invideo.io/blog/google-veo-prompt-guide/)

ElevenLabs
- [Models](https://elevenlabs.io/docs/overview/models) · [Prompting v4 (tags, ellipses, no SSML break)](https://elevenlabs.io/docs/best-practices/prompting/eleven-v4) · [Prompting v3](https://elevenlabs.io/docs/best-practices/prompting/eleven-v3) · [Controls (break ≤ 3 s, speed 0.7–1.2, phoneme, dictionaries)](https://elevenlabs.io/docs/best-practices/prompting/controls)
- [TTS convert API (voice_settings, stitching, dictionaries, seed)](https://elevenlabs.io/docs/api-reference/text-to-speech/convert) · [with-timestamps](https://elevenlabs.io/docs/api-reference/text-to-speech/convert-with-timestamps) · [Request stitching](https://elevenlabs.io/docs/cookbooks/text-to-speech/request-stitching)
- [Pricing](https://elevenlabs.io/pricing) · [API pricing](https://elevenlabs.io/pricing/api) · [Billing — commercial rights](https://elevenlabs.io/docs/overview/administration/billing)
- [Voices guide — Voice Library commercial license](https://elevenlabs.io/elevenlabs-voices-a-comprehensive-guide) · [Voice Library Addendum](https://elevenlabs.io/vla)
- [Music](https://elevenlabs.io/docs/overview/capabilities/music) · [Music best practices](https://elevenlabs.io/docs/overview/capabilities/music/best-practices) · [Music compose API](https://elevenlabs.io/docs/api-reference/music/compose) · [Eleven Music model-specific terms](https://elevenlabs.io/eleven-music-model-specific-terms)
- [Sound effects](https://elevenlabs.io/docs/overview/capabilities/sound-effects) · [SFX API](https://elevenlabs.io/docs/api-reference/text-to-sound-effects/convert) · [SFX cost help (chưa mở được, 403)](https://help.elevenlabs.io/hc/en-us/articles/25735337678481)
- Bên thứ ba: [Runware — v3 stability modes](https://runware.ai/docs/models/elevenlabs-v3/guides/directing-with-audio-tags) · [LiteLLM — v3 speed](https://docs.litellm.ai/docs/providers/elevenlabs)

**Chưa xác minh (cần chủ app hoặc lượt tra sau):** Ultra có bỏ dấu ở Việt Nam; Extend cho Omni trong Flow UI; `[short pause]`/`[long pause]` và Creative/Natural/Robust trong docs chính thức; v3 với `with-timestamps`; credit/phút Eleven Music và credit SFX qua API; PAYG có quyền thương mại; Frames + Ingredients cùng lượt trên Veo.
