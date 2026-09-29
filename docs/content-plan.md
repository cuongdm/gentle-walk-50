# Kế hoạch nội dung — Gentle Walk 50+ (MVP)
_Cập nhật: 28/09/2026 (thêm video động tác, giãn cơ; rà soát) · Số lượng là ước tính từ spec, chưa phải số đo · Không ghi số tiền_

## Tham chiếu
- **[app-context.md](../app-context.md)**: người dùng mục tiêu, ba trụ, giá bằng chữ, **Tone & copy rules** (giọng văn, từ cấm, từ nên dùng, quy tắc thông báo), ràng buộc (offline, không tài khoản). Kế hoạch này không lặp lại các quy tắc đó; mọi nội dung phải theo app-context.
- **[docs/idea/gentle-walk-voice.md](idea/gentle-walk-voice.md)**: lý do của từng quyết định (§4 bằng chứng, §9 hành trình và thông báo, §11 MVP).
- **[docs/design/gentle-walk-screen-spec.html](design/gentle-walk-screen-spec.html)**: màn hình nào dùng nội dung nào, chữ hiển thị mẫu.
- **[docs/video-skill-notes.md](video-skill-notes.md)**: quy trình làm clip động tác trên Flow, QA, dựng; script ở `tools/video/`.

## 1. Tổng quan
| Nhóm | Số lượng ước tính | Bắt buộc trước ra mắt | Người duyệt |
|---|---|---|---|
| A. Kịch bản giọng | 490–600 câu (có A10 giãn cơ) | có | huấn luyện viên có chứng chỉ, người biên tập tiếng Anh Mỹ |
| B. Âm thanh | giọng + 3 chuông + 9–15 bản nhạc | có | chủ app, nhóm test |
| V. Video động tác | 17 job Flow động tác ghế (V1-1 … V6-3, mỗi job ≤ 10 giây) + 27 ảnh khung · **6 clip chính đã xong 28/09/2026** · thêm 6–8 clip giãn cơ (V2b) | 6 clip chính + 6–8 clip giãn cơ | huấn luyện viên (từng clip), chủ app |
| C. Minh hoạ | 50–60 tranh | khoảng 15 | chủ app |
| D. Chữ trong app | khoảng 400 mục | có | người biên tập tiếng Anh Mỹ |
| E. Nội dung hằng tháng | 1 gói hành trình/tháng | sau ra mắt | như C và D |

## 2. A. Kịch bản giọng (thư viện câu ngắn, app ghép khi chạy)
Giọng: nữ 58–65 tuổi, trầm ấm, khoảng 130 từ/phút, giọng Mỹ trung tính, **không gọi tên người dùng**, luôn nói bản dễ trước, khi đi bộ mỗi câu cách 8–10 giây.

| Mục | Số câu | Ghi chú |
|---|---|---|
| A1. First Walk 5 phút | ~30 | ngồi, không thể thất bại, kết bằng bưu thiếp đầu · **bản nháp 1: [scripts/A1-first-walk.md](scripts/A1-first-walk.md)** |
| A2. Dẫn đi bộ: Ngồi / Tại chỗ / Walking pad | ~150 (tối thiểu 67) | khởi động, nhanh, chậm, thả lỏng; 3–4 biến thể mỗi pha · **bản tối thiểu: [scripts/A2-walk-min.md](scripts/A2-walk-min.md)** |
| A3. Dẫn đi ngoài trời | 30–50 | câu an toàn ở pha nhanh ("watch for curbs"), "find somewhere to sit" |
| A4. 6 động tác ghế và thăng bằng | ~45 | giới thiệu, tư thế, bản dễ, bản khó, kết thúc; "Stand behind your chair" trước bài đứng · **bản nháp 1 cùng file với clip: [scripts/V-exercise-clips.md](scripts/V-exercise-clips.md)** |
| A5. Số đếm và đếm ngược | ~40 | 1–20, "3, 2, 1", "30 seconds left", "one minute left" |
| A6. Câu động viên | 40–60 | so với chính mình, không hype |
| A7. Break, This hurts, an toàn | ~20 | "Sit down, sip some water…", "Let's take care of that" |
| A8. Tới địa danh | 30–60 | 1–2 câu cho mỗi bưu thiếp của 5 hành trình |
| A9. Chuyển bài, check-in, welcome back | ~30 | theo Achy / Okay / Great |
| A10. Giãn cơ nhẹ (mới 28/09/2026) | 55 | 6–8 tư thế × (giới thiệu, vào tư thế, nhắc thở, bản dễ, đổi bên, ra tư thế); phần hạ nhiệt 1–2 phút sau đi bộ dùng 2–3 tư thế ngồi; "a gentle pull, never pain", không nhún, không nín thở; không hứa hết đau · viết cùng file với clip V2b · **bản nháp 1 có nguồn NHS/NIA: [scripts/A10-stretch.md](scripts/A10-stretch.md)** |

