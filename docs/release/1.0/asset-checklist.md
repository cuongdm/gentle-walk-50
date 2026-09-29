# Gentle Walk 1.0 — asset thật cần có trước khi nộp (task 9.2)
_29/09/2026. `ReleaseContentTests` (chạy với `TEST_RUNNER_RELEASE_CHECK=1`) chỉ xanh khi đủ các mục có dấu ✱._

| Asset | Hiện có | Cần | Kiểm bằng |
|---|---|---|---|
| ✱ Giọng HLV (voice-lines.json) | 40/247 câu, gói ElevenLabs Free (chỉ prototype) | 247/247 câu, gói thương mại | `ContentValidator` release: 0 `missingVoiceFile` |
| ✱ Clip giãn cơ V7-1 … V7-7 | chưa có | 7 clip lặp 720p, cùng HLV | mọi exercise có `videoFile` |
| Clip động tác ghế V1–V6 | 6 clip 720p (có dấu ✦ của Google, giữ nguyên) | HLV duyệt động tác | xem tay |
| Chuông đổi pha, chuông xong | âm sine tạo bằng ffmpeg | chuông trầm hai nốt + chuông xong | nghe tay |
| Nhạc (music.json) | 3 bài thử Lyria 3.5 (đi bộ, động tác ghế, giãn cơ), chuẩn -20 LUFS, `tools/music/build_music.py` | nhạc có giấy phép dùng thương mại rõ, cùng cách đặt tên `<tên>-walk/seated/stretch.mp3` | nút Music, Me → Music |
| Tranh minh hoạ (Welcome, Break, bưu thiếp, bản đồ, cây, cảnh S11) | khung màu + biểu tượng hệ thống | bộ tranh màu nước theo spec | xem tay |
| App icon | icon tạm vẽ từ SF Symbol | icon thiết kế riêng (SF Symbols không được dùng trong icon) | xem tay |
