# Gentle Walk 50+ (tên làm việc)

App iPhone dẫn đi bộ trong nhà, động tác ghế và giãn cơ nhẹ bằng giọng cho phụ nữ Mỹ 50–64 mới tập. Chưa có code; repo đang ở giai đoạn ý tưởng và nội dung (stage 1 của pipeline manh-skill).

## Đọc theo thứ tự
| File | Là gì |
|---|---|
| [app-context.md](app-context.md) | Sự thật sản phẩm mọi bước dùng chung: định vị, đối thủ, giá bằng chữ, quy tắc giọng văn và từ cấm, rủi ro, decisions log |
| [docs/idea/gentle-walk-voice.md](docs/idea/gentle-walk-voice.md) | Brief ý tưởng: bằng chứng, kết luận GO, vòng lặp hành vi, MVP, tuần mẫu, câu hỏi mở |
| [docs/design/gentle-walk-screen-spec.html](docs/design/gentle-walk-screen-spec.html) | Spec màn hình cho designer (S01–S21), chữ hiển thị mẫu, từ vựng cố định, danh sách frame |
| [docs/content-plan.md](docs/content-plan.md) | Kế hoạch nội dung: kịch bản giọng, âm thanh, video động tác, minh hoạ, chữ trong app, thứ tự sản xuất |
| [docs/scripts/A1-first-walk.md](docs/scripts/A1-first-walk.md) | Kịch bản First Walk 5 phút (nháp 1) |
| [docs/scripts/V-exercise-clips.md](docs/scripts/V-exercise-clips.md) | Kịch bản 6 clip động tác ghế, lời giọng A4, kết quả clip (mục 5·0) |
| [docs/video-skill-notes.md](docs/video-skill-notes.md) | Quy trình làm clip trên Google Flow, QA, dựng, bài học |
| [docs/reviews/](docs/reviews/) | Báo cáo rà soát theo ngày |
| [docs/todo.md](docs/todo.md) | Việc cần làm và các đề xuất đang chờ chủ app chốt |
| [docs/research/prototype-test-plan.md](docs/research/prototype-test-plan.md) | Kế hoạch test prototype với 6–8 người |

## Tài sản
- `assets/video/V1-1 … V6-1/`: clip lặp trong app (`*_loop.mp4`), video xem thử có giọng và phụ đề (`*_preview.mp4`), bản gốc Flow, cấu hình `preview.json`; bản 1080p trong thư mục `1080/`.
- `assets/voice/`: mẫu so sánh giọng ElevenLabs và cache câu thoại (chỉ dùng cho prototype, xem rủi ro giấy phép trong app-context).
- `tools/video/`: script dựng clip lặp, video xem thử, đo QA (cần ffmpeg và Pillow; giọng cần key ElevenLabs ở `~/.config/elevenlabs/api_key`, không nằm trong repo).

## Bước tiếp theo
Xem [docs/todo.md](docs/todo.md), rồi "Việc cần làm" trong [docs/content-plan.md](docs/content-plan.md) và báo cáo rà soát mới nhất trong `docs/reviews/`.
