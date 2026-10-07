# Quảng cáo năm đầu (đề xuất, 03/10/2026)

Chủ app chốt: năm đầu chạy quảng cáo kéo người dùng; app vẫn không có quảng cáo bên trong.

Nền số liệu:
- [2026-10-03-kiem-tien-dinh-vi-doi-thu.md](2026-10-03-kiem-tien-dinh-vi-doi-thu.md)
- Khách mục tiêu: phụ nữ Mỹ 58–75, lõi 60–72.

**Nguyên tắc:**
- Tìm ra kênh có lời ở quy mô nhỏ rồi mới tăng tiền.
- Mỗi giai đoạn có ngưỡng qua. Không qua thì dừng, sửa phễu, không đổ thêm tiền.

---

## 1. Bài toán hoà vốn (quan trọng nhất)

### Chi phí thị trường

| Kênh | Chỉ số | Nguồn |
|---|---|---|
| Apple Ads, Health & Fitness, Mỹ (2025) | **chi phí mỗi lần chạm 1,68 USD · chuyển đổi 50,3% · chi phí mỗi lượt tải 3,77 USD** · tỉ lệ chạm 7,5% | [AppTweak](https://www.apptweak.com/en/aso-blog/apple-ads-benchmarks) |
| Lượt tải trả phí iOS ở Mỹ, Health & Fitness | 2–5,5 USD | [The Social Outline](https://thesocialoutline.com/blog/cpi-benchmarks-health-fitness-apps) |
| Chi phí mỗi người bắt đầu dùng thử | 20–40 USD là mức "khoẻ" | [Airbridge](https://airbridge.io/en/blog/cost-per-trial-cost-per-subscription-subscription-app-ua-metrics) |
| Meta, ngách fitness | 8–18 USD cho 1.000 lần hiển thị; khán giả 55+ đắt hơn khán giả trẻ | [Webtonic](https://www.webtonic.io/blog/fitness-ad-creative-statistics), [Kevin Goodwin](https://kevingoodwin.substack.com/p/performance-marketing-reboot-10324) |
| Mẫu quảng cáo fitness | chỉ 5–7% mẫu thắng; cần thử 20–32 hướng; video kiểu người dùng thật (UGC) vượt video studio | Webtonic |

### Mỗi người trả tiền đáng bao nhiêu (2 năm, sau phí Apple 15%)

Giả định cách chọn gói:
- 70% gói năm, 30% trong số đó gia hạn.
- 20% gói tháng, trung bình 4 tháng.
- 10% trả một lần.

| Giá năm / trả một lần | Thu ròng mỗi người trả tiền | Riêng năm 1 |
|---|---|---|
| 39,99 / 79,99 USD (giá test hiện tại) | **43 USD** | 36 USD |
| 49,99 / 99,99 USD | **53 USD** | 44 USD |
| 59,99 / 129,99 USD | **63 USD** | 52 USD |

### Chi tối đa mỗi lượt tải để hoà vốn trong 2 năm

Cột "tải → dùng thử" là tỉ lệ người tải app bắt đầu trial.

| Giá năm | Dùng thử → trả tiền | Hoà vốn mỗi người dùng thử | Tải → dùng thử 10% | 15% | 25% |
|---|---|---|---|---|---|
| 39,99 | 38% (trung vị ngành) | 16 USD | 1,64 | 2,46 | 4,10 |
| 39,99 | 50% (nhóm top) | 22 USD | 2,16 | 3,24 | 5,40 |
| 49,99 | 38% | 20 USD | 2,00 | 3,00 | 5,00 |
| 49,99 | 50% | 26 USD | 2,63 | 3,94 | 6,57 |
| 59,99 | 38% | 24 USD | 2,39 | 3,58 | 5,97 |
| 59,99 | 50% | 31 USD | 3,14 | 4,72 | **7,86** |

**Kết luận:**
- Với giá test 39,99 USD và phễu trung bình, mỗi lượt tải chỉ được chi khoảng 1,6–2,5 USD. Thấp hơn chi phí Apple Ads (3,77 USD), nên **chạy quảng cáo bị lỗ**.
- Để hoà vốn ở mức giá thị trường cần **cả hai** điều:
  1. Phễu mạnh: ≥ 20–25% người tải bắt đầu trial (nhờ onboarding cá nhân hoá rồi mới paywall), và ≥ 45–50% người dùng thử trả tiền.
  2. Giá năm **49,99–59,99 USD**.
- Đây là lý do mạnh nhất để chốt giá sớm (docs/todo.md, mục Giá).

---

## 2. Đo lường: vướng luật "không backend, không SDK"

Không đo được thì không biết kênh nào lời.

| Cách | Đo được gì | Luật dự án |
|---|---|---|
| **Apple Ads + App Store Connect** | Apple Ads cho lượt tải và chi phí mỗi lượt tải theo từ khoá. App Store Connect cho tổng trial, trả tiền, hoàn tiền theo ngày. Trang sản phẩm tuỳ chỉnh cho lượt tải và tỉ lệ chuyển đổi theo từng trang. Link chiến dịch (`ct=`) cho số liệu theo chiến dịch khi người dùng đến từ web (cần kiểm tra trên App Store Connect những chỉ số nào có). | Giữ luật |
| **Chạy từng kênh một, so với mức tự nhiên trước đó** ("đo theo chênh lệch") | Tác động thật của một kênh lên tổng trial và doanh thu | Giữ luật |
| **AdAttributionKit / SKAdNetwork do app tự báo** khi người dùng bắt đầu trial hoặc mua: framework của Apple, không có SDK bên thứ ba, không gửi dữ liệu cá nhân | Meta và các mạng khác biết mẫu quảng cáo nào ra trial hoặc người trả tiền | **VƯỢT LUẬT DỰ ÁN** (nhẹ). Cần kiểm tra Meta có nhận cấu hình mà không cần SDK của Meta hay không |
| SDK Meta hoặc nền tảng đo lường (MMP) | Đo đầy đủ trên Meta | **VƯỢT LUẬT DỰ ÁN** (nặng): thêm SDK, sửa privacy manifest và nhãn quyền riêng tư; trái tinh thần "dữ liệu không rời máy". Không đề xuất trừ khi cách 3 thất bại |

**Đề xuất:**
- Giai đoạn 1 dùng cách 1 và 2.
- Trước giai đoạn 2, chủ app quyết cách 3. Nếu đồng ý, đây là một task code nhỏ: báo giá trị chuyển đổi khi bắt đầu trial và khi mua.

**Lưu ý về trial 14 ngày:**
- Người dùng chỉ trả tiền sau 14 ngày, nên quảng cáo phải tối ưu theo "bắt đầu trial", không theo "mua".
- Kết quả trả tiền có sau ít nhất 2 tuần, nên mỗi vòng thử của mỗi giai đoạn tốn ít nhất 3 tuần.
- Nếu muốn học nhanh hơn, có thể cân nhắc trial 7 ngày cho người đến từ quảng cáo. Ghi vào danh sách chốt giá.

---

## 3. Các giai đoạn

### Giai đoạn 0: trước ra mắt (khoảng 3–6 nghìn USD, chủ yếu làm video)
- **ASO:** tên, phụ đề, từ khoá theo [2026-10-03-ten-app-moi.md](2026-10-03-ten-app-moi.md).
- **3 trang sản phẩm tuỳ chỉnh**, mỗi trang một thông điệp (mục 4): (a) ghế và giọng dẫn; (b) đi bộ trong nhà và hành trình; (c) minh bạch tiền.
- **Video:**
  - 6–10 video kiểu người dùng thật: phụ nữ 60–72 **thật**, tập theo app ở phòng khách, nghe rõ giọng HLV.
  - Chi phí: 150–600 USD mỗi video, cộng 30–50% cho quyền chạy quảng cáo 90 ngày ([LaunchPoint](https://www.launchpointhq.com/guides/rates/how-much-do-fitness-ugc-creators-charge)).
  - **Không dùng người do AI tạo trong quảng cáo**: review đối thủ đã nghi HLV là AI (5–6% review 1–2★ ở một số nhóm), và Meta gắn nhãn nội dung AI.
- **Tài khoản:** Apple Ads, Meta Business (Facebook và Instagram).
- **Bảng theo dõi tuần** (mục 5). Một trang web tĩnh (trang chủ, hỗ trợ, pháp lý), làm cùng task 9.1.

### Giai đoạn 1: tháng 1–2 sau ra mắt, **chỉ Apple Ads** (2–3 nghìn USD/tháng)
- **Từ khoá ý định cao, khớp chính xác:**
  - chair yoga, chair workout, chair exercises, indoor walking, walk at home
  - low impact workout, beginner workout women, home workout for women
  - tai chi for beginners, stretching for beginners
  - tên app (phòng thủ thương hiệu)
- Tắt Search Match ở tuần đầu.
- **Tên đối thủ** (LazyFit, Bend, WalkFit) để một nhóm riêng, ngân sách nhỏ. Apple Ads cho đặt giá thầu, nhưng mẫu quảng cáo chỉ dùng chữ của mình.
- **Ngưỡng qua giai đoạn 2** (đo trên 4 tuần):
  - Chi phí mỗi lượt tải ≤ 3,5 USD.
  - Tải → trial ≥ 20%.
  - Trial → trả tiền ≥ 40%.
  - Rating ≥ 4,6 với ≥ 50 lượt đánh giá.
  - Hầu như không có review 1★ về tiền.
- **Không qua thì dừng:** sửa onboarding hoặc paywall, chốt giá, rồi thử lại.

### Giai đoạn 2: tháng 3–6, **thêm Meta** (5–15 nghìn USD/tháng, chỉ khi qua ngưỡng 1)
- Facebook và Instagram là nơi phụ nữ 60–75 dành nhiều thời gian nhất.
- Chiến dịch Advantage+ cho app, tối ưu theo "bắt đầu trial", nhắm phụ nữ 58–75 ở Mỹ, để thuật toán tự tìm người.
- **Thử 20–30 hướng mẫu trước khi tăng tiền**, 50–100 USD/ngày cho mỗi nhóm thử. Giữ mẫu có 3 giây đầu mạnh và giữ được người xem.
- **Ngưỡng tăng tiền:** chi phí mỗi người dùng thử ≤ mức hoà vốn ở mục 1 (theo giá đã chốt), và thu ròng trong 12 tháng ≥ chi phí (hoàn vốn ≤ 12 tháng).

### Giai đoạn 3: tháng 7–12, tăng kênh thắng (theo ngưỡng 2)
- Tăng tối đa 20% ngân sách mỗi tuần cho mẫu và kênh thắng.
- **Mùa:**
  - **Tháng 1** (mục tiêu năm mới) là mùa mạnh nhất: dồn ngân sách.
  - Mùa xuân: thông điệp đi ngoài trời.
- **Thử thêm:**
  - YouTube: quảng cáo trước video đi bộ hoặc tập ghế, nơi khách đang xem Leslie Sansone.
  - Người sáng tạo nội dung 55+ trên Facebook và YouTube, dùng link chiến dịch riêng.

### Ngân sách năm 1 (ước tính, phụ thuộc ngưỡng)

| Kết cục | Tổng chi |
|---|---|
| Dừng sau giai đoạn 1 (phễu chưa đạt) | khoảng 10 nghìn USD |
| Qua giai đoạn 2, chưa tăng | khoảng 40–70 nghìn USD |
| Tăng được ở giai đoạn 3 | 150–300 nghìn USD, phần lớn bù bằng doanh thu từ chính quảng cáo |

→ Chủ app nên đặt **mức lỗ tối đa chấp nhận được** cho năm 1 (ví dụ 10–20 nghìn USD). Chạm mức đó thì dừng.

---

## 4. Thông điệp quảng cáo (nháp, phải qua copy_lint và luật quảng cáo)

| # | Hướng | Câu mở (3 giây đầu) |
|---|---|---|
| 1 | Ghế và giọng dẫn | "No floor. No jumping. Just follow the voice." |
| 2 | Cứng người buổi sáng | "Stiff in the morning? Ten gentle minutes in your chair." (không hứa hết đau hay chữa khớp) |
| 3 | Đi bộ trong nhà có hành trình | "Walk to Central Park from your living room." |
| 4 | Minh bạch tiền | "Free for 14 days. We remind you before it ends. Cancel in one tap." |
| 5 | Không cần nhìn màn hình | "Put the phone down. She'll talk you through it." |

**Luật cần nhớ:**
- **Meta cấm nói hoặc ngụ ý thuộc tính cá nhân, gồm cả tuổi và bệnh.** Không viết "Are you over 60?" hay "Your bad knees…". Nhắm tuổi bằng cài đặt, không bằng chữ.
- Không trước/sau, không hứa giảm cân hay chống ngã (khớp luật 1.4.1 và luật Tone & copy của app).
- Không "senior", "elderly".
- Video chỉ dùng tính năng có thật trong app. Lời khen chỉ từ người đã dùng thật.

---

## 5. Bảng theo dõi tuần (làm tay, không cần backend)

| Chỉ số | Lấy từ đâu |
|---|---|
| Chi tiêu, lượt hiển thị, lượt tải, chi phí mỗi lượt tải theo từ khoá hoặc mẫu | Apple Ads, Meta Ads Manager |
| Lượt tải theo nguồn và theo trang sản phẩm tuỳ chỉnh | App Store Connect → App Analytics |
| Trial mới, trial → trả tiền, gia hạn, hoàn tiền, thu ròng | App Store Connect → Subscriptions và Sales and Trends |
| Rating, review 1–2★ về tiền | App Store Connect → Ratings and Reviews |
| Chi phí mỗi trial, thu ròng mỗi lượt tải, số tháng hoàn vốn | Tự tính trong bảng tính |

## Câu hỏi còn mở
1. Mức lỗ tối đa chấp nhận được năm 1 là bao nhiêu?
2. Có cho app tự báo giá trị chuyển đổi qua AdAttributionKit/SKAdNetwork (vượt luật nhẹ, không SDK) trước giai đoạn 2 không?
3. Trial 14 ngày hay 7 ngày cho người đến từ quảng cáo? (chốt cùng giá)
4. Ai làm video UGC: thuê người sáng tạo nội dung 55+ qua nền tảng, hay tự tuyển từ người test prototype (cần đồng ý bằng văn bản)?
