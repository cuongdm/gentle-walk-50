# Câu được nói và không được nói — chương trình vững chân

_08/10/2026 · Task 1.2 của [plans/2026-10-08-steady-program.md](../plans/2026-10-08-steady-program.md). Áp dụng cho chữ trong app, lời HLV, thông báo, store, quảng cáo, site. **Chưa có luật sư duyệt**: đưa luật sư nhãn hiệu xem bảng này cùng lúc với tên app._

Nguồn của mức rủi ro:
- [reports/Chọn ngách cho Good Footing.md](../../reports/Chọn%20ngách%20cho%20Good%20Footing.md), mục 7 (bảng mức rủi ro cụm từ).
- [research_notes/Chọn ngách cho Good Footing/feasibility_risk_codefit.md](../../research_notes/Chọn%20ngách%20cho%20Good%20Footing/feasibility_risk_codefit.md): App Review 1.4.1, FDA General Wellness (bản 06/01/2026), FTC, Sway 510(k), LIFTMOR.

Phần lớn nguồn gốc đọc qua đoạn trích tìm kiếm, chưa mở toàn văn (xem mục "Giới hạn" của báo cáo).

`tools/lint/copy_lint.py` chặn tự động các cụm ở cột "Không nói" (Task 1.1).

## Bảng

| Được nói (rủi ro thấp) | Không nói (rủi ro cao) | Vì sao |
|---|---|---|
| Steadier on your feet | Fall prevention · prevents falls | Hứa phòng ngã là claim y khoa; app đánh giá nguy cơ ngã thuộc thiết bị FDA (Sway 510(k) K121590) |
| Get up from a chair more easily | Reduce / lower your fall risk | Như trên; FTC đòi bằng chứng thử nghiệm trên chính sản phẩm |
| Stronger legs, at your own pace | Build bone · bone density · reverse osteoporosis | Bài nhẹ tại nhà là loại bài của nhóm đối chứng LIFTMOR, nên hứa xây xương là sai sự thật |
| Balance moves with a chair beside you | Relieves / reduces knee pain · pain relief | Claim điều trị (1.4.1) |
| Looser, less stiff | Fix your posture | Claim kết quả lâm sàng |
| You compare only with yourself | Below normal for your age · your score · risk level | Bảng chuẩn và nhãn nguy cơ đưa app vào vùng "health measurement" của 1.4.1 |
| Your 2-week check · your chair count | Fall risk test · balance test score | Không gọi là "test" hay "score" |
| This is general fitness, not medical advice | Clinically proven · doctor-approved | Không mượn số Cochrane, Otago, StandingTall làm lời hứa cho app (bài học Lumosity, FTC 2016) |
| Talk to your doctor if you have a health condition | Safe for everyone | Có người không nên tập khi chưa hỏi bác sĩ |
| Gentle moves for achy knees (cần trích nguồn) | Cures arthritis · treats arthritis | "Knee-friendly" ở mức vừa: 1.4.1 có thể đòi trích dẫn |

## Ngoại lệ đã có trong app
- Dòng nhắc đi khám trên S06: "Had a fall recently, or fainted or felt dizzy in the past year? Check with your doctor first." là lời nhắc an toàn, không phải lời hứa. Lint cho qua (test `test_doctor_reminder_about_a_fall_is_allowed`).

## Câu cố định của tự kiểm tra (Task 1.3)

| EN | VI |
|---|---|
| This is not a medical test. | Đây không phải bài kiểm tra y tế. |
| You compare only with yourself. | Bạn chỉ so với chính mình. |
| Stop if anything hurts or you feel dizzy. | Thấy đau hay chóng mặt thì dừng ngay. |