**Việc cần làm:** viết A1 trước (xong, bản nháp 1) → TTS prototype → nghe thử với nhóm test → viết A10 cùng kịch bản clip giãn cơ → viết phần còn lại → huấn luyện viên duyệt A2–A4, A7, A10 → chọn cách làm giọng (thu người thật, TTS hay clone có đồng ý; giọng ElevenLabs gói Free chỉ dùng cho prototype) → sản xuất → chuẩn hoá độ to → xuất phụ đề từ chính kịch bản.

### Bộ nội dung tối thiểu cho demo MVP (29/09/2026)
Mục tiêu: mọi màn và mọi luồng trong plan có nội dung thật (chữ) để demo chạy trọn; âm thanh, clip và tranh dùng placeholder tới khi làm asset thật (sau test prototype). Mỗi mục có tối thiểu là được; bản đầy đủ viết sau.
| Nhóm | Tối thiểu cho demo | Tình trạng | File |
|---|---|---|---|
| A1 First Walk | 30 câu | xong (nháp 1) | [A1-first-walk.md](scripts/A1-first-walk.md) |
| A2 Dẫn đi bộ | 67 câu (41 mới + 26 dùng lại A1), 3 cấp × 3 cường độ | xong (nháp 1) | [A2-walk-min.md](scripts/A2-walk-min.md) |
| A3 Ngoài trời | 12 câu | xong | [A-min-support.md](scripts/A-min-support.md) |
| A4 Động tác ghế | 6 × 6–8 câu | có sẵn | [V-exercise-clips.md](scripts/V-exercise-clips.md) |
| A5 Đếm | 22 câu | xong | A-min-support.md |
| A6 Động viên | 10 câu | xong | A-min-support.md |
| A7 An toàn | 12 câu | xong | A-min-support.md |
| A8 Địa danh | 10 câu (New York 6 + chặng đầu 4 tuyến) | xong | A-min-support.md |
| A9 Chuyển bài, check-in | 14 câu | xong | A-min-support.md |
| A10 Giãn cơ | 55 câu, 8 tư thế có nguồn | xong (nháp 1) | [A10-stretch.md](scripts/A10-stretch.md) |
| B1 Giọng | file tạm: bản DEBUG đọc bằng `AVSpeechSynthesizer` (plan 3.3); ElevenLabs gói thương mại sau | placeholder | — |
| B2 Chuông | 3 file tạm tạo bằng ffmpeg (sine hai nốt) | làm ở task code | — |
| B3 Nhạc | 0 (thư viện nhạc rỗng được, plan 3.12) | placeholder | — |
| V Clip | 6 clip động tác có sẵn; giãn cơ dùng ảnh khung tạm (plan 4.8) | 6/13 | assets/video/ |
| C Tranh | placeholder toàn bộ | placeholder | — |
| D1, D4, D11 | theo spec | có sẵn | spec |
| D2, D3, D5, D6, D7, D8, D9, D10 | 6 · 7 · 14 · 5 · 6 · 28 · 8 · 5 | xong (nháp 1) | [D-min-texts.md](scripts/D-min-texts.md) |
Tổng câu giọng tối thiểu: khoảng 250 (A1 30 + A2 41 mới + A3–A9 80 + A4 khoảng 45 + A10 55). Đủ cho sessions.json và voice-lines.json của plan task 1.5.

