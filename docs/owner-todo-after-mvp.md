# Việc chủ app cần làm sau khi code xong MVP
_Cập nhật 29/09/2026, sau khi code xong Milestone 1–9. Mỗi mục ghi việc gì, vì sao, làm ở đâu. Xong mục nào thì đánh dấu._

## 1. Kiểm trên iPhone thật (simulator không làm được)
Cài bản DEBUG từ Xcode lên iPhone (cần Team ID đúng, xem mục 3).
- [ ] **3.5 Khoá màn hình:** bắt đầu First Walk, khoá màn hình, để túi 5 phút, nhạc tắt. Mở Console trên Mac hoặc chạy lệnh dưới: đủ 30 câu và 7 chuông, lệch ≤ 0.5 s. Ghi thêm: khoá màn hình có còn rung không.
  ```bash
  log stream --device --predicate 'subsystem == "com.kmd.gentlewalk" AND category == "cue"'
  ```
- [ ] **3.6 Rung khi đổi pha:** hai nhịp rung khi màn hình đang mở.
- [ ] **3.7 Màn khoá:** hiện "Gentle Walk · First walk"; bấm Pause/Play trên màn khoá; mở lại app vẫn đúng chỗ.
- [ ] **4.7 Toàn màn hình ngang:** ở động tác ghế, xoay ngang: nút Exit, bộ đếm, phụ đề, Break và This hurts đều thấy.
- [ ] **4.13 Chạy tay trọn luồng lần đầu ở chế độ máy bay:** Welcome → câu hỏi → Your plan → paywall → Maybe later → Phone placement → First Walk → Complete → Two quick things → Today.
- [ ] **6.7 Apple Health:** sau buổi tập, workout hiện trong app Health (đi bộ trong nhà có nhãn indoor).
- [ ] **8.6 Đi ngoài trời 10 phút:** chọn Outdoors → Use my location; sau buổi, tuyến hiện trên Complete và trong app Health.
- [ ] **8.8 Ghi dữ liệu ngồi–đứng:** áp điện thoại lên ngực, làm 10 lần đúng, 10 lần dùng tay đẩy, 1 phút ngồi yên. Việc còn lại của tôi: làm màn ghi CSV (DEBUG) rồi chỉnh ngưỡng bộ dò theo dữ liệu thật.
- [ ] **8.9 Counted for you:** chọn "Held to my chest", làm Sit-to-stand 10 lần, số đếm lệch ≤ 1.
- [ ] **7.10 Bốn mẫu thông báo trên màn khoá:** nhắc tập có nút Start walk / Rest today, gần địa danh, tổng kết tuần, hết trial.

## 2. Tài nguyên còn là bản tạm (`docs/release/1.0/asset-checklist.md`)
- [ ] **Giọng:** 40/247 câu có file, gói ElevenLabs Free (chỉ dùng prototype). Cần gói thương mại cho đủ 247 câu. Bản DEBUG tự đọc câu thiếu bằng giọng hệ thống; bản nộp store bị chặn nếu còn thiếu.
- [ ] **Clip giãn cơ V7-1 … V7-7:** chưa có, player hiện ảnh giữ chỗ.
- [ ] **Chuông:** `App/Resources/Media/Sounds/bell-phase.m4a`, `bell-done.m4a` là âm sine tạo bằng ffmpeg.
- [ ] **Tranh minh hoạ:** mọi tranh đang là khung màu + biểu tượng hệ thống (Welcome, player đi bộ, Break, bưu thiếp, bản đồ, cây).
- [ ] **App icon — chặn nộp store:** icon tạm vẽ từ SF Symbol. Giấy phép SF Symbols không cho dùng trong icon app. Cần icon thiết kế riêng.
- [ ] **Nhạc:** đã đưa 3 bài thử Lyria 3.5 vào app (đi bộ, động tác ghế, giãn cơ). Cần xác nhận giấy phép dùng thương mại, hoặc thay nhạc khác: đặt file `<tên>-walk.mp3`, `-seated.mp3`, `-stretch.mp3` vào một thư mục trong `assets/music/` rồi chạy `python3 tools/music/build_music.py --source <thư mục>`. Tên phong cách đang tạm là "Feel-good 70s and 80s"; nghe thử rồi báo tôi tên đúng.
- Kiểm tất cả bằng cổng release (đang RED đúng như dự kiến):
  ```bash
  TEST_RUNNER_RELEASE_CHECK=1 xcodebuild test -project GentleWalk.xcodeproj -scheme GentleWalk -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:GentleWalkTests/ReleaseContentTests
  ```

