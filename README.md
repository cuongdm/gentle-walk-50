# Good Footing (tên làm việc cũ: Gentle Walk 50+)

*Steadier on your feet, at your own pace.*

App iPhone/iPad dẫn bài tập nhẹ tại nhà bằng giọng (đi bộ trong nhà, động tác ghế, giãn cơ, thăng bằng) cho phụ nữ Mỹ 58–75 mới tập hoặc quay lại. Tên store: "Good Footing: Gentle Workouts" (chốt 07/10/2026); mã nội bộ vẫn là `GentleWalk` / `com.kmd.goodfooting`. Đã code xong MVP iOS (113 task, 29/09/2026); việc chủ app còn làm ở [docs/owner-todo-after-mvp.md](docs/owner-todo-after-mvp.md).

## Cấu trúc thư mục
| Thư mục | Là gì |
|---|---|
| `iOS/` | Toàn bộ project iOS: `App/` (code + tài nguyên), `GentleWalkTests/`, `Packages/GentleWalkCore/` (logic sản phẩm, `swift test`), `Config/`, `project.yml` (XcodeGen), `scripts/` (chụp màn, icon tạm, kiểm String Catalog) |
| `Android/` | Để dành cho bản Android |
| `docs/`, `app-context.md` | Tài liệu dùng chung: sản phẩm, spec, kế hoạch, kịch bản, review, phát hành |
| `assets/` | Nguồn gốc dùng chung: tờ tranh (`art/`), nhạc (`music/`), clip (`video/`), giọng (`voice/`) |
| `tools/` | Công cụ dùng chung: build nội dung, cắt tranh, chuyển nhạc, gắn giọng, lint câu chữ; hiện ghi vào `iOS/App/…` |
| `site/` | Trang Privacy |

Mở project iOS:
```bash
cd iOS && xcodegen generate && open GentleWalk.xcodeproj
```

## Đọc theo thứ tự
| File | Là gì |
|---|---|
| [app-context.md](app-context.md) | Sự thật sản phẩm mọi bước dùng chung: định vị, đối thủ, giá bằng chữ, quy tắc giọng văn và từ cấm, rủi ro, decisions log |
| [docs/idea/gentle-walk-voice.md](docs/idea/gentle-walk-voice.md) | Brief ý tưởng: bằng chứng, kết luận GO, vòng lặp hành vi, MVP, tuần mẫu, câu hỏi mở |
| [docs/design/gentle-walk-screen-spec.html](docs/design/gentle-walk-screen-spec.html) | Spec màn hình cho designer (S01–S21), chữ hiển thị mẫu, từ vựng cố định, danh sách frame |
| [docs/content-plan.md](docs/content-plan.md) | Kế hoạch nội dung: kịch bản giọng, âm thanh, video động tác, minh hoạ, chữ trong app, thứ tự sản xuất |
| [docs/scripts/A1-first-walk.md](docs/scripts/A1-first-walk.md) | Kịch bản First Walk 5 phút (nháp 1) |
| [docs/scripts/A2-walk-min.md](docs/scripts/A2-walk-min.md) · [A-min-support.md](docs/scripts/A-min-support.md) · [A10-stretch.md](docs/scripts/A10-stretch.md) · [D-min-texts.md](docs/scripts/D-min-texts.md) | Bộ nội dung tối thiểu cho demo MVP: dẫn đi bộ, câu phụ (ngoài trời, đếm, an toàn, địa danh, chuyển bài), giãn cơ có nguồn, chữ trong app |
| [docs/scripts/V-exercise-clips.md](docs/scripts/V-exercise-clips.md) | Kịch bản 6 clip động tác ghế, lời giọng A4, kết quả clip (mục 5·0) |
| [docs/plans/2026-09-30-content-4-groups.md](docs/plans/2026-09-30-content-4-groups.md) · [docs/scripts/P-production-prompts.md](docs/scripts/P-production-prompts.md) | Kế hoạch nội dung thật cho 4 nhóm bài (Walks, Chair moves, Stretches, Extras) và thư viện prompt Flow/ElevenLabs cho agent sản xuất; nền: `docs/research/2026-09-30-*.md` (chuẩn sức khoẻ có nguồn, đối thủ, kỹ thuật) |
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
