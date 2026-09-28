# App context — Gentle Walk 50+ (tên làm việc)

_Updated: 28/09/2026 (thêm giãn cơ) · by: manh-skill-idea · Brief: docs/idea/gentle-walk-voice.md · Spec màn hình: docs/design/gentle-walk-screen-spec.html · Kế hoạch nội dung: docs/content-plan.md_

## Identity
- App name (store): chưa chốt, cần kiểm tra trademark · Bundle ID (iOS): chưa có · Package (Android): chưa có
- App Store ID: chưa có · Website / Support / Privacy / Terms URL: chưa có
- Category: Health & Fitness · Age rating: chưa trả lời
- Platforms: iOS trước (iPhone + iPad) · Android để sau, tính như sản phẩm thứ hai
- Kế thừa spec PawSteps v3, đã bỏ mascot chó và thư viện video dài; có clip ngắn không tiếng cho 6 động tác ghế (từ 28/09/2026)

## Positioning
- One-sentence pitch: đi bộ trong nhà và động tác ghế cho phụ nữ 50+ mới bắt đầu, theo giọng HLV, không cần nhìn màn hình.
- Problem: muốn vận động lại nhưng đau khớp, sợ ngã, không theo kịp video; app hiện có trừ tiền bất ngờ và "cá nhân hoá" chung chung.
- Target user: phụ nữ Mỹ 50–64 (trước tuổi Medicare), thừa cân hoặc đau khớp, thường chăm người khác; phần lớn thế hệ X. Hiện dùng YouTube Leslie Sansone, WalkFit, LazyFit hoặc ChatGPT.
- Differentiators:
  1. Không cần nhìn màn hình: giọng dẫn từng pha, chuông trầm, phụ đề.
  2. Mọi bài có bản ngồi; giới hạn cơ thể lọc bài; "This hurts" và "Break" trên mọi player.
  3. Minh bạch tiền: ngày và số tiền ở paywall, nhắc trước khi hết trial, huỷ một chạm.
- Bồi thêm, không lên listing: hành trình địa danh tính theo phút tập; tự đếm ngồi–đứng khi áp ngực (mặc định tính giờ, luôn có đếm tay); chế độ đi ngoài trời.
- Not for: người chạy bộ và tập gym · phục hồi sau phẫu thuật · người 65+ đã có Bold/SilverSneakers qua bảo hiểm (không chặn, không nhắm) · trẻ em.
- Two-sentence definition: Gentle Walk 50+ là app iPhone hướng dẫn đi bộ trong nhà và động tác trên ghế bằng giọng nói cho phụ nữ 50–64 mới tập. Mỗi phút tập đưa người dùng qua hành trình địa danh thật như Central Park hay Camino de Santiago.

## Market
| Name | Link/ID | Model | They win at | We win at |
|---|---|---|---|---|
| WalkFit | 1457956232 | subscription, bán qua web | 520+ bài | minh bạch tiền, bản ngồi |
| LazyFit | 1669413773 | subscription, trial 7 ngày | chair/tai chi/pilates, HLV lớn tuổi | không cần nhìn màn hình, không lặp sau 28 ngày |
| ChillFit | 6754075317 | subscription | tăng nhanh | huỷ được trong app, minh bạch |
| Walk at Home | 1535065182 | subscription | video Leslie, thương hiệu | audio-first, tập theo giới hạn cơ thể |
| Bold / SilverSneakers GO | 6478184749 / 1410437380 | miễn phí qua bảo hiểm 65+ | miễn phí, nhiều lớp | nhóm 50–64 chưa có bảo hiểm này |
| Aaptiv | 869058995 | subscription | audio-first, thư viện lớn | làm riêng cho 50+ và khớp đau; đang cập nhật |
| Bend | 1513988468 | subscription | giãn cơ, thư viện lớn | làm riêng cho 50+ đau khớp, bản ngồi |
| Tai chi cho người lớn tuổi (nhiều app 2025–2026) | 6751329158 · 6759260204 | subscription, quảng cáo mạnh | bắt trend tai chi | chậm, dẫn bằng giọng, minh bạch tiền |
| The Conqueror | 1539543704 | trả một lần mỗi thử thách | tuyến thật, medal | tuyến rút gọn cho người mới, gắn với bài tập |
- Đối thủ thật: YouTube miễn phí và ChatGPT.
- Saturated-category exposure: adjacent — simple timers. Mitigation: ba trụ thấy trong 2 phút; ngoài trời là chế độ trong app, không tách app; review notes nêu khác biệt.
- Portfolio overlap: không có app cùng mảng trên tài khoản.

