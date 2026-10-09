# Review toàn app vòng 2 — tóm tắt (09/10/2026)

_Chỉ đọc, không sửa mã. Nhánh `cloud/review-round2` từ `mac/integration` 97aaa71. Chi tiết, `file:dòng` và cách sửa: `lens-1-code.md` … `lens-6-perf.md` (tiếng Anh)._
_Baseline: core `swift test` **307/307 xanh**; app **không build, không chạy test** (không có Xcode); UI xét từ code + ảnh Pro Max có sẵn, **chưa có ảnh iPhone SE** của các màn mới. Ngôn ngữ: coverage en/vi 0 thiếu, `apply_catalog --check` 1089/1089, `copy_lint` 0._

**Tổng: 1 Critical · 21 Important · 39 Minor.** Cổng sang release: **chưa qua**.

| # | Lăng kính | Kết luận | Phát hiện |
|---|---|---|---|
| 1 | Code | Fail | C1, I1–I5, M1–M10 |
| 2 | UI/UX | Fail | I6–I19, M11–M26 |
| 3 | Ngôn ngữ | Pass with notes | M27–M33 |
| 4 | Pháp lý | Fail (chờ chủ app) | I20 |
| 5 | Riêng tư/bảo mật | Pass with notes | M34–M35 + danh sách repo public |
| 6 | Hiệu năng | Fail (chờ đo máy thật) | I21, M36–M39 |

## Critical
- **C1 — Nút "Tiếp tục từ tuần N" không biến mất sau khi bấm.** Nó đổi sang tuần sớm hơn. Mỗi lần bấm thêm: kế hoạch lùi lại, thêm một kỳ nghỉ trùng, hai thang Pro (số lần, bậc vịn) hạ thêm một bậc. Thẻ "Stage N is done" bị giữ lại tới khi hết hạn 7 ngày. (`TodayModel.swift:203`, `ProgramCalendar.swift:51`, `AppModel+Program.swift:80`)

## Important (gọn)
- **Tiền và dùng thử:**
  - I1: thông báo nhắc ngày 12 có thể mất, khi mở app lúc offline hoặc khi "Xoá dữ liệu" trong lúc dùng thử.
  - I2: đã huỷ dùng thử mà Today và Me vẫn ghi "You'll be billed $49.99".
  - I20 (pháp lý 3.1.2(c), *likely*): paywall không nói Pro có gì. Tiêu đề "Your 12 weeks…" lại nói về chương trình vốn miễn phí.
- **Today:**
  - I3: câu trả lời Achy/Okay/Great tự quay về mặc định mỗi lần app `reload()`.
  - I8: thẻ giai đoạn đè thẻ "đã tạm gác bài đau". Thẻ tạm gác chỉ sống 3 ngày nên có thể mất hẳn.
  - I21: mỗi lần vẽ Today dựng ~22 kế hoạch buổi tập (*likely*, cần đo).
- **Kế hoạch 12 tuần:**
  - I4: bắt đầu vòng mới vẫn hiện dấu tự kiểm tra của vòng cũ.
  - I5: màn kết thúc so lần đầu với lần mới dù khác cách (có/không vịn tay).
- **Dài và thừa chỗ:**
  - I6: màn Kế hoạch dài ~4,5 màn SE ở tuần 10–12.
  - I7: thẻ "Stage N is done" trên Today cao ~500 pt trên SE.
  - I11: player trên iPad đứng để trống 350–430 pt.
- **Kẹt hoặc lặp:**
  - I9: màn "Plans aren't available" không cuộn ở cỡ chữ lớn nhất.
  - I10: gói lỗi vẫn được chọn sau "This plan isn't available".
  - I14: "Connect Apple Health" không làm gì sau khi đã từ chối.
  - I15: chọn ngày nghỉ thứ ba không phản hồi.
- **Hiển thị:**
  - I12: cả app xoay ngang trên iPhone, không chỉ player.
  - I13: nút A+ có thể làm chữ nhỏ đi.
  - I16: công tắc chỉ bấm được ô 51×31 pt.
  - I17: sửa tiêu đề màn ở vòng 1 chưa xong ("Acknowled/gements").
  - I18: màn kết thúc tự kiểm tra tràn ở cỡ chữ lớn nhất.
  - I19: chữ xanh trên nền tối chỉ đạt 2,9–3,2:1.

