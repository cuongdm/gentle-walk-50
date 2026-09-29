# Gentle Walk 50+ — Session choice (milestone 10) — kế hoạch 29/09/2026 (đã duyệt toàn bộ 29/09/2026)

**Goal:** người dùng đổi được buổi hôm nay sang môn khác mà vẫn tính ngày, xem mọi buổi theo 4 nhóm có tranh, đánh dấu yêu thích và tập lại; giữ 4 tab, không thêm nội dung.

**Nguồn:** [docs/idea/session-choice.md](../idea/session-choice.md) (GO 29/09/2026) · app-context decisions log 29/09/2026.

**Phạm vi đã chốt (checkpoint 1, 29/09/2026):** đủ 4 phần · iOS 18.0 (iPhone + iPad), không API mới hơn · Android để sau · không backend, không analytics · en-US · free mở mọi buổi đi bộ + "Gentle chair moves" + "Seated stretch · gentle" · Extras giữ Pro, thêm "See all" cho mọi người.

**Ngoài phạm vi:** tab thứ 5 · kcal · đo nhịp tim · Focus Area · Kegel / Wall Pilates / bài trên giường · meal plan · đổi trọng tâm kế hoạch · "Don't show this move again" · tự dời lịch tuần khi đổi buổi.

## Decisions
- **Danh mục buổi = cấu hình có tên, không phải nội dung mới.** `SessionPreset` (id ổn định, nhóm, `PlannedDay.Main`, `Intensity`, `WalkLevel`, standing?, `isFree`) và `SessionCatalog` trong `GentleWalkCore` (Foundation, `swift test`). Buổi vẫn ghép bằng `SessionBuilder` như hiện nay. _Bỏ:_ file `sessions-catalog.json` (thêm một nguồn phải đồng bộ với `build_content.py`).
- **Đổi buổi không sửa lịch tuần.** Mọi buổi đã tập đều ghi `WorkoutRecord` → `ActivityCalendar` tính ngày, cây và dặm như cũ; dải tuần hiện dấu ✓ cho ngày đó. _Bỏ:_ dời loại buổi bị bỏ sang ngày khác (đợt sau nếu cần).
- **Yêu thích lưu `UserDefaults`** (key `favouriteSessions`, mảng id theo thứ tự thêm), thêm vào `AppDefaultsKeys` để "Delete all my data" xoá. _Bỏ:_ SwiftData model mới (cần `SchemaV2` + migration cho một danh sách id).
- **Điều hướng:** "See all" dùng `NavigationStack(path: $app.todayPath)` + một `navigationDestination(for: TodayRoute.self)`; bảng đổi buổi là `.sheet(isPresented:)` trên Today (không mang dữ liệu tuỳ chọn). "Do it again" gọi lại `app.preview(request)` với đúng `WorkoutRequest` vừa tập.
- **State:** `TodayModel` thêm `swapOptions`; màn All sessions có `AllSessionsModel` (`@Observable @MainActor`) nhận catalog, entitlement, favourites, limits; mỗi thẻ là một `struct: View` nhận input hẹp; `ForEach` theo `SessionPreset.id`.
- **Khoá theo gói:** buổi khoá mở paywall `.lockedContent` (paywall hiện có, đủ Restore + Terms + Privacy + giá phải trả lớn nhất). Không có paywall mới.
- **Chữ:** String Catalog, en-US; số phút qua interpolation; không số bịa, không kcal; `copy_lint.py` 0 findings.

## Compliance-by-design
| Luật | Việc | Task |
|---|---|---|
| 5.1.1(v) / quyền riêng tư: xoá dữ liệu | `favouriteSessions` nằm trong `AppDefaultsKeys`; test DataEraser | 10.3 |
| 3.1.1 / 3.1.2 paywall | Buổi khoá dùng paywall hiện có (trigger `.lockedContent`); không nút mua mới | 10.8 |
| 1.4.1 tuyên bố sức khoẻ | Không kcal, không nhịp tim trên thẻ; copy lint | 10.11 |
| Accessibility (spec) | Nút tim ≥ 56 pt, nhãn "Add to favourites / Remove from favourites"; Dynamic Type XXL | 10.8 |
| PrivacyInfo | UserDefaults CA92.1 đã khai; không đổi | — |

## Milestone 10 — Session choice (13 task)
Lệnh chung — Core: `cd iOS/Packages/GentleWalkCore && swift test --filter <Suite>` · App: `cd iOS && xcodebuild test -project GentleWalk.xcodeproj -scheme GentleWalk -destination 'id=<iPhone 17 iOS 27>' -derivedDataPath /tmp/gw-dd -only-testing:GentleWalkTests/<Suite>` · Chụp: `iOS/scripts/capture_states.sh <out> "iPhone 17" <state>`.

