# Việc cần làm — Good Footing
_Cập nhật 09/10/2026 (trước đó 08/10/2026). Mỗi việc có người làm, đầu ra và trạng thái. Xong thì gạch và ghi ngày; quyết định sản phẩm ghi thêm vào decisions log của app-context.md._

## RevenueCat và giá (09/10/2026) — code xong trên nhánh `local/revenuecat`
Kế hoạch: [plans/2026-10-09-revenuecat.md](plans/2026-10-09-revenuecat.md). Chủ app chốt: SDK RevenueCat làm lớp mua (đảo quyết định 08/10 "không SDK" cho riêng mua hàng); giá năm 49,99 (dùng thử 14 ngày), tháng 9,99, trả một lần 99,99.
- [x] ~~Claude — tích hợp SDK sau seam `PurchaseBackend`, luật `CustomerRules` ở core, paywall đọc giá từ cửa hàng, trạng thái "Try again" khi không có cửa hàng, giá mới ở `.storekit`/ảnh chụp/test, chữ Privacy (app, web, checklist) + bản Việt~~ Xong 09/10.
- [ ] **Chủ app** — làm phần A và B của [release/1.0/revenuecat-setup.md](release/1.0/revenuecat-setup.md) (App Store Connect, khoá In-App Purchase, project RevenueCat).
- [ ] **Chủ app** — đặt public SDK key vào `iOS/Config/Local.xcconfig`: `REVENUECAT_PUBLIC_KEY = appl_…` (mẫu ở `iOS/Config/Local.xcconfig.example`). Thiếu khoá thì cổng phát hành `ReleaseContentTests.revenueCatKeyIsSet` đỏ.
- [ ] **Chủ app** — mua thử Sandbox trên iPhone thật: năm (có 14 ngày dùng thử, thẻ Today, nhắc ngày 12), tháng, trả một lần khi đang có gói năm (cảnh báo + hướng dẫn huỷ), Restore sau khi cài lại, huỷ gói → hết hạn về miễn phí.
- [ ] **Chủ app** — TestFlight 1.0 (2) báo "This item is not available." khi mua (09/10): đi checklist [release/1.0/purchase-troubleshooting.md](release/1.0/purchase-troubleshooting.md); nghi nhất là tài khoản App Store Việt Nam trong khi 3 sản phẩm chỉ bán ở Mỹ. App đã sửa trên nhánh `local/purchase-unavailable` (paywall giữ nguyên + câu nhẹ nhàng, không còn "kiểm tra kết nối").
- [ ] **Chủ app quyết** — nhãn App Privacy: có khai thêm Identifiers → Device ID không (SDK gửi IDFV trong header; RevenueCat nói không bắt buộc). Xem [release/1.0/checklist.md](release/1.0/checklist.md) mục 3.
- [ ] **Chủ app** — đăng lại `site/privacy.html` (đã thêm mục RevenueCat).

## Nối Kế hoạch 12 tuần với Hành trình (09/10/2026) — code xong trên nhánh `local/plan-journey-link`
Kế hoạch: [plans/2026-10-09-plan-journey-link.md](plans/2026-10-09-plan-journey-link.md). Tóm tắt từng giai đoạn (Kế hoạch), thẻ "Stage N is done" (Hôm nay), "Your whole route" (kết thúc 12 tuần), "Your 12 weeks" (Hành trình). Ảnh Pro Max sáng/tối/XXL đã xem.
- [ ] **Chủ app quyết** — thu câu HLV mở buổi đầu của giai đoạn mới không (mặc định: không thu, chỉ có chữ): "A new stage starts today. Same pace, same you. We only add more when it feels easy." / "Hôm nay sang giai đoạn mới. Vẫn nhịp cũ, vẫn là bạn. Mình chỉ thêm khi bạn thấy dễ."
- [ ] **Chủ app xem** — thẻ "Stage N is done" tự ẩn sau 7 ngày chương trình nếu không bấm (giữ tóm tắt trên màn Kế hoạch); muốn giữ tới khi bấm thì đổi `StageRecaps.cardDays`.
- [ ] **Claude** — chụp lại trên iPhone SE (sáng + XXL): `today-stage-recap`, `program-recaps`, `program-finished-route` (thêm thẻ nên màn kết thúc giờ phải cuộn trên SE, nút vẫn ghim đáy), `journey-with-stages`.
- [ ] **Claude** — chụp bản tiếng Việt của 4 trạng thái trên khi chủ app yêu cầu (chữ đã dịch, chưa xem trên ảnh).

