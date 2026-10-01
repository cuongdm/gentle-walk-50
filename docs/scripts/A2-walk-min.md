# A2 — Dẫn đi bộ, bản tối thiểu cho demo MVP · bản nháp 1
> **30/09/2026:** bản đầy đủ ở [A2-walk.md](A2-walk.md); file này giữ để đối chiếu ID.
_29/09/2026 · Theo [app-context.md](../../app-context.md) (Tone & copy rules) và [content-plan.md](../content-plan.md) mục A2 · Tái dùng 26 câu "Dùng lại" của [A1](A1-first-walk.md) · Chữ thoại tiếng Anh Mỹ, ghi chú tiếng Việt_

## 1. Phạm vi
- Đủ để app dựng **mọi buổi đi bộ** của plan task 2.8: 3 cấp (Seated · In place · Walking pad) × 3 cường độ (Gentle · Steady · Strong). Ngoài trời dùng bộ A3 tối thiểu trong [A-min-support.md](A-min-support.md).
- Bản đầy đủ (khoảng 150 câu, 3–4 biến thể mỗi pha) viết sau test prototype. Bản này: **mỗi chỗ 2–3 biến thể**, đủ để hai buổi liền nhau không nghe y hệt.
- Câu đếm (A5), an toàn (A7), chuyển bài và check-in (A9) ở [A-min-support.md](A-min-support.md).
- NIA-3T (xem [A10](A10-stretch.md) §1): khởi động và thả lỏng bằng đi chậm trước và sau phần nhanh; "nói chuyện được" là mức vừa — dùng làm câu tự đo cường độ, không đưa nhịp tim.

## 2. Khung buổi (cho sessions.json và task 2.8, 2.11)
| Cường độ | Khởi động | Vòng nhanh / chậm | Thả lỏng | Tổng |
|---|---|---|---|---|
| Gentle (Achy) | 2:00 | 2 × (0:30 nhanh + 0:30 chậm) | 1:00 | 5:00 |
| Steady (Okay) | 2:00 | 2 × (1:00 nhanh + 1:00 chậm) | 2:00 | 8:00 |
| Strong (Great) | 2:00 | 3 × (1:00 nhanh + 1:00 chậm) | 2:00 | 10:00 |
- Cấp chỉ đổi câu dựng tư thế, câu vào pha nhanh và câu thả lỏng; khung giờ giống nhau (Walking pad dùng nhịp như In place, plan 8.10).
- Nhãn player: khởi động và pha chậm = EASY WALK (sky), pha nhanh = BRISK WALK (sun). Chuông đổi pha phát trước câu 1 giây (như A1).
- Sau phần đi bộ, ngày có động tác ghế hoặc hạ nhiệt thì nối sang A9 (chuyển bài) rồi A4 / A10.

### 2.1 Chỗ đặt câu trong một buổi (khe)
| Khe | Thời điểm | Chọn từ |
|---|---|---|
| mở | 0:00 | `a2.open.*` |
| dựng tư thế | 0:08 | `a2.setup.<cấp>.*` |
| khởi động | 0:20 → 1:50, mỗi 10–12 s | `a1.04–a1.11` (A1), `a2.warm.*`; ghế: có `a1.08`; đứng: bỏ `a1.08` |
| báo sắp nhanh | khởi động − 0:08 | `a1.12`, `a2.soon.*` |
| vào nhanh | đầu mỗi vòng nhanh | `a2.brisk.<cấp>.*` (vòng 1), `a1.19`, `a2.brisk.again.*` (vòng sau) |
| giữa nhanh | +0:10, +0:30 | `a1.14`, `a1.20`, `a2.brisk.mid.*` |
| đếm lùi | nhanh − 0:10 | `a1.15`, `a1.21` hoặc A5 |
| vào chậm | đầu mỗi pha chậm | `a1.16`, `a1.22`, `a2.easy.*` |
| giữa chậm | +0:10 | `a1.17`, `a1.23`, `a2.easy.mid.*` |
| báo vòng tiếp | chậm − 0:08 | `a2.round.*` (Gentle 30 giây: `a1.18`) |
| thả lỏng | đầu pha thả lỏng | `a2.cool.<cấp>.*` |
| giữa thả lỏng | +0:10, +0:22, +0:34 | `a1.26`, `a1.27`, `a1.28`, `a2.cool.mid.*` |
| kết | cuối | `a2.close.*` (không dùng `a1.29–30`, riêng First Walk) |
Chọn biến thể theo `rotationIndex` (task 2.8): biến thể = (ngày hoạt động + khe) mod số biến thể, để hai ngày liền nhau khác câu.