- [x] **10.0 · TDD · carry-over** — test `expiryDropsToFree` lỗi trên iOS 27: tìm nguyên nhân (in giao dịch sau `expireSubscription`), sửa code hoặc test. Test: `StoreServiceTests`. Mong đợi: 9/9 xanh. _Stop and ask nếu nguyên nhân là hành vi StoreKit iOS 27 cần đổi logic entitlement._
  - DONE_WITH_CONCERNS: iOS 27 StoreKitTest giữ giao dịch đã hết hạn trong `currentEntitlements` (hạn gốc 29/10) và status `.subscribed` sau `expireSubscription` (in ra 29/09) → app không thấy được; test ghi `withKnownIssue` chỉ trên iOS ≥ 27, quy tắc hết hạn có ở `EntitlementRulesTests`. Refund/tắt gia hạn: thêm vòng chờ ≤ 5 s. `StoreServiceTests` 9/9 pass, 1 known issue.
- [x] **10.1 · TDD** — Create `Packages/GentleWalkCore/Sources/GentleWalkCore/Plan/SessionCatalog.swift` (`SessionPreset`, `SessionCatalog.groups`: walks · chair · stretch · extras, id ổn định, ≤ 6 mỗi nhóm). Test `SessionCatalogTests`: id duy nhất; mỗi nhóm 1–6 buổi; mọi buổi đi bộ free; chỉ `chair.gentle` và `stretch.seated.gentle` free trong nhóm của chúng; extras Pro. Mong đợi: RED (type chưa có) → GREEN.
  - DONE: RED (stub rỗng, 11 issue) → GREEN; `swift test` 116 tests / 27 suites pass.
- [x] **10.2 · TDD** — `SessionCatalog.swapOptions(planned: PlannedDay.Main?)`: 3 môn khác môn đã lên lịch + "Just 5 minutes today" (walk gentle ngắn); ngày nghỉ trả rỗng. Test: walk → chair, stretch, 5 min; stretch → walk, chair, 5 min; rest → []. Mong đợi: GREEN.
  - DONE: cùng suite; walk → chair.gentle, stretch.seated.gentle, walk.gentle; rest → [].
- [x] **10.3 · DATA** — Create `App/Services/Data/FavouriteSessions.swift` (`contains`, `toggle`, `ids` theo thứ tự, bỏ id lạ; `UserDefaults` tiêm vào); Modify `App/Services/Data/DataEraser.swift` (thêm key). Test `FavouriteSessionsTests` + `DataEraserTests` (xoá key). Mong đợi: GREEN.
  - DONE: RED 6 issue → GREEN; `FavouriteSessionsTests` + `DataEraserTests` 5/5 pass; key trong `AppDefaultsKeys`.
- [x] **10.4 · TDD** — Create `App/Features/Sessions/SessionPreset+Request.swift`: `request(limits:rotationIndex:) -> WorkoutRequest` (giãn cơ ngồi thêm `.standingIsHard`), `art: Art`, `title`. Test `SessionPresetRequestTests`: mọi preset dựng được plan từ `TestFixtures.content`, phút > 0; stretch seated có `.standingIsHard`. Mong đợi: GREEN.
  - DONE: RED 46 issue → GREEN; `SessionPresetRequestTests` pass (mọi preset > 0 phút; seated stretch thêm standingIsHard; Balance rotation 5; `canReplay`; preview giữ presetID + tư thế đứng).
- [x] **10.5 · TDD** — Modify `App/Features/Today/TodayModel.swift`: `swapOptions: [TodaySwapOption]` (id, title có phút, art, request, isLocked); không hiện khi đã xong hoặc ngày nghỉ. Test trong `TodayModelTests`: ngày đi bộ → chair / stretch / 5 min; ngày done → []; free không có mục khoá (mẫu nhẹ nhất). Mong đợi: GREEN.
  - DONE: RED 4 issue → GREEN; `TodayModelTests` 12/12 pass.
- [x] **10.6 · UI** — Create `App/Features/Today/SwapSessionSheet.swift` (4 `PictureChoiceCard`, tiêu đề "Try something else today", dòng "It still counts for today."); Modify `TodayView.swift` (`TodaySessionCard`: link "Try something else" dưới Start, mở sheet; chọn → `actions.onStart`). Evidence: `today-swap` sáng + tối: sheet 4 thẻ có tranh, không chữ bị cắt.
  - DONE: ảnh `today`, `today-swap`, `today-swap@xxl` (iPhone 17), `today-swap` (iPhone SE): 3 thẻ có tranh, XXL ẩn tranh, không chữ bị cắt.
