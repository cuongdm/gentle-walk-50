# Bàn giao cho phiên Mac: Chương trình vững chân (Steady program)
_08/10/2026 · Từ phiên cloud "Gentle Walk 50+ git setup - Cloud" sang phiên local "Gental Walk Main - Local" · Kế hoạch: [docs/plans/2026-10-08-steady-program.md](../plans/2026-10-08-steady-program.md)_

## 0. Đọc trước
1. `CLAUDE.md`, `app-context.md`, kế hoạch ở trên (mỗi task có dòng **Evidence** ghi trạng thái hiện tại).
2. File này: việc nào đã chạy được trên cloud, việc nào **chỉ mới viết, chưa từng build**, và lệnh để kiểm.
3. Luật câu chữ của chương trình: [docs/design/steady-claims.md](../design/steady-claims.md). Không hứa phòng ngã, xương, giảm đau. Không bảng chuẩn theo tuổi. Tự kiểm tra chỉ so với chính mình, cùng cách làm.

## 1. Nhánh và trạng thái
- Nhánh: `claude/tender-planck-e4oiyx` (chưa merge vào `main`; merge chỉ khi chủ app nói có).
- Lấy về: `git fetch origin claude/tender-planck-e4oiyx && git checkout claude/tender-planck-e4oiyx`.
- Cloud là Linux, không có Xcode. **Không file Swift nào trong `iOS/App` hay `iOS/GentleWalkTests` của nhánh này từng được biên dịch.** Phần core (`iOS/Packages/GentleWalkCore`) và tool Python thì đã chạy.

| Phần | Trạng thái | Bằng chứng |
|---|---|---|
| Nhóm 1 (lint, bảng câu, câu minh bạch, manifest) | XANH | `copy_lint` 0 findings; `test_copy_lint` OK |
| Nhóm 2 (core) + core mới của nhóm 4–5 | XANH trên Docker `swift:6.2-noble` | `Test run with 191 tests in 40 suites passed` |
| Nội dung (A12, thông báo `nt.check.*`, bản Việt) | XANH | `build_content.py --check` → `stale: none` |
| Nhóm 3 (SchemaV2, migration, RepLadderStore, xoá dữ liệu) | VIẾT XONG, CHƯA BUILD | commit `82a8c08` |
| Nhóm 4 (giao diện, 15 task) | VIẾT XONG, CHƯA BUILD | commit sau `82a8c08` |
| Nhóm 5.4 (chữ giao diện EN + VI) | bản Việt sẵn, cần Mac trích khoá | `docs/i18n/vi/ui-extra-8.json` |
| Nhóm 6 (tài liệu phát hành) | XONG | screenshots.md, checklist.md, privacy.html, app-context, todo |

## 2. Lệnh chạy theo thứ tự (trong `iOS/`)
```bash
cd iOS
xcodegen generate
# /tmp/gw-dd: capture_states.sh và extract_sources.py đọc bản build ở đây
xcodebuild build -project GentleWalk.xcodeproj -scheme GentleWalk -destination 'platform=iOS Simulator,name=iPhone 17' \
  -derivedDataPath /tmp/gw-dd SWIFT_EMIT_LOC_STRINGS=YES
```
Sửa hết lỗi biên dịch trước (xem mục 4 các chỗ dễ lỗi). Sau đó:
```bash
# Core (đã xanh trên cloud, chạy lại trên Mac)
swift test --package-path Packages/GentleWalkCore

# Test app của chương trình, từng suite một
for S in PersistenceTests RepLadderStoreTests DataEraserTests TodayModelTests SelfCheckFlowModelTests \
         SessionAudioComposerTests NotificationSchedulerTests DesignTokenTests CaptureHookTests LocalizationTests; do
  xcodebuild test -project GentleWalk.xcodeproj -scheme GentleWalk \
    -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:GentleWalkTests/$S || break
done
# Rồi toàn bộ suite app một lần (không suite nào được đỏ thêm so với trước)
xcodebuild test -project GentleWalk.xcodeproj -scheme GentleWalk -destination 'platform=iOS Simulator,name=iPhone 17'
```
Mong đợi: `** TEST SUCCEEDED **`. `ReleaseContentTests` chỉ chạy khi `RELEASE_CHECK=1` và sẽ đỏ tới khi thu giọng A12 (bình thường).