## 3. Câu thoại mới
### 3.1 Mở và dựng tư thế
| ID | Câu thoại |
|---|---|
| a2.open.1 | Welcome back. Let's get your feet moving. |
| a2.open.2 | Good to see you. This walk is all at your pace. |
| a2.open.3 | Ready when you are. Let's start slow and easy. |
| a2.setup.seated.1 | Sit toward the front of your chair, feet flat, back tall. |
| a2.setup.seated.2 | Find the front of your seat and plant your feet. Hands can rest on your thighs. |
| a2.setup.inplace.1 | Stand near your chair so you can hold it if you need to. Feet about hip-width apart. |
| a2.setup.inplace.2 | Stand tall with your chair close by. Soft knees, relaxed shoulders. |
| a2.setup.pad.1 | Step onto your walking pad and start it at a slow, easy speed. |
| a2.setup.pad.2 | Start your pad nice and slow. You can change the speed anytime. |

### 3.2 Khởi động và báo sắp nhanh
| ID | Câu thoại |
|---|---|
| a2.warm.1 | Easy steps to start. Let your arms swing naturally. |
| a2.warm.2 | Keep it light. Heels, then toes, nice and steady. |
| a2.warm.3 | Roll your shoulders once or twice. Stay loose. |
| a2.warm.4 | Just warming up. No rush at all. |
| a2.soon.1 | Quicker steps coming up in a few seconds. |
| a2.soon.2 | Get ready to pick up the pace, just a little. |

### 3.3 Pha nhanh
| ID | Câu thoại |
|---|---|
| a2.brisk.seated.1 | A little quicker now. March your feet, and let your arms join in. |
| a2.brisk.seated.2 | Pick up the pace in your chair. Quick, small steps. |
| a2.brisk.inplace.1 | A little quicker now. Lift your knees a bit and swing your arms. |
| a2.brisk.inplace.2 | Pick up the pace, right where you are. Stay close to your chair. |
| a2.brisk.pad.1 | Turn your pad up a notch, or just take quicker steps. |
| a2.brisk.pad.2 | A little faster now, if it feels right. Hold the handle if your pad has one. |
| a2.brisk.again.1 | Here we go again. Quicker steps. |
| a2.brisk.again.2 | Brisk again. Find that same rhythm. |
| a2.brisk.mid.1 | You should be breathing a bit harder, but still able to talk. |
| a2.brisk.mid.2 | Nice rhythm. Keep your shoulders relaxed. |
| a2.brisk.mid.3 | If it feels like too much, slow down a little. That still counts. |
| a2.brisk.last | Last quicker round. You've got this. |

### 3.4 Pha chậm và báo vòng tiếp
| ID | Câu thoại |
|---|---|
| a2.easy.1 | And ease off. Easy steps, catch your breath. |
| a2.easy.2 | Slow it down. Nice and relaxed. |
| a2.easy.mid.1 | Let your breathing settle. You're doing well. |
| a2.easy.mid.2 | Easy pace. Loosen your hands. |
| a2.round.1 | Another quicker round in a few seconds. |
| a2.round.2 | Get ready. One more round coming up. |

### 3.5 Thả lỏng và kết
| ID | Câu thoại |
|---|---|
| a2.cool.seated.1 | Time to wind down. Slow your feet until they're barely moving. |
| a2.cool.inplace.1 | Time to wind down. Slow, gentle steps, then let your feet rest. |
| a2.cool.pad.1 | Bring your pad down to a slow stroll. |
| a2.cool.pad.2 | When you're ready, stop your pad and step off carefully. |
| a2.cool.mid.1 | Shake out your hands. Let your breathing slow down. |
| a2.close.1 | That's your walk for today. Well done. |
| a2.close.2 | All done. Every minute counts, and you did them all. |
| a2.close.3 | That's it for today. Your journey just moved a little further. |

Tổng câu mới: 41. Cộng 26 câu dùng lại của A1 (`a1.02`–`a1.28`, trừ các câu chỉ dùng cho First Walk: `a1.01`, `a1.29`, `a1.30`) = **67 câu** cho mọi buổi đi bộ.

## 4. Kiểm tra theo quy tắc
- Từ cấm: không có (quét tay theo app-context 29/09/2026; lint `tools/lint/copy_lint.py` sẽ chạy lại ở task 1.14).
- Bản dễ trước: `a2.brisk.mid.3` cho phép chậm lại trong pha nhanh; cấp ghế là mặc định.
- Không tuyên bố sức khoẻ: chỉ tự đo "breathing a bit harder, but still able to talk".
- Walking pad: app không điều khiển máy; chỉ nhắc chỉnh tốc độ và bước xuống cẩn thận.
- Không gọi tên người dùng.