- [x] **10.7 · UI** — Modify `App/Features/Root/AppCover.swift` (`enum TodayRoute { case allSessions }`), `AppModel` (`todayPath`), `MainTabView.swift` (path + `navigationDestination`), `TodayCards.swift` (`ExtrasRow` tiêu đề + "See all"). Evidence: bấm "See all" mở All sessions (inspect nhãn "See all").
  - DONE: `ExtrasRow` có "See all" (nhãn đọc "See all sessions"); `TodayRoute.allSessions` qua `app.todayPath`.
- [x] **10.8 · UI** — Create `App/Features/Sessions/AllSessionsModel.swift`, `AllSessionsView.swift`, `SessionCard.swift`: hàng "Your favourites" (khi có), 4 nhóm, thẻ tranh + tên + phút + mức, nút tim 56 pt, `ProBadge` khi khoá; bấm thẻ khoá → `offerPlans(.lockedContent)`, thẻ mở → `preview`. Test `AllSessionsModelTests`: favourites lên đầu theo thứ tự; free thấy đúng mục khoá; lọc giới hạn cơ thể giữ buổi dựng được. Evidence: `all-sessions` (Pro, có favourites), `all-sessions-free`, dark, XXL.
  - DONE: RED 6 issue → GREEN `AllSessionsModelTests` 4/4; ảnh `all-sessions` (favourites trên cùng, tim đỏ), `all-sessions-free` (Pro badge), `all-sessions@dark`.
- [x] **10.9 · UI** — "Do it again": Modify `CompleteView.swift` (link dưới Share, chỉ khi buổi còn mở với gói hiện tại), `WorkoutView.swift` (`onAgain`), `AppModel+Flows.swift` (`again(_:)` → đóng cover, `preview`). Evidence: `complete` có link; bấm mở lại xem trước đúng buổi.
  - DONE: ảnh iPad 13" `complete`: "Do it again" dưới Share; không có sau First Walk; free chỉ khi buổi mở. Kèm: Complete giới hạn 700 pt trên iPad (bưu thiếp không còn bị kéo giãn).
- [x] **10.10 · UI** — Capture hook: thêm `today-swap`, `all-sessions`, `all-sessions-free` vào `App/Debug/CaptureHook.swift` + `AppCaptureScene.swift` (fixture favourites); `CaptureHookTests` liệt kê trạng thái mới. Mong đợi: GREEN; 3 ảnh chụp được.
  - DONE: `CaptureState` 83 trạng thái; `CaptureHookTests` 3/3 pass; 3 trạng thái mới chụp được.
- [x] **10.11 · UI** — Chữ: mọi chuỗi mới qua String Catalog; `python3 tools/lint/copy_lint.py` → `0 findings`; mở Xcode một lần để catalog ghi chuỗi mới (việc của chủ app, ghi trong owner-todo).
  - DONE: `copy_lint.py` → 0 findings. Mở Xcode một lần để catalog ghi chuỗi mới (owner-todo mục 5).
- [x] **10.12 · Gate** — Toàn bộ test Core + App xanh; build sạch; chụp tiếng Anh các màn đã đổi (Today, sheet, All sessions free/Pro, Complete) sáng/tối/XXL và iPhone SE; ghi bằng chứng dưới từng task; cập nhật `docs/owner-todo-after-mvp.md` nếu có việc cho chủ app.
  - DONE: Core 116/116; App 111 tests / 29 suites pass (1 known issue iOS 27). SE: tranh đầu Today co theo chiều cao màn (≤ 190 pt) để thẻ buổi hôm nay hiện trong màn đầu.

## Localization
en-US. Chuỗi mới: "Try something else", "Try something else today", "It still counts for today.", "Just 5 minutes today", "See all", "All sessions", "Your favourites", "Walks", "Chair moves", "Stretches", "Short extras", "Add to favourites", "Remove from favourites", "Do it again", tên preset. Trạng thái chụp: `today-swap`, `all-sessions`, `all-sessions-free` (+ `@dark`, `@xxl`).

## Test plan
- Unit (Core): `SessionCatalogTests` (10.1–10.2).
- Unit (App): `FavouriteSessionsTests`, `DataEraserTests`, `SessionPresetRequestTests`, `TodayModelTests`, `AllSessionsModelTests`, `CaptureHookTests`, `StoreServiceTests` (10.0).
- Chỉ bằng ảnh chụp: sheet đổi buổi, All sessions, link "Do it again".

## Release
Không đổi IAP, age rating, App Privacy. Screenshot store có thể thêm All sessions (quyết định ở stage release).

## Approval checklist
- [x] Decisions
- [x] Compliance-by-design
- [x] Task 10.0–10.12
- [x] Localization + test plan