## 3. B. Âm thanh
| Mục | Số lượng | Yêu cầu |
|---|---|---|
| B1. File giọng | theo A | AAC, đóng gói sẵn, độ to đều |
| B2. Chuông | 3 | đổi pha (âm trầm 500–800 Hz, hai nốt) · đếm một lần · hoàn thành buổi |
| B3. Nhạc nền | 3 phong cách × 3–5 bản lặp | "Feel-good 70s and 80s" (mặc định), Calm piano, Country; **tạo bằng AI trên gói trả phí có quyền thương mại** (chốt 28/09/2026, docs/todo.md #4), không lời, tự nhỏ khi HLV nói |

## 4. V. Video động tác (người thật do AI tạo, không tiếng)
Giọng vẫn là lõi: clip chỉ minh hoạ, không mang thông tin mà giọng không nói. Người trong clip là HLV có giọng dẫn: trông 58–62 tuổi, tóc muối tiêu, dáng đầy đặn, đeo kính, áo sage cố định (spec mục "Brief cho designer"). Không đặt tên hay chứng chỉ cho HLV AI.

| Mục | Số lượng | Yêu cầu |
|---|---|---|
| V1. Ảnh tham chiếu HLV | 3–4 góc | dùng cho mọi clip để giữ cùng một người |
| V2. Clip chính cho 6 động tác (kịch bản: [scripts/V-exercise-clips.md](scripts/V-exercise-clips.md); **V1-1 … V6-1 xong 28/09/2026 (cùng khung máy, 720p + 1080p, giọng ElevenLabs): assets/video/**, chờ huấn luyện viên duyệt) | 6 (heel và toe gộp một clip V4-1) | 16:9 ngang, 2.5–9 giây một vòng, lặp liền mạch, một góc máy cố định (V1–V2 chính diện, V3–V6 nghiêng thuần), cùng cỡ người và phòng ở mọi clip, không cắt cảnh, không chữ in trong hình, không âm thanh, không watermark hiển thị; động tác luân phiên chứa cả hai bên trong một clip, không lật gương |
| V2b. Clip giãn cơ nhẹ (từ 28/09/2026) | 6–8 | cùng khung máy V1 (ảnh khung lấy từ video V1, xem skill §5f); bản ngồi trên ghế và đứng vịn ghế: 7 tư thế ngồi + bắp chân đứng vịn ghế theo [A10](scripts/A10-stretch.md) (clip V7-1 … V7-7; bỏ tư thế hông vắt chân); mỗi clip một động tác, vào tư thế 2–3 giây rồi app dừng ở khung giữ 15–20 giây; **kịch bản A10 đã có (29/09/2026, nguồn từng tư thế), báo giá credit trước khi tạo** |
| V3. Bản dễ và bản khó | 6–12 | ví dụ Sit-to-stand dùng tay đẩy / không dùng tay; heel raise ngồi / đứng vịn ghế |
| V4. Ảnh khung tĩnh lấy từ clip | 2 mỗi clip | tư thế đầu và cuối; dùng cho Reduce Motion, thumbnail, lỗi video, VoiceOver |

**Lỗi của clip thử 28/09/2026 cần tránh:** chữ prompt in vào hình · dấu ✦ watermark · cảnh cận và rộng làm động tác khác nhau · chân chéo ra ngoài thay vì thẳng phía trước · HLV trông khoảng 75 tuổi · có cắt cảnh và track âm thanh. Bài học đầy đủ và quy trình 7 bước: [video-skill-notes.md](video-skill-notes.md).
**Tình trạng và việc cần làm:** V1 nhân vật GWCoach và 6 clip chính V2 đã có → huấn luyện viên duyệt 6 clip (đặc biệt V1 tay chạm ghế khi ngồi, V6 chân nhấc cao hơn kịch bản) → viết A10 và kịch bản V2b → báo giá credit → tạo V2b → V3 bản dễ/khó → V4 ảnh khung tĩnh. Dấu ✦ vẫn có trên gói Pro: chốt gói không watermark hoặc công cụ khác trước khi sản xuất hàng loạt; không tự xoá watermark. **Báo giá credit trước mỗi đợt.**

## 5. C. Minh hoạ (màu nước)
Nhân vật minh hoạ: nhân vật chính + 3 nhân vật phụ, mô tả ở spec mục "Brief cho designer". Phong cách: gouache/màu nước, texture giấy. Động tác ghế dùng video (mục V), không vẽ.

| Mục | Số lượng | Mức | Ghi chú |
|---|---|---|---|
| C1. Bảng nhân vật (4 người, nhiều góc) | 4 | trước tất cả | chốt trước khi tạo hàng loạt |
| C2. Hướng dẫn phong cách một trang | 1 | trước tất cả | màu, nét, ánh sáng, bố cục bưu thiếp |
| C4. Đứng sau ghế trước bài đứng | 1 | bắt buộc | |
| C5. Ba cách để điện thoại | 3 | bắt buộc | túi quần, áp ngực, trên bàn |
| C6. Cảnh player: ngồi, tại chỗ, ngoài trời, bản tối | 4–6 | bắt buộc | tranh tĩnh, nền đổi màu theo pha |
| C7. New York: 6 bưu thiếp + 1 bản đồ | 7 | bắt buộc | bưu thiếp đầu có ngay buổi đầu |
| C8. Welcome, Break trong nhà, Break ngoài trời, chuẩn bị ra ngoài | 4 | nên có | Welcome có nhân vật phụ |
| C9. Màn thấu hiểu và 3 màn chuyển phần | 4 | nên có | tranh nhỏ |
| C10. Thang cây Seed → Sprout → Sapling → Tree | 4 | nên có | |
| C11. 4 hành trình trả phí: 24 bưu thiếp + 4 bản đồ | 28 | giao theo đợt | địa danh ở spec mục Journey |
| C12. Khung ảnh chia sẻ | 1 | nên có | không tên đường, không số nhà |
| C13. Mô tả chữ cho VoiceOver | theo C4–C12 và V4 | bắt buộc | viết cùng lúc với tranh và clip |

**Việc cần làm:** C1 → C2 → 1 bưu thiếp New York để chốt phong cách → phần còn lại. **Báo giá credit trước mỗi đợt tạo tranh.**

## 6. D. Chữ trong app (tiếng Anh Mỹ)
| Mục | Số lượng | Ghi chú |
|---|---|---|
| D1. Onboarding | ~14 màn | chữ mẫu ở spec S01–S07 |
| D2. Màn thấu hiểu theo rào cản | 6 biến thể | theo 6 lựa chọn ở S03 |
| D3. "Why this will work for you" | 6 biến thể | nối với S03 |
| D4. Paywall và màn trước hộp thoại Apple | 2 màn | ngày và số tiền là biến; không ghi số trong tài liệu |
| D5. Hướng dẫn động tác và giãn cơ | 6 × (3 gợi ý + bản dễ + bản khó) + 6–8 tư thế giãn cơ × (2 gợi ý + bản dễ) | huấn luyện viên duyệt; giãn cơ không có bản khó, chỉ giữ lâu hơn |
| D6. Mô tả hành trình | 5 | ghi "A gentle version of the route" |
| D7. Mặt sau bưu thiếp | 30 × (2–3 câu + 1 câu HLV) | Camino viết như chuyến đi văn hoá, không tôn giáo |
| D8. Kho câu thông báo | ~70 | xem bảng dưới |
| D9. Everyday wins | ~10 | "Carried the groceries in one trip" |
| D10. Lưu ý an toàn và hỏi bác sĩ | ~5 | không tuyên bố y khoa |
| D11. Trạng thái đặc biệt, Settings, lỗi | ~40 | theo spec mục Trạng thái đặc biệt và S20 |

**D8. Kho câu thông báo** (không lặp trong 14 ngày, không ghi tình trạng sức khoẻ):
| Loại | Số câu | Lý do |
|---|---|---|
| Nhắc tập | 14 × 3 mốc sinh hoạt = 42 | đủ 14 ngày không lặp cho mỗi mốc |
| Ngày 2 | 3 | chọn ngẫu nhiên |
| Gần địa danh | 30 | một câu mỗi bưu thiếp |
| Tổng kết tuần | 12 mẫu có biến | tăng, bằng, ít hơn tuần trước (không nhắc ngày bỏ) |
| Quay lại ngày 3 và 10 | 6 | |
| Hết trial | 1 | có biến ngày và số tiền |
| Tuyến mới | 1 mỗi tháng | chỉ gửi người đã tự bật |
| Thẻ "fewer reminders" | 1 | |

## 7. E. Gói nội dung hằng tháng (sau ra mắt)
Mỗi hành trình mới: 6 bưu thiếp + 1 bản đồ (C) · 6 mặt sau bưu thiếp + 1 mô tả (D) · 6–12 câu giọng tới địa danh (A8) · 6 câu thông báo gần địa danh + 1 câu "tuyến mới" (D8) · mô tả VoiceOver. Hàng chờ: Route 66, Amalfi (nếu nới giới hạn một tuyến châu Âu), Grand Canyon rim.

## 8. Thứ tự sản xuất
| Bước | Việc | Cần cho |
|---|---|---|
| 1 | V1 ảnh tham chiếu HLV (xong: GWCoach) · C1 bảng nhân vật · C2 hướng dẫn phong cách | mọi clip và tranh |
| 2 | V2 6 clip chính (xong, chờ duyệt) + C7 một bưu thiếp New York; huấn luyện viên duyệt | chốt phong cách, prototype |
| 3 | Công cụ video: chốt 29/09/2026 tạm dùng Flow Pro (có dấu ✦); mọi clip là bản dựng thử, tạo lại trên gói không watermark trước khi nộp (giữ prompt, ảnh khung, mốc cắt) · A1 + TTS (dựng file 5 phút bằng build_preview) · A10 + kịch bản V2b · **A2 tối thiểu khoảng 60 câu, A5, A7, A9** (chữ cần cho timeline và test, trước milestone 4 của plan) | code MVP, test prototype |
| 4 | Test prototype 6–8 người: giọng + tranh so với giọng + video, bố cục YouTube và Full screen, nhân vật, tuyến muốn đi, buổi giãn cơ có dễ theo bằng giọng không | quyết định giọng, HLV, nhân vật |
| 5 | A2–A10 đầy đủ, D1–D11, huấn luyện viên duyệt | code MVP |
| 6 | Sản xuất giọng (gói có giấy phép thương mại), B2–B3, phụ đề | code MVP |
| 7 | V2b còn lại, V3, V4 · C4–C10, C12–C13, phần còn lại của C7 | ra mắt |
| 8 | C11 và nội dung 4 hành trình trả phí | ra mắt, giao theo đợt |

## 9. Tiêu chí xong cho mỗi mục
Đúng Tone & copy rules trong app-context · không từ cấm · không tuyên bố y khoa · người duyệt đã ký · có mô tả VoiceOver (tranh, ảnh khung) hoặc phụ đề (giọng) · clip không watermark, không chữ in, huấn luyện viên đã duyệt · có giấy phép thương mại (nhạc, giọng TTS hoặc clone, công cụ tạo video) · tên file theo quy ước sẽ chốt ở manh-skill-plan.

## 10. Câu hỏi mở
- Giọng: thu người thật, TTS hay clone có đồng ý? Trả lời sau bước 4.
- Ai là huấn luyện viên duyệt động tác, và duyệt theo đợt hay từng mục?
- Công cụ tạo video nào cho phép dùng thương mại không watermark, và giữ được cùng một HLV qua 12–18 clip?
- Có thuê người biên tập tiếng Anh Mỹ bản địa không?
- Quy ước tên file và cấu trúc thư mục asset: chốt ở manh-skill-plan.
- Giãn cơ cho người thay khớp, đau vai, chóng mặt: tư thế nào phải ẩn theo giới hạn ở S06? Chốt 28/09/2026: tự lọc theo chống chỉ định trong nguồn công khai (NIA, NHS), ghi vào A10; không thuê người duyệt (docs/todo.md #2).
- Nhạc: chốt 28/09/2026, tạo bằng AI trên gói trả phí (docs/todo.md #4).
- Kế hoạch test prototype: đã viết docs/research/prototype-test-plan.md, chờ OK.