## 3. Chữ giao diện EN + VI (Task 5.4)
Khoá mới chưa có trong `Localizable.xcstrings` (Xcode thêm khi build). Bản Việt đã viết sẵn theo đúng khoá (dạng `%lld`, `%@`):
```bash
# gốc repo, sau bản build ở mục 2 (có SWIFT_EMIT_LOC_STRINGS=YES, -derivedDataPath /tmp/gw-dd)
python3 tools/i18n/extract_sources.py /tmp/gw-dd # cập nhật docs/i18n/source/ (ui.json …)
python3 tools/i18n/apply_catalog.py vi           # ghi cột vi từ docs/i18n/vi/ui-*.json
python3 tools/i18n/apply_catalog.py vi --check && python3 iOS/scripts/xcstrings_coverage.py iOS/App/Localizable.xcstrings en,vi && python3 tools/lint/copy_lint.py
python3 tools/i18n/scan_literals.py              # literal chưa vào catalog (vd. nhánh `? :`) → thêm vào docs/i18n/source/ui-manual.json
```
Mong đợi: `0 missing; 0 problems`, coverage 0, `0 findings`. Khoá nào Xcode trích khác với khoá trong `ui-extra-8.json` (vd. dấu `’`, `%lld` thành `%d`) thì sửa khoá trong file Việt, không sửa code.

## 4. Chỗ dễ lỗi khi build (đọc trước khi sửa)
1. **SwiftData V1/V2** (`iOS/App/Persistence/SchemaV2.swift`): V2 chép nguyên 7 model của V1 và thêm `ProgramState`, `SelfCheckRecord`. Typealias toàn app trỏ sang `SchemaV2.*` (đã xoá khỏi `SchemaV1.swift`). Nếu migration nhẹ báo lỗi checksum/hash: không sửa `SchemaV1`, không xoá version cũ (luật CLAUDE.md). Test `migratesV1StoreKeepingRows` phải xanh (1/5/1/0 dòng).
2. **Swift 6 concurrency:** `MigrationPlan.stages` là thuộc tính tính toán (MigrationStage không Sendable). `SelfCheckAudioPlayer` gọi `SessionAudioComposer.compose` từ MainActor giống `AVPlaybackEngine.load`.
3. **`AppCover`** thêm `.selfCheck(SelfCheckFlowModel)` và `.programFinished`; **`TodayRoute`** thêm `.program`. Mọi `switch` cũ đều có `default` hoặc đã cập nhật (`CoverView`, `MainTabView`).
4. **`NotificationKind.selfCheck`** (core) đã có từ nhóm 2; app chỉ thêm công tắc và `selfCheckDue` trong `AppModel.plannerInput()`.
5. **`ProgressSnapshot.sitToStand` đã bỏ**, thay bằng `selfChecks: [SelfCheckPoint]` và `supportLevels`; `SitToStandChart` thay bằng `SelfCheckChart` + `SupportLevelsCard`.
6. **`WorkoutView`/`CompleteView`** có tham số mới (`onSelfCheck`, `onSelfCheckLater`, `levelUpLine`, `selfCheckInvite`) đặt đúng thứ tự khai báo; nếu trình biên dịch kêu "argument must precede", sửa thứ tự gọi.
7. **`TodayInput`** thêm 4 trường có mặc định ở cuối (test cũ dựng tay vẫn biên dịch).
8. `WorkoutSessionModel.ladderExercises` = `SupportLadder.exercises.union(RepLadder.exercises)`: ghi nhận cả bài thăng bằng và 3 bài đếm số lần cho hai thang.
9. Không dùng API mới hơn iOS 18 (đã tránh `alert(item:)`, `reorderable()`…). `confirmationDialog`, `accessibilityAdjustableAction`, `Chart` đều có từ iOS 15–16.