## Locales & markets
- Locales: en-US · Thị trường: Mỹ; sau đó UK, CA, AU · RTL: không
- Đơn vị mặc định ft/lb/dặm, có chuyển cm/kg/km.
- Dữ liệu mẫu cho screenshot: người dùng Margaret, 58 tuổi; hành trình New York đang ở Times Square; không dùng tên hay ảnh người thật.

## Price model (words only)
- Model: subscription tháng và năm, cộng trả một lần dùng mãi. Không gói tuần.
- Free: mỗi ngày một bài đi bộ kèm 1–2 động tác ghế luân phiên, streak, hành trình New York, chặng đầu mọi hành trình khác, This hurts, chế độ ngoài trời.
- Paid: đủ cấp và chương trình tuần, thư viện động tác đầy đủ, các buổi giãn cơ đầy đủ (bản miễn phí có phần hạ nhiệt ngắn), 4 hành trình còn lại và tuyến mới hằng tháng, lịch sử chi tiết.
- Trial: 14 ngày trên gói năm (chọn sẵn), nhắc ngày 12; kiểm tra điều kiện bằng StoreKit 2. Trả một lần ở vị trí thứ ba, không chọn sẵn.
- Mời nâng cấp: onboarding · hoàn thành New York · bấm nội dung khoá. Không hiện mỗi lần mở app.
- Store fee assumption: 15%.

## Tone & copy rules
- Voice: ấm, chậm, tôn trọng. Không hype, không so với người khác, chỉ so với chính mình.
- Banned: lazy, fat, burn, blast, crush, no excuses, transformation, skinny, anti-aging, senior, elderly, rehab, therapy, guaranteed, melt, shred, tone up, before/after; tên bài kiểu "SHRED"; tuyên bố y khoa hoặc giảm nguy cơ ngã.
- Nên dùng: gentle, steady, stronger, steadier, at your pace, comfortable, your time, on your feet, keep up with.
- Giọng HLV không gọi tên người dùng; luôn nói bản dễ trước.
- Thông báo: tối đa một mỗi ngày; không ghi tình trạng sức khoẻ trên màn khoá; không lặp câu trong 14 ngày; không bao giờ "mất chuỗi"; tổng kết tuần chỉ so với chính mình.
- Emoji: không trong copy store · Dấu: ASCII thường.

## Content & visuals
- Kế hoạch nội dung đầy đủ (giọng, âm thanh, minh hoạ, chữ trong app, gói hằng tháng): docs/content-plan.md. Không lặp lại ở đây.

## Seasonal hooks (thị trường Mỹ)
- Đầu năm (tháng 1): mục tiêu năm mới · Mùa xuân: bắt đầu đi ngoài trời · Mùa hè: nhắc nắng nóng, đi sớm · Mùa thu (tháng 9–10): tuyến Smoky Mountains và hải đăng New England đẹp nhất · Mother's Day (tháng 5): ảnh chia sẻ với gia đình.

