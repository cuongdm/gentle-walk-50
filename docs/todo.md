# Việc cần làm — Gentle Walk 50+
_Cập nhật 28/09/2026. Mỗi việc có người làm, đầu ra và trạng thái. Xong thì gạch và ghi ngày; quyết định sản phẩm ghi thêm vào decisions log của app-context.md._

## Chủ app quyết định (đề xuất mặc định đã ghi, chưa chốt)
| # | Việc | Đề xuất mặc định | Trạng thái |
|---|---|---|---|
| 1 | Thang cây Seed → Sprout → Sapling → Tree hết sau 3 tuần | Giãn mốc **7 · 21 · 42 ngày hoạt động** (Sprout ngày 7, Sapling ngày 21, Tree ngày 42). Sau Tree: mỗi 42 ngày thêm một "vòng năm" trên thân cây, không thêm cấp mới. Mockup S19 đổi thành "Sprout · 8 days to Sapling". | Chờ OK |
| 2 | Ai duyệt kịch bản giãn cơ và lọc tư thế theo giới hạn S06 | Thuê **một huấn luyện viên có chứng chỉ chuyên người lớn tuổi** (ACE Senior Fitness Specialist, NASM Senior Fitness Specialist, hoặc kỹ thuật viên vật lý trị liệu) qua Upwork/Fiverr, duyệt **theo đợt**: đợt 1 = 6 clip + A4 + A10 (giãn cơ) + A7; đợt 2 = A2, A3. Đầu ra: bảng từng động tác/tư thế, cột "ẩn khi người dùng chọn" (Knees, Hips, Shoulders, Joint replacement, I get dizzy easily, Standing for long is hard). Không ghi tên hay chứng chỉ của người duyệt trong app. | Chờ OK, chưa tìm người |
| 3 | Kế hoạch test prototype | Đã viết một trang: [research/prototype-test-plan.md](research/prototype-test-plan.md). 6–8 phụ nữ Mỹ 55–70, 40 phút mỗi người qua video call, 3 mẫu thử (giọng + tranh, giọng + video, giãn cơ theo giọng), tiêu chí đạt ghi sẵn. | Chờ OK kế hoạch, chưa tuyển |
| 4 | Nguồn nhạc miễn bản quyền cho app trả phí | Mua **giấy phép theo bài, loại cho app** (không dùng gói cá nhân YouTube). Ưu tiên: (a) đặt nhạc sĩ làm 9–15 bản lặp 2–3 phút, mua đứt bản quyền, giữ đúng 3 phong cách; (b) nếu muốn nhanh: Artlist hoặc Epidemic Sound gói có điều khoản "app/software", hoặc Pond5 theo bài với giấy phép app. Kiểm tra: cho phép nhúng vào app trả phí, không giới hạn lượt tải, không cần ghi nguồn trong app. Chưa có ứng viên cụ thể. | Chờ OK hướng, chưa chọn |

## Trước khi đóng gói giọng vào app
- [ ] **Nâng ElevenLabs lên gói có giấy phép thương mại** (Starter trở lên; verify trên trang giá), rồi **tạo lại toàn bộ câu thoại** bằng gói mới. Cache hiện tại ở `assets/voice/cache/` chỉ dùng cho prototype. Khi nâng gói, nghe thử lại 3 ứng viên giọng thư viện (Elise Hart, Jane Hackett, Carol, id trong docs/video-skill-notes.md §5) so với Bella trước khi sản xuất hàng loạt.
- [ ] Chốt cách làm giọng cuối (TTS, thu người thật hay clone có đồng ý) sau test prototype.

## Video
- [ ] Huấn luyện viên duyệt 6 clip V1-1 … V6-1 (V1 tay chạm ghế khi ngồi, V6 chân nhấc cao hơn kịch bản 2 inch).
- [ ] Viết A10 + kịch bản clip giãn cơ `docs/scripts/S-stretch-clips.md` theo mẫu V-exercise-clips; báo giá credit; tạo 2 clip mẫu trước.
- [ ] Chốt gói Flow không watermark (Google AI Ultra, verify) hoặc công cụ khác trước khi làm hàng loạt; không tự xoá dấu ✦.
- [ ] V3 bản dễ/khó, V4 ảnh khung tĩnh cho Reduce Motion và VoiceOver.

## Tài liệu và repo
- [ ] Chép tranh mẫu phong cách từ `Idea-Fitness/docs/ai-test/` vào `docs/design/reference/`.
- [ ] Kiểm tra trademark tên app; chọn tên store.
- [ ] Viết Privacy Policy và Terms (cần cho HealthKit và subscription) trước khi nộp; URL ghi vào app-context.
- [ ] Cân nhắc Git LFS nếu thêm nhiều clip 1080p (repo hiện khoảng 109 MB).

## Sau khi 1–4 chốt và huấn luyện viên duyệt xong
- [ ] Gọi `manh-skill-plan`: hằng số phút → dặm, mốc thang cây, quy ước tên file asset, cách đo thông báo không backend, launch argument cho screenshot.