## 3. Quyết định và thông tin chờ chủ app
- [ ] **Team ID** `55V8Y3PCLY` trong `Config/Local.xcconfig` (lấy từ chứng chỉ Distribution trên máy): xác nhận đúng team.
- [ ] **Email hỗ trợ:** trang Privacy có chỗ `[support email]`; app chưa có nút Contact us vì chưa có địa chỉ.
- [ ] **Trang Privacy:** điền ngày, email trong `site/privacy.html`, đăng lên hosting (mặc định GitHub Pages từ thư mục `site/`), rồi gửi tôi URL để gắn vào app và checklist.
- [ ] **Terms:** đang dùng EULA chuẩn của Apple (mặc định của task 5.10). Nếu muốn Terms riêng, báo tôi.
- [ ] **App Store Connect:** làm theo `docs/release/1.0/checklist.md` (3 IAP, age rating, App Privacy, review notes).
- [ ] **Tên app trên store** (backlog M11): đang dùng tên làm việc "Gentle Walk".

## 4. Quyết định nhỏ tôi đã tự chốt khi code (xem, đổi được)
- Walk dài ngày thứ Sáu = thêm một vòng nhanh + chậm (Steady 8 → 10 phút).
- Giãn cơ giữ 10/20/30 giây theo cường độ (A10 §3), plan cũ ghi cố định 20 giây.
- App không bao giờ tự chuyển người dùng lên Walking pad.
- Sit-to-stand mục tiêu hiển thị "10 reps" mọi cường độ.
- Ảnh chia sẻ ghi "… on the way to Brooklyn Bridge" (không dùng "her").
- Không có nhạc thì chương trình âm thanh kết thúc ở câu cuối, không thêm đoạn im lặng (2.5.4).
- Thông báo "quay lại" đếm theo ngày kế hoạch, bỏ ngày nghỉ (vì màn S16 hứa "never on rest days"): buổi cuối thứ Năm → nhắc lại thứ Ba và thứ Năm tuần sau nữa.
- Tổng kết tuần bỏ qua tuần không có buổi nào (không bao giờ gửi "0 active days").
- "Remind me later" ở màn xem trước = một nhắc sau 2 giờ, chỉ trong khung 8:00–20:00.
- Extras: "Commercial break walk" dài 5 phút (spec ghi 3 phút, nhưng buổi đi bộ ngắn nhất là 5 phút).
- Cuối danh sách hành trình ghi "Coming next: Route 66" (hàng chờ trong content-plan).
- Thẻ sau buổi ngoài trời "Your chair moves for today · 4 min" là số cố định.
- Nhạc luôn có trong chương trình âm thanh; nút Music trong buổi đi bộ tắt/bật ngay, Me → Music đặt trạng thái lúc bắt đầu. Mỗi loại buổi có bài riêng.
- Paywall ở cỡ chữ thường: nút, điều khoản, Restore · Terms · Privacy ghim dưới đáy (thấy ngay trên iPhone SE); cỡ chữ rất lớn thì cuộn cùng trang.

## 5. Môi trường
- [ ] Khi lên Xcode 27: sửa dòng "Xcode 27 / SDK 27" trong `CLAUDE.md` nếu bản cài khác; build lại và chạy toàn bộ test.
- [ ] Mở dự án bằng Xcode một lần để String Catalog tự thêm chữ mới (build dòng lệnh không ghi lại catalog; tiếng Anh vẫn hiện đúng vì chữ nguồn là chữ hiển thị).
- Tôi đã tạo máy ảo "Gentle SE" (iPhone SE 3rd gen) để kiểm màn nhỏ. Xoá được trong Xcode → Devices and Simulators nếu không cần.
