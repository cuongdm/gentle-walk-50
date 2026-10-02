# Đêm 01→02/10/2026: tiếng Việt + kiểm thử toàn app

_Chủ app giao trước khi ngủ: (1) đa ngôn ngữ, tiếng Việt là ngôn ngữ thứ hai, mặc định tiếng Anh, đổi trong Me; dùng key ElevenLabs Creator nếu cần tạo giọng; Claude dịch và review cho tự nhiên, trung tính. (2) Tự kiểm thử mọi mặt: màn hình, luồng, logic, code, UI/UX, dễ dùng lần đầu, đa ngôn ngữ, khả năng mở rộng ngôn ngữ. Test – sửa – lặp tới khi ổn._

Commit chốt việc cũ trước khi làm: `661b2f4` (cả 81 clip video app dùng). Mọi thay đổi đêm nay **chưa commit** (đề xuất message ở cuối).

## 1. Tiếng Việt — đã xong phần chữ, chờ phần giọng
| Phần | Kết quả |
|---|---|
| Chữ màn hình | 648/648 chuỗi có bản Việt trong `Localizable.xcstrings`; 6 câu xin quyền iOS trong `InfoPlist.xcstrings` |
| Nội dung | 35 động tác (tên, công dụng, mẹo, dễ hơn/khó hơn, ghi chú theo giới hạn cơ thể), 5 hành trình + 30 bưu thiếp, 26 thông báo, 8 việc nhỏ làm được → `Resources/Content/content.vi.json` |
| Lời HLV | 592/592 câu dịch, giữ độ dài gần bằng tiếng Anh (lời đặt theo giây trong buổi tập) |
| Giọng HLV tiếng Việt | **Chưa tạo**: gói ElevenLabs Creator còn ~680/131.000 ký tự tới 21/10/2026, cần ~35.000. Đã dựng sẵn quy trình (`render_lines.py --voice bella-v4-vi`, `build_content_overlay.py vi --cache …`) và 2 giọng mẫu để chọn: `assets/voice/samples-vi/bella-v4.mp3` (giọng HLV tiếng Anh hiện tại nói tiếng Việt), `sarah-v4.mp3`. Bản DEBUG đọc tạm bằng giọng hệ thống iOS tiếng Việt |
| Đổi ngôn ngữ | Me → Language: English · Tiếng Việt (mặc định English kể cả iPhone tiếng Việt). Đóng hẳn app rồi mở lại để áp dụng (app hướng dẫn cách vuốt đóng, bằng chính ngôn ngữ vừa chọn) |
| An toàn bản phát hành | Bản Release chỉ cho chọn ngôn ngữ đã có đủ giọng; nếu ép tiếng Việt từ Cài đặt iOS khi chưa có giọng thì màn hình tiếng Việt, HLV vẫn nói tiếng Anh (không im lặng). Cổng phát hành `ReleaseContentTests` chặn ngôn ngữ thiếu ghi âm |
| Mở rộng ngôn ngữ | Thêm 1 ngôn ngữ = 1 case `AppLanguage` + 1 cột catalog + 1 file `content.<mã>.json` + giọng. Hướng dẫn: `docs/i18n/README.md`. Thuật ngữ: `docs/i18n/glossary-vi.md` |

Cách làm: 6 agent dịch song song theo bảng thuật ngữ chung (tên 35 động tác chốt trước để màn hình và lời HLV khớp nhau) → 1 agent rà chéo toàn bộ (thống nhất "lượt", "giọng hướng dẫn", "Muốn dễ hơn…", bỏ từ lóng, bỏ "chúng tôi") → tôi chụp 88 màn tiếng Việt, sửa chữ tràn và chữ chưa dịch.

Lỗi đa ngôn ngữ tìm và sửa:
- Chữ "Back" (vùng lưng) trên màn Bị đau hiện "Quay lại" (trùng khoá nút Back) → khoá riêng `body.back`.
- 12 câu không vào catalog vì nằm trong `điều kiện ? "A" : "B"` hoặc trong tuple (câu cảm thông onboarding, câu màn Nghỉ…) → công cụ `tools/i18n/scan_literals.py` quét chữ hiển thị bị sót; danh sách khoá thủ công `docs/i18n/source/ui-manual.json`.
- Tên phong cách nhạc, tên mẫu "Margaret" trong ô nhập tên (tiếng Việt: "Lan"), "Later" dùng cho 2 nghĩa → đã tách/dịch.
- Bố cục: "Hôm nay" trong dải tuần bị thu bé quá → hiện tên thứ in đậm; tiêu đề tháng viết hoa chữ đầu ("Tháng 10 năm 2026"); dòng trạng thái player rút gọn ("Lượt 2/6 · tổng còn 7:13"); ô "Have ready" rút còn 1–2 chữ.