## 5. Ảnh chụp cần lấy (Task 4.x)
```bash
cd ..   # gốc repo
iOS/scripts/capture_states.sh /tmp/gf-steady "iPhone 17" today-program today-check-due program selfcheck-intro \
  selfcheck-timer selfcheck-count progress-checks complete-check-invite complete-reps-up program-finished \
  chair-player chair-player-dark onboarding-welcome onboarding-plan me
```
Mỗi trạng thái: sáng, tối (`<state>@dark`), cỡ chữ lớn nhất (`<state>@xxl`), và một lượt trên máy ảo iPad. Script cài app từ `/tmp/gw-dd` (bản build mục 2). Kiểm bằng mắt và accessibility tree:
- `today-program`: "Week 3 of 12", "Stage 1 · Steady base", "Plan ›"; thẻ tự kiểm tra một dòng "is in 12 days".
- `today-check-due`: thẻ "Your 2-week check is ready" + "Start my check".
- `program`: 4 chặng, chặng 1 viền xanh, 7 mốc (0, 2 … 12), dòng "general fitness".
- `selfcheck-intro`: 4 lời dặn, 3 bước, "This is not a medical test.", "I'm ready" / "Not today".
- `selfcheck-timer`: đồng hồ đang đếm (bắt đầu lùi 20 s), "Stop early", "This hurts".
- `selfcheck-count`: − / + 72 pt, số lớn, "Yes, with my hands" / "No", "Last time: 8", "Save".
- `progress-checks`: cột Week 0/2/4 = 7/8/9, "+2 since your first check", thẻ "Hands on the chair".
- `complete-check-invite`: thẻ "Want to see where you start?" (ngay dưới so sánh, trên hành trình).
- `complete-reps-up`: dòng "You did these in full twice in a row. Next time: Sit-to-stand, 10 times."
- `program-finished`: "+2 since your first check", hai nút.
- Vùng chạm ≥ 56 pt; chữ ≥ 17 pt; không chữ bị cắt "…".
Ghi đường dẫn ảnh và kết quả vào dòng **Evidence** của từng task trong kế hoạch (đổi "VIẾT XONG, CHƯA BUILD" thành `DONE` hoặc `DONE_WITH_CONCERNS`).

## 6. Quyết định nhỏ đã tự chốt khi code (báo chủ app, đổi được)
- Trạng thái chụp `complete-reps-up` thay tên `complete-level-up` trong kế hoạch (tên cũ đã là màn lên cấp cây).
- Màn Kế hoạch dùng `TodayRoute.program` (cùng stack Hôm nay) thay kiểu `ProgramRoute` riêng.
- Tuần 1 bắt đầu từ ngày của buổi tập đầu tiên; người đã tập trước khi có chương trình cũng vậy (`AppModel.ensureProgram`, gọi trong `reload()`).
- Thẻ mời tuần 0 hiện ở **mọi** màn Hoàn thành cho tới khi làm hoặc bấm "Later" (Later ẩn 2 ngày, sau đó Hôm nay hiện "ready").
- Thẻ tự kiểm tra trên Hôm nay hiện cả khi còn xa ("is in 12 days", một dòng nhỏ) theo test của kế hoạch; nếu thấy chật, đổi `TodayModel.checkCard` để chỉ hiện khi ≤ 3 ngày.
- Tiến bộ hiện mức vịn ở cường độ Steady (thẻ chỉ để xem, không phải mức của hôm nay).
- "Sang chặng mới" chưa có dòng riêng ở màn Hoàn thành (chỉ thẻ Hôm nay đổi chặng); câu HLV cho chặng để ở mục đề xuất của A12.
- Bản privacy trong app (`PaywallLegalFooter`) chưa thêm câu tự kiểm tra; trang web đã có.

## 7. Việc của chủ app (không làm thay)
1. Duyệt kịch bản `docs/scripts/A12-steady-program.md` (3 câu mới).
2. Thu 3 câu EN + VI qua Vibi; rồi `python3 tools/voice/qc_lines.py`, `python3 tools/i18n/build_content_overlay.py vi --cache assets/voice/cache-vi-bella-v4` (**luôn kèm `--cache`**: thiếu nó, overlay xoá file ghi âm Việt đã có khỏi `content.vi.json`).
3. Luật sư nhãn hiệu cho tên Good Footing; kiểm việc đổi tên trên Mac (mục "Sau khi đổi tên" trong `docs/todo.md`).
4. Merge nhánh vào `main` khi các test và ảnh ở trên đã xong.

## 8. Commit
Danh tính: `Cuong <cuongdm@live.com>` (đã đặt trong repo-local config). Không thêm `Co-Authored-By` hay "Generated with". Không push `main`, không tag nếu chủ app chưa nói có.