## Chương trình vững chân (08/10/2026) — đang làm
Kế hoạch: [plans/2026-10-08-steady-program.md](plans/2026-10-08-steady-program.md). Bàn giao cho phiên Mac: [handoff/2026-10-08-steady-program-local.md](handoff/2026-10-08-steady-program-local.md).
- [x] Nhóm 1–2 (lint, core) xanh trên cloud; nhóm 6 (tài liệu phát hành) xong.
- [x] ~~Claude (Mac) — build, sửa lỗi, test nhóm 3–4, chụp 10 trạng thái, trích khoá và áp bản Việt~~ Xong 08/10 trên `main` (kết quả ở đầu file bàn giao). Còn ảnh iPad.
- [ ] **Chủ app** — nghe 3 câu HLV mới (`a12.check.*`, đã thu EN + VI qua Vibi 08/10: `assets/voice/cache-bella-v4`, `cache-vi-bella-v4`); muốn sửa lời thì sửa [scripts/A12-steady-program.md](scripts/A12-steady-program.md) rồi thu lại.
- [ ] **Chủ app** — xem các quyết định nhỏ đã tự chốt (handoff mục 6). Code đã ở `main`.

- [ ] **Chủ app quyết (nghiên cứu độc lập 08/10, [research/2026-10-08-kha-nang-chi-tra-va-kiem-tien.md](research/2026-10-08-kha-nang-chi-tra-va-kiem-tien.md)):** nhóm 58–75 trả được $39,99/năm, nhưng chưa có bằng chứng quảng cáo hoàn vốn (mô hình cơ sở: mỗi $1 quảng cáo thu về ~$0,24–0,30). (1) mức lỗ tối đa chấp nhận năm đầu; (2) cho phép Meta SDK hoặc đối tác đo lường không (luật "không SDK" vẫn giữ cho quảng cáo; RevenueCat là ngoại lệ cho mua hàng từ 09/10); (3) thu nhỏ bản miễn phí không; (4) ~~giá: tháng $9,99, trọn đời $99,99, thử năm $49,99 song song~~ chốt 09/10: năm $49,99, tháng $9,99, trọn đời $99,99; (5) kiểm chứng rẻ trước (~$5–8K: test trang đích Meta $300–500, rồi Apple Ads tới ~1.000–1.500 cài).
  - Chốt 08/10: tạm GIỮ NGUYÊN không SDK (đo bằng Apple Search Ads/AdServices trước, Meta chỉ test trang đích) và GIỮ nhắc trước khi hết dùng thử. Còn mở: mức lỗ tối đa năm đầu, thu nhỏ bản miễn phí, giá.

- [ ] **Chủ app xem (code 08/10, kế hoạch [plans/2026-10-08-ui-onboarding-personalization.md](plans/2026-10-08-ui-onboarding-personalization.md)):**
  - Today trên iPhone SE: nút Start nằm ở ~60% chiều cao màn (mục tiêu 55%); có bỏ/dời dòng "We'll set today's session to match." không.
  - Chữ rút gọn để vừa iPhone SE ở onboarding và paywall (vd. "What matters most?", "Get up from chairs easily", "Floor is hard", "Standing tires me", "I get dizzy", "Unsteady on my feet"; 24 giờ huỷ dời xuống dưới các gói).
  - Paywall khi mở "See other plans" bằng tiếng Việt trên SE: gói thứ ba nằm dưới thanh nút, phải cuộn.
  - Màn chơi ghế trên SE: phần giữa cuộn, chip "Two hands on the chair" bị che một nửa.
  - "Your results" dùng 4 tuần theo thiết kế (kế hoạch ghi 8 tuần).
  - Bài bị tạm gác sau 2 lần báo đau: thẻ trên Today hiện 3 ngày.
  - Check-in tuần chọn "Easier than I expected" → buổi đi bộ dài thêm ~2 phút.
  - Duyệt câu mới: "After last time, Great is picked…", "A gentle start for your first sessions…".
  - Nghe lại 6 câu HLV tiếng Việt của hành trình Pro bị máy nghe-chữ gắn cờ vì tên địa danh tiếng Anh: a8.smoky.2, a8.smoky.6, a8.camino.3, a8.camino.5, a8.camino.6, a8.ne.6.

