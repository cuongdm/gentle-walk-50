# Việc cần làm — Gentle Walk 50+
_Cập nhật 28/09/2026. Mỗi việc có người làm, đầu ra và trạng thái. Xong thì gạch và ghi ngày; quyết định sản phẩm ghi thêm vào decisions log của app-context.md._

## Chủ app quyết định (đề xuất mặc định đã ghi, chưa chốt)
| # | Việc | Đề xuất mặc định | Trạng thái |
|---|---|---|---|
| 1 | Thang cây Seed → Sprout → Sapling → Tree hết sau 3 tuần | Giãn mốc **7 · 21 · 42 ngày hoạt động** (Sprout ngày 7, Sapling ngày 21, Tree ngày 42). Sau Tree: mỗi 42 ngày thêm một "vòng năm" trên thân cây, không thêm cấp mới. Mockup S19 đổi thành "Sprout · 8 days to Sapling". | Chốt 29/09/2026: 7 · 21 · 42, đổi sau nếu cần |
| 2 | Cơ sở cho bài giãn cơ | **Chốt 28/09/2026: không thuê người duyệt.** Bài giãn cơ lấy từ nguồn công khai có uy tín, ghi nguồn cho từng tư thế trong kịch bản A10: [NIA Go4Life, 6 flexibility exercises](https://go4life.nia.nih.gov/sample_workout/6-flexibility-exercises-older-adults) và [trang cổ](https://go4life.nia.nih.gov/exercise/neck/) (giữ 10–30 giây, lặp 3–5 lần, không nhún, thở đều, giãn sau khi đã ấm người); [NHS Sitting exercises](https://www.nhs.uk/live-well/exercise/sitting-exercises/) và [NHS flexibility exercises PDF](https://assets.nhs.uk/prod/documents/NHS-flexibility-exercise.pdf) (ghế không bánh xe, không tay vịn, 2 lần một tuần trở lên); ACSM cho người lớn tuổi: giữ 30–60 giây, 2–4 lần, 2–3 ngày một tuần ([tổng hợp](https://www.unm.edu/~lkravitz/Article%20folder/ACSMGuidelinesUNM.pdf)). Tham khảo thêm video của Bend và chair yoga trên YouTube để xem cách dẫn, không chép lời. Lọc theo S06 tự làm theo chống chỉ định ghi trong các nguồn trên (ví dụ thay khớp háng: không vắt chân, không gập hông quá 90 độ). | Chốt; việc còn lại là viết A10 kèm nguồn |
| 3 | Kế hoạch test prototype | Đã viết một trang: [research/prototype-test-plan.md](research/prototype-test-plan.md). 6–8 phụ nữ Mỹ 55–70, 40 phút mỗi người qua video call, 3 mẫu thử (giọng + tranh, giọng + video, giãn cơ theo giọng), tiêu chí đạt ghi sẵn. | Chờ OK kế hoạch, chưa tuyển |
| 4 | Nhạc nền | **Chốt 28/09/2026: nhạc tạo bằng AI trên gói trả phí.** Đề xuất sau tra cứu: **Eleven Music trên cùng tài khoản ElevenLabs với giọng** (API chính thức, dữ liệu có giấy phép, thương mại từ Starter); không dùng "Suno API" qua bên trung gian. Chi tiết và giá: [research/audio-api-options.md](research/audio-api-options.md). Phương án cũ (Suno Pro/Premier trên web hoặc Udio gói trả phí: gói trả phí có quyền thương mại, không cần ghi nguồn; chỉ dùng bài tải về khi đang ở gói trả phí; lưu bằng chứng gói và ngày tạo cho từng bài; [điều khoản Suno](https://help.suno.com/en/categories/550145-rights-ownership), verify lại lúc tạo). 3 phong cách × 3–5 bản lặp 2–3 phút, không lời, không giai điệu giống bài có bản quyền. **Làm sau khi code**, player dùng file tạm trước. | Chốt; làm ở giai đoạn asset |

## Nguyên tắc chốt 28/09/2026, làm rõ 29/09/2026: code trước, test prototype trên bản build, rồi asset thật
Thứ tự: code hết MVP với asset tạm → test prototype 6–8 người (docs/research/prototype-test-plan.md) → sửa UI theo kết quả → sản xuất asset thật → nộp. Chữ kịch bản (A2–A10) không phải asset: cần trước milestone 4 (mục I4 dưới).
Sang manh-skill-plan với asset hiện có (6 clip, A1, giọng prototype). Nhạc AI, giọng gói thương mại, clip giãn cơ, tranh bưu thiếp làm song song hoặc sau khi code chạy; app dùng placeholder tới lúc đó.

## Trước khi đóng gói giọng vào app
- [ ] **Nâng ElevenLabs lên gói có giấy phép thương mại** (đề xuất Creator một tháng, khoảng 22 USD, đủ cả giọng và nhạc; xem [research/audio-api-options.md](research/audio-api-options.md); verify trên trang giá), rồi **tạo lại toàn bộ câu thoại** bằng gói mới. Cache hiện tại ở `assets/voice/cache/` chỉ dùng cho prototype. Khi nâng gói, nghe thử lại 3 ứng viên giọng thư viện (Elise Hart, Jane Hackett, Carol, id trong docs/video-skill-notes.md §5) so với Bella trước khi sản xuất hàng loạt.
- [ ] Chốt cách làm giọng cuối (TTS, thu người thật hay clone có đồng ý) sau test prototype.

## Video
- [ ] Huấn luyện viên duyệt 6 clip V1-1 … V6-1 (V1 tay chạm ghế khi ngồi, V6 chân nhấc cao hơn kịch bản 2 inch).
- [ ] Viết A10 + kịch bản clip giãn cơ `docs/scripts/S-stretch-clips.md` theo mẫu V-exercise-clips, mỗi tư thế ghi nguồn (mục 2 ở trên); báo giá credit; tạo 2 clip mẫu trước.
- [ ] Tạo nhạc AI 9–15 bản trên gói trả phí (mục 4 ở trên), chuẩn hoá độ to, kiểm tra lặp liền.
- [x] ~~Chốt gói Flow không watermark~~ Chốt 29/09/2026: tạm dùng Flow Pro hiện tại cho clip giãn cơ, nâng gói sau. Hệ quả: trước khi nộp phải tạo lại hoặc xuất lại toàn bộ clip trên gói không watermark (plan 9.2); giữ nguyên prompt, ảnh khung và mốc cắt để làm lại nhanh; không tự xoá dấu ✦.
- [ ] V3 bản dễ/khó, V4 ảnh khung tĩnh cho Reduce Motion và VoiceOver.

## Tài liệu và repo
- [ ] Chép tranh mẫu phong cách từ `Idea-Fitness/docs/ai-test/` vào `docs/design/reference/`.
- [ ] Kiểm tra trademark tên app; chọn tên store.
- [ ] Viết Privacy Policy và Terms (cần cho HealthKit và subscription) trước khi nộp; URL ghi vào app-context.
- [ ] Cân nhắc Git LFS nếu thêm nhiều clip 1080p (repo hiện khoảng 109 MB).

## Backlog từ review 29/09/2026 (docs/reviews/2026-09-29-tai-lieu-ke-hoach.md)
Plan đã duyệt nên không sửa thầm; các mục dưới đưa vào task tương ứng khi bắt đầu task đó.
- [ ] **M5** Task 9.1 thêm Support URL và email liên hệ (ASC bắt buộc; S20 "Contact us"); ghi vào app-context Identity.
- [ ] **M8** Task 5.9 thêm biến thể `paywall-not-eligible`: tiêu đề "Everything in Gentle Walk Pro", nút "Continue"; sửa spec S08.
- [ ] **M9** Task 3.5 thêm bước: bấm Break khi màn hình khoá, chờ 3 phút, Resume từ màn khoá (Now Playing 3.7) — app không phát âm thanh có thể bị treo.
- [ ] **M10** Dựng file A1 5 phút cho mẫu thử M1 bằng `tools/video/build_preview.py` (giọng Bella, cảnh tĩnh S11) — cần cho test prototype.
- [ ] **M11** Task 1.8 ghi chú `CFBundleDisplayName` "Gentle Walk" là tên tạm, đổi khi chốt tên store.
- [x] ~~**I1–I3, I5** chờ chốt~~ Chốt 29/09/2026 (app-context decisions log); đã ghi vào brief, spec, plan (dòng "Bổ sung 29/09" ở task 2.4, 2.7, 2.13, 5.8, 5.9, 6.2, 6.4, 6.9, 7.1), test plan.
- [ ] **I4** Viết A2 tối thiểu (khoảng 60 câu, tái dùng 26 câu "Dùng lại" của A1), A5 số đếm, A7 an toàn, A9 check-in, A10 giãn cơ — **trước milestone 4**; nạp vào voice-lines.json (plan 1.5 nạp thêm khi có).
- [x] ~~**I6**~~ Chốt 29/09/2026: dùng Flow Pro hiện tại; báo giá credit khi tạo clip giãn cơ, và ước thêm một lần tạo lại toàn bộ (6 + 6–8 clip) khi nâng gói.
- [x] ~~**I7**~~ Test plan đổi tuổi người tham gia thành 50–64 (+ tối đa 2 người 65–68).

## Kế hoạch code (đã duyệt 29/09/2026)
- [x] ~~Gọi `manh-skill-plan`~~ → `docs/plans/2026-09-29-mvp.md`: 113 task / 9 milestone, duyệt toàn bộ. Đã chốt: 0,05 dặm mỗi phút tập, hook `-ScreenshotMode`, không đo hiệu quả thông báo trong v1.
- [ ] Gọi `manh-skill-code` trên Mac (cần Xcode 27, `brew install xcodegen`), bắt đầu Task 1.1.
- [ ] Trả lời 4 STOP AND ASK khi tới task: Team ID (1.1), mốc thang cây (2.5, mặc định 7 · 21 · 42), EULA Apple hay Terms riêng (5.10), hosting trang pháp lý (9.1, mặc định GitHub Pages).
- [ ] Chuẩn bị iPhone thật cho 3.5 (chạy khi khoá màn hình), 8.6 (tuyến ngoài trời), 8.8–8.9 (ghi dữ liệu và thử tự đếm).
