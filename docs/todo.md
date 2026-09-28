# Việc cần làm — Gentle Walk 50+
_Cập nhật 28/09/2026. Mỗi việc có người làm, đầu ra và trạng thái. Xong thì gạch và ghi ngày; quyết định sản phẩm ghi thêm vào decisions log của app-context.md._

## Chủ app quyết định (đề xuất mặc định đã ghi, chưa chốt)
| # | Việc | Đề xuất mặc định | Trạng thái |
|---|---|---|---|
| 1 | Thang cây Seed → Sprout → Sapling → Tree hết sau 3 tuần | Giãn mốc **7 · 21 · 42 ngày hoạt động** (Sprout ngày 7, Sapling ngày 21, Tree ngày 42). Sau Tree: mỗi 42 ngày thêm một "vòng năm" trên thân cây, không thêm cấp mới. Mockup S19 đổi thành "Sprout · 8 days to Sapling". | Chờ OK |
| 2 | Cơ sở cho bài giãn cơ | **Chốt 28/09/2026: không thuê người duyệt.** Bài giãn cơ lấy từ nguồn công khai có uy tín, ghi nguồn cho từng tư thế trong kịch bản A10: [NIA Go4Life, 6 flexibility exercises](https://go4life.nia.nih.gov/sample_workout/6-flexibility-exercises-older-adults) và [trang cổ](https://go4life.nia.nih.gov/exercise/neck/) (giữ 10–30 giây, lặp 3–5 lần, không nhún, thở đều, giãn sau khi đã ấm người); [NHS Sitting exercises](https://www.nhs.uk/live-well/exercise/sitting-exercises/) và [NHS flexibility exercises PDF](https://assets.nhs.uk/prod/documents/NHS-flexibility-exercise.pdf) (ghế không bánh xe, không tay vịn, 2 lần một tuần trở lên); ACSM cho người lớn tuổi: giữ 30–60 giây, 2–4 lần, 2–3 ngày một tuần ([tổng hợp](https://www.unm.edu/~lkravitz/Article%20folder/ACSMGuidelinesUNM.pdf)). Tham khảo thêm video của Bend và chair yoga trên YouTube để xem cách dẫn, không chép lời. Lọc theo S06 tự làm theo chống chỉ định ghi trong các nguồn trên (ví dụ thay khớp háng: không vắt chân, không gập hông quá 90 độ). | Chốt; việc còn lại là viết A10 kèm nguồn |
| 3 | Kế hoạch test prototype | Đã viết một trang: [research/prototype-test-plan.md](research/prototype-test-plan.md). 6–8 phụ nữ Mỹ 55–70, 40 phút mỗi người qua video call, 3 mẫu thử (giọng + tranh, giọng + video, giãn cơ theo giọng), tiêu chí đạt ghi sẵn. | Chờ OK kế hoạch, chưa tuyển |
| 4 | Nhạc nền | **Chốt 28/09/2026: nhạc tạo bằng AI trên gói trả phí** (Suno Pro/Premier hoặc Udio gói trả phí: gói trả phí có quyền thương mại, không cần ghi nguồn; chỉ dùng bài tải về khi đang ở gói trả phí; lưu bằng chứng gói và ngày tạo cho từng bài; [điều khoản Suno](https://help.suno.com/en/categories/550145-rights-ownership), verify lại lúc tạo). 3 phong cách × 3–5 bản lặp 2–3 phút, không lời, không giai điệu giống bài có bản quyền. **Làm sau khi code**, player dùng file tạm trước. | Chốt; làm ở giai đoạn asset |

## Nguyên tắc chốt 28/09/2026: code trước, asset bổ sung sau
Sang manh-skill-plan với asset hiện có (6 clip, A1, giọng prototype). Nhạc AI, giọng gói thương mại, clip giãn cơ, tranh bưu thiếp làm song song hoặc sau khi code chạy; app dùng placeholder tới lúc đó.

## Trước khi đóng gói giọng vào app
- [ ] **Nâng ElevenLabs lên gói có giấy phép thương mại** (Starter trở lên; verify trên trang giá), rồi **tạo lại toàn bộ câu thoại** bằng gói mới. Cache hiện tại ở `assets/voice/cache/` chỉ dùng cho prototype. Khi nâng gói, nghe thử lại 3 ứng viên giọng thư viện (Elise Hart, Jane Hackett, Carol, id trong docs/video-skill-notes.md §5) so với Bella trước khi sản xuất hàng loạt.
- [ ] Chốt cách làm giọng cuối (TTS, thu người thật hay clone có đồng ý) sau test prototype.

## Video
- [ ] Huấn luyện viên duyệt 6 clip V1-1 … V6-1 (V1 tay chạm ghế khi ngồi, V6 chân nhấc cao hơn kịch bản 2 inch).
- [ ] Viết A10 + kịch bản clip giãn cơ `docs/scripts/S-stretch-clips.md` theo mẫu V-exercise-clips, mỗi tư thế ghi nguồn (mục 2 ở trên); báo giá credit; tạo 2 clip mẫu trước.
- [ ] Tạo nhạc AI 9–15 bản trên gói trả phí (mục 4 ở trên), chuẩn hoá độ to, kiểm tra lặp liền.
- [ ] Chốt gói Flow không watermark (Google AI Ultra, verify) hoặc công cụ khác trước khi làm hàng loạt; không tự xoá dấu ✦.
- [ ] V3 bản dễ/khó, V4 ảnh khung tĩnh cho Reduce Motion và VoiceOver.

## Tài liệu và repo
- [ ] Chép tranh mẫu phong cách từ `Idea-Fitness/docs/ai-test/` vào `docs/design/reference/`.
- [ ] Kiểm tra trademark tên app; chọn tên store.
- [ ] Viết Privacy Policy và Terms (cần cho HealthKit và subscription) trước khi nộp; URL ghi vào app-context.
- [ ] Cân nhắc Git LFS nếu thêm nhiều clip 1080p (repo hiện khoảng 109 MB).

## Sau khi 1–4 chốt và huấn luyện viên duyệt xong
- [ ] Gọi `manh-skill-plan`: hằng số phút → dặm, mốc thang cây, quy ước tên file asset, cách đo thông báo không backend, launch argument cho screenshot.