## 2. Kiểm thử toàn app — lỗi đã sửa
Nguồn: 2 agent rà soát (code/logic 21 mục, luồng người dùng 20 mục), 182 ảnh màn hình (88 tiếng Việt + 94 tiếng Anh), test tự động.

**Nghiêm trọng**
- Đi ngoài trời → Nghỉ → "Đi về nhà nhẹ nhàng" làm **crash app** (đếm ngược tới vô cực). Sửa + màn đi về nhà đếm thời gian đã đi + test.

**Quan trọng**
- Dừng buổi vì **bị đau** vẫn hiện lá rơi, chuông vui, "Làm được rồi!" → màn riêng: "Dừng lại là đúng. Hôm nay vẫn được tính…", HLV nghỉ ngơi, không hỏi "Dễ quá/Khó quá".
- "Bị đau → Bỏ qua động tác" làm lướt qua màn **Đứng sau ghế** → giữ màn đó chờ người dùng.
- Nút Play ở màn khoá/tai nghe/xe hơi phát tiếp **sau lưng** màn Nghỉ, Bị đau, Đứng sau ghế → chỉ phát tiếp khi đang ở màn tập.
- Rút tai nghe: âm thanh dừng nhưng app vẫn hiện đang phát → chuyển sang "Đã tạm dừng".
- Dựng buổi tập lỗi thì GPS vẫn chạy ngầm → chỉ bật GPS/cảm biến sau khi dựng xong.
- Xong hành trình New York thì **mọi buổi sau** đều báo "hoàn thành" và mời mua Pro → chỉ một lần.
- Màn "Hai việc nhanh thôi" (quyền Health + lời nhắc) bị mất vĩnh viễn khi bấm "Tập lại", "Tập động tác ghế ngay" hay mở từ thông báo → xếp hàng chạy sau.
- Số ngồi–đứng của buổi trước bị cộng sang buổi sau; Quay lại thì mất số đã đếm → đếm theo từng buổi.
- Đi ngoài trời khi đang nghe podcast: nhạc app phát đè → tắt nhạc app trong trường hợp này.
- Màn **Đứng sau ghế** không có lối ra → thêm "✕ Kết thúc" và "Bỏ qua động tác này".
- Màn chuẩn bị ngoài trời không quay lại được → thêm "Đóng"; bấm "Dùng vị trí" giờ **chờ** người dùng trả lời hộp iOS (trước đây buổi đầu thường mất bản đồ).
- Me hiện "Nhắc đi bộ: bật" dù iPhone chặn thông báo → hiện "Lời nhắc đang tắt trên iPhone này · Bật trong Cài đặt"; "Bật lời nhắc" sau khi đã từ chối giờ mở Cài đặt. Tương tự với vị trí ngoài trời.
- Thẻ "Thời gian dùng thử đã kết thúc" hiện mãi mãi → 7 ngày.
- Thẻ sắp hết dùng thử: "Quản lý" chỉ chuyển tab → mở thẳng "Cách huỷ".
- Màn Bị đau và Nghỉ: thêm dòng an toàn "Đau ngực, choáng muốn ngất hay rất khó thở? Dừng ngay và gọi cấp cứu."

**Nhỏ**
- "Remind me later" bị xoá khi app lên lịch lại thông báo; lời nhắc lệch 1 giờ ngày đổi giờ mùa đông (1/11); người đang ân hạn thanh toán bị mất Pro; tranh chấp dữ liệu sau khi mua trọn đời; Skip/Back lúc đang dựng lại âm thanh làm lệch tiếng–hình; dựng lại lỗi thì im lặng.
- Cuộc gọi/Siri làm dừng mà không giải thích → lớp "Đã tạm dừng vì điện thoại đang bận việc khác" trên mọi player.
- Nghỉ giữa động tác ghế không có nút Kết thúc; hộp "Kết thúc buổi tập?" nói "đã lưu" dù chưa tới 1 phút; buổi đầu luôn ghi "Năm phút" dù dừng sớm.
- "Rest today" từ thông báo không hiện trên Today và có thể ghi sai ngày → Today hiện "Ngày nghỉ".
- Nút "Mở" bưu thiếp mới trên Complete không chạy → mở đúng bưu thiếp ở tab Hành trình.
- Điểm dừng khoá (Pro) bấm không phản hồi → mở gói Pro; người dùng miễn phí thấy thẻ "Tuần của bạn" với "Đổi với Pro".
- Hôm nay đã tập xong vẫn có link "Xem tất cả buổi tập"; bảng Âm thanh trong lúc tập có công tắc Phụ đề.
- Thanh hành trình trên Today chạy quá chặng miễn phí; thẻ Apple Health trên Today hiện trước buổi tập đầu / ngay sau khi vừa "Để sau".
- Xoá toàn bộ dữ liệu giờ báo "Đã xoá dữ liệu của bạn"; chọn ngôn ngữ chưa bỏ chọn được trước khi mở lại.
- Chụp màn `-xxl` trước đây không phóng to chữ → giờ đúng cỡ trợ năng; ở cỡ này icon cạnh tên buổi tập được ẩn để tiêu đề không vỡ từng chữ.

