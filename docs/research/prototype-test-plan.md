# Kế hoạch test prototype — Good Footing (một trang)
_28/09/2026, sửa 29/09/2026 · Bước 4 trong docs/content-plan.md §8 · **Thời điểm (chốt 29/09/2026): sau khi code hết MVP với asset tạm, trước khi sản xuất asset thật**; mẫu thử M1–M3 chạy trên bản build TestFlight thay vì file rời khi có. Mục tiêu: trả lời 4 câu hỏi mở ở docs/idea/gentle-walk-voice.md §12._

## Câu hỏi cần trả lời
1. Chỉ **giọng + tranh tĩnh** có đủ cho người quen xem video không, hay cần clip?
2. **Giọng** nào (Bella hay ứng viên khác), nhịp 8–10 giây mỗi câu có vội không, "heel taps" có hiểu khi chỉ nghe không?
3. **Giãn cơ dẫn bằng giọng** có theo được mà không nhìn màn hình không (tư thế, đổi bên, thở)?
4. **Nhân vật** trông giống họ không; muốn đi hành trình nào sau New York; có dùng tai nghe khi đi ngoài trời không?
5. **Tên app** (thêm 03/10/2026; 07/10 chủ app đã chốt **Good Footing**, Kind Pace giữ làm đối chứng): trước khi cho xem phụ đề, đọc to "Good Footing" và hỏi *"Just from the name, what do you think this app helps you do?"*; rồi đọc to 2 tên (đổi thứ tự giữa các người tham gia), hỏi tên nào nghe như app dành cho mình, tên nào nghe như app cho "người già". Đạt khi đa số trả lời kiểu "balance / feel steady / get started again"; nếu ≥ 3/8 nghĩ tới chăm sóc bàn chân, chỉ đi bộ, hoặc "app cho người già" thì xem lại tên trước khi nộp đơn nhãn hiệu.

## Người tham gia
- 6–8 phụ nữ Mỹ **58–75 tuổi** (khách mục tiêu đổi 03/10/2026; ít nhất 3 người 65+, tối đa 1 người 50–57 để so sánh), tự nhận là mới hoặc đã bỏ tập lâu, có đau gối/hông/lưng hoặc thừa cân; không tuyển người tập gym hay chạy bộ. Ưu tiên 2–3 người đang hoặc từng dùng WalkFit, LazyFit, Walk at Home, Leslie Sansone trên YouTube.
- Tuyển qua UserInterviews.com hoặc Respondent (lọc tuổi, giới, bang), dự phòng nhóm Facebook đi bộ cho phụ nữ 50+. Thù lao theo mức thường của nền tảng; không ghi số trong tài liệu.
- Không thu dữ liệu sức khoẻ ngoài câu tự kể; có đồng ý ghi hình; xoá bản ghi sau 90 ngày.

## Mẫu thử (chuẩn bị trước)
| Mẫu | Nội dung | Có sẵn chưa |
|---|---|---|
| M1 Giọng + tranh | First Walk 5 phút (A1) đọc bằng ElevenLabs Bella, màn player tĩnh S11 dạng ảnh, một bưu thiếp Central Park Zoo | A1 có, TTS chưa dựng thành file 5 phút, tranh chưa có (dùng tranh mẫu tạm) |
| M2 Giọng + video | `assets/video/V1-1/V1-1_preview.mp4` và `V2-1_preview.mp4` (Sit-to-stand, Seated knee lift) | Có |
| M3 Giãn cơ theo giọng | 2 tư thế từ A10 (đùi sau ngồi, cổ–vai) chỉ có giọng, không video | Chưa, viết cùng A10 |
| M4 Nhân vật | 3 ảnh: nhân vật chính hiện tại, nhân vật đề xuất (55–58, đầy đặn), khung hình GWCoach từ clip | 2 trong 3 có |
| M5 Hành trình | Danh sách 5 tuyến + 3 tuyến chờ (Route 66, Amalfi, Grand Canyon) | Có trong spec |
| M6 Paywall | Mockup S08 dạng ảnh, số tiền để chỗ trống | Chưa vẽ |

## Buổi test (40 phút, qua video call, người tham gia ngồi trên ghế ăn ở nhà)
| Phút | Việc | Ghi nhận |
|---|---|---|
| 0–5 | Hỏi thói quen hiện tại, app đã bỏ và lý do | câu chữ họ dùng về tiền và về "quá nhanh" |
| 5–12 | **M1**: điện thoại úp trên bàn, làm theo giọng 5 phút | có làm được heel taps và marching không; mấy lần nhìn màn hình; câu nào khó hiểu |
| 12–18 | **M2**: xem preview V1-1 và làm theo 3 lần; hỏi "video có cần không, hay chỉ nghe là đủ?" | thích M1 hay M2; tay có với ghế khi ngồi không |
| 18–24 | **M3**: giãn cơ 2 tư thế chỉ nghe | có vào đúng tư thế không; đổi bên có rối không; có nín thở không |
| 24–30 | **M4 + M5**: chọn nhân vật giống mình nhất, chọn tuyến muốn đi tiếp | thứ tự chọn |
| 30–36 | **M6**: đọc paywall, kể lại "khi nào bị trừ tiền, huỷ thế nào" | kể đúng ngày và cách huỷ không |
| 36–40 | Hỏi: "Ngày mai có mở lại không, vì sao?"; tai nghe khi đi ngoài trời | lý do quay lại |

## Tiêu chí đạt (ghi trước, không đổi sau khi test)
| Câu hỏi | Đạt khi |
|---|---|
| 1 Giọng + tranh đủ | ≥ 5/8 làm trọn M1 mà nhìn màn hình ≤ 2 lần và nói không cần video cho đi bộ; nếu < 5, video vào cả player đi bộ |
| 2 Giọng | ≥ 6/8 hiểu "heel taps" ngay; ≤ 2 người nói "quá nhanh"; nếu ≥ 3 người nói vội thì kéo khoảng im lên 12 giây |
| 3 Giãn cơ | ≥ 6/8 vào đúng tư thế và đổi bên đúng chỉ bằng giọng; nếu không, giãn cơ dùng video từ đầu và câu "đổi bên" có chuông riêng |
| 4 Nhân vật | nhân vật đề xuất được chọn "giống tôi" ≥ 5/8; tuyến được chọn nhiều nhất làm tuyến trả phí đầu tiên |
| Paywall | ≥ 7/8 kể đúng ngày trừ tiền và cách huỷ; nếu không, sửa S08 trước khi code |

## Đầu ra
- `docs/research/prototype-test-results.md`: bảng 8 người × 5 tiêu chí, trích lời nguyên văn, quyết định cho từng câu hỏi.
- Ghi quyết định vào decisions log của app-context.md và câu hỏi mở của brief.
