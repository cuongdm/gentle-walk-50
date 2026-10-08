# Tổng hợp nghiên cứu 08/10/2026: màn hình, onboarding, font, cá nhân hoá

Ba báo cáo chi tiết (Fable nghiên cứu, chưa sửa code):
- UI/UX + onboarding mới: [ui-ux-va-onboarding.md](ui-ux-va-onboarding.md) · mockup [onboarding-mockups.html](onboarding-mockups.html), ảnh `mockups/` (13 màn × iPhone SE / iPhone 11)
- Font + hình ảnh: [font-va-hinh-anh.md](font-va-hinh-anh.md) · ảnh mẫu font Apple thật `spec-system-light.png`, `spec-system-dark.png`
- Cá nhân hoá: [../../research/2026-10-08-ca-nhan-hoa.md](../../research/2026-10-08-ca-nhan-hoa.md)
- Bằng chứng: 50 ảnh chụp iPhone 11 trong `ip11/`

## 1. Kết luận chính
1. **Tràn màn hình:** 21/50 màn phải cuộn trên iPhone 11, 31/50 trên iPhone SE. Nặng nhất: onboarding goal và barriers giấu nút Continue dưới mép; màn body giấu "I feel unsteady on my feet" và "None of these" dưới thanh nút (lựa chọn an toàn bị khuất).
2. **Onboarding không đều:** Continue lúc ghim đáy, lúc nằm trong danh sách; câu HLV mọc dưới đẩy nút đi; mỗi màn 25–110 chữ.
3. **Font:** giữ font hệ thống Apple (đủ dấu tiếng Việt, không lỗi, tự co theo cỡ chữ). Đổi duy nhất: chữ thường từ SF Pro Rounded sang **SF Pro** (nét sắc hơn ở cỡ nhỏ); Rounded chỉ cho số (đồng hồ, số lần); tiêu đề giữ New York. Atkinson Hyperlegible và nhiều font "dễ đọc" khác **không có tiếng Việt**.
4. **Cá nhân hoá ~2,5/5:** chỉ giới hạn cơ thể và câu "How do your joints feel" thật sự đổi buổi tập. Mục tiêu, trở ngại, mức vận động, Easier/Harder, tự kiểm tra, bước chân được lưu nhưng **bỏ phí**. 7 câu HLV đã thu (`a9.*`) không được phát ở đâu.
5. **Lỗi thật (đã kiểm code):** "How did that feel?" tính theo cấp khởi đầu lúc onboarding (`TodayModel.swift:140`, `Adaptation.swift:45`). Sau khi lên cấp, các câu "Too hard" bị bỏ qua nên không bao giờ hạ cấp lại được; lúc lên cấp Today cũng không báo. Lời hứa "adjust after every session" chưa đúng.

## 2. Đề xuất theo thứ tự làm
| Đợt | Việc | Cỡ |
|---|---|---|
| 0 (sửa lỗi) | Sửa vòng "How did that feel?" (lên và xuống cấp đúng, thẻ báo lên cấp) | S |
| 1 (không tràn) | Khung onboarding chung + nút ghim đáy; paywall vừa SE; tách màn xin quyền thành 2; Self-check intro, Welcome, Preview, Phone placement, Outdoor prep vừa SE | M–L |
| 1 (font, màu, cỡ) | Chữ thường sang SF Pro; caption 15 → 16 pt; nút chính 60 → 64 pt; `secondary` đậm hơn khi có chữ trắng (4,6:1 sát ngưỡng) | S |
| 2 (onboarding mới) | 7 bước + Welcome + Plan (9 màn), tiêu đề ≤ 8 chữ, gợi ý ≤ 15 chữ, "Hear your coach · 10 seconds" trên thẻ Day 1 trước paywall, paywall nói lại mục tiêu | L |
| 3 (cá nhân hoá) | P1 phát 7 câu HLV đã thu theo tình trạng ngày · P4 nhắc lại mục tiêu trên Today/Complete/Progress · P5 nhớ Easier/Harder · P3 nhớ bài làm đau · P6 check-in tuần · P8 màn "Kết quả của bạn" · P7 câu HLV theo lịch sử (cần thu ~10 khung câu) | S–M mỗi việc |

## 3. Quyết định chủ app cần chốt
1. Font: phương án A1 (SF Pro chữ, SF Pro Rounded số, New York tiêu đề) hay giữ nguyên, hay bộ thương hiệu Literata + Nunito Sans.
2. Bốn thay đổi onboarding đổi quyết định cũ: chọn 1 mục tiêu; bỏ màn "You're not alone" (câu đó thành lời HLV đáp); bỏ câu "How active are you now?" (cấp khởi đầu tính từ câu đứng lên từ ghế + giới hạn cơ thể); tách màn cơ thể thành 2.
3. Paywall: giữ trong onboarding (thêm nghe HLV 10 giây trước) hay dời sau buổi tập đầu.
4. Thứ tự làm và phạm vi đợt đầu.

Các câu hỏi phụ còn lại nằm ở mục cuối từng báo cáo.
