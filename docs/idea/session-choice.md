# Ý tưởng: Chọn lại buổi · tập môn khác (session-choice)
_Ngày: 29/09/2026 · Mode: Feature · Stage: manh-skill-idea_

## 1. Ý tưởng một câu
Người dùng đổi được buổi hôm nay sang môn khác (vẫn tính ngày), xem được mọi buổi theo nhóm, đánh dấu yêu thích và tập lại, mà không thêm tab.

## 2. Vấn đề · Người dùng · "Aha"
- Vấn đề: hôm mệt hoặc đau, buổi theo kế hoạch không hợp; hiện chỉ đổi được nơi tập, mức ngồi/tại chỗ và từng động tác ghế, không đổi được cả buổi.
- Người dùng: phụ nữ Mỹ 50–64 mới tập (app-context). Đối thủ cho chọn thoải mái, nhưng người dùng chê lặp lại và không thay được bài (§4).
- Aha: bấm "Try something else" trên Today → chọn "Gentle stretch" → tập xong, ngày vẫn tính, cây vẫn lớn.

## 3. Kết luận: GO — lý do duy nhất
"Lặp lại, không đổi được bài" là lời chê lặp lại trong review nhóm app lười tập / ghế, và Gentle Walk đã có đủ buổi (đi bộ, ghế, giãn cơ, extras) để cho chọn mà không cần làm thêm nội dung.

## 4. Bảng bằng chứng
| # | Nhận định | Nguồn | Ngày xem | Độ tin cậy | Ảnh hưởng |
|---|---|---|---|---|---|
| 1 | LazyFit có tab Library riêng: chương trình 28 ngày, chip loại bài, Focus Area, ~15 hàng bài; thẻ có phút + kcal + tim | Video quay app của chủ app (`~/Downloads/IMG_2132.MP4`, 2:46) + ảnh chụp Library | 29/09/2026 | High | mẫu cấu trúc |
| 2 | Chi tiết bài: danh sách động tác 30 s, Start, "Measure Heart Rate"; player 3-2-1-GO, Get Ready, 👍👎 từng động tác; thoát giữa chừng "Just 22 exercises left" | cùng video | 29/09/2026 | High | lấy/không lấy (§11) |
| 3 | Khen đa dạng: "Love Variety… every day is new exercises"; "Love all the options and choices… make it harder or easier" | radar-research, review App Store US LazyFit 5★ (DB lấy 28/09/2026) | 29/09/2026 | Medium | hỗ trợ GO |
| 4 | Chê lặp lại: LazyFit "exercises are repetitive at each level"; JustFit 1★ "same exercises repeated again and again"; FitMe 2★ "repeating and I'm not able to choose another one to replace it" | radar-research, review App Store US | 29/09/2026 | Medium | lý do GO |
| 5 | Chê bài không hợp cơ thể: JustFit 3★ bệnh tự miễn, không chịu lực gối/cổ tay, "1st day was a lot of squatting" | radar-research | 29/09/2026 | Medium | giữ lọc giới hạn cơ thể cho buổi tự chọn |
| 6 | Bỏ một buổi gần như không ảnh hưởng hình thành thói quen; tự thông cảm giúp quay lại | brief gentle-walk-voice §4 dòng 20 | 27/09/2026 | High | đổi buổi nhẹ vẫn tính ngày |

## 5. Bảng đối thủ
Giữ bảng ở [gentle-walk-voice.md §5](gentle-walk-voice.md) (LazyFit, ChillFit, WalkFit…); lần này chỉ thêm quan sát Library của LazyFit (§4 dòng 1–2).

## 6. Bão hoà & rủi ro portfolio
Không đổi so với brief gốc: tính năng trong app, không tạo app mới.

## 7. Trụ cột
- Đổi buổi mà vẫn tính ngày: đúng · thấy ngay trên Today · reviewer thấy không cần login.
- Tất cả buổi theo 4 nhóm có tranh: đúng · thấy từ Extras → See all · không cần login.
- ~~Thư viện lớn như LazyFit~~: trái hướng "ít lựa chọn cho người mới", bỏ.

## 8. Mô hình giá
Miễn phí: mọi buổi đi bộ (ngồi và tại chỗ) + 1 buổi ghế + 1 buổi giãn cơ mẫu. Pro: toàn bộ All sessions, yêu thích, tập lại buổi Pro. Không đổi trial/giá.

## 9. Vòng lặp hành vi
Đường phục hồi: ngày mệt đổi sang "Just 5 minutes today" hoặc giãn cơ ngồi vẫn giữ ngày hoạt động và cây. Không streak, không phạt.

## 10. Rủi ro nền tảng
Không quyền mới, không backend. Không kcal, không đo nhịp tim bằng camera (1.4.1). Yêu thích lưu UserDefaults, thêm vào danh sách xoá của "Delete all my data".

## 11. Phiên bản nhỏ nhất
1. Today: "Try something else" trên thẻ buổi hôm nay → bảng 4 lựa chọn (Walk, Chair moves, Gentle stretch, Just 5 minutes today); chọn là thay buổi hôm nay, vẫn tính ngày, cây và dặm.
2. Extras → "See all" → màn All sessions: Walks · Chair moves · Stretches · Short extras, mỗi nhóm ≤ ~6 thẻ; thẻ có tranh, tên, phút, mức độ; áp dụng lọc giới hạn cơ thể.
3. Yêu thích (tim) + hàng "Your favourites" đầu All sessions + "Do it again" ở Complete.
4. Chia free/Pro như §8.
- Hoãn: đổi trọng tâm kế hoạch trong Me; "Don't show this move again"; tab Library riêng; kcal; đo nhịp tim; Focus Area; Kegel, Wall Pilates, bài trên giường; meal plan.

## 12. Câu hỏi mở
- Khi đổi buổi, lịch tuần có dời loại buổi bị bỏ sang ngày khác không? (Bản đầu: không dời.)
- Đổi trọng tâm kế hoạch, bỏ động tác vĩnh viễn: làm ở đợt sau?

## 13. Dòng ghi vào decisions log
- 29/09/2026 — GO "session-choice" (docs/idea/session-choice.md): đổi buổi hôm nay trên Today (vẫn tính ngày), Extras → See all mở All sessions 4 nhóm, yêu thích + tập lại; giữ 4 tab; free = đi bộ + 1 ghế + 1 giãn cơ mẫu; không kcal, không đo nhịp tim, không Focus Area.
