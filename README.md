# Gentle Walk 50+ (tên làm việc)

App iPhone dẫn đi bộ trong nhà, động tác ghế và giãn cơ nhẹ bằng giọng cho phụ nữ Mỹ 50–64 mới tập. Chưa có code. Ý tưởng đã GO (stage 1) và kế hoạch MVP đã duyệt 29/09/2026 (stage 2); bước tiếp theo là `manh-skill-code` từ Task 1.1 sau khi chủ app chốt các điểm mở trong báo cáo review mới nhất.

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
| [docs/plans/2026-09-29-mvp.md](docs/plans/2026-09-29-mvp.md) | Kế hoạch MVP đã duyệt: kiến trúc, bảng tuân thủ, 113 task / 9 milestone, kế hoạch ngôn ngữ và test |
| [docs/research/audio-api-options.md](docs/research/audio-api-options.md) | Giọng và nhạc AI: nền tảng, giấy phép, chi phí |
| [docs/reviews/](docs/reviews/) | Báo cáo rà soát theo ngày (mới nhất: 2026-09-29-tai-lieu-ke-hoach.md) |
| [docs/todo.md](docs/todo.md) | Việc cần làm và các đề xuất đang chờ chủ app chốt |
| [docs/research/prototype-test-plan.md](docs/research/prototype-test-plan.md) | Kế hoạch test prototype với 6–8 người |

## Tài sản
- `assets/video/V1-1 … V6-1/`: clip lặp trong app (`*_loop.mp4`), video xem thử có giọng và phụ đề (`*_preview.mp4`), bản gốc Flow, cấu hình `preview.json`; bản 1080p trong thư mục `1080/`.
- `assets/voice/`: mẫu so sánh giọng ElevenLabs và cache câu thoại (chỉ dùng cho prototype, xem rủi ro giấy phép trong app-context).
- `tools/video/`: script dựng clip lặp, video xem thử, đo QA (cần ffmpeg và Pillow; giọng cần key ElevenLabs ở `~/.config/elevenlabs/api_key`, không nằm trong repo).

## Bước tiếp theo
Xem [docs/todo.md](docs/todo.md), rồi "Việc cần làm" trong [docs/content-plan.md](docs/content-plan.md) và báo cáo rà soát mới nhất trong `docs/reviews/`.

## Cấu trúc tài liệu
Dự án dùng cấu trúc của pipeline manh-skill (`app-context.md` · `docs/idea/` · `docs/plans/` · `docs/reviews/`) thay cho bộ 7 file `docs/*.md` ghi trong `CascadeProjects/CLAUDE.md`. Ánh xạ: tổng quan và PDR → brief + app-context · kiến trúc và code standards → `docs/plans/2026-09-29-mvp.md` mục Decisions và `CLAUDE.md` · roadmap → brief §11 "Thứ tự phase" và `docs/todo.md` · deployment → `docs/release/` (tạo ở stage release).