**Vòng rà soát thứ 2 (agent đối kháng soi chính các sửa đêm nay) — đã sửa thêm:**
- Đi về nhà → Bị đau → "Bỏ qua phần này" vẫn **crash** (đường mới mở ra sau lần sửa đầu) → không cho bỏ qua phần mở (ẩn nút), timeline không cắt vô cực + test Core.
- "Bỏ qua động tác này" ở màn Đứng sau ghế: vòng 2 của cùng tư thế đứng (giãn bắp chân) chạy luôn không có màn chờ → giữ màn cho vòng sau.
- "Remind me later" giữ lại được nhưng cũng phải tự huỷ khi đã tập/nghỉ/tắt nhắc → đã làm + test.
- Màn dừng vì đau vẫn mời "Tập lại", "Tập động tác ghế ngay", "Chia sẻ" → ẩn.
- Một chút âm thanh lọt sau màn Đứng sau ghế khi rời màn Bị đau → Bị đau không tự phát tiếp nữa, phiên tập quyết định.
- Màn mời Pro khi xong New York bị ghi đè bởi "Tập động tác ghế ngay" → xếp hàng.
- Ghi chú "Vị trí đang tắt" không cập nhật sau khi từ chối; ngôn ngữ chọn trong Cài đặt iOS hiển thị sai trong Me; ngày nghỉ (Rest today) trong lúc "khởi động lại nhẹ nhàng"; hộp Kết thúc và luật lưu lệch nhau ở giây 59,5; cổng phát hành chặn bản tiếng Anh vì tiếng Việt chưa có giọng → đều đã sửa.
- Thêm test: Bỏ qua/Kết thúc ở màn Đứng sau ghế, nút Play từ xa sau màn Nghỉ, nhắc lại sau.

**Kiểm tra tay trên simulator:** iPhone đặt tiếng Việt → app vẫn mở tiếng Anh (mặc định đúng), cả lần mở thứ hai. Me → Language → Tiếng Việt → hộp nhắc bằng tiếng Việt → mở lại app → toàn bộ tiếng Việt. Light/Dark/Auto chuyển qua lại đúng.

**Kết quả cuối:** test app 160/160 đạt (1 lỗi đã biết của iOS 27 như trước), Core 152/152, copy lint 0, catalog 649/649 có bản Việt, máy quét chữ sót = 0. Ảnh: 88 màn tiếng Việt + 94 màn tiếng Anh đã soát bằng mắt.

**Giữ nguyên có chủ ý:** "Xoá toàn bộ dữ liệu" không đổi ngôn ngữ đã chọn (là cài đặt của máy, không phải dữ liệu tập).

## 3. Chưa làm — cần chủ app quyết
1. **Giọng tiếng Việt:** nghe 2 mẫu, chọn giọng; chờ 21/10 (reset ký tự) hay bật trả thêm để tạo ngay ~35.000 ký tự.
2. **"Chưa" ở Up next:** người chọn "Chưa" chưa được hỏi giờ nhắc (lời nhắc chỉ hỏi sau buổi đầu) → có thêm "Nhắc tôi ngày mai?" không.
3. **Đi bộ không có nút Bỏ qua** (cố ý vì đi theo lượt?) → hiện người mệt phải dùng "Bị đau → Bỏ qua phần này", và việc đó ghi thành báo đau.
4. **Đứng sau ghế dừng giọng HLV** tới khi bấm Sẵn sàng → với điện thoại trong túi, người dùng không biết đang chờ. Có tự đi tiếp sau ~8 giây không (đổi luật an toàn hiện tại)?
5. Tiếng Việt: dùng "dặm" (theo tuyến Mỹ) hay đổi sang km cho người dùng tiếng Việt?
