# Review tài liệu, nghiên cứu và kế hoạch MVP — 29/09/2026

_Trạng thái: DONE_WITH_CONCERNS (I4 kịch bản A2–A10 còn phải viết; I6 chấp nhận rủi ro tạo lại clip) · Cổng sang code: qua (Critical mở: 0) · Stage: manh-skill-review, chạy trên tài liệu trước khi có code_

## 1. Phạm vi & baseline
- Phạm vi: toàn bộ repo tại commit `e360fd3` (29/09/2026): app-context.md · docs/idea/gentle-walk-voice.md · docs/design/gentle-walk-screen-spec.html · docs/content-plan.md · docs/plans/2026-09-29-mvp.md · docs/todo.md · docs/research/* · docs/scripts/* · docs/video-skill-notes.md · docs/reviews/2026-09-28-tai-lieu.md · README.md · CLAUDE.md · tools/video/* · assets/ · iOS.
- Kế hoạch tham chiếu: docs/plans/2026-09-29-mvp.md (113 task, đã duyệt toàn bộ) · app-context.md: có.
- Baseline: chưa có code, chưa có build hay test; working tree sạch, 9 commit của `Cuong`. Repo 109 MB (mp4 trong git).
- Lăng kính chạy: 1 (đọc là "kế hoạch thay cho code"), 2 (spec màn hình), 3 (kế hoạch ngôn ngữ và quy tắc chữ), 4 (pháp lý theo bảng compliance của plan), 5 (quyền riêng tư theo plan và repo), 6 bỏ qua — không có code để đo.
- Sửa trực tiếp trong lúc thu thập: không. Sau báo cáo: chỉ Minor đồng bộ tài liệu (mục 6), không đổi quyết định sản phẩm.
- Cổng 1→2 và 2→3 (manh-skill-lifecycle/gates.md): đủ — app-context có Identity, Positioning 3 trụ + Not for, Market 9 đối thủ có ID, giá bằng chữ, locale; brief có GO + bảng bằng chứng 29 dòng có ngày; 4.3(a)/(b) có mitigation; plan có kiến trúc, compliance, task 2–5 phút, milestone, CLAUDE.md, checklist duyệt.

## 2. Sáu lăng kính

| # | Lăng kính | Đã chạy | Kết luận | Findings |
|---|---|---|---|---|
| 1 | Kế hoạch (thay code) | đọc 113 task, đối chiếu brief/spec/content-plan/todo, gates.md | Pass with notes | I1, I2, I3, I4, I5, M5, M8, M9, M11 |
| 2 | UI/UX (spec) | đọc spec S01–S21, trạng thái đặc biệt, danh sách frame; quy tắc 50+ | Pass with notes | M2, M3, M4 |
| 3 | Ngôn ngữ | Localization plan, Tone & copy rules, quét từ cấm A1/A4/spec | Pass | M1 |
| 4 | Pháp lý | bảng compliance của plan (3.1.1, 3.1.2, 2.5.4, 4.5.4, 5.1.1, 5.1.3, 1.4.1, 5.6.1, 4.3) + review-legal.md | Pass with notes | I6 |
| 5 | Quyền riêng tư & bảo mật | plan 1.9–1.11, 1.7, 6.10; grep secret; git ls-files | Pass | — |
| 6 | Hiệu năng & build | — | Skipped — chưa có code | — |
| — | Nghiên cứu (radar, Reddit, prototype) | đọc brief §4 dòng 24–29, prototype-test-plan, audio-api-options | Pass with notes | I7, M6, M10 |

### 2.1 Kế hoạch
- Đã chạy: đọc từng task; kiểm tra mỗi luật sản phẩm trong brief §8–§9 có task tương ứng; mỗi dòng compliance có task, file, bằng chứng. Quy tắc đã đúng: audio là composition liên tục (2.5.4), quyền xin đúng lúc (5.1.1(ii)), không SDK, không tài khoản, `cloudKitDatabase: .none`.
- Lỗ hổng: nhắc hết trial không có đường dự phòng (I1); mua lifetime khi gói còn tự gia hạn (I2); ngày nghỉ ở bản miễn phí (I3); lời giọng cho các buổi ngoài First Walk chưa có người viết (I4); thứ tự test prototype so với code (I5).

### 2.2 UI/UX
- Spec đủ 21 màn + biến thể, quy tắc 50+ (chữ ≥ 17 pt, vùng chạm 56 pt, không slider, không sheet nửa màn), Dynamic Type XXL cho 3 màn, iPad ngang cho player. Số liệu mockup còn ba chỗ lệch (M2, M3, M4).

### 2.3 Ngôn ngữ
- en-US, String Catalog + JSON nội dung, `Measurement<UnitLength>`, lint từ cấm (task 1.14). A1 30 câu và A4 41 câu không có từ cấm, không tuyên bố y khoa. Còn từ "streak" trong mô tả bản miễn phí (M1).

### 2.4 Pháp lý
- Plan gắn số guideline cho 27 mục; paywall có bộ ba (Restore, Terms/Privacy, giá thu thật nổi bật) và không dark pattern; thông báo 4.5.4; không tài khoản nên không cần 5.1.1(v). Điểm mở duy nhất là điều khoản công cụ video và dấu ✦ (I6): không phải luật Apple mà là điều khoản Google (verify), nhưng 9.2 đã chặn nộp nếu còn watermark.

### 2.5 Quyền riêng tư & bảo mật
- Không secret trong repo (`grep` key/token: chỉ có tên header trong script; `git ls-files` không có api_key/.env). Key ElevenLabs ở `~/.config`, ngoài repo. Purpose strings cụ thể cho 4 quyền; manifest CA92.1; entitlement chỉ HealthKit; dữ liệu sức khoẻ trên máy. Cache giọng gói Free nằm trong repo chỉ để prototype, đã ghi rủi ro.

## 3. Phát hiện (xếp theo mức độ)

### Critical
Không có.

### Important
I1 [Plan] [Important] docs/plans/2026-09-29-mvp.md task 5.12 · spec S16/S17 · brief §7 trụ 3 — Trụ "nhắc trước khi hết trial" chỉ chạy bằng thông báo, mà quyền thông báo xin ở S16 và người dùng có thể bấm "Not now" · khi đó ngày 12 không có gì nhắc, ngày 14 bị trừ tiền: đúng lời chê lớn nhất của đối thủ (brief §4 dòng 3) · sửa: thêm thẻ trên S17 từ ngày 10 của trial đến khi hết ("Your trial ends on Oct 11 · Manage"), không cần quyền; thêm vào test TodayModel (6.2) và trạng thái chụp `today-trial-ending`; ghi vào spec S17 và brief §7.
    Bằng chứng: task 5.12 "vẫn cần quyền thông báo"; spec S17 chỉ có trạng thái "Hết trial, chưa trả phí"; grep "trial ends in|trial-ending" trong spec và plan: 0 kết quả.

I2 [Plan] [Important] docs/plans/2026-09-29-mvp.md task 5.8, 5.9, 6.9 — Người đang có gói năm hoặc tháng mua thêm "One payment" thì gói cũ vẫn tự gia hạn · bị trừ hai lần, trái trụ 3 · sửa: khi có subscription đang hoạt động, thẻ One payment ghi "Your subscription keeps renewing until you cancel it"; sau khi mua lifetime hiện S21 với lý do; S20 hiện cả hai dòng; thêm test `lifetimeWhileSubscribedShowsCancelGuide` vào 5.8.
    Bằng chứng: plan Decisions "lifetime thắng mọi gói khác" và task 6.9 chỉ có hai trạng thái Free trial / Lifetime; không có tình huống lifetime + gói còn hạn.

I3 [Plan] [Important] app-context Price model · brief §11 tuần mẫu · spec S07, S17, S20 · plan 2.4, 2.7, 7.1 — Bản miễn phí không có tuần mẫu và S20 ẩn "Your week", nhưng S07 vẫn hiện "2 rest days a week" cho mọi người, ActivityCalendar tính "2 ngày nghỉ hợp lệ", NotificationPlanner "không gửi ngày nghỉ" · với người miễn phí, ngày nghỉ là gì? Không định nghĩa → test 2.4/2.7/7.1 không viết được cho free · sửa: chốt "miễn phí có 2 ngày nghỉ mặc định Thứ bảy + Chủ nhật, không đổi được (đổi ngày là tính năng Pro)", ghi vào app-context, brief §11, spec S07/S17/S20, plan 2.7/7.1.
    Bằng chứng: plan 2.7 "free → ngày nào cũng walk"; spec S20 "Your week … Bản miễn phí: ẩn"; spec S17 "Bản miễn phí: bảy chấm không icon" nhưng dòng "2 rest days are part of the plan" không ghi ẩn.

I4 [Plan] [Important] docs/plans/2026-09-29-mvp.md task 1.5, 2.8, 2.11, 4.13 · content-plan §2 · todo — Plan nạp voice-lines.json chỉ có A1 (30 câu) + A4; nhưng SessionBuilder (2.8) dựng buổi đi bộ theo cấp × cường độ 5–10 phút, ngày ghế, ngày giãn cơ, và 4.13 chạy trọn luồng · các buổi ngoài First Walk không có lời (A2 khoảng 150 câu, A5 số đếm, A6 động viên, A7 an toàn, A9 check-in, A10 giãn cơ) và không có task hay người viết; "code trước, asset sau" đúng với file âm thanh, không đúng với chữ kịch bản vì timeline và test cần chữ · sửa: thêm mục todo "Viết A2 tối thiểu (khoảng 60 câu, tái dùng 26 câu 'Dùng lại' của A1), A5, A7, A9, A10 trước milestone 4"; plan 1.5 ghi rõ nạp thêm khi có; DEBUG đọc bằng `AVSpeechSynthesizer` (3.3) đã lo phần âm thanh.
    Bằng chứng: task 1.5 "voice-lines.json (30 câu A1 + câu A4)"; content-plan §2 A2–A10 chưa có bản nháp trừ A1, A4; todo không có mục viết kịch bản ngoài A10.

I5 [Plan] [Important] brief §11 "Thứ tự phase" · todo "Nguyên tắc chốt 28/09" · research/prototype-test-plan.md — Ba tài liệu nói ba thứ tự: brief "0 test prototype → 1 MVP"; todo và app-context "code trước, asset sau"; test plan "trước khi viết phần còn lại của kịch bản và code MVP" · tiêu chí đạt của test có thể đổi thiết kế đã lên task (video vào player đi bộ → 4.4; giãn cơ dùng video từ đầu + chuông đổi bên → 4.8; kéo khoảng im 12 giây → 2.11) · sửa: chốt "test prototype chạy song song milestone 1–3 (core, audio, không phụ thuộc UI), kết quả về trước khi bắt đầu milestone 4"; ghi cùng một câu vào brief §11, todo, test plan.
    Bằng chứng: brief dòng 130; todo dòng 12; prototype-test-plan dòng 2.

I6 [Legal] [Important] content-plan §8 bước 3 và 7 · todo mục Video · plan 3.9, 9.2 — 6 clip đang có mang dấu ✦ của Flow; 9.2 chặn nộp khi còn watermark; nhưng bước tiếp theo là tạo 6–8 clip giãn cơ trên cùng công cụ trước khi chốt gói không watermark · nếu chốt sau, phải làm lại 12–14 clip và QA lại · sửa: đưa "chốt gói Google AI Ultra hoặc công cụ khác (verify điều khoản thương mại và watermark)" lên trước V2b trong content-plan §8 và todo; ghi rõ 6 clip hiện có là bản dựng thử, sẽ tạo lại; ước chi phí credit cho lần tạo lại khi báo giá.
    Bằng chứng: video-skill-notes §5c "Dấu ✦ vẫn có trên gói Pro"; plan 9.2 "clip không watermark" là điều kiện GREEN; content-plan §8 bước 3 tạo 2 clip giãn cơ mẫu trước bước chốt công cụ. (Điều khoản Google: verify trước khi mua.)

I7 [Research] [Important] docs/research/prototype-test-plan.md mục Người tham gia · brief §12 — Tuyển "55–70 tuổi" (brief ghi 55–75) trong khi người dùng mục tiêu là 50–64 và app né nhóm 65+ có Bold/SilverSneakers miễn phí · kết quả 5 tiêu chí đạt sẽ đo trên nhóm khác nhóm mua · sửa: tuyển 50–64, cho phép tối đa 2 người 65–68 để so sánh; sửa cả brief §12.
    Bằng chứng: app-context Target user "50–64"; Not for "65+ đã có Bold/SilverSneakers"; test plan "55–70".

### Minor
M1 [L10n] [Minor] app-context.md Price model · brief §8 — Bản miễn phí ghi có "streak" trong khi plan Decisions và brief §9 chốt "ngày hoạt động thay streak, không bao giờ mất chuỗi" · sửa chữ thành "ngày hoạt động".
    Bằng chứng: app-context dòng 47; brief dòng 80; plan Decisions "ngày hoạt động thay streak".
M2 [UI/UX] [Minor] spec S15, S19 · todo #1 · plan 2.5, 6.8 — Spec còn "Lên cấp mỗi 7 ngày hoạt động" và "Sprout · 1 day to Sapling"; plan 6.8 chờ "8 days to Sapling" theo mốc mặc định 7 · 21 · 42; todo #1 vẫn "Chờ OK" · chốt mốc rồi sửa spec một lần.
    Bằng chứng: spec dòng 558, 638; plan dòng 737.
M3 [UI/UX] [Minor] spec S15 — "+0.6 mi" cộng vào 1.8 (S17/S18) thành 2.4, còn 2.6 dặm tới Brooklyn Bridge (mốc 5.0), không phải "1.2 mi" · sửa số.
    Bằng chứng: spec dòng 548–550, 586; journeys.json trong plan 1.5: Brooklyn Bridge 5.0.
M4 [UI/UX] [Minor] spec S16 thẻ 1 — Copy nói Apple Health dùng "to measure outdoor walks", nhưng đo ngoài trời không GPS dùng Motion (CMPedometer, plan 8.4), Health chỉ đọc bước cả ngày · sửa copy: bỏ vế đo ngoài trời; giữ purpose string 1.9 (đã đúng).
    Bằng chứng: spec dòng 571; plan 8.4; plan 1.9 `NSMotionUsageDescription`.
M5 [Plan] [Minor] plan 9.1, 9.4 · app-context Identity · spec S20 "Contact us" — Không có task cho Support URL và email liên hệ; App Store Connect bắt buộc Support URL khi nộp · thêm vào 9.1 (trang support hoặc mailto) và app-context.
    Bằng chứng: app-context dòng 7 "Support … chưa có"; plan 9.1 chỉ privacy/terms.
M6 [Research] [Minor] app-context decisions log 28/09 (b) — Ghi nhạc "Suno/Udio", nhưng tra cứu cùng ngày chọn Eleven Music (todo #4, research/audio-api-options.md); chưa có dòng log mới · thêm dòng 28/09 hoặc 29/09 ghi đổi sang Eleven Music, kèm phương án rẻ hơn (Gemini Lyria) để chủ app chọn.
    Bằng chứng: app-context dòng 102; todo #4.
M7 [Plan] [Minor] README.md · /Users/cuong/CascadeProjects/CLAUDE.md mục "Documentation Management" — README nói "chưa có code, stage 1" trong khi plan đã duyệt (stage 2 xong); thư mục docs không có 7 file theo quy ước cha (project-overview-pdr, code-standards, codebase-summary, design-guidelines, deployment-guide, system-architecture, project-roadmap) · cập nhật README; ghi rõ dự án dùng cấu trúc manh-skill (brief · app-context · plan) thay cho 7 file, để người đọc không tìm nhầm.
    Bằng chứng: README dòng 3; `ls docs`.
M8 [Plan] [Minor] plan 5.9 · spec S08 — Trạng thái không đủ điều kiện trial chỉ ghi "không có dòng trial"; tiêu đề "Try everything free for 14 days" và nút "Start free trial" chưa có biến thể · thêm tiêu đề "Everything in Gentle Walk Pro" và nút "Continue" cho `paywall-not-eligible`.
    Bằng chứng: plan dòng 236; spec S08.
M9 [Plan] [Minor] plan 3.5, 3.7 — Bằng chứng chạy nền chỉ đo phát liên tục 5 phút; chưa có bước "bấm Break khi màn hình khoá, chờ 3 phút, Resume từ màn khoá" — lúc không phát âm thanh app có thể bị treo · thêm bước vào 3.5 và tình huống vào 3.7.
    Bằng chứng: plan 3.5 bước 1–2.
M10 [Research] [Minor] prototype-test-plan.md bảng Mẫu thử M1 · todo — "TTS chưa dựng thành file 5 phút" nhưng `tools/video/build_preview.py` đã dựng được giọng + phụ đề; todo không có việc này · thêm mục todo "dựng A1 5 phút bằng build_preview (giọng Bella, cảnh tĩnh)".
    Bằng chứng: test plan dòng M1; todo mục "Trước khi đóng gói giọng".
M11 [Plan] [Minor] plan 1.8 — `CFBundleDisplayName` = "Gentle Walk" trong khi tên làm việc là "Gentle Walk 50+" và tên store chưa chốt (trademark, todo) · ghi chú "tên hiển thị tạm, đổi khi chốt tên store" để không ai coi là quyết định.
    Bằng chứng: plan dòng 183; app-context Identity.

## 4. Cần tự kiểm trong App Store Connect / dịch vụ ngoài
- [ ] ASC: 3 IAP `com.kmd.goodfooting.pro.yearly` (intro offer 2 tuần), `.pro.monthly`, `.pro.lifetime` tạo và "Ready to Submit" trước bản 1.0 (plan 9.4).
- [ ] ASC: Support URL, Privacy Policy URL, EULA (chuẩn Apple hay riêng — STOP AND ASK 5.10).
- [ ] ASC: bảng age rating trả lời theo 9.4; App Privacy "Data Not Collected" chỉ đúng khi không có gì rời máy — xác nhận HealthKit đọc/ghi trên máy không tính là thu thập (verify hướng dẫn hiện hành).
- [ ] ElevenLabs: gói có giấy phép thương mại (Creator hoặc trả theo lượt — verify PAYG có kèm quyền thương mại), lưu hoá đơn; tạo lại toàn bộ giọng.
- [ ] Google Flow: gói không watermark hiển thị và điều khoản thương mại (verify trên trang gói); nếu không, đổi công cụ trước khi tạo clip giãn cơ.
- [ ] Trademark tên app; tên store.
- [ ] Thiết bị thật: 3.5 (khoá màn hình 5 phút), M9 (Break khi khoá), 3.7 (Now Playing), 8.6 (tuyến ngoài trời), 8.8–8.9 (tự đếm ±1).

## 5. Điểm tốt
- Bảng compliance trong plan: 27 luật, mỗi luật có số guideline, task, file và bằng chứng mong đợi; quyền xin đúng lúc và composition âm thanh liên tục là hai chỗ dễ bị reject nhất, đã thiết kế từ đầu.
- Quyết định phương pháp tập (giãn cơ GO, tai chi phase 2, wall pilates/somatic NO-GO) có 6 dòng bằng chứng với số app, số review và ngày, không phải cảm tính.
- 6 clip có số đo QA (đầu, máy lệch, nối, đối xứng chân) và cùng khung máy; tài liệu ghi cả lỗi cũ làm bài học.

## 6. Nhật ký sửa
| Finding | Hành động | Chạy lại lăng kính | Kết quả |
|---|---|---|---|
| M1 | sửa chữ "streak" → "ngày hoạt động" trong app-context, brief | 3 | Pass |
| M3 | spec S15 "1.2 mi" → "2.6 mi" | 2 | Pass |
| M4 | spec S16 bỏ vế "measure outdoor walks" | 2 | Pass |
| M6 | thêm dòng decisions log 29/09 về Eleven Music | — | ghi |
| M7 | README cập nhật giai đoạn và ghi chú cấu trúc docs | — | ghi |
| M10, M5, M8, M9, M11 | thêm vào docs/todo.md mục "Backlog từ review 29/09" (plan đã duyệt, không sửa plan thầm) | — | mở |
| I1 | chủ app chốt: thẻ Today từ ngày 10 → app-context, brief §7, spec S17, plan 2.13/6.2/6.4 + trạng thái chụp | 1, 2 | Pass — ghi |
| I2 | chủ app chốt: cảnh báo + S21 sau mua → app-context, brief §8, spec S08/S20, plan 5.8/5.9/6.9 | 1, 4 | Pass — ghi |
| I3 | chủ app giao chọn theo văn hoá → chốt 2 ngày nghỉ cố định T7+CN cho free (lý do ở brief §11) → app-context, brief, spec S07, plan 2.4/2.7/7.1 | 1 | Pass — ghi |
| I4 | thêm todo: viết A2/A5/A7/A9/A10 trước milestone 4; content-plan §8 bước 3 | — | mở (việc) |
| I5 | chủ app chốt: code hết MVP rồi test → brief §11, todo, test plan | 1 | Pass — ghi |
| I6 | chủ app chốt: tạm dùng Flow Pro, nâng gói sau; ghi hệ quả tạo lại clip trước khi nộp vào todo, content-plan, app-context | 4 | chấp nhận (rủi ro ghi rõ) |
| I7 | test plan: 50–64 (+2 người 65–68); brief §12 | — | Pass — ghi |
| M2 | chủ app chốt 7 · 21 · 42 → spec S15/S19, từ vựng, brief §12, app-context, plan 2.5 | 2 | Pass — ghi |

## 7. Decisions log
29/09/2026 · review tài liệu + kế hoạch MVP · Critical 0 · Important 7 (chốt và ghi 6 / còn việc 1: I4 kịch bản) · Minor 11 (sửa 6, backlog 5) · cổng sang code: qua có concerns · tiếp: gọi `manh-skill-code` từ Task 1.1; viết A2/A5/A7/A9/A10 trước milestone 4.