## Thứ tự sửa đề xuất
1. C1, kèm test "nút biến mất sau khi bấm".
2. Nhóm tiền: I1, I2, I20 (I20 cần chủ app duyệt câu chữ).
3. Logic Today và Kế hoạch: I3, I8, I4, I5.
4. Paywall ở các trường hợp lỗi: I9, I10, M1, M3.
5. Bố cục:
   - I6, I7 (rút gọn tóm tắt giai đoạn);
   - I12 (khoá dọc);
   - I17, I18, I19, I16, I13, I14, I15;
   - I11 (iPad).
6. I21 và M36 (tính một lần trong `init`), rồi đo trên máy thật.
7. Minor theo từng lăng kính. Sau mỗi nhóm: build, test, chụp lại trên SE.

## Chủ app cần tự kiểm tra
- **App Store Connect:**
  - Gắn nhóm subscription và 3 IAP vào bản 1.0. Thiếu thì reviewer thấy "Plans aren't available" và bị trả theo 2.1.
  - Privacy URL.
  - Nhãn App Privacy (câu hỏi IDFV đang chờ quyết).
  - Bậc tuổi, review notes kèm số điện thoại.
- **iPhone thật (Sandbox, tài khoản Mỹ):**
  - Dùng thử: tắt mạng rồi mở app và xem thông báo đã lên lịch (I1). Huỷ dùng thử rồi xem Today và Me (I2).
  - Ask to Buy (M3).
  - Restore khi huỷ đăng nhập (M2).
  - Xoay ngang (I12).
  - Bấm chữ cạnh công tắc (I16).
  - Health sau khi đã từ chối (I14).
  - Đo thời gian trên iPhone đời cũ nhất (I21).
- **Ảnh SE (sáng và XXL):**
  - 4 màn tóm tắt giai đoạn, thẻ kết quả, các trạng thái paywall.
  - Bản tiếng Việt của 4 màn giai đoạn.
  - Màn kết thúc tự kiểm tra.
- **Repo đang public:**
  - Nghiên cứu doanh thu và quảng cáo, dữ liệu đối thủ.
  - Toàn bộ giọng, video, nhạc, kịch bản. Bộ giọng ElevenLabs gói Free không dùng thương mại.
  - Tên pháp lý, email cá nhân.
  - Xem lens 5. Lưu ý: GitHub Pages trên repo private cần gói trả phí.

## Điều tốt
- RevenueCat nằm gọn sau `PurchaseBackend`. Luật quyền Pro ở core, có test. Khoá chỉ lấy từ xcconfig, lịch sử git không lộ khoá. Manifest khớp với SDK.
- Paywall đủ bộ ba, giá bị trừ nổi nhất. Số ngày dùng thử đọc từ cửa hàng. Lỗi mua giờ nói đúng lý do.
- `StageRecaps` tính ngày theo lịch (an toàn với giờ mùa hè), không bịa số, không nêu điểm dừng ngoài chặng miễn phí. "Xoá dữ liệu" xoá cả dữ liệu giai đoạn.
- Chuỗi mới đủ tiếng Việt, đúng thuật ngữ. Không có câu y khoa.

## Câu hỏi chưa giải quyết
- Thẻ giai đoạn đặt trước thẻ "tạm gác" là chủ app chốt hay mặc định của kế hoạch (I8)?
- Có cho xoay ngang ngoài player không (I12)? A+ tăng theo cỡ chữ iPhone hay ẩn khi chữ đã to (I13)?
- Ngôn ngữ đã chọn có giữ lại sau "Xoá dữ liệu" không (M9)? Pro được chọn 0–1 ngày nghỉ không (M29)?
- Handoff yêu cầu báo cáo ngắn trong `docs/handoff/`. Lần này chỉ ghi trong thư mục review (theo giới hạn được giao), nên file này thay cho báo cáo đó.