- [x] ~~Chủ app chốt lại D5~~ Chốt 08/10: bỏ "Not now" ở màn trước quyền Health và nhắc nhở (một nút mở hộp thoại Apple, "Don't Allow" vẫn đi tiếp), ẩn Close ở bước xin vị trí. Làm trong task 3.8.

## Chủ app quyết định (đề xuất mặc định đã ghi, chưa chốt)
| # | Việc | Đề xuất mặc định | Trạng thái |
|---|---|---|---|
| 1 | Thang cây Seed → Sprout → Sapling → Tree hết sau 3 tuần | Giãn mốc **7 · 21 · 42 ngày hoạt động** (Sprout ngày 7, Sapling ngày 21, Tree ngày 42). Sau Tree: mỗi 42 ngày thêm một "vòng năm" trên thân cây, không thêm cấp mới. Mockup S19 đổi thành "Sprout · 8 days to Sapling". | Chốt 29/09/2026: 7 · 21 · 42, đổi sau nếu cần |
| 2 | Cơ sở cho bài giãn cơ | **Chốt 28/09/2026: không thuê người duyệt.** Bài giãn cơ lấy từ nguồn công khai có uy tín, ghi nguồn cho từng tư thế trong kịch bản A10: [NIA Go4Life, 6 flexibility exercises](https://go4life.nia.nih.gov/sample_workout/6-flexibility-exercises-older-adults) và [trang cổ](https://go4life.nia.nih.gov/exercise/neck/) (giữ 10–30 giây, lặp 3–5 lần, không nhún, thở đều, giãn sau khi đã ấm người); [NHS Sitting exercises](https://www.nhs.uk/live-well/exercise/sitting-exercises/) và [NHS flexibility exercises PDF](https://assets.nhs.uk/prod/documents/NHS-flexibility-exercise.pdf) (ghế không bánh xe, không tay vịn, 2 lần một tuần trở lên); ACSM cho người lớn tuổi: giữ 30–60 giây, 2–4 lần, 2–3 ngày một tuần ([tổng hợp](https://www.unm.edu/~lkravitz/Article%20folder/ACSMGuidelinesUNM.pdf)). Tham khảo thêm video của Bend và chair yoga trên YouTube để xem cách dẫn, không chép lời. Lọc theo S06 tự làm theo chống chỉ định ghi trong các nguồn trên (ví dụ thay khớp háng: không vắt chân, không gập hông quá 90 độ). | Chốt; việc còn lại là viết A10 kèm nguồn |
| 3 | Kế hoạch test prototype | Đã viết một trang: [research/prototype-test-plan.md](research/prototype-test-plan.md). 6–8 phụ nữ Mỹ 55–70, 40 phút mỗi người qua video call, 3 mẫu thử (giọng + tranh, giọng + video, giãn cơ theo giọng), tiêu chí đạt ghi sẵn. | Chờ OK kế hoạch, chưa tuyển |
| 4 | Nhạc nền | **Chốt 28/09/2026: nhạc tạo bằng AI trên gói trả phí.** Đề xuất sau tra cứu: **Eleven Music trên cùng tài khoản ElevenLabs với giọng** (API chính thức, dữ liệu có giấy phép, thương mại từ Starter); không dùng "Suno API" qua bên trung gian. Chi tiết và giá: [research/audio-api-options.md](research/audio-api-options.md). Phương án cũ (Suno Pro/Premier trên web hoặc Udio gói trả phí: gói trả phí có quyền thương mại, không cần ghi nguồn; chỉ dùng bài tải về khi đang ở gói trả phí; lưu bằng chứng gói và ngày tạo cho từng bài; [điều khoản Suno](https://help.suno.com/en/categories/550145-rights-ownership), verify lại lúc tạo). 3 phong cách × 3–5 bản lặp 2–3 phút, không lời, không giai điệu giống bài có bản quyền. **Làm sau khi code**, player dùng file tạm trước. | Chốt; làm ở giai đoạn asset |

## Sau nghiên cứu thị trường 03/10/2026 (app-context decisions log)
Đã chốt: khách mục tiêu 58–75 (lõi 60–72); tìm tên mới; năm đầu chạy quảng cáo; chưa mua Sensor Tower/AppMagic.

**Giá: chốt 09/10/2026 — năm 49,99 USD (dùng thử 14 ngày), tháng 9,99, trả một lần 99,99** (`.storekit` đã theo; giá thật đặt ở App Store Connect). Các mục dưới giữ làm lịch sử.
- [x] ~~**Gói năm:** cân nhắc 49,99–59,99 USD thay 39,99 USD.~~ Chốt 49,99.
  - Ở 39,99 USD với phễu trung bình, quảng cáo chỉ hoà vốn khi mỗi lượt tải tốn ≤ 1,6–2,5 USD, trong khi Apple Ads tốn khoảng 3,77 USD.
  - Thị trường: LazyFit có gói 69,99 USD; Essentrics thu 189,99 USD/năm từ phụ nữ khoảng 66 tuổi.
  - Bảng tính: [research/2026-10-03-quang-cao-nam-dau.md](research/2026-10-03-quang-cao-nam-dau.md) §1.
- [x] ~~**Gói trả một lần:** cân nhắc 99–129 USD thay 79,99 USD, và cho nổi bật hơn.~~ Chốt 99,99, giữ vị trí thứ ba.
  - Nhóm 60–75 ghét gói tự gia hạn; 49% review 1–2★ của cả ngách là về tiền.
  - Giữ thứ tự hiện tại: gói năm chọn sẵn, trả một lần đứng thứ ba.
- [x] ~~**Trial 14 ngày hay 7 ngày** cho người đến từ quảng cáo~~ Chốt 09/10: giữ 14 ngày (app đọc số ngày từ ưu đãi của App Store, đổi ở ASC không cần sửa app).
- [x] ~~Khi chốt: sửa `.storekit` và App Store Connect, nhãn "Lowest monthly cost" (S2) tự tính lại, cập nhật app-context mục Price model.~~ `.storekit` + app-context xong 09/10 (nhãn S2 đã bỏ khỏi paywall gọn 08/10; "$4.17 a month" tính từ giá thật). App Store Connect: chủ app (revenuecat-setup.md).

**Việc khác:**
- [x] ~~**Tên mới**~~ Đổi 07/10/2026 sang **Good Footing**, khẩu hiệu "Steadier on your feet, at your own pace.": tên dưới icon, câu xin quyền, Welcome, "Good Footing Pro", `.storekit`, trang privacy, bản Việt; tên gom ở `iOS/App/Design/AppBrand.swift`. Bundle ID và mã sản phẩm giữ nguyên.
- [x] ~~Sau khi đổi tên (cần Mac): build, `LocalizationTests` `StoreConfigTests` `PaywallModelTests`, xem Welcome, paywall, Me, Journey, màn xin quyền~~ Xong 08/10 (Mac): build + 198/198 test xanh, ảnh đúng tên Good Footing.
- [ ] **Còn sau khi đổi tên:** thẻ chia sẻ, 4 hộp xin quyền của hệ thống, tên dưới icon trên iPhone nhỏ nhất (checklist đổi tên mục 6 bước 11); một lượt ảnh trên iPad (giới hạn 2 máy ảo nên chưa chạy). Icon, ảnh store, video preview làm lại với tên mới.
- [ ] **Quảng cáo:** chủ app đặt mức lỗ tối đa năm 1; quyết có cho app tự báo AdAttributionKit/SKAdNetwork (vượt luật nhẹ) trước giai đoạn Meta không; chọn cách làm video UGC. Kế hoạch: [research/2026-10-03-quang-cao-nam-dau.md](research/2026-10-03-quang-cao-nam-dau.md).
- [x] ~~**Rà chuẩn tập theo nhóm 65+**~~ Xong 06/10/2026: docs/reviews/2026-10-06-chuyen-gia-ra-soat-bai-tap-58-75.md (Steady set miễn phí, liều mới, chip unsteady, 4 bài Otago, thang vịn Pro, 2 clip, 2 tranh); STD đã cập nhật.
- [ ] **Nhân vật HLV và tranh (chốt 27/09: 55–58 tuổi):** có cần trông lớn hơn (khoảng 60–65) không? Hỏi trong test prototype (câu 4), chưa đổi asset.
- [ ] **Trường keywords ẩn có chữ `seniors` không** (vượt luật copy nhẹ, người dùng không thấy): chủ app quyết.
- [ ] **Từ nghiên cứu yes2next (07/10/2026, [research/2026-10-07-yes2next.md](research/2026-10-07-yes2next.md)):**
  - Mở [studio.com/yes2next](https://studio.com/yes2next) trên máy, ghi giá và cách bán của app Get Moving 50+ vào bảng Market.
  - Có làm "15-day Steady challenge" không (sự kiện trong app trên App Store + móc quảng cáo), làm trong 1.0 hay sau ra mắt?
  - Ảnh store và video preview: một khung người ngồi và người đứng cùng làm một động tác; thẻ buổi tập ghi "Seated or standing".
  - Phase 2: một bài 25–30 phút cho Pro; đi bộ theo mùa và dịp lễ Mỹ.
  - Gửi ảnh chụp trang playlist YouTube nếu cần tên và số video chính xác từng playlist.

**Còn mở sau rà soát 06/10/2026:**
- [ ] Chủ app xem clip S13 (`assets/video/A/S13/stills/`): chỉ một lần ngả lặp lại (2,17 s). Muốn làm lại: khoảng 24 credit mỗi lượt 720p.
- [ ] **V4-3 (nhón gót + nhấc mũi đứng vịn ghế) — chủ app 06/10/2026: tạm được, chưa ok lắm.** Bản trong app: một lần tạo Gemini 360p → 1080p, ghim gót, làm lại nhịp (`assets/video/A/V4-3/V4-3c_smooth.py`, 5,54 s). Còn: chuyển nhịp nhón gót → nhấc mũi chưa thật mượt; vệt mờ AI sau gót và trên sàn trước mũi giày; mép chân tường lệch ~2 px. Hướng làm lại: tạo 720p một lần (18 credit; prompt V4-3c trong `docs/scripts/P-production-prompts.md` §9.3, nhịp chậm đều hơn, có thể tách 2 clip cùng ảnh đầu), rồi chạy lại `V4-3_feet_pin.py` + `V4-3c_smooth.py`. Ngân sách video còn ~29,6/110.
- [ ] Chủ app xem 2 tranh `ex-back-walk`, `ex-walk-turn` (iOS/App/Assets.xcassets/Art).
- [ ] Nghe thử 25 câu mới (EN + VI): `assets/voice/cache-bella-v4`, `cache-vi-bella-v4`.

## Nguyên tắc chốt 28/09/2026, làm rõ 29/09/2026: code trước, test prototype trên bản build, rồi asset thật
Thứ tự: code hết MVP với asset tạm → test prototype 6–8 người (docs/research/prototype-test-plan.md) → sửa UI theo kết quả → sản xuất asset thật → nộp. Chữ kịch bản (A2–A10) không phải asset: cần trước milestone 4 (mục I4 dưới).
Sang manh-skill-plan với asset hiện có (6 clip, A1, giọng prototype). Nhạc AI, giọng gói thương mại, clip giãn cơ, tranh bưu thiếp làm song song hoặc sau khi code chạy; app dùng placeholder tới lúc đó.

## Trước khi đóng gói giọng vào app
- [ ] **Nâng ElevenLabs lên gói có giấy phép thương mại** (đề xuất Creator một tháng, khoảng 22 USD, đủ cả giọng và nhạc; xem [research/audio-api-options.md](research/audio-api-options.md); verify trên trang giá), rồi **tạo lại toàn bộ câu thoại** bằng gói mới. Cache hiện tại ở `assets/voice/cache/` chỉ dùng cho prototype. Khi nâng gói, nghe thử lại 3 ứng viên giọng thư viện (Elise Hart, Jane Hackett, Carol, id trong docs/video-skill-notes.md §5) so với Bella trước khi sản xuất hàng loạt.
- [ ] Chốt cách làm giọng cuối (TTS, thu người thật hay clone có đồng ý) sau test prototype.

## Video
- [x] ~~Duyệt kế hoạch nội dung 4 nhóm~~ Duyệt 30/09/2026: [plans/2026-09-30-content-4-groups.md](plans/2026-09-30-content-4-groups.md) §7 (8 chốt, 9 pending) + [scripts/P-production-prompts.md](scripts/P-production-prompts.md); dấu ✦ xử lý bằng `tools/video/crop_avoid_logo.py` (test 2 clip đạt). Chốt 30/09: #8b giữ 1688×950; #8c tạo lại V1 và V6 trong đợt A (guard `tools/video/crop_subject_check.py`), giữ V2–V5.
- [ ] **M2 xong phần tạo 30/09** (master + 7 khung, 0 credit, guard PASS; `assets/video/frames/M2-frames-sheet.jpg`) → **chủ app duyệt ảnh** + OK tạo lại thêm V5 → M3: 5 clip mẫu (báo credit trước) + `tools/video/retime.py`.
- [ ] **M3 xong phần tạo 30/09** (180 credit): V5 làm lại 2 lượt (lượt 2 sửa người lệch phải: khung MF-05c, tâm 40%; MF-04c cũng đã dời, dùng cho V9–V11/S11/B1), W2-1 (+easy/quick remap), V8 (làm lại sau lỗi chạm sàn, ghép 2 bên), S5, S5-hold (từ S5, 0 credit) đạt; B2 đi ngang dừng sau 4 lượt (bắt chéo chân) — kết quả `docs/scripts/P-production-prompts.md` §9, lưới `assets/video/M3/M3_review_grid.mp4`. **Chờ chủ app duyệt**; B2 chốt (a) 30/09: bỏ video đi ngang, dùng clip W2-2 side step (bắt buộc ở đợt A); sau đó tải 1080p cho clip đạt và sang M4/M5.
- [ ] Code kèm theo (sau M3): nhãn "QUICKER" cho cấp Seated (String Catalog + spec S11); màn xác nhận tay vịn Walking pad; câu setup ghế có tay vịn cho Joint replacement; chip Lower back thêm "or bone thinning"; `WalkVideo` chọn file theo động tác + pha; `ContentValidator` 6 quy tắc STD §7.
- [ ] Huấn luyện viên duyệt 6 clip V1-1 … V6-1 (V1 tay chạm ghế khi ngồi, V6 chân nhấc cao hơn kịch bản 2 inch).
- [x] ~~Viết A10 + kịch bản clip giãn cơ~~ Xong 29/09/2026: `docs/scripts/A10-stretch.md` (mục 6 là danh sách clip V7-1 … V7-7). Còn: báo giá credit, tạo 2 clip mẫu trước.
- [ ] Tạo nhạc AI 9–15 bản trên gói trả phí (mục 4 ở trên), chuẩn hoá độ to, kiểm tra lặp liền.
- [x] ~~Chốt gói Flow không watermark~~ Chốt 29/09/2026: tạm dùng Flow Pro hiện tại cho clip giãn cơ, nâng gói sau. Hệ quả: trước khi nộp phải tạo lại hoặc xuất lại toàn bộ clip trên gói không watermark (plan 9.2); giữ nguyên prompt, ảnh khung và mốc cắt để làm lại nhanh; không tự xoá dấu ✦.
- [ ] V3 bản dễ/khó, V4 ảnh khung tĩnh cho Reduce Motion và VoiceOver.

## Chương trình vững chân (duyệt 08/10/2026)
- [x] ~~Code theo [plans/2026-10-08-steady-program.md](plans/2026-10-08-steady-program.md)~~ Xong 08/10: cloud (milestone 1–2, 5–6) + Mac (build, test 198/198, chữ EN/VI 805/805, giọng A12, ảnh sáng/tối/XXL, sửa 5 lỗi cỡ chữ lớn). Còn: ảnh iPad.
- [x] ~~Thu giọng A12 EN/VI qua Vibi (5.3)~~ Xong 08/10; chủ app nghe lại (dòng đầu file).
- [ ] Song song: test thông điệp quảng cáo "steadier / getting up from a chair" so với "less stiff" (báo cáo chọn ngách mục kiểm chứng).

## Tài liệu và repo
- [ ] Chép tranh mẫu phong cách từ `Idea-Fitness/docs/ai-test/` vào `docs/design/reference/`.
- [ ] Tên store: **07/10/2026 chủ app chốt Good Footing** ("Good Footing: Gentle Workouts", phụ đề "Chair Yoga, Walks & Stretches"), trước khi test người dùng và luật sư. Còn: hỏi người test (câu 5, để bắt rủi ro "nghe như app cho người già" hoặc "chăm sóc bàn chân") → luật sư nhãn hiệu Mỹ (cả dòng nguồn infographic) → nộp đơn, đăng ký `goodfooting.app` / `getgoodfooting.com`, giữ tên trên App Store Connect. Nếu trượt: đổi `AppBrand.name` và các file ở checklist đổi tên.
- [ ] Viết Privacy Policy và Terms (cần cho HealthKit và subscription) trước khi nộp; URL ghi vào app-context.
- [ ] Cân nhắc Git LFS nếu thêm nhiều clip 1080p (repo hiện khoảng 109 MB).

## Backlog từ review 29/09/2026 (docs/reviews/2026-09-29-tai-lieu-ke-hoach.md)
Plan đã duyệt nên không sửa thầm; các mục dưới đưa vào task tương ứng khi bắt đầu task đó.
- [ ] **M5** Task 9.1 thêm Support URL và email liên hệ (ASC bắt buộc; S20 "Contact us"); ghi vào app-context Identity.
- [ ] **M8** Task 5.9 thêm biến thể `paywall-not-eligible`: tiêu đề "Everything in Good Footing Pro", nút "Continue"; sửa spec S08.
- [ ] **M9** Task 3.5 thêm bước: bấm Break khi màn hình khoá, chờ 3 phút, Resume từ màn khoá (Now Playing 3.7) — app không phát âm thanh có thể bị treo.
- [ ] **M10** Dựng file A1 5 phút cho mẫu thử M1 bằng `tools/video/build_preview.py` (giọng Bella, cảnh tĩnh S11) — cần cho test prototype.
- [x] ~~**M11**~~ `CFBundleDisplayName` đổi thành "Good Footing" (07/10/2026).
- [x] ~~**I1–I3, I5** chờ chốt~~ Chốt 29/09/2026 (app-context decisions log); đã ghi vào brief, spec, plan (dòng "Bổ sung 29/09" ở task 2.4, 2.7, 2.13, 5.8, 5.9, 6.2, 6.4, 6.9, 7.1), test plan.
- [x] ~~**I4**~~ Xong 29/09/2026 (nháp 1): A10 (55 câu, nguồn NHS/NIA), A2 tối thiểu (67 câu), A3/A5–A9 (80 câu), D2–D10. Bảng "Bộ nội dung tối thiểu cho demo MVP" ở content-plan §2. Chờ chủ app đọc duyệt.
- [x] ~~**I6**~~ Chốt 29/09/2026: dùng Flow Pro hiện tại; báo giá credit khi tạo clip giãn cơ, và ước thêm một lần tạo lại toàn bộ (6 + 6–8 clip) khi nâng gói.
- [x] ~~**I7**~~ Test plan đổi tuổi người tham gia thành 50–64 (+ tối đa 2 người 65–68).

## Kế hoạch code (đã duyệt 29/09/2026)
- [x] ~~Gọi `manh-skill-plan`~~ → `docs/plans/2026-09-29-mvp.md`: 113 task / 9 milestone, duyệt toàn bộ. Đã chốt: 0,05 dặm mỗi phút tập, hook `-ScreenshotMode`, không đo hiệu quả thông báo trong v1.
- [x] ~~Gọi `manh-skill-code` trên Mac~~ Xong 08/10.
- [ ] Trả lời 4 STOP AND ASK khi tới task: Team ID (1.1), mốc thang cây (2.5, mặc định 7 · 21 · 42), EULA Apple hay Terms riêng (5.10), hosting trang pháp lý (9.1, mặc định GitHub Pages).
- [ ] Chuẩn bị iPhone thật cho 3.5 (chạy khi khoá màn hình), 8.6 (tuyến ngoài trời), 8.8–8.9 (ghi dữ liệu và thử tự đếm).