## Engineering hooks for capture
- Chưa có. manh-skill-plan quyết định launch argument cho screenshot, deep link và accessibility identifier.
- Thông báo local, lên lịch trên máy theo từng đợt ngắn: nhắc tập theo mốc sinh hoạt (có nút Start walk / Rest today), ngày 2, gần địa danh, tổng kết tuần, quay lại ngày 3 và 10, hết trial ngày 12, tin tuyến mới (tắt mặc định). Giảm dần khi người dùng tự tập 5 ngày liền trước giờ nhắc.
- Quyền dự kiến: Motion & Fitness · HealthKit (đọc bước, ghi workout và tuyến) · thông báo sau buổi đầu · vị trí "When In Use" chỉ khi đi ngoài trời · background audio; background location chỉ trong buổi ngoài trời.
- Ràng buộc: không tài khoản, không backend, không quảng cáo; offline; dữ liệu sức khoẻ không lên iCloud.

## Risks
- Đi tại chỗ có đếm được bằng CMPedometer không, rung có chạy khi khoá màn hình không → đo trên máy thật.
- Người quen video thấy bản giọng "mỏng" → test prototype trước khi code.
- 65+ có app miễn phí → nhắm 50–64 trong metadata và onboarding.
- Tranh AI lệch nhân vật → bảng nhân vật, hướng dẫn phong cách, huấn luyện viên duyệt tư thế.
- 1.4.1 → không tuyên bố y khoa.
- Video AI người thật sai kỹ thuật hoặc lệch HLV giữa các clip → làm 2 động tác trước, huấn luyện viên duyệt; không watermark, kiểm tra điều khoản thương mại; không đặt tên hay chứng chỉ cho HLV AI.
- Thông báo mất tác dụng sau khoảng 4 tuần (HeartSteps) → kho câu xoay vòng, đổi loại theo giai đoạn, giảm dần khi đã thành thói quen.
- Chưa có cách đo hiệu quả thông báo khi không có backend → chốt ở manh-skill-plan.

## Decisions log (append-only)
- 27/09/2026 — GO "gentle-walk-voice" (docs/idea/gentle-walk-voice.md): giữ khác biệt của PawSteps, bỏ thư viện video và mascot chó.
- 27/09/2026 — GO bản giọng nói, cảm biến làm phụ; nhắm 50–64; Fitness Check phase 2, chó + video phase 3. Rút lại lý do cũ "Walk at Home ngừng cập nhật" vì sai.
- 27/09/2026 — Đi ngoài trời: GO chế độ phụ, vào MVP, GPS tuỳ chọn.
- 27/09/2026 — Hành trình & paywall: tính theo phút tập; 5 tuyến, mỗi tháng thêm một; trial 14 ngày; thêm trả một lần; miễn phí có động tác ghế và chặng đầu mọi tuyến.
- 27/09/2026 — Nhân vật & onboarding: nhân vật chính 55–58 tuổi + 3 nhân vật phụ; không màn chọn avatar; onboarding khoảng 13–14 màn. Ghi theo đề xuất, chủ app yêu cầu cập nhật tài liệu.
- 27/09/2026 — Gộp tài liệu: còn brief, app-context và spec màn hình.
- 28/09/2026 — Thông báo: GO toàn bộ đề xuất (docs/idea/gentle-walk-voice.md §9) — 7 loại, tối đa một mỗi ngày, nhắc theo mốc sinh hoạt, Rest today, giảm dần, không ghi sức khoẻ trên màn khoá, tuyến mới tắt mặc định.
- 28/09/2026 — Tách kế hoạch nội dung ra docs/content-plan.md; app-context chỉ trỏ tới, không gộp.
- 28/09/2026 — Video + audio: GO clip ngắn không tiếng, người thật do AI tạo, cho 6 động tác ghế; audio vẫn là lõi; bố cục kiểu YouTube, có Full screen (docs/idea/gentle-walk-voice.md §11).
- 28/09/2026 — Phương pháp tập thêm: GO giãn cơ nhẹ vào MVP (gộp chair yoga); tai chi chậm phase 2 sau test giọng; NO-GO wall pilates, somatic, bài lazy/trên giường; bài mới phải dẫn được bằng giọng (docs/idea/gentle-walk-voice.md dòng 24–29).
